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
    
    <!-- // 聯絡我們 -->
    <section class="section-contact">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <h1><%: NamingItem.JoinUsContactTitle %></h1>
                    <p class="lead"><%: NamingItem.JoinUsContactDesc %></p>
                    <a href="#" class="more"><%: NamingItem.HereWeGo %><i class="pl-1 fa fa-angle-right"></i></a>
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
