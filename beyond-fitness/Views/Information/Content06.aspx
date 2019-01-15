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
                        <p class="title-desc"><span class="accent-color">CORRECTION & REMODEL</span></p>
                        <h4 class="classic-title"><span>矯正訓練及復健後訓練</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>Beyond Fitness 擁有多家醫療合作機構，如復建科醫師（Rehab Doctor），物理治療單位（Physical Therapy, RT）在於非體能訓練專業部分，將適度轉介(Transfer)相關機構，經醫療或診斷恢復後，再檢測(detecting)。如復原後身體基本功能狀態良好，才開始逐步重建(Rebuilding)肌力及體能，進行專業的矯正訓練、功能性訓練 (Functional Training)，將為客戶打造最安全、最專業的訓練流程及健康規劃。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-06.jpg" alt="" />
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
