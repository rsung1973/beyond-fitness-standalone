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
    var toPay = _contractItems.FilterByToPay(models);
%>
<div class="body">
    <div class="row">
        <div class="col-8">
            <h5 class="m-t-0">催收帳款</h5>
            <p class="text-small">
                <%  DateTime dateFrom = DateTime.Today.FirstDayOfMonth();
                    DateTime dateTo = dateFrom.AddMonths(1);
                    var items = toPay.Where(c => !c.PayoffDue.HasValue
                                    || (c.PayoffDue >= dateFrom && c.PayoffDue < dateTo));  %>
                <%= $"{dateFrom:yyyy/MM}" %>：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    PayoffMode = Naming.ContractPayoffMode.Unpaid,
                                    PayoffDueFrom = dateFrom,
                                    PayoffDueTo = dateTo,
                                    IncludeTotalUnpaid = true,
                                }) %>,<%= items.Count() %>);'><%= items.Count() %></a>
                <br />
                <%
                    for (int i = 1; i < 5; i++)
                    {
                        dateFrom = dateTo;
                        dateTo = dateTo.AddMonths(1);
                        items = toPay.Where(c => c.PayoffDue >= dateFrom && c.PayoffDue < dateTo);
                        %>
                <%= $"{dateFrom:yyyy/MM}" %>：<a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    PayoffMode = Naming.ContractPayoffMode.Unpaid,
                                    PayoffDueFrom = dateFrom,
                                    PayoffDueTo = dateTo,
                                }) %>,<%= items.Count() %>);'><%= items.Count() %></a>
                <br />
                <%      
                    }
                    %>
            </p>
        </div>
        <div class="col-4 text-right">
            <a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                new
                                {
                                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                                    PayoffMode = Naming.ContractPayoffMode.Unpaid,
                                }) %>,<%= toPay.Count() %>);'>
                <h2 class="col-red"><%= toPay.Count() %></h2>
            </a>
            <small class="info">全部</small>
        </div>
    </div>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IQueryable<CourseContract> _contractItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _contractItems = models.PromptAccountingContract();


    }


</script>
