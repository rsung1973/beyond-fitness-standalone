<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  if (_items.Count() > 0)
    {
        Html.RenderPartial("~/Views/CornerKick/Module/TrainingContentPieChart.ascx", _items);
    }
    else
    {   %>
<div class="pie">
    <div class="pie_light">
        您沒有<br />
        <span>相關累計運動時間</span>
    </div>
</div>
<%  }   %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    string _chartID = "pieChart" + DateTime.Now.Ticks;
    IQueryable<TrainingExecutionStage> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

        DateTime startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);

        _items = models.GetTable<RegisterLesson>().Where(f => f.UID == _model.UID)
           .TotalLessons(models)
           .Where(l => l.ClassTime >= startDate && l.ClassTime < DateTime.Today.AddDays(1))
           .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
           .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
           .Join(models.GetTable<TrainingExecutionStage>(), x => x.ExecutionID, s => s.ExecutionID, (x, s) => s);

        DateTime lastStart = startDate.AddMonths(-1);

        var compareTo = models.GetTable<RegisterLesson>().Where(f => f.UID == _model.UID)
           .TotalLessons(models)
           .Where(l => l.ClassTime >= lastStart && l.ClassTime<startDate)
           .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
           .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
           .Join(models.GetTable<TrainingExecutionStage>(), x => x.ExecutionID, s => s.ExecutionID, (x, s) => s);

        ViewBag.CompareTo = compareTo;
    }

</script>
