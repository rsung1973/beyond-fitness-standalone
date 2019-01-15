<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="far fa-chart-bar"></i>
        </span>
    </span>
    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>績效管理</li>
        <li>分店上課總覽</li>
    </ol>
    <!-- end breadcrumb -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <%  Html.RenderPartial("~/Views/Achievement/Module/BranchStoreWidgetGrid.ascx", _model); %>
    <script>
        $(function () {
            $global.viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;

            for(var i=0;i<$global.onReady.length;i++) {
                $global.onReady[i]();
            }
        });
    </script>
    <%  Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    AchievementQueryViewModel _viewModel;
    UserProfile _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
        _model = (UserProfile)this.Model;
    }


</script>
