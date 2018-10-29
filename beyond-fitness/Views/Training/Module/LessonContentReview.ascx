<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">
    <%  Html.RenderPartial("~/Views/Training/Module/CurrentLessonContentPie.ascx", _item.TrainingPlan.Select(p => p.TrainingExecution).FirstOrDefault()); %>
    <%  Html.RenderPartial("~/Views/Training/Module/LearnerLessonContentPie.ascx", _model); %>
</div>
<div class="row">
    <%  Html.RenderPartial("~/Views/Training/Module/LearnerLessonContentGraph.ascx", _model); %>
</div>
<div class="row">
    <%  Html.RenderPartial("~/Views/Training/Module/LearnerExerciseGraph.ascx", _model); %>
</div>
<div class="row">
    <%  Html.RenderPartial("~/Views/Training/Module/LearnerTrainingAidsPie.ascx", _model); %>
    <div class="col-xs-12 col-sm-6 col-md-6 text-center">
        <%  Html.RenderPartial("~/Views/Training/Module/LearnerTrainingAidsList.ascx", _model); %>
    </div>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    LessonTime _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
    }

</script>
