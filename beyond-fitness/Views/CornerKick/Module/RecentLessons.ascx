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

<div class="class-block">
    <h3>課表內容</h3>
    <!--Slider-->
    <div class="royalSlider contentSlider rsDefault" id="class-slider">
        <%  LessonTime todayLesson = null;
            if (_items.Count == 0)
            {   %>
        <div class="rsTextSlide">
            <div class="row valign-wrapper">
                <div class="col s4 m3 l2">
                        <img src="images/avatars/noname.png" alt="" class="circle responsive-img valign">
                </div>
                <div class="col s8 m9 l10 text-box">
                    <span class="black-t18">Ooooooops！目前沒有上課耶！</span>
                </div>
            </div>
        </div>
        <%  }
            else
            {
                foreach (var item in _items)
                {
                    if (item.ClassTime.Value.Date == DateTime.Today)
                    {
                        todayLesson = item;
                    } %>
        <div class="rsTextSlide">
            <div class="row valign-wrapper">
                <div class="col s4 m3 l2">
                    <a href="javascript:gtag('event', '課表內容', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("ViewLesson","CornerKick",new { keyID = HttpUtility.UrlEncode(item.LessonID.EncryptKey()) }) %>';">
                        <%  ViewBag.ImgClass = "circle responsive-img valign";
                            Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", item.AsAttendingCoach.UserProfile);
                        %>
                    </a>
                </div>
                <div class="col s8 m9 l10 text-box">
                    <span class="black-t18">
                        <a href="javascript:gtag('event', '課表內容', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});window.location.href = '<%= Url.Action("ViewLesson","CornerKick",new { keyID = HttpUtility.UrlEncode(item.LessonID.EncryptKey()) }) %>';"><%= $"{item.ClassTime:yyyy/MM/dd HH:mm}" %></a>
                    </span>
                    <span class="black-t12"><%= item.TrainingPlan.FirstOrDefault()?.TrainingExecution.Emphasis %></span>
                </div>
            </div>
            <span class="rsTmb"><%= $"{item.ClassTime:MM/dd}" %></span>
        </div>
        <%      }
            } %>
    </div>
    <!-- // End of Slider  -->
</div>
<script>
    $(function () {

        $('#class-slider').royalSlider({
            autoHeight: true,
            arrowsNav: false,
            fadeinLoadedSlide: false,
            controlNavigationSpacing: 0,
            controlNavigation: '<%= _items.Count>0 ? "tabs" : "none" %>',
            imageScaleMode: 'none',
            imageAlignCenter: false,
            loop: true,
            loopRewind: true,
            numImagesToPreload: 5,
            keyboardNavEnabled: true,
            usePreloader: false,
            startSlideId: <%= _items.Count>0
                                ? todayLesson!=null
                                    ? _items.IndexOf(todayLesson)
                                    :_items.Count-1
                                : 0 %>,
        });
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    List<LessonTime> _items;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        _items = models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID)
                    .TotalLessons(models)
                    .OrderByDescending(l => l.ClassTime)
                    .Take(3)
                    .OrderBy(l => l.ClassTime).ToList();

    }

</script>
