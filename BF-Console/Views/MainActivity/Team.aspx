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
                <h1 class="align-center"><%: NamingItem.TeamTitle %></h1>
                <h2 class="align-center"><%= _coachData.branchName %></h2>
            </div>
            <div class="row grid-space-0">
            <%  foreach (var c in _coachData.coachItems)
                {   %>
                <div class="col-xs-6 col-sm-4 col-md-4 col-lg-3 isotope-item">
                    <div class="image-box text-center">
                        <div class="overlay-container">
                            <img src="<%= $"images/landing/portfolio/{ c.nickname}/Cover.png" %>" alt="私人教練">
                            <div class="overlay-top">
                                <div class="text">
                                    <h3><%= c.coachName %> <small><%= c.nickname %></small></h3>
                                </div>
                            </div>
                            <div class="overlay-bottom">
                                <div class="links">
                                    <a href='javascript:showDetails(<%= JsonConvert.SerializeObject(c) %>);' class="btn btn-gray-transparent btn-animated btn-sm"><%: NamingItem.LearnMore %> <i class="pl-10 fa fa-arrow-right"></i></a>
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
    <%  Html.RenderPartial("~/Views/MainActivity/Module/ContactItem.ascx"); %>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- jquery reel -->
    <script src="plugins/jquery-reel/jquery.reel.js"></script>
    <script>
        $(function () {
            reloadPage = function () {
                $('').launchDownload('<%= Url.Action("Team", "MainActivity") %>', {'branchName':'<%= ViewBag.BranchName %>'});
            };
        });
    </script>
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
