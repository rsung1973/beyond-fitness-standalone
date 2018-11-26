<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  if (_model.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
    {
        Html.RenderPartial("~/Views/ConsoleEvent/EventModal/CoachPI.ascx", _model);
    }
    else if (_model.GroupingLesson.RegisterLesson.Count > 1)
    {
        Html.RenderPartial("~/Views/ConsoleEvent/EventModal/OtherLesson.ascx", _model);
    }
    else
    {
        Html.RenderPartial("~/Views/ConsoleEvent/EventModal/LearnerLesson.ascx", _model);
    }
    %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    CalendarEventQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
    }


</script>
