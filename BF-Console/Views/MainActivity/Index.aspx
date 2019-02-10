<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/MainActivity/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- // Banner -->
    <section class="section-header">
        <div class="container">
            <div class="row">
                <div class="col-md-8 col-md-offset-2 text-center">
                    <h1 class="wow zoomIn" data-wow-delay=".3s">我們的堅持</h1>
                    <h2 class="wow zoomIn col-white" data-wow-delay=".6s">源自於客戶每一分安心</h2>
                    <a href="contact.html" class="btn btn-default btn-round fadeInUp animated hidden-md-up" data-wow-delay=".6s" data-effect="mfp-zoom-in">預約諮詢</a>
                </div>
                <!-- iPhone -->
                <img class="header_iphone wow fadeInUp animated" src="images/landing/banner/banner-index.jpg" alt="孕婦健身" data-wow-delay=".3s" data-effect="mfp-zoom-in">
                <!-- //iPhone -->
            </div>
        </div>
    </section>
    <!-- // 三大保證 -->
    <section class="section-features white">
        <div class="container">
            <div class="row">
                <div class="col-sm-4 features-item">
                    <div class="icon-wrapper"> <img src="images/landing/icon.png" alt="安心承諾"> </div>
                    <h2>安心承諾</h2>
                    <hr />
                    <p> 真正的專業來自於信任，我們專注於溝通及傾聽，與您攜手合作獲得成功。 </p>
                    <a href="features.html" class="more">了解更多<i class="pl-1 fa fa-angle-right"></i></a>
                </div>

                <div class="col-sm-4 features-item  ">
                    <div class="icon-wrapper"> <img src="images/landing/icon2.png" alt="證照背書"> </div>
                    <h2>證照背書</h2>
                    <hr />
                    <p> 擁有國際級六大專業證照，讓您在專業及安全的環境下運動。 </p>
                    <a href="features.html" class="more">了解更多<i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-4 features-item  ">
                    <div class="icon-wrapper"> <img src="images/landing/icon3.png" alt="數據管理"> </div>
                    <h2>數據管理</h2>
                    <hr />
                    <p> 全新體能分析庫、個人化課表內容、每月挑戰，全為激發你的源源動力。 </p>
                    <a href="features.html" class="more">了解更多<i class="pl-1 fa fa-angle-right"></i></a>
                </div>
            </div>
        </div>
    </section>
    <!-- // 影片分享 -->
    <section class="section-vedio">
        <div class="container">
            <div class="row mb-30">
                <div class="col-md-12">
                    <h2>給 不知道如何開始 背後的你</h2>
                    <h1>夢想實踐者</h1>
                    <p>看看 黃伯伯 <span class="hidden-sm-down">和 陳阿姨 </span>如何透過專業的訓練，更加了解運動的價值。</p>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-6">
                    <div class="popup-gallery">
                        <a class="popup-youtube" href="https://www.youtube-nocookie.com/embed/x88BkpwEvKc?autoplay=1&rel=0&showinfo=0&loop=1">
                            <img src="images/landing/video/index-1.jpg" alt="銀髮族運動" class="wow zoomin" data-wow-delay=".3s">
                            <span class="eye-wrapper">
                                <i class="zmdi zmdi-youtube-play"></i>
                            </span>
                        </a>
                    </div>
                </div>
                <div class="col-sm-6 hidden-sm-down">
                    <div class="popup-gallery">
                        <a class="popup-youtube" href="https://www.youtube-nocookie.com/embed/5chW8tcwMr0?autoplay=1&rel=0&showinfo=0&loop=1">
                            <img src="images/landing/video/index-2.jpg" alt="信義區健身" class="wow zoomin" data-wow-delay=".3s">
                            <span class="eye-wrapper">
                                <i class="zmdi zmdi-youtube-play"></i>
                            </span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- // 雲端數據 -->
    <section class="section-fun-facts nopadding full-width-section">
        <div class="full-text-container bg-light-gray text-right">
            <h1>數據體能分析，<br />創造強而有力的新雲端</h1>
        </div>
        <div>
            <img src="images/landing/mobile.jpg" class="wow zoomIn" data-wow-delay=".3s" alt="客製化健身藍圖" >
        </div>
    </section>
    <!-- // 經驗分享 -->
    <section class="section-slick">
        <div class="testimonials-slick-slide">
            <div class="row">
                <div class="col-md-3"></div>
                <div class="col-md-6 testimonials">
                    <div class="body text-center">
                        <i class="fa fa-quote-left"></i>
                        <p>專業是細心且提升客戶的保障，Beyond 運動與物理治療的配合是有效的</p>
                        <div class="m-t-30">
                            <img class="media-object rounded-circle shadow" src="images/avatar/therapist.jpg" alt="物理治療">
                            <h5 class="mb-0 m-t-10">Jane Doe</h5>
                            <span>物理治療師</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-3"></div>
            </div>
            <div class="row">
                <div class="col-md-3"></div>
                <div class="col-md-6 testimonials">
                    <div class="body text-center">
                        <i class="fa fa-quote-left"></i>
                        <p>在溫馨與專業的Beyond，確保你的飲食以及運動都得到妥善照顧</p>
                        <div class="m-t-30">
                            <img class="media-object rounded-circle shadow" src="images/avatar/dietitian.jpg" alt="運動營養">
                            <h5 class="mb-0 m-t-10">Jane Doe</h5>
                            <span>營養師</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-3"></div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <section class="section-contact">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <h1>開始您的第一步</h1>
                    <p class="lead">我們隨時提供協助。</p>
                    <a href="contact.html" class="more">立即提問<i class="pl-1 fa fa-angle-right"></i></a>
                    <ul class="contact_social">
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-facebook"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-instagram"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-youtube-play"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="fab fa-line"></i></a></li>
                    </ul>
                    <div class="copyright">Copyright © 2018 Beyond Fitness. All Rights Reserved</div>
                </div>
            </div>
        </div>
    </section>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">

</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;

    }

</script>
