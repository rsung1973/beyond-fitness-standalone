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

<%  if (_model != null)
    { %>
<%--<img id="barcode" alt="" height="22" src="<%= WebHome.Properties.Settings.Default.HostDomain
        + Url.Action("GetBarCode39","Published",new { code = String.Format("{0:000}{1:00}{2}{3}{4}", _model.InvoiceDate.Value.Year - 1911, _model.InvoiceDate.Value.Month, _model.TrackCode, _model.No, _model.RandomNo) }) %>" width="160" />--%>
<%--<img id="barcode" alt="" height="<%= (bool?)ViewBag.Canvas==true ? "50" : "22" %>" src="<%= String.Format("{0:000}{1:00}{2}{3}{4}", _model.InvoiceDate.Value.Year - 1911, _model.InvoiceDate.Value.Month, _model.TrackCode, _model.No, _model.RandomNo).GetCode39ImageSrc(false,600f) %>"
    width="<%= (bool?)ViewBag.Canvas==true ? "350" : "160" %>" />--%>
<img id="barcode" alt="" src="<%= String.Format("{0:000}{1:00}{2}{3}{4}", _model.InvoiceDate.Value.Year - 1911, _model.InvoiceDate.Value.Month, _model.TrackCode, _model.No, _model.RandomNo).GetCode39ImageSrc(false,600f) %>" />
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    InvoiceItem _model;
    Organization _seller;
    
    bool _isB2C;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (InvoiceItem)this.Model;
        _seller = _model.Organization;
        _isB2C = String.IsNullOrEmpty(_model.InvoiceBuyer.ReceiptNo) || _model.InvoiceBuyer.ReceiptNo == "0000000000";
    }


</script>
