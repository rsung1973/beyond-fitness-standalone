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
                        <a href="javascript:(history.back());"><i class="fas fa-backward"></i></a>
                    </span>
                </div>
            </div>
            <ul class="list-group list-group-flush">
                <%  foreach (var item in _model.OrderByDescending(b => b.BlogID))
                    {   %>
                <li class="list-group-item">
                    <div class="media mleft">
                        <div class="media-left">
                            <a href="<%= Url.Action("BlogSingle", "MainActivity", new { item.DocID }) %>">
                                <%  var imgUrl = $"Blog/{item.BlogID}/images/Title.jpg"; %>
                                <img class="blog-img" src="images/blog/DefaultTitle.jpg" onload="<%= System.IO.File.Exists(Server.MapPath(imgUrl)) ? $"this.onload = null;this.src = '{imgUrl}';" : null %>" />
                            </a>
                        </div>
                        <div class="media-body">
                            <h4 class="media-heading"><a href="<%= Url.Action("BlogSingle", "MainActivity", new { item.DocID }) %>"><%= item.Title %></a></h4>
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
    IQueryable<BlogArticle> _model;
    BlogArticleQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<BlogArticle>)this.Model;
        _viewModel = (BlogArticleQueryViewModel)ViewBag.ViewModel;
    }

</script>
