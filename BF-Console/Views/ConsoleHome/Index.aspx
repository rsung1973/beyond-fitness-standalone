<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

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

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">
    <!-- royalslider -->
    <link href="plugins/royalslider/royalslider.css" rel="stylesheet"/>
    <link href="plugins/royalslider/skins/default/rs-default.css" rel="stylesheet"/>
    <link href="css/royalslider.css?1.0" rel="stylesheet"/>
    <!-- charts-c3 -->
    <link href="plugins/charts-c3/plugin.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!--Sparkline Plugin Js-->
    <script src="plugins/jquery-sparkline/jquery.sparkline.js"></script>
    <section class="content">

        <%  ViewBag.BlockHeader = "任意門";
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model); %>
        <!--本月運動時間-->
        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-lg-12 col-md-12">
                    <div class="card bg-darkteal exerciserank">
                        <div class="body">
                            <%  DateTime monthStart = DateTime.Today.FirstDayOfMonth();

                                var selfTraining = models.PromptMemberExerciseLessons(models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID))
                                        .Where(l => l.LessonAttendance != null);

                                var selfTrainingThisMonth = selfTraining.Where(l => l.ClassTime >= monthStart && l.ClassTime < DateTime.Today.AddDays(1));
                                var totalMinutes = selfTrainingThisMonth.Sum(l => l.DurationInMinutes) ?? 0;

                                var totalMinutesLastMonth = selfTraining
                                        .Where(l => l.ClassTime >= monthStart.AddMonths(-1) && l.ClassTime < DateTime.Today.AddMonths(-1).AddDays(1))
                                        .Sum(l => l.DurationInMinutes) ?? 0;
                            %>
                            <div class="font-20 align-center">
                                本月運動：<span class="col-lime counto" data-to="<%= totalMinutes/60 %>"><%= totalMinutes/60 %></span>小時:<span class="col-lime counto" data-to="<%= totalMinutes%60 %>"><%= totalMinutes%60 %></span>分鐘 
                                <%  if (totalMinutes > totalMinutesLastMonth)
                                    {   %>
                                <i class="zmdi zmdi-caret-up zmdi-hc-2x text-danger"></i>
                                <%  }
                                    else if (totalMinutes < totalMinutesLastMonth)
                                    {   %>
                                <i class="zmdi zmdi-caret-down zmdi-hc-2x text-success"></i>
                                <%  } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--我的行事曆卡片-->
        <div class="container-fluid">
            <div class="row clearfix">
                <h4 class="card-outbound-header m-l-15">我的行事曆</h4>
                <div class="col-lg-12 col-md-12">
                    <div class="row clearfix">
                        <div class="col-12">
                            <div class="card">
                                <div class="body">
                                    <div class="row clearfix">
                                        <div class="col-md-6 col-12 weather calendar">
                                            <ul class="row days list-unstyled m-t-20">
                                                <%
                                                    DateTime weekday = DateTime.Today.FirstDayOfWeek();

                                                    bool includeUserEvent = _model.IsAssistant() || _model.IsSysAdmin() || _model.IsOfficer();
                                                    IQueryable<UserEvent> userEvents = null;
                                                    if (includeUserEvent)
                                                    {
                                                        userEvents = models.PromptMemberEvents(_model);
                                                    }

                                                    for (int i = 0; i < 7; i++)
                                                    {
                                                        DateTime endDate = weekday.AddDays(1);
                                                        var lessons = _lessons.Where(l => l.ClassTime >= weekday && l.ClassTime < endDate);
                                                        var lessonCount = lessons.Count();
                                                        if (includeUserEvent)
                                                        {
                                                            lessonCount += (userEvents.Where(t => (t.StartDate >= weekday && t.StartDate < endDate)
                                                                || (t.EndDate >= weekday && t.EndDate < endDate)
                                                                || (t.StartDate < weekday && t.EndDate >= endDate)).Count());
                                                        }
                                                %>
                                                <li class="<%= weekday==DateTime.Today ? "col-pink" : null %>" onclick="window.location.href = '<%= Url.Action("Calendar","ConsoleHome",new { DateFrom = weekday, DateTo = endDate }) %>';">
                                                    <h5><%= $"{weekday:M/d}" %></h5>
                                                    <img src="<%= lessonCount<3 
                                                  ? "images/facesmile/easy.jpg"
                                                  : lessonCount>5
                                                        ? "images/facesmile/hard.jpg"
                                                        : "images/facesmile/ragular.jpg"%>">
                                                    <span class="degrees"><%= lessonCount %></span>
                                                </li>
                                                <%     weekday = weekday.AddDays(1);
                                                    } %>
                                            </ul>
                                        </div>
                                        <div class="col-md-6 col-12">
                                            <ul class="row profile_state list-unstyled">
                                                <%  if (_model.IsViceManager() || _model.IsManager())
                                                    {
                                                        ViewBag.Allotment = 3;
                                                    }
                                                    else
                                                    {
                                                        ViewBag.Allotment = 2;
                                                    }
                                                    %>
                                                <%  Html.RenderPartial("~/Views/ConsoleHome/Module/AboutEditableLessons.ascx", _model); %>
                                                <%  Html.RenderPartial("~/Views/ConsoleHome/Module/AboutLearnerUncheckedLessons.ascx", _model); %>
                                                <%  if (_model.IsViceManager() || _model.IsManager())
                                                    {
                                                        Html.RenderPartial("~/Views/ConsoleHome/Module/AboutToApprovePreferredLessons.ascx", _model);
                                                    }
                                                    %>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--我的合約與收款卡片-->
        <div class="container-fluid">
            <h4 class="card-outbound-header">我的合約與收款</h4>
            <div class="card widget_2">
                <ul class="row clearfix list-unstyled m-b-0">
                    <li class="col-lg-3 col-md-6 col-sm-12 contract">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutExpiring.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12 contract">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContracts.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12 contract">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutContractServices.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <div class="body">
                            <div class="row">
                                <div class="col-8">
                                    <%
                                        var payment = models.GetTable<Payment>().FilterByUserRoleScope(models, _model);
                                        var paymentToday = payment.Where(p => p.PayoffDate >= DateTime.Today);
                                        var voidToday = models.GetTable<VoidPayment>().Where(v => v.VoidDate >= DateTime.Today)
                                                .Join(payment, v => v.VoidID, p => p.PaymentID, (v, p) => p);
                                    %>
                                    <h5 class="m-t-0">本日收款</h5>
                                    <p class="text-small">
                                        收款：<a href="javascript:void(0);"><%= paymentToday.Count() %></a>
                                        <br />
                                        作廢：<a href="javascript:void(0);"><%= voidToday.Where(v=>v.InvoiceItem.InvoiceCancellation!=null).Count() %></a><br />
                                        折讓：<a href="javascript:void(0);"><%= voidToday.Where(v=>v.AllowanceID.HasValue).Count() %></a>
                                    </p>
                                </div>
                                <div class="col-4 text-right">
                                    <a href="javascript:void(0);">
                                        <h2><%= paymentToday.Count() + voidToday.Count() %></h2>
                                    </a>
                                    <small class="info"></small>
                                </div>
                            </div>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
        <!--我的學生-->
        <%  if (_model.IsCoach())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutLearners_1.ascx", _model);
            }   %>        <!--我的分店業績卡片-->        <%  if (_model.IsOfficer() || _model.IsManager() || _model.IsViceManager())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutAchievementC3.ascx", _model);
            }   %>        <!--我的業績&我的比賽-->        <%  if (_model.IsCoach())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutCoach.ascx", _model);
            }   %>        <!--我的業績&我的比賽&運動小學堂-->
        <%--        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-lg-12 col-md-12">
                    <div class="row clearfix">
                        <div class="col-sm-4 col-12 achivement">
                            <h4 class="card-outbound-header">我的業績</h4>
                            <div class="parallax-img-card">
                                <div class="body">
                                    <h4>AFM / P.T 6<br />
                                        2 張證照</h4>
                                </div>
                                <div class="parallax">
                                    <img src="images/carousel/level-background.jpg"></div>
                            </div>
                        </div>
                        <div class="col-sm-4 col-12">
                            <h4 class="card-outbound-header">我的比賽</h4>
                            <div class="parallax-card bg-darkteal">
                                <div class="body">
                                    <h4>目前第 1 名</h4>
                                </div>
                                <div class="chart-box">
                                    <canvas id="radarChart" height="150"></canvas>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4 col-12">
                            <h4 class="card-outbound-header">運動小學堂</h4>
                            <div class="parallax-img-card">
                                <div class="body">
                                    <h4>目前已編寫題目卷<span class="col-lime"> 5 </span>張囉！</h4>
                                    <p class="col-white">題目卷答題率已達 <span class="col-lime">24%</span>，成績單及格率<span class="col-lime"> 10%</span></p>
                                </div>
                                <div class="parallax">
                                    <img src="images/carousel/qa-background.jpg"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>--%>
        <!--我的發票卡片-->
        <%  if (_model.IsAssistant() || _model.IsAuthorizedSysAdmin())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutInvoice.ascx", _model);
            }           %>        <!--專業文章&我的比賽-->        <%  if (_model.IsAssistant() || _model.IsAuthorizedSysAdmin() || _model.IsServitor())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutStaff.ascx", _model);
            }           %>    </section>
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- countTo Plugin Js -->
    <script src="bundles/countTo.bundle.js"></script>
    <!--ChartJS Plugin Js-->
    <script src="bundles/chartscripts.bundle.js"></script>
    <!-- royalslider Plugin Js-->
    <script src="plugins/royalslider/jquery.royalslider.min.js" class="rs-file"></script>
    <!-- ChartC3 Js -->
    <script src="bundles/cs.bundles.js"></script>

    <script>

        $(function () {

            $('.counto').countTo();
  
        });
        //行事曆
        //$(".calendar").on('click', function (event) {
        //    window.location.href = 'calendar.html';
        //});

        //本月運動時間卡片
        $(".exerciserank").on('click', function (event) {
            window.location.href = '<%= Url.Action("ExerciseBillboard","ConsoleHome") %>';
        });
        //我的功課卡片
        $(".calendar-todolist").on('click', function (event) {
            window.location.href = 'calendar-todolist.html';
        });
        //我的業績
        $(".achivement").on('click', function (event) {
            window.location.href = 'achivement-self.html';
        });

        function showContractList(viewModel, alertCount) {
            if (alertCount == 0)
                return;
            viewModel.scrollToView = false;
            if (alertCount && alertCount > 300) {
                swal({
                    title: "繼續載入?",
                    text: "讀取大量資料，將影響系統效能!",
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "確定, 不後悔",
                    cancelButtonText: "不, 點錯了",
                    closeOnConfirm: true,
                    closeOnCancel: true,
                }, function (isConfirm) {
                    if (isConfirm) {
                        showLoading();
                        $('').launchDownload('<%= Url.Action("ShowContractList","ContractConsole") %>', viewModel);
                    } else {
                    }
                });
            } else {
                showLoading();
                $('').launchDownload('<%= Url.Action("ShowContractList","ContractConsole") %>', viewModel);
            }
        }

    </script>
</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<LessonTime> _lessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

        IQueryable<LessonTime> items = models.GetTable<LessonTime>().Where(l => l.AttendingCoach == _model.UID);
        //.FilterByUserRoleScope(models, _model);
        ViewBag.LessonTimeItems = items;

        _lessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());

        //items = models.GetTable<LessonTime>().FilterByUserRoleScope(models, _model);
    }

</script>
