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
                        <p class="title-desc"><span class="accent-color">PERSONAL FITNESS</span></p>
                        <h4 class="classic-title"><span>私人體能訓練顧問</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>Beyond Fitness是 私人體能訓練的專家（Sport and Fitness Professional），我們擁有豐富的實務訓練經驗及充實的科學訓練背景知識。</p>
                        <p>私人體能訓練課程就是依據客戶個人整體健康數據、全方位體能及生活評估，規劃出最有效率以及最貼近客戶需求的體能計劃。我們最大的榮耀是讓客戶得以在最好的環境、生活、時間中取得最大的訓練價值價值。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-01.jpg" alt="" />
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
