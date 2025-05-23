﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Mvc;

using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Helper.BusinessOperation;
using WebHome.Controllers;
using System.Runtime.Caching;

namespace WebHome.Helper
{
    public static partial class BusinessConsoleExtensions
    {
        public static MonthlyIndicator InitializeMonthlyIndicator(this GenericManager<BFDataContext> models, int year, int month, bool? forcedPrepare = null)
                
        {
            DateTime startDate = new DateTime(year, month, 1);
            DateTime lastPeriod = startDate.AddMonths(-1);

            var sampleItem = models.GetTable<MonthlyIndicator>()
                                .Where(i => i.StartDate == lastPeriod).FirstOrDefault();

            if (sampleItem == null)
            {
                sampleItem = models.GetTable<MonthlyIndicator>()
                    .OrderBy(m => m.PeriodID).FirstOrDefault();
            }

            if (sampleItem == null)
                return null;

            MonthlyIndicator item = models.GetTable<MonthlyIndicator>().Where(i => i.Year == year && i.Month == month).FirstOrDefault();
            if (item == null)
            {
                item = new MonthlyIndicator
                {
                    Year = year,
                    Month = month,
                    StartDate = startDate,
                    EndExclusiveDate = startDate.AddMonths(1),
                };

                models.GetTable<MonthlyIndicator>().InsertOnSubmit(item);
            }

            foreach (var r in sampleItem.MonthlyRevenueIndicator)
            {
                MonthlyRevenueIndicator newItem = item.MonthlyRevenueIndicator.Where(i => i.GradeID == r.GradeID).FirstOrDefault();
                if (newItem != null)
                {
                    if (newItem.MonthlyRevenueGoal != null)
                        continue;
                }
                else
                {
                    newItem = new MonthlyRevenueIndicator
                    {
                        MonthlyIndicator = item,
                        RevenueGoal = r.RevenueGoal,
                        GradeID = r.GradeID,
                    };
                }


                if (r.MonthlyRevenueGoal != null)
                {
                    newItem.MonthlyRevenueGoal = new MonthlyRevenueGoal
                    {
                        CustomIndicatorPercentage = r.MonthlyRevenueGoal.CustomIndicatorPercentage,
                        CustomRevenueGoal = r.MonthlyRevenueGoal.CustomRevenueGoal,
                        NewContractCount = r.MonthlyRevenueGoal.NewContractCount,
                        RenewContractCount = r.MonthlyRevenueGoal.RenewContractCount,
                        NewContractSubtotal = r.MonthlyRevenueGoal.NewContractSubtotal,
                        RenewContractSubtotal = r.MonthlyRevenueGoal.RenewContractSubtotal,
                        InstallmentCount = r.MonthlyRevenueGoal.InstallmentCount,
                        InstallmentSubtotal = r.MonthlyRevenueGoal.InstallmentSubtotal,
                        LessonTuitionIndicatorPercentage = r.MonthlyRevenueGoal.LessonTuitionIndicatorPercentage,
                    };
                }
            }

            foreach (var b in sampleItem.MonthlyBranchIndicator)
            {
                MonthlyBranchIndicator newBranchItem = item.MonthlyBranchIndicator.Where(i => i.BranchID == b.BranchID).FirstOrDefault();
                if (newBranchItem == null)
                {
                    newBranchItem = new MonthlyBranchIndicator
                    {
                        MonthlyIndicator = item,
                        BranchID = b.BranchID,
                    };
                }

                foreach (var r in b.MonthlyBranchRevenueIndicator)
                {
                    MonthlyBranchRevenueIndicator newItem = newBranchItem.MonthlyBranchRevenueIndicator.Where(i => i.GradeID == r.GradeID).FirstOrDefault();
                    if (newItem != null)
                    {
                        if (newItem.MonthlyBranchRevenueGoal != null)
                            continue;
                    }
                    else
                    {
                        newItem = new MonthlyBranchRevenueIndicator
                        {
                            MonthlyBranchIndicator = newBranchItem,
                            GradeID = r.GradeID,
                            RevenueGoal = r.RevenueGoal,
                        };
                    }

                    var branchGoal = r.MonthlyBranchRevenueGoal;
                    if (branchGoal != null)
                    {
                        newItem.MonthlyBranchRevenueGoal = new MonthlyBranchRevenueGoal
                        {
                            LessonTuitionGoal = branchGoal.LessonTuitionGoal,
                            CompleteLessonsGoal = branchGoal.CompleteLessonsGoal,
                            AchievementGoal = branchGoal.AchievementGoal,
                            CustomRevenueGoal = branchGoal.CustomRevenueGoal,
                            CustomIndicatorPercentage = branchGoal.CustomIndicatorPercentage,
                            LessonTuitionIndicatorPercentage = branchGoal.LessonTuitionIndicatorPercentage,
                            NewContractCount = branchGoal.NewContractCount,
                            RenewContractCount = branchGoal.RenewContractCount,
                            NewContractSubtotal = branchGoal.NewContractSubtotal,
                            RenewContractSubtotal = branchGoal.RenewContractSubtotal,
                            InstallmentCount = branchGoal.InstallmentCount,
                            InstallmentSubtotal = branchGoal.InstallmentSubtotal,
                        };
                    }
                }
            }

            if (forcedPrepare == true)
            {
                foreach (var c in sampleItem.MonthlyCoachRevenueIndicator)
                {
                    MonthlyCoachRevenueIndicator newItem = item.MonthlyCoachRevenueIndicator.Where(i => i.CoachID == c.CoachID).FirstOrDefault();
                    if (newItem != null)
                        continue;

                    int actualCount = c.ActualCompleteLessonCount ?? 0;

                    newItem = new MonthlyCoachRevenueIndicator
                    {
                        MonthlyIndicator = item,
                        CoachID = c.CoachID,
                        BranchID = c.BranchID,
                        AchievementGoal = c.AchievementGoal,
                        CompleteLessonsGoal = c.CompleteLessonsGoal,
                        LessonTuitionGoal = c.LessonTuitionGoal,
                        //BRCount = c.BRCount,
                        LevelID = c.ServingCoach.LevelID,
                        //AverageLessonPrice = actualCount > 0
                        //    ? (c.ActualLessonAchievement + c.ActualCompleteLessonCount - 1) / actualCount
                        //    : 0,
                        AverageLessonPrice = sampleItem.CalculateAverageLessonPrice(models, c.CoachID),
                        AdjustActualBRCount = 0,
                        AdjustDealedCountWithBR = 0,
                        AdjustTrialDealedCount = 0,
                    };
                    newItem.LessonTuitionGoal = newItem.CompleteLessonsGoal * newItem.AverageLessonPrice;

                    models.GetTable<MonthlyCoachLearnerReview>()
                        .InsertOnSubmit(new MonthlyCoachLearnerReview
                        {
                            MonthlyIndicator = item,
                            CoachID = c.CoachID,
                        });
                }
            }

            models.SubmitChanges();

            return item;

        }

