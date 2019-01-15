<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-xs-4 col-sm-3 profile-pic">
    <% _model.RenderUserPicture(Writer, "profileImg"); %>
    <div class="padding-10">
        <i class="fa fa-birthday-cake"></i>&nbsp;&nbsp;<span class="txt-color-darken"> <%= _model.YearsOld() %>歲</span>
        <br />
        <h4 class="font-md"><strong>
            <% var totalLessons = _currentLessons.Sum(c => (int?)c.Lessons); %>
            <%= totalLessons
                    - _currentLessons.Sum(c=>c.AttendedLessons)
                    - _currentLessons.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/)) %> / <%= totalLessons %></strong>
            <br />
            <small>剩餘/全部 上課數</small>
            <br />
            <strong>
            <%= _currentLessons.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(l=>l.LessonAttendance== null && l.ClassTime<DateTime.Today.AddDays(1))) %> / 
            <%= _currentLessons.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(l=> l.ClassTime>=DateTime.Today && l.LessonAttendance==null)) %></strong>
            <br />
            <small>未完成/已預約 上課數</small>
            <br />
            <small><i class="fa fa-gift"></i>每日小提問答題已得<%= _model.BonusPoint(models) ?? 0 %>點</small>
        </h4>
        <br />
        <a class="btn bg-color-blueLight btn-sm" onclick="showRecentLessons(<%= _model.UID %>);"><i class="fa fa-fw fa-eye"></i>檢視上課記錄</a>
    </div>
</div>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    IQueryable<RegisterLesson> _items;
    IQueryable<RegisterLesson> _currentLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

        _items = models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID)
            .Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .OrderByDescending(r => r.RegisterID);
        _currentLessons = _items.Where(i => i.Attended != (int)Naming.LessonStatus.課程結束);
    }

</script>
