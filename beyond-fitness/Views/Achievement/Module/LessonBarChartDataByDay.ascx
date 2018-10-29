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
<%= JsonConvert.SerializeObject(result) %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;
    String _chartID = "bar" + DateTime.Now.Ticks;
    Object result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;


        List<_ResultItem> items = new List<_ResultItem>();

        for (DateTime t = _viewModel.AchievementDateFrom.Value; t <= _viewModel.AchievementDateTo.Value; t = t.AddDays(1))
        {
            var lessons = _model.Where(l => l.ClassTime >= t && l.ClassTime < t.AddDays(1));
            items.Add(new _ResultItem
            {
                ClassTime = t,
                PTCount = lessons.PTLesson().Count(),
                PICount = lessons.Where(l => l.TrainingBySelf == 1).Count(),
                TrialCount = lessons.TrialLesson().Count()
            });
        }


        result = new
        {
            labels = items.Select(g => String.Format("{0:yyyy/MM/dd}", g.ClassTime)),
            datasets = new object[]
            {
                new
                {
                    type= "bar",
                    label= "P.T",
                    yAxisID= "y-axis-0",
                    backgroundColor= "rgba(184,227,243,.43)",
                    data= items.Select(g=>g.PTCount),
                },
                new
                {
                    type= "bar",
                    label= "P.I",
                    yAxisID= "y-axis-0",
                    backgroundColor= "rgba(255,7,7,.43)",
                    data= items.Select(g=>g.PICount),
                },
                new
                {
                    type= "bar",
                    label= "體驗",
                    yAxisID= "y-axis-0",
                    backgroundColor= "rgba(233,157,201,.43)",
                    data= items.Select(g=>g.TrialCount),
                }
            }
        };
    }

    class _ResultItem
    {
        public DateTime? ClassTime { get; set; }
        public int Hour { get; set; }
        public int PTCount { get; set; }
        public int PICount { get; set; }
        public int TrialCount { get; set; }
    }
</script>