        public static MonthlyIndicator AssertMonthlyIndicator(this MonthlyIndicatorQueryViewModel viewModel, GenericManager<BFDataContext> models)
                
        {
            var item = models.GetTable<MonthlyIndicator>().Where(i => i.PeriodID == viewModel.PeriodID).FirstOrDefault();
            if (item != null)
                return item;

            item = models.GetTable<MonthlyIndicator>().Where(i => (i.Year == viewModel.Year && i.Month == viewModel.Month)).FirstOrDefault();
            if (item != null)
                return item;

            item = models.InitializeMonthlyIndicator(viewModel.Year.Value, viewModel.Month.Value);

            return item;
        }

        public static MonthlyIndicator GetAlmostMonthlyIndicator(this MonthlyIndicatorQueryViewModel viewModel, GenericManager<BFDataContext> models, bool? exact = null)
                
        {
            var item = models.GetTable<MonthlyIndicator>().Where(i => i.PeriodID == viewModel.PeriodID).FirstOrDefault();
            if (item != null)
            {
                return item;
            }

            item = models.GetTable<MonthlyIndicator>().Where(i => (i.Year == viewModel.Year && i.Month == viewModel.Month)).FirstOrDefault();
            if (item != null)
            {
                return item;
            }

            if (exact == true)
            {
                return null;
            }

            DateTime period = viewModel.Year.HasValue && viewModel.Month.HasValue
                    ? new DateTime(viewModel.Year.Value, viewModel.Month.Value, 1)
                    : DateTime.Today;

            item = models.GetTable<MonthlyIndicator>().Where(i => i.StartDate <= period)
                        .OrderByDescending(i => i.StartDate).FirstOrDefault();

            if (item != null)
            {
                return item;
            }

            item = models.GetTable<MonthlyIndicator>().Where(i => i.StartDate > period)
                        .OrderBy(i => i.StartDate).FirstOrDefault();

            return item;
        }

