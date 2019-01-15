<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-at"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>場地租借</li>
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
        <i class="fa-fw fa fa-at"></i>場地租借
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">
        <!-- SuperBox -->
        <div class="superbox col-sm-12 bg-color-darken txt-color-white">
            <div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_01.jpg" data-img="../img/placebox/place_01.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_02.jpg" data-img="../img/placebox/place_02.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_03.jpg" data-img="../img/placebox/place_03.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_04.jpg" data-img="../img/placebox/place_04.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_05.jpg" data-img="../img/placebox/place_05.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_06.jpg" data-img="../img/placebox/place_06.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_07.jpg" data-img="../img/placebox/place_07.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_08.jpg" data-img="../img/placebox/place_08.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_09.jpg" data-img="../img/placebox/place_09.jpg" alt="" title="訓練場地" class="superbox-img">
            </div><div class="superbox-list">
                <img runat="server" src="~/img/placebox/place_10.jpg" data-img="../img/placebox/place_10.jpg" alt="" title="訓練場地" class="superbox-img">
            </div>
            <div class="superbox-float"></div>
        </div>
        <!-- /SuperBox -->

        <div class="superbox-show" style="height: 300px; display: none"></div>

    </div>
    <script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/superbox/superbox.min.js") %>"></script>
    <script>
        $(function () {
            $('.superbox').SuperBox();
        });
    </script>
</asp:Content>
