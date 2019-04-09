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
            <%  DateTime monthStart = DateTime.Today.FirstDayOfMonth();
                var contracts = models.PromptContractService();
                var editingItems = contracts
                                    .Where(c => c.FitnessConsultant == _model.UID)
                                    .Where(c => c.Status == (int)Naming.CourseContractStatus.草稿);
                var toConfirmItems = contracts
                                    .FilterByBranchStoreManager(models, _model.UID)
                                    .Where(c => c.Status == (int)Naming.CourseContractStatus.待確認);
                var toSignItems = contracts
                                    .FilterByBranchStoreManager(models, _model.UID)
                                    .Where(c => c.Status == (int)Naming.CourseContractStatus.待簽名);
            %>
            <h5 class="m-t-0">服務申請</h5>
            <p class="text-small">
                編輯中：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ServiceOnly,
                                    Status = (int)Naming.CourseContractStatus.草稿,
                                }) %>,<%= editingItems.Count() %>);'><%= editingItems.Count() %></a><br />
                待簽名：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ServiceOnly,
                                    Status = (int)Naming.CourseContractStatus.待簽名,
                                }) %>,<%= toSignItems.Count() %>);'><%= toSignItems.Count() %></a><br />
                待審核：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ManagerID = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ServiceOnly,
                                    Status = (int)Naming.CourseContractStatus.待確認,
                                }) %>,<%= toConfirmItems.Count() %>);'><%= toConfirmItems.Count() %></a>
            </p>
        </div>
        <div class="col-4 text-right">
            <%  var totalCount = models.PromptContractService().FilterByEffective(models)
                            .Where(c => c.FitnessConsultant == _model.UID)
                            .Where(c => c.EffectiveDate >= monthStart && c.EffectiveDate < monthStart.AddMonths(1)).Count(); %>
            <a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    FitnessConsultant = _model.UID,
                                    ContractQueryMode = Naming.ContractServiceMode.ServiceOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    EffectiveDateFrom = monthStart,
                                    EffectiveDateTo = monthStart.AddMonths(1),
                                }) %>,<%= totalCount %>);'>
                <h2><%= totalCount %></h2>
            </a>
            <small class="info">本月</small>
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
