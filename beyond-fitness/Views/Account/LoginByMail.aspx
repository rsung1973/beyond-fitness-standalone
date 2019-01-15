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
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-sign-in"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>登入</li>
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
    <!-- END RIBBON -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-sign-in"></i>登入
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-colorbutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
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
                    <h2>填寫相關資訊 </h2>

                </header>

                <!-- widget div-->
                <div>

                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">

                        <%  Html.RenderPartial("~/Views/Account/Module/LoginForm.ascx"); %>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->
            </div>
        </article>

        <!-- NEW COL START -->
        <% Html.RenderPartial("~/Views/Layout/QuickLink.ascx"); %>
        <!-- END COL -->
    </div>
    <script>

        $('#btnLogin').on('click', function (evt) {

            var form = $(this)[0].form;

            startLoading();
            form.submit();

        });

    </script>

</asp:Content>
<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

    }



</script>
