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
               <h1><%: NamingItem.IndexFeature1 %></h1>
               <%= NamingItem.Features1Desc %>
               <a href="<%= Url.Action("BookNow") %>" class="btn btn-default btn-round btn-simple"><%: NamingItem.BookNow %></a>
            </div>
         </div>
      </div>
   </section>
   <!-- // 安心承諾 -->
   <section class="features-btm white">
      <div class="container">
         <div class="row reverse">
            <div class="col-md-6">
               <h1><%: NamingItem.IndexFeature2 %></h1>
               <%= NamingItem.Features2Desc %>               
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
               <h1><%: NamingItem.IndexFeature3 %></h1>
               <%= NamingItem.Features3Desc %>
               <a href="<%= Url.Action("BookNow") %>" class="btn btn-default btn-round btn-simple"><%: NamingItem.BookNow %></a>
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