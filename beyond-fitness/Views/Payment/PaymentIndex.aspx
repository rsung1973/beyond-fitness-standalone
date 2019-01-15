<%@  Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
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
            <i class="fa fa-hand-holding-usd"></i>
        </span>
    </span>
    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>收款管理</li>
        <li>新增/作廢收款</li>
    </ol>
    <!-- end breadcrumb -->

</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">

</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <%  Html.RenderPartial("~/Views/Payment/Module/WidgetGrid.ascx",_model); %>
    <%  Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    DailyBookingQueryViewModel _viewModel;
    UserProfile _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }


</script>
