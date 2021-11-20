using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

namespace WebHome.Helper
{
    public static class InvoiceExtensionMethods
    {
        public static bool IsB2C(this InvoiceBuyer buyer)
        {
            return String.IsNullOrEmpty(buyer.ReceiptNo) || buyer.ReceiptNo == "0000000000";
        }

        public static bool IsB2C(this InvoiceAllowanceBuyer buyer)
        {
            return String.IsNullOrEmpty(buyer.ReceiptNo) || buyer.ReceiptNo == "0000000000";
        }

        public static void ProcessE0402(this GenericManager<BFDataContext> models, int year, int periodNo, int? branchID)
            
        {
            IQueryable<BranchStore> items = models.GetTable<BranchStore>();
            if (branchID.HasValue)
            {
                items = items.Where(b => b.BranchID == branchID);
            }

            foreach (var item in items)
            {
                var vacantNoList = models.DataContext.InquireVacantNo(item.BranchID, year, periodNo)
                    .GroupBy(v => v.TrackID);
                foreach (var v in vacantNoList)
                {
                    Models.MIG3_1.E0402.BranchTrackBlank result = models.CreateE0402(v.ToArray());
                    String fileName = Path.Combine(TaskExtensionMethods.E0402Outbound, result.Main.YearMonth + "-" + result.Main.BranchBan + ".xml");
                    result.ConvertToXml().Save(fileName);
                }
            }
        }

        public static WebHome.Models.MIG3_1.E0402.BranchTrackBlank CreateE0402(this GenericManager<BFDataContext> models, InquireVacantNoResult[] items)
                    
        {
            var v = items[0];
            var interval = models.GetTable<InvoiceNoInterval>().Where(i => i.SellerID == v.SellerID && i.TrackID == v.TrackID).First();
            var result = new Models.MIG3_1.E0402.BranchTrackBlank
            {
                Main = new Models.MIG3_1.E0402.Main
                {
                    BranchBan = interval.InvoiceTrackCodeAssignment.Organization.ReceiptNo,
                    HeadBan = interval.GroupID.HasValue
                        ? interval.InvoiceNoIntervalGroup.InvoiceNoInterval.First().InvoiceTrackCodeAssignment.Organization.ReceiptNo
                        : interval.InvoiceTrackCodeAssignment.Organization.ReceiptNo,
                    InvoiceTrack = v.TrackCode,
                    InvoiceType = Models.MIG3_1.E0402.InvoiceTypeEnum.Item07,
                    YearMonth = String.Format("{0}{1:00}", v.Year - 1911, v.PeriodNo * 2)
                }
            };

            List<Models.MIG3_1.E0402.DetailsBranchTrackBlankItem> details = new List<Models.MIG3_1.E0402.DetailsBranchTrackBlankItem>();
            foreach (var item in items.Where(r => !r.CheckPrev.HasValue))
            {
                InquireVacantNoResult tailItem;
                if (item.CheckNext.HasValue)
                {
                    var index = Array.IndexOf(items, item);
                    tailItem = items[index + 1];
                }
                else
                    tailItem = item;

                details.Add(new Models.MIG3_1.E0402.DetailsBranchTrackBlankItem
                {
                    InvoiceBeginNo = String.Format("{0:00000000}", item.InvoiceNo),
                    InvoiceEndNo = String.Format("{0:00000000}", tailItem.InvoiceNo)
                });

            }

            result.Details = details.ToArray();
            return result;
        }

        public static void CreateAllowanceForContract(this GenericManager<BFDataContext> models, CourseContract contractItem, int totalAllowanceAmount, UserProfile handler, DateTime? allowanceDate = null)
        {
            var paymentItems = contractItem.ContractPayment.Select(p => p.Payment)
                    .Where(p => p.PayoffAmount > 0)
                    .FilterByEffective()
                    .Where(p => p.InvoiceID.HasValue)
                    .OrderByDescending(p => p.PaymentID)
                    .ToArray();
            int totalAmt = totalAllowanceAmount;
            for (int i = 0; totalAmt > 0 && i < paymentItems.Length; i++)
            {
                var allowanceAmt = Math.Min(totalAmt, paymentItems[i].PayoffAmount.Value);
                models.PrepareAllowanceForPayment(paymentItems[i], allowanceAmt, "終止退款", allowanceDate);
                paymentItems[i].VoidPayment.HandlerID = handler?.UID;
                totalAmt -= allowanceAmt;
            }
        }

        public static InvoiceAllowance PrepareAllowanceForPayment(this GenericManager<BFDataContext> models, Payment item,decimal? allowanceAmount=null,String remark=null, DateTime? allowanceDate = null)
        {
            PaymentAllowanceValidator validator = new PaymentAllowanceValidator(models);
            var exception = validator.Validate(item, allowanceAmount, remark, allowanceDate);
            if (exception != null)
            {
                return null;
            }

            var newItem = validator.Allowance;
            if (item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                newItem.InvoiceAllowanceDispatch = new InvoiceAllowanceDispatch { };
            models.GetTable<InvoiceAllowance>().InsertOnSubmit(newItem);
            item.VoidPayment = new VoidPayment
            {
                Remark = remark,
                Status = (int)Naming.CourseContractStatus.已生效,
                VoidDate = DateTime.Now
            };

            ///刪除當月已分潤
            /// 
            DateTime startDate = DateTime.Today.FirstDayOfMonth();
            if(item.PayoffDate >= startDate && item.PayoffDate < startDate.AddMonths(1))
            {
                models.DeleteAllOnSubmit<TuitionAchievement>(t => t.InstallmentID == item.PaymentID);
            }

            return newItem;
        }
    }
}