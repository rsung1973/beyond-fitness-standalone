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
<%@ Import Namespace="BFConsole.Views.MainActivity.Resources" %>

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- // Banner -->
    <section class="section-header">
        <div class="container">
            <div class="row">
                <div class="col-md-8 col-md-offset-2 text-center">
                    <h1 class="wow zoomIn" data-wow-delay=".3s"><%: NamingItem.IndexBannerTitle %></h1>
                    <h2 class="wow zoomIn col-white" data-wow-delay=".6s"><%: NamingItem.IndexBannerSubTitle %></h2>
                    <a href="<%= Url.Action("BookNow") %>" class="btn btn-default btn-round fadeInUp animated hidden-md-up" data-wow-delay=".6s" data-effect="mfp-zoom-in"><%: NamingItem.BookNow %></a>
                </div>
                <!-- iPhone -->
                <div class="col-md-10 col-md-offset-1 text-center">
                    <img class="header_iphone wow fadeInUp animated" src="images/landing/banner/banner-index.jpg" alt="孕婦健身" data-wow-delay=".3s" data-effect="mfp-zoom-in">
                </div>                
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
                    <h2><%: NamingItem.IndexFeature1 %></h2>
                    <hr />
                    <p> <%: NamingItem.IndexFeature1Desc %> </p>
                    <a href="<%= Url.Action("Features") %>" class="more"><%: NamingItem.LearnMore %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>

                <div class="col-sm-4 features-item  ">
                    <div class="icon-wrapper"> <img src="images/landing/icon2.png" alt="證照背書"> </div>
                    <h2><%: NamingItem.IndexFeature2 %></h2>
                    <hr />
                    <p> <%: NamingItem.IndexFeature2Desc %> </p>
                    <a href="<%= Url.Action("Features") %>" class="more"><%: NamingItem.LearnMore %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-4 features-item  ">
                    <div class="icon-wrapper"> <img src="images/landing/icon3.png" alt="數據管理"> </div>
                    <h2><%: NamingItem.IndexFeature3 %></h2>
                    <hr />
                    <p> <%: NamingItem.IndexFeature3Desc %> </p>
                    <a href="<%= Url.Action("Features") %>" class="more"><%: NamingItem.LearnMore %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
            </div>
        </div>
    </section>
    <!-- // 影片分享 -->
    <section class="section-vedio">
        <div class="container">
            <div class="row mb-30">
                <div class="col-md-12">
                    <h2><%: NamingItem.IndexVedioTitle %></h2>
                    <h1><%: NamingItem.IndexVedioSubTitle %></h1>
                    <p><%= NamingItem.IndexVedioDesc %></p>
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
            <h1><%= NamingItem.IndexFunFactsTitle %></h1>
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
                        <p><%: NamingItem.IndexSlick1Desc %></p>
                        <div class="m-t-30">
                            <img class="media-object rounded-circle shadow" src="images/avatar/therapist.jpg" alt="物理治療">
                            <h5 class="mb-0 m-t-10"><%: NamingItem.IndexSlick1Name %></h5>
                            <span><%: NamingItem.IndexSlick1Title %></span>
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
                        <p><%: NamingItem.IndexSlick2Desc %></p>
                        <div class="m-t-30">
                            <img class="media-object rounded-circle shadow" src="images/avatar/dietitian.jpg" alt="運動營養">
                            <h5 class="mb-0 m-t-10"><%: NamingItem.IndexSlick2Name %></h5>
                            <span><%: NamingItem.IndexSlick2Title %></span>
                        </div>
                    </div>
                </div>
                <div class="col-md-3"></div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <%  Html.RenderPartial("~/Views/MainActivity/Module/ContactItem.ascx"); %>
    
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
