<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<!--我的分店合約-->
<div class="container-fluid">
    <h4 class="card-outbound-header">我的分店合約</h4>
    <div class="card widget_2">
        <ul class="row clearfix list-unstyled m-b-0">
            <li class="col-lg-4 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutExpiringByBranch.ascx", _model); %>
            </li>
            <li class="col-lg-4 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContractsByBranch.ascx", _model); %>
            </li>
            <li class="col-lg-4 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutPaymentByBranch.ascx", _model); %>
            </li>
        </ul>
        <ul class="row clearfix list-unstyled m-b-0">
            <li class="col-lg-8 col-md-6 col-sm-12">
                <div class="body">
                    <div class="row">
                        <div class="col-lg-6 col-md-6 col-12">
                            <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutCompleteLessons.ascx", _effectiveItems); %>
                        </div>
                        <div class="col-lg-6 col-md-6 col-12">
                            <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutInstallment.ascx", _effectiveItems); %>
                        </div>
                    </div>
                </div>
            </li>
            <li class="col-lg-4 col-md-6 col-sm-12">
                <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutReceivablesByBranch.ascx", _model); %>
            </li>
        </ul>
    </div>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IQueryable<CourseContract> _effectiveItems;
    IQueryable<CourseContract> _contractItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        _contractItems = models.PromptOriginalContract().FilterByBranchStoreManager(models, _model.UID);
        _effectiveItems = models.PromptEffectiveContract().FilterByBranchStoreManager(models, _model.UID);
    }


</script>
