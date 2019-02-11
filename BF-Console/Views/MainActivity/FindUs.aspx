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

    <section class="section-branch">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1> <%: NamingItem.FindNanjingBranch %>
                        <a href="tel://+886-2-2715-2733" class="tel">(02)2715-2733</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市大安區大安路一段75巷21號B1" target="_blank" class="add">
                        <%: NamingItem.FindNanjingBranchAdd %>
                    </a>
                    <p><%: NamingItem.FindNanjingBranchDesc1 %></p>
                    <p><%: NamingItem.FindNanjingBranchDesc2 %></p>
                    <a href="team-arena.html" class="more"><%: NamingItem.OurTeam %<i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-arena" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <section class="section-branch second">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1><%: NamingItem.FindXinyiBranch %>
                        <a href="tel://+886-2-2720-0530" class="tel">(02)2720-0530</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市信義區信義路五段16號2樓之2" target="_blank" class="add">
                        <%: NamingItem.FindXinyiBranchAdd %>
                    </a>
                    <p><%: NamingItem.FindXinyiBranchDesc1 %></p>
                    <p><%: NamingItem.FindXinyiBranchDesc2 %></p>
                    <a href="team-101.html" class="more"><%: NamingItem.OurTeam %<i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-101" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <section class="section-branch second">
        <div class="container">
            <div class="row">
                <div class="col-sm-6">
                    <h1><%: NamingItem.FindZhongxiaoBranch %>
                        <a href="tel://+886-2-2776-9932" class="tel">(02)2776-9932</a>
                    </h1>
                    <a href="https://maps.google.com/?q=台北市大安區大安路一段75巷21號B1" target="_blank" class="add">
                        <%: NamingItem.FindZhongxiaoBranchAdd %>
                    </a>                    
                    <p><%: NamingItem.FindZhongxiaoBranchDesc1 %></p>
                    <p><%: NamingItem.FindZhongxiaoBranchDesc2 %></p>
                    <a href="team-sogo.html" class="more"><%: NamingItem.OurTeam %><i class="pl-1 fa fa-angle-right"></i></a>
                </div>
                <div class="col-sm-6 p-t-20">
                    <div id="map-sogo" class="map-canvas small"></div>
                </div>
            </div>
        </div>
    </section>
    <!-- // 聯絡我們 -->
    <section class="section-contact">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <h1><%: NamingItem.ContactTitle %></h1>
                    <p class="lead"><%: NamingItem.ContactSubTitle %></p>
                    <a href="contact.html" class="more"><%: NamingItem.ContactAskNow %><i class="pl-1 fa fa-angle-right"></i></a>
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
