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

    <section class="section-team">
        <div class="container">
            <div class="row">
                <h1 class="align-center">專業團隊</h1>
                <h2 class="align-center"><%= _coachData.branchName %></h2>
            </div>
            <div class="row grid-space-0">
            <%  foreach (var c in _coachData.coachItems)
                {   %>
                <div class="col-xs-6 col-sm-4 col-md-4 col-lg-3 isotope-item">
                    <div class="image-box text-center">
                        <div class="overlay-container">
                            <img src="<%= c.coverPhoto %>" alt="私人教練">
                            <div class="overlay-top">
                                <div class="text">
                                    <h3><%= c.coachName %> <small><%= c.nickname %></small></h3>
                                </div>
                            </div>
                            <div class="overlay-bottom">
                                <div class="links">
                                    <a href='javascript:showDetails(<%= JsonConvert.SerializeObject(c) %>);' class="btn btn-gray-transparent btn-animated btn-sm">了解更多 <i class="pl-10 fa fa-arrow-right"></i></a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <%  }   %>
                <script>
                    function showDetails(coachItem) {
                        $('').launchDownload('<%= Url.Action("CoachDetails", "MainActivity") %>', coachItem);
                    }
                </script>
            </div>
        </div>
    </section>  
    <!-- 360度照片 -->
    <section class="section-360">
        <div class="container">
            <div class="row clearfix">
                <div class="col-12">
                    <div class="fullwidth-gallery">
                        <img src="<%= _coachData.arenaView %>" class="reel" data-image="<%= _coachData.arenaView %>" data-frames="2" data-footage="2" data-revolution="800"/>
                    </div>
                </div>
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
    CoachData _coachData;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _coachData = (CoachData)this.Model;
    }

</script>
