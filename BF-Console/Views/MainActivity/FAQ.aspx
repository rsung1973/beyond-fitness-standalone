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
    <section class="section-faq">
        <div class="container">
            <div class="row">
                <div class="col-md-8 col-md-offset-2 text-center">
                    <h1>我們樂於協助你，<br />讓一切輕鬆又簡單。</h1>
                </div>
                <!-- iPhone -->
                <img class="header_image" src="images/landing/banner/banner-QA.jpg" alt="私人教練">
                <!-- //iPhone -->
            </div>

        </div>
    </section>
    <!-- // 常見問題 -->
    <section class="section-faq-content">
        <div class="container">
            <ul class="accordion">
                <li class="accordion-item">
                    <input id="q1" class="hide" type="checkbox">
                    <label for="q1" class="accordion-label">我想瞭解私人教練課程內容？</label>
                    <ul class="accordion-child accordion sub">
                        <li class="accordion-item">
                            <input id="q11" class="hide" type="checkbox">
                            <label for="q11" class="accordion-label sub">是否有體驗課程？</label>
                            <p class="accordion-child">有的！體驗課程需要提前 1~2日 預約，您就可以準備體驗您的快樂運動時光。</p>
                        </li>
                        <li class="accordion-item">
                            <input id="q12" class="hide" type="checkbox">
                            <label for="q12" class="accordion-label sub">課程內容是什麼呢？</label>
                            <ul class="accordion-child list-style3">
                                體驗課程如下：
                                <li>您將會了解您的身體狀況諮詢服務。</li>
                                <li>練將會細心的了解您的運動狀況與生活型態。</li>
                                <li>教練將帶您期許的運動目標以及運動效果，讓您體驗愉快的課程。</li>
                                <li>教練將與您一同討論專屬於您的客製化訓練。</li>
                            </ul>
                        </li>
                        <li class="accordion-item">
                            <input id="q13" class="hide" type="checkbox">
                            <label for="q13" class="accordion-label sub">我要如何預約呢？</label>
                            <ul class="accordion-child list-style3">
                                您可以透過以下方式聯繫我們完成您的首次體驗課程<br />
                                <li>電話
                                    <span>南京店：<a href="tel://+886-2-2715-2733" class="more">(02)-2715-2733</a></span>
                                    <span>信義店：<a href="tel://+886-2-2720-0530" class="more">(02)2720-0530</a></span>
                                    <span>忠孝店：<a href="tel://+886-2-2776-9932" class="more">(02)2776-9932</a></span>
                                </li>
                                <li>Facebook：<a href="https://www.facebook.com/beyond.fitness.pro/" target="_blank" class="more">立即前往<i class="pl-1 fa fa-angle-right"></i></a></li>
                                <li>線上預約：<a href="#" class="more">立即預約<i class="pl-1 fa fa-angle-right"></i></a></li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li class="accordion-item">
                    <input id="q2" class="hide" type="checkbox">
                    <label for="q2" class="accordion-label">費用問題？</label>
                    <ul class="accordion-child accordion sub">
                        <li class="accordion-item">
                            <input id="q21" class="hide" type="checkbox">
                            <label for="q21" class="accordion-label sub">有月費、入會費及手續費嗎？</label>
                            <p class="accordion-child">Beyond Fitness專注於1對1客製化專業訓練，您無須再繳交任何其他相關費用。</p>
                        </li>
                        <li class="accordion-item">
                            <input id="q22" class="hide" type="checkbox">
                            <label for="q22" class="accordion-label sub">如何收費呢？</label>
                            <p class="accordion-child">專業客製的訓練費用，以堂數做收費計算，規劃訓練價格會依照您的目標、規劃的時間長短及堂數而有所不同。</p>
                        </li>
                    </ul>
                </li>
                <li class="accordion-item">
                    <input id="q3" class="hide" type="checkbox">
                    <label for="q3" class="accordion-label">Beyond的團隊為何與眾不同？</label>
                    <p class="accordion-child">
                        Beyond Fitness的教練團隊為業界首屈一指的專業團隊， 所有相關人員皆俱備國際教練認證資格（國際證照且必須在有效期限內），內部專業團隊學術科考核（每季、半年、一年），以真誠認真的心搭配科學化訓練為根本、系統化紀錄、分析，讓每一位來運動的客戶感受最貼心且值得信任的服務。
                    </p>
                </li>
                <li class="accordion-item">
                    <input id="q4" class="hide" type="checkbox">
                    <label for="q4" class="accordion-label">私人教練課程跟團體課程的差別？</label>
                    <p class="accordion-child">
                        優良的私人教練是針對客戶的目標、生活作息、每一次的當天狀況做出客製化的訓練安排，同時給予您最好的訓練效果去幫助您達成改變並確實地避免運動傷害。<br/><br/>
                        最重要的並幫助您規劃您生活中其餘非運動時間需要注意的事項，相較於團體課程，教練更能針對客戶的目標去做訓練，並依照每位客戶的獨特性以及個別差異化進而給予最有效果的訓練哦！練，並依照每位客戶的獨特性進而給予最有效益的訓練哦！
                    </p>
                </li>
                <li class="accordion-item">
                    <input id="q5" class="hide" type="checkbox">
                    <label for="q5" class="accordion-label">請問可以自己去Beyond運動嗎？</label>
                    <p class="accordion-child">
                        可以的 , 我們只提供 BeyondFitness的客戶登記使用喔，經由規劃專業自主訓練P.I Session，並且進行人數的管控以維持場地以提供客戶最好的運動品質。
                    </p>
                </li>
            </ul>
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
