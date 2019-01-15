<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

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
            <h2>填寫身體健康指數 </h2>
        </header>

        <!-- widget div-->
        <div>

            <!-- widget content -->
            <div class="widget-body">
                <%  Html.RenderPartial("~/Views/Activity/HealthFitnessAssessmentGroup.ascx", _model); %>
            </div>
            <!-- end widget content -->

        </div>
        <!-- end widget div -->

    </div>
    <%  } %>
    <!-- end widget -->
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
    }

</script>
