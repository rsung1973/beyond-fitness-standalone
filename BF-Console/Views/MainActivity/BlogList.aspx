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
            <span class="mode">
                <a href="<%= Url.Action("BlogGrid") %>"><i class="fas fa-th-large"></i></a>
            </span>
            <ul class="list-group list-group-flush">  
                <%  foreach (var item in models.GetTable<BlogCategoryDefinition>())
                    {   %>
                <li class="list-group-item">
                    <div class="media mleft">
                        <div class="media-left">
                            <a href="<%= Url.Action("BlogArticleList","MainActivity",new { item.CategoryID }) %>">
                                <img class="blog-img" src="<%= item.CategoryIndication %>">
                            </a>
                        </div>
                        <div class="media-body">
                            <h4 class="media-heading">
                                <a href="<%= Url.Action("BlogArticleList","MainActivity",new { item.CategoryID }) %>">
                                    <%= item.Category %>
                                </a>
                            </h4>                            
                        </div>
                    </div>
                </li>
                <%  }   %>
            </ul>
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
