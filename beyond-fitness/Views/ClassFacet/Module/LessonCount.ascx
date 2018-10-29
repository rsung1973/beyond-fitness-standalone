<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="head" style="bottom center no-repeat;">
    <%  ViewBag.IsLearner = true;
        Html.RenderPartial("~/Views/Member/Module/MemberPhoto.ascx", _model); %>
    <div class="head-panel nm">
        <div class="hp-info pull-left">
            <div class="hp-icon">
                <span class="fa fa-birthday-cake"></span>
            </div>
            <span class="hp-main"><%= _model.YearsOld() %></span>
            <span class="hp-sm">Age</span>
        </div>
        <div class="hp-info pull-left" onclick="diagnose();" >
            <div class="hp-icon">
                <span class="fa fa-diagnoses"></span>
            </div>
            <span class="hp-main"><%= String.Format("{0:.}",_model.BodyDiagnosis.Count) %></span>
            <span class="hp-sm">Dx.</span>
        </div>
        <div class="hp-info pull-left" onclick="checkBonus(<%= _model.UID %>);" >
            <div class="hp-icon">
                <span class="fa fa-gift"></span>
            </div>
            <span class="hp-main"><%= _model.BonusPoint(models) ?? 0 %></span>
            <span class="hp-sm">Point</span>
        </div>
        <div class="hp-info pull-left">
            <div class="hp-icon">
                <font color="red"><span class="fa fa-tint"></span></font>
            </div>
            <%  var totalLessons = _currentLessons.Sum(c => (int?)c.Lessons);
                        var familyLessons =
                            _currentLessons.Join(models.GetTable<RegisterLessonContract>().Where(c => c.CourseContract.CourseContractType.ContractCode == "CFA"), r => r.RegisterID, c => c.RegisterID, (r, c) => c)
                                .Join(models.GetTable<RegisterLessonContract>(), c => c.ContractID, r => r.ContractID, (c, r) => r)
                                .Join(models.GetTable<RegisterLesson>(), c => c.RegisterID, r => r.RegisterID, (c, r) => r); %>
            <font color="red"><span class="hp-main">
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
                        <%= totalLessons
                    - _currentLessons.Sum(c=>c.AttendedLessons)
                    - _currentLessons.Where(c=>c.RegisterGroupID.HasValue).Sum(c=>(int?)c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/)) %>
                        <%  } %>
                              </span></font>
            <span class="hp-sm"><%= totalLessons %></span>
        </div>
        <div class="hp-info pull-right">
            <a onclick="editPowerAbility();" id="powerAbility"></a>&nbsp;&nbsp;
            <script>
                $(function () {
                    showAbility('<%= _model.PersonalExercisePurpose!=null && _model.PersonalExercisePurpose.PowerAbility!=null
                                                                                                                  ? _model.PersonalExercisePurpose.PowerAbility : null %>');
                });
                
                function showAbility(data) {
                    var $a = $('#powerAbility');
                    if (data.indexOf('初') >= 0) {
                        $a.attr('class', 'btn btn-circle btn-warning');
                    } else if (data.indexOf('中') >= 0) {
                        $a.attr('class', 'btn btn-circle btn-success');
                    } else if (data.indexOf('高') >= 0) {
                        $a.attr('class', 'btn btn-circle btn-danger');
                    } else {
                        $a.attr('class', 'btn btn-circle bg-color-blueLight');
                    }
                    if (data.indexOf('變') >= 0) {
                        $a.text('變');
                    } else if (data.indexOf('守') >= 0) {
                        $a.text('守');
                    } else if (data.indexOf('混') >= 0) {
                        $a.text('混');
                    } else {
                        $a.text('無');
                    }
                }
            </script>
        </div>
        <%  Html.RenderPartial("~/Views/ClassFacet/Module/CurrentQuestionnaire.ascx", _lesson); %>
        <%--<%
            var questItems = models.GetTable<QuestionnaireRequest>()
                .Where(q => q.UID == _model.UID)
                .Where(q => !q.Status.HasValue || q.Status == (int)Naming.IncommingMessageStatus.未讀)
                .Where(q => q.PDQTask.Any());


            if (questItems.Count()>0)
            { %>
        <div class="hp-info pull-right" onclick="showLearnerQuestionnaire(<%= questItems.OrderByDescending(q => q.QuestionnaireID).Select(q => q.QuestionnaireID).First() %>);">
            <div class="hp-icon">
                <span class="fa fa-volume-up text-success"></span>
            </div>
            <span class="hp-main text-success"><%= questItems.Count() %></span>
            <span class="hp-sm text-success">New</span>
        </div>
        <%  } %>--%>
    </div>
</div>

<script>
    function diagnose(diagnosisID) {
        showLoading();
        $.post('<%= Url.Action("Diagnose","FitnessDiagnosis",new { uid = _model.UID }) %>', { 'diagnosisID': diagnosisID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function checkBonus(id) {
        showLoading();
        $.post('<%= Url.Action("CheckBonus","LearnerFacet") %>', { 'id': id }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
        return false;
    }

    function editPowerAbility() {
        showLoading();
        $.post('<%= Url.Action("EditPowerAbility","ClassFacet",new { uid = _model.UID }) %>', { }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }


</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    LessonTime _item;
    RegisterLesson _lesson;

    IQueryable<RegisterLesson> _items;
    IQueryable<RegisterLesson> _currentLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
        _lesson = (RegisterLesson)ViewBag.RegisterLesson;

        _items = models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID)
            .Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .OrderByDescending(r => r.RegisterID);
        _currentLessons = _items.Where(i => i.Attended != (int)Naming.LessonStatus.課程結束
            && (i.RegisterLessonContract == null || (i.RegisterLessonContract != null && i.RegisterLessonContract.CourseContract.Expiration >= DateTime.Today))
            || (i.RegisterLessonEnterprise != null && i.RegisterLessonEnterprise.EnterpriseCourseContract.Expiration >= DateTime.Today));
    }

</script>
