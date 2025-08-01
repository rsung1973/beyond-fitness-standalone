﻿using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

using CommonLib.DataAccess;
using WebHome.Helper.BusinessOperation;
using Newtonsoft.Json;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class ReportExtensionMethods
    {
        public static DataTable CreateLessonAchievementDetails(this GenericManager<BFDataContext> models, IQueryable<LessonTime> items)
            
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("合約編號", typeof(String)));
            table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            table.Columns.Add(new DataColumn("簽約場所", typeof(String)));
            table.Columns.Add(new DataColumn("學員", typeof(String)));
            table.Columns.Add(new DataColumn("合約名稱", typeof(String)));
            table.Columns.Add(new DataColumn("課程單價", typeof(int)));
            table.Columns.Add(new DataColumn("全價計算堂數", typeof(int)));
            table.Columns.Add(new DataColumn("半價計算堂數", typeof(int)));
            table.Columns.Add(new DataColumn("上課地點", typeof(String)));
            table.Columns.Add(new DataColumn("累計上課金額", typeof(int)));
            table.Columns.Add(new DataColumn("是否信託", typeof(String)));
            table.Columns.Add(new DataColumn("課程代碼", typeof(int)));
            table.Columns.Add(new DataColumn("體能顧問所屬分店", typeof(String)));

            var details = items.Where(t => t.RegisterLesson.RegisterLessonContract != null)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    t.RegisterLesson.RegisterLessonContract.ContractID,
                    t.BranchID
                });

            foreach (var item in details)
            {
                CourseContract contract = models.GetTable<CourseContract>().Where(u => u.ContractID == item.Key.ContractID).First();
                ServingCoach coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == item.Key.AttendingCoach).First();
                var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == item.Key.BranchID).First();

                var r = table.NewRow();
                r[0] = contract.ContractNo();
                r[1] = coach.UserProfile.FullName();
                r[2] = contract.CourseContractExtension.BranchStore.BranchName;

                if (contract.CourseContractType.IsGroup == true)
                {
                    r[3] = String.Join("/", contract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(m => m.FullName()));
                }
                else
                {
                    r[3] = contract.ContractOwner.FullName();
                }

                r[4] = contract.CourseContractType.TypeName
                    + " (" + contract.LessonPriceType.DurationInMinutes + " 分鐘)";
                r[5] = contract.LessonPriceType.ListPrice;

                var count = item.Count();
                var halfCount = item.Count(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue);
                r[6] = count - halfCount;
                r[7] = halfCount;
                r[8] = branch.BranchName;
                var discount = contract.CourseContractType.GroupingLessonDiscount;
                r[9] = item.Sum(l => l.RegisterLesson.LessonPriceType.ListPrice) * discount.GroupingMemberCount * discount.PercentageOfDiscount / 100;
                r[10] = contract.Entrusted == true
                    ? "是"
                    : contract.Entrusted == false
                        ? "否"
                        : "";
                if (contract.LessonPriceType.Status.HasValue)
                {
                    r[11] = contract.LessonPriceType.Status.Value;
                }
                r[12] = coach.WorkPlace();
                table.Rows.Add(r);
            }

            var enterprise = items.Where(t => t.RegisterLesson.RegisterLessonEnterprise != null)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    t.RegisterLesson.RegisterLessonEnterprise.ContractID,
                    t.RegisterID,
                    t.BranchID
                });

            foreach (var item in enterprise)
            {
                EnterpriseCourseContract contract = models.GetTable<EnterpriseCourseContract>().Where(u => u.ContractID == item.Key.ContractID).First();
                ServingCoach coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == item.Key.AttendingCoach).First();
                RegisterLesson lesson = models.GetTable<RegisterLesson>().Where(g => g.RegisterID == item.Key.RegisterID).First();
                var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == item.Key.BranchID).First();

                var r = table.NewRow();

                r[0] = contract.ContractNo;
                r[1] = coach.UserProfile.FullName();
                r[2] = contract.BranchStore.BranchName;

                if (lesson.GroupingMemberCount > 1)
                {
                    r[3] = String.Join("/", lesson.GroupingLesson.RegisterLesson.Select(s => s.UserProfile).ToArray().Select(m => m.FullName()));
                }
                else
                {
                    r[3] = lesson.UserProfile.FullName();
                }

                r[4] = contract.Subject;
                r[5] = contract.EnterpriseCourseContent.OrderByDescending(c => c.ListPrice).First().ListPrice;
                var count = item.Count();
                var halfCount = item.Count(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue);
                r[6] = count - halfCount;
                r[7] = halfCount;
                r[8] = branch.BranchName;
                r[9] = count * lesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
                        * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100;
                r[11] = (int)Naming.LessonPriceStatus.企業合作方案;
                r[12] = coach.WorkPlace();
                table.Rows.Add(r);
            }

            var others = items.Where(t => t.RegisterLesson.RegisterLessonContract == null && t.RegisterLesson.RegisterLessonEnterprise == null);
            foreach (var item in others)
            {
                var coach = item.AsAttendingCoach;
                var r = table.NewRow();
                r[0] = "--";
                r[1] = coach.UserProfile.FullName();
                if (item.BranchID.HasValue)
                    r[2] = item.BranchStore.BranchName;

                r[3] = item.RegisterLesson.UserProfile.FullName();

                r[4] = item.RegisterLesson.LessonPriceType.Description
                    + " (" + item.RegisterLesson.LessonPriceType.DurationInMinutes + " 分鐘)";
                r[9] = r[5] = item.RegisterLesson.LessonPriceType.ListPrice;
                var halfCount = item.LessonAttendance == null || item.LessonPlan.CommitAttendance.HasValue ? 1 : 0;
                r[6] = 1 - halfCount;
                r[7] = halfCount;
                if (item.BranchID.HasValue)
                {
                    r[8] = item.BranchStore.BranchName;
                }
                if (item.RegisterLesson.LessonPriceType.Status.HasValue)
                {
                    r[11] = item.RegisterLesson.LessonPriceType.Status.Value;
                }
                r[12] = coach.WorkPlace();
                table.Rows.Add(r);
            }

            table.TableName = "上課統計表-人員明細";

            return table;
        }

        public static DataTable CreateLessonAchievementDetails(this GenericManager<BFDataContext> models, IQueryable<V_Tuition> items)
            
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("合約編號", typeof(String)));	//	0
            table.Columns.Add(new DataColumn("上課體能顧問", typeof(String)));	//	1
            table.Columns.Add(new DataColumn("簽約場所", typeof(String)));	//	2
            table.Columns.Add(new DataColumn("學生", typeof(String)));	//	3
            table.Columns.Add(new DataColumn("合約名稱", typeof(String)));	//	4
            table.Columns.Add(new DataColumn("課程單價", typeof(int)));	//	5
            table.Columns.Add(new DataColumn("已完成上課", typeof(int)));	//	6
            table.Columns.Add(new DataColumn("學員打卡", typeof(int)));	//	7
            table.Columns.Add(new DataColumn("上課場所", typeof(String)));	//	8
            table.Columns.Add(new DataColumn("上課金額", typeof(int)));	//	9
            table.Columns.Add(new DataColumn("是否信託", typeof(String)));	//	10
            table.Columns.Add(new DataColumn("課程代碼", typeof(int)));	//	11
            table.Columns.Add(new DataColumn("體能顧問所屬分店", typeof(String)));	//	12
            table.Columns.Add(new DataColumn("預約上課數", typeof(int)));	//	13
            table.Columns.Add(new DataColumn("SettlementID", typeof(int)));	//	14
            table.Columns.Add(new DataColumn("簽約體能顧問", typeof(String)));	//	15
            table.Columns.Add(new DataColumn("CoachID", typeof(int)));	//	16
            table.Columns.Add(new DataColumn("主教練", typeof(String)));	//	17
            table.Columns.Add(new DataColumn("PriceID", typeof(int)));	//	18


            var details = items.Where(t => t.ContractID.HasValue)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    t.ContractID,
                    t.PriceID,
                    t.BranchID,
                    t.SettlementID,
                    t.RegisterID,
                });

            var branchItems = models.GetTable<BranchStore>().ToArray();

            foreach (var item in details)
            {
                CourseContract contract = models.GetTable<CourseContract>().Where(u => u.ContractID == item.Key.ContractID).First();
                ServingCoach coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == item.Key.AttendingCoach).First();
                LessonPriceType price = models.GetTable<LessonPriceType>().Where(u => u.PriceID == item.Key.PriceID).FirstOrDefault();
                var branch = branchItems.Where(b => b.BranchID == item.Key.BranchID).First();
                var lesson = models.GetTable<RegisterLesson>().Where(g => g.RegisterID == item.Key.RegisterID).First();

                var r = table.NewRow();
                r[0] = contract.ContractNo();
                r[1] = coach.UserProfile.FullName();
                r[2] = contract.CourseContractExtension.BranchStore.BranchName;

                if (contract.CourseContractType.IsGroup == true)
                {
                    var learners = contract.CourseContractMember.Select(m => m.UserProfile).ToArray();
                    r[3] = String.Join("/", learners.Select(m => m.FullName()));
                    r[17] = learners.Select(u => u.LearnerCoachProperty
                                        .Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                                        .Select(p => p.ServingCoach.UserProfile.FullName()).Concatenate("/")).Concatenate("\r\n");
                }
                else
                {
                    r[3] = lesson.UserProfile.FullName();
                    r[17] = lesson.UserProfile.LearnerCoachProperty
                                        .Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                                        .Select(p => p.ServingCoach.UserProfile.FullName()).Concatenate("/");
                }

                r[4] = $"{contract.CourseContractType.TypeName} ({price?.DurationInMinutes} 分鐘)";
                r[5] = price?.ListPrice;

                r[6] = item.Where(l => l.CoachAttendance.HasValue).Count();     //item.Where(l => l.AchievementIndex == 1m).Count();
                r[7] = item.Join(models.GetTable<Settlement>(), l => l.SettlementID, s => s.SettlementID, (l, s) => new { l.CommitAttendance, s.SettlementDate })
                            .Where(l => l.CommitAttendance <= l.SettlementDate).Count();    //item.Where(l => l.AchievementIndex == 0.5m).Count();
                r[8] = branch.BranchName;
                r[9] = item.Sum(l => l.ListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100);
                r[10] = contract.Entrusted == true
                    ? "是"
                    : contract.Entrusted == false
                        ? "否"
                        : "";
                if (price != null)
                {
                    r[11] = price.Status.Value;
                }

                var sample = item.First();
                r[12] = branchItems.Where(b => b.BranchID == sample.CoachWorkPlace)
                            .Select(b=>b.BranchName).FirstOrDefault() ?? "其他";
                r[13] = item.Count();
                if (item.Key.SettlementID.HasValue)
                    r[14] = item.Key.SettlementID;
                r[15] = contract.ServingCoach.UserProfile.FullName();
                r[16] = coach.CoachID;
                table.Rows.Add(r);
            }

            var enterprise = items.Where(t => t.EnterpriseContractID.HasValue)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    ContractID = t.EnterpriseContractID,
                    t.RegisterID,
                    t.BranchID,
                    t.SettlementID,
                });

            foreach (var item in enterprise)
            {
                EnterpriseCourseContract contract = models.GetTable<EnterpriseCourseContract>().Where(u => u.ContractID == item.Key.ContractID).First();
                ServingCoach coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == item.Key.AttendingCoach).First();
                RegisterLesson lesson = models.GetTable<RegisterLesson>().Where(g => g.RegisterID == item.Key.RegisterID).First();
                var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == item.Key.BranchID).First();

                var r = table.NewRow();

                r[0] = contract.ContractNo;
                r[1] = coach.UserProfile.FullName();
                r[2] = contract.BranchStore.BranchName;

                if (lesson.GroupingMemberCount > 1)
                {
                    var learners = lesson.GroupingLesson.RegisterLesson.Select(s => s.UserProfile).ToArray();
                    r[3] = String.Join("/", learners.Select(m => m.FullName()));
                    r[17] = learners.Select(u => u.LearnerCoachProperty
                                        .Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                                        .Select(p => p.ServingCoach.UserProfile.FullName()).Concatenate("/")).Concatenate("\r\n");
                }
                else
                {
                    r[3] = lesson.UserProfile.FullName();
                    r[17] = lesson.UserProfile.LearnerCoachProperty
                                        .Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                                        .Select(p => p.ServingCoach.UserProfile.FullName()).Concatenate("/");
                }

                r[4] = contract.Subject;
                r[5] = contract.EnterpriseCourseContent.OrderByDescending(c => c.ListPrice).First().ListPrice;
                r[6] = item.Where(l => l.CoachAttendance.HasValue).Count();     //item.Where(l => l.AchievementIndex == 1m).Count();
                r[7] = item.Join(models.GetTable<Settlement>(), l => l.SettlementID, s => s.SettlementID, (l, s) => new { l.CommitAttendance, s.SettlementDate })
                            .Where(l => l.CommitAttendance <= l.SettlementDate).Count();     //item.Where(l => l.AchievementIndex == 0.5m).Count();
                r[8] = branch.BranchName;
                r[9] = item.Sum(l=>l.EnterpriseListPrice * l.GroupingMemberCount
                        * l.PercentageOfDiscount / 100);
                r[11] = item.FirstOrDefault()?.ELStatus;    //(int)Naming.LessonPriceStatus.企業合作方案;
                var sample = item.First();
                r[12] = branchItems.Where(b => b.BranchID == sample.CoachWorkPlace)
                            .Select(b => b.BranchName).FirstOrDefault() ?? "其他";
                r[13] = item.Count();
                if (item.Key.SettlementID.HasValue)
                    r[14] = item.Key.SettlementID;
                r[16] = coach.CoachID;

                table.Rows.Add(r);
            }

            var others = items.Where(t => !t.ContractID.HasValue && !t.EnterpriseRegisterID.HasValue);
            foreach (var item in others)
            {
                ServingCoach coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == item.AttendingCoach).First();
                var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == item.BranchID).FirstOrDefault();
                var lesson = models.GetTable<RegisterLesson>().Where(g => g.RegisterID == item.RegisterID).First();

                var r = table.NewRow();
                r[0] = "--";
                r[1] = coach.UserProfile.FullName();
                if (item.BranchID.HasValue)
                    r[2] = branch.BranchName;

                r[3] = lesson.UserProfile.FullName();
                r[17] = lesson.UserProfile.LearnerCoachProperty
                                        .Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                                        .Select(p => p.ServingCoach.UserProfile.FullName()).Concatenate("/");

                r[4] = lesson.LessonPriceType.Description
                    + " (" + lesson.LessonPriceType.DurationInMinutes + " 分鐘)";
                r[9] = r[5] = item.ListPrice;
                r[6] = item.CoachAttendance.HasValue ? 1 : 0;   //item.AchievementIndex == 1m ? 1 : 0;
                var settlement = models.GetTable<Settlement>().Where(s => s.SettlementID == item.SettlementID).FirstOrDefault();
                r[7] = item.CommitAttendance.HasValue && item.CommitAttendance <= settlement?.SettlementDate ? 1 : 0;  //item.AchievementIndex == 0.5m ? 1 : 0;
                if (branch != null)
                {
                    r[8] = branch.BranchName;
                }

                r[11] = item.PriceStatus;
                //r[11] = item.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程
                //        ? models.GetTable<LessonPriceProperty>()
                //            .Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程)
                //            .Where(p => p.PriceID == item.PriceID).Any()
                //                ? (int)Naming.LessonPriceStatus.運動恢復課程
                //                : (int)Naming.LessonPriceStatus.點數兌換課程
                //        : item.PriceStatus;
                r[12] = branchItems.Where(b => b.BranchID == item.CoachWorkPlace)
                            .Select(b => b.BranchName).FirstOrDefault() ?? "其他";
                r[13] = 1;
                if (item.SettlementID.HasValue)
                    r[14] = item.SettlementID;
                r[16] = coach.CoachID;
                r[18] = item.PriceID;

                table.Rows.Add(r);
            }

            table.TableName = "上課統計表-人員明細";

            return table;
        }


        public static DataTable CreateTuitionAchievementDetails(this GenericManager<BFDataContext> models, IQueryable<TuitionAchievement> items)
            
        {
            var details = items.ToArray().Select(item => new
            {
                發票號碼 = item.Payment.InvoiceID.HasValue
                    ? item.Payment.InvoiceItem.TrackCode + item.Payment.InvoiceItem.No : null,
                分店 = item.Payment.PaymentTransaction.BranchStore.BranchName,
                收款人 = item.Payment.UserProfile.FullName(),
                業績所屬體能顧問 = item.ServingCoach.UserProfile.FullName(),
                學員 = item.Payment.TuitionInstallment != null
                        ? item.Payment.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.Payment.ContractPayment != null
                            ? item.Payment.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--",
                收款日期 = item.Payment.VoidPayment == null ? String.Format("{0:yyyy/MM/dd}", item.Payment.PayoffDate) : null,
                作廢日期 = item.Payment.VoidPayment != null ? String.Format("{0:yyyy/MM/dd}", item.Payment.VoidPayment.VoidDate) : null,
                業績金額 = item.ShareAmount,
                收款方式 = item.Payment.PaymentType,
                發票類型 = item.Payment.InvoiceID.HasValue
                        ? item.Payment.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本"
                        : "--",
                發票狀態 = item.Payment.VoidPayment == null
                        ? "已開立"
                        : item.Payment.VoidPayment.Status == (int)Naming.CourseContractStatus.已生效
                            ? item.Payment.InvoiceItem.InvoiceAllowance.Any()
                                ? "已折讓"
                                : "已作廢"
                            : "已開立",
                合約編號 = item.Payment.ContractPayment != null
                    ? item.Payment.ContractPayment.CourseContract.ContractNo()
                    : ((Naming.PaymentTransactionType)item.Payment.TransactionType).ToString(),
                狀態 = ((Naming.CourseContractStatus)item.Payment.Status).ToString()
                    + (item.Payment.PaymentAudit.AuditorID.HasValue ? "" : "(*)")
            });

            DataTable table = details.ToDataTable();
            table.TableName = "業績統計表-人員明細";
            return table;
        }

        public static DataTable CreateAchievementShareList(this GenericManager<BFDataContext> models, IQueryable<TuitionAchievement> items)
            
        {
            var details = items.ToArray().Select(item => new
            {
                體能顧問 = item.ServingCoach.UserProfile.FullName(),
                學生 = item.Payment.TuitionInstallment != null
                        ? item.Payment.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.Payment.ContractPayment != null
                            ? item.Payment.ContractPayment.CourseContract.ContractLearner()
                            : "--",
                分潤業績 = item.ShareAmount,
                類別 = ((Naming.PaymentTransactionType?)item.Payment.TransactionType).ToString(),
                發票號碼 = item.Payment.InvoiceID.HasValue
                    ? item.Payment.InvoiceItem.TrackCode + item.Payment.InvoiceItem.No : null,
                收款日期 = /*item.Payment.VoidPayment == null ?*/ String.Format("{0:yyyy/MM/dd}", item.Payment.PayoffDate)/* : null*/,
                簽約場所 = item.Payment.PaymentTransaction.BranchStore.BranchName,
                體能顧問所屬分店 = item.CoachWorkPlace.HasValue ? item.BranchStore.BranchName : "其他",
                是否續約 = item.Payment.ContractPayment?.CourseContract.Renewal.TruthValue(),
                分期期別 = item.Payment.ContractPayment?.CourseContract.GetInstallmentPeriodNo(models),
            });

            DataTable table = details.ToDataTable();
            return table;
        }

        public static DataTable CreateVoidShareList(this GenericManager<BFDataContext> models, IQueryable<TuitionAchievement> items)

        {
            var details = items.ToArray().Select(item => new
            {
                體能顧問 = item.ServingCoach.UserProfile.FullName(),
                學生 = item.Payment.TuitionInstallment != null
                        ? item.Payment.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.Payment.ContractPayment != null
                            ? item.Payment.ContractPayment.CourseContract.ContractLearner()
                            : "--",
                分潤業績 = -item.VoidShare,
                類別 = ((Naming.PaymentTransactionType?)item.Payment.TransactionType).ToString(),
                發票號碼 = item.Payment.InvoiceID.HasValue
                    ? item.Payment.InvoiceItem.TrackCode + item.Payment.InvoiceItem.No : null,
                折讓日期 = String.Format("{0:yyyy/MM/dd}", item.Payment.InvoiceAllowance.AllowanceDate),
                簽約場所 = item.Payment.PaymentTransaction.BranchStore.BranchName,
                體能顧問所屬分店 = item.CoachWorkPlace.HasValue ? item.BranchStore.BranchName : "其他",
                是否續約 = item.Payment.ContractPayment?.CourseContract.Renewal.TruthValue(),
                分期期別 = item.Payment.ContractPayment?.CourseContract.GetInstallmentPeriodNo(models),
            });

            DataTable table = details.ToDataTable();
            return table;
        }

        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForPISession(this PaymentQueryViewModel viewModel, GenericManager<BFDataContext> models)
            
        {
            IQueryable<Payment> items = models.GetTable<Payment>()
                    .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);

            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName(),
                        //合約編號 = null,
                        信託 = null,
                        摘要 = $"銷貨收入-{i.PaymentFor}{i.PayoffDate:yyyyMMdd}-{i.TuitionInstallment?.IntuitionCharge.RegisterLesson.UserProfile.RealName}({i.PaymentType})",
                        退款金額_含稅 = null,
                        收款金額_含稅 = i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                    });

            //作廢或折讓
            details = details.Concat(
                    items.Join(models.GetTable<VoidPayment>()
                                .Where(v => v.VoidDate >= viewModel.PayoffDateFrom && v.VoidDate < viewModel.PayoffDateTo),
                            p => p.PaymentID, v => v.VoidID, (p, v) => p)
                        .ToArray()
                            .Select(i => new PaymentMonthlyReportItem
                            {
                                日期 = $"{i.VoidPayment.VoidDate:yyyyMMdd}",
                                發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                                分店 = i.PaymentTransaction.BranchStore.BranchName,
                                買受人統編 = i.InvoiceID.HasValue
                                          ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                          : "--",
                                //姓名 = i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName(),
                                //合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)銷貨收入-{i.PaymentFor}-{i.TuitionInstallment?.IntuitionCharge.RegisterLesson.UserProfile.RealName}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)銷貨收入-{i.PaymentFor}-{i.TuitionInstallment?.IntuitionCharge.RegisterLesson.UserProfile.RealName}",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ));

            return details;
        }
        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForSale(this PaymentQueryViewModel viewModel, GenericManager<BFDataContext> models)
            
        {

            IQueryable<Payment> items = models.GetTable<Payment>()
                    .Join(models.GetTable<PaymentTransaction>().Where(t => t.PaymentOrder.Any()),
                        p => p.PaymentID, t => t.PaymentID, (p, t) => p);

            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = null,
                        //合約編號 = null,
                        信託 = null,
                        摘要 = $"其他營業收入-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}-{i.PaymentTransaction.UserProfile?.RealName}({i.PaymentType})",
                        退款金額_含稅 = null,
                        收款金額_含稅 = i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                    });

            //作廢或折讓
            details = details.Concat(
                    items.Join(models.GetTable<VoidPayment>()
                                .Where(v => v.VoidDate >= viewModel.PayoffDateFrom && v.VoidDate < viewModel.PayoffDateTo),
                            p => p.PaymentID, v => v.VoidID, (p, v) => p)
                        .ToArray()
                            .Select(i => new PaymentMonthlyReportItem
                            {
                                日期 = $"{i.VoidPayment.VoidDate:yyyyMMdd}",
                                發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                                分店 = i.PaymentTransaction.BranchStore.BranchName,
                                買受人統編 = i.InvoiceID.HasValue
                                          ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                          : "--",
                                //姓名 = null,
                                //合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)其他營業收入-{(Naming.PaymentTransactionType?)i.TransactionType}-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)其他營業收入-{(Naming.PaymentTransactionType?)i.TransactionType}-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ));

            return details;
        }
        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForCustom(this PaymentQueryViewModel viewModel, GenericManager<BFDataContext> models)
        {

            IQueryable<Payment> items = models.GetTable<Payment>()
                    .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.各項費用)
                    .Where(p => !models.GetTable<PaymentOrder>().Any(o => o.PaymentID == p.PaymentID));

            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = null,
                        //合約編號 = null,
                        信託 = null,
                        摘要 = $"銷貨收入-{i.InvoiceItem?.InvoiceDetails.FirstOrDefault()?.InvoiceProduct.Brief}-{i.PaymentTransaction.UserProfile?.RealName}({i.PaymentType})",
                        退款金額_含稅 = null,
                        收款金額_含稅 = i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                    });

            //作廢或折讓
            details = details.Concat(
                    items.Join(models.GetTable<VoidPayment>()
                                .Where(v => v.VoidDate >= viewModel.PayoffDateFrom && v.VoidDate < viewModel.PayoffDateTo),
                            p => p.PaymentID, v => v.VoidID, (p, v) => p)
                        .ToArray()
                            .Select(i => new PaymentMonthlyReportItem
                            {
                                日期 = $"{i.VoidPayment.VoidDate:yyyyMMdd}",
                                發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                                分店 = i.PaymentTransaction.BranchStore.BranchName,
                                買受人統編 = i.InvoiceID.HasValue
                                          ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                          : "--",
                                //姓名 = null,
                                //合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)銷貨收入-{(Naming.PaymentTransactionType?)i.TransactionType}-{i.InvoiceItem?.InvoiceDetails.FirstOrDefault()?.InvoiceProduct.Brief}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)銷貨收入-{(Naming.PaymentTransactionType?)i.TransactionType}-{i.InvoiceItem?.InvoiceDetails.FirstOrDefault()?.InvoiceProduct.Brief}",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ));

            return details;
        }
        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForFeeCharge(this PaymentQueryViewModel viewModel, GenericManager<BFDataContext> models)
        {

            IQueryable<Payment> items = models.GetTable<Payment>().Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.終止手續費);

            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = null,
                        //合約編號 = null,
                        信託 = null,
                        摘要 = $"銷貨收入-手續費收入-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractNo()}-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractOwner.RealName}({i.PaymentType})",
                        退款金額_含稅 = null,
                        收款金額_含稅 = i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                    });

            //作廢或折讓
            details = details.Concat(
                    items.Join(models.GetTable<VoidPayment>()
                                .Where(v => v.VoidDate >= viewModel.PayoffDateFrom && v.VoidDate < viewModel.PayoffDateTo),
                            p => p.PaymentID, v => v.VoidID, (p, v) => p)
                        .ToArray()
                            .Select(i => new PaymentMonthlyReportItem
                            {
                                日期 = $"{i.VoidPayment.VoidDate:yyyyMMdd}",
                                發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                                分店 = i.PaymentTransaction.BranchStore.BranchName,
                                買受人統編 = i.InvoiceID.HasValue
                                          ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                          : "--",
                                //姓名 = null,
                                //合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)手續費收入-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractNo()}-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractOwner.RealName}({i.PaymentType})"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)手續費收入-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractNo()}-{i.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision.CourseContract.ContractOwner.RealName}({i.PaymentType})",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ));

            return details;
        }
        public static IEnumerable<DailyBranchReportItem> BuildDailyPaymentReportForBranch(this IEnumerable<PaymentMonthlyReportItem> details, BranchStore branch)
        {
            var items = details.Where(d => d.分店 == branch.BranchName);
            IEnumerable<DailyBranchReportItem> results = items.GroupBy(d => d.日期).Select(g => new DailyBranchReportItem
            {
                日期 = g.Key,
                收款總計 = g.Sum(i => i.收款金額_含稅),
                現金收款 = g.Where(i => i.摘要.Contains("現金")).Sum(i => i.收款金額_含稅),
                轉帳收款 = g.Where(i => i.摘要.Contains("轉帳")).Sum(i => i.收款金額_含稅),
                刷卡收款 = g.Where(i => i.摘要.Contains("刷卡")).Sum(i => i.收款金額_含稅),
                作廢總計 = g.Where(i => i.摘要.Contains("作廢")).Sum(i => i.退款金額_含稅),
                終止退款 = g.Where(i => i.摘要.Contains("終止退款")).Sum(i => i.退款金額_含稅),
                終止轉收 = g.Where(i => i.摘要.Contains("終止轉收")).Sum(i => i.退款金額_含稅),
            }).ToList();
            foreach (var r in results)
            {
                r.實際收款 = r.收款總計 - r.作廢總計;
            }
            return results;
        }

        public static DataTable BuildContractPaymentReport(this IEnumerable<PaymentMonthlyReportItem> details, GenericManager<BFDataContext> models)
            
        {
            List<DataItem> results = new List<DataItem>();
            DataItem subtotal = new DataItem
            {
                A = "總計"
            };
            foreach(var branch in models.GetTable<BranchStore>())
            {
                var items = details.Where(d => d.分店 == branch.BranchName);
                var i = new DataItem
                {
                    A = branch.BranchName,
                    B = (items.Where(d => d.摘要.StartsWith("課程顧問費用")).Sum(d => d.收款金額_含稅) ?? 0)
                            - (items.Where(d => d.摘要.Contains("課程顧問費用")).Where(d => d.摘要.Contains("作廢") || d.摘要.Contains("折讓")).Sum(d => d.退款金額_含稅) ?? 0),
                    C = items.Where(d => d.摘要.Contains("終止退款")).Sum(d => d.退款金額_含稅) ?? 0,
                    D = items.Where(d => d.摘要.Contains("終止轉收")).Sum(d => d.退款金額_含稅) ?? 0,
                    E = items.Where(d => d.摘要.StartsWith("課程顧問費用")).Sum(d => d.貸方金額) ?? 0,
                    F = items.Where(d => d.摘要.Contains("終止退款")).Sum(d => d.借方金額) ?? 0,
                    G = items.Where(d => d.摘要.Contains("終止轉收")).Sum(d => d.借方金額) ?? 0,
                };
                subtotal.B += i.B;
                subtotal.C += i.C;
                subtotal.D += i.D;
                subtotal.E += i.E;
                subtotal.F += i.F;
                subtotal.G += i.G;
                results.Add(i);
            }
            results.Add(subtotal);
            DataTable table = results.ToDataTable();
            table.Columns[0].ColumnName = "分店/全部";
            table.Columns[1].ColumnName = "新增(含稅)";
            table.Columns[2].ColumnName = "終止退款(含稅)";
            table.Columns[3].ColumnName = "終止轉收(含稅)";
            table.Columns[4].ColumnName = "新增(未稅)";
            table.Columns[5].ColumnName = "終止退款(未稅)";
            table.Columns[6].ColumnName = "終止轉收(未稅)";
            return table;
        }

        class DataItem
        {
            public String A { get; set; }
            public int B { get; set; }
            public int C { get; set; }
            public int D { get; set; }
            public int E { get; set; }
            public int F { get; set; }
            public int G { get; set; }
        };

        public static int PromptEmploymentDurationInDays(this GenericManager<BFDataContext> models, int uid)
        {
            var items = models.GetTable<ForEmployee>().Where(p => p.UID == uid)
                            .OrderBy(p => p.LogID);
            int days = 0;
            foreach(var item in items)
            {
                if(item.EmploymentDate.HasValue)
                {
                    days += ((int)((item.LeavedDate ?? DateTime.Today) - item.EmploymentDate.Value).TotalDays + 1);
                }
            }
            return days;
        }

        static readonly int[] PerformanceAchievementIndex = new int[] { 304762, 238095, 179048 };
        static readonly decimal[] ShareRatioIncrementForPerformance = new decimal[] { 5.3m, 4.5m, 3.7m };
        //static readonly int[] AttendingLessonIndex = new int[] { 152, 142, 132, 112, 92 };
        //static readonly decimal[] ShareRatioIncrementForAttendance = new decimal[] { 2m, 1.5m, 1.25m, 1m, 0.5m };
        static readonly int[] AttendingLessonIndex = new int[] { 142, 132, 122, 112, 92 };
        static readonly decimal[] ShareRatioIncrementForAttendance = new decimal[] { 2m, 1.5m, 1.25m, 1m, 0.5m };

        static readonly int[] ManagerAttendanceIndex = { 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] ManagerAttendanceBonus = { 42500, 40500, 37000, 34000, 31000, 27500, 24000, 21000, 18000, 15000, 12000, 9000, 6000, 3000 };
        static readonly int[] ViceManagerAttendanceIndex = { 91, 86, 81, 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] ViceManagerAttendanceBonus = { 47000, 44500, 42000, 39500, 37000, 34500, 32000, 29500, 27000, 24500, 22000, 19500, 17000, 14500, 12000, 9500, 7000 };
        static readonly int[] EducatorAttendanceIndex = { 91, 86, 81, 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] EducatorAttendanceBonus = { 47500, 45000, 42500, 40000, 37000, 34000, 31500, 29000, 26500, 24000, 21500, 19000, 16500, 14000, 11500, 9000, 6500 };

        static readonly int[] ManagerManagementBonusIndex = { 130, 120, 110, 100 };
        static readonly decimal[] ManagerManagementBonusRatio = { 0.03M, 0.02M, 0.015M, 0.01M };
        static readonly decimal[] ViceManagerManagementBonusRatio = { 0.01M, 0.008M, 0.006M, 0.005M };
        static readonly decimal[] ApprenticeManagementBonusRatio = { 0.005M, 0.004M, 0.003M, 0.002M };
        static readonly int[][] EmploymentDurationYearIndex =
            {
                new int[]{5,8,10,11 },
                new int[]{5,8,10,11 },
                new int[]{5,8,10,11 }
            };
        static readonly int[][] EmploymentDurationGradeThousandth =
            {
                new int[]{2,6,10,10 },
                new int[]{3,7,11,11 },
                new int[]{4,8,12,12 }
            };

        public static void ExecuteLessonPerformanceSettlement(this GenericManager<BFDataContext> models, DateTime startDate, DateTime endExclusiveDate, String forRole=null)
        {
            var settlement = models.GetTable<Settlement>().Where(s => startDate <= s.SettlementDate && endExclusiveDate > s.SettlementDate).FirstOrDefault();
            if (settlement == null)
                return;

            Dictionary<int, int[][]> DietitianBonusIndex = new Dictionary<int, int[][]>
                    {
                        {
                            37,
                            new[]
                            {
                                new int[] { 36, 250 },
                                new int[] { 16, 200 },
                            }
                        },
                        {
                            38,
                            new[]
                            {
                                new int[] { 46, 350 },
                                new int[] { 36, 300 },
                                new int[] { 16, 250 },
                            }
                        },
                        {
                            42,
                            new[]
                            {
                                new int[] { 51, 400 },
                                new int[] { 36, 350 },
                                new int[] { 16, 300 },
                            }
                        },
                        {
                            43,
                            new[]
                            {
                                new int[] { 56, 550 },
                                new int[] { 36, 400 },
                                new int[] { 16, 350 },
                            }
                        },
                        {
                            44,
                            new[]
                            {
                                new int[] { 61, 600 },
                                new int[] { 36, 450 },
                                new int[] { 16, 400 },
                            }
                        },
            };

            Dictionary<int, int[][]> HealthCareBonusIndex = new Dictionary<int, int[][]>
            {
                { 36,   //  level 0
                    new []
                    {
                        new int[] { 101, 180,25 },
                        new int[] { 26, 150,25 },
                    }
                },
                { 33,   //  level 1
                    new []
                    {
                        new int[] { 111, 200,20 },
                        new int[] { 101, 200,20 },
                        new int[] { 21, 170,20},
                    }
                },
                { 34,   //  level 2
                    new []
                    {
                        new int[] { 121, 240 ,25},
                        new int[] { 101, 230 ,25},
                        new int[] { 26, 190,25},
                    }
                },
                { 35,   //  level 3
                    new []
                    {
                        new int[] { 131, 280,30 },
                        new int[] { 101, 260,30 },
                        new int[] { 31, 210, 30 },
                    }
                },
                { 39,   //  level 4
                    new []
                    {
                        new int[] { 141, 320,35 },
                        new int[] { 101, 290,35 },
                        new int[] { 36, 230, 35 },
                    }
                },
                { 40,   //  level 5
                    new []
                    {
                        new int[] { 151, 360,40 },
                        new int[] { 101, 320,40 },
                        new int[] { 41, 250, 40 },
                    }
                },
                { 41,   //  level 6
                    new []
                    {
                        new int[] { 161, 400,45 },
                        new int[] { 101, 350,45 },
                        new int[] { 46, 270, 45 },
                    }
                },
            };

            //models.ExecuteCommand(@"UPDATE Report.MonthlySalaryDetails
            //    SET SettlementID = {0} where SettlementID is null", settlement.SettlementID);

            forRole = forRole?.GetEfficientString()?.ToLower();

            LessonTimeAchievementHelper helper = new LessonTimeAchievementHelper(models)
            {
                LessonItems = models.GetTable<V_Tuition>().Where(l => l.ClassTime >= settlement.StartDate && l.ClassTime < settlement.EndExclusiveDate)
            };

            foreach(var item in helper.SettlementFullAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementStatus = {0},SettlementID = {1} where LessonID={2}", (int)Naming.LessonSettlementStatus.FullAchievement, settlement.SettlementID, item.LessonID);
            }

            foreach (var item in helper.SettlementHalfAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementStatus = {0},SettlementID = {1} where LessonID={2}", (int)Naming.LessonSettlementStatus.HalfAchievement, settlement.SettlementID, item.LessonID);
            }

            foreach (var item in helper.SettlementVainAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementID = {0} where LessonID={1}", settlement.SettlementID, item.LessonID);
            }

            var coachItems = models.PromptEffectiveCoach();

            var salaryTable = models.GetTable<CoachMonthlySalary>();
            var countableItems = helper.PerformanceCountableLesson;
            var PTItems = helper.PTSession;
            //var PTItemsAchievement = helper.PTSessionForAchievement;

            var paymentItems = models.GetTable<Payment>().Where(p => p.PayoffDate >= settlement.StartDate && p.PayoffDate < settlement.EndExclusiveDate);
            //.FilterByEffective();
            IQueryable<TuitionAchievement> achievementItems = paymentItems.GetPaymentAchievement(models);

            var voidPayment = models.GetTable<VoidPayment>().Where(p => p.VoidDate >= settlement.StartDate && p.VoidDate < settlement.EndExclusiveDate)
                                .Join(models.GetTable<Payment>().Where(p => p.AllowanceID.HasValue), v => v.VoidID, p => p.PaymentID, (v, p) => p);

            foreach (var coach in coachItems)
            {
                var lessonItem = countableItems.Where(l => l.AttendingCoach == coach.CoachID).FirstOrDefault();
                var salary = salaryTable.Where(s => s.CoachID == coach.CoachID && s.SettlementID == settlement.SettlementID).FirstOrDefault();
                if (salary == null)
                {
                    salary = new CoachMonthlySalary
                    {
                        CoachID = coach.CoachID,
                        SettlementID = settlement.SettlementID,
                        Year = settlement.Year,
                        AvgFlag = true,
                    };
                    salaryTable.InsertOnSubmit(salary);
                }

                if (coach.CoachWorkplace.Count == 1)
                {
                    salary.WorkPlace = coach.CoachWorkplace.First().BranchID;
                }

                if (lessonItem != null)
                {
                    salary.LevelID = lessonItem.ProfessionalLevelID;
                    //salary.GradeIndex = lessonItem.MarkedGradeIndex ?? 0;
                }
                else
                {
                    salary.LevelID = coach.LevelID ?? 0;
                    //salary.GradeIndex = coach.ProfessionalLevel?.GradeIndex ?? 0;
                }

                var performanceItems = achievementItems.Where(t => t.CoachID == coach.CoachID);
                salary.PerformanceAchievement = performanceItems.Sum(t => t.ShareAmount) ?? 0;

                var voidTuition = voidPayment
                    .Join(models.GetTable<TuitionAchievement>()
                            .Where(t => t.CoachID == coach.CoachID),
                        p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                salary.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;

                models.SubmitChanges();

                // 從 JSON 設定檔載入門檻值、百分比與年資加成
                var bonusConfigSR = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_SR.json"));
                var bonusConfigCoach = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_Coach.json"));
                var bonusConfigCooperation = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_Cooperation.json"));
                var groupXConfig = LoadGroupXBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "GroupXBonusConfig.json"));

                void calcGeneralAchievement()
                {
                    var attendingLessons = countableItems.Where(l => l.AttendingCoach == coach.CoachID);
                    foreach (var g in attendingLessons.GroupBy(l => l.BranchID))
                    {
                        var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == g.Key).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = g.Key.Value
                            };
                            salary.CoachBranchMonthlyBonus.Add(branchBonus);
                        }

                        LessonTimeAchievementHelper branchHelper = new LessonTimeAchievementHelper(models)
                        {
                            LessonItems = attendingLessons.Where(l => l.BranchID == g.Key)
                        };

                        branchBonus.AchievementAttendanceCount = branchHelper.LessonItems.Count()
                                - branchHelper.SettlementPILesson.Count() / 2m
                                - branchHelper.TSSRSession.Count() / 2m;

                        branchBonus.Tuition = branchHelper.LessonItems.CalcTuition(models);

                        branchBonus.AttendanceBonus = branchHelper.LessonItems.CalcTuitionShare(models);

                        models.SubmitChanges();
                    }

                    salary.PTAttendanceCount = PTItems.Where(v => v.AttendingCoach == coach.CoachID).Count();
                    salary.PTAverageUnitPrice = salary.PTAttendanceCount > 0
                            ? (int?)(PTItems.Where(v => v.AttendingCoach == coach.CoachID).CalcTuition(models) / (decimal?)salary.PTAttendanceCount + 0.5M)
                            : 0;

                    var tuitionCoach = helper.PTTuitionCoach
                                        .Where(t => t.AttendingCoach != t.PrimaryCoach)
                                        .Where(t => t.PrimaryCoach == coach.CoachID);
                    
                    salary.AttendedByOther = tuitionCoach.Count();
                    salary.AttendedShare = 0;
                    if (salary.AttendedByOther > 0)
                    {
                        var lessonAchievement = tuitionCoach.Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0M;
                        lessonAchievement += (tuitionCoach.Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0M);
                        salary.AttendedByOtherAvgPrice = (int)(lessonAchievement / salary.AttendedByOther + 0.5M);
                        //var ratio = salary.AttendedByOther > 29 ? 5 : 4;
                        //salary.AttendedShare = (Math.Max(salary.AttendedByOther.Value - (10 - Math.Min(salary.PTAttendanceCount.Value, 10)), 0) * salary.AttendedByOtherAvgPrice * ratio + 50) / 100;
                    }
                    else
                    {
                        salary.AttendedByOtherAvgPrice = 0;
                    }

                    salary.JobTenureInDays = models.PromptEmploymentDurationInDays(coach.CoachID);
                    var TS_Items = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                            .Where(v => v.AttendingCoach == coach.CoachID);
                    salary.TSAttendanceCount = TS_Items.Count();
                    salary.TSBonus = TS_Items.Sum(v => v.CoachPayoff) ?? 0;

                    var groupX = helper.GroupXItems
                            .Where(v => v.AttendingCoach == coach.CoachID)
                            .GroupBy(t => t.ClassTime).ToList();
                    salary.GroupXAttendanceCount = groupX.Count();
                    salary.GroupXBonus = groupX.Any()
                        ? groupX.Sum(g => CalculateGroupXBonus(1, g.Count(), groupXConfig))
                        : 0;

                    var PI_Items = helper.LessonItems
                        .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練)
                        .Where(v => v.AttendingCoach == coach.CoachID);
                    salary.PIAttendanceCount = PI_Items.Count();
                    salary.PIBonus = PI_Items.Sum(v => v.CoachPayoff) ?? 0;

                    models.SubmitChanges();
                }

                void calcCoachBonus()
                {
                    //Console.WriteLine($"教練: {coach.CoachID} , {coach.UserProfile.RealName}");
                    // 計算累計獎金
                    int durationYears = (salary.JobTenureInDays ?? 0) / 365;
                    // 計算年資加成
                    decimal seniorityBonusPercentage = AppSettings.Default.SeniorityBonusAvailableLevel.Any(l => l == coach.LevelID)
                        ? GetSeniorityBonusPercentage(durationYears, bonusConfigCoach.SeniorityBonuses)
                        : 0;
                    //Console.WriteLine($"年資: {durationYears}, 年資加成: {seniorityBonusPercentage}, 平均單價: {salary.PTAverageUnitPrice}, PT課數: {salary.PTAttendanceCount ?? 0}");
                    salary.AttendanceBonus = (int)(ComputeBonusThreshold((decimal)(salary.PTAverageUnitPrice ?? 0), salary.PTAttendanceCount ?? 0, bonusConfigCoach, seniorityBonusPercentage) + 0.5M);
                    //Console.WriteLine($"上課獎金: {salary.AttendanceBonus}");
                    if (salary.PTAttendanceCount >= 40 && salary.AttendedByOther > 0)
                    {
                        //Console.WriteLine($"合作課**************************************");
                        salary.AttendedShare = (int)(ComputeBonusThreshold((decimal)(salary.AttendedByOtherAvgPrice ?? 0), salary.AttendedByOther ?? 0, bonusConfigCooperation) + 0.5M);
                        //Console.WriteLine($"合作課獎金: {salary.AttendedShare}");
                    }
                    //Console.WriteLine($"********************************************");
                    models.SubmitChanges();
                }

                //void calcCoachBonus()
                //{
                //    var netAchievement = (int)Math.Max((salary.PerformanceAchievement.Value - salary.VoidShare.Value) / 1.05M + 0.5M, 0);

                //    var attendanceCount = salary.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                //    decimal shareRatio = 3m;
                //    for (int i = 0; i < PerformanceAchievementIndex.Length; i++)
                //    {
                //        if (netAchievement >= PerformanceAchievementIndex[i])
                //        {
                //            shareRatio = ShareRatioIncrementForPerformance[i];
                //            break;
                //        }
                //    }
                //    for (int i = 0; i < AttendingLessonIndex.Length; i++)
                //    {
                //        if (attendanceCount >= AttendingLessonIndex[i])
                //        {
                //            shareRatio += ShareRatioIncrementForAttendance[i];
                //            break;
                //        }
                //    }

                //    salary.AchievementShareRatio = shareRatio;

                //    if (coach.ServingCoachProperty.Any(p => p.PropertyID == (int)ServingCoachProperty.PropertyDefinition.Apprentice))
                //    {
                //        salary.GradeIndex = 30;
                //    }
                //    else
                //    {
                //        salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;
                //    }

                //    if (salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.EmploymentGradeIndex >= 0
                //            && salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.EmploymentGradeIndex < EmploymentDurationYearIndex.Length)
                //    {

                //        int durationYears = (salary.JobTenureInDays ?? 0) / 365;

                //        bool hasDurationGrade = false;
                //        int gradeIndex;
                //        int[] indexArray = EmploymentDurationYearIndex[salary.ProfessionalLevel.ProfessionalLevelBasicSalary.SalaryDetails.EmploymentGradeIndex.Value];

                //        for (gradeIndex = indexArray.Length-1; gradeIndex >=0 ; gradeIndex--)
                //        {
                //            if (durationYears >= indexArray[gradeIndex])
                //            {
                //                hasDurationGrade = true;
                //                break;
                //            }
                //        }

                //        if(hasDurationGrade)
                //        {
                //            if (gradeIndex == indexArray.Length - 1)
                //            {
                //                salary.EmploymentDurationGradeIndex =
                //                    Math.Min(EmploymentDurationGradeThousandth[salary.ProfessionalLevel.ProfessionalLevelBasicSalary.SalaryDetails.EmploymentGradeIndex.Value][indexArray.Length - 1]
                //                            + (durationYears - indexArray.Last()), 20);
                //            }
                //            else
                //            {
                //                salary.EmploymentDurationGradeIndex = EmploymentDurationGradeThousandth[salary.ProfessionalLevel.ProfessionalLevelBasicSalary.SalaryDetails.EmploymentGradeIndex.Value][gradeIndex];
                //            }
                //        }
                //    }

                //    salary.AttendanceBonus = (int?)(Math.Max(salary.PTAttendanceCount.Value - 10, 0)
                //        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                //        * (salary.GradeIndex / 100M + ((salary.EmploymentDurationGradeIndex ?? 0) / 1000M)) 
                //        + 0.5M) ?? 0;

                //    salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                //    if (coach.ServingCoachProperty.Any(p => p.PropertyID == (int)ServingCoachProperty.PropertyDefinition.Apprentice))
                //    {
                //        salary.SpecialBonus = (int?)(netAchievement * salary.AchievementShareRatio / 100M + 0.5M ?? 0);
                //    }
                //    else
                //    {
                //        salary.AchievementBonus = (int?)(netAchievement * salary.AchievementShareRatio / 100M + 0.5M ?? 0);
                //    }

                //    models.SubmitChanges();
                //}

                //void calcManagerBonus(BranchStore branch, CoachBranchMonthlyBonus branchBonus)
                //{
                //    //var netAchievement = Math.Max(salary.PerformanceAchievement.Value - salary.VoidShare.Value, 0);

                //    var attendanceCount = salary.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                //    int bonusIdx = 0;
                //    for (; bonusIdx < ManagerAttendanceIndex.Length; bonusIdx++)
                //    {
                //        if (attendanceCount >= ManagerAttendanceIndex[bonusIdx])
                //        {
                //            break;
                //        }
                //    }

                //    if (bonusIdx < ManagerAttendanceIndex.Length)
                //    {
                //        salary.AttendanceBonus = ManagerAttendanceBonus[bonusIdx];
                //    }
                //    else
                //    {
                //        salary.AttendanceBonus = 0;
                //    }

                //    salary.ManagerBonus = 0;
                //    decimal achievementRatio = 0;

                //    var indicator = models.GetTable<MonthlyIndicator>().Where(s => s.StartDate <= settlement.StartDate && s.EndExclusiveDate > settlement.StartDate).FirstOrDefault();
                //    if (indicator != null)
                //    {
                //        MonthlyBranchRevenueGoal item = indicator.MonthlyBranchRevenueIndicator.Where(r => r.BranchID == branch.BranchID)
                //            .Where(r => r.MonthlyBranchRevenueGoal != null)
                //            .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();

                //        if (item != null)
                //        {
                //            branchBonus.BranchTotalPTCount = 
                //                (item.ActualCompleteLessonCount ?? 0) 
                //                + (item.SRCount ?? 0)
                //                + (item.SDCount ?? 0)
                //                + (item.ATCount ?? 0);

                //            var tuitionSubtotal = 
                //            branchBonus.BranchTotalPTTuition =
                //                (item.ActualLessonAchievement ?? 0)
                //                + (item.SRAchievement ?? 0)
                //                + (item.SDAchievement ?? 0)
                //                + (item.ATAchievement ?? 0);

                //            decimal indicatorAmt = (decimal)item.MonthlyBranchRevenueIndicator.RevenueGoal;
                //            decimal basePercentage = item.MonthlyBranchRevenueIndicator.MonthlyRevenueGrade.IndicatorPercentage;
                //            int totalAchievementAmt = (tuitionSubtotal + item.ActualSharedAchievement - (item.VoidShare ?? 0)) ?? 0;

                //            achievementRatio = Math.Round(totalAchievementAmt * basePercentage / indicatorAmt);
                //            bonusIdx = 0;
                //            for (; bonusIdx < ManagerManagementBonusIndex.Length; bonusIdx++)
                //            {
                //                if (achievementRatio >= ManagerManagementBonusIndex[bonusIdx])
                //                {
                //                    break;
                //                }
                //            }

                //            if (bonusIdx < ManagerManagementBonusIndex.Length)
                //            {
                //                salary.ManagementBonusGrade = ManagerManagementBonusRatio[bonusIdx];
                //                salary.ManagerBonus = (int)(tuitionSubtotal * ManagerManagementBonusRatio[bonusIdx] / 1.05M + 0.5M);
                //            }
                //        }
                //    }

                //    var summaryItem = models.GetTable<BranchMonthlySummary>().Where(m => m.SettlementID == settlement.SettlementID && m.BranchID == branch.BranchID).FirstOrDefault();
                //    if (summaryItem == null)
                //    {
                //        summaryItem = new BranchMonthlySummary
                //        {
                //            SettlementID = settlement.SettlementID,
                //            BranchID = branch.BranchID
                //        };
                //        models.GetTable<BranchMonthlySummary>().InsertOnSubmit(summaryItem);
                //    }

                //    summaryItem.AchievementRatio = achievementRatio;

                //    models.SubmitChanges();
                //}

                void calcManagerBonus(BranchStore branch, CoachBranchMonthlyBonus branchBonus)
                {
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    //if(salary.LevelID == (int)Naming.ProfessionLevelDefinition.RFM)
                    //{
                    //    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 80)
                    //        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                    //        * (salary.GradeIndex / 100M)
                    //        + 0.5M) ?? 0;
                    //}
                    //else
                    {
                        salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 40)
                            * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                            * (salary.GradeIndex / 100M)
                            + 0.5M) ?? 0;
                    }

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    decimal achievementRatio = 0;

                    var summaryItem = models.GetTable<BranchMonthlySummary>().Where(m => m.SettlementID == settlement.SettlementID && m.BranchID == branch.BranchID).FirstOrDefault();
                    if (summaryItem == null)
                    {
                        summaryItem = new BranchMonthlySummary
                        {
                            SettlementID = settlement.SettlementID,
                            BranchID = branch.BranchID
                        };
                        models.GetTable<BranchMonthlySummary>().InsertOnSubmit(summaryItem);
                    }

                    summaryItem.AchievementRatio = achievementRatio;

                    models.SubmitChanges();
                }


                void calcViceManagerBonus(BranchStore branch,CoachBranchMonthlyBonus branchBonus)
                {
                    var netAchievement = Math.Max(salary.PerformanceAchievement.Value - salary.VoidShare.Value, 0);

                    var attendanceCount = salary.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    int bonusIdx = 0;
                    for (; bonusIdx < ViceManagerAttendanceIndex.Length; bonusIdx++)
                    {
                        if (attendanceCount >= ViceManagerAttendanceIndex[bonusIdx])
                        {
                            break;
                        }
                    }

                    if (bonusIdx < ViceManagerAttendanceIndex.Length)
                    {
                        salary.AttendanceBonus = ViceManagerAttendanceBonus[bonusIdx];
                    }
                    else
                    {
                        salary.AttendanceBonus = 0;
                    }

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    var indicator = models.GetTable<MonthlyIndicator>().Where(s => s.StartDate <= settlement.StartDate && s.EndExclusiveDate > settlement.StartDate).FirstOrDefault();
                    decimal achievementRatio = 0;
                    salary.ManagerBonus = 0;

                    if (indicator != null)
                    {
                        MonthlyBranchRevenueGoal item = indicator.MonthlyBranchRevenueIndicator.Where(r => r.BranchID == branch.BranchID)
                            .Where(r => r.MonthlyBranchRevenueGoal != null)
                            .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();

                        if (item != null)
                        {
                            branchBonus.BranchTotalPTCount =
                                (item.ActualCompleteLessonCount ?? 0)
                                + (item.SRCount ?? 0)
                                + (item.SDCount ?? 0)
                                + (item.ATCount ?? 0);
                            var tuitionSubtotal =
                            branchBonus.BranchTotalPTTuition =
                                (item.ActualLessonAchievement ?? 0)
                                + (item.SRAchievement ?? 0)
                                + (item.SDAchievement ?? 0)
                                + (item.ATAchievement ?? 0);

                            decimal indicatorAmt = (decimal)item.MonthlyBranchRevenueIndicator.RevenueGoal;
                            decimal basePercentage = item.MonthlyBranchRevenueIndicator.MonthlyRevenueGrade.IndicatorPercentage;
                            int totalAchievementAmt = (tuitionSubtotal + item.ActualSharedAchievement - (item.VoidShare ?? 0)) ?? 0;

                            achievementRatio = Math.Round(totalAchievementAmt * basePercentage / indicatorAmt);
                            bonusIdx = 0;
                            for (; bonusIdx < ManagerManagementBonusIndex.Length; bonusIdx++)
                            {
                                if (achievementRatio >= ManagerManagementBonusIndex[bonusIdx])
                                {
                                    break;
                                }
                            }

                            if (bonusIdx < ManagerManagementBonusIndex.Length)
                            {
                                //salary.ManagerBonus = (int)(tuitionSubtotal * ViceManagerManagementBonusRatio[bonusIdx] / 1.05M + 0.5M);
                                salary.ManagementBonusGrade = ViceManagerManagementBonusRatio[bonusIdx];
                            }
                        }
                    }

                    var summaryItem = models.GetTable<BranchMonthlySummary>().Where(m => m.SettlementID == settlement.SettlementID && m.BranchID == branch.BranchID).FirstOrDefault();
                    if (summaryItem == null)
                    {
                        summaryItem = new BranchMonthlySummary
                        {
                            SettlementID = settlement.SettlementID,
                            BranchID = branch.BranchID
                        };
                        models.GetTable<BranchMonthlySummary>().InsertOnSubmit(summaryItem);
                    }
                    summaryItem.AchievementRatio = achievementRatio;

                    models.SubmitChanges();

                    //抽個人
                    if ((salary.SpecialBonus == 0 || !salary.SpecialBonus.HasValue) && achievementRatio <= 85)
                    {
                        calcCoachBonus();
                        salary.SpecialBonus = salary.AchievementBonus;
                        salary.AchievementBonus = 0;
                        models.SubmitChanges();
                    }
                }

                //void calcFESBonus()
                //{
                //    var netAchievement = Math.Max(salary.PerformanceAchievement.Value - salary.VoidShare.Value, 0);

                //    var attendanceCount = salary.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                //    int bonusIdx = 0;
                //    for (; bonusIdx < EducatorAttendanceIndex.Length; bonusIdx++)
                //    {
                //        if (attendanceCount >= EducatorAttendanceIndex[bonusIdx])
                //        {
                //            break;
                //        }
                //    }

                //    if (bonusIdx < EducatorAttendanceIndex.Length)
                //    {
                //        salary.AttendanceBonus = EducatorAttendanceBonus[bonusIdx];
                //    }
                //    else
                //    {
                //        salary.AttendanceBonus = 0;
                //    }

                //    models.SubmitChanges();
                //}

                void calcFESBonus()
                {
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 50)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    models.SubmitChanges();
                }

                void calcRFMBonus()
                {
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 60)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    models.SubmitChanges();
                }

                void calcHealthCareBonus()
                {
                    salary.PTAttendanceCount = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.運動恢復課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程)
                            .Where(v => v.AttendingCoach == coach.CoachID).Count();

                    // 計算累計獎金
                    int durationYears = (salary.JobTenureInDays ?? 0) / 365;
                    // 計算年資加成
                    decimal seniorityBonusPercentage = AppSettings.Default.SeniorityBonusAvailableLevel.Any(l => l == coach.LevelID)
                        ? GetSeniorityBonusPercentage(durationYears, bonusConfigCoach.SeniorityBonuses)
                        : 0;
                    salary.AttendanceBonus = (int)(ComputeBonusThreshold((decimal)(salary.PTAverageUnitPrice ?? 0), salary.PTAttendanceCount ?? 0, bonusConfigSR, seniorityBonusPercentage) + 0.5M);
                    //if (HealthCareBonusIndex.ContainsKey(salary.LevelID))
                    //{
                    //    decimal totalCount = salary.PTAttendanceCount.Value + salary.TSAttendanceCount.Value / 2M;
                    //    var bonusLevel = HealthCareBonusIndex[salary.LevelID];
                    //    var bonusIdx = bonusLevel.Where(i => totalCount >= i[0]).FirstOrDefault();
                    //    if (bonusIdx != null)
                    //    {
                    //        salary.AttendanceBonus = (int)((totalCount - bonusIdx[2]) * bonusIdx[1]);
                    //        salary.PTAverageUnitPrice = bonusIdx[1];
                    //    }
                    //    else
                    //    {
                    //        salary.PTAverageUnitPrice = 0;
                    //    }
                    //}

                    salary.AttendedByOther = 0;
                    salary.AttendedShare = 0;
                    salary.AttendedByOtherAvgPrice = 0;

                    models.SubmitChanges();
                }

                void calcDietitianBonus()
                {
                    salary.PTAttendanceCount = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.營養課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                            .Where(v => v.AttendingCoach == coach.CoachID).Count();

                    salary.AttendanceBonus = 0;

                    if (coach.LevelID.HasValue && DietitianBonusIndex.ContainsKey(coach.LevelID.Value))
                    {
                        var bonusLevel = DietitianBonusIndex[coach.LevelID.Value];
                        var bonusIdx = bonusLevel.Where(i => salary.PTAttendanceCount >= i[0]).FirstOrDefault();
                        if (bonusIdx != null)
                        {
                            salary.AttendanceBonus = (salary.PTAttendanceCount -15) * bonusIdx[1];
                        }
                    }

                    models.SubmitChanges();
                }

                BranchStore branch;
                if (coach.ProfessionalLevel.IsOfficer())
                {
                    if(forRole != "officer")
                    {
                        continue;
                    }

                    foreach(var b in models.GetTable<BranchStore>())
                    {
                        var g = countableItems.Where(t => t.BranchID == b.BranchID);

                        var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == b.BranchID).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = b.BranchID
                            };
                            salary.CoachBranchMonthlyBonus.Add(branchBonus);
                        }

                        branchBonus.BranchTotalAttendanceCount = g.Count();
                        branchBonus.BranchTotalTuition = g.CalcTuition(models);

                        var branchVoidTuition = voidPayment
                            .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == b.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                            .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                        branchBonus.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;

                        models.SubmitChanges();
                    }

                    calcGeneralAchievement();

                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 50)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    int lessonAchievement = helper.LessonItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                    lessonAchievement += (helper.LessonItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);

                    salary.ManagerBonus = (int)(lessonAchievement / 1.05M * 0.01M + 0.5M);
                    models.SubmitChanges();
                }
                else if (coach.ProfessionalLevel.IsFES())
                {
                    if (forRole != "fes")
                    {
                        continue;
                    }
                    calcGeneralAchievement();
                    calcFESBonus();
                }
                else if (coach.ProfessionalLevel.IsRFM())
                {
                    if (forRole != "rfm")
                    {
                        continue;
                    }
                    calcGeneralAchievement();
                    calcRFMBonus();
                }
                else if (coach.ProfessionalLevel.IsManager())
                {
                    if (forRole != "manager")
                    {
                        continue;
                    }

                    branch = models.GetTable<BranchStore>()
                        .Where(b => b.ManagerID == coach.CoachID).FirstOrDefault();

                    if (branch == null)
                    {
                        branch = coach.CurrentWorkBranch();
                    }

                    CoachBranchMonthlyBonus branchBonus = null;
                    if (branch != null)
                    {
                        branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = branch.BranchID
                            };
                            salary.CoachBranchMonthlyBonus.Add(branchBonus);
                        }
                        var branchItems = countableItems.Where(w => w.WorkPlace == branch.BranchID);
                        branchBonus.BranchTotalAttendanceCount = branchItems.Count();
                        branchBonus.BranchTotalTuition = branchItems.CalcTuition(models);

                        var branchVoidTuition = voidPayment
                            .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == branch.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                            .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                        branchBonus.VoidShare = branchVoidTuition.Sum(t => t.VoidShare) ?? 0;

                        models.SubmitChanges();
                    }

                    calcGeneralAchievement();
                    calcManagerBonus(branch, branchBonus);
                }
                else if (coach.ProfessionalLevel.IsViceManager())
                {
                    if (forRole != "vicemanager")
                    {
                        continue;
                    }

                    if (coach.ServingCoachProperty.Any(p => p.PropertyID == (int)ServingCoachProperty.PropertyDefinition.Apprentice))
                    {
                        calcGeneralAchievement();
                        calcCoachBonus();

                        branch = models.GetTable<BranchStore>().Where(b => b.ViceManagerID == coach.CoachID).FirstOrDefault();
                        branch ??= coach.CurrentWorkBranch();

                        CoachBranchMonthlyBonus branchBonus = null;
                        if (branch != null)
                        {
                            branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                        }

                        var indicator = models.GetTable<MonthlyIndicator>().Where(s => s.StartDate <= settlement.StartDate && s.EndExclusiveDate > settlement.StartDate).FirstOrDefault();
                        decimal achievementRatio = 0;
                        salary.ManagerBonus = 0;
                        int bonusIdx = 0;

                        if (indicator != null && branchBonus != null)
                        {
                            MonthlyBranchRevenueGoal item = indicator.MonthlyBranchRevenueIndicator.Where(r => r.BranchID == branch.BranchID)
                                .Where(r => r.MonthlyBranchRevenueGoal != null)
                                .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();

                            if (item != null)
                            {
                                branchBonus.BranchTotalPTCount =
                                    (item.ActualCompleteLessonCount ?? 0)
                                    + (item.SRCount ?? 0)
                                    + (item.SDCount ?? 0)
                                    + (item.ATCount ?? 0);
                                var tuitionSubtotal =
                                branchBonus.BranchTotalPTTuition =
                                    (item.ActualLessonAchievement ?? 0)
                                    + (item.SRAchievement ?? 0)
                                    + (item.SDAchievement ?? 0)
                                    + (item.ATAchievement ?? 0);

                                decimal indicatorAmt = (decimal)item.MonthlyBranchRevenueIndicator.RevenueGoal;
                                decimal basePercentage = item.MonthlyBranchRevenueIndicator.MonthlyRevenueGrade.IndicatorPercentage;
                                int totalAchievementAmt = (tuitionSubtotal + item.ActualSharedAchievement - (item.VoidShare ?? 0)) ?? 0;

                                achievementRatio = Math.Round(totalAchievementAmt * basePercentage / indicatorAmt);
                                bonusIdx = 0;
                                for (; bonusIdx < ManagerManagementBonusIndex.Length; bonusIdx++)
                                {
                                    if (achievementRatio >= ManagerManagementBonusIndex[bonusIdx])
                                    {
                                        break;
                                    }
                                }

                                if (bonusIdx < ManagerManagementBonusIndex.Length)
                                {
                                    //salary.ManagerBonus = (int)(tuitionSubtotal * ApprenticeManagementBonusRatio[bonusIdx] / 1.05M + 0.5M);
                                    salary.ManagementBonusGrade = ApprenticeManagementBonusRatio[bonusIdx];
                                }
                                models.SubmitChanges();
                            }
                        }
                    }
                    else
                    {
                        branch = models.GetTable<BranchStore>().Where(b => b.ViceManagerID == coach.CoachID).FirstOrDefault();

                        if (branch == null)
                        {
                            branch = coach.CurrentWorkBranch();
                        }

                        CoachBranchMonthlyBonus branchBonus = null;
                        if (branch != null)
                        {
                            branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                            if (branchBonus == null)
                            {
                                branchBonus = new CoachBranchMonthlyBonus
                                {
                                    CoachMonthlySalary = salary,
                                    BranchID = branch.BranchID
                                };
                                salary.CoachBranchMonthlyBonus.Add(branchBonus);
                            }
                            var branchItems = countableItems.Where(w => w.WorkPlace == branch.BranchID);
                            branchBonus.BranchTotalAttendanceCount = branchItems.Count();
                            branchBonus.BranchTotalTuition = branchItems.CalcTuition(models);

                            var branchVoidTuition = voidPayment
                                .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == branch.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                                .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                            branchBonus.VoidShare = branchVoidTuition.Sum(t => t.VoidShare) ?? 0;

                            models.SubmitChanges();
                        }

                        calcGeneralAchievement();
                        calcViceManagerBonus(branch, branchBonus);
                    }
                }
                else if (coach.ProfessionalLevel.IsHealthCare())
                {
                    if (forRole != "health")
                    {
                        continue;
                    }

                    calcGeneralAchievement();
                    calcHealthCareBonus();
                }
                else if (coach.ProfessionalLevel.IsDietitian())
                {
                    if (forRole != "health")
                    {
                        continue;
                    }

                    calcGeneralAchievement();
                    calcDietitianBonus();
                }
                else
                {
                    if (forRole != "coach")
                    {
                        continue;
                    }

                    calcGeneralAchievement();
                    calcCoachBonus();
                }
            }
        }

        public static void ExecuteYearlyPerformanceReview(this GenericManager<BFDataContext> models, int year, String forRole = null)
        {
            var settlement = models.GetTable<YearlySettlement>().Where(s => s.Year == year).FirstOrDefault();
            if (settlement == null)
                return;

            var currentSettlementCount = settlement.Settlement.Count;

            forRole = forRole?.GetEfficientString()?.ToLower();

            var countableItems = models.GetTable<V_YearlyReview>().Where(v => v.Year == year)
                                    .Join(models.PromptEffectiveCoach(), 
                                        r => r.CoachID, c => c.CoachID, (r, c) => r);
            var yearlyPay = models.GetTable<CoachYearlyAdditionalPay>();

            foreach (var reviewItem in countableItems)
            {
                var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == reviewItem.CoachID).First();
                var salary = yearlyPay.Where(s => s.CoachID == coach.CoachID && s.Year == year).FirstOrDefault();
                if (salary == null)
                {
                    salary = new CoachYearlyAdditionalPay
                    {
                        CoachID = coach.CoachID,
                        Year = year,
                    };
                    yearlyPay.InsertOnSubmit(salary);
                }

                if (coach.CoachWorkplace.Count == 1)
                {
                    salary.WorkPlace = coach.CoachWorkplace.First().BranchID;
                }

                CoachMonthlySalary monthlySalary = settlement.Settlement
                    .OrderByDescending(s => s.SettlementID)
                    .FirstOrDefault()?.CoachMonthlySalary
                        .Where(c => c.CoachID == coach.CoachID)
                        .FirstOrDefault();

                salary.LevelID = monthlySalary?.LevelID ?? coach.LevelID ?? 0;

                models.SubmitChanges();

                void calcCoachBonus()
                {
                    var netAchievement = (int)Math.Max((reviewItem.PerformanceAchievement.Value - reviewItem.VoidShare.Value) / 1.05M + 0.5M, 0);
                    var monthlyAchievement = (int)Math.Max(netAchievement / reviewItem.DataCount.Value + 0.5M, 0);
                    var attendanceCount = (int)((reviewItem.AchievementAttendanceCount ?? 0) / reviewItem.DataCount.Value + 0.5M);

                    decimal shareRatio = 3m;
                    for (int i = 0; i < PerformanceAchievementIndex.Length; i++)
                    {
                        if (monthlyAchievement >= PerformanceAchievementIndex[i])
                        {
                            shareRatio = ShareRatioIncrementForPerformance[i];
                            break;
                        }
                    }
                    for (int i = 0; i < AttendingLessonIndex.Length; i++)
                    {
                        if (attendanceCount >= AttendingLessonIndex[i])
                        {
                            shareRatio += ShareRatioIncrementForAttendance[i];
                            break;
                        }
                    }

                    salary.GradeIndex = monthlySalary?.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.AnnualGrade ?? 0;

                    salary.AttendanceBonus = (int?)(
                            Math.Max(reviewItem.PTAttendanceCount.Value - 10 * (currentSettlementCount == reviewItem.DataCount ? currentSettlementCount : reviewItem.DataCount.Value - 1), 0)
                            * (int?)(reviewItem.PTAverageUnitPrice / 1.05M + 0.5M)
                            * salary.GradeIndex / 100M * 0.08M + 0.5M
                        ) ?? 0;

                    salary.AchievementBonus = (int?)(netAchievement * shareRatio / 100M * 0.08M + 0.5M );
                    salary.AchievementShareRatio = shareRatio;
                    models.SubmitChanges();
                }

                void calcManagerBonus()
                {

                }

                void calcViceManagerBonus()
                {

                }

                void calcFESBonus()
                {

                }

                void calcHealthCareBonus()
                {
                    var netAchievement = (int)Math.Max((reviewItem.PerformanceAchievement.Value - reviewItem.VoidShare.Value) / 1.05M + 0.5M, 0);

                    salary.AchievementBonus = (int?)(netAchievement * 0.055M + 0.5M);

                    models.SubmitChanges();
                }

                if (coach.UserProfile.IsOfficer())
                {
                    //if (forRole != "officer")
                    //{
                    //    continue;
                    //}
                }
                else if (coach.UserProfile.IsFES())
                {
                    //if (forRole != "fes")
                    //{
                    //    continue;
                    //}
                    calcFESBonus();
                }
                else if (coach.UserProfile.IsManager())
                {
                    //if (forRole != "manager")
                    //{
                    //    continue;
                    //}

                    calcManagerBonus();
                }
                else if (coach.UserProfile.IsViceManager())
                {
                    //if (forRole != "vicemanager")
                    //{
                    //    continue;
                    //}

                    calcViceManagerBonus();
                }
                else if (coach.UserProfile.IsHealthCare())
                {
                    //if (forRole != "health")
                    //{
                    //    continue;
                    //}
                    calcHealthCareBonus();
                }
                else
                {
                    //if (forRole != "coach")
                    //{
                    //    continue;
                    //}

                    calcCoachBonus();
                }
            }
        }

        public static void ExecuteVoidShareSettlement(this GenericManager<BFDataContext> models, DateTime startDate, DateTime endExclusiveDate)
        {
            var settlement = models.GetTable<Settlement>().Where(s => startDate <= s.SettlementDate && endExclusiveDate > s.SettlementDate).FirstOrDefault();
            if (settlement == null)
                return;


            var coachItems = models.PromptEffectiveCoach();
            var salaryTable = models.GetTable<CoachMonthlySalary>();

            var voidPayment = models.GetTable<VoidPayment>().Where(p => p.VoidDate >= settlement.StartDate && p.VoidDate < settlement.EndExclusiveDate)
                                .Join(models.GetTable<Payment>().Where(p => p.AllowanceID.HasValue), v => v.VoidID, p => p.PaymentID, (v, p) => p);
            //.FilterByEffective();
            foreach(var voidItem in voidPayment)
            {
                if(voidItem.TuitionAchievement.Any())
                {
                    var voidAmt = (int?)(voidItem.InvoiceAllowance.TotalAmount + voidItem.InvoiceAllowance.TaxAmount);
                    var totalShare = voidItem.TuitionAchievement.Sum(t => t.ShareAmount) ?? 1;

                    foreach(var t in voidItem.TuitionAchievement)
                    {
                        t.VoidShare = (int?)((decimal?)voidAmt * (decimal?)t.ShareAmount / totalShare);
                    }
                }
                models.SubmitChanges();
            }

            var voidTuition = voidPayment
                                .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

            foreach (var coach in coachItems)
            {
                var salary = salaryTable.Where(s => s.CoachID == coach.CoachID && s.SettlementID == settlement.SettlementID).FirstOrDefault();
                if (salary == null)
                {
                    salary = new CoachMonthlySalary
                    {
                        CoachID = coach.CoachID,
                        SettlementID = settlement.SettlementID,
                        Year = settlement.Year,
                        AvgFlag = true,
                    };
                    salaryTable.InsertOnSubmit(salary);
                }

                if (coach.CoachWorkplace.Count == 1)
                {
                    salary.WorkPlace = coach.CoachWorkplace.First().BranchID;
                }


                var voidItems = voidTuition.Where(t => t.CoachID == coach.CoachID);
                salary.VoidShare = voidItems.Sum(t => t.VoidShare) ?? 0;

                models.SubmitChanges();

                BranchStore branch;
                if (coach.UserProfile.IsOfficer())
                {
                    foreach (var g in voidPayment.GroupBy(l => l.PaymentTransaction.BranchID))
                    {
                        var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == g.Key).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = g.Key
                            };
                        }

                        branchBonus.VoidShare = (int?)voidPayment
                                .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == g.Key), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                                .Join(models.GetTable<InvoiceAllowance>(), p => p.AllowanceID, t => t.AllowanceID, (p, t) => t)
                                .Sum(a => a.TotalAmount + a.TaxAmount);
                        models.SubmitChanges();
                    }
                }
                else if ((branch = models.GetTable<BranchStore>().Where(b => b.ManagerID == coach.CoachID || b.ViceManagerID == coach.CoachID).FirstOrDefault()) != null)
                {
                    var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                    if (branchBonus == null)
                    {
                        branchBonus = new CoachBranchMonthlyBonus
                        {
                            CoachMonthlySalary = salary,
                            BranchID = branch.BranchID
                        };
                        salary.CoachBranchMonthlyBonus.Add(branchBonus);
                    }

                    branchBonus.VoidShare = (int?)voidPayment
                            .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == branch.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                            .Join(models.GetTable<InvoiceAllowance>(), p => p.AllowanceID, t => t.AllowanceID, (p, t) => t)
                            .Sum(a => a.TotalAmount + a.TaxAmount);
                    models.SubmitChanges();
                }
            }
        }

        public static IQueryable<CoachMonthlySalary> InquireMonthlySalary(this AchievementQueryViewModel viewModel, GenericManager<BFDataContext> models)
            
        {

            IQueryable<CoachMonthlySalary> items = models.GetTable<Settlement>()
                .Where(s => s.SettlementDate >= viewModel.AchievementDateFrom.Value.AddMonths(1)
                    && s.SettlementDate < viewModel.AchievementDateTo.Value.AddMonths(1))
                .Join(models.GetTable<CoachMonthlySalary>(),
                    s => s.SettlementID, c => c.SettlementID, (s, c) => c);

            return items;
        }

        public static IQueryable<V_Tuition> InquireAchievementTuition(this AchievementQueryViewModel viewModel, GenericManager<BFDataContext> models)
            
        {
            if (!viewModel.AchievementDateFrom.HasValue)
            {
                if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
                {
                    viewModel.AchievementDateFrom = DateTime.ParseExact(viewModel.AchievementYearMonthFrom, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                }
                else
                {
                    viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
                }
            }

            if (!viewModel.AchievementDateTo.HasValue)
            {

                if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthTo))
                {
                    viewModel.AchievementDateTo = DateTime.ParseExact(viewModel.AchievementYearMonthTo, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture).AddMonths(1);
                }
                else
                {
                    viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);
                }
            }

            IQueryable<V_Tuition> items = models.GetTable<V_Tuition>();

            if (viewModel.CoachID.HasValue)
            {
                items = items.Where(c => c.AttendingCoach == viewModel.CoachID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(c => viewModel.ByCoachID.Contains(c.AttendingCoach));
            }

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(c => c.BranchID == viewModel.BranchID);
            }

            if (viewModel.AchievementDateFrom.HasValue)
            {
                items = items.Where(c => c.ClassTime >= viewModel.AchievementDateFrom);
            }

            if (viewModel.AchievementDateTo.HasValue)
            {
                items = items.Where(c => c.ClassTime < viewModel.AchievementDateTo);
            }

            return items;
        }

        static int CalculateGroupXBonus(int classes, int attendance, CustomizedGroupCourse config)
        {
            int totalBonus = 0;
            // 找出適用的獎金規則
            var applicableRule = config.AttendanceRanges.FirstOrDefault(r =>
                attendance >= (r.Min ?? int.MinValue) &&
                (r.Max == null || attendance <= r.Max));

            if (applicableRule != null)
            {
                totalBonus = applicableRule.BonusPerClass * classes;
            }

            return totalBonus;
        }

        static decimal CalculateTotalBonus(decimal averagePrice, int totalClasses, int seniorityYears, BonusConfig config)
        {
            decimal totalBonus = ComputeBonusThreshold(averagePrice, totalClasses, config);

            // 計算年資加成
            decimal seniorityBonusPercentage = GetSeniorityBonusPercentage(seniorityYears, config.SeniorityBonuses);
            totalBonus += totalClasses * averagePrice * seniorityBonusPercentage;

            return totalBonus;
        }

        static decimal ComputeBonusThreshold(decimal averagePrice, int totalClasses, BonusConfig config, decimal seniorityPercentage = 0)
        {
            decimal totalBonus = 0;
            averagePrice = (int)(averagePrice / 1.05M + 0.5M);
            // 計算基本抽成獎金
            for (int i = 0; i < config.Thresholds.Length; i++)
            {
                int lowerBound = config.Thresholds[i];
                int upperBound = (i + 1 < config.Thresholds.Length)
                                    ? config.Thresholds[i + 1] - 1
                                    : config.ClassesCeiling.HasValue
                                        ? Math.Min(totalClasses, config.ClassesCeiling.Value)
                                        : totalClasses;

                if (totalClasses >= lowerBound)
                {
                    int applicableClasses = Math.Min(totalClasses, upperBound) - lowerBound + 1;
                    totalBonus += averagePrice * applicableClasses * (config.Percentages[i] + seniorityPercentage);
                    //Console.WriteLine($"累進抽成獎金: {totalBonus} , {averagePrice} * {applicableClasses} * {config.Percentages[i] + seniorityPercentage}");
                }
                else
                {
                    break;
                }
            }

            return totalBonus;
        }

        static decimal GetSeniorityBonusPercentage(int years, SeniorityBonus[] bonuses)
        {
            foreach (var bonus in bonuses)
            {
                if ((bonus.MinYears <= years) && (bonus.MaxYears == null || years < bonus.MaxYears))
                {
                    return bonus.BonusPercentage;
                }
            }
            return 0;
        }

        static BonusConfig LoadBonusConfig(string filePath)
        {
            var config = new BonusConfig();
            if (File.Exists(filePath))
            {
                string json = File.ReadAllText(filePath);
                return JsonConvert.DeserializeObject<BonusConfig>(json);
            }
            else
            {
                File.WriteAllText(filePath, config.JsonStringify());
            }
            return config;
        }

        static CustomizedGroupCourse LoadGroupXBonusConfig(string filePath)
        {
            var config = new CustomizedGroupCourse();
            if (File.Exists(filePath))
            {
                string json = File.ReadAllText(filePath);
                return JsonConvert.DeserializeObject<CustomizedGroupCourse>(json);
            }
            else
            {
                File.WriteAllText(filePath, config.JsonStringify());
            }
            return config;
        }
    }

    public class PaymentMonthlyReportItem
    {
        public String 日期 { get; set; }
        public String 分店 { get; set; }
        public String 發票號碼 { get; set; }
        public String 買受人統編 { get; set; }
        public String 摘要 { get; set; }
        public int? 退款金額_含稅 { get; set; }
        public int? 收款金額_含稅 { get; set; }
        public int? 借方金額 { get; set; }
        public int? 貸方金額 { get; set; }        
        //public String 姓名 { get; set; }
        //public String 合約編號 { get; set; }
        public String 信託 { get; set; }
    }

    public class DailyBranchReportItem
    {
        public String 日期 { get; set; }
        public int? 收款總計 { get; set; }
        public int? 現金收款 { get; set; }
        public int? 轉帳收款 { get; set; }
        public int? 刷卡收款 { get; set; }
        public int? 作廢總計 { get; set; }
        public int? 實際收款 { get; set; }
        public int? 終止退款 { get; set; }
        public int? 終止轉收 { get; set; }
    }

    class BonusConfig
    {
        public int[] Thresholds { get; set; } = [51, 61, 71, 81, 91, 101, 111, 121, 131]; // 門檻值
        public decimal[] Percentages { get; set; } = [0.3m, 0.35m, 0.4m, 0.45m, 0.5m, 0.55m, 0.65m, 0.65m, 0.7m]; // 百分比
        public SeniorityBonus[] SeniorityBonuses { get; set; } = 
            [
                new SeniorityBonus { MinYears= 5, MaxYears= 8, BonusPercentage= 0.004m },
                new SeniorityBonus { MinYears= 8, MaxYears= 10, BonusPercentage= 0.008m},
                new SeniorityBonus { MinYears = 10, MaxYears = null, BonusPercentage = 0.01m }
            ];
        public int TSBonusUnitPrice { get; set; } = 267; // 體驗課抽成單價
        public int? ClassesCeiling { get; set; } // 課程抽成上限
    }

    class SeniorityBonus
    {
        public int MinYears { get; set; }
        public int? MaxYears { get; set; } // 使用 nullable 表示無上限的情況
        public decimal BonusPercentage { get; set; }
    }

    class AttendanceRange
    {
        public int? Min { get; set; }
        public int? Max { get; set; }
        public int BonusPerClass { get; set; }
    }

    class CustomizedGroupCourse
    {
        public string CourseName { get; set; } = "購買客製化團課合約 Group X Session";
        public AttendanceRange[] AttendanceRanges { get; set; } =
        [
            new AttendanceRange { Min = 1, Max = 5, BonusPerClass = 1200 },
            new AttendanceRange { Min = 6, Max = 7, BonusPerClass = 1500 },
            new AttendanceRange { Min = 8, Max = null, BonusPerClass = 1800 }
        ];
    }

    //class BonusRules
    //{
    //    public CustomizedGroupCourse[] CustomizedGroupCourses { get; set; }
    //}


}