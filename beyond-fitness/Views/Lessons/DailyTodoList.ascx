<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="widget-body bg-color-darken txt-color-white no-padding smart-form">
    <!-- content goes here -->
    <%  if (!_profile.IsFreeAgent())
        {
            Html.RenderPartial("~/Views/BulletinBoard/LearnerBirthdayNotification.ascx");
            Html.RenderPartial("~/Views/BulletinBoard/LearnerIncomingQuestionnaireNotification.ascx");
            Html.RenderPartial("~/Views/BulletinBoard/LearnerQuestionnaireNotification.ascx");
            Html.RenderPartial("~/Views/BulletinBoard/LearnerRemarkNotification.ascx");
        } %>
</div>

<script>
    function showAttendee(lessonDate, hour) {
        pageParam.hour = hour;
        $('#loading').css('display', 'table');
        $('#attendeeList').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingMembers") %>', { 'lessonDate': lessonDate, 'hour': hour }, function () {
            $('#loading').css('display', 'none');
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _profile = Context.GetUser();
    }

</script>
