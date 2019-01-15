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
        <h2>著重方向 </h2>
        <%  if (ViewBag.ShowOnly != true)
            { %>
        <div class="widget-toolbar">
            <a class="btn btn-primary" onclick="editAssessmentItem(<%= _model.AssessmentID %>);"><i class="fa fa-fw fa-plus"></i>新增評量指數</a>
        </div>
        <%  } %>
    </header>

    <!-- widget div-->
    <div>

        <!-- widget content -->
        <div class="widget-body bg-color-darken txt-color-white no-padding">
            <div class="row">
                <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentTrendPie.ascx", _model); %>
                <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentStrengthPie.ascx", _model); %>
            </div>
            <%  if (ViewBag.LearnerAttendance != true)
                { %>
            <div class="row">
                <div class="col-sm-12 col-md-12 col-lg-12" id="<%= _id %>">
                    <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentTrendList.ascx", _model); %>
                </div>
            </div>
            <%  } %>
        </div>
        <!-- end widget content -->

    </div>
    <!-- end widget div -->

</div>
<%  Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;
    String _id;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
        _id = "trendList" + _model.AssessmentID;
    }

</script>
