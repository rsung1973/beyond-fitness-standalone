<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script>
    $(function () {
        showLoading();
        $('#diagnosisContent').load('<%= Url.Action("DiagnosisContent","FitnessDiagnosis",new { diagnosisID = _model.DiagnosisID,uid = _model.LearnerID }) %>', {}, function (data) {
            hideLoading();
        });
    });
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String  _dialog = "diagnosis" + DateTime.Now.Ticks;
    BodyDiagnosis _model;
    FitnessDiagnosisViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (BodyDiagnosis)this.Model;
        _viewModel = (FitnessDiagnosisViewModel)ViewBag.ViewModel;
    }

</script>
