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
    <section class="section-flow">
        <div class="container">
            <div class="row">
                <h1 class="align-center"><%: NamingItem.BookNowTitle %></h1>
                <div class="col-md-4 align-center">
                    <div class="wow fadeIn p-t-20" data-wow-delay="0.15s">
                        <div class="image">
                            <img src="images/landing/contact.png">
                        </div>                        
                    </div>
                </div>
                <div class="col-md-8">                    
                    <hr />
                    <ul class="list-style2">
                        <li><%= NamingItem.BookNowStep1 %></li>
                        <li><%= NamingItem.BookNowStep2 %></li>
                        <li><%= NamingItem.BookNowStep3 %></li>
                        <li><%= NamingItem.BookNowStep4 %></li>
                    </ul>
                    <a href="https://goo.gl/forms/b9KvsoRwhqdFbNC03" target="_blank" class="btn btn-default btn-round wow fadeInUp animated" data-wow-delay=".6s" data-effect="mfp-zoom-in"><%: NamingItem.BookNow %></a>
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
