<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

    <div id="placeholder" class="chart-large has-legend-unique"></div>

<script>

    $(function () {

        $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyTrendPie") %>', { 'lessonID': <%= _model.LessonID %>,'isLearner': <%= ViewBag.Learner==true ? "true" : "false" %> }, function (data) {
            drawPie($("#placeholder"),data);
        });
    });


</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
    }

</script>
