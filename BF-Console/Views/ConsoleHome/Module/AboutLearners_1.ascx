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
        <div class="col-lg-2 col-md-4 col-sm-4 col-6">
            <h4 class="card-outbound-header m-l-15">我的學生 <i class="zmdi livicon-evo" data-options="name: gift.svg; size: 30px; style: original; strokeWidth:2px;"></i></h4>
        </div>
    </div>
    <div class="card">
        <ul class="row profile_state list-unstyled">
        <%  var lessons = models.GetTable<RegisterLesson>().Where(r => r.AdvisorID == _model.UID);
            var readyLessons = lessons.Where(r => r.Attended == (int)Naming.LessonStatus.準備上課);
            var awardingCount = readyLessons.Where(r => models.GetTable<AwardingLesson>().Any(a => a.RegisterID == r.RegisterID)).Count()
                        + readyLessons.Where(r => models.GetTable<AwardingLessonGift>().Any(a => a.RegisterID == r.RegisterID)).Count(); %>

        <%  DateTime firstDay = DateTime.Today.FirstDayOfMonth();
            var attendedLessons = models.GetTable<LessonTime>()
                    .Where(l => l.AttendingCoach == _model.UID)
                    .Where(l => l.LessonAttendance != null);
            var currentAttendedLessons = attendedLessons
                    .Where(l => l.ClassTime >= firstDay)
                    .Where(l => l.ClassTime < DateTime.Today.AddDays(1))
                    .Join(models.GetTable<GroupingLesson>(), l => l.GroupID, g => g.GroupID, (l, g) => g)
                    .Join(lessons, g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                    .GroupBy(r => r.UID).Count();
            var attendedLessonsLastMonth = attendedLessons
                    .Where(l => l.ClassTime >= firstDay.AddMonths(-1))
                    .Where(l => l.ClassTime < firstDay)
                    .Join(models.GetTable<GroupingLesson>(), l => l.GroupID, g => g.GroupID, (l, g) => g)
                    .Join(lessons, g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                    .GroupBy(r => r.UID).Count();
        %>
            <li class="col-lg-4 col-md-4 col-6">
                <div class="body">
                    <div id="sparkline-pie" class="sparkline-pie"><%= attendedLessonsLastMonth %>,<%= currentAttendedLessons %></div>
                    <h6 class="m-t-25">上月(<%= attendedLessonsLastMonth %>) V.S. 本月(<%= currentAttendedLessons %>)</h6>
                </div>
                <script>
                    $('#sparkline-pie').sparkline('html', {
                        type: 'pie',
                        offset: 85,
                        width: '90px',
                        height: '90px',
                        sliceColors: ['#cbd1d9', '#ffe6aa']
                    });
                </script>
            </li>
            <%
                var contracts = models.GetTable<CourseContract>().Where(c => c.FitnessConsultant == _model.UID);
                var learnerCount = Math.Max(models.GetTable<CourseContractMember>().Join(contracts, m => m.ContractID, c => c.ContractID, (m, c) => m.UID).Distinct().Count(), 1);
                var activeLearnerCount = models.GetTable<CourseContractMember>().Join(contracts.Where(c => c.Expiration >= DateTime.Today), m => m.ContractID, c => c.ContractID, (m, c) => m.UID).Distinct().Count();
                var discontinuation = (learnerCount - activeLearnerCount) * 100 / learnerCount;
                %>
            <li class="col-lg-4 col-md-4 col-6">
                <div class="body">
                    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/Knob.ascx", discontinuation); %>                    <h6 class="m-t-20">不續約比例</h6>
                </div>
            </li>
            <%  Html.RenderPartial("~/Views/ConsoleHome/Module/FocusItemToday.ascx"); %>
        </ul>
    </div>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
