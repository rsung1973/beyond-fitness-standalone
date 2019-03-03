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
                    <h1 class="wow fadeInUp animated" data-wow-delay=".3s" data-effect="mfp-zoom-in"><%: NamingItem.AboutBannerTitle %></h1>
                    <h2 class="wow fadeInUp animated col-white" data-wow-delay=".3s" data-effect="mfp-zoom-in"><%: NamingItem.AboutBannerSubTitle %></h2>
                    <a href="<%= Url.Action("BookNow") %>" class="btn btn-default btn-round fadeInUp animated hidden-md-up" data-wow-delay=".6s" data-effect="mfp-zoom-in"><%: NamingItem.BookNow %></a>
                </div>
                <!-- iPhone -->
                <div class="col-md-10 col-md-offset-1 text-center">
                    <img class="header_iphone wow fadeInUp animated" src="images/landing/banner/banner-about.jpg" alt="私人教練" data-wow-delay=".3s" data-effect="mfp-zoom-in">
                </div>               
                <!-- //iPhone -->
            </div>
        </div>
    </section>
    <section class="section-vedio bg-white tall">
        <div class="container">
            <div class="row">
                <h1><%: NamingItem.AboutVedioTitle %></h1>
                <hr />
                <div class="col-md-6">                    
                    <p class="col-dark-grey"><%: NamingItem.AboutVedioDesc1 %></p>
                    <p class="col-dark-grey"><%: NamingItem.AboutVedioDesc2 %></p><br />
                    <p class="col-dark-grey"><%: NamingItem.AboutVedioDesc3 %></p><br />
                    <p class="col-dark-grey"><%: NamingItem.AboutVedioDesc4 %></p>
                </div>
                <div class="col-md-6">
                    <div class="wow fadeIn p-t-20" data-wow-delay="0.15s">
                        <div class="popup-gallery">
                            <a class="popup-youtube" href="https://www.youtube-nocookie.com/embed/q-XoF1jUM20?autoplay=1">                            
                                <img src="images/landing/video/about-1.jpg" alt="大安區健身">
                                <span class="eye-wrapper">
                                    <i class="zmdi zmdi-youtube-play"></i>
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <section class="section-vedio">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <div class="wow fadeIn" data-wow-delay="0.3s">
                        <h1><i class="fas fa-hands"></i> <%: NamingItem.AboutVedioDeclaration1 %></h1>
                        <h1><%: NamingItem.AboutVedioDeclaration2 %></h1>
                    </div>
                </div>
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
