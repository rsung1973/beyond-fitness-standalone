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

<%  var r = new Random();
    var idx = r.Next(5);
    foreach (var item in _model)
    {
        switch((idx++)%5)
        {
            case 0: %>
<article class="post post--table <%= String.Join(" ",item.ArticleCategory.Select(t=>t.Category)) %>">
    <a class="image-container image-container--max post__link-area" href="single-post.html?id=<%= item.DocID %>">
        <img src="<%= item.Illustration.HasValue ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/")+item.Attachment.AttachmentID.ToString() + "?stretch=true" : VirtualPathUtility.ToAbsolute("~/images/blog_pic.png") %>" alt="">
    </a>
    <div class="post__detail">
        <a class="post__link" href="single-post.html?id=<%= item.DocID %>">
            <h3 class="post__heading"><%= item.Title %></h3>
        </a>
        <p class="post__date"><%= item.Document.DocDate.ToString("yyyy-MM-dd") %></p>
        <p class="post__text"><%= getBrief(item.ArticleContent) %></p>
    </div>
</article>
<%  
            break;
        case 1: %>
<!-- Arcticle with testimonial -->
<article class="post post--table <%= String.Join(" ",item.ArticleCategory.Select(t=>t.Category)) %>">
    <a class="post__link-area" href="single-post.html?id=<%= item.DocID %>">
        <div class="testimonial testimonial--string testimonial--short testimonial--secondary">
            <p class="testimonial__text"><%= item.Title %></p>
            <p class="testimonial__author"><%= item.UserProfile.RealName %></p>
        </div>
    </a>
    <div class="post__detail">
        <a class="post__link" href="single-post.html?id=<%= item.DocID %>">
            <%--<h3 class="post__heading"><%= item.Title %></h3>--%>
        <p class="post__date"><%= item.Document.DocDate.ToString("yyyy-MM-dd") %></p>
        <p class="post__text"><%= getBrief(item.ArticleContent) %></p>
        </a>
    </div>
</article>
<!-- end article -->
<%          break;
        case 2: %>
<article class="post post--table blue button <%= String.Join(" ",item.ArticleCategory.Select(t=>t.Category)) %>">
    <a class="image-container image-container--max post__link-area" href="single-post.html?id=<%= item.DocID %>">
        <img src="<%= item.Illustration.HasValue ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/")+item.Attachment.AttachmentID.ToString() + "?stretch=true" : VirtualPathUtility.ToAbsolute("~/images/blog_pic.png") %>" alt="">
    </a>
    <div class="post__detail">
        <a class="post__link" href="single-post.html?id=<%= item.DocID %>">
            <h3 class="post__heading"><%= item.Title %></h3>
        </a>
        <p class="post__date"><%= item.Document.DocDate.ToString("yyyy-MM-dd") %></p>
        <p class="post__text"><%= getBrief(item.ArticleContent) %></p>
    </div>
</article>
<%          break;
        case 3: %>
<article class="post post--table <%= String.Join(" ",item.ArticleCategory.Select(t=>t.Category)) %>">
    <a class="post__link-area" href="single-post.html?id=<%= item.DocID %>">
        <div class="testimonial testimonial--string testimonial--short testimonial--danger">
            <p class="testimonial__text"><%= item.Title %></p>
            <p class="testimonial__author"><%= item.UserProfile.RealName %></p>
        </div>
    </a>
    <div class="post__detail">
        <a class="post__link" href="single-post.html?id=<%= item.DocID %>">
            <%--<h3 class="post__heading"></h3>--%>
        <p class="post__date"><%= item.Document.DocDate.ToString("yyyy-MM-dd") %></p>
        <p class="post__text"><%= getBrief(item.ArticleContent) %></p>
        </a>
    </div>
</article>
            <%  break;
            case 4: %>
<article class="post post--table <%= String.Join(" ",item.ArticleCategory.Select(t=>t.Category)) %>">
    <a class="post__link-area" href="single-post.html?id=<%= item.DocID %>">
        <div class="testimonial testimonial--string testimonial--short testimonial--warnning">
            <p class="testimonial__text"><%= item.Title %></p>
            <p class="testimonial__author"><%= item.UserProfile.RealName %></p>
        </div>
    </a>
    <div class="post__detail">
        <a class="post__link" href="single-post.html?id=<%= item.DocID %>">
            <%--<h3 class="post__heading"></h3>--%>
        <p class="post__date"><%= item.Document.DocDate.ToString("yyyy-MM-dd") %></p>
        <p class="post__text"><%= getBrief(item.ArticleContent) %></p>
        </a>
    </div>
</article>

<%
                break;
        }
    } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IEnumerable<Article> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = ((IEnumerable<Article>)this.Model).OrderByDescending(a => a.DocID);
    }

    String getBrief(String content)
    {
        if (content == null)
            return null;
        String result = Regex.Replace(content.Substring(0, Math.Min(500, content.Length)), "<\\s*[Bb][Rr]\\s*/?\\s*>", "\r\n").Trim();
        result = Regex.Replace(result, @"<[^>]+>|&nbsp;", String.Empty);
        result = Regex.Replace(result, "(\\r\\n){2,}", "\r\n");
        return result.Length > 50 ? (result.Substring(0, 50) + "...").Replace("\r\n", "<br/>") : result.Replace("\r\n", "<br/>");
    }

</script>
