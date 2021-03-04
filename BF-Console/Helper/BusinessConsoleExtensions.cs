using System;
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
using System.Web.Mvc;

using CommonLib.DataAccess;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Helper.BusinessOperation;
using WebHome.Controllers;

namespace WebHome.Helper
{
    public static class BusinessConsoleExtensions
    {
        public static MonthlyIndicator InitializeMonthlyIndicator<TEntity>(this ModelSource<TEntity> models, int year, int month, bool? forcedPrepare = null)
                where TEntity : class, new()
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
                            NewContractCount = branchGoal.NewContractCount,
                            RenewContractCount = branchGoal.RenewContractCount,
                            NewContractSubtotal = branchGoal.NewContractSubtotal,
                            RenewContractSubtotal = branchGoal.RenewContractSubtotal,
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
                        BRCount = c.BRCount,
                        LevelID = c.ServingCoach.LevelID,
                        //AverageLessonPrice = actualCount > 0
                        //    ? (c.ActualLessonAchievement + c.ActualCompleteLessonCount - 1) / actualCount
                        //    : 0,
                        AverageLessonPrice = sampleItem.CalculateAverageLessonPrice(models, c.CoachID),
                    };
                    newItem.LessonTuitionGoal = newItem.CompleteLessonsGoal * newItem.AverageLessonPrice;
                }
            }

            models.SubmitChanges();

            return item;

        }

        public static MonthlyIndicator AssertMonthlyIndicator<TEntity>(this MonthlyIndicatorQueryViewModel viewModel, ModelSource<TEntity> models)
                where TEntity : class, new()
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

        public static MonthlyIndicator GetAlmostMonthlyIndicator<TEntity>(this MonthlyIndicatorQueryViewModel viewModel, ModelSource<TEntity> models, bool? exact = null)
                where TEntity : class, new()
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

        public static readonly int?[] SessionScopeForAchievement = new int?[]
                    {
                        (int)Naming.LessonPriceStatus.一般課程,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.團體學員課程,
                    };

        public static readonly int?[] SessionScopeForComleteLessonCount = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.已刪除,
                    (int)Naming.LessonPriceStatus.點數兌換課程,
                    (int)Naming.LessonPriceStatus.員工福利課程,
                    (int)Naming.LessonPriceStatus.團體學員課程,
        };

        public static void UpdateMonthlyAchievement<TEntity>(this MonthlyIndicator item, ModelSource<TEntity> models,bool? forcedUpdate = null,bool? calcAverage = null)
            where TEntity : class, new()
        {

            AchievementQueryViewModel queryModel = new AchievementQueryViewModel
            {
                AchievementDateFrom = item.StartDate,
                BypassCondition = true,
            };

            IQueryable<V_Tuition> lessonItems = queryModel.InquireAchievement(models);

            if (forcedUpdate == true)
            {
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
            }
            else if (item.StartDate == DateTime.Today.FirstDayOfMonth())
            {
                lessonItems = lessonItems.Where(l => l.ClassTime < DateTime.Today);
            }
            else
            {
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
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
                Status = (int)Naming.CourseContractStatus.已生效,
                EffectiveDateFrom = item.StartDate,
                EffectiveDateTo = item.EndExclusiveDate,
            };
            IQueryable<CourseContract> contractItems = contractQuery.InquireContract(models);

            int lessonAchievement, tuitionAchievement;

            void calcHeadquarterAchievement()
            {
                lessonAchievement = tuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                lessonAchievement += (tuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                tuitionAchievement = achievementItems.Sum(a => a.ShareAmount) ?? 0;

                var revenueItem = item.MonthlyRevenueIndicator.Where(r => r.MonthlyRevenueGoal != null)
                        .Select(r => r.MonthlyRevenueGoal)
                        .FirstOrDefault();
                if (revenueItem != null)
                {
                    revenueItem.ActualCompleteLessonCount = tuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.PriceStatus)).Count()
                                    + tuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.ELStatus)).Count();
                    revenueItem.ActualLessonAchievement = lessonAchievement;
                    revenueItem.ActualSharedAchievement = tuitionAchievement;
                    revenueItem.RenewContractCount = contractItems.Where(c => c.Renewal == true).Count();
                    revenueItem.NewContractCount = contractItems.Count() - revenueItem.RenewContractCount;
                    revenueItem.RenewContractSubtotal = contractItems.Where(c => c.Renewal == true).Sum(c => c.TotalCost) ?? 0;
                    revenueItem.NewContractSubtotal = contractItems.Sum(c => c.TotalCost) - revenueItem.RenewContractSubtotal;

                    revenueItem.ActualCompleteTSCount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                    + tuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                    revenueItem.ActualCompletePICount = tuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                    + tuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                    models.SubmitChanges();
                }
            }

            void calcBranchAchievement()
            {
                foreach (var branchIndicator in item.MonthlyBranchIndicator)
                {
                    var branchTuitionItems = tuitionItems.Where(t => t.CoachWorkPlace == branchIndicator.BranchID);
                    var branchAchievementItems = achievementItems.Where(t => t.CoachWorkPlace == branchIndicator.BranchID);
                    var branchContractItems = contractItems.Where(c => c.CourseContractExtension.BranchID == branchIndicator.BranchID);

                    var revenueItem = branchIndicator.MonthlyBranchRevenueIndicator
                            .Where(v => v.MonthlyBranchRevenueGoal != null)
                            .FirstOrDefault()?.MonthlyBranchRevenueGoal;
                    if (revenueItem != null)
                    {
                        lessonAchievement = branchTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                        lessonAchievement += (branchTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                        tuitionAchievement = branchAchievementItems.Sum(a => a.ShareAmount) ?? 0;

                        revenueItem.ActualCompleteLessonCount = branchTuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.PriceStatus)).Count()
                                        + branchTuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.ELStatus)).Count();
                        revenueItem.ActualLessonAchievement = lessonAchievement;
                        revenueItem.ActualSharedAchievement = tuitionAchievement;
                        revenueItem.RenewContractCount = branchContractItems.Where(c => c.Renewal == true).Count();
                        revenueItem.NewContractCount = branchContractItems.Count() - revenueItem.RenewContractCount;
                        revenueItem.RenewContractSubtotal = branchContractItems.Where(c => c.Renewal == true).Sum(c => c.TotalCost) ?? 0;
                        revenueItem.NewContractSubtotal = branchContractItems.Sum(c => c.TotalCost) - revenueItem.RenewContractSubtotal;
                        revenueItem.ActualCompleteTSCount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                        + branchTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                        revenueItem.ActualCompletePICount = branchTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                        + branchTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                        models.SubmitChanges();
                    }
                }
            }

            void calcCoachAchievement()
            {
                foreach (var coachIndicator in item.MonthlyCoachRevenueIndicator)
                {
                    var coachTuitionItems = tuitionItems.Where(t => t.AttendingCoach == coachIndicator.CoachID);
                    var coachAchievementItems = achievementItems.Where(t => t.CoachID == coachIndicator.CoachID);
                    var coachContractItems = contractItems.Where(c => c.FitnessConsultant == coachIndicator.CoachID);

                    lessonAchievement = coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                    lessonAchievement += (coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                    tuitionAchievement = coachAchievementItems.Sum(a => a.ShareAmount) ?? 0;

                    coachIndicator.ActualCompleteLessonCount = coachTuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.PriceStatus)).Count()
                                    + coachTuitionItems.Where(t => SessionScopeForComleteLessonCount.Contains(t.ELStatus)).Count();
                    coachIndicator.ActualLessonAchievement = lessonAchievement;
                    coachIndicator.ActualRenewContractAchievement = coachContractItems.Where(c => c.Renewal == true).Count();
                    coachIndicator.ActualNewContractAchievement = coachContractItems.Count() - coachIndicator.ActualRenewContractAchievement;
                    coachIndicator.ActualCompleteTSCount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                    coachIndicator.ActualCompletePICount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                    if (calcAverage == true)
                    {
                        coachIndicator.AverageLessonPrice = item.CalculateAverageLessonPrice(models, coachIndicator.CoachID);
                        coachIndicator.LessonTuitionGoal = coachIndicator.CompleteLessonsGoal * coachIndicator.AverageLessonPrice;
                    }

                    models.SubmitChanges();
                }
            }

            calcHeadquarterAchievement();
            calcBranchAchievement();
            calcCoachAchievement();
        }

        public static int CalculateAverageLessonPrice<TEntity>(this MonthlyIndicator item, ModelSource<TEntity> models, int? coachID)
            where TEntity : class, new()
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
            lessonAchievement = coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
            lessonAchievement += (coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);

            var completeLessonCount = Math.Max(coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.PriceStatus)).Count()
                                    + coachTuitionItems.Where(t => SessionScopeForAchievement.Contains(t.ELStatus)).Count(), 1);

            return (lessonAchievement + completeLessonCount - 1) / completeLessonCount;
        }

        public static void UpdateMonthlyAchievementGoal<TEntity>(this MonthlyIndicator item, ModelSource<TEntity> models)
            where TEntity : class, new()
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
                revenueGoal.CustomRevenueGoal = branchItems.Sum(b => b.LessonTuitionGoal + b.AchievementGoal);

                var baseIndicator = branchIndicator.MonthlyBranchRevenueIndicator.OrderBy(m => m.GradeID).First();
                revenueGoal.CustomIndicatorPercentage = Math.Round(((decimal?)revenueGoal.CustomRevenueGoal * (decimal?)baseIndicator.MonthlyRevenueGrade.IndicatorPercentage / (decimal?)baseIndicator.RevenueGoal) ?? 0m, 2);

                revenueGoal.AchievementGoal = branchItems.Sum(b => b.AchievementGoal);
                revenueGoal.LessonTuitionGoal = branchItems.Sum(b => b.LessonTuitionGoal);
                revenueGoal.CompleteLessonsGoal = branchItems.Sum(b => b.CompleteLessonsGoal);

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
                headquarterRevenueGoal.CompleteLessonsGoal = branchGoalItems.Sum(b => b.CompleteLessonsGoal);

                models.SubmitChanges();
            }
        }
    }
}