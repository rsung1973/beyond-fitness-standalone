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
    DateTime calcStart = new DateTime(2018, 12, 1);
    var calculatedItems = _contractItems.Where(c => c.EffectiveDate >= calcStart);
    var calculatedInstallment = calculatedItems.Where(c => c.InstallmentID.HasValue);
    var ratio = calculatedInstallment.Count() * 100 / Math.Max(calculatedItems.Count(), 1);
%>
<div class="body">
    <div class="row">
        <div class="col-12 text-center">
            <input type="text" class="knob" data-linecap="round" data-width="90" data-height="90" data-thickness="0.25" data-anglearc="250" data-angleoffset="-125" data-fgcolor="#379c94" readonly id="<%= _knobID %>" />
            <script>
                $(function () {
                    drawKnob($("#<%= _knobID %>"),<%= ratio %>, 3800);
                });
            </script>
            <h6 class="m-t-20">分期比率</h6>
            <p class="displayblock m-b-0">
                <%= ratio %>% 本月平均 
                <%  DateTime monthStart = DateTime.Today.FirstDayOfMonth();
                    var currentContractsMonthly = _contractItems.Where(c => c.EffectiveDate >= monthStart);
                    var contractsInstallment = currentContractsMonthly.Where(c => c.InstallmentID.HasValue);                                    
                    var contractsLastMonth = _contractItems.Where(c => c.EffectiveDate >= monthStart.AddMonths(-1) && c.EffectiveDate < monthStart);
                    var contractsLastMonthInstallment = contractsLastMonth.Where(c => c.InstallmentID.HasValue);
                    var currentCount = contractsInstallment.Count();
                    var lastMonthCount = contractsLastMonthInstallment.Count();
                    if (currentCount < lastMonthCount)
                    {
                %>
                <i class="zmdi zmdi-trending-down"></i>
                <%  }
                    else if (currentCount > lastMonthCount)
                    {
                %>
                <i class="zmdi zmdi-trending-up"></i>
                <%  }   %>
            </p>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<CourseContract> _model;
    IQueryable<CourseContract> _contractItems;
    String _knobID = $"installmentRate{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = _contractItems = (IQueryable<CourseContract>)this.Model;
    }


</script>
