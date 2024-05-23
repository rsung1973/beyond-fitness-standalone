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
using Microsoft.AspNetCore.Mvc;
using CommonLib.DataAccess;
//using MessagingToolkit.QRCode.Codec;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;


namespace WebHome.Helper
{
    public static class B2CExtensionMethods
    {
        public static WebHome.Models.MIG3_1.C0401.Invoice CreateC0401(this InvoiceItem item)
        {
            var result = new WebHome.Models.MIG3_1.C0401.Invoice
            {
                Main = new WebHome.Models.MIG3_1.C0401.Main
                {
                    Buyer = new WebHome.Models.MIG3_1.C0401.MainBuyer
                    {
                        Address = item.InvoiceBuyer.Address.GetEfficientStringMaxSize(0, 100).InsteadOfNullOrEmpty(""),
                        CustomerNumber = item.InvoiceBuyer.CustomerNumber.GetEfficientStringMaxSize(0, 20).InsteadOfNullOrEmpty(""),
                        EmailAddress = item.InvoiceBuyer.EMail.GetEfficientStringMaxSize(0, 80).InsteadOfNullOrEmpty(""),
                        FacsimileNumber = item.InvoiceBuyer.Fax.GetEfficientStringMaxSize(0, 26).InsteadOfNullOrEmpty(""),
                        Identifier = item.InvoiceBuyer.ReceiptNo,
                        Name = item.InvoiceBuyer.IsB2C()
                            ? Encoding.GetEncoding(950).GetBytes(item.InvoiceBuyer.Name.InsteadOfNullOrEmpty("")).Length == 4
                                ? item.InvoiceBuyer.Name : ValidityAgent.GenerateRandomCode(4)
                            : String.IsNullOrEmpty(item.InvoiceBuyer.Name)
                                ? item.InvoiceBuyer.ReceiptNo : item.InvoiceBuyer.Name,
                        PersonInCharge = item.InvoiceBuyer.PersonInCharge.GetEfficientStringMaxSize(0, 30).InsteadOfNullOrEmpty(""),
                        RoleRemark = item.InvoiceBuyer.RoleRemark.GetEfficientStringMaxSize(0, 40).InsteadOfNullOrEmpty(""),
                        TelephoneNumber = item.InvoiceBuyer.Phone.GetEfficientStringMaxSize(0, 26).InsteadOfNullOrEmpty("")
                    },
                    BuyerRemark = String.IsNullOrEmpty(item.BuyerRemark) ? WebHome.Models.MIG3_1.C0401.BuyerRemarkEnum.Item1 : (WebHome.Models.MIG3_1.C0401.BuyerRemarkEnum)int.Parse(item.BuyerRemark),
                    BuyerRemarkSpecified = !String.IsNullOrEmpty(item.BuyerRemark),
                    Category = item.Category,
                    CheckNumber = item.CheckNo,
                    CustomsClearanceMark = String.IsNullOrEmpty(item.CustomsClearanceMark) ? WebHome.Models.MIG3_1.C0401.CustomsClearanceMarkEnum.Item1 : (WebHome.Models.MIG3_1.C0401.CustomsClearanceMarkEnum)int.Parse(item.CustomsClearanceMark),
                    CustomsClearanceMarkSpecified = !String.IsNullOrEmpty(item.CustomsClearanceMark),
                    InvoiceType = (WebHome.Models.MIG3_1.C0401.InvoiceTypeEnum)((int)item.InvoiceType),
                    //DonateMark = (WebHome.Models.MIG3_1.C0401.DonateMarkEnum)(int.Parse(item.DonateMark)),
                    DonateMark = string.IsNullOrEmpty(item.DonateMark) ? WebHome.Models.MIG3_1.C0401.DonateMarkEnum.Item0 : (WebHome.Models.MIG3_1.C0401.DonateMarkEnum)(int.Parse(item.DonateMark)),
                    CarrierType = item.InvoiceCarrier != null ? item.InvoiceCarrier.CarrierType : "",
                    //CarrierTypeSpecified = item.InvoiceCarrier != null ? true : false,
                    CarrierId1 = item.InvoiceCarrier != null ? item.InvoiceCarrier.CarrierNo : "",
                    CarrierId2 = item.InvoiceCarrier != null ? item.InvoiceCarrier.CarrierNo2 : "",
                    //PrintMark = item.CDS_Document.DocumentPrintLogs.Any(l => l.TypeID == (int)Model.Locale.Naming.DocumentTypeDefinition.E_Invoice) ? "Y"  : "N"
                    PrintMark = item.PrintMark,
                    NPOBAN = item.InvoiceDonation != null ? item.InvoiceDonation.AgencyCode : "",
                    RandomNumber = item.RandomNo,
                    GroupMark = item.GroupMark,
                    InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate.Value),
                    InvoiceTime = item.InvoiceDate.Value,
                    //InvoiceTimeSpecified = false,
                    InvoiceNumber = String.Format("{0}{1}", item.TrackCode, item.No),
                    MainRemark = item.Remark.GetEfficientStringMaxSize(0, 200),
                    //PermitNumber = item.PermitNumber,
                    //PermitDate = item.PermitDate.HasValue ? String.Format("{0:yyyyMMdd}", item.PermitDate.Value) : null,
                    //PermitWord = item.PermitWord,
                    RelateNumber = item.RelateNumber,
                    //TaxCenter = item.TaxCenter,
                    Seller = new WebHome.Models.MIG3_1.C0401.MainSeller
                    {
                        Address = item.InvoiceSeller.Address.GetEfficientStringMaxSize(0, 100).InsteadOfNullOrEmpty(""),//.InvoiceSeller.Address,
                        CustomerNumber = item.InvoiceSeller.CustomerID.GetEfficientStringMaxSize(0, 20).InsteadOfNullOrEmpty(""),//.InvoiceSeller.CustomerID,
                        EmailAddress = item.InvoiceSeller.EMail.GetEfficientStringMaxSize(0, 80).InsteadOfNullOrEmpty(""),//.InvoiceSeller.EMail,
                        FacsimileNumber = item.InvoiceSeller.Fax.GetEfficientStringMaxSize(0, 26).InsteadOfNullOrEmpty(""),//.InvoiceSeller.Fax,
                        Identifier = item.InvoiceSeller.ReceiptNo,//.InvoiceSeller.ReceiptNo,
                        Name = item.InvoiceSeller.CustomerName.GetEfficientStringMaxSize(0, 60).InsteadOfNullOrEmpty(""),//.InvoiceSeller.Name,
                        PersonInCharge = item.Organization.UndertakerName.GetEfficientStringMaxSize(0, 30).InsteadOfNullOrEmpty(""),
                        RoleRemark = item.InvoiceSeller.RoleRemark.GetEfficientStringMaxSize(0, 40).InsteadOfNullOrEmpty(""),//InvoiceSeller.RoleRemark,
                        TelephoneNumber = item.InvoiceSeller.Phone.GetEfficientStringMaxSize(0, 26).InsteadOfNullOrEmpty("")
                    }
                },
                Details = buildC0401Details(item),
                Amount = new WebHome.Models.MIG3_1.C0401.Amount
                {
                    CurrencySpecified = false,
                    DiscountAmount = item.InvoiceAmountType.DiscountAmount.HasValue ? (long)item.InvoiceAmountType.DiscountAmount.Value : 0,
                    DiscountAmountSpecified = item.InvoiceAmountType.DiscountAmount.HasValue,
                    ExchangeRateSpecified = false,
                    OriginalCurrencyAmountSpecified = false,
                    //SalesAmount = item.InvoiceAmountType.SalesAmount.HasValue ? (long)item.InvoiceAmountType.SalesAmount.Value : 0,
                    SalesAmount = item.InvoiceBuyer.ReceiptNo == "0000000000" ? (long)item.InvoiceAmountType.TotalAmount.Value : (long)item.InvoiceAmountType.SalesAmount.Value,
                    FreeTaxSalesAmount = (item.InvoiceAmountType.TaxType == 3) ? (long)item.InvoiceAmountType.SalesAmount.Value : 0,
                    ZeroTaxSalesAmount = (item.InvoiceAmountType.TaxType == 2) ? (long)item.InvoiceAmountType.SalesAmount.Value : 0,
                    TaxAmount = item.InvoiceBuyer.ReceiptNo == "0000000000" ? 0 : item.InvoiceAmountType.TaxAmount.HasValue ? (long)item.InvoiceAmountType.TaxAmount.Value : 0,
                    TaxRate = item.InvoiceAmountType.TaxRate.HasValue ? item.InvoiceAmountType.TaxRate.Value : 0.05m,
                    TaxType = (WebHome.Models.MIG3_1.C0401.TaxTypeEnum)((int)item.InvoiceAmountType.TaxType.Value),
                    TotalAmount = item.InvoiceAmountType.TotalAmount.HasValue ? (long)item.InvoiceAmountType.TotalAmount.Value : 0
                }
            };
            return result;
        }