        public static IQueryable<Payment> UpdateVoidShare(this GenericManager<BFDataContext> models, DateTime startDate, DateTime endExclusiveDate)
        {

            var voidPayment = models.GetTable<VoidPayment>().Where(p => p.VoidDate >= startDate && p.VoidDate < endExclusiveDate)
                                .Join(models.GetTable<Payment>().Where(p => p.AllowanceID.HasValue), v => v.VoidID, p => p.PaymentID, (v, p) => p);
            //.FilterByEffective();
            foreach (var voidItem in voidPayment)
            {
                if (voidItem.TuitionAchievement.Any())
                {
                    var voidAmt = (int?)(voidItem.InvoiceAllowance.TotalAmount + voidItem.InvoiceAllowance.TaxAmount);
                    var totalShare = voidItem.TuitionAchievement.Sum(t => t.ShareAmount) ?? 1;

                    foreach (var t in voidItem.TuitionAchievement)
                    {
                        t.VoidShare = (int?)((decimal?)voidAmt * (decimal?)t.ShareAmount / totalShare);
                    }
                }
                models.SubmitChanges();
            }

            return voidPayment;
        }

        public static void UpdateMonthlyAchievement(this MonthlyIndicator item, GenericManager<BFDataContext> models, bool? forcedUpdate = null, bool? calcAverage = null)

        {

            AchievementQueryViewModel queryModel = new AchievementQueryViewModel
            {
                AchievementDateFrom = item.StartDate,
                BypassCondition = true,
            };

            IQueryable<Payment> voidPayment = UpdateVoidShare(models, item.StartDate, item.EndExclusiveDate);

            IQueryable<V_Tuition> lessonItems = queryModel.InquireAchievement(models);
            IQueryable<LessonTime> STItems = models.GetTable<LessonTime>()
                .Where(c => c.ClassTime >= item.StartDate)
                .Where(c => c.ClassTime < item.StartDate.AddMonths(1))
                .Where(t => t.TrainingBySelf == 2);

            IQueryable<LessonTime> GroupXItems = models.GetTable<LessonTime>()
                .Where(c => c.ClassTime >= item.StartDate)
                .Where(c => c.ClassTime < item.StartDate.AddMonths(1))
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.團體課程);


            if (forcedUpdate == true)
            {
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
                GroupXItems = GroupXItems.Join(models.GetTable<LessonTimeSettlement>()
                    .Where(t => t.SettlementID.HasValue), l => l.LessonID, t => t.LessonID, (l, t) => l);
            }
            else if (item.StartDate == DateTime.Today.FirstDayOfMonth())
            {
                lessonItems = lessonItems.Where(l => l.ClassTime < DateTime.Today.AddDays(1));
                GroupXItems = GroupXItems.Where(l => l.ClassTime < DateTime.Today.AddDays(1));
            }
            else
            {
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
                GroupXItems = GroupXItems.Join(models.GetTable<LessonTimeSettlement>()
                    .Where(t => t.SettlementID.HasValue), l => l.LessonID, t => t.LessonID, (l, t) => l);
            }

            IQueryable<V_Tuition> tuitionItems = lessonItems;

            PaymentQueryViewModel paymentQuery = new PaymentQueryViewModel
            {
                PayoffDateFrom = item.StartDate,
                PayoffDateTo = item.EndExclusiveDate.AddDays(-1),
                BypassCondition = true,
            };

            IQueryable<Payment> paymentItems = paymentQuery.InquirePayment(models);
            IQueryable<TuitionAchievement> achievementItems = paymentItems.GetPaymentAchievement(models);

            CourseContractQueryViewModel contractQuery = new CourseContractQueryViewModel
            {
                ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                //Status = (int)Naming.CourseContractStatus.已生效,
                EffectiveDateFrom = item.StartDate,
                EffectiveDateTo = item.EndExclusiveDate,
            };
            IQueryable<CourseContract> contractItems =
                contractQuery.InquireContract(models)
                    .Where(c => c.Status != (int)Naming.CourseContractStatus.已終止);
            IQueryable<CourseContract> BRCountingItems = contractItems.Where(c => !c.Installment.HasValue || c.Installment == false);
            IQueryable<CourseContract> installmentItems = contractItems.Where(c => c.Installment.HasValue);
            IQueryable<CourseContract> nonInstallmentItems = contractItems.Where(c => !c.Installment.HasValue);

