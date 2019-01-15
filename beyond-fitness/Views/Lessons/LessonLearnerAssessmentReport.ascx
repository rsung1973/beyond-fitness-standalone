<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row padding-5">
    <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
        <!-- new widget -->
        <div class="jarviswidget" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
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
            <%  Html.RenderAction("PersonalStrengthAssessment", "Fitness", new { uid = _model.UID, itemID = new int[] { 23, 24, 25, 26, 34, 35 } }); %>
        </div>
        <!-- end widget -->
    </div>
</div>
<div class="row padding-5">
    <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
        <!-- new widget -->
        <div class="jarviswidget" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
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
                <span class="widget-icon"><i class="fa fa-line-chart text-success"></i></span>
                <h2><%--<%= String.Format("{0:yyyy/MM/dd}",_first.AssessmentDate) %> - <%= String.Format("{0:yyyy/MM/dd}",_last.AssessmentDate) %>--%> 訓練系統強度 </h2>
            </header>
            
            <div class="row">
                <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                    <%  Html.RenderAction("EnhancedTraining", "Fitness", new { uid = _model.UID, itemID = new int[] { 28 } }); %>
                </div>
                <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                    <%  Html.RenderAction("BodyEnergyMuscleStrengthAssessment", "Fitness", new { uid = _model.UID, itemID = new int[] { 16,17,52 } }); %>
                </div>
            </div>
        </div>
        <!-- end widget -->
    </div>
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
