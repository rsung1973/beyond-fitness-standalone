<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="article-block">
    <h3>專業文章</h3>
    <!--Slider-->
    <div class="royalSlider contentSlider rsDefault" id="article-slider">
        <%  for (int i = 0; i < 5; i++)
            { %>
        <div class="rsTextSlide">
            <img class="rsImg" src="<%= __Articles[i] %>" data-rsh="" data-rsw="">
            <a onclick="gtag('event', '專業文章', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});" href="<%= "../../front-end/single-post.html?id=" + _items[i].DocID %>" target="_blank">
                <h3><%= _items[i].Title %></h3>
            </a>
        </div>
        <%  } %>
    </div>
    <!-- // End of Slider  -->
</div>
<script>
    $(function () {
        //Slider
        $('#article-slider').royalSlider({
            autoHeight: true,
            arrowsNav: true,
            arrowsNavAutoHide: false,
            fadeinLoadedSlide: false,
            controlNavigationSpacing: 0,
            controlNavigation: 'none',
            imageScaleMode: 'none',
            imageAlignCenter: false,
            loop: true,
            loopRewind: true,
            numImagesToPreload: 5,
            keyboardNavEnabled: true,
            usePreloader: false,
            transitionType: 'fade',
        });
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    List<Article> _items;
    static String[] __Articles = {
        "images/carousel/article-background-1.jpg",
        "images/carousel/article-background-2.jpg",
        "images/carousel/article-background-3.jpg",
        "images/carousel/article-background-4.jpg",
        "images/carousel/article-background-5.jpg"
    };


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        _items = models.GetTable<Article>()
                .Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.正常)
                .OrderByDescending(a => a.DocID)
                .Take(5).ToList();

    }

</script>
