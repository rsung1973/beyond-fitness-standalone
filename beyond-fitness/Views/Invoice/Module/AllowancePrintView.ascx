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

<% if (_model != null)
    {
        var details = _model.InvoiceAllowanceDetails.Select(d => d.InvoiceAllowanceItem).First();
            %>
<div style="page-break-after: always; margin-left: 0cm; margin-right: 0cm">
    <div class="container" style="border-top: 0px; border-bottom: 0px;">
        <p style="text-align:center">電子發票銷貨退回、進貨退出<Br />或折讓證明單證明聯</p>
        <p style="text-align:center"><%= String.Format("{0:yyyy-MM-dd}", _model.AllowanceDate) %></p>
        <p style="width: 390px;">賣方統編：<%= _model.InvoiceAllowanceSeller.ReceiptNo %><br />
           賣方名稱：<%= _model.InvoiceAllowanceSeller.CustomerName %><br />
           發票開立日期：<%= String.Format("{0:yyyy-MM-dd}", details.InvoiceDate) %><br />
            <%= details.InvoiceNo.Substring(0,2) %>-<%= details.InvoiceNo.Substring(2) %><br />
           買方統編：<%= !_model.InvoiceAllowanceBuyer.IsB2C() ? _model.InvoiceAllowanceBuyer.ReceiptNo : null %><br />
           買方名稱：<%= !_model.InvoiceAllowanceBuyer.IsB2C() ? _model.InvoiceAllowanceBuyer.CustomerName : null %><br />
        </p>
        <p></p>
        <p>
        <%  
            var items = _model.InvoiceAllowanceDetails.Select(d => d.InvoiceAllowanceItem);
            foreach (var d in items)
            { %>
            品名：<%= d.OriginalDescription %><br />
            數量：<%= String.Format("{0:##,###,###,###,###}", d.Piece) %><br />
            單價：<%= String.Format("{0:##,###,###,###,###}", d.UnitCost) %><br />
            金額(不含稅)：<%= String.Format("{0:##,###,###,###,###}", d.Amount) %><br />
            課稅別：<%= (d.TaxType == (byte)2 || d.TaxType == (byte)3) ? "TZ" : "TX"%>
        <%  } %>
        </p>
        <p>
            營業稅額合計：<%= String.Format("{0:##,###,###,###,###}", _model.TaxAmount) %><br />
            金額(不含稅)合計：<%= String.Format("{0:##,###,###,###,###}", _model.TotalAmount) %><br />
        </p>
        <p></p>
        <p>
            簽收人：
        </p>
    </div>
</div>
<%      
    } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    InvoiceAllowance _model;
    Organization _seller;
    
    bool _isB2C;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (InvoiceAllowance)this.Model;
        _seller = _model.InvoiceAllowanceSeller.Organization;
        _isB2C = String.IsNullOrEmpty(_model.InvoiceAllowanceBuyer.ReceiptNo) || _model.InvoiceAllowanceBuyer.ReceiptNo == "0000000000";
    }

</script>
