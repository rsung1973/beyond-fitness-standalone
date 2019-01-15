<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_model != null)
    { %>
<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12 no-padding">
    <!-- Widget ID (each widget will need unique ID)-->
    <%  if (ViewBag.LearnerAttendance != true)
        { %>
    <div class="jarviswidget" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-colorbutton="false" data-widget-fullscreenbutton="false">
        <!-- widget options:
                                                                                usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
                                                                                
                                                                                data-widget-colorbutton="false" 
                                                                                data-widget-editbutton="false"
                                                                                data-widget-togglebutton="false"
                                                                                data-widget-deletebutton="false"
                                                                                data-widget-fullscreenbutton="false"
                                                                                data-widget-custombutton="false"
                                                                                data-widget-collapsed="true" 
                                                                                data-widget-sortable="false"
                                                                                
                                                                            -->
        <header>
            <span class="widget-icon"><i class="fa fa-edit"></i></span>
            <h2>訓練強度 </h2>
        </header>

        <!-- widget div-->
        <div>

            <!-- widget content -->
            <div class="widget-body">
                <%  Html.RenderPartial("~/Views/Activity/BasicFitnessAssessmentGroup.ascx", _model); %>
            </div>
            <!-- end widget content -->

        </div>
        <!-- end widget div -->

    </div>
    <%  } %>
    <!-- end widget -->
    <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
        <!-- Widget ID (each widget will need unique ID)-->
        <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentTrend.ascx", _model); %>
        <!-- end widget -->
    </div>
    <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
        <!-- Widget ID (each widget will need unique ID)-->
        <div id="<%= "_" + _model.AssessmentID + "_18" %>">
            <%  Html.RenderAction("FitnessAssessmentGroup", "Activity", new { assessmentID = _model.AssessmentID, itemID = 18, viewIndex = ViewBag.Index, learnerAttendance = ViewBag.LearnerAttendance, showOnly = ViewBag.ShowOnly }); %>
        </div>
        <!-- end widget -->

        <!-- Widget ID (each widget will need unique ID)-->
        <div id="<%= "_" + _model.AssessmentID + "_19" %>">
            <%  Html.RenderAction("FitnessAssessmentGroup", "Activity", new { assessmentID = _model.AssessmentID, itemID = 19, viewIndex = ViewBag.Index, learnerAttendance = ViewBag.LearnerAttendance, showOnly = ViewBag.ShowOnly }); %>
        </div>
        <!-- end widget -->
        <!-- Widget ID (each widget will need unique ID)-->
        <div id="<%= "_" + _model.AssessmentID + "_20" %>">
            <%  Html.RenderAction("FitnessAssessmentGroup", "Activity", new { assessmentID = _model.AssessmentID, itemID = 20, viewIndex = ViewBag.Index, learnerAttendance = ViewBag.LearnerAttendance, showOnly = ViewBag.ShowOnly }); %>
        </div>

        <div id="<%= "_" + _model.AssessmentID + "_21" %>">
            <%  Html.RenderAction("FitnessAssessmentGroup", "Activity", new { assessmentID = _model.AssessmentID, itemID = 21, viewIndex = ViewBag.Index, learnerAttendance = ViewBag.LearnerAttendance, showOnly = ViewBag.ShowOnly }); %>
        </div>
        <!-- end widget -->
    </div>
</div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        if (this.Model != null && this.Model is LessonFitnessAssessment)
        {
            _model = (LessonFitnessAssessment)this.Model;
        }
    }

</script>
