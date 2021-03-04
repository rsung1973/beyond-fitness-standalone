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
        dayClick: function (date, allDay, jsEvent, view) {
            //bookingByCoach(date.format('YYYY-MM-DD')+' 08:00');
        },
        eventClick: function (calEvent) {
            if(calEvent.id=='course' || calEvent.id=='self' || calEvent.id=='trial' || calEvent.id=='home' || calEvent.id=='coach') {
                showLoading();
                $.post('<%= Url.Action("LearnerRecentLessons","ClassFacet") %>', { 'uid': <%= _model.UID %>, 'lessonID': calEvent.lessonID }, function (data) {
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
    RegisterLesson _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _model = (RegisterLesson)this.Model;
        ViewBag.LessonDate = DateTime.Today;
        ViewBag.EventsUrl = Url.Action("VipEvents", "Lessons", new { id = _model.UID, learner = false });

    }

</script>
