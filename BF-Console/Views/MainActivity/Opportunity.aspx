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
    <section class="section-header bg-darkteal small">
        <div class="container">
            <div class="row">
                <div class="col-md-8 col-md-offset-2 text-center">
                    <h1 class="wow fadeInUp animated" data-wow-delay=".3s" data-effect="mfp-zoom-in"><%: NamingItem.OpportunityBannerTitle %></h1>
                    <p class="wow fadeInUp animated" data-wow-delay=".3s" data-effect="mfp-zoom-in"><%: NamingItem.OpportunityBannerSubTitle %></p>
                    <a href="<%= Url.Action("BookNow") %>" class="btn btn-primary btn-round wow fadeInUp animated hidden-md-up" data-wow-delay=".6s" data-effect="mfp-zoom-in"><%: NamingItem.BookNow %></a>
                </div>
                <!-- iPhone -->
                <div class="col-md-10 col-md-offset-1 text-center">
                    <img class="header_iphone wow fadeInUp animated" src="images/landing/banner/banner-join.jpg" alt="孕婦健身" data-wow-delay=".3s" data-effect="mfp-zoom-in">
                </div>                
                <!-- //iPhone -->
            </div>
        </div>
    </section>
    <section class="section-join">
        <div class="container">
            <div class="row">
                <h3 class="section-title col-black align-center"> <%: NamingItem.OpportunityFeaturesTitle %></h3>
                <div class="col-md-5 align-center">
                    <img src="images/landing/org.png">
                </div>
                <div class="col-md-7">
                    <ul class="features-list">
                        <li><%: NamingItem.OpportunityFeaturesDesc1 %></li>
                        <li><%: NamingItem.OpportunityFeaturesDesc2 %></li>
                        <li><%: NamingItem.OpportunityFeaturesDesc3 %></li>
                        <li><%: NamingItem.OpportunityFeaturesDesc4 %></li>
                    </ul>
                </div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <%  Html.RenderPartial("~/Views/MainActivity/Module/JoinItem.ascx"); %>
    
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
