<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

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
        <span class="widget-icon"><i class="fa fa-heartbeat"></i></span>
        <h2><%= _model.FitnessAssessmentItem.ItemName %>-<%= String.Format("{0:.}",_model.TotalAssessment) %>分鐘(
            <%  var totalAssessment = _model.LessonFitnessAssessment.LessonFitnessAssessmentReport.Where(r => r.FitnessAssessmentItem.GroupID == 3).Sum(r => r.TotalAssessment);
                if (!totalAssessment.HasValue || totalAssessment <= 0)
                {
                    totalAssessment = 1;
                }
                Writer.Write(Math.Round((_model.TotalAssessment ?? 0) / (totalAssessment ?? 1) * 100)); %>
             %) </h2>
    </header>

    <!-- widget div-->
    <div>

        <!-- widget content -->
        <div class="widget-body bg-color-darken txt-color-white no-padding">
            <div class="row">
                <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentGroupPie.ascx", _model); %>
            </div>
            <%  if (ViewBag.LearnerAttendance != true)
                { %>
            <div class="row">
                <div class="col-sm-12 col-md-12 col-lg-12" id="<%= "group_" + _model.AssessmentID + "_" + _model.ItemID %>">
                    <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentGroupList.ascx", _model); %>
                </div>
            </div>
            <%  } %>
        </div>
        <!-- end widget content -->

    </div>
    <!-- end widget div -->

</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessmentReport _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessmentReport)this.Model;
    }

</script>
