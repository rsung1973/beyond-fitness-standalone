<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <!-- Start Page Banner -->
    <div class="page-banner" style="padding: 40px 0; background: url(../images/page_banner_bg.gif);">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <h2>專業體能訓練</h2>
                    <p>We Are Professional</p>
                </div>
                <div class="col-md-6">
                    <ul class="breadcrumbs">
                        <li><a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">首頁</a></li>
                        <li>專業體能訓練</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <!-- End Page Banner -->

    <!-- Start Content -->
    <div id="content">
        <div class="container">
            <div class="page-content">

                <div class="row">


                    <div class="col-md-7">
                        <!-- Start Big Heading -->
                        <p class="title-desc"><span class="accent-color">DISPATCH & BUSINESS</span></p>
                        <h4 class="classic-title"><span>訓練派遣與企業顧問</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>Beyond Fitness 提供各項到府派遣私人體能訓練服務包含專業體能顧問(Personal Trainer)、瑜珈(Yoga)、皮拉提斯(Pilates)以及各種符合客戶需求的體能規劃訓練。</p>
                        <p>Beyond Fitness 有最專業的體能訓練顧問團隊，能為各種企業公司提供長期規劃之健康體能訓練企劃，包括定期動作功能性篩檢、矯正動作訓練、肌力體能訓練及各種體能檢測等服務。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-08.jpg" alt="" />
                    </div>
                </div>

            </div>

        </div>
    </div>
    <!-- End content -->
    <script>
    $('#professional,#m_professional').addClass('active');
    </script>
</asp:Content>
