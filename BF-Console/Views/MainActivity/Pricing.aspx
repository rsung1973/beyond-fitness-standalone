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
                <img src="<%= $"images/landing/portfolio/{ _viewModel.nickname}/Cover.png" %>" alt="私人教練">
            </div>
            <div class="full-text-container bg-light-gray">
                <h1 class="text-center"><%= _viewModel.coachName %> <small><%= _viewModel.nickname %></small></h1>
                <div class="testimonials">
                    <div class="body">
                        <i class="fa fa-quote-left"></i><h2><%= _viewModel.prologue %></h2>
                    </div>                    
                </div>                
            </div>
    </section>
    <!-- // 教學照片 -->
    <%  if (_viewModel.scenarioPhoto != null && _viewModel.scenarioPhoto.Count > 0)
        {   %>
    <section class="section-slick nopadding">
        <div class="testimonials-slick-slide">
            <%  foreach (var photo in _viewModel.scenarioPhoto)
                {   %>
            <div class="row">
                <div class="col-md-6 col-md-offset-3 col-sm-6 col-sm-offset-3">
                    <img class="fullwidth" src="<%= $"images/landing/portfolio/{ _viewModel.nickname}/{photo}" %>" alt="私人教練"/>                   
                </div>
            </div>
            <%  }   %>
        </div>
    </section>
    <%  }   %>
    <!-- // 聯絡我們 -->
    <%  Html.RenderPartial("~/Views/MainActivity/Module/ContactItem.ascx"); %>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <script>
        $(function () {
            reloadPage = function () {
                $('').launchDownload('<%= Url.Action("CoachDetails", "MainActivity") %>', <%= JsonConvert.SerializeObject(_viewModel) %>);
            };
        });
    </script>

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
