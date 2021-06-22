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
using WebHome.Helper.BusinessOperation;

namespace WebHome.Controllers.Base
{
    [Authorize]
    public class PaymentBaseController : SampleController<UserProfile>
    {

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
                    ModelState.AddModelError("SellerID", "請選擇收款場地");
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

    }
}