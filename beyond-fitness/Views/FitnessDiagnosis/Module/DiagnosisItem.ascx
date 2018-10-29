<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="widget-body bg-color-darken txt-color-white padding-5">
    <div class="row">
        <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
            <div class="row">
                <div class="col-sm-6 body_show text-center">
                    <div class="body-thumbnail">
                        <%  if (_model.LevelID == (int)Naming.DocumentLevelDefinition.暫存)
                            { %>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-neck <%= _model.BodySuffering.Any(p => p.PartID == 1) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-leftshoulder <%= _model.BodySuffering.Any(p => p.PartID == 2) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-rightshoulder <%= _model.BodySuffering.Any(p => p.PartID == 3) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-leftupperlimb <%= _model.BodySuffering.Any(p => p.PartID == 4) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-rightupperlimb <%= _model.BodySuffering.Any(p => p.PartID == 5) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-leftwrist <%= _model.BodySuffering.Any(p => p.PartID == 6) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-rightwrist <%= _model.BodySuffering.Any(p => p.PartID == 7) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-chest <%= _model.BodySuffering.Any(p => p.PartID == 8) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-waist <%= _model.BodySuffering.Any(p => p.PartID == 9) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-leftlowerlimbs <%= _model.BodySuffering.Any(p => p.PartID == 10) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-rightlowerlimbs <%= _model.BodySuffering.Any(p => p.PartID == 11) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-leftankle <%= _model.BodySuffering.Any(p => p.PartID == 12) ? "warning" : null %>"></a>
                        <a onclick="checkSuffering(<%= _model.DiagnosisID %>);" class="informer-rightankle <%= _model.BodySuffering.Any(p => p.PartID == 13) ? "warning" : null %>"></a>
                        <%  }
                            else
                            {
                                foreach(var item in _model.BodySuffering)
                                {   %>
                                    <a class="<%= item.BodyParts.Part %> warning"></a>
                        <%      }
                            } %>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-12 col-sm-9 col-md-9 col-lg-9">
            <!-- new widget -->
            <div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
                <header>
                    <span class="widget-icon"><i class="fa fa-user-circle-o"></i></span>
                    <h2>體能顧問：<%= _model.Conductor.FullName() %></h2>
                    <div class="widget-toolbar">
                        <div class="widget-toolbar">
                            <%  if (_model.LevelID == (int)Naming.DocumentLevelDefinition.暫存)
                                { %>
                            <a href="#" class="btn bg-color-yellow" onclick="editDiagnosisGoal(<%= _model.DiagnosisID %>);"><i class="fa fa-anchor"></i>編輯診斷內容</a>
                            <a href="#" class="btn  bg-color-yellow" onclick="editDiagnosisAssessment(<%= _model.DiagnosisID %>);"><i class="fa fa-plus"></i>新增項目</a>
                            <%  } %>
                        </div>
                    </div>
                </header>
                <!-- widget div-->
                <div>
                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                        <p class="alert alert-info" id="diagGoal">
                            <%  Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisGoal.ascx", _model); %>                        
                        </p>
                        <!-- content goes here -->
                        <div id="diagAssessment">
                            <%  Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisAssessment.ascx", _model); %>
                        </div>
                        
                        <!-- end content -->
                    </div>
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    BodyDiagnosis _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (BodyDiagnosis)this.Model;
    }

</script>
