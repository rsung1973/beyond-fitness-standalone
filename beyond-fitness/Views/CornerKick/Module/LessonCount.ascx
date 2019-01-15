<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  var familyLessons =
                        _currentLessons.Join(models.GetTable<RegisterLessonContract>().Where(c => c.CourseContract.CourseContractType.ContractCode == "CFA"), r => r.RegisterID, c => c.RegisterID, (r, c) => c)
                            .Join(models.GetTable<RegisterLessonContract>(), c => c.ContractID, r => r.ContractID, (c, r) => r)
                            .Join(models.GetTable<RegisterLesson>(), c => c.RegisterID, r => r.RegisterID, (c, r) => r);
    int? totalLessons = _currentLessons.Sum(c => (int?)c.Lessons);
    int? attendedLessons = _currentLessons.Sum(c => (int?)c.AttendedLessons);
    int? attendance = (int?)_currentLessons.Sum(c => (int?)c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/));%>
<%  if (familyLessons.Count() > 0)
    {
        var exceptFamily = _currentLessons.Where(r => r.RegisterLessonContract == null || r.RegisterLessonContract.CourseContract.CourseContractType.ContractCode != "CFA");    %>
<%= totalLessons
                    - (exceptFamily.Sum(c=>c.AttendedLessons) ?? 0)
                    - (exceptFamily.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/)) ?? 0)
                    - familyLessons.Sum(c=>c.AttendedLessons)
                    - familyLessons.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/)) %>
<%  }
    else
    { %>
<%= totalLessons.HasValue ? totalLessons
                                        - (attendedLessons ?? 0)
                                        - attendance : 0 %>
<%  } %>
                   / <%= totalLessons ?? 0 %>

<script>
    $('#bonus_link').click(function () {
        showLoading();
        $.post('<%= Url.Action("CheckBonus","LearnerFacet",new { id = _model.UID }) %>', {}, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
        return false;
    });

    $('#undolistDialog_link').click(function () {
        if ($('#undolistDialog_link u').text() == '0')
            return false;
        showLoading();
        $.post('<%= Url.Action("CheckLessonAttendance","LearnerFacet",new { id = _model.UID }) %>', {}, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
        return false;

    });

</script>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    IQueryable<RegisterLesson> _items;
    IQueryable<RegisterLesson> _currentLessons;
    IQueryable<LessonTime> _uncheckedLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

        _items = models.GetTable<RegisterLesson>()
            .Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .Where(r => r.UID == _model.UID)
            .OrderByDescending(r => r.RegisterID);
        _currentLessons = _items.Where(i => i.Attended != (int)Naming.LessonStatus.課程結束);

        _uncheckedLessons = _model.LearnerGetUncheckedLessons(models);
    }

</script>
