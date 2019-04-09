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
<div class="body">
    <div class="row">
        <div class="col-8">
            <h5 class="m-t-0">即將過期</h5>
            <%  var effectiveItems = models.PromptEffectiveContract()
                    .FilterByBranchStoreManager(models, _model.UID);
                var expiringItems = models.PromptExpiringContract().FilterByBranchStoreManager(models, _model.UID);
                var expiredItems = models.PromptRegisterLessonContract()
                    .FilterByExpired(models)
                    .FilterByBranchStoreManager(models, _model.UID); %>
            <p class="text-small">
                已過期：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    IsExpired = true,
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已過期,
                                }) %>,<%= expiredItems.Count() %>);'><%= expiredItems.Count() %></a><br />
                生效中：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    IsExpired = false,
                                }) %>,<%= effectiveItems.Count() %>);'><%= effectiveItems.Count() %></a>
            </p>
        </div>
        <div class="col-4 text-right">
            <a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    ExpirationFrom = DateTime.Today,
                                    ExpirationTo = DateTime.Today.AddMonths(1),
                                }) %>,<%= expiringItems.Count() %>);'>
                <h2 class="col-red"><%= expiringItems.Count() %></h2>
            </a>
            <small class="info">合約</small>
        </div>
    </div>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
