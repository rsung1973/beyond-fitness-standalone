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

    <!-- // 個人介紹 -->
    <section class="section-portfolio full-width-section">
        <div class="text-center">
                <img src="<%= _viewModel.personalPhoto %>" alt="私人教練">
            </div>
            <div class="full-text-container bg-light-gray">
                <h1 class="text-center"><%= _viewModel.fullName %></h1>
                <div class="testimonials">
                    <div class="body">
                        <i class="fa fa-quote-left"></i><h2><%= _viewModel.prologue %></h2>
                    </div>                    
                </div>                
            </div>
    </section>
    <!-- // 教學照片 -->
    <section class="section-slick nopadding">
        <div class="testimonials-slick-slide">
            <div class="row">
                <div class="col-md-3"></div>
                <div class="col-md-6">
                    <img class="fullwidth" src="<%= _viewModel.scenarioSample %>" alt=""/>                   
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
    CoachItem _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (CoachItem)ViewBag.ViewModel;
    }

</script>
