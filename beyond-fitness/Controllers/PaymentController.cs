using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Newtonsoft.Json;

using CommonLib.MvcExtension;
using CommonLib.DataAccess;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using WebHome.Properties;

namespace WebHome.Controllers
{
    //class CheckContractPayment
    //{
    //    private static CheckContractPayment _instance = new CheckContractPayment();
    //    private Dictionary<int, long> _recentPayment;
    //    private CheckContractPayment()
    //    {
    //        _recentPayment = new Dictionary<int, long>();
    //    }

    //    public static bool IsPayoffRecently(int contractID)
    //    {
    //        lock(_instance)
    //        {
    //            var result = false;
    //            var ticks = DateTime.Now.Ticks;
    //            if(_instance._recentPayment.ContainsKey(contractID))
    //            {
    //                if((ticks-_instance._recentPayment[contractID])<60*10000000L)
    //                {
    //                    result = true;
    //                }
    //                _instance._recentPayment[contractID] = ticks;
    //            }
    //            else
    //            {
    //                _instance._recentPayment.Add(contractID, ticks);
    //            }
    //            return result;
    //        }
    //    }
    //}

    [Authorize]
    public class PaymentController : SampleController<UserProfile>
    {
        // GET: Payment
        public ActionResult PaymentIndex()
        {
            return View();
        }
        public ActionResult QueryIndex()
        {
            return View();
        }
        public ActionResult AchievementIndex()
        {
            return View();
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor,(int)Naming.RoleID.Manager,(int)Naming.RoleID.ViceManager})]
        public ActionResult EditPayment(PaymentViewModel viewModel)
        {
            switch ((Naming.PaymentTransactionType?)viewModel.TransactionType)
            {
                case Naming.PaymentTransactionType.自主訓練:
                    return EditPaymentForPISession(viewModel);
                case Naming.PaymentTransactionType.運動商品:
                case Naming.PaymentTransactionType.飲品:
                    return EditPaymentForShopping(viewModel);
                case Naming.PaymentTransactionType.體能顧問費:
                default:
                    return EditPaymentForContract(viewModel);
            }
        }

        public ActionResult LoadMerchandiseOptions(PaymentViewModel viewModel)
        {
            var items = models.GetTable<MerchandiseTransaction>().Where(m => m.TransactionID == viewModel.TransactionType)
                .Select(m => m.MerchandiseWindow)
                .Where(p => p.Status == (int)Naming.MerchandiseStatus.OnSale);
            return View("~/Views/SystemInfo/MerchandiseOptions.ascx", items);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForPISession(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForPISession.ascx";

            return result;
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForShopping(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForShopping.ascx";

            return result;
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForContract(PaymentViewModel viewModel)
        {
            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item != null)
            {
                viewModel.PayoffAmount = item.PayoffAmount;
                viewModel.PayoffDate = item.PayoffDate;
                viewModel.Status = item.Status;
                viewModel.HandlerID = item.HandlerID;
                viewModel.PaymentType = item.PaymentType;
                viewModel.InvoiceID = item.InvoiceID;
                viewModel.TransactionType = item.TransactionType;
                viewModel.BuyerReceiptNo = item.InvoiceItem.InvoiceBuyer.IsB2C() ? null : item.InvoiceItem.InvoiceBuyer.ReceiptNo;
                viewModel.Remark = item.Remark;
                viewModel.InvoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No;
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/EditPaymentForContract.ascx", item);
        }

        public ActionResult CommitPaymentForContract(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            CourseContract contract = null;
            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if (viewModel.ContractNo == null)
            {
                ModelState.AddModelError("ContractNo", "請輸入合約編號!!");
            }
            else
            {
                var no = viewModel.ContractNo.Split('-');
                int seqNo = 0;
                if (no.Length > 1)
                {
                    int.TryParse(no[1], out seqNo);
                }
                contract = models.GetTable<CourseContract>()
                    .Where(c => c.ContractNo == no[0] && c.SequenceNo == seqNo)
                    .Where(c => c.Status >= (int)Naming.CourseContractStatus.已生效)
                    .FirstOrDefault();

                if (contract == null)
                {
                    ModelState.AddModelError("ContractNo", "合約編號錯誤!!");
                }
                //else if (contract.ContractPayment.Any(p => p.Payment.PayoffDate > DateTime.Now.AddMinutes(-1)))
                //{
                //    ModelState.AddModelError("ContractNo", "本合約一分鐘內重複收款，請再確認!!");
                //}

                //else if(CheckContractPayment.IsPayoffRecently(contract.ContractID))
                //{
                //    ModelState.AddModelError("ContractNo", "本合約一分鐘內重複收款，請再確認!!");
                //}
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("errorMessage", "請選擇收款方式!!");
            }

            viewModel.ItemNo = new string[] { "01","02" };
            viewModel.Brief = new string[] { "專業顧問建置與諮詢費", "教練課程費" };
            viewModel.CostAmount = new int?[] { (viewModel.PayoffAmount * 8 + 5) / 10, (viewModel.PayoffAmount * 2 + 5) / 10 };
            viewModel.UnitCost = new int?[] { (viewModel.PayoffAmount * 8 + 5) / 10, (viewModel.PayoffAmount * 2 + 5) / 10 };
            viewModel.Piece = new int?[] { 1,1 };
            viewModel.ItemRemark = new string[] { viewModel.Remark, null };

            var invoice = checkInvoiceNo(viewModel);

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇分店!!");
            }

            if (contract!=null && contract.TotalPaidAmount() + viewModel.PayoffAmount > contract.TotalCost)
            {
                ModelState.AddModelError("PayoffAmount", "含本次收款金額已大於總收費金額!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {
                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    item = new Payment
                    {
                        Status = (int)Naming.CourseContractStatus.已生效,
                        ContractPayment = new ContractPayment { },
                        PaymentTransaction = new PaymentTransaction
                        { },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;

                    models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                    {
                        ContractID = contract.ContractID,
                        EventDate = viewModel.PayoffDate.Value,
                        Payment = item,
                        TrustType = Naming.TrustType.B.ToString()
                    });
                }

                preparePayment(viewModel, profile, item);

                item.ContractPayment.ContractID = contract.ContractID;
                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;

                models.SubmitChanges();
                TaskExtensionMethods.ProcessInvoiceToGov();

                return Json(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager,(int)Naming.RoleID.Officer })]
        public ActionResult EditPaymentForEnterprise(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForEnterprise.ascx";
            return result;
        }

        public ActionResult CommitPaymentForEnterprise(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            EnterpriseCourseContract contract = models.GetTable<EnterpriseCourseContract>().Where(t => t.ContractID == viewModel.ContractID).FirstOrDefault();
            if (contract == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            var invoice = checkInvoiceNo(viewModel);

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇分店!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {
                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    item = new Payment
                    {
                        Status = (int)Naming.CourseContractStatus.已生效,
                        EnterpriseCoursePayment = new EnterpriseCoursePayment
                        {
                            ContractID = contract.ContractID
                        },
                        PaymentTransaction = new PaymentTransaction
                        { },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;

                }

                preparePayment(viewModel, profile, item);

                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;

                models.SubmitChanges();

                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public ActionResult CommitInvoice(InvoiceViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var seller = models.GetTable<Organization>().Where(o => o.CompanyID == viewModel.SellerID).FirstOrDefault();
            if (seller == null)
            {
                return View("~/Views/SiteAction/Alert.ascx", model: "發票開立人錯誤!!");
            }

            viewModel.SellerName = seller.CompanyName;
            viewModel.SellerReceiptNo = seller.ReceiptNo;

            InvoiceViewModelValidator<UserProfile> validator = new InvoiceViewModelValidator<UserProfile>(models, seller);
            var exception = validator.Validate(viewModel);
            if (exception != null)
            {
                return View("~/Views/SiteAction/Alert.ascx", model: exception.Message);
            }

            InvoiceItem newItem = validator.InvoiceItem;
            models.GetTable<InvoiceItem>().InsertOnSubmit(newItem);
            models.SubmitChanges();

            viewModel.TrackCode = newItem.TrackCode;
            viewModel.No = newItem.No;

            if (newItem.InvoiceCarrier != null)
            {
                return View("~/Views/InvoiceBusiness/Module/InvoiceCreated.ascx", newItem);
            }
            else
            {
                return View("PrintInvoice", newItem);
            }
            //return Json(new { result = true, printUrl = VirtualPathUtility.ToAbsolute("~/SAM/NewPrintSingleInvoicePOSPage.aspx") + "?invoiceID=" + newItem.InvoiceID });

        }

        private void preparePayment(PaymentViewModel viewModel, UserProfile profile, Payment item)
        {
            item.PayoffAmount = viewModel.PayoffAmount;
            item.PayoffDate = viewModel.PayoffDate;
            item.Remark = viewModel.Remark;
            item.HandlerID = profile.UID;
            item.PaymentType = viewModel.PaymentType;
            if (item.InvoiceItem == null)
            {
                item.InvoiceItem = createPaperInvoice(viewModel);
            }
            item.TransactionType = viewModel.TransactionType;
            item.InvoiceItem.InvoiceType = (byte)viewModel.InvoiceType;
            item.InvoiceItem.InvoiceBuyer.ReceiptNo = viewModel.BuyerReceiptNo;
            item.InvoiceItem.InvoiceAmountType.TotalAmount = viewModel.PayoffAmount;
        }

        public ActionResult CommitPaymentForPISession(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (!viewModel.RegisterID.HasValue)
            {
                ModelState.AddModelError("RegisterID", "請選擇收款自主訓練!!");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            viewModel.ItemNo = new string[] { "01" };
            viewModel.Brief = new string[] { "自主訓練費用" };
            viewModel.CostAmount = new int?[] { viewModel.PayoffAmount };
            viewModel.UnitCost = new int?[] { viewModel.PayoffAmount };
            viewModel.Piece = new int?[] { 1 };
            viewModel.ItemRemark = new string[] { viewModel.Remark };

            var invoice = checkInvoiceNo(viewModel);

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇分店!!");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("errorMessage", "請選擇收款方式!!");
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {
                var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).First();

                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    item = new Payment
                    {
                        Status = (int)Naming.CourseContractStatus.已生效,
                        TuitionInstallment = new TuitionInstallment
                        {

                        },
                        PaymentTransaction = new PaymentTransaction
                        { },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    item.TuitionAchievement.Add(new TuitionAchievement
                    {
                        CoachID = lesson.AdvisorID.Value,
                        ShareAmount = viewModel.PayoffAmount
                    });
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;
                }
                item.TuitionInstallment.RegisterID = lesson.IntuitionCharge.RegisterID;
                item.TuitionInstallment.PayoffAmount = viewModel.PayoffAmount;
                item.TuitionInstallment.PayoffDate = viewModel.PayoffDate;

                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;

                preparePayment(viewModel, profile, item);

                models.SubmitChanges();
                models.AttendLesson(lesson.LessonTime.First());
                TaskExtensionMethods.ProcessInvoiceToGov();

                return Json(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> TestCommitPaymentForShopping(PaymentViewModel viewModel, int? times)
        {
            ActionResult result = new EmptyResult();
            await Task.Run(() =>
            {
                for (int i = 0; i < (times ?? 1000); i++)
                {
                    result = CommitPaymentForShopping(viewModel);
                }
            });
            return result;
        }

        public ActionResult CommitPaymentForShopping(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (!viewModel.ProductID.HasValue)
            {
                ModelState.AddModelError("RegisterID", "請選擇品項!!");
            }

            if (!viewModel.ProductCount.HasValue)
            {
                ModelState.AddModelError("RegisterID", "請輸入數量!!");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            var product = models.GetTable<MerchandiseWindow>().Where(c => c.ProductID == viewModel.ProductID).FirstOrDefault();
            if (product == null)
            {
                ModelState.AddModelError("ProductID", "請選擇品項!!");
            }
            else
            {
                int? totalAmt = product.UnitPrice * viewModel.ProductCount;
                if (totalAmt > viewModel.PayoffAmount)
                {
                    viewModel.ItemNo = new string[] { "01","02" };
                    viewModel.Brief = new string[] { product.ProductName,"優惠折扣" };
                    viewModel.CostAmount = new int?[] { totalAmt, viewModel.PayoffAmount - totalAmt };
                    viewModel.UnitCost = new int?[] { product.UnitPrice, viewModel.PayoffAmount - totalAmt };
                    viewModel.Piece = new int?[] { viewModel.ProductCount, 1 };
                    viewModel.ItemRemark = new string[] { viewModel.Remark, null };
                }
                else
                {
                    viewModel.ItemNo = new string[] { "01" };
                    viewModel.Brief = new string[] { product.ProductName };
                    viewModel.CostAmount = new int?[] { product.UnitPrice * viewModel.ProductCount };
                    viewModel.UnitCost = new int?[] { product.UnitPrice };
                    viewModel.Piece = new int?[] { viewModel.ProductCount };
                    viewModel.ItemRemark = new string[] { viewModel.Remark };
                }
            }

            var invoice = checkInvoiceNo(viewModel);

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇分店!!");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("errorMessage", "請選擇收款方式!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {

                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    item = new Payment
                    {
                        Status = (int)Naming.CourseContractStatus.已生效,
                        PaymentTransaction = new PaymentTransaction
                        { },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;
                }
                else
                {
                    models.DeleteAllOnSubmit<PaymentOrder>(p => p.PaymentID == item.PaymentID);
                }

                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;
                item.PaymentTransaction.PaymentOrder.Add(new PaymentOrder
                {
                    ProductID = viewModel.ProductID.Value,
                    ProductCount = viewModel.ProductCount.Value
                });

                preparePayment(viewModel, profile, item);

                models.SubmitChanges();

                //invoice.RandomNo = String.Format("{0:0000}", invoice.InvoiceID % 10000);
                //models.SubmitChanges();

                TaskExtensionMethods.ProcessInvoiceToGov();
                
                //if (invoice.InvoiceCancellation != null && invoice.InvoiceType!=(int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                //{
                //    models.ExecuteCommand(@"DELETE FROM Document
                //        FROM Document INNER JOIN
                //            DerivedDocument ON Document.DocID = DerivedDocument.DocID
                //        WHERE (DerivedDocument.SourceID = {0})", invoice.InvoiceID);
                //    models.ExecuteCommand(@"delete InvoiceCancellation where InvoiceID = {0}", invoice.InvoiceID);
                //    models.ExecuteCommand(@"delete Payment where InvoiceID = {0} and PaymentID <> {1}", invoice.InvoiceID, item.PaymentID);
                //}

                return Json(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        private InvoiceItem checkInvoiceNo(PaymentViewModel viewModel)
        {
            if (!viewModel.PayoffAmount.HasValue || viewModel.PayoffAmount <= 0)
            {
                ModelState.AddModelError("PayoffAmount", "請輸入收款金額!!");
                return null;
            }

            String trackCode, no;
            viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
            if (viewModel.InvoiceType != Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
            {
                if (viewModel.InvoiceNo == null || !Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
                {
                    ModelState.AddModelError("InvoiceNo", "請輸入正確發票號碼!!");
                }
                else
                {
                    trackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
                    no = viewModel.InvoiceNo.Substring(2);
                    var invoice = models.GetTable<InvoiceItem>().Where(i => i.TrackCode == trackCode && i.No == no).FirstOrDefault();
                    //if (invoice != null && invoice.Payment.Any(p => p.VoidPayment != null))
                    //{
                    //    ModelState.AddModelError("InvoiceNo", "發票號碼重複!!");
                    //}
                    if (invoice != null)
                    {
                        if (invoice.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                        {
                            ModelState.AddModelError("InvoiceNo", "發票號碼為已開立之電子發票!!");
                            return null;
                        }
                        //else if (invoice.InvoiceCancellation != null)
                        //{
                        //    ModelState.AddModelError("InvoiceNo", "該號碼之發票已作廢!!");
                        //    return null;
                        //}
                    }
                    return invoice;
                }
            }
            else
            {
                prepareInvoice(viewModel);

                var seller = models.GetTable<Organization>().Where(o => o.CompanyID == viewModel.SellerID).FirstOrDefault();
                if (seller == null)
                {
                    ModelState.AddModelError("SellerID", "發票開立人錯誤!!");
                    return null;
                }

                viewModel.SellerName = seller.CompanyName;
                viewModel.SellerReceiptNo = seller.ReceiptNo;

                InvoiceViewModelValidator<UserProfile> validator = new InvoiceViewModelValidator<UserProfile>(models, seller);
                var exception = validator.Validate(viewModel);
                if (exception != null)
                {
                    if (exception.RequestName == null)
                    {
                        ModelState.AddModelError("errorMessage", exception.Message);
                    }
                    else
                    {
                        ModelState.AddModelError(exception.RequestName, exception.Message);
                    }
                    return null;
                }

                InvoiceItem newItem = validator.InvoiceItem;
                newItem.InvoiceItemDispatch = new InvoiceItemDispatch { };
                models.GetTable<InvoiceItem>().InsertOnSubmit(newItem);

                return newItem;
            }

            return null;
        }

        private void prepareInvoice(PaymentViewModel viewModel)
        {
            viewModel.SalesAmount = (int)Math.Round((decimal)viewModel.PayoffAmount / 1.05m);
            viewModel.TaxAmount = viewModel.PayoffAmount - viewModel.SalesAmount;
        }

        protected InvoiceItem createPaperInvoice(PaymentViewModel viewModel)
        {
            InvoiceItem item;
            item = new InvoiceItem
            {
                Document = new Document
                {
                    DocDate = DateTime.Now,
                    DocType = (int)Naming.DocumentTypeDefinition.E_Invoice
                },
                InvoiceDate = viewModel.PayoffDate,
                InvoiceType = (byte)Naming.InvoiceTypeDefinition.二聯式,
                SellerID = viewModel.SellerID.Value,
                InvoiceSeller = new InvoiceSeller
                {
                },
                InvoiceBuyer = new InvoiceBuyer { },
                InvoiceAmountType = new InvoiceAmountType
                {
                }
            };

            if (viewModel.InvoiceType != Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
            {
                item.TrackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
                item.No = viewModel.InvoiceNo.Substring(2);
            }

            return item;
        }

        public ActionResult ListUnpaidPISession(int? branchID)
        {
            var profile = HttpContext.GetUser();
            var items = models.GetTable<LessonTime>()
                .Where(r => r.ClassTime < DateTime.Today.AddDays(1))
                .Where(r => r.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)
                .Where(r => r.RegisterLesson.IntuitionCharge.TuitionInstallment.Count == 0
                    || !r.RegisterLesson.IntuitionCharge.TuitionInstallment.Any(t => t.Payment.VoidPayment == null || t.Payment.VoidPayment.Status != (int)Naming.CourseContractStatus.已生效));

            if (branchID.HasValue)
            {
                items = items.Where(r => r.BranchID == branchID);
            }

            return View("~/Views/Payment/Module/UnpaidPISession.ascx", items);
        }

        public ActionResult PaymentAuditSummary()
        {
            var profile = HttpContext.GetUser();
            if (profile.IsAssistant() || profile.IsManager() || profile.IsViceManager() || profile.IsAccounting()/* || profile.IsOfficer()*/)
            {
                return View("~/Views/Payment/Module/PaymentAuditSummary.ascx");
            }
            else
            {
                return View("~/Views/Payment/Module/PaymentAuditSummaryCoachView.ascx");
            }
        }

        public ActionResult ListPaymentByInvoice(PaymentViewModel viewModel)
        {
            IQueryable<Payment> items = models.GetTable<Payment>().Where(p => p.TransactionType.HasValue);
            if (viewModel.InvoiceNo == null || !Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
            {
                ModelState.AddModelError("InvoiceNo", "請輸入正確發票號碼!!");
            }

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            string trackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
            string no = viewModel.InvoiceNo.Substring(2);

            items = items
                .Where(p=>p.Status==(int)Naming.CourseContractStatus.已生效)
                .Where(p => p.InvoiceItem.TrackCode == trackCode && p.InvoiceItem.No == no);

            if (items.Count(p => p.VoidPayment != null) > 0)
            {
                ModelState.AddModelError("InvoiceNo", "發票已作廢或作廢審核中!!");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            return View("~/Views/Payment/Module/PaymentQueryList.ascx", items);
        }

        public ActionResult ListContractByContractNo(PaymentViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>()
                    .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效);

            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if (viewModel.ContractNo != null)
            {
                var no = viewModel.ContractNo.Split('-');
                int seqNo = 0;
                if (no.Length > 1)
                {
                    int.TryParse(no[1], out seqNo);
                }
                items = items.Where(c => c.ContractNo == no[0]
                    && c.SequenceNo == seqNo);
            }
            else
            {
                items = items.Where(c => false);
            }

            return View("~/Views/Payment/Module/ContractQueryList.ascx", items);

        }


        public ActionResult AuditPayment(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            IQueryable<Payment> items = models.GetPaymentToAuditByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;

            return View("~/Views/Payment/Module/AuditPayment.ascx", items);
        }

        public ActionResult ApproveToVoidPayment(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            IQueryable<Payment> items = models.GetVoidPaymentToApproveByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewAction = "待審核";

            return View("~/Views/Payment/Module/ApproveToVoidPayment.ascx", items);
        }

        public ActionResult EditToVoidPayment(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            IQueryable<Payment> items = models.GetVoidPaymentToEditByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewAction = "草稿";

            return View("~/Views/Payment/Module/ApproveToVoidPayment.ascx", items);
        }



        public ActionResult ApproveToVoidPaymentView(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            var items = models.GetTable<Payment>().Where(v => v.PaymentID == viewModel.PaymentID)
                            .Join(models.GetTable<Payment>(), p => p.InvoiceID, v => v.InvoiceID, (p, v) => v)
                            .Where(p => p.VoidPayment != null);
            var item = items.Select(p => p.VoidPayment).FirstOrDefault();

            if (item != null)
            {
                viewModel.Remark = item.Remark;
                viewModel.Status = item.Status;
            }

            ViewBag.ViewModel = viewModel;

            return View("~/Views/Payment/Module/VoidPaymentApprovalView.ascx", items);
        }

        public ActionResult EditToVoidPaymentView(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)ApproveToVoidPaymentView(viewModel);
            result.ViewName = "~/Views/Payment/Module/VoidPaymentEditingView.ascx";
            return result;
        }

        public ActionResult ExecuteVoidPaymentStatus(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            if (profile == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "連線已中斷，請重新登入!!");
            }

            var items = models.GetTable<Payment>().Where(v => v.PaymentID == viewModel.PaymentID)
                            .Join(models.GetTable<Payment>(), p => p.InvoiceID, v => v.InvoiceID, (p, v) => v)
                        .Join(models.GetTable<VoidPayment>(), p => p.PaymentID, v => v.VoidID, (p, v) => v);

            if (items.Count() > 0)
            {
                try
                {
                    foreach (var item in items)
                    {
                        item.VoidPaymentLevel.Add(new VoidPaymentLevel
                        {
                            ExecutorID = profile.UID,
                            LevelDate = DateTime.Now,
                            LevelID = viewModel.Status.Value
                        });
                        item.Status = viewModel.Status.Value;
                        item.Drawback = viewModel.Drawback;
                        if (viewModel.Status == (int)Naming.CourseContractStatus.待審核)
                        {
                            item.Remark = viewModel.Remark;
                        }

                    }

                    models.SubmitChanges();

                    if (viewModel.Status == (int)Naming.CourseContractStatus.已生效)
                    {
                        foreach (var item in items)
                        {
                            withdrawPayment(item);
                        }

                        var invForAllowance = items.Select(i => i.Payment).Where(p => p.AllowanceID.HasValue && p.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票);
                        if (invForAllowance.Count() > 0)
                        {
                            return Json(new
                            {
                                result = true,
                                invoiceID = invForAllowance.Select(p => p.InvoiceID).ToArray()
                            });
                        }
                    }

                    return Json(new { result = true });
                }
                catch(Exception ex)
                {
                    Logger.Error(ex);
                    return Json(new { result = false, message = ex.Message });
                }
            }

            return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
        }

        private void withdrawPayment(VoidPayment item)
        {
            if (item.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練)
            {
                models.ExecuteCommand(@"
                            DELETE FROM LessonAttendance
                            FROM     LessonAttendance INNER JOIN
                                           LessonTime ON LessonAttendance.LessonID = LessonTime.LessonID
                            WHERE   (LessonTime.RegisterID = {0})", item.Payment.TuitionInstallment.IntuitionCharge.RegisterLesson.RegisterID);
            }

            if (item.Payment.InvoiceItem.InvoiceCancellation != null)
            {
                if (item.Payment.ContractPayment != null)
                {
                    if (item.Payment.PayoffDate.Value.AddMonths(1) > item.VoidDate)
                    {
                        models.ExecuteCommand(@"
                            DELETE FROM ContractTrustTrack
                            FROM     ContractTrustTrack INNER JOIN
                                           Payment ON ContractTrustTrack.PaymentID = Payment.PaymentID INNER JOIN
                                           VoidPayment ON Payment.PaymentID = VoidPayment.VoidID
                            WHERE   (ContractTrustTrack.PaymentID = {0})", item.VoidID);
                    }
                    else
                    {
                        models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                        {
                            ContractID = item.Payment.ContractPayment.ContractID,
                            EventDate = item.VoidDate.Value,
                            VoidID = item.VoidID,
                            TrustType = Naming.TrustType.V.ToString()
                        });
                    }
                }

                if (item.Payment.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                    && item.Payment.InvoiceItem.InvoiceCancellation.InvoiceCancellationDispatch == null)
                {
                    item.Payment.InvoiceItem.InvoiceCancellation.InvoiceCancellationDispatch = new InvoiceCancellationDispatch { };
                    models.SubmitChanges();
                }
            }
            else
            {
                InvoiceAllowance allowance;
                if (item.Payment.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                    && item.Payment.InvoiceItem.InvoiceAllowance.Count>0 
                    && (allowance = item.Payment.InvoiceItem.InvoiceAllowance.First()).InvoiceAllowanceDispatch == null)
                {
                    allowance.InvoiceAllowanceDispatch = new InvoiceAllowanceDispatch { };
                    models.SubmitChanges();
                }

                if (item.Payment.ContractPayment != null)
                {
                    models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                    {
                        ContractID = item.Payment.ContractPayment.ContractID,
                        EventDate = item.VoidDate.Value,
                        VoidID = item.VoidID,
                        TrustType = Naming.TrustType.V.ToString()
                    });
                }

                models.SubmitChanges();
            }

            TaskExtensionMethods.ProcessInvoiceToGov();

        }

        public ActionResult CancelVoidPayment(PaymentViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var items = models.GetTable<Payment>().Where(v => v.PaymentID == viewModel.PaymentID)
                            .Join(models.GetTable<Payment>(), p => p.InvoiceID, v => v.InvoiceID, (p, v) => v);

            if (items.Count() > 0)
            {
                try
                {
                    foreach (var item in items.ToList())
                    {
                        models.DeleteAnyOnSubmit<InvoiceCancellation>(c => c.InvoiceID == item.InvoiceID);
                        models.DeleteAnyOnSubmit<Document>(d => models.GetTable<DerivedDocument>()
                            .Where(r => r.SourceID == item.InvoiceID)
                            .Select(r => r.DocID).Contains(d.DocID));
                        models.DeleteAnyOnSubmit<VoidPayment>(v => v.VoidID == item.PaymentID);
                        models.SubmitChanges();
                    }
                    return Json(new { result = true });
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                    return Json(new { result = false, message = ex.Message });
                }
            }

            return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
        }


        public ActionResult VoidPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/VoidPayment.ascx");
        }

        public ActionResult CommitToVoidPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (viewModel.VoidID==null || viewModel.VoidID.Length==0)
            {
                ModelState.AddModelError("InvoiceNo", "發票資料無效!!");
            }

            try
            {
                List<VoidPayment> items = new List<VoidPayment>();
                foreach (var v in viewModel.VoidID)
                {
                    var item = models.GetTable<Payment>().Where(p => p.PaymentID == v).FirstOrDefault();
                    if (item.VoidPayment == null)
                    {
                        voidPaymentForInvoice(item);

                        item.VoidPayment = new Models.DataEntity.VoidPayment
                        {
                            HandlerID = profile.UID,
                            Remark = viewModel.Remark,
                            Status = (int)Naming.CourseContractStatus.待審核,
                            VoidDate = DateTime.Now
                        };

                        if (profile.IsManager())
                        {
                            item.VoidPayment.Status = (int)Naming.CourseContractStatus.已生效;
                        }
                        items.Add(item.VoidPayment);
                    }
                }

                if (items.Count>0)
                {
                    models.SubmitChanges();

                    foreach(var v in items)
                    {
                        if(!v.Payment.PaymentAudit.AuditorID.HasValue)
                        {
                            v.Payment.PaymentAudit.AuditorID = Settings.Default.DefaultCoach;
                            v.Payment.PaymentAudit.AuditDate = DateTime.Now;
                            models.SubmitChanges();
                        }
                    }

                    if (profile.IsManager())
                    {
                        foreach (var item in items)
                        {
                            withdrawPayment(item);
                        }

                        var invForAllowance = items.Select(i => i.Payment).Where(p => p.AllowanceID.HasValue && p.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票);
                        if (invForAllowance.Count() > 0)
                        {
                            return Json(new
                            {
                                result = true,
                                invoiceID = invForAllowance.Select(p => p.InvoiceID).ToArray()
                            });
                        }
                        else
                        {
                            return Json(new { result = true, message = "作廢收款資料已生效!!" });
                        }
                    }
                    return Json(new { result = true, message = "作廢收款資料已送交審核!!" });
                }
                else
                    return Json(new { result = false, message = "作廢收款資料錯誤!!" });

            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        private void voidPaymentForInvoice(Payment item)
        {
            if (item.InvoiceID.HasValue)
            {
                //createAllowance(item);

                if (item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                    && (item.InvoiceItem.InvoiceDate.Value.Year < DateTime.Today.Year || (item.InvoiceItem.InvoiceDate.Value.Month + 1) / 2 < (DateTime.Today.Month + 1) / 2))
                {
                    createAllowance(item);
                }
                else
                {
                    if (item.InvoiceItem.InvoiceCancellation == null)
                        cancelInvoice(item.InvoiceItem);
                }
            }
        }

        private InvoiceAllowance createAllowance(Payment item)
        {
            PaymentAllowanceValidator<UserProfile> validator = new PaymentAllowanceValidator<UserProfile>(models);
            var exception = validator.Validate(item);
            if (exception != null)
            {
                ModelState.AddModelError("errorMsg", exception.Message);
                return null;
            }

            var newItem = validator.Allowance;
            newItem.InvoiceAllowanceDispatch = new InvoiceAllowanceDispatch { };
            models.GetTable<InvoiceAllowance>().InsertOnSubmit(newItem);

            return newItem;
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult CommitToAuditPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            try
            {
                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    return Json(new { result = false,message="收款資料錯誤!!" });
                }

                item.PaymentAudit.AuditDate = DateTime.Now;
                item.PaymentAudit.AuditorID = profile.UID;

                models.SubmitChanges();

                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        private void cancelInvoice(InvoiceItem invoice)
        {
            invoice.InvoiceCancellation = new InvoiceCancellation
            {
                InvoiceItem = invoice,
                CancellationNo = invoice.TrackCode + invoice.No,
                Remark = "作廢收款",
                CancelReason = "作廢收款",
                //ReturnTaxDocumentNo = invoice.ReturnTaxDocumentNumber,
                CancelDate = DateTime.Now
            };

            var doc = new DerivedDocument
            {
                Document = new Document
                {
                    DocType = (int)Naming.DocumentTypeDefinition.E_InvoiceCancellation,
                    DocDate = DateTime.Now
                },
                SourceID = invoice.InvoiceID
            };

            models.GetTable<DerivedDocument>().InsertOnSubmit(doc);
        }

        public ActionResult InquirePayment(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<Payment> items = models.GetTable<Payment>()
                .Where(p => p.TransactionType.HasValue)
                .Where(p => p.PayoffAmount > 0)
                .Where(p => p.Status.HasValue);

            IQueryable<VoidPayment> voidItems = models.GetTable<VoidPayment>();

            IQueryable<InvoiceItem> invoiceItems = models.GetTable<InvoiceItem>();

            var profile = HttpContext.GetUser();

            Expression<Func<Payment, bool>> queryExpr = c => false;
            bool hasConditon = false;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName != null)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.ContractPayment.CourseContract.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.UserName) || m.UserProfile.Nickname.Contains(viewModel.UserName)));
                queryExpr = queryExpr.Or(c => c.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.RealName.Contains(viewModel.UserName));
                queryExpr = queryExpr.Or(c => c.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.Nickname.Contains(viewModel.UserName));
            }

            if(!hasConditon)
            {
                viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
                if (viewModel.ContractNo != null)
                {
                    hasConditon = true;
                    var no = viewModel.ContractNo.Split('-');
                    int seqNo;
                    if (no.Length > 1)
                    {
                        int.TryParse(no[1], out seqNo);
                        queryExpr = queryExpr.Or(c => c.ContractPayment.CourseContract.ContractNo.StartsWith(no[0])
                            && c.ContractPayment.CourseContract.SequenceNo == seqNo);
                    }
                    else
                    {
                        queryExpr = queryExpr.Or(c => c.ContractPayment.CourseContract.ContractNo.StartsWith(viewModel.ContractNo));
                    }
                }
            }

            if(!hasConditon)
            {
                if (viewModel.BranchID.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.PaymentTransaction.BranchID == viewModel.BranchID);
                }
            }

            if(!hasConditon)
            {
                if (viewModel.HandlerID.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.HandlerID == viewModel.HandlerID);
                    voidItems = voidItems.Where(v => v.HandlerID == viewModel.HandlerID);
                }
            }

            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsAccounting() || profile.IsServitor() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var branches = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID);
                    items = items
                        .Join(models.GetTable<PaymentTransaction>()
                            .Join(branches, p => p.BranchID, b => b.BranchID, (p, b) => p),
                            c => c.PaymentID, h => h.PaymentID, (c, h) => c);
                }
                else if (profile.IsCoach())
                {
                    items = items.Where(p => p.HandlerID == profile.UID);
                    voidItems = voidItems.Where(v => v.HandlerID == profile.UID);
                }
                else
                {
                    items = items.Where(p => false);
                }
            }

            if (hasConditon)
            {
                items = items.Where(queryExpr);
            }

            if (viewModel.TransactionType.HasValue)
                items = items.Where(c => c.TransactionType == viewModel.TransactionType);

            if (viewModel.Status.HasValue)
            {
                //items = items.Where(c => c.Status == viewModel.Status);
                //items = items.Where(c => c.VoidPayment.Status == viewModel.Status);
                items = items.Where(c => c.Status == viewModel.Status
                    || c.VoidPayment.Status == viewModel.Status);
            }

            if (viewModel.InvoiceType.HasValue)
            {
                invoiceItems = invoiceItems.Where(c => c.InvoiceType == (byte)viewModel.InvoiceType);
            }


            viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
            if (viewModel.InvoiceNo != null && Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
            {
                String trackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
                String no = viewModel.InvoiceNo.Substring(2);
                invoiceItems = invoiceItems.Where(c => c.TrackCode == trackCode
                    && c.No == no);

                //allowanceItems = allowanceItems.Where(a => a.AllowanceNumber == viewModel.InvoiceNo);
                //voidItems = voidItems
                //    .Join(models.GetTable<Payment>()
                //        .Join(models.GetTable<InvoiceItem>().Where(i => i.TrackCode == trackCode && i.No == no),
                //            p => p.InvoiceID, i => i.InvoiceID, (p, i) => p),
                //        v => v.VoidID, p => p.PaymentID, (v, p) => v);
            }

            viewModel.BuyerReceiptNo = viewModel.BuyerReceiptNo.GetEfficientString();
            if(viewModel.BuyerReceiptNo!=null)
            {
                invoiceItems = invoiceItems.Where(c => c.InvoiceBuyer.ReceiptNo == viewModel.BuyerReceiptNo);
            }

            Expression<Func<InvoiceItem,bool>> queryInv = f => true;
            bool dateQuery = false;
            Expression<Func<Payment, bool>> dateItems = p => true;
            IQueryable<InvoiceAllowance> allowanceItems = models.GetTable<InvoiceAllowance>();
            IQueryable<InvoiceCancellation> cancelledItems = models.GetTable<InvoiceCancellation>();

            if (viewModel.PayoffDateFrom.HasValue)
            {
                dateQuery = true;
                dateItems = dateItems.And(p => p.PayoffDate >= viewModel.PayoffDateFrom);
                queryInv = queryInv.And(i => i.InvoiceDate >= viewModel.PayoffDateFrom);
                cancelledItems = cancelledItems.Where(i => i.CancelDate >= viewModel.PayoffDateFrom);
                allowanceItems = allowanceItems.Where(a => a.AllowanceDate >= viewModel.PayoffDateFrom);
                voidItems = voidItems.Where(v => v.VoidDate >= viewModel.PayoffDateFrom);
            }

            if (viewModel.PayoffDateTo.HasValue)
            {
                dateQuery = true;
                dateItems = dateItems.And(i => i.PayoffDate < viewModel.PayoffDateTo.Value.AddDays(1));
                queryInv = queryInv.And(i => i.InvoiceDate < viewModel.PayoffDateTo.Value.AddDays(1));
                cancelledItems = cancelledItems.Where(i => i.CancelDate < viewModel.PayoffDateTo.Value.AddDays(1));
                allowanceItems = allowanceItems.Where(a => a.AllowanceDate < viewModel.PayoffDateTo.Value.AddDays(1));
                voidItems = voidItems.Where(v => v.VoidDate < viewModel.PayoffDateTo.Value.AddDays(1));
            }

            IQueryable<Payment> result = items.Join(invoiceItems, p => p.InvoiceID, i => i.InvoiceID, (p, i) => p);
            if (dateQuery)
            {
                result = result.Join(models.GetTable<Payment>().Where(dateItems), p => p.PaymentID, d => d.PaymentID, (p, d) => p)
                    .Union(result.Join(models.GetTable<InvoiceItem>().Where(queryInv), p => p.InvoiceID, i => i.InvoiceID, (p, i) => p))
                    .Union(result.Join(allowanceItems, p => p.AllowanceID, a => a.AllowanceID, (p, a) => p)
                    .Union(result.Join(voidItems, p => p.PaymentID, c => c.VoidID, (p, c) => p)));
            }

            if (viewModel.IsCancelled == true)
            {
                result = result
                    .Where(p => p.VoidPayment != null || p.AllowanceID.HasValue);

            }
            else if (viewModel.IsCancelled == false)
            {
                result = items
                    .Where(p => p.VoidPayment == null && !p.AllowanceID.HasValue);
            }

            return View("~/Views/Payment/Module/PaymentInvoiceList.ascx", result);

        }

        class _PaymentItem
        {
            public int Direction { get; set; }
            public Payment Item { get; set; }
        }

        public ActionResult CreatePaymentQueryXlsx(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquirePayment(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;
            var voidItems = items.Join(models.GetTable<VoidPayment>(), p => p.PaymentID, v => v.VoidID, (p, v) => p);

            var details = items.ToArray().Select(p => new _PaymentItem { Direction = 1, Item = p })
                    .Concat(voidItems.ToArray().Select(p => new _PaymentItem { Direction = -1, Item = p }))
                .OrderByDescending(i => i.Item.PayoffDate)
                .ThenBy(i => i.Item.PaymentID)
                .Select(i => new
                {
                    發票號碼 = i.Item.InvoiceItem.TrackCode + i.Item.InvoiceItem.No,
                    分店 = i.Item.PaymentTransaction.BranchStore.BranchName,
                    收款人 = i.Item.UserProfile.FullName(),
                    學員 = i.Item.TuitionInstallment != null
                        ? i.Item.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : i.Item.ContractPayment != null
                            ? i.Item.ContractPayment.CourseContract.CourseContractType.IsGroup == true
                                ? String.Join("/", i.Item.ContractPayment.CourseContract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                                : i.Item.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--",
                    收款日期 = String.Format("{0:yyyy/MM/dd}", i.Item.PayoffDate),
                    收款品項 = String.Concat(((Naming.PaymentTransactionType)i.Item.TransactionType).ToString(),
                            i.Item.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.Item.TransactionType == (int)Naming.PaymentTransactionType.飲品
                                ? String.Format("({0})", String.Join("、", i.Item.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)))
                                : null),
                    金額 = i.Direction > 0
                        ? i.Item.PayoffAmount >= 0 ? i.Item.PayoffAmount : -i.Item.PayoffAmount
                        : i.Item.PayoffAmount,
                    未稅金額 = i.Direction > 0
                        ? i.Item.PayoffAmount >= 0 ? Math.Round((decimal)i.Item.PayoffAmount/1.05m) : Math.Round((decimal)-i.Item.PayoffAmount/1.05m)
                        : Math.Round((decimal)i.Item.PayoffAmount/1.05m),
                    收款方式 = i.Item.PaymentType,
                    發票類型 = i.Item.InvoiceID.HasValue
                        ? i.Item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本"
                        : "--",
                    發票狀態 = i.Direction > 0
                        ? i.Item.VoidPayment == null
                            ? "已開立"
                            : i.Item.VoidPayment.Status == (int)Naming.CourseContractStatus.已生效
                                ? i.Item.InvoiceItem.InvoiceAllowance.Any()
                                    ? "已折讓"
                                    : "已作廢"
                                : "已開立"
                        : i.Item.VoidPayment.Status == (int)Naming.CourseContractStatus.已生效
                            ? i.Item.InvoiceItem.InvoiceAllowance.Any()
                                ? "已折讓"
                                : "已作廢"
                            : "--",
                    買受人統編 = i.Item.InvoiceID.HasValue
                        ? i.Item.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.Item.InvoiceItem.InvoiceBuyer.ReceiptNo
                        : "--",
                    合約編號 = i.Item.ContractPayment != null
                        ? i.Item.ContractPayment.CourseContract.ContractNo()
                        : "--",
                    合約總金額 = i.Item.ContractPayment != null
                        ? i.Item.ContractPayment.CourseContract.TotalCost
                        : (int?)null,
                    狀態 = i.Direction > 0
                        ? String.Concat((Naming.CourseContractStatus)i.Item.Status, i.Item.PaymentAudit.AuditorID.HasValue ? "" : "(*)")
                        : String.Concat((Naming.VoidPaymentStatus)i.Item.VoidPayment.Status, "(作廢)"),
                    備註 = i.Direction > 0 ? i.Item.Remark : i.Item.VoidPayment.Remark,
                    i.Item.PaymentID,
                    VoidID = i.Item.VoidPayment!=null ? i.Item.VoidPayment.VoidID : (int?)null
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("PaymentDetails.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "收款資料明細";
                ds.Tables.Add(table);

                foreach (var r in table.Select("買受人統編 = '0000000000'"))
                {
                    r["買受人統編"] = "";
                }

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult CreatePaymentInvoiceQueryXlsx(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquirePayment(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

            var details = items
                .OrderByDescending(i => i.PayoffDate)
                .ToArray()
                .Select(i => new
                {
                    發票號碼 = i.InvoiceItem.TrackCode + i.InvoiceItem.No,
                    分店 = i.PaymentTransaction.BranchStore.BranchName,
                    收款人 = i.UserProfile.FullName(),
                    學員 = i.TuitionInstallment != null
                        ? i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : i.ContractPayment != null
                            ? i.ContractPayment.CourseContract.CourseContractType.IsGroup == true
                                ? String.Join("/", i.ContractPayment.CourseContract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                                : i.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--",
                    收款日期 = String.Format("{0:yyyy/MM/dd}", i.PayoffDate),
                    發票日期 = String.Format("{0:yyyy/MM/dd}", i.InvoiceItem.InvoiceDate),
                    作廢或折讓日 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
                        ? String.Format("{0:yyyy/MM/dd}", i.InvoiceItem.InvoiceCancellation.CancelDate)
                        : i.InvoiceAllowance != null
                            ? String.Format("{0:yyyy/MM/dd}", i.InvoiceAllowance.AllowanceDate)
                            : "--",
                    收款品項 = String.Concat(((Naming.PaymentTransactionType)i.TransactionType).ToString(),
                            i.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.TransactionType == (int)Naming.PaymentTransactionType.飲品
                                ? String.Format("({0})", String.Join("、", i.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)))
                                : null),
                    收款金額 = i.PayoffAmount,
                    發票金額 = i.InvoiceItem.InvoiceBuyer.IsB2C() ? i.InvoiceItem.InvoiceAmountType.TotalAmount : i.InvoiceItem.InvoiceAmountType.SalesAmount,
                    收款未稅金額 = Math.Round((decimal)i.PayoffAmount / 1.05m),
                    作廢或折讓未稅金額 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
                        ? i.PayoffAmount
                        : i.InvoiceAllowance != null
                            ? i.InvoiceAllowance.TotalAmount
                            : null,
                    營業稅 = i.InvoiceItem.InvoiceBuyer.IsB2C() ? (decimal?)null : i.InvoiceItem.InvoiceAmountType.TaxAmount,
                    收款方式 = i.PaymentType,
                    發票類型 = i.InvoiceID.HasValue
                        ? i.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本"
                        : "--",
                    發票狀態 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment!=null
                        ? "已作廢"
                        : i.InvoiceAllowance != null
                            ? "已折讓"
                            : "已開立",
                    買受人統編 = i.InvoiceID.HasValue
                        ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                        : "--",
                    合約編號 = i.ContractPayment != null
                        ? i.ContractPayment.CourseContract.ContractNo()
                        : "--",
                    合約總金額 = i.ContractPayment != null
                        ? i.ContractPayment.CourseContract.TotalCost
                        : (int?)null,
                    備註 = i.VoidPayment != null
                        ? i.VoidPayment.Remark
                        : i.InvoiceAllowance != null
                            ? i.InvoiceAllowance.InvoiceAllowanceDetails.First().InvoiceAllowanceItem.Remark
                            : null,
                    狀態 = i.VoidPayment == null
                        ? String.Concat((Naming.CourseContractStatus)i.Status, i.PaymentAudit.AuditorID.HasValue ? "" : "(*)")
                        : String.Concat((Naming.VoidPaymentStatus)i.VoidPayment.Status, "(作廢)"),
                    //i.PaymentID,
                    //VoidID = i.VoidPayment != null ? i.VoidPayment.VoidID : (int?)null
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("PaymentDetails.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "收款資料明細";
                ds.Tables.Add(table);

                foreach (var r in table.Select("買受人統編 = '0000000000'"))
                {
                    r["買受人統編"] = "";
                }

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult GetPaymentQuery(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquirePayment(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

            var details = items.OrderByDescending(i => i.PayoffDate).ToArray()
                .Select(i => new
                {
                    //i.InvoiceItem.TrackCode,
                    //i.InvoiceItem.No,
                    //i.PaymentTransaction.BranchStore.BranchName,
                    發票號碼 = i.InvoiceItem.TrackCode + i.InvoiceItem.No,
                    分店 = i.PaymentTransaction.BranchStore.BranchName,
                    收款人 = i.UserProfile.FullName(),
                    學員 = i.TuitionInstallment != null
                        ? i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : i.ContractPayment != null
                            ? i.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--",
                    收款日期 = String.Format("{0:yyyy/MM/dd}", i.PayoffDate),
                    收款品項 = String.Concat(((Naming.PaymentTransactionType)i.TransactionType).ToString(),
                            i.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.TransactionType == (int)Naming.PaymentTransactionType.飲品
                                ? String.Format("({0})", String.Join("、", i.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)))
                                : null),
                    金額 =  i.PayoffAmount,
                    收款方式 = i.PaymentType,
                    發票類型 = i.InvoiceID.HasValue
                        ? i.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本"
                        : "--",
                    發票狀態 = i.VoidPayment == null
                        ? "已開立"
                        : i.VoidPayment.Status == (int)Naming.CourseContractStatus.已生效
                            ? i.InvoiceItem.InvoiceAllowance.Any()
                                ? "已折讓"
                                : "已作廢"
                            : "已開立",
                    買受人統編 = i.InvoiceID.HasValue
                        ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                        : "--",
                    合約編號 = i.ContractPayment != null
                        ? i.ContractPayment.CourseContract.ContractNo()
                        : null,
                    狀態 = String.Concat((Naming.CourseContractStatus)i.Status, i.PaymentAudit.AuditorID.HasValue ? "" : "(*)")
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "message/rfc822";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("收款資料明細.xml"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                var table = details.ToDataTable();
                table.TableName = "收款資料明細";
                ds.Tables.Add(table);
                ds.WriteXml(Response.OutputStream);
            }

            //using (DataSet ds = new DataSet())
            //{
            //    DataTable table = new DataTable("收款資料明細");
            //    ds.Tables.Add(table);
            //    table.Columns.Add("發票號碼");
            //    table.Columns.Add("分店");
            //    table.Columns.Add("收款人");
            //    table.Columns.Add("學員");
            //    table.Columns.Add("收款日期");
            //    table.Columns.Add("收款品項");
            //    table.Columns.Add("金額");
            //    table.Columns.Add("收款方式");
            //    table.Columns.Add("發票類型");
            //    table.Columns.Add("發票狀態");
            //    table.Columns.Add("買受人統編");
            //    table.Columns.Add("合約編號");
            //    table.Columns.Add("狀態");


            //    DataSource.GetDataSetResult(details, table);
            //    foreach (var r in table.Select("買受人統編 = '0000000000'"))
            //    {
            //        r["買受人統編"] = "";
            //    }

            //    using (var xls = ds.ConvertToExcel())
            //    {
            //        xls.SaveAs(Response.OutputStream);
            //    }
            //}

            return new EmptyResult();
        }


        public ActionResult InquirePaymentForAchievement(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquirePayment(viewModel);

            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;
            items = items.Where(p => p.VoidPayment == null);

            return View("~/Views/Payment/Module/PaymentAchievementList.ascx", items);
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentAchievement(PaymentViewModel viewModel)
        {
            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/EditPaymentAchievement.ascx", item);
        }

        public ActionResult LoadCoachAchievement(PaymentViewModel viewModel)
        {
            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/PaymentCoachAchievement.ascx", item);
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
        public ActionResult DeleteCoachAchievement(PaymentViewModel viewModel)
        {
            try
            {
                var item = models.DeleteAny<TuitionAchievement>(d => d.CoachID == viewModel.CoachID && d.InstallmentID == viewModel.PaymentID);
                if (item != null)
                {
                    return Json(new { result = true });
                }
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
            return Json(new { result = false,message = "資料錯誤!!" });
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult DeleteEnterprisePayment(PaymentViewModel viewModel)
        {
            try
            {
                var item = models.DeleteAny<Payment>(d => d.PaymentID == viewModel.PaymentID 
                    && d.EnterpriseCoursePayment.ContractID == viewModel.ContractID);
                if (item != null)
                {
                    return Json(new { result = true });
                }
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
            return Json(new { result = false, message = "資料錯誤!!" });
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
        public ActionResult CommitToApplyCoachAchievement(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.ShareAmount.HasValue || viewModel.ShareAmount <= 0)
            {
                ModelState.AddModelError("ShareAmount", "請輸入業績分潤金額");
            }

            if (!viewModel.CoachID.HasValue)
            {
                ModelState.AddModelError("CoachID", "請選擇體能顧問");
            }

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            try
            {
                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    return Json(new { result = false, message = "收款資料錯誤!!" });
                }

                if (item.TuitionAchievement.Where(t => t.CoachID != viewModel.CoachID).Sum(t => t.ShareAmount) + viewModel.ShareAmount > item.EffectiveAchievement())
                {
                    return Json(new { result = false, message = "所屬體能顧問業績總額大於實收業績金額!!" });
                }
                
                var achievement = item.TuitionAchievement.Where(t => t.CoachID == viewModel.CoachID).FirstOrDefault();

                if (achievement==null)
                {
                    achievement = new TuitionAchievement
                    {
                        CoachID = viewModel.CoachID.Value,
                        Payment = item
                    };
                    item.TuitionAchievement.Add(achievement);
                }

                achievement.ShareAmount = viewModel.ShareAmount;
                models.SubmitChanges();

                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }


        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
        public ActionResult ApplyPaymentAchievement(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/ApplyPaymentAchievement.ascx", item);
        }

    }
}