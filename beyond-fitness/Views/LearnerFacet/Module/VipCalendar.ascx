<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  Html.RenderPartial("~/Views/Shared/LessonsFullCalendar.ascx"); %>

<script>
    calendarEventHandler = {
        dayClick: function (calEvent) {
            showLoading();
            $.post('<%= Url.Action("CreateUserEvent","LearnerFacet",new { UID = _model.UID }) %>', {
                'StartDate': calEvent.format('YYYY-MM-DD'),
                'EndDate': calEvent.format('YYYY-MM-DD')
            }, function (data) {
                $(data).appendTo($('body'));
                hideLoading();
            });
        },
        eventClick: function (calEvent) {
            var event = event || window.event;
            if (calEvent.id == 'my') {
                showLoading();
                $.post('<%= Url.Action("CreateUserEvent","LearnerFacet",new { UID = _model.UID }) %>', { 'EventID': calEvent.lessonID }, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
            } else {
                showLoading(true);
                $.post('<%= Url.Action("LearnerLesson","LearnerFacet") %>', { 'lessonID': calEvent.lessonID, 'attendance': true }, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
            }
        }
    };
</script>

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
        ViewBag.LessonDate = DateTime.Today;
        ViewBag.EventsUrl = Url.Action("VipEvents", "Lessons", new { id = _model.UID, learner = true });

    }

</script>
