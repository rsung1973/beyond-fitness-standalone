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
                var items = models.PromptOriginalContract()
                        .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效);
                var currentItems = items.Where(c => c.EffectiveDate >= DateTime.Today && c.EffectiveDate < DateTime.Today.AddDays(1));
            %>
            <h5 class="m-t-0">賀成交</h5>
            <p class="text-small">
                今日：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    EffectiveDateFrom = DateTime.Today,
                                    EffectiveDateTo = DateTime.Today.AddDays(1),
                                }) %>,<%= currentItems.Count() %>);'><%= currentItems.Count() %></a>
                <br />
                <%
                    var weekStart = DateTime.Today.FirstDayOfWeek();
                    currentItems = items.Where(c => c.EffectiveDate >= weekStart && c.EffectiveDate < weekStart.AddDays(7));
                    %>
                本週：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    EffectiveDateFrom = weekStart,
                                    EffectiveDateTo = weekStart.AddDays(7),
                                }) %>,<%= currentItems.Count() %>);'><%= currentItems.Count() %></a>
                <br />
                <%
                    currentItems = items.Where(c => c.EffectiveDate >= monthStart && c.EffectiveDate < monthStart.AddMonths(1));
                %>
                本月：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    EffectiveDateFrom = monthStart,
                                    EffectiveDateTo = monthStart.AddMonths(1),
                                }) %>,<%= currentItems.Count() %>);'><%= currentItems.Count() %></a>
            </p>
        </div>
        <div class="col-4 text-right">
            <%  currentItems = items.Where(c => c.EffectiveDate >= monthStart.AddMonths(-1) && c.EffectiveDate < monthStart); %>
            <a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new 
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    Status = (int)Naming.CourseContractStatus.已生效,
                                    EffectiveDateFrom = monthStart.AddMonths(-1),
                                    EffectiveDateTo = monthStart,
                                }) %>,<%= currentItems.Count() %>);'>
                <h2><%= currentItems.Count() %></h2>
            </a>
            <small class="info">上月</small>
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
