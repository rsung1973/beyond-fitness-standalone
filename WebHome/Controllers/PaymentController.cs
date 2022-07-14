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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Newtonsoft.Json;


using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using WebHome.Properties;
using WebHome.Helper.BusinessOperation;
using WebHome.Controllers.Base;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

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
    public class PaymentController : PaymentBaseController
    {
        public PaymentController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor,(int)Naming.RoleID.Manager,(int)Naming.RoleID.ViceManager})]
        public ActionResult EditPayment(PaymentViewModel viewModel)
        {
            switch ((Naming.PaymentTransactionType?)viewModel.TransactionType)
            {
                case Naming.PaymentTransactionType.自主訓練:
                    return EditPaymentForPISession(viewModel);
                case Naming.PaymentTransactionType.運動商品:
                case Naming.PaymentTransactionType.食飲品:
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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForPISession(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForPISession.ascx";

            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForShopping(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForShopping.ascx";

            return result;
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public ActionResult EditPaymentForContract(PaymentViewModel viewModel)
        {
            var item = viewModel.EditPaymentForContract(this.HttpContext);
            return View("~/Views/Payment/Module/EditPaymentForContract.ascx", item);
        }

        public async Task<ActionResult> CommitPaymentForContractAsync(PaymentViewModel viewModel, bool? alertError)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            CourseContract contract = null;
            if(viewModel.ContractID.HasValue)
            {
                contract = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            }
            if (contract == null)
            {
                viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
                if (viewModel.ContractNo == null)
                {
                    ModelState.AddModelError("ContractNo", "請輸入合約編號!!");
                    if (alertError != false)
                        return View("~/Views/Shared/AlertMessage.ascx", model: "請輸入合約編號");
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
                        if (alertError != false)
                            return View("~/Views/Shared/AlertMessage.ascx", model: "合約編號錯誤");
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
            }

            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
                }
            }

            if(!viewModel.InvoiceType.HasValue)
            {
                ModelState.AddModelError("InvoiceType", "請選擇發票類型");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇發票類型");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請輸入收款日期");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請輸入收款日期");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇收款方式");
            }

            if (viewModel.CustomBrief == true)
            {
                if (viewModel.Brief == null || viewModel.Brief.Length == 0 || (viewModel.Brief[0] = viewModel.Brief[0].GetEfficientString()) == null)
                {
                    //ModelState.AddModelError("Brief", "請輸入發票品項");
                    if (alertError != false)
                        return View("~/Views/Shared/AlertMessage.ascx", model: "請輸入發票品項");
                }

                viewModel.ItemNo = new string[] { "01" };
                viewModel.Brief = new string[] { viewModel.Brief[0]/*"顧問費用"*/ };
                viewModel.CostAmount = new int?[] { viewModel.PayoffAmount };
                viewModel.UnitCost = new int?[] { viewModel.PayoffAmount };
                viewModel.Piece = new int?[] { 1 };
                viewModel.ItemRemark = new string[] { null };
            }
            else 
            {
                if (!viewModel.CustomBrief.HasValue)
                {
                    ModelState.AddModelError("CustomBrief", "請選擇發票品項是否更改");
                }

                viewModel.ItemNo = new string[] { "01", "02" };
                viewModel.Brief = new string[] { "專業顧問建置與諮詢費", "教練課程費" };
                viewModel.CostAmount = new int?[] { (viewModel.PayoffAmount * 8 + 5) / 10, (viewModel.PayoffAmount * 2 + 5) / 10 };
                viewModel.UnitCost = new int?[] { (viewModel.PayoffAmount * 8 + 5) / 10, (viewModel.PayoffAmount * 2 + 5) / 10 };
                viewModel.Piece = new int?[] { 1, 1 };
                viewModel.ItemRemark = new string[] { null, null };
            }

            InvoiceItem invoice = null;
            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇收款場地");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇收款場地");
            }
            else
            {
                if (contract != null)
                {
                    if (viewModel.SellerID != contract.CourseContractExtension.BranchID)
                    {
                        return View("~/Views/Shared/AlertMessage.ascx", model: "簽約場地與收款場地不符");
                        //ModelState.AddModelError("SellerID", "簽約場地與收款場地不符");
                    }
                }
                invoice = checkInvoiceNo(viewModel);
            }

            if (contract!=null && contract.TotalPaidAmount() + viewModel.PayoffAmount > contract.TotalCost)
            {
                ModelState.AddModelError("PayoffAmount", "含本次收款金額已大於總收費金額!!");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "含本次收款金額已大於總收費金額");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                if (alertError != false)
                {
                    return View("~/Views/Shared/AlertMessage.ascx", model: ModelState.ErrorMessage());
                }
                else
                {
                    return View(Startup.Properties["ReportInputError"]);
                }
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

                if (invoice.InvoiceCarrier != null && viewModel.MyCarrier == true)
                {
                    item.ContractPayment.CourseContract.ContractOwner.UserProfileExtension.CarrierType = invoice.InvoiceCarrier.CarrierType;
                    item.ContractPayment.CourseContract.ContractOwner.UserProfileExtension.CarrierNo = invoice.InvoiceCarrier.CarrierNo;
                    models.SubmitChanges();
                }

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID, keyID = contract.ContractID.EncryptKey() }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager,(int)Naming.RoleID.Officer })]
        public ActionResult EditPaymentForEnterprise(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPaymentForContract(viewModel);
            result.ViewName = "~/Views/Payment/Module/EditPaymentForEnterprise.ascx";
            return result;
        }

        public async Task<ActionResult> CommitPaymentForEnterpriseAsync(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            EnterpriseCourseContract contract = models.GetTable<EnterpriseCourseContract>().Where(t => t.ContractID == viewModel.ContractID).FirstOrDefault();
            if (contract == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇分店!!");
            }

            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
                }
            }

            var invoice = checkInvoiceNo(viewModel);

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

                return Content(new { result = true, item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
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

            InvoiceViewModelValidator validator = new InvoiceViewModelValidator(models, seller);
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

        public async Task<ActionResult> CommitPaymentForPISession(PaymentViewModel viewModel, bool? alertError)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            if (!viewModel.RegisterID.HasValue || lesson == null)
            {
                ModelState.AddModelError("RegisterID", "請選擇收款自主訓練!!");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇收款自主訓練");
            }
            else
            {
                viewModel.SellerID = lesson.LessonTime.First().BranchID.Value;
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇收款日期");
            }

            viewModel.ItemNo = new string[] { "01" };
            viewModel.Brief = new string[] { "自主訓練費用" };
            viewModel.CostAmount = new int?[] { viewModel.PayoffAmount };
            viewModel.UnitCost = new int?[] { viewModel.PayoffAmount };
            viewModel.Piece = new int?[] { 1 };
            viewModel.ItemRemark = new string[] { null };
            viewModel.InvoiceType = Naming.InvoiceTypeDefinition.一般稅額計算之電子發票;
            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();

            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
                }
            }

            var invoice = checkInvoiceNo(viewModel);

            //if (!viewModel.SellerID.HasValue)
            //{
            //    ModelState.AddModelError("SellerID", "請選擇分店!!");
            //}

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式!!");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇收款方式");
            }

            if (!viewModel.InvoiceType.HasValue)
            {
                ModelState.AddModelError("InvoiceType", "請選擇發票類型");
                if (alertError != false)
                    return View("~/Views/Shared/AlertMessage.ascx", model: "請選擇發票類型");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Startup.Properties["ReportInputError"]);
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
                        ShareAmount = viewModel.PayoffAmount,
                        CoachWorkPlace = lesson.ServingCoach.WorkBranchID()
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
                models.AttendLesson(lesson.LessonTime.First(), profile);

                if (invoice.InvoiceCarrier != null && viewModel.MyCarrier == true)
                {
                    lesson.UserProfile.UserProfileExtension.CarrierType = invoice.InvoiceCarrier.CarrierType;
                    lesson.UserProfile.UserProfileExtension.CarrierNo = invoice.InvoiceCarrier.CarrierNo;
                    models.SubmitChanges();
                }

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, InvoiceID = item.InvoiceID, InvoiceType = item.InvoiceItem.InvoiceType, PaymentID = item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> TestCommitPaymentForShopping(PaymentViewModel viewModel, int? times)
        {
            ActionResult result = new EmptyResult();
            await Task.Run(async () =>
            {
                for (int i = 0; i < (times ?? 1000); i++)
                {
                    result = await CommitPaymentForShopping(viewModel);
                }
            });
            return result;
        }

        public async Task<ActionResult> CommitPaymentForShopping(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

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
                    viewModel.ItemRemark = new string[] { null, null };
                }
                else
                {
                    viewModel.ItemNo = new string[] { "01" };
                    viewModel.Brief = new string[] { product.ProductName };
                    viewModel.CostAmount = new int?[] { product.UnitPrice * viewModel.ProductCount };
                    viewModel.UnitCost = new int?[] { product.UnitPrice };
                    viewModel.Piece = new int?[] { viewModel.ProductCount };
                    viewModel.ItemRemark = new string[] { null };
                }
            }

            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
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

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> CommitPaymentForShopping2019(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.ProductItemID == null || viewModel.ProductItemID.Length == 0)
            {
                ModelState.AddModelError("ProductItems", "請選擇品項");
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("errorMessage", "請選擇收款日期");
            }
            
            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
                }
            }

            var invoice = checkInvoiceNo(viewModel);

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇收款場地");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Startup.Properties["ReportInputError"]);
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
                int idx = 0;
                item.PaymentTransaction.PaymentOrder.AddRange(viewModel.ProductItemID.Select(d =>
                    new PaymentOrder
                    {
                        ProductID = d.Value,
                        ProductCount = viewModel.Piece[idx++].Value
                    }));

                preparePayment(viewModel, profile, item);

                models.SubmitChanges();

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> ListUnpaidPISession(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            var items = viewModel.GetUnpaidPISession(models);

            return View("~/Views/Payment/Module/UnpaidPISession.ascx", items);
        }

        public async Task<ActionResult> PaymentAuditSummary()
        {
            var profile = await HttpContext.GetUserAsync();
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
            IQueryable<CourseContract> items = models.PromptAccountingContract();

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


        public async Task<ActionResult> AuditPayment(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

            IQueryable<Payment> items = models.GetPaymentToAuditByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;

            return View("~/Views/Payment/Module/AuditPayment.ascx", items);
        }

        public async Task<ActionResult> ApproveToVoidPayment(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

            IQueryable<Payment> items = models.GetVoidPaymentToApproveByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewAction = "待審核";

            return View("~/Views/Payment/Module/ApproveToVoidPayment.ascx", items);
        }

        public async Task<ActionResult> EditToVoidPayment(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

            IQueryable<Payment> items = models.GetVoidPaymentToEditByAgent(profile)
                .Select(a => a.Payment)
                .Where(p => p.TransactionType == viewModel.TransactionType);

            ViewBag.ViewModel = viewModel;
            ViewBag.ViewAction = "草稿";

            return View("~/Views/Payment/Module/ApproveToVoidPayment.ascx", items);
        }



        public async Task<ActionResult> ApproveToVoidPaymentView(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

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

        public async Task<ActionResult> EditToVoidPaymentView(PaymentViewModel viewModel)
        {
            ViewResult result = (ViewResult)await ApproveToVoidPaymentView(viewModel);
            result.ViewName = "~/Views/Payment/Module/VoidPaymentEditingView.ascx";
            return result;
        }

        public async Task<ActionResult> ExecuteVoidPaymentStatus(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();

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
                    ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                    return Json(new { result = false, message = ex.Message });
                }
            }

            return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
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
            else if (item.Payment.TransactionType == (int)Naming.PaymentTransactionType.終止手續費)
            {
                var revision = item.Payment.PaymentTransaction.PaymentContractTermination?.CourseContractTermination.CourseContractRevision;
                if (revision != null)
                {
                    if (!revision.CourseContract.CourseContractAction.Any(c => c.ActionID == (int)CourseContractAction.ActionType.合約終止手續費))
                    {
                        revision.CourseContract.CourseContractAction
                            .Add(
                                new CourseContractAction
                                {
                                    ActionID = (int)CourseContractAction.ActionType.合約終止手續費
                                });
                        models.SubmitChanges();
                    }
                }
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

        public async Task<ActionResult> CancelVoidPaymentAsync(PaymentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
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
                    ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                    return Json(new { result = false, message = ex.Message });
                }
            }

            return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
        }


        public ActionResult VoidPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/VoidPayment.ascx");
        }

        public async Task<ActionResult> CommitToVoidPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.VoidID == null || viewModel.VoidID.Length == 0)
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.VoidID = new int?[] { viewModel.DecryptKeyValue() };
                }
            }

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
                    if (item!=null && item.VoidPayment == null)
                    {
                        voidPaymentForInvoice(item);

                        item.VoidPayment = new VoidPayment
                        {
                            HandlerID = profile.UID,
                            Remark = viewModel.Remark,
                            Status = (int)Naming.CourseContractStatus.待審核,
                            VoidDate = DateTime.Now
                        };

                        ///刪除當月已分潤
                        /// 
                        DateTime startDate = DateTime.Today.FirstDayOfMonth();
                        if (item.PayoffDate >= startDate && item.PayoffDate < startDate.AddMonths(1))
                        {
                            models.DeleteAllOnSubmit<TuitionAchievement>(t => t.InstallmentID == item.PaymentID);
                        }

                        if (viewModel.Status.HasValue)
                        {
                            item.VoidPayment.Status = viewModel.Status;
                        }
                        else if (profile.IsManager())
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
                            v.Payment.PaymentAudit.AuditorID = Startup.Properties.GetValue<int>("DefaultCoach");
                            v.Payment.PaymentAudit.AuditDate = DateTime.Now;
                            models.SubmitChanges();
                        }
                    }

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
                else
                    return Json(new { result = false, message = "作廢收款資料錯誤!!" });

            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
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
            PaymentAllowanceValidator validator = new PaymentAllowanceValidator(models);
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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public async Task<ActionResult> CommitToAuditPayment(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

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
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
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

        public async Task<ActionResult> InquirePaymentAsync(PaymentQueryViewModel viewModel)
        {
            IQueryable<Payment> items = await viewModel.InquirePaymentByCustomAsync(this);
            return View("~/Views/Payment/Module/PaymentInvoiceList.ascx", items);
        }

        class _PaymentItem
        {
            public int Direction { get; set; }
            public Payment Item { get; set; }
        }

        public async Task<ActionResult> CreatePaymentQueryXlsxAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquirePaymentAsync(viewModel);
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
                            i.Item.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.Item.TransactionType == (int)Naming.PaymentTransactionType.食飲品
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

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "收款資料明細";
                ds.Tables.Add(table);

                foreach (var r in table.Select("買受人統編 = '0000000000'"))
                {
                    r["買受人統編"] = "";
                }

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("PaymentDetails"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

        public async Task<ActionResult> CreatePaymentInvoiceQueryXlsxAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquirePaymentAsync(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

            if (items.Count() == 0)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }

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
                            i.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.TransactionType == (int)Naming.PaymentTransactionType.食飲品
                                ? String.Format("({0})", String.Join("、", i.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)))
                                : null),
                    收款金額 = i.PayoffAmount,
                    發票金額 = i.InvoiceItem.InvoiceBuyer.IsB2C() ? i.InvoiceItem.InvoiceAmountType.TotalAmount : i.InvoiceItem.InvoiceAmountType.SalesAmount,
                    收款未稅金額 = Math.Round((decimal)i.PayoffAmount / 1.05m),
                    營業稅 = i.PayoffAmount - Math.Round((decimal)i.PayoffAmount / 1.05m),
                    作廢金額 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
                        ? i.PayoffAmount
                        : null,
                    折讓金額 = i.InvoiceAllowance?.TotalAmount,
                    折讓稅額 = i.InvoiceAllowance?.TaxAmount,
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

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                if (viewModel.PayoffDateFrom.HasValue)
                {
                    table.TableName = $"收款資料明細{viewModel.PayoffDateFrom:yyyy-MM-dd}~{viewModel.PayoffDateTo:yyyy-MM-dd}";
                }
                else
                {
                    table.TableName = "收款資料明細";
                }
                ds.Tables.Add(table);

                foreach (var r in table.Select("買受人統編 = '0000000000'"))
                {
                    r["買受人統編"] = "";
                }

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("PaymentDetails"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

        public async Task<ActionResult> GetPaymentQueryAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquirePaymentAsync(viewModel);
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
                            i.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.TransactionType == (int)Naming.PaymentTransactionType.食飲品
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

            using (DataSet ds = new DataSet())
            {
                var table = details.ToDataTable();
                table.TableName = "收款資料明細";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("收款資料明細"), DateTime.Now), viewModel.FileDownloadToken);
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


        public async Task<ActionResult> InquirePaymentForAchievementAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquirePaymentAsync(viewModel);

            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;
            //items = items.FilterByEffective();

            return View("~/Views/Payment/Module/PaymentAchievementList.ascx", items);
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
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


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
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
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
            }
            return Json(new { result = false,message = "資料錯誤!!" });
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
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
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
            }
            return Json(new { result = false, message = "資料錯誤!!" });
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
        public ActionResult CommitToApplyCoachAchievement(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

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
                return View(Startup.Properties["ReportInputError"]);
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

                if (achievement == null)
                {
                    achievement = new TuitionAchievement
                    {
                        CoachID = viewModel.CoachID.Value,
                        Payment = item
                    };
                    item.TuitionAchievement.Add(achievement);
                }

                achievement.ShareAmount = viewModel.ShareAmount;
                achievement.CommitShare = DateTime.Now;
                achievement.CoachWorkPlace = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).First().WorkBranchID();
                models.SubmitChanges();

                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor, (int)Naming.RoleID.Manager })]
        public ActionResult ApplyPaymentAchievement(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Payment/Module/ApplyPaymentAchievement.ascx", item);
        }

        public async Task<ActionResult> CreateMonthlyPaymentReportXlsxAsync(PaymentQueryViewModel viewModel)
        {
            //if(viewModel.SettlementDate.HasValue)
            //{
            //    viewModel.SettlementDate = viewModel.SettlementDate.Value.FirstDayOfMonth();
            //}
            //else
            //{
            //    viewModel.SettlementDate = DateTime.Today.FirstDayOfMonth();
            //}
            //viewModel.PayoffDateTo = viewModel.SettlementDate.Value.AddMonths(1);

            if (!viewModel.PayoffDateFrom.HasValue)
            {
                ModelState.AddModelError("PayoffDateFrom", "請選擇起始日期");
            }
            if (!viewModel.PayoffDateTo.HasValue)
            {
                ModelState.AddModelError("PayoffDateTo", "請選擇結束日期");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }
            viewModel.PayoffDateTo = viewModel.PayoffDateTo.Value.AddDays(1);
            viewModel.BypassCondition = true;

            IQueryable<Payment> items = models.GetTable<Payment>()
                .Where(p => p.ContractPayment != null);

            //收款(不含終止沖銷)
            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .Where(p => p.TransactionType != (int)Naming.PaymentTransactionType.合約終止沖銷 || p.AdjustmentAmount.HasValue)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = i.ContractPayment.CourseContract.ContractLearner("/"),
                        //合約編號 = i.ContractPayment.CourseContract.ContractNo(),
                        信託 = i.ContractPayment.CourseContract.Entrusted == true
                                  ? "是"
                                  : i.ContractPayment.CourseContract.Entrusted == false
                                      ? "否"
                                      : "",
                        摘要 = i.TransactionType==(int)Naming.PaymentTransactionType.合約終止沖銷
                                ? i.AdjustmentAmount>0
                                    ? $"(沖:終止轉收)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"    
                                    //(沖:終止轉收)課程顧問費用-CPA201801290752-00-陳筱鈴
                                    : $"(沖:終止減收)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                : i.TransactionType==(int)Naming.PaymentTransactionType.體能顧問費 
                                    ? $"課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}({i.PaymentType})"
                                    //(沖:轉讓)課程顧問費用-CPA201706277998-00-陳潔
                                    : i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? $"{i.Remark}-課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                        : $"(沖:{i.Remark})-課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}",
                        退款金額_含稅 =  i.TransactionType==(int)Naming.PaymentTransactionType.合約終止沖銷
                                            ? i.AdjustmentAmount
                                            : !(i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                                || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                                || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                                                ? -i.PayoffAmount
                                                : null,
                        收款金額_含稅 = i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? i.PayoffAmount
                                        : null,
                        借方金額 = i.TransactionType==(int)Naming.PaymentTransactionType.合約終止沖銷
                                    ? (int?)Math.Round(i.AdjustmentAmount.Value / 1.05m, MidpointRounding.AwayFromZero)
                                    : !(i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                                        ? (int?)Math.Round(-i.PayoffAmount.Value / 1.05m,MidpointRounding.AwayFromZero)
                                        : null,
                        貸方金額 = i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero)
                                        : null,
                    });

            //作廢或折讓(含終止)
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
                                //姓名 = i.ContractPayment.CourseContract.ContractLearner("/"),
                                //合約編號 = i.ContractPayment.CourseContract.ContractNo(),
                                信託 = i.ContractPayment.CourseContract.Entrusted == true
                                          ? "是"
                                          : i.ContractPayment.CourseContract.Entrusted == false
                                              ? "否"
                                              : "",
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : i.VoidPayment.Remark == "終止退款"
                                            ? $"(沖:{i.PayoffDate:yyyyMMdd}-終止退款)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                            : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ))
                                .OrderBy(d => d.日期).ThenByDescending(d => d.收款金額_含稅)
                                    .ThenByDescending(d => d.退款金額_含稅);

            details = details.Concat(viewModel.CreateMonthlyPaymentReportForPISession(models))
                        .Concat(viewModel.CreateMonthlyPaymentReportForSale(models))
                        .Concat(viewModel.CreateMonthlyPaymentReportForFeeCharge(models))
                        .OrderBy(d => d.日期)
                        .ThenBy(d => d.發票號碼);


            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = $"{viewModel.PayoffDateFrom:yyyyMMdd}~{viewModel.PayoffDateTo.Value.AddDays(-1):yyyyMMdd}";
                table.Columns[5].ColumnName = "退款金額(含稅)";
                table.Columns[6].ColumnName = "收款金額(含稅)";
                ds.Tables.Add(table);

                List<String> days = new List<string>();
                for (int i = 0; i < (viewModel.PayoffDateTo - viewModel.PayoffDateFrom).Value.TotalDays; i++)
                {
                    days.Add($"{viewModel.PayoffDateFrom.Value.AddDays(i):yyyyMMdd}");
                }

                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var data = details.BuildDailyPaymentReportForBranch(branch).ToList();
                    foreach (var emptyItem in days.Except(data.Select(d => d.日期)))
                    {
                        data.Add(new DailyBranchReportItem
                        {
                            日期 = emptyItem
                        });
                    }
                    table = data.OrderBy(d => d.日期).ToDataTable();
                    table.TableName = branch.BranchName;
                    ds.Tables.Add(table);
                }

                //if (!details.Any(d => d.摘要.StartsWith("課程顧問費用") && d.信託 == ""))
                {
                    table = details.Where(d => d.信託 == "是").BuildContractPaymentReport(models);
                    table.TableName = "課程顧問費用彙總-信託";
                    ds.Tables.Add(table);

                    table = details.Where(d => d.信託 == "否").BuildContractPaymentReport(models);
                    table.TableName = "課程顧問費用彙總-非信託";
                    ds.Tables.Add(table);
                }

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("DiaryLedger"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

        public async Task<ActionResult> CreateMonthlyPaymentReportXlsx2021Async(PaymentQueryViewModel viewModel)
        {
            //if(viewModel.SettlementDate.HasValue)
            //{
            //    viewModel.SettlementDate = viewModel.SettlementDate.Value.FirstDayOfMonth();
            //}
            //else
            //{
            //    viewModel.SettlementDate = DateTime.Today.FirstDayOfMonth();
            //}
            //viewModel.PayoffDateTo = viewModel.SettlementDate.Value.AddMonths(1);

            if (!viewModel.PayoffDateFrom.HasValue)
            {
                ModelState.AddModelError("PayoffDateFrom", "請選擇起始日期");
            }
            if (!viewModel.PayoffDateTo.HasValue)
            {
                ModelState.AddModelError("PayoffDateTo", "請選擇結束日期");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }
            viewModel.PayoffDateTo = viewModel.PayoffDateTo.Value.AddDays(1);
            viewModel.BypassCondition = true;

            IQueryable<Payment> items = models.GetTable<Payment>()
                .Where(p => p.ContractPayment != null);

            //收款(不含終止沖銷)
            IEnumerable<PaymentMonthlyReportItem> details = items
                .Where(p => p.PayoffDate >= viewModel.PayoffDateFrom && p.PayoffDate < viewModel.PayoffDateTo)
                .Where(p => p.TransactionType != (int)Naming.PaymentTransactionType.合約終止沖銷 || p.AdjustmentAmount.HasValue)
                .ToArray()
                    .Select(i => new PaymentMonthlyReportItem
                    {
                        日期 = $"{i.PayoffDate:yyyyMMdd}",
                        發票號碼 = i.InvoiceID.HasValue ? i.InvoiceItem.TrackCode + i.InvoiceItem.No : null,
                        分店 = i.PaymentTransaction.BranchStore.BranchName,
                        買受人統編 = i.InvoiceID.HasValue
                                  ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
                                  : "--",
                        //姓名 = i.ContractPayment.CourseContract.ContractLearner("/"),
                        //合約編號 = i.ContractPayment.CourseContract.ContractNo(),
                        信託 = i.ContractPayment.CourseContract.Entrusted == true
                                  ? "是"
                                  : i.ContractPayment.CourseContract.Entrusted == false
                                      ? "否"
                                      : "",
                        摘要 = i.TransactionType == (int)Naming.PaymentTransactionType.合約終止沖銷
                                ? i.AdjustmentAmount > 0
                                    ? $"(沖:終止轉收)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                    //(沖:終止轉收)課程顧問費用-CPA201801290752-00-陳筱鈴
                                    : $"(沖:終止減收)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                : i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                    ? $"課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}({i.PaymentType})"
                                    //(沖:轉讓)課程顧問費用-CPA201706277998-00-陳潔
                                    : i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? $"{i.Remark}-課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                        : $"(沖:{i.Remark})-課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}",
                        退款金額_含稅 = i.TransactionType == (int)Naming.PaymentTransactionType.合約終止沖銷
                                            ? i.AdjustmentAmount
                                            : !(i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                                || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                                || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                                                ? -i.PayoffAmount
                                                : null,
                        收款金額_含稅 = i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? i.PayoffAmount
                                        : null,
                        借方金額 = i.TransactionType == (int)Naming.PaymentTransactionType.合約終止沖銷
                                    ? (int?)Math.Round(i.AdjustmentAmount.Value / 1.05m, MidpointRounding.AwayFromZero)
                                    : !(i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                                        ? (int?)Math.Round(-i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero)
                                        : null,
                        貸方金額 = i.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                                            || i.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額
                                        ? (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero)
                                        : null,
                    });

            //作廢或折讓(含終止)
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
                                //姓名 = i.ContractPayment.CourseContract.ContractLearner("/"),
                                //合約編號 = i.ContractPayment.CourseContract.ContractNo(),
                                信託 = i.ContractPayment.CourseContract.Entrusted == true
                                          ? "是"
                                          : i.ContractPayment.CourseContract.Entrusted == false
                                              ? "否"
                                              : "",
                                摘要 = i.InvoiceItem.InvoiceCancellation != null
                                        ? $"(沖:{i.PayoffDate:yyyyMMdd}-作廢)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                        //(沖:20190104-作廢)課程顧問費用-CFA201810091870-00-林妍君
                                        : i.VoidPayment.Remark == "終止退款"
                                            ? $"(沖:{i.PayoffDate:yyyyMMdd}-終止退款)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}"
                                            : $"(沖:{i.PayoffDate:yyyyMMdd}-折讓)課程顧問費用-{i.ContractPayment.CourseContract.ContractNo()}-{i.ContractPayment.CourseContract.ContractLearnerName("/")}",
                                退款金額_含稅 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount + i.InvoiceAllowance.TaxAmount)
                                                : i.PayoffAmount,
                                收款金額_含稅 = null,
                                借方金額 = i.AllowanceID.HasValue
                                                ? (int?)(i.InvoiceAllowance.TotalAmount)
                                                : (int?)Math.Round(i.PayoffAmount.Value / 1.05m, MidpointRounding.AwayFromZero),
                                貸方金額 = null,
                            }
                                ))
                                .OrderBy(d => d.日期).ThenByDescending(d => d.收款金額_含稅)
                                    .ThenByDescending(d => d.退款金額_含稅);

            details = details.Concat(viewModel.CreateMonthlyPaymentReportForPISession(models))
                        .Concat(viewModel.CreateMonthlyPaymentReportForSale(models))
                        .Concat(viewModel.CreateMonthlyPaymentReportForFeeCharge(models))
                        .OrderBy(d => d.日期)
                        .ThenBy(d => d.發票號碼);

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.Columns.RemoveAt(9);
                table.TableName = $"{viewModel.PayoffDateFrom:yyyyMMdd}~{viewModel.PayoffDateTo.Value.AddDays(-1):yyyyMMdd}";
                table.Columns[5].ColumnName = "退款金額(含稅)";
                table.Columns[6].ColumnName = "收款金額(含稅)";
                ds.Tables.Add(table);

                List<String> days = new List<string>();
                for (int i = 0; i < (viewModel.PayoffDateTo - viewModel.PayoffDateFrom).Value.TotalDays; i++)
                {
                    days.Add($"{viewModel.PayoffDateFrom.Value.AddDays(i):yyyyMMdd}");
                }

                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var data = details.BuildDailyPaymentReportForBranch(branch).ToList();
                    foreach (var emptyItem in days.Except(data.Select(d => d.日期)))
                    {
                        data.Add(new DailyBranchReportItem
                        {
                            日期 = emptyItem
                        });
                    }
                    table = data.OrderBy(d => d.日期).ToDataTable();
                    table.TableName = branch.BranchName;
                    ds.Tables.Add(table);
                }

                table = details.BuildContractPaymentReport(models);
                table.TableName = "課程顧問費用彙總";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("DiaryLedger"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

    }
}