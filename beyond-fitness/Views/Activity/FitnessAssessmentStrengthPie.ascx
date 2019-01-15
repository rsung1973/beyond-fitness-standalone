<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-sm-12 col-md-12 col-lg-12">
    <div id="<%= _pieID %>" class="chart-large has-legend-unique"></div>
</div>

<%  if (_model.LessonFitnessAssessmentReport.Count(r => r.FitnessAssessmentItem.GroupID == 4 || r.FitnessAssessmentItem.GroupID == 5) > 0)
    { %>
<script>
    $(function(){
        drawStrengthPie(<%= _model.AssessmentID %>,'<%= ((long?)ViewBag.Index).ToString() %>');
    });
</script>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;
    String _pieID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
        _pieID = "strength-pie" + _model.AssessmentID + ((long?)ViewBag.Index).ToString();
    }

</script>
