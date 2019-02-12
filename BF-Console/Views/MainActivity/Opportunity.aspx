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
                    <h1 class="wow fadeInUp animated" data-wow-delay=".3s" data-effect="mfp-zoom-in">幸福</h1>
                    <p class="wow fadeInUp animated" data-wow-delay=".3s" data-effect="mfp-zoom-in">是把健康安放在最適當的位置</p>
                    <a href="#" class="btn btn-primary btn-round wow fadeInUp animated hidden-md-up" data-wow-delay=".6s" data-effect="mfp-zoom-in">我想諮詢</a>
                </div>
                <!-- iPhone -->
                <img class="header_iphone wow fadeInUp animated" src="images/landing/banner/banner-join.jpg" alt="孕婦健身" data-wow-delay=".3s" data-effect="mfp-zoom-in">
                <!-- //iPhone -->
            </div>
        </div>
    </section>
    <section class="section-join">
        <div class="container">
            <div class="row">
                <h3 class="section-title col-black align-center"> 你可以獲得什麼</h3>
                <div class="col-md-5 align-center">
                    <img src="images/landing/org.png">
                </div>
                <div class="col-md-7">
                    <ul class="features-list">
                        <li>與優秀夥伴共事的機會</li>
                        <li>一個世界級視野的訓練平台</li>
                        <li>在壓力鍋中爆炸性成長的專業水準</li>
                        <li>一份不算太高但可以舒適過生活的薪水</li>
                        <li>在工作中玩樂，玩樂中工作</li>
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
