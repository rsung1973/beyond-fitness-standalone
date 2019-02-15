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
                    <h1><%= NamingItem.FAQBannerTitle %></h1>
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
                    <label for="q1" class="accordion-label"><%= NamingItem.FAQQestion1 %></label>
                    <ul class="accordion-child accordion sub">
                        <li class="accordion-item">
                            <input id="q11" class="hide" type="checkbox">
                            <label for="q11" class="accordion-label sub"><%= NamingItem.FAQQestion11 %></label>
                            <p class="accordion-child"><%= NamingItem.FAQAnswer11 %></p>
                        </li>
                        <li class="accordion-item">
                            <input id="q12" class="hide" type="checkbox">
                            <label for="q12" class="accordion-label sub"><%= NamingItem.FAQQestion12 %></label>
                            <ul class="accordion-child list-style3"><%= NamingItem.FAQAnswer12 %></ul>
                        </li>
                        <li class="accordion-item">
                            <input id="q13" class="hide" type="checkbox">
                            <label for="q13" class="accordion-label sub"><%= NamingItem.FAQQestion13 %></label>
                            <ul class="accordion-child list-style3">
                                <%= NamingItem.FAQAnswer13 %><br />
                                <li>Tel
                                    <span><%: NamingItem.FindNanjingBranch %>：<a href="tel://+886-2-2715-2733" class="more">(02)-2715-2733</a></span>
                                    <span><%: NamingItem.FindXinyiBranch %>：<a href="tel://+886-2-2720-0530" class="more">(02)2720-0530</a></span>
                                    <span><%: NamingItem.FindZhongxiaoBranch %>：<a href="tel://+886-2-2776-9932" class="more">(02)2776-9932</a></span>
                                </li>
                                <li>Facebook：<a href="https://www.facebook.com/beyond.fitness.pro/" target="_blank" class="more"><%: NamingItem.Go %><i class="pl-1 fa fa-angle-right"></i></a></li>
                                <li><%: NamingItem.OnlineReservation %>：<a href="<%= Url.Action("BookNow") %>" class="more"><%: NamingItem.BookNow %><i class="pl-1 fa fa-angle-right"></i></a></li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li class="accordion-item">
                    <input id="q2" class="hide" type="checkbox">
                    <label for="q2" class="accordion-label"><%= NamingItem.FAQQestion2 %></label>
                    <ul class="accordion-child accordion sub">
                        <li class="accordion-item">
                            <input id="q21" class="hide" type="checkbox">
                            <label for="q21" class="accordion-label sub"><%= NamingItem.FAQQestion21 %></label>
                            <p class="accordion-child"><%= NamingItem.FAQAnswer21 %></p>
                        </li>
                        <li class="accordion-item">
                            <input id="q22" class="hide" type="checkbox">
                            <label for="q22" class="accordion-label sub"><%= NamingItem.FAQQestion22 %></label>
                            <p class="accordion-child"><%= NamingItem.FAQAnswer22 %></p>
                        </li>
                    </ul>
                </li>
                <li class="accordion-item">
                    <input id="q3" class="hide" type="checkbox">
                    <label for="q3" class="accordion-label"><%= NamingItem.FAQQestion3 %></label>
                    <p class="accordion-child"><%= NamingItem.FAQAnswer3 %></p>
                </li>
                <li class="accordion-item">
                    <input id="q4" class="hide" type="checkbox">
                    <label for="q4" class="accordion-label"><%= NamingItem.FAQQestion4 %></label>
                    <p class="accordion-child"><%= NamingItem.FAQAnswer4 %></p>
                </li>
                <li class="accordion-item">
                    <input id="q5" class="hide" type="checkbox">
                    <label for="q5" class="accordion-label"><%= NamingItem.FAQQestion5 %></label>
                    <p class="accordion-child"><%= NamingItem.FAQAnswer5 %></p>
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
