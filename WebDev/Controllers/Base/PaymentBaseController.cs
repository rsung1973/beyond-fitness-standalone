using System;
using System.Collections.Generic;
using System.Data;
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
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers.Base
{
    [Authorize]
    public class PaymentBaseController : SampleController<UserProfile>
    {
        public PaymentBaseController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        protected InvoiceItem checkInvoiceNo(PaymentViewModel viewModel)
        {
            if (!viewModel.PayoffAmount.HasValue || viewModel.PayoffAmount <= 0)
            {
                ModelState.AddModelError("PayoffAmount", "請輸入收款金額");
                return null;
            }

            String trackCode, no;
            viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
            if (viewModel.InvoiceType != Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
            {
                if (viewModel.InvoiceNo == null || !Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
                {
                    ModelState.AddModelError("InvoiceNo", "請輸入紙本發票號碼");
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
                        if (invoice.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            && invoice.InvoiceDate >= new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 2 * 2 + 1, 1))
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
                    ModelState.AddModelError("SellerID", "請選擇收款場地");
                    return null;
                }

                viewModel.SellerName = seller.CompanyName;
                viewModel.SellerReceiptNo = seller.ReceiptNo;

                InvoiceViewModelValidator validator = new InvoiceViewModelValidator(models, seller);
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

        protected void prepareInvoice(PaymentViewModel viewModel)
        {
            viewModel.SalesAmount = (int)Math.Round((decimal)viewModel.PayoffAmount / 1.05m);
            viewModel.TaxAmount = viewModel.PayoffAmount - viewModel.SalesAmount;
        }

        protected void preparePayment(PaymentViewModel viewModel, UserProfile profile, Payment item)
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
            viewModel.CarrierType = viewModel.CarrierType.GetEfficientString();
            viewModel.BuyerReceiptNo = viewModel.BuyerReceiptNo.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.BuyerReceiptNo != null)
                {
                    ModelState.AddModelError("CarrierId1", "買受人統編與載具請擇一輸入");
                }
                else if (viewModel.CarrierType == null)
                {
                    ModelState.AddModelError("CarrierType", "請選擇發票載具類型");
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

            if (!viewModel.PayerID.HasValue)
            {
                ModelState.AddModelError("PayerName", "請輸入買受人（學生）");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(WebApp.Properties["ReportInputError"]);
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
                        {
                        },
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
                item.PaymentTransaction.PayerID = viewModel.PayerID;

                int idx = 0;
                item.PaymentTransaction.PaymentOrder.AddRange(viewModel.ProductItemID.Select(d =>
                    new PaymentOrder
                    {
                        ProductID = d.Value,
                        ProductCount = viewModel.Piece[idx++].Value
                    }));

                preparePayment(viewModel, profile, item);

                models.SubmitChanges();

                if (viewModel.PayerID.HasValue)
                {
                    if (invoice.InvoiceCarrier != null && viewModel.MyCarrier == true)
                    {
                        var payer = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.PayerID).FirstOrDefault();
                        if (payer != null)
                        {
                            payer.UserProfileExtension.CarrierType = invoice.InvoiceCarrier.CarrierType;
                            payer.UserProfileExtension.CarrierNo = invoice.InvoiceCarrier.CarrierNo;
                            models.SubmitChanges();
                        }
                    }
                }

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentBaseController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> CommitPaymentForCustomAsync(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (!viewModel.SellerID.HasValue)
            {
                ModelState.AddModelError("SellerID", "請選擇收款場地");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式");
            }

            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            viewModel.CarrierType = viewModel.CarrierType.GetEfficientString();
            viewModel.BuyerReceiptNo = viewModel.BuyerReceiptNo.GetEfficientString();
            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.BuyerReceiptNo != null)
                {
                    ModelState.AddModelError("CarrierId1", "買受人統編與載具請擇一輸入");
                }
                else if (viewModel.CarrierType == null)
                {
                    ModelState.AddModelError("CarrierType", "請選擇發票載具類型");
                }
            }

            viewModel.Brief = viewModel.Brief?
                .Select(b => b.GetEfficientString())
                .Where(b => b != null)
                .ToArray();
            if (!(viewModel.Brief?.Length > 0))
            {
                ModelState.AddModelError("Brief", "請輸入發票明細，例：課程顧問費用");
            }

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式!!");
            }

            if (!(viewModel.PayoffAmount > 0))
            {
                ModelState.AddModelError("PayoffAmount", "請輸入收款金額!!");
            }

            if (profile.IsSysAdmin() || profile.IsAssistant())
            {

            }
            else
            {
                if (!viewModel.PayerID.HasValue)
                {
                    ModelState.AddModelError("PayerName", "請輸入買受人（學生）");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            viewModel.ItemNo = new string[] { "01" };
            viewModel.CostAmount = new int?[] { viewModel.PayoffAmount };
            viewModel.UnitCost = new int?[] { viewModel.PayoffAmount };
            viewModel.Piece = new int?[] { 1 };
            viewModel.ItemRemark = new string[] { "" };
            viewModel.InvoiceType = Naming.InvoiceTypeDefinition.一般稅額計算之電子發票;
            viewModel.TransactionType = (int)Naming.PaymentTransactionType.各項費用;

            var invoice = checkInvoiceNo(viewModel);

            //if (!viewModel.InvoiceType.HasValue)
            //{
            //    ModelState.AddModelError("InvoiceType", "請選擇發票類型");
            //}

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(WebApp.Properties["ReportInputError"]);
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
                        {
                        },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;
                }

                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;
                item.PaymentTransaction.PayerID = viewModel.PayerID;

                preparePayment(viewModel, profile, item);
                //item.Remark = $"{viewModel.Remark} {viewModel.Brief[0]}";
                models.SubmitChanges();

                if (viewModel.PayerID.HasValue)
                {
                    if (invoice.InvoiceCarrier != null && viewModel.MyCarrier == true)
                    {
                        var payer = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.PayerID).FirstOrDefault();
                        if (payer != null)
                        {
                            payer.UserProfileExtension.CarrierType = invoice.InvoiceCarrier.CarrierType;
                            payer.UserProfileExtension.CarrierNo = invoice.InvoiceCarrier.CarrierNo;
                            models.SubmitChanges();
                        }
                    }
                }

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Content(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID }.JsonStringify(), "application/json");
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PaymentBaseController>()
                    .LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }


    }
}