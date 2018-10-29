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
    <link href="plugins/royalslider/royalslider.css" rel="stylesheet">
    <link href="plugins/royalslider/skins/default/rs-default.css" rel="stylesheet">
    <link href="css/royalslider.css" rel="stylesheet">
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
                                                    int offsetDays = (int)DateTime.Today.DayOfWeek;
                                                    offsetDays = offsetDays == 0 ? 6 : offsetDays - 1;
                                                    DateTime weekStart = DateTime.Today.AddDays(-offsetDays);
                                                    DateTime weekday = weekStart;

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
                                                <li class="<%= weekday==DateTime.Today ? "col-pink" : null %>">
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
                                                <li class="col-sm-6 col-6 calendar-todolist">
                                                    <div class="body">
                                                        <i class="zmdi livicon-evo" data-options="name: pencil.svg; size: 40px; style: original; strokeWidth:2px;"></i>
                                                        <h4><%= _editableLessons
                                                                    .Where(l => l.ClassTime >= weekStart && l.ClassTime < weekStart.AddDays(7))
                                                                    .Where(l=>l.LessonAttendance==null).Count() %></h4>
                                                        <span>本週編輯中</span>
                                                    </div>
                                                </li>
                                                <li class="col-sm-6 col-6 calendar-todolist">
                                                    <div class="body">
                                                        <i class="zmdi livicon-evo" data-options="name: remove.svg; size: 40px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                        <h4><%= _learnerLessons.Where(l => l.ClassTime >= monthStart && l.ClassTime < monthStart.AddMonths(1))
                                                                    .GetLearnerUncheckedLessons().Count() %></h4>
                                                        <span>本月未打卡</span>
                                                    </div>
                                                </li>
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
                        <div class="body">
                            <div class="row">
                                <div class="col-8">
                                    <h5 class="m-t-0">即將過期</h5>
                                    <%  var effectiveItems = models.PromptEffectiveContract().FilterByUserRoleScope(models, _model);
                                        var contractItems = models.PromptExpiringContract().FilterByUserRoleScope(models, _model);
                                        var expiringItems = contractItems.Where(c => c.Expiration >= DateTime.Today);
                                        var expiredItems = contractItems.FilterByExpired(models); %>
                                    <p class="text-small">
                                        已過期：<a href="javascript:void(0);"><%= expiredItems.Count() %></a><br />
                                        生效中：<%= effectiveItems.Count() %>
                                    </p>
                                </div>
                                <div class="col-4 text-right">
                                    <a href="javascript:void(0);">
                                        <h2 class="col-red"><%= expiringItems.Count() %></h2>
                                    </a>
                                    <small class="info">合約</small>
                                </div>
                            </div>
                        </div>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12 contract">
                        <div class="body">
                            <div class="row">
                                <div class="col-8">
                                    <%  
                                        var editingItems = models.GetContractInEditingByAgent(_model);
                                        var toConfirmItems = models.GetContractToConfirmByAgent(_model);
                                        var toSignItems = models.GetContractToSignByAgent(_model);
                                    %>
                                    <h5 class="m-t-0">賀成交</h5>
                                    <p class="text-small">
                                        編輯中：<a href="javascript:void(0);"><%= editingItems.Count() %></a>
                                        <br />
                                        待簽名：<a href="javascript:void(0);"><%= toSignItems.Count() %></a>
                                        <br />
                                        待審核：<a href="javascript:void(0);"><%= toConfirmItems.Count() %></a>
                                    </p>
                                </div>
                                <div class="col-4 text-right">
                                    <a href="javascript:void(0);">
                                        <h2><%= models.PromptEffectiveContract()
                                                    .Where(c=>c.EffectiveDate>=monthStart && c.EffectiveDate<monthStart.AddMonths(1))
                                                    .FilterByUserRoleScope(models,_model).Count() %></h2>
                                    </a>
                                    <small class="info">本月</small>
                                </div>
                            </div>
                        </div>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12 contract">
                        <div class="body">
                            <div class="row">
                                <div class="col-8">
                                    <%  var revisions = models.GetApplyingAmendmentByAgent(_model);
                                        var toConfirmRevisions = models.GetAmendmentToAllowByAgent(_model);
                                        var toSignRevisions = models.GetAmendmentToSignByAgent(_model);
                                    %>
                                    <h5 class="m-t-0">服務申請</h5>
                                    <p class="text-small">
                                        編輯中：0<br />
                                        待簽名：<a href="javascript:void(0);"><%= toSignRevisions.Count() %></a><br />
                                        待審核：<a href="javascript:void(0);"><%= toConfirmRevisions.Count() %></a>
                                    </p>
                                </div>
                                <div class="col-4 text-right">
                                    <a href="javascript:void(0);">
                                        <h2><%= models.PromptEffectiveRevision(monthStart,monthStart.AddMonths(1))
                                                    .FilterByUserRoleScope(models,_model).Count() %></h2>
                                    </a>
                                    <small class="info">本月</small>
                                </div>
                            </div>
                        </div>
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
                                    <h5 class="m-t-0">本日收付</h5>
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
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutLearners.ascx", _model);
            }   %>        <!--我的分店業績卡片-->        <%  if (_model.IsOfficer() || _model.IsManager() || _model.IsViceManager())
            {
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutAchievement.ascx", _model);
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
                Html.RenderPartial("~/Views/ConsoleHome/Module/AboutArticle.ascx", _model);
            }           %>    </section>
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- countTo Plugin Js -->
    <script src="bundles/countTo.bundle.js"></script>
    <!--ChartJS Plugin Js-->
    <script src="bundles/chartscripts.bundle.js"></script>
    <!-- royalslider Plugin Js-->
    <script src="plugins/royalslider/jquery.royalslider.min.js" class="rs-file"></script>

    <script>

        $(function () {

            $('.counto').countTo();
  
        });
        //行事曆
        $(".calendar").on('click', function (event) {
            window.location.href = 'calendar.html';
        });

        //本月運動時間卡片
        $(".exerciserank").on('click', function (event) {
            window.location.href = '<%= Url.Action("ExerciseBillboard","ConsoleHome") %>';
        });
        //我的功課卡片
        $(".calendar-todolist").on('click', function (event) {
            window.location.href = 'calendar-todolist.html';
        });
        //我的合約與收款
        $(".contract").on('click', function (event) {
            window.location.href = 'contract&payment.html';
        });
        //我的業績
        $(".achivement").on('click', function (event) {
            window.location.href = 'achivement-self.html';
        });
    </script>
</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<LessonTime> _lessons;
    IQueryable<LessonTime> _editableLessons;
    IQueryable<LessonTime> _learnerLessons;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        var items = models.GetTable<LessonTime>().Where(l => l.AttendingCoach == _model.UID);
        _lessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());


        items = models.GetTable<LessonTime>().FilterByUserRoleScope(models, _model);
        _editableLessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());

        _learnerLessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1));
    }

</script>
