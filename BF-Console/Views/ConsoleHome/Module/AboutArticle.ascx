<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="<%= $"col-sm-{12/_allotment} col-12" %>">
    <h4 class="card-outbound-header">專業文章</h4>
    <div class="parallax-img-card">
        <div class="royalSlider contentSlider rsDefault" id="article-slider">
            <%  foreach (var item in _items)
                { %>
            <div class="rsTextSlide">
                <img class="rsImg" src="<%= Url.Action("GetResource","Information",new { id = item.Attachment?.AttachmentID, stretch = false }) %>" data-rsh="" data-rsw="" />
                <a href="#">
                    <h3 class="bottommask"><%= item.Title %></h3>
                </a>
                <%--<span class="rsTmb"><%= $"{_items[i].Document.DocDate:MM/dd}" %></span>--%>
            </div>
            <%  } %>
        </div>
    </div>
</div>

<script>
    $(function () {
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
            transitionType: 'fade'
        }).resize();
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    List<Article> _items;
    //static String[] __Articles = {
    //    "images/carousel/article-background-1.jpg",
    //    "images/carousel/article-background-2.jpg",
    //    "images/carousel/article-background-3.jpg",
    //    "images/carousel/article-background-4.jpg",
    //    "images/carousel/article-background-5.jpg"
    //};
    int _allotment;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        var items = models.GetTable<Article>()
                .Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.正常)
                .Where(a => a.DocID >= 21961)
                .OrderByDescending(a => a.DocID);

        var totalCount = items.Count();
        Random rand = new Random((int) DateTime.Now.Ticks & 0x0000FFFF);

        _items = new List<Article>();
        while (_items.Count < Math.Min(totalCount, 5))
        {
            var idx = rand.Next(totalCount);
            var item = items.Skip(idx).Take(1).FirstOrDefault();
            if (item != null)
                _items.Add(item);
        }
        _allotment = ((int?)ViewBag.Allotment) ?? 2;
    }


</script>
