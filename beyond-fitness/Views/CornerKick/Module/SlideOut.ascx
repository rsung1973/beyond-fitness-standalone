<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
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

<ul id="slide-out" class="side-nav">
    <li>
        <div class="user-view">
            <div class="background">
                <img src="images/carousel/side-background.jpg"></div>
            <a href="javascript:gtag('event', '我的設定', {  'event_category': '大頭貼點擊',  'event_label': '漢堡選單'});window.location.href='<%= Url.Action("Settings","CornerKick",new { learnerSettings = true }) %>';">
                <%  Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", _model); %></a> 
            <a href="javascript:gtag('event', '我的設定', {  'event_category': '大頭貼點擊',  'event_label': '漢堡選單'});window.location.href='<%= Url.Action("Settings","CornerKick",new { learnerSettings = true }) %>';">
                <span class="white-text name">
                    <%= _model.UserName ?? _model.RealName %>
                    <%  Html.RenderPartial("~/Views/CornerKick/Module/LessonCount.ascx", _model); %>
                </span>
            </a> 
            <a href="javascript:gtag('event', '登出', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("Logout","CornerKick") %>';"><span class="white-text email">登出</span></a>
        </div>
    </li>
    <li><a href="javascript:gtag('event', '我的行事曆', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("LearnerCalendar","CornerKick") %>';">我的行事曆</a></li>
    <%  
        TimelineEvent eventItem = _model.CheckLessonAttendanceEvent(models);
        if (eventItem != null)
            _items.Add(eventItem);
        eventItem = _model.CheckDailyQuestionEvent(models);
        if (eventItem != null)
            _items.Add(eventItem);
        eventItem = _model.CheckUserGuideEvent(models);
        if (eventItem != null)
            _items.Add(eventItem);
        eventItem = _model.CheckPromptContractEvent(models);
        int contractCount = 0;
        if (eventItem != null)
        {
            _items.Add(eventItem);
            contractCount = ((PromptContractEvent)eventItem).ContractList.Count() - 1;
        }
        eventItem = _model.CheckExercisePurposeEvent(models);
        if (eventItem != null)
            _items.Add(eventItem);
        eventItem = _model.CheckAccomplishedExercisePurposeEvent(models);
        if (eventItem != null)
            _items.Add(eventItem);
         %>
    <li><a href="javascript:gtag('event', '我的通知', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("LearnerNotice", "CornerKick") %>';">我的通知 
        <%  if (_items.Count > 0)
            { %>
        <span class="btn-floating waves-effect waves-light btn-notice red"><%= _items.Count+contractCount %></span>
        <%  } %>
        </a></li>
    <li><a href="javascript:gtag('event', '我的目標', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("LearnerTrainingGoal", "CornerKick") %>';">我的目標</a></li>
    <li><a href="javascript:gtag('event', '我的設定', {'event_category': '連結點擊','event_label': '漢堡選單'});window.location.href = '<%= Url.Action("Settings","CornerKick",new { learnerSettings = true }) %>';">我的設定</a></li>
    <li><a href="javascript:gtag('event', '兌換我的裝備', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("CheckBonusPoint", "CornerKick") %>';">兌換我的裝備</a></li>
    <li><a href="javascript:gtag('event', '新手上路', {  'event_category': '連結點擊',  'event_label': '漢堡選單'});window.location.href = '<%= Url.Action("StartNavigation","CornerKick") %>';">新手上路</a></li>
    <!--
                        <li><div class="divider"></div></li>
                           <li><a class="subheader">Subheader</a></li>
                           <li><a class="waves-effect" href="#!">Third Link With Waves</a></li>
                        -->
</ul>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    List<TimelineEvent> _items;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        _items = (List<TimelineEvent>)ViewBag.UserNotice;

    }

</script>
