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

<%  
    foreach (var item in _model.LessonTime.TrainingPlan)
    {
        Html.RenderPartial("~/Views/Lessons/TrainingExecutionItem.ascx", item.TrainingExecution);
    }  %>
<div class="col-sm-12" id="trainingPlan">
    <hr class="simple">
</div>
<div class="row">
    <div class="col-xs-12 col-sm-12">
        <a onclick="addTrainingPlan()"><i class="fa fa-plus-circle text-success fa-2x"></i>請點選 <i class="fa fa-plus-circle text-success"></i>新增一組內容</a>
    </div>
</div>

<script>

function addTrainingPlan() {
    $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/TrainingExecutionItem") %>', {}, function (data) {
        $('#trainingPlan').before($(data));
    })
}

</script>

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
