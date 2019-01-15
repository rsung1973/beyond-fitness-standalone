<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Utility" %>

<%  if (_qrCode!=null)
    { %>
        <img class="qrcode" alt="" width="<%= (bool?)ViewBag.Canvas==true ? "160" : "80" %>" height="<%= (bool?)ViewBag.Canvas==true ? "160" : "80" %>" src="<%= _qrCode.CreateQRCodeImageSrc() %>" />
&nbsp;&nbsp;&nbsp;&nbsp;
        <img class="qrcode" alt="" width="<%= (bool?)ViewBag.Canvas==true ? "160" : "80" %>" height="<%= (bool?)ViewBag.Canvas==true ? "160" : "80" %>" src="<%= "**".CreateQRCodeImageSrc() %>" />
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    InvoiceItem _model;
    Organization _seller;

    bool _isB2C;
    String _qrCode;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (InvoiceItem)this.Model;
        _seller = _model.Organization;
        _isB2C = String.IsNullOrEmpty(_model.InvoiceBuyer.ReceiptNo) || _model.InvoiceBuyer.ReceiptNo == "0000000000";

        if (_model != null)
            getQRCodeContent();
    }

    protected void getQRCodeContent()
    {
        String keyFile = Path.Combine(Logger.LogPath, "ORCodeKey.txt");
        if (!File.Exists(keyFile))
            return;

        String key = File.ReadAllText(keyFile);
        String EncryptContent = _model.TrackCode + _model.No + _model.RandomNo;
        com.tradevan.qrutil.QREncrypter qrencrypter = new com.tradevan.qrutil.QREncrypter();
        String finalEncryData = qrencrypter.AESEncrypt(EncryptContent, key);

        StringBuilder sb = new StringBuilder();
        sb.Append(_model.TrackCode + _model.No);
        sb.Append(String.Format("{0:000}{1:00}{2:00}", _model.InvoiceDate.Value.Year - 1911, _model.InvoiceDate.Value.Month, _model.InvoiceDate.Value.Day));
        sb.Append(_model.RandomNo);
        sb.Append(String.Format("{0:X8}", (int)_model.InvoiceAmountType.SalesAmount));
        sb.Append(String.Format("{0:X8}", (int)_model.InvoiceAmountType.TotalAmount));
        sb.Append(_isB2C ? "00000000" : _model.InvoiceBuyer.ReceiptNo);
        sb.Append(_model.Organization.ReceiptNo);
        sb.Append(finalEncryData);
        sb.Append(":");
        sb.Append("**********");
        sb.Append(":");
        var itemsCount = _model.InvoiceDetails.Sum(d => d.InvoiceProduct.InvoiceProductItem.Count);
        sb.Append(itemsCount);
        sb.Append(":");
        sb.Append(itemsCount);
        sb.Append(":");
        sb.Append(1);
        sb.Append(":");
        foreach (var d in _model.InvoiceDetails)
        {
            var product = d.InvoiceProduct;
            foreach (var p in product.InvoiceProductItem)
            {
                sb.Append(product.Brief);
                sb.Append(":");
                sb.Append(String.Format("{0:0}", p.Piece));
                sb.Append(":");
                sb.Append(String.Format("{0:0}", p.UnitCost));
                sb.Append(":");
            }
        }

        _qrCode = sb.ToString();

    }



</script>
