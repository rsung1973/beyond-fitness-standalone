<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/MainActivity/Template/BlogPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

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

    <!-- Main Content -->
    <section class="section-blog dark">
        <div class="container">            
            <div class="row clearfix">
                <div class="col-12">
                    <span class="mode p-r-20">
                        <a href="<%= Url.Action("BlogList") %>"><i class="fas fa-th-list"></i></a>
                    </span>
                </div>
            </div>
            <div class="row clearfix">    
                <%  foreach (var item in models.GetTable<BlogCategoryDefinition>())
                    {   %>                
                <div class="col-xs-6 col-sm-4 col-md-3 col-lg-3">
                    <div class="blog-item text-center">
                        <div class="blog-img">
                            <img class="img-fluid" src="<%= item.CategoryIndication %>">
                            <div class="blog-overlay" onclick="javascript:viewArticleList(<%= item.CategoryID %>);">
                                <div class="overlay-social-icon text-center">
                                    <ul class="social-icons">
                                        <li><a href="<%= Url.Action("BlogArticleList","MainActivity",new { item.CategoryID }) %>">了解更多</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <div class="info-text">
                            <h3><%= item.Category %></h3>
                        </div>
                    </div>
                </div>
                <%  }   %>
            </div>
        </div>
    </section>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
   <script>

        function viewArticleList(categoryID) {
            $('').launchDownload('<%= Url.Action("BlogArticleList", "MainActivity") %>', { 'CategoryID': categoryID });
        }
    </script>
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

