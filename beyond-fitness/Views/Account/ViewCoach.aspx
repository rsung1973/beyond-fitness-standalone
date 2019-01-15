<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-user"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li><%= _userProfile!=null && _userProfile.UID==_model.UID ? "我的" : "體能顧問" %>簡介</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
                ribbon for further usability

                Example below:

                <span class="ribbon-button-alignment pull-right">
                <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
                <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
                <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
                </span> -->

    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-user"></i><%= _userProfile!=null && _userProfile.UID==_model.UID ? "我的" : "體能顧問" %>簡介
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <%  Html.RenderPartial("~/Views/Member/CoachArticle.ascx", _model); %>

        <article class="col-xs-12 col-sm-12 col-md-3 col-lg-3">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i> 快速功能</h5>
                <ul class="no-padding no-margin ">
                    <p class="no-margin ">
                        <ul class="icons-list ">
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/TimeLine.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/VipOverview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Overview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/EditProfile.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Logout.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Login.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Register.ascx"); %>
                        </ul>
                    </p>
                </ul>
            </div>
            <!-- /well -->
        </article>


    </div>


    <script>
        $(function () {
            $('.carousel.slide').carousel({
                interval: 3000,
                cycle: true
            });
            $('.carousel.fade').carousel({
                interval: 3000,
                cycle: true
            });
        });
    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _userProfile = Context.GetUser();
    }


</script>
