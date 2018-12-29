<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%
    var totalAmt = _contractItems.Sum(c => c.TotalCost) ?? 1;
    var toPayItems = _contractItems.QueryContractPayment(models)
                        .Where(p => !p.TotalPaidAmount.HasValue || p.Contract.TotalCost > p.TotalPaidAmount);
    var totalAmtToPay = toPayItems.Sum(c => c.Contract.TotalCost - (c.TotalPaidAmount ?? 0));   %>

<div class="body">
    <div class="row">
        <div class="col-12 text-center">
            <input type="text" class="knob" data-linecap="round" data-width="90" data-height="90" data-thickness="0.25" data-anglearc="250" data-angleoffset="-125" data-fgcolor="#F15F79" readonly id="<%= _knobID %>" />
            <script>
                $(function () {
                    drawKnob($("#<%= _knobID %>"),<%= totalAmtToPay*100 / totalAmt %>, 3800);
                });
            </script>
            <h6 class="m-t-20">催收帳款比率</h6>
            <p class="displayblock m-b-0">$<%= $"{totalAmtToPay:##,###,###,##0}" %></p>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<CourseContract> _model;
    IQueryable<CourseContract> _contractItems;
    String _knobID = $"toPayRatio{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = _contractItems = (IQueryable<CourseContract>)this.Model;
    }


</script>
