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
                        <p class="title-desc"><span class="accent-color">ATHLETES PERFORMANCE</span></p>
                        <h4 class="classic-title"><span>專業運動顧問</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>Beyond Fitness 提供最專業的運動競技能力訓練計畫，國際級的肌力與體能訓練專家(Strength and Conditioning Professional)將運動科學（Sport Science）與肌力及體能訓練（Strength and Conditioning）整合成有效率、有計畫性的科學化訓練系統，協助客戶特定運動項目需求分析，針對每一年度的重要賽事，強化其肌力體能與各種傷害防護訓練。</p>
                        <p>在台灣常見的運動項目，包含三鐵(Triathlete)、田徑 (Track and Field)、游泳(Swimming)、網球 (Tennis)、籃球(Basketball)、羽球 (Badminton )、高爾夫球(Golf)、CROSSFIT 、技擊(Martial Art)類，甚至是綜合格鬥(MMA)項目選手等，都需要運動訓練科技專業顧問針對專項(Specific Sport)的特性作分析評估，提升其特定爆發力(Explosion)、敏捷性(Agility)、穩定度(Stability)、協調性(Coordirnaiton)、肌耐力(Muscle Endurance)等。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-02.jpg" alt="" />
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
