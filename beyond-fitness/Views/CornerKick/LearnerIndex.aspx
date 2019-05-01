<%@ Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Register Src="~/Views/CornerKick/Module/UserGuideNotice.ascx" TagPrefix="uc1" TagName="UserGuideNotice" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>BEYOND FITNESS - 卡片總覽</title>
    <!-- CSS  -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!-- materialize  -->
    <link href="css/materialize.css" type="text/css" rel="stylesheet" />
    <!-- livIconsevo  -->
    <link href='css/livIconsevo/LivIconsEvo.css' rel='stylesheet' type='text/css'>
    <link href="css/livIconsevo/LivIconsEvo.css" rel="stylesheet" type="text/css">
    <!-- scrollup-master  -->
    <link href="css/scrollup-master/themes/image.css?1.1" rel="stylesheet" id="scrollUpTheme">    <!-- royalslider -->
    <link href="css/royalslider/royalslider.css" rel="stylesheet" class="rs-file">
    <link href="css/preview-assets/reset.css" rel="stylesheet">
    <link href="css/royalslider/skins/default/rs-default.css" rel="stylesheet" class="rs-file">
    <!-- STYLE 要放最下面  -->
    <link href="css/style.css?1.2" type="text/css" rel="stylesheet" media="screen,projection" />
              <link rel="icon" href="favicons/favicon_96x96.png">
      <!-- Specifying a Webpage Icon for Web Clip -->
      <link rel="apple-touch-icon-precomposed" href="favicons/favicon_57x57.png">
      <link rel="apple-touch-icon-precomposed" sizes="72x72" href="favicons/favicon_72x72.png">
      <link rel="apple-touch-icon-precomposed" sizes="114x114" href="favicons/favicon_114x114.png">
      <link rel="apple-touch-icon-precomposed" sizes="144x144" href="favicons/favicon_144x144.png">
      <link rel="apple-touch-icon-precomposed" sizes="180x180" href="favicons/favicon_180x180.png">       

    <script src="js/libs/jquery-2.2.4.min.js"></script>
    <script src="js/materialize.js"></script>
    <script src="js/init.js"></script>
    <!-- LivIconsEvo  -->
    <script src="js/plugin/LivIconsEvo/tools/snap.svg-min.js"></script>
    <script src="js/plugin/LivIconsEvo/tools/TweenMax.min.js"></script>
    <script src="js/plugin/LivIconsEvo/tools/DrawSVGPlugin.min.js"></script>
    <script src="js/plugin/LivIconsEvo/tools/MorphSVGPlugin.min.js"></script>
    <script src="js/plugin/LivIconsEvo/tools/verge.min.js"></script>
    <script src="js/plugin/LivIconsEvo/LivIconsEvo.Tools.js"></script>
    <script src="js/plugin/LivIconsEvo/LivIconsEvo.defaults.js"></script>
    <script src="js/plugin/LivIconsEvo/LivIconsEvo.js"></script>
    <!-- scrollup-master  -->
    <script src="js/plugin/scrollup-master/jquery.scrollUp.min.js"></script>
<%--     <!--counup plugin-->
    <script src="js/plugin/countup/countUp.min.js"></script>--%>
   <!--countTo plugin--> 
    <script src="js/plugin/jquery-countto/jquery.countTo.js"></script> 
    <!--chartjs plugin-->
    <script src="js/plugin/chartjs/chart.min.js"></script>
    <!-- royalslider -->
    <script src="js/plugin/royalslider/jquery.royalslider.min.js" class="rs-file"></script>
    <script>
        var $global = {
            'onReady': [],
            call: function (name) {
                var fn = $global[name];
                if (typeof fn === 'function') {
                    fn();
                }
            },
        };
    </script>
