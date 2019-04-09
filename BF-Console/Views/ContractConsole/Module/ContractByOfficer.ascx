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

<!--我的分店合約-->
<div class="container-fluid">
    <h4 class="card-outbound-header">我的分店合約</h4>
    <div class="card widget_2">
        <ul class="row clearfix list-unstyled m-b-0">
            <li class="col-lg-3 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutExpiringByOfficer.ascx", _model); %>
            </li>
            <li class="col-lg-3 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutContractsByOfficer.ascx", _model); %>
            </li>
            <li class="col-lg-3 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutContractServicesSummaryByOfficer.ascx", _model); %>
            </li>
            <li class="col-lg-3 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutPaymentByOfficer.ascx", _model); %>
            </li>
        </ul>
        <ul class="row clearfix list-unstyled m-b-0">
            <li class="col-lg-3 col-md-3 col-sm-6">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/ToRenewByOfficer.ascx", _model); %>
            </li>
            <li class="col-lg-3 col-md-3 col-sm-6">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutCompleteLessons.ascx", _effectiveItems); %>
            </li>
            <li class="col-lg-3 col-md-3 col-sm-6">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutInstallment.ascx", _effectiveItems); %>
            </li>
            <li class="col-lg-3 col-md-3 col-sm-6">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutReceivablesByOfficer.ascx", _model); %>
            </li>
        </ul>
    </div>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IQueryable<CourseContract> _contractItems;
    IQueryable<CourseContract> _effectiveItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        _effectiveItems = models.PromptEffectiveContract();
        _contractItems = models.PromptOriginalContract();
    }


</script>
