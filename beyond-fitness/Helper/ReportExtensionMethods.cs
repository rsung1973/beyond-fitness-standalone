using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using CommonLib.DataAccess;

namespace WebHome.Helper
{
    public static class ReportExtensionMethods
    {
        public static DataTable CreateLessonAchievementDetails<TEntity>(this ModelSource<TEntity> models,IQueryable<LessonTime> items)
            where TEntity : class, new()
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("合約編號", typeof(String)));
            table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            table.Columns.Add(new DataColumn("合約分店", typeof(String)));
            table.Columns.Add(new DataColumn("學員", typeof(String)));
            table.Columns.Add(new DataColumn("合約名稱", typeof(String)));
            table.Columns.Add(new DataColumn("課程單價", typeof(int)));
            table.Columns.Add(new DataColumn("全價計算堂數", typeof(int)));
            table.Columns.Add(new DataColumn("半價計算堂數", typeof(int)));
            table.Columns.Add(new DataColumn("上課地點", typeof(String)));
            table.Columns.Add(new DataColumn("累計上課金額", typeof(int)));
            table.Columns.Add(new DataColumn("是否信託", typeof(String)));

            var details = items.Where(t => t.RegisterLesson.RegisterLessonContract != null)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    ContractID = t.RegisterLesson.RegisterLessonContract.ContractID,
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
                r[9] = count * contract.LessonPriceType.ListPrice * discount.GroupingMemberCount * discount.PercentageOfDiscount / 100;
                r[10] = contract.ContractTrustSettlement.Any() ? "是" : "否";
                table.Rows.Add(r);
            }

            var enterprise = items.Where(t => t.RegisterLesson.RegisterLessonEnterprise != null)
                .GroupBy(t => new
                {
                    t.AttendingCoach,
                    ContractID = t.RegisterLesson.RegisterLessonEnterprise.ContractID,
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
                table.Rows.Add(r);
            }

            var others = items.Where(t => t.RegisterLesson.RegisterLessonContract == null && t.RegisterLesson.RegisterLessonEnterprise == null);
            foreach (var item in others)
            {
                var r = table.NewRow();
                r[0] = "--";
                r[1] = item.AsAttendingCoach.UserProfile.FullName();
                if (item.BranchID.HasValue)
                    r[2] = item.BranchStore.BranchName;

                r[3] = item.RegisterLesson.UserProfile.FullName();

                r[4] = item.RegisterLesson.LessonPriceType.Description
                    + " (" + item.RegisterLesson.LessonPriceType.DurationInMinutes + " 分鐘)";
                r[5] = item.RegisterLesson.LessonPriceType.ListPrice;
                var halfCount = item.LessonAttendance == null || item.LessonPlan.CommitAttendance.HasValue ? 1 : 0;
                r[6] = 1 - halfCount;
                r[7] = halfCount;
                if (item.BranchID.HasValue)
                    r[8] = item.BranchStore.BranchName;
                table.Rows.Add(r);
            }

            table.TableName = "上課統計表-人員明細";

            return table;
        }

        public static DataTable CreateTuitionAchievementDetails<TEntity>(this ModelSource<TEntity> models, IQueryable<TuitionAchievement> items)
            where TEntity : class, new()
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

        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForPISession<TEntity>(this PaymentQueryViewModel viewModel, ModelSource<TEntity> models)
            where TEntity : class, new()
        {

            IQueryable<RegisterLesson> lessons = models.GetTable<RegisterLesson>()
                    .Join(models.GetTable<LessonTime>().PILesson(), r => r.RegisterID, l => l.RegisterID, (r, l) => r);
            IQueryable<Payment> items = models.GetTable<Payment>().Join(models.GetTable<TuitionInstallment>()
                    .Join(lessons, 
                        t => t.RegisterID, r => r.RegisterID, (t, r) => t),
                p => p.PaymentID, t => t.InstallmentID, (p, t) => p);

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
                        姓名 = i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName(),
                        合約編號 = null,
                        信託 = null,                       
                        摘要 =  $"銷貨收入-自主訓練-{i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.RealName}({i.PaymentType})",
                        退款金額_含稅 =  null,
                        收款金額_含稅 =  i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = null,
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
                                姓名 = i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName(),
                                合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)銷貨收入-自主訓練-{i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.RealName}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)銷貨收入-自主訓練-{i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.RealName}",
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
        public static IEnumerable<PaymentMonthlyReportItem> CreateMonthlyPaymentReportForSale<TEntity>(this PaymentQueryViewModel viewModel, ModelSource<TEntity> models)
            where TEntity : class, new()
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
                        姓名 = null,
                        合約編號 = null,
                        信託 = null,
                        摘要 = $"其他營業收入-{((Naming.PaymentTransactionType)i.TransactionType).ToString()}-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}({i.PaymentType})",
                        退款金額_含稅 = null,
                        收款金額_含稅 = i.PayoffAmount,
                        借方金額 = null,
                        貸方金額 = null,
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
                                姓名 = i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName(),
                                合約編號 = null,
                                信託 = null,
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)其他營業收入-{((Naming.PaymentTransactionType)i.TransactionType).ToString()}-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)其他營業收入-{((Naming.PaymentTransactionType)i.TransactionType).ToString()}-{String.Join("/", i.PaymentTransaction.PaymentOrder.Select(o => o.MerchandiseWindow.ProductName))}",
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

    }

    public class PaymentMonthlyReportItem
    {
        public String 日期 { get; set; }
        public String 分店 { get; set; }
        public String 買受人統編 { get; set; }
        public String 摘要 { get; set; }
        public int? 退款金額_含稅 { get; set; }
        public int? 收款金額_含稅 { get; set; }
        public int? 借方金額 { get; set; }
        public int? 貸方金額 { get; set; }
        public String 發票號碼 { get; set; }
        public String 姓名 { get; set; }
        public String 合約編號 { get; set; }
        public String 信託 { get; set; }
    }

}