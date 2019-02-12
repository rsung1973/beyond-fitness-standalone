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
    
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- // 安心承諾 -->
    <section class="features-btm">
        <div class="container">
            <div class="row">
                <div class="col-md-6 text-center">
                    <div class="image wow zoomIn" data-wow-delay=".3s">
                        <img src="images/landing/banner/banner-about.jpg">
                    </div>
                </div>
                <div class="col-md-6">
                    <h1>安心承諾</h1>
                    <p>Beyond Fitness提供以下承諾</p>
                    <ul class="features-list">
                        <li>客製化課程內容，學習更安全，同時讓您得到顯著的運動效果</li>
                        <li>專業教練帶領下，清楚了解自己的身體狀況與運動進度</li>
                        <li>透過與您互相討論課程內容，強化掌握運動時的每個環節</li>
                        <li>固定時間評估並分析身體狀況與課程內容，隨時替您把關上課品質</li>
                    </ul>
                    <a href="contact.html" class="btn btn-default btn-round btn-simple">立即諮詢</a>
                </div>
            </div>
        </div>
    </section>
    <!-- // 安心承諾 -->
    <section class="features-btm white">
        <div class="container">
            <div class="row reverse">
                <div class="col-md-6">
                    <h1>證照背書</h1>
                    <p>Beyond Fitness 團隊是業界擁有最多國際級六大專業證照的機構，讓您在專業及安全的環境下運動<p>
                            <ul class="features-list">
                                <li>ACE&nbsp;&nbsp;&nbsp;美國運動委員會</li>
                                <li>ACSM&nbsp;&nbsp;美國運動醫學會</li>
                                <li>NCAA&nbsp;&nbsp;國家委員會授證機構</li>
                                <li>NSCA&nbsp;&nbsp;美國肌力體能協會</li>
                                <li>NASM&nbsp;&nbsp;美國國家運動醫學會</li>
                                <li>CrossFit&nbsp;&nbsp;&nbsp;美國混合健身系統</li>
                                <li>EXOS-XPS&nbsp;&nbsp;&nbsp;美國最大私人運動員機構</li>
                                <li>CPR+AED&nbsp;&nbsp;&nbsp;&nbsp;中華民國紅十字會</li>
                            </ul>
                </div>
                <div class="col-md-6 text-center">
                    <div class="image wow zoomIn" data-wow-delay=".8s">
                        <img src="images/landing/banner/banner-index.jpg">
                    </div>
                </div>
            </div>
        </div>
    </section>


    <!-- // 安心承諾 -->
    <section class="features-btm">
        <div class="container">
            <div class="row">
                <div class="col-md-6 text-center">
                    <div class="image wow zoomIn" data-wow-delay=".3s">
                        <img src="images/landing/banner/banner-join.jpg">
                    </div>
                </div>
                <div class="col-md-6">
                    <h1>數據管理</h1>
                    <p>Beyond Fitness成立以來，持續提供您運動時的相關分析，打造屬於您個人的體能分析庫<p>
                            <ul class="features-list">
                                <li>體能分析庫，全面性分析您的運動與身體狀態</li>
                                <li>雲端課表內容，提供您更了解當下運動內容</li>
                                <li>實用的專業文章，隨時補充您的運動與健康資訊</li>
                                <li>有趣的運動小學堂，替您在運動後帶來不同的互動樂趣</li>
                            </ul>
                            <a href="contact.html" class="btn btn-default btn-round btn-simple">立即諮詢</a>
                </div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <%  Html.RenderPartial("~/Views/MainActivity/Module/ContactItem.ascx"); %>
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
