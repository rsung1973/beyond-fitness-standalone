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
                var editingItems = models.PromptContractInEditing();
                var toConfirmItems = models.PromptContractToConfirm();
                var toSignItems = models.PromptContractToSign();
            %>
            <h5 class="m-t-0">賀成交</h5>
            <p class="text-small">
                編輯中：<a href='javascript:showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.草稿,
                                }) %>,<%= editingItems.Count() %>);'><%= editingItems.Count() %></a>
                <br />
                待簽名：<a href='javascript:showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.待簽名,
                                }) %>,<%= toSignItems.Count() %>);'><%= toSignItems.Count() %></a>
                <br />
                待審核：<a href='javascript:showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.待審核,
                                }) %>,<%= toConfirmItems.Count() %>);'><%= toConfirmItems.Count() %></a>
            </p>
        </div>
        <div class="col-4 text-right">
            <%  var totalCount = models.PromptEffectiveContract()
                            .Where(c => c.EffectiveDate >= monthStart && c.EffectiveDate < monthStart.AddMonths(1)).Count(); %>
            <a href='javascript:showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
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
