<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">
    <%  foreach (var item in _model.LessonTime.TrainingPlan)
    {
        Html.RenderPartial("~/Views/Lessons/ViewTrainingExecutionItem.ascx", item.TrainingExecution);
    }  %>
</div>

    <script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTimeExpansion _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTimeExpansion)this.Model;
    }





</script>
