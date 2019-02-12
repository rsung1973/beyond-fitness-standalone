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
    <!-- // 加入執行團隊 -->
    <section class="section-features">
        <div class="container">
            <div class="row mb-30">
                <div class="col-md-12">
                    <h1 class="text-center"><%: NamingItem.JoinUsTitle %></h1>
                    <p><%: NamingItem.JoinUsDesc %></p>
                </div>
            </div>
            <div class="row">
                <div class="col-md-10 col-md-offset-1 col-sm-12">
                    <div class="row">
                        <div class="col-md-6 col-sm-6 features-item left wow zoomIn" data-wow-delay=".3s">
                            <div class="icon-wrapper">
                                <img src="images/landing/smile.png" alt="微笑">
                            </div> 
                            <h3><%: NamingItem.JoinUsFeature1 %><small><%: NamingItem.JoinUsFeature1Desc %></small></h3>
                        </div>
                        <div class="col-md-6 col-sm-6 features-item left wow zoomIn" data-wow-delay=".6s">
                            <div class="icon-wrapper">
                                <img src="images/landing/inspire.png" alt="啟發">
                            </div> 
                            <h3><%: NamingItem.JoinUsFeature2 %><small><%: NamingItem.JoinUsFeature2Desc %></small></h3>
                        </div>
                        <div class="col-md-6 col-sm-6 features-item left wow zoomIn" data-wow-delay=".9s">
                            <div class="icon-wrapper">
                                <img src="images/landing/warm.png" alt="溫暖">
                            </div> 
                            <h3><%: NamingItem.JoinUsFeature3 %><small><%: NamingItem.JoinUsFeature3Desc %></small></h3>
                        </div>
                        <div class="col-md-6 col-sm-6 features-item left wow zoomIn" data-wow-delay="1.2s">
                            <div class="icon-wrapper">
                                <img src="images/landing/upright.png" alt="正直">
                            </div> 
                            <h3><%: NamingItem.JoinUsFeature4 %><small><%: NamingItem.JoinUsFeature4Desc %></small></h3>
                        </div>
                    </div>
                </div>
                
            </div>
        </div>
    </section>
    <section class="section-job">
        <div class="container">
            <div class="row">
                <div class="col-md-10 col-md-offset-1">
                    <div class="row clearfix">
                        <div class="col-md-6 col-sm-6">
                            <div class="features-box">
                                <div class="features-icon title"><i class="fas fa-user-tag"></i> <%: NamingItem.JoinUsJob1 %></div>
                                <div class="features-content">
                                    <a href="<%= Url.Action("Opportunity") %>" class="more"><%: NamingItem.LearnMore %><i class="pl-1 fa fa-angle-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 col-sm-6">
                            <div class="features-box">
                                <div class="features-icon title"><i class="fas fa-user-tag"></i> <%: NamingItem.JoinUsJob2 %></div>
                                <div class="features-content">
                                    <a href="<%= Url.Action("Opportunity") %>" class="more"><%: NamingItem.LearnMore %><i class="pl-1 fa fa-angle-right"></i></a>
                                </div>
                            </div>
                        </div>
                    </div>
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
