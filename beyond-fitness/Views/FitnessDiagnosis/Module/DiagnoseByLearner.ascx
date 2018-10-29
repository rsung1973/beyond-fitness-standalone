<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="Fitness Diagnosis" class="bg-color-darken no-padding">
    <!-- new widget -->
    <div id="diagnosisContent" class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
        <%  Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisContentByLearner.ascx",_item); %>
    </div>
    <!-- end widget -->
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-diagnoses'></i> Fitness Diagnosis</h4></div>",
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

        function diagnosisContentByLearner(diagnosisID) {
            $('#<%= _dialog %>').dialog("close");
            diagnose(diagnosisID);
        }

        function diagnosisRule(diagnosisID, itemID) {
            showLoading();
            $.post('<%= Url.Action("DiagnosisRule","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID, 'itemID': itemID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String  _dialog = "diagnosis" + DateTime.Now.Ticks;
    BodyDiagnosis _item;
    UserProfile _model;
    FitnessDiagnosisViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (BodyDiagnosis)ViewBag.DataItem;
        _model = (UserProfile)this.Model;
        _viewModel = (FitnessDiagnosisViewModel)ViewBag.ViewModel;
    }

</script>
