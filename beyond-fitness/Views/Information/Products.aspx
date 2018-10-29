<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-product-hunt"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>相關商品</li>
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
        <i class="fa-fw fa fa-product-hunt"></i>相關商品
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">

        <!-- SuperBox -->
        <div class="superbox col-sm-12 bg-color-darken txt-color-white">
            <div class="superbox-list">    
                <img src="../img/superbox/product_01.jpg" data-img="../img/superbox/product_01.jpg" alt="售價：7480元" title="HYPERICE振動滾筒" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_02.jpg" data-img="../img/superbox/product_02.jpg" alt="售價：3280元" title="HYPERICE 冰敷袋（通用部件：膝、肘、腕及小腿）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_03.jpg" data-img="../img/superbox/product_03.jpg" alt="售價：3580元" title="HYPERICE 冰敷袋（膝蓋部件）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_04.jpg" data-img="../img/superbox/product_04.jpg" alt="售價：4380元" title="HYPERICE冰敷袋（腰背部件）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_05.jpg" data-img="../img/superbox/product_05.jpg" alt="售價：1280元" title="HYPERICE人造冰" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_06.jpg" data-img="../img/superbox/product_06.jpg" alt="售價：2600元" title="按摩滾筒（長版）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_07.jpg" data-img="../img/superbox/product_07.jpg" alt="售價：2600元" title="按摩滾筒(長版狼牙棒）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_08.jpg" data-img="../img/superbox/product_08.jpg" alt="售價：1600元" title="按摩滾筒（短版）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_09.jpg" data-img="../img/superbox/product_09.jpg" alt="售價：650元" title="MINI BAND 迷你彈力帶（1組）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_10.jpg" data-img="../img/superbox/product_10.jpg" alt="售價：3500元" title="SUPER BAND 長版彈力帶（1組）" class="superbox-img">
            </div><div class="superbox-list">                
                <img src="../img/superbox/product_11.jpg" data-img="../img/superbox/product_11.jpg" alt="售價：900元" title="按摩滾棒（長版）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_12.jpg" data-img="../img/superbox/product_12.jpg" alt="售價：700元" title="按摩滾棒（短版）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_13.jpg" data-img="../img/superbox/product_13.jpg" alt="售價：1000元" title="GYM BOSS電子訓練計時器" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_14.jpg" data-img="../img/superbox/product_14.jpg" alt="售價：1890元" title="RIVAL拳擊手套" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_15.jpg" data-img="../img/superbox/product_15.jpg" alt="售價：300元" title="瑜珈墊(24*68*3.5cm)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_16.jpg" data-img="../img/superbox/product_16.jpg" alt="售價：2500元" title="BOSU半圓球(直徑60cm, 附plastic rim)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_17.jpg" data-img="../img/superbox/product_17.jpg" alt="售價：120元/個，150元/個" title="敏捷標示圈(直徑50cm, 60cm)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_18.jpg" data-img="../img/superbox/product_18.jpg" alt="售價：2000元/組" title="敏捷角錐套組(碗型, 40個, 附收納掛勾)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_19.jpg" data-img="../img/superbox/product_19.jpg" alt="售價：60元/個" title="敏捷角錐(高15cm)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_20.jpg" data-img="../img/superbox/product_20.jpg" alt="售價：1000元, 1200元, 1500元" title="重量訓練桿(4磅,6磅,9磅；長120cm)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_21.jpg" data-img="../img/superbox/product_21.jpg" alt="售價：1100元/個" title="專利BEASTIE®深層按摩球" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_22.jpg" data-img="../img/superbox/product_22.jpg" alt="售價：800元/個" title="T-BALL 按摩花生球" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_23.jpg" data-img="../img/superbox/product_23.jpg" alt="M售價：800元/個" title="平衡墊" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_24.jpg" data-img="../img/superbox/product_24.jpg" alt="售價：850元/個" title="按摩花生球(大)" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_25.jpg" data-img="../img/superbox/product_25.jpg" alt="售價：30000元/個" title="滑板（3公尺可調式滑板，附一對鞋套）" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_26.jpg" data-img="../img/superbox/product_26.jpg" alt="售價：1000元/個" title="大型按摩球" class="superbox-img">
            </div><div class="superbox-list">
                <img src="../img/superbox/product_27.jpg" data-img="../img/superbox/product_27.jpg" alt="售價：2000元/個" title="大型反應球(17×17×17cm)" class="superbox-img">
            </div><div class="superbox-float"></div>
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
