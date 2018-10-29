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

<%  foreach (var item in _model)
    {   %>
<div class="col-xs-6 col-sm-12 one-column">
    <article class="post post--latest">
        <h3 class="not-visible">Latest post</h3>
        <a class="post__images" href="single-post.html?id=<%= item.DocID %>">
            <img src="<%= item.Illustration.HasValue ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/")+item.Attachment.AttachmentID.ToString() + "?stretch=true" : VirtualPathUtility.ToAbsolute("~/images/blog_pic.png") %>" alt="">
        </a>
        <a class="post__text" href="single-post.html?id=<%= item.DocID %>">《<%= item.Title %>》 </a>
        <time datetime="<%= item.Document.DocDate.ToString("yyyy-MM-dd") %>" class="post__date"><%= item.Document.DocDate.ToString("MMM d, yyyy") %></time>
    </article>
</div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IEnumerable<Article> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IEnumerable<Article>)this.Model;
    }

</script>
