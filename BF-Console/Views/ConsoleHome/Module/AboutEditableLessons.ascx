<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  var weekStart = DateTime.Today.FirstDayOfWeek(); %>
<li class="<%= $"col-sm-{12/_allotment} col-{12/_allotment} calendar-todolist" %>">
    <div class="body">
        <i class="zmdi livicon-evo" data-options="name: pencil.svg; size: 40px; style: original; strokeWidth:2px;"></i>
        <h4><%= _editableLessons
                    .Where(l => l.ClassTime >= weekStart && l.ClassTime < weekStart.AddDays(7))
                    .Where(l=>l.LessonAttendance==null).Count() %></h4>
        <span>本週編輯中</span>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _editableLessons;
    UserProfile _model;
    int _allotment;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _allotment = ((int?)ViewBag.Allotment) ?? 2;

        IQueryable<LessonTime> items = ViewBag.LessonTimeItems as IQueryable<LessonTime>;
        _editableLessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());

    }


</script>