</head>
<body>
    <div class="wrapper">
        <div class="wrapper-fixed">
            <!--Header -->
            <nav class="white" role="navigation">
                <div class="nav-wrapper container">
                    <a id="logo-container" href="#" class="brand-logo center">
                        <img src="images/Nav-logo-black.png" title="BEYOND FITNESS" alt="BEYOND FITNESS"></a>
                    <ul class="right hide-on-med-and-down">
                        <li>
                            <a href="javascript:gtag('event', '我的行事曆', {  'event_category': '連結點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("LearnerCalendar","CornerKick") %>';">
                                <i class="livicon-evo" data-options="name: calendar.svg; size: 40px; style: lines; strokeColor:#0f244a; strokeWidth:2px; autoPlay:true"></i>
                            </a>
                        </li>
                    </ul>
                    <!-- 側邊選單 -->
                    <%  List<TimelineEvent> events = new List<TimelineEvent>();
                        ViewBag.UserNotice = events;
                        Html.RenderPartial("~/Views/CornerKick/Module/SlideOut.ascx", _model); %>
                    <a href="<%= Url.Action("LearnerCalendar","CornerKick") %>" data-activates="slide-out" class="button-collapse">
                        <i class="livicon-evo" data-options="name: morph-menu-collapse.svg; size: 40px; style: lines; strokeColor:#0f244a; strokeWidth:2px; autoPlay:true"></i>
                    </a>
                    <!-- // End of 側邊選單 -->
                </div>
            </nav>
            <!-- // End of Header -->
            <!-- main -->
            <div class="main">
                <div class="container">
                    <!-- 訊息通知 -->
                    <%   if (events.Count > 0)
                        {
                            var count = events.Count;   %>
                    <div class="notice-block">
                        <ul id="dropdown1" class="dropdown-content notice-dropdown">
                            <% TimelineEvent item = events.Where(v => v is LessonAttendanceCheckEvent).FirstOrDefault();
                                if (item != null)
                                {    %>
                            <li><a href="javascript:gtag('event', '上課打卡', {  'event_category': '下拉式選單點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("LearnerToCheckAttendance","CornerKick") %>';"><%= _model.UserProfileExtension.Gender=="F" ? "親愛的" : "兄弟" %>，還有 <%= ((LessonAttendanceCheckEvent)item).CheckCount %> 堂課沒打卡 <i class="material-icons right">arrow_forward</i></a></li>
                            <% }
                                item = events.Where(v => v is DailyQuestionEvent).FirstOrDefault();
                                if (item != null)
                                { %>
                            <li><a href="javascript:gtag('event', '運動小學堂', {  'event_category': '下拉式選單點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("AnswerDailyQuestion","CornerKick") %>';"><%= _model.UserProfileExtension.Gender=="F" ? "親愛的" : "兄弟" %>，來挑戰運動小學堂 <i class="material-icons right">arrow_forward</i></a></li>
                            <% }
                                item = events.Where(v => v is UserGuideEvent).FirstOrDefault();
                                if (item != null)
                                {
                                    var eventItem = ((UserGuideEvent)item).GuideEventList.Where(v => v.SystemEventID == global::ASP.views_cornerkick_module_userguidenotice_ascx.__EVENT_ID).FirstOrDefault();
                                    if(eventItem!=null)
                                    { 
                                    %>
                            <li><a href="javascript:gtag('event', '新手上路', {  'event_category': '下拉式選單點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action(eventItem.SystemEventBulletin.ActionName,eventItem.SystemEventBulletin.ControllerName,new { keyID =  eventItem.EventID.EncryptKey() }) %>';"><%= _model.UserProfileExtension.Gender=="F" ? "親愛的" : "兄弟" %>，跟著 Beyond 走，新手導航去 <i class="material-icons right">arrow_forward</i></a> </li>
                            <%      }
                                }
                                item = events.Where(v => v is PersonalExercisePurposeEvent && !(v is PersonalExercisePurposeAccomplishedEvent)).FirstOrDefault();
                                if (item != null)
                                {
                                    %>
                                <li><a href="javascript:gtag('event', '我的目標', {  'event_category': '下拉式選單點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("LearnerToCheckTrainingGoal","CornerKick") %>';"><%= _model.UserProfileExtension.Gender=="F" ? "親愛的" : "兄弟" %>，你教練有新的想法喔，點擊詳閱說明書 <i class="material-icons right">arrow_forward</i></a></li>                            
                            <%      
                                }
                                item = events.Where(v => v is PersonalExercisePurposeAccomplishedEvent).FirstOrDefault();
                                if (item != null)
                                {
                                    %>
                                <li><a href="javascript:gtag('event', '我的目標', {  'event_category': '下拉式選單點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("LearnerTrainingGoal","CornerKick") %>';"><%= _model.UserProfileExtension.Gender=="F" ? "親愛的" : "兄弟" %>，恭喜成就達成，來回顧血淚史吧!! <i class="material-icons right">arrow_forward</i></a></li>                            
                            <%      
                                }

                                item = events.Where(v => v is PromptContractEvent).FirstOrDefault();
                                if (item != null)
                                {
                                    foreach (var c in ((PromptContractEvent)item).ContractList)
                                    {
                                        count++;%>
                            <li><a href="#"><%= _model.UserProfileExtension.Gender == "F" ? "親愛的" : "兄弟" %>，合約於 <%= $"{c.Expiration():yyyy/MM/dd}" %> 到期 <i class="livicon-evo right" data-options="name: bell.svg; size: 30px; style: lines; strokeColor:#0f244a; strokeWidth:2px; autoPlay:true"></i></a></li>
                            <%      }
                                    count--;
                                } %>
                        </ul>
                        <ul class="hide-on-med-and-down">
                            <!-- Dropdown Trigger -->
                            <li><a class="dropdown-button" data-activates="dropdown1"><span class="btn-floating waves-effect waves-light btn-notice red"><%= count %></span>提醒通知 <i class="material-icons right">keyboard_arrow_down</i> </a></li>
                        </ul>
                    </div>
                    <%   } %>
                    <!-- // End of 活動通知 -->
                    <!-- 累計運動時間 -->
                    <div class="notice-block">
                        <ul id="dropdown2" class="dropdown-content notice-dropdown ">
                        </ul>
                        <ul class="hide-on-med-and-down notice-non">
                            <!-- Dropdown Trigger -->
                            <%  
                                var endDate = DateTime.Today.AddDays(1);
                                var startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                                var totalMinutes = _model.TotalLessonMinutes(models, startDate, endDate);
                            %>
                            <li><a class="dropdown-button" data-activates="dropdown2">本月：<span class="f-green countuptime" data-to="<%= totalMinutes %>"><%= totalMinutes %></span>分鐘（<span class="f-green countuptime" data-to="<%= totalMinutes/60 %>"><%= totalMinutes/60 %></span>小時:<span class="f-green countuptime" data-to="<%= totalMinutes % 60 %>"><%= totalMinutes % 60 %></span>分鐘）</a></li>
                        </ul>
                    </div>
                    <!-- // End of 活動通知 -->
                    <!-- 體能分析圖 -->
                    <%  Html.RenderPartial("~/Views/CornerKick/Module/BodyFitness.ascx", _model); %>
                    <!-- // End of 體能分析圖 -->
                    <!-- 個人目標 -->
                    <div class="goal-block" onclick="javascript:gtag('event', '我的目標', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});window.location.assign('<%= Url.Action("LearnerTrainingGoal","CornerKick") %>');">
                        <h3>我的目標</h3>
                        <div class="parallax-container">
                            <div class="section no-pad-bot">
                                <div class="container">
                                    <div class="text-area">
                                        <h4>週期性目標<br />
                                            <%= _model.PersonalExercisePurpose!=null
                                                    && !String.IsNullOrEmpty(_model.PersonalExercisePurpose.Purpose)? _model.PersonalExercisePurpose.Purpose+"期" : null %></h4>
                                    </div>
                                </div>
                            </div>
                            <div class="parallax">
                                <%  if (_model.UserProfileExtension.Gender == "F")
                                    { %>
                                <img src="images/carousel/goal-background-girl.jpg" />
                            <%  }
                                else
                                { %>
                                <img src="images/carousel/goal-background-boy.jpg"/>
                            <%  } %>
                            </div>
                        </div>
                    </div>
                    <!-- // End of 個人目標 -->
                    <!-- 課表內容 Slider -->
                    <%  Html.RenderPartial("~/Views/CornerKick/Module/RecentLessons.ascx", _model); %>
                    <!-- // End of 課表內容 Slider -->
                    <!-- 專業文章 Slider -->
                    <%  Html.RenderPartial("~/Views/CornerKick/Module/RecentArticles.ascx", _model); %>
                    <!-- // End of 專業文章 Slider -->
                    <!-- 點數兌換 -->
                    <%  Html.RenderPartial("~/Views/CornerKick/Module/PromptDailyQuestion.ascx", _model); %>
                    <!-- // End of 點數兌換 -->
                </div>
            </div>
            <!-- // End of main -->
        </div>
        <!--// End of wrapper-fixed-->
        <!-- Footer -->
        <!--
            <footer class="page-footer teal">
               <div class="footer-copyright">
                  <div class="container"><a class="brown-text text-lighten-3" href="#">BEYOND FITNESS</a> </div>
               </div>
            </footer>
            -->
        <!-- // End of Footer -->
    </div>
    <!--// End of wrapper-->
    <!--  Scripts-->
    <script>
        $(function () {
            $.scrollUp({
                animation: 'fade',
                scrollImg: {
                    active: true,
                    type: 'background',
                    src: '../images/top.png'
                }
            });
            //SideNavOpen
            $('.button-collapse').sideNav({
                onOpen: function (el) {
                    $('.dropdown-button').dropdown('close');
                }
            });
            //countup
            //$('.countuptime').each(function () {
            //    // no need to specify options unless they differ from the defaults
            //    var target = this;
            //    var endVal = parseInt($(this).attr('data-endVal'));
            //    theAnimation = new countUp(target, 0, endVal, 0, 2.5);
            //    theAnimation.start();
            //});
            $('.countuptime').countTo();

        });


    </script>
</body>
</html>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
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

        var item = models.GetTable<UserEvent>().Where(v => v.UID == _model.UID && v.SystemEventID == 2).FirstOrDefault();
        if (item != null)
        {
            Response.Redirect(Url.Action("StartNavigation", "CornerKick", new UserEventViewModel { CreateNew = true, KeyID = item.EventID.EncryptKey() }));
        }
    }

</script>