            int lessonAchievement, tuitionAchievement;
            var level_FM_FES_CEO = models.GetTable<ProfessionalLevel>()
                                        .Where(p => p.CategoryID == (int)Naming.ProfessionalCategory.FM
                                            || p.CategoryID == (int)Naming.ProfessionalCategory.FES
                                            || p.CategoryID == (int)Naming.ProfessionalCategory.Special);
            IQueryable<V_Tuition> exclusive_FM_FES_Items;

            void calcHeadquarterAchievement()
            {
                var voidTuition = voidPayment
                                    .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);
                exclusive_FM_FES_Items = tuitionItems.Where(t => !level_FM_FES_CEO.Any(l => l.LevelID == t.ProfessionalLevelID));

                lessonAchievement = exclusive_FM_FES_Items.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                lessonAchievement += (exclusive_FM_FES_Items.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                tuitionAchievement = achievementItems.Sum(a => a.ShareAmount) ?? 0;

                IQueryable<TuitionAchievement> newContractAchievementItems = paymentItems
                    .Join(models.GetTable<ContractPayment>()
                            .Join(models.GetTable<CourseContract>()
                                .Where(t => !t.Installment.HasValue)
                                .Where(t => !t.Renewal.HasValue || t.Renewal != true),
                                c => c.ContractID, t => t.ContractID, (c, t) => c),
                        p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                    .GetPaymentAchievement(models);

                IQueryable<TuitionAchievement> renewContractAchievementItems = paymentItems
                    .Join(models.GetTable<ContractPayment>()
                            .Join(models.GetTable<CourseContract>()
                                .Where(t => !t.Installment.HasValue)
                                .Where(t => t.Renewal == true),
                                c => c.ContractID, t => t.ContractID, (c, t) => c),
                        p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                    .GetPaymentAchievement(models);

                IQueryable<TuitionAchievement> installmentContractAchievementItems = paymentItems
                    .Join(models.GetTable<ContractPayment>()
                            .Join(models.GetTable<CourseContract>()
                                .Where(t => t.Installment.HasValue),
                                c => c.ContractID, t => t.ContractID, (c, t) => c),
                        p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                    .GetPaymentAchievement(models);

                var revenueItem = item.MonthlyRevenueIndicator.Where(r => r.MonthlyRevenueGoal != null)
                        .Select(r => r.MonthlyRevenueGoal)
                        .FirstOrDefault();
                if (revenueItem != null)
                {
                    revenueItem.ActualCompleteLessonCount = exclusive_FM_FES_Items.SessionScopeForComleteLesson(models).Count();
                    revenueItem.ActualLessonAchievement = lessonAchievement;
                    revenueItem.ActualSharedAchievement = tuitionAchievement;
                    revenueItem.RenewContractCount = nonInstallmentItems.Where(c => c.Renewal == true).Count();
                    revenueItem.NewContractCount = nonInstallmentItems.Count() - revenueItem.RenewContractCount;
                    revenueItem.RenewContractSubtotal = nonInstallmentItems.Where(c => c.Renewal == true).Sum(c => c.TotalCost) ?? 0;
                    revenueItem.NewContractSubtotal = nonInstallmentItems.Sum(c => c.TotalCost) - revenueItem.RenewContractSubtotal;
                    revenueItem.InstallmentCount = installmentItems.Count();
                    revenueItem.InstallmentSubtotal = installmentItems.Sum(c => c.TotalCost) ?? 0;

                    revenueItem.ActualCompleteTSCount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                    + tuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                    revenueItem.ActualCompletePICount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                    + tuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                    revenueItem.NewContractAchievement = newContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                    revenueItem.RenewContractAchievement = renewContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                    revenueItem.InstallmentAchievement = installmentContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                    revenueItem.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;
                    revenueItem.ATCount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Count();
                    revenueItem.ATAchievement = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Sum(t => t.ListPrice) ?? 0;
                    revenueItem.SRCount = tuitionItems.SRSessionScope(models).Count();
                    revenueItem.SRAchievement = tuitionItems.SRSessionScope(models).Sum(t => t.ListPrice) ?? 0;
                    revenueItem.SDCount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Count();
                    revenueItem.SDAchievement = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Sum(t => t.ListPrice) ?? 0;
                    revenueItem.GroupXCount = GroupXItems.GroupBy(l => new { l.ClassTime, l.AttendingCoach }).Count();
                    revenueItem.GroupXAchievement = GroupXItems.Sum(t => t.RegisterLesson.LessonPriceType.ListPrice) ?? 0;

                    models.SubmitChanges();
                }
            }

            void calcBranchAchievement()
            {
                foreach (var branchIndicator in item.MonthlyBranchIndicator)
                {
                    var voidTuition = voidPayment
                        .Join(models.GetTable<TuitionAchievement>(), 
                            p => p.PaymentID, t => t.InstallmentID, (p, t) => t)
                        .Where(t => t.CoachWorkPlace == branchIndicator.BranchID);

                    var branchTuitionItems = tuitionItems.Where(t => t.BranchID == branchIndicator.BranchID);
                    var branchAchievementItems = achievementItems.Where(t => t.CoachWorkPlace == branchIndicator.BranchID);
                    var branchContractItems = contractItems.Where(c => c.CourseContractExtension.BranchID == branchIndicator.BranchID);
                    var branchInstallmentItems = installmentItems.Where(c => c.CourseContractExtension.BranchID == branchIndicator.BranchID);
                    var branchNonInstallmentItems = nonInstallmentItems.Where(c => c.CourseContractExtension.BranchID == branchIndicator.BranchID);
                    var branchGroupXItems = GroupXItems.Where(t => t.BranchID == branchIndicator.BranchID);

                    IQueryable<TuitionAchievement> branchNewContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => !t.Installment.HasValue)
                                    .Where(t => !t.Renewal.HasValue || t.Renewal != true),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachWorkPlace == branchIndicator.BranchID);

                    IQueryable<TuitionAchievement> branchRenewContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => !t.Installment.HasValue)
                                    .Where(t => t.Renewal == true),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachWorkPlace == branchIndicator.BranchID);

                    IQueryable<TuitionAchievement> branchInstallmentContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => t.Installment.HasValue),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachWorkPlace == branchIndicator.BranchID);

