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
                        <p class="title-desc"><span class="accent-color">PREGNANT FITNESS</span></p>
                        <h4 class="classic-title"><span>孕婦產前產後運動顧問</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>在安全環境下，適當的運動能提供孕婦增進腸胃消化、循環代謝、免疫系統以及增加有利於分娩之身體條件，同時能刺激其胎兒生長發育，有利於胎兒之感覺、器官、平衡、呼吸及免疫系統發展。</p>
                        <p>Beyond Fitness 提供專業的孕婦運動訓練規劃，包含安全運動、生活飲食及健康相關建議規劃。以嚴謹的運動動作篩選，嚴格的運動強度即時監控，規劃產前運動、產後運動，內容包括輕度有氧適能、瑜珈、呼吸等相關訓練。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-07.jpg" alt="" />
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
