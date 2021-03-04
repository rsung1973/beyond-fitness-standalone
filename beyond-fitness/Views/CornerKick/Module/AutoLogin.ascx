<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script src="js/libs/jquery-2.2.4.min.js"></script>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.cshtml"); %>
<script>
    console.log('自動登入完成...');
    gtag('event', '登入', {
        'event_category': '自動導入',
        'event_label': '<%= _viewModel.LineID!=null ? "LINE登入" : "自動登入" %>'
    });
    window.location.href = '<%= _model ?? Url.Action("LearnerIndex","CornerKick") %>';
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _model;
    RegisterViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as String;
        _viewModel = (RegisterViewModel)ViewBag.ViewModel;
    }

</script>