        private static WebHome.Models.MIG3_1.C0401.DetailsProductItem[] buildC0401Details(InvoiceItem item)
        {
            List<WebHome.Models.MIG3_1.C0401.DetailsProductItem> items = new List<WebHome.Models.MIG3_1.C0401.DetailsProductItem>();
            foreach (var detailItem in item.InvoiceDetails)
            {
                detailItem.InvoiceProduct.InvoiceProductItem.ToList();
                foreach (var productItem in detailItem.InvoiceProduct.InvoiceProductItem)
                {
                    items.Add(new WebHome.Models.MIG3_1.C0401.DetailsProductItem
                    {
                        Amount = productItem.CostAmount.HasValue ? productItem.CostAmount.Value : 0m,
                        Description = detailItem.InvoiceProduct.Brief,
                        Quantity = productItem.Piece.HasValue ? productItem.Piece.Value : 0,
                        RelateNumber = productItem.RelateNumber,
                        Remark = productItem.Remark.GetEfficientStringMaxSize(0,40),
                        SequenceNumber = String.Format("{0:00}", productItem.No),
                        Unit = productItem.PieceUnit,
                        UnitPrice = productItem.UnitCost.HasValue ? productItem.UnitCost.Value : 0,
                    });
                }
            }
            return items.ToArray();
        }

