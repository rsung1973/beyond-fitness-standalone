<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="System.Web.Mvc" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="post post--full">
    <h1 class="post-heading">《<%= _model.Title %>》</h1>
    <div class="post--full__info">
        <p class="post__date post__date--rect"><%= _model.Document.DocDate.ToString("MMM d yyyy") %></p>
        <ul class="tags post__tags">
            <li class="tags__item tags__item--user"><a href="#" class="tags__link">by <%= _model.UserProfile.RealName %></a></li>
        </ul>
    </div>
    <!-- Slider with sidebar -->
    <p></p>
    <p>
        <%= _model.ArticleContent %>
    </p>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    Article _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (Article)this.Model;
    }

</script>