                    var revenueItem = branchIndicator.MonthlyBranchRevenueIndicator
                            .Where(v => v.MonthlyBranchRevenueGoal != null)
                            .FirstOrDefault()?.MonthlyBranchRevenueGoal;
                    if (revenueItem != null)
                    {
                        exclusive_FM_FES_Items = branchTuitionItems.Where(t => !level_FM_FES_CEO.Any(l => l.LevelID == t.ProfessionalLevelID));
                        lessonAchievement = exclusive_FM_FES_Items.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                        lessonAchievement += (exclusive_FM_FES_Items.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                        tuitionAchievement = branchAchievementItems.Sum(a => a.ShareAmount) ?? 0;

                        revenueItem.ActualCompleteLessonCount = exclusive_FM_FES_Items.SessionScopeForComleteLesson(models).Count();
                        revenueItem.ActualLessonAchievement = lessonAchievement;
                        revenueItem.ActualSharedAchievement = tuitionAchievement;
                        revenueItem.RenewContractCount = branchNonInstallmentItems.Where(c => c.Renewal == true).Count();
                        revenueItem.NewContractCount = branchNonInstallmentItems.Count() - revenueItem.RenewContractCount;
                        revenueItem.RenewContractSubtotal = branchNonInstallmentItems.Where(c => c.Renewal == true).Sum(c => c.TotalCost) ?? 0;
                        revenueItem.NewContractSubtotal = branchNonInstallmentItems.Sum(c => c.TotalCost) - revenueItem.RenewContractSubtotal;
                        revenueItem.InstallmentCount = branchInstallmentItems.Count();
                        revenueItem.InstallmentSubtotal = branchInstallmentItems.Sum(c => c.TotalCost) ?? 0;

                        revenueItem.ActualCompleteTSCount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                        + branchTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                        revenueItem.ActualCompletePICount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                        + branchTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                        revenueItem.NewContractAchievement = branchNewContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                        revenueItem.RenewContractAchievement = branchRenewContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                        revenueItem.InstallmentAchievement = branchInstallmentContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                        revenueItem.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;
                        revenueItem.ATCount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Count();
                        revenueItem.ATAchievement = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Sum(t => t.ListPrice) ?? 0;
                        revenueItem.SRCount = branchTuitionItems.SRSessionScope(models).Count();
                        revenueItem.SRAchievement = branchTuitionItems.SRSessionScope(models).Sum(t => t.ListPrice) ?? 0;
                        revenueItem.SDCount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Count();
                        revenueItem.SDAchievement = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Sum(t => t.ListPrice) ?? 0;
                        revenueItem.GroupXCount = branchGroupXItems.GroupBy(l=>new { l.ClassTime, l.AttendingCoach }).Count();
                        revenueItem.GroupXAchievement = branchGroupXItems.Sum(t => t.RegisterLesson.LessonPriceType.ListPrice) ?? 0;

                        models.SubmitChanges();
                    }
                }
            }

            void calcCoachAchievement()
            {
                foreach (var coachIndicator in item.MonthlyCoachRevenueIndicator)
                {
                    var voidTuition = voidPayment
                        .Join(models.GetTable<TuitionAchievement>()
                            .Where(t => t.CoachID == coachIndicator.CoachID),
                            p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                    var coachTuitionItems = tuitionItems.Where(t => t.AttendingCoach == coachIndicator.CoachID);
                    var coachAchievementItems = achievementItems.Where(t => t.CoachID == coachIndicator.CoachID);
                    var coachContractItems = contractItems.Where(c => c.FitnessConsultant == coachIndicator.CoachID);
                    IQueryable<CourseContract> coachInstallmentItems = coachContractItems.Where(c => c.Installment.HasValue);
                    IQueryable<CourseContract> coachNonInstallmentItems = coachContractItems.Where(c => !c.Installment.HasValue);

                    var coachSTItems = STItems.Where(t => t.AttendingCoach == coachIndicator.CoachID);
                    var coachGroupXItems = GroupXItems.Where(t => t.AttendingCoach == coachIndicator.CoachID);

                    IQueryable<TuitionAchievement> coachNewContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => !t.Installment.HasValue)
                                    .Where(t => !t.Renewal.HasValue || t.Renewal != true),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachID == coachIndicator.CoachID);

                    IQueryable<TuitionAchievement> coachRenewContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => !t.Installment.HasValue)
                                    .Where(t => t.Renewal == true),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachID == coachIndicator.CoachID);

                    IQueryable<TuitionAchievement> coachInstallmentContractAchievementItems = paymentItems
                        .Join(models.GetTable<ContractPayment>()
                                .Join(models.GetTable<CourseContract>()
                                    .Where(t => t.Installment.HasValue),
                                    c => c.ContractID, t => t.ContractID, (c, t) => c),
                            p => p.PaymentID, c => c.PaymentID, (p, c) => p)
                        .GetPaymentAchievement(models)
                        .Where(t => t.CoachID == coachIndicator.CoachID);


                    lessonAchievement = coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                    lessonAchievement += (coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                    tuitionAchievement = coachAchievementItems.Sum(a => a.ShareAmount) ?? 0;

                    coachIndicator.ActualCompleteLessonCount = coachTuitionItems.SessionScopeForComleteLesson(models).Count();
                    coachIndicator.PTCount = coachTuitionItems.SessionScopeForComleteLesson(models).Count();
                    coachIndicator.ActualLessonAchievement = lessonAchievement;
                    coachIndicator.ActualRenewContractAchievement = coachRenewContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                    coachIndicator.ActualNewContractAchievement = coachNewContractAchievementItems.Sum(t => t.ShareAmount) ?? 0;
                    coachIndicator.ActualCompleteTSCount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();

                    var property = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.一般課程);
                    coachIndicator.ExamTrialCount = coachTuitionItems
                                    .Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                                    .Where(t => property.Any(p => t.PriceID == p.PriceID))
                                    .Count();

                    property = models.GetTable<LessonPriceProperty>().Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.BR體驗);
                    coachIndicator.BRTrialCount = coachTuitionItems
                                    .Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                                    .Where(t => property.Any(p => t.PriceID == p.PriceID))
                                    .Count();

                    coachIndicator.ActualCompletePICount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                    var shareSummary = item.GetPaymentAchievementSummary(models, coachIndicator.CoachID);
                    var voidItems = item.GetVoidShare(models, coachIndicator.CoachID);
                    coachIndicator.InstallmentAchievement = shareSummary - (voidItems.Sum(t => t.VoidShare) ?? 0);

                    coachIndicator.RenewContractCount = coachNonInstallmentItems.Where(t => t.Renewal == true).Count();
                    coachIndicator.NewContractCount = coachNonInstallmentItems.Count() - coachIndicator.RenewContractCount;
                    coachIndicator.RenewContractSubtotal = coachNonInstallmentItems.Where(c => c.Renewal == true).Sum(c => c.TotalCost) ?? 0;
                    coachIndicator.NewContractSubtotal = coachNonInstallmentItems.Sum(c => c.TotalCost) - coachIndicator.RenewContractSubtotal;
                    coachIndicator.InstallmentCount = coachInstallmentItems.Count();
                    coachIndicator.InstallmentSubtotal = coachInstallmentItems.Sum(c => c.TotalCost) ?? 0;


                    if (calcAverage == true)
                    {
                        coachIndicator.AverageLessonPrice = item.CalculateAverageLessonPrice(models, coachIndicator.CoachID);
                        coachIndicator.LessonTuitionGoal = coachIndicator.CompleteLessonsGoal * coachIndicator.AverageLessonPrice;
                    }

                    coachIndicator.STCount = coachSTItems.Count();
                    coachIndicator.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;
                    coachIndicator.ATCount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Count();
                    coachIndicator.ATAchievement = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.運動防護課程).Sum(t => t.ListPrice) ?? 0;
                    coachIndicator.SRCount = coachTuitionItems.SRSessionScope(models).Count();
                    coachIndicator.SRAchievement = coachTuitionItems.SRSessionScope(models).Sum(t => t.ListPrice) ?? 0;
                    coachIndicator.SDCount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Count();
                    coachIndicator.SDAchievement = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.營養課程).Sum(t => t.ListPrice) ?? 0;
                    var extensionItems = models.GetTable<CourseContractExtension>()
                                            .Where(n => n.BRByCoach == coachIndicator.CoachID);
                    coachIndicator.ActualBRCount = BRCountingItems.Where(c => extensionItems.Any(n => n.ContractID == c.ContractID))
                                                    .Sum(c => c.CourseContractType.GroupingMemberCount) ?? 0;
                    extensionItems = models.GetTable<CourseContractExtension>()
                                                                .Where(n => n.BRByCoach.HasValue || n.BRByLearner.HasValue);
                    coachIndicator.DealedCountWithBR = coachContractItems.Where(c => extensionItems.Any(n => n.ContractID == c.ContractID))
                                                            .Sum(c => c.CourseContractType.GroupingMemberCount) ?? 0;
                    extensionItems = models.GetTable<CourseContractExtension>()
                                                                .Where(n => !n.BRByCoach.HasValue);
                    coachIndicator.TrialDealedCount = BRCountingItems
                                    .Where(c => c.FitnessConsultant == coachIndicator.CoachID)
                                    .Where(c => c.Renewal == false)
                                    .Where(c => extensionItems.Any(n => n.ContractID == c.ContractID))
                                    .Sum(c => c.CourseContractType.GroupingMemberCount) ?? 0;
                    coachIndicator.GroupXCount = coachGroupXItems.GroupBy(l => l.ClassTime).Count();
                    coachIndicator.GroupXAchievement = coachGroupXItems.Sum(t => t.RegisterLesson.LessonPriceType.ListPrice) ?? 0;

                    models.SubmitChanges();
                }
            }

            calcHeadquarterAchievement();
            calcBranchAchievement();
            calcCoachAchievement();
        }

        public static int CalculateAverageLessonPrice(this MonthlyIndicator item, GenericManager<BFDataContext> models, int? coachID)
            
        {
            AchievementQueryViewModel queryModel = new AchievementQueryViewModel
            {
                AchievementDateFrom = item.StartDate.AddMonths(-1),
                BypassCondition = true,
            };

            IQueryable<V_Tuition> lessonItems = queryModel.InquireAchievement(models);

            if (item.StartDate == DateTime.Today.FirstDayOfMonth())
            {
                lessonItems = lessonItems.Where(l => l.ClassTime < DateTime.Today);
            }
            else
            {
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
            }

            IQueryable<V_Tuition> tuitionItems = lessonItems;
            int lessonAchievement;
            var coachTuitionItems = tuitionItems.Where(t => t.AttendingCoach == coachID);
            lessonAchievement = coachTuitionItems.Where(t => GeneralPTSessionScope.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
            lessonAchievement += (coachTuitionItems.Where(t => GeneralPTSessionScope.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);

            var completeLessonCount = Math.Max(coachTuitionItems.Where(t => GeneralPTSessionScope.Contains(t.PriceStatus)).Count()
                                    + coachTuitionItems.Where(t => GeneralPTSessionScope.Contains(t.ELStatus)).Count(), 1);

            return (lessonAchievement + completeLessonCount - 1) / completeLessonCount;
        }

        public static void UpdateMonthlyAchievementGoal(this MonthlyIndicator item, GenericManager<BFDataContext> models)
            
        {
            IQueryable<MonthlyCoachRevenueIndicator> coachItems = models.GetTable<MonthlyCoachRevenueIndicator>().Where(r => r.PeriodID == item.PeriodID);
            List<MonthlyBranchRevenueGoal> branchGoalItems = new List<MonthlyBranchRevenueGoal>();
            foreach (var branchIndicator in item.MonthlyBranchIndicator)
            {
                var revenueGoal = branchIndicator.MonthlyBranchRevenueIndicator.Where(r => r.MonthlyBranchRevenueGoal != null)
                                    .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();
                if (revenueGoal == null)
                    continue;

                var branchItems = coachItems.Where(c => c.BranchID == branchIndicator.BranchID);
                revenueGoal.CustomRevenueGoal = branchItems.Sum(b => b.LessonTuitionGoal /*+ b.AchievementGoal*/);

                var baseIndicator = branchIndicator.MonthlyBranchRevenueIndicator.OrderBy(m => m.GradeID).First();
                revenueGoal.CustomIndicatorPercentage = Math.Round(((decimal?)revenueGoal.CustomRevenueGoal * (decimal?)baseIndicator.MonthlyRevenueGrade.IndicatorPercentage / (decimal?)baseIndicator.RevenueGoal) ?? 0m, 2);
                revenueGoal.LessonTuitionIndicatorPercentage = Math.Round(((decimal?)revenueGoal.LessonTuitionGoal * (decimal?)baseIndicator.MonthlyRevenueGrade.IndicatorPercentage / (decimal?)baseIndicator.RevenueGoal) ?? 0m, 2);

                revenueGoal.AchievementGoal = branchItems.Sum(b => b.AchievementGoal);
                var branchPTItems = branchItems
                                        .Where(b => b.ServingCoach.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Health)
                                        .Where(b => b.ServingCoach.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM);
                var branchSRItems = branchItems.Where(b => b.ServingCoach.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Health);
                revenueGoal.CompleteLessonsGoal = branchPTItems.Sum(b => b.CompleteLessonsGoal);
                revenueGoal.SRLessonsGoal = branchSRItems.Sum(b => b.CompleteLessonsGoal);
                revenueGoal.LessonTuitionGoal = branchPTItems.Sum(b => b.LessonTuitionGoal);
                revenueGoal.SRLessonTuitionGoal = branchSRItems.Sum(b => b.LessonTuitionGoal);

                models.SubmitChanges();
                branchGoalItems.Add(revenueGoal);
            }

            var headquarterRevenueGoal = item.MonthlyRevenueIndicator.Where(r => r.MonthlyRevenueGoal != null)
                                            .Select(r => r.MonthlyRevenueGoal).FirstOrDefault();

            if (headquarterRevenueGoal != null)
            {
                headquarterRevenueGoal.CustomRevenueGoal = branchGoalItems.Sum(b => b.CustomRevenueGoal);
                var baseIndicator = item.MonthlyRevenueIndicator.OrderBy(r => r.GradeID).First();
                headquarterRevenueGoal.CustomIndicatorPercentage = Math.Round((decimal)headquarterRevenueGoal.CustomRevenueGoal * (decimal)baseIndicator.MonthlyRevenueGrade.IndicatorPercentage / (decimal)baseIndicator.RevenueGoal, 2);
                headquarterRevenueGoal.AchievementGoal = branchGoalItems.Sum(b => b.AchievementGoal);
                headquarterRevenueGoal.LessonTuitionGoal = branchGoalItems.Sum(b => b.LessonTuitionGoal);
                headquarterRevenueGoal.SRLessonTuitionGoal = branchGoalItems.Sum(b => b.SRLessonTuitionGoal);
                headquarterRevenueGoal.CompleteLessonsGoal = branchGoalItems.Sum(b => b.CompleteLessonsGoal);
                headquarterRevenueGoal.SRLessonsGoal = branchGoalItems.Sum(b => b.SRLessonsGoal);
                headquarterRevenueGoal.LessonTuitionIndicatorPercentage = Math.Round((decimal)headquarterRevenueGoal.LessonTuitionGoal * (decimal)baseIndicator.MonthlyRevenueGrade.IndicatorPercentage / (decimal)baseIndicator.RevenueGoal, 2);

                models.SubmitChanges();
            }
        }

    }
}