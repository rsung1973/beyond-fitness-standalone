<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="container-fluid">
    <div class="row clearfix">
        <div class="col-lg-12 col-md-12">
            <div class="row clearfix">
                <div class="col-sm-6 col-12">
                    <h4 class="card-outbound-header">專業文章</h4>
                    <div class="parallax-img-card">
                        <div class="royalSlider contentSlider rsDefault" id="article-slider">
                        <%  for (int i = 0; i < 5; i++)
                            { %>
                            <div class="rsTextSlide">
                                <img class="rsImg" src="<%= __Articles[i] %>" data-rsh="" data-rsw="">
                                <a href="#">
                                    <h3><%= _items[i].Title %></h3>
                                </a>
                                <span class="rsTmb"><%= $"{_items[i].Document.DocDate:MM/dd}" %></span>
                            </div>
                            <%  } %>
                        </div>
                    </div>
                </div>
                <%  if (!_model.IsServitor())
                    {
                        Html.RenderPartial("~/Views/ConsoleHome/Module/AboutContest.ascx", _model);
                    }
                    else
                    {
                        Html.RenderPartial("~/Views/ConsoleHome/Module/AboutDailyQuestion.ascx", _model);
                    }
                    %>
            </div>
        </div>
    </div>
</div>
<script>
$(function(){
            $('#article-slider').royalSlider({
                autoHeight: true,
                arrowsNav: false,
                fadeinLoadedSlide: false,
                controlNavigationSpacing: 0,
                controlNavigation: 'tabs',
                imageScaleMode: 'none',
                imageAlignCenter: false,
                loop: true,
                loopRewind: true,
                numImagesToPreload: 5,
                keyboardNavEnabled: true,
                usePreloader: false,                
                startSlideId: 2
            }).resize();
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