        public static WebHome.Models.MIG3_1.C0501.CancelInvoice CreateC0501(this InvoiceItem item)
        {
            InvoiceCancellation InvCancel = item.InvoiceCancellation;
            if (InvCancel == null)
            {
                return null;
            }

            var result = new WebHome.Models.MIG3_1.C0501.CancelInvoice
            {
                CancelInvoiceNumber = InvCancel.CancellationNo,
                InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate.Value),
                BuyerId = item.InvoiceBuyer.ReceiptNo,
                SellerId = item.Organization.ReceiptNo,
                CancelDate = String.Format("{0:yyyyMMdd}", InvCancel.CancelDate.Value),
                CancelTime = InvCancel.CancelDate.Value,
                CancelReason = InvCancel.CancelReason,
                ReturnTaxDocumentNumber = InvCancel.ReturnTaxDocumentNo,
                Remark = InvCancel.Remark,
            };
            return result;
        }

        public static WebHome.Models.MIG3_1.D0401.Allowance CreateD0401(this InvoiceAllowance item)
        {
            var result = new WebHome.Models.MIG3_1.D0401.Allowance
            {
                Main = new WebHome.Models.MIG3_1.D0401.Main
                {
                    AllowanceNumber = item.AllowanceNumber,
                    AllowanceDate = String.Format("{0:yyyyMMdd}", item.AllowanceDate),
                    AllowanceType = (WebHome.Models.MIG3_1.D0401.AllowanceTypeEnum)((int)item.AllowanceType),
                    Buyer = new WebHome.Models.MIG3_1.D0401.MainBuyer
                    {
                        Address =string.IsNullOrEmpty( item.InvoiceAllowanceBuyer.Address)?
                        "":
                         item.InvoiceAllowanceBuyer.Address.Length>100?
                          item.InvoiceAllowanceBuyer.Address.Substring(0,100):
                           item.InvoiceAllowanceBuyer.Address,
                        //CustomerNumber = item.InvoiceAllowanceBuyer.CustomerName,
                        EmailAddress = "",//item.InvoiceAllowanceBuyer.EMail,
                        FacsimileNumber =String.IsNullOrEmpty( item.InvoiceAllowanceBuyer.Fax)?
                        "":
                         item.InvoiceAllowanceBuyer.Fax.Length>26?
                          item.InvoiceAllowanceBuyer.Fax.Substring(0,26):
                           item.InvoiceAllowanceBuyer.Fax,
                        Identifier = item.InvoiceAllowanceBuyer.ReceiptNo,
                        Name = item.InvoiceAllowanceBuyer.IsB2C()
                            ? Encoding.GetEncoding(950).GetBytes(item.InvoiceAllowanceBuyer.Name.InsteadOfNullOrEmpty("")).Length == 4
                                ? item.InvoiceAllowanceBuyer.Name : ValidityAgent.GenerateRandomCode(4)
                            : String.IsNullOrEmpty(item.InvoiceAllowanceBuyer.Name)
                                ? item.InvoiceAllowanceBuyer.ReceiptNo : item.InvoiceAllowanceBuyer.Name,
                        PersonInCharge =String.IsNullOrEmpty( item.InvoiceAllowanceBuyer.PersonInCharge)?
                        "":
                        item.InvoiceAllowanceBuyer.PersonInCharge.Length>30?
                        item.InvoiceAllowanceBuyer.PersonInCharge.Substring(0,30):
                        item.InvoiceAllowanceBuyer.PersonInCharge,
                        RoleRemark = item.InvoiceAllowanceBuyer.RoleRemark,
                        TelephoneNumber = "",//item.InvoiceAllowanceBuyer.Phone,
                    },
                    Seller = new WebHome.Models.MIG3_1.D0401.MainSeller
                    {
                        Address =String.IsNullOrEmpty( item.InvoiceAllowanceSeller.Address)?
                        "":
                         item.InvoiceAllowanceSeller.Address.Length > 100 ?
                          item.InvoiceAllowanceSeller.Address.Substring(0, 100) :
                           item.InvoiceAllowanceSeller.Address,
                        //CustomerNumber = item.InvoiceAllowanceSeller.CustomerName,
                        EmailAddress = "",//item.InvoiceAllowanceSeller.EMail,
                        FacsimileNumber =String.IsNullOrEmpty( item.InvoiceAllowanceSeller.Fax)?
                        "":
                        item.InvoiceAllowanceSeller.Fax.Length>26?
                        item.InvoiceAllowanceSeller.Fax.Substring(0,26):
                        item.InvoiceAllowanceSeller.Fax,
                        Identifier = item.InvoiceAllowanceSeller.ReceiptNo,
                        Name = item.InvoiceAllowanceSeller.Name,
                        PersonInCharge =String.IsNullOrEmpty( item.InvoiceAllowanceSeller.PersonInCharge)?
                        "":
                         item.InvoiceAllowanceSeller.PersonInCharge.Length>30?
                          item.InvoiceAllowanceSeller.PersonInCharge.Substring(0,30):
                           item.InvoiceAllowanceSeller.PersonInCharge,
                        RoleRemark = item.InvoiceAllowanceSeller.RoleRemark,
                        TelephoneNumber = "",//item.InvoiceAllowanceSeller.Phone,
                    },
                },
                Amount = new WebHome.Models.MIG3_1.D0401.Amount
                {
                    TaxAmount = item.TaxAmount.HasValue ? (long)item.TaxAmount.Value : 0,
                    TotalAmount = item.TotalAmount.HasValue ? (long)item.TotalAmount.Value : 0,
                },
            };

            result.Details = item.InvoiceAllowanceDetails.Select(d => new WebHome.Models.MIG3_1.D0401.DetailsProductItem
            {
                AllowanceSequenceNumber = d.InvoiceAllowanceItem.No.ToString(),
                Amount = d.InvoiceAllowanceItem.Amount.HasValue ? d.InvoiceAllowanceItem.Amount.Value : 0m,
                OriginalDescription = d.InvoiceAllowanceItem.OriginalDescription,
                OriginalInvoiceDate = String.Format("{0:yyyyMMdd}", d.InvoiceAllowanceItem.InvoiceDate),
                OriginalInvoiceNumber = d.InvoiceAllowanceItem.InvoiceNo,
                OriginalSequenceNumber = d.InvoiceAllowanceItem.OriginalSequenceNo.HasValue ? d.InvoiceAllowanceItem.OriginalSequenceNo.Value.ToString() : "1",
                Quantity = d.InvoiceAllowanceItem.Piece.HasValue ? d.InvoiceAllowanceItem.Piece.Value : 0.00000M,
                Tax = (long)d.InvoiceAllowanceItem.Tax.Value,
                TaxType = (WebHome.Models.MIG3_1.D0401.DetailsProductItemTaxType)(int)d.InvoiceAllowanceItem.TaxType,
                Unit = d.InvoiceAllowanceItem.PieceUnit,
                UnitPrice = d.InvoiceAllowanceItem.UnitCost.HasValue ? d.InvoiceAllowanceItem.UnitCost.Value : 0,
            }).ToArray();

            return result;
        }

        public static WebHome.Models.MIG3_1.D0501.CancelAllowance CreateD0501(this InvoiceAllowance item)
        {
            InvoiceAllowanceCancellation InvCanlAllow = item.InvoiceAllowanceCancellation;
            if (InvCanlAllow == null)
            {
                return null;
            }

            var result = new WebHome.Models.MIG3_1.D0501.CancelAllowance
            {
                CancelAllowanceNumber = item.AllowanceNumber,
                AllowanceDate = String.Format("{0:yyyyMMdd}",item.AllowanceDate.Value),
                BuyerId = item.BuyerId,
                SellerId = item.SellerId,
                CancelDate = String.Format("{0:yyyyMMdd}",InvCanlAllow.CancelDate.Value),
                CancelTime = InvCanlAllow.CancelDate.Value,
                CancelReason = InvCanlAllow.CancelReason,
                Remark = InvCanlAllow.Remark,
            };
            return result;
        }

        public static WebHome.Models.MIG3_1.C0701.VoidInvoice CreateC0701(this InvoiceItem item)
        {
            return new WebHome.Models.MIG3_1.C0701.VoidInvoice
            {
                VoidInvoiceNumber = item.TrackCode + item.No,
                InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate),
                BuyerId = item.InvoiceBuyer.ReceiptNo,
                SellerId = item.InvoiceSeller.ReceiptNo,
                VoidDate = DateTime.Now.Date.ToString("yyyyMMdd"),
                VoidTime = DateTime.Now,
                VoidReason = "註銷重開",
                Remark = ""
            };
        }

    }
}
