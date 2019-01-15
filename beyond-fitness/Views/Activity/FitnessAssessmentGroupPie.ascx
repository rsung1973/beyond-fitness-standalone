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

<%  if (models.GetTable<LessonFitnessAssessmentReport>().Count(r => 
        r.FitnessAssessmentItem.FitnessAssessmentGroup.MajorID == _model.ItemID) > 0)
    { %>
<script>
    $(function(){
        drawGroupPie({ 'assessmentID':<%= _model.AssessmentID %>,'itemID':<%= _model.ItemID %>,'index':'<%= ((long?)ViewBag.Index).ToString() %>' });
    });
</script>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessmentReport _model;
    String _pieID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessmentReport)this.Model;
        _pieID = "group-pie" + _model.AssessmentID + "-" + _model.ItemID+ ((long?)ViewBag.Index).ToString();
    }

</script>
