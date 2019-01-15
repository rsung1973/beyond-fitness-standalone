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
                        <p class="title-desc"><span class="accent-color">GROUP & BOOT CAMP</span></p>
                        <h4 class="classic-title"><span>小班制及團體課程規劃</span></h4>

                        <!-- End Big Heading -->

                        <!-- Some Text -->
                        <p>Beyond Fitness針對每位銀髮族做出最貼心，最安全。最照顧以及最完整四大方向健康體能訓練規劃流程，同時擁有相關的醫療合作機構及多方轉介服務，可提供最專業、最安全與最貼近銀髮族生活中的全方位健康體能需求規劃。</p>
                        Beyond Fitness 提供1~6人小班制訓練 、 綜合性訓練、瑜珈、皮拉提斯、多功能循環訓練及TRX懸吊系統訓練。依據小班制成員特性，打造專屬最適合、最貼近學員需求的小班制訓練課程。 Beyond Fitness 提供企業公司團體合作6人以上，中型、大型團體活動及訓練課程， 其訓練內容視其企業公司教育訓練需求做考量，打造專案活動訓練企劃。</p>

                    </div>
                    <!-- Start Memebr 1 -->
                    <div class="col-md-5 image-service-box">
                        <img class="img-thumbnail" src="../images/professional-fitness-05.jpg" alt="" />
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
