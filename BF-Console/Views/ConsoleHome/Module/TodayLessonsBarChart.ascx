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

<%  var items = models.GetTable<LessonTime>().Where(l => l.ClassTime >= DateTime.Today && l.ClassTime < DateTime.Today.AddDays(1));
    if(_model.IsManager() || _model.IsViceManager())
    {
        var branch = models.GetTable<BranchStore>().Where(b => b.ManagerID == _model.UID || b.ViceManagerID == _model.UID)
                .Select(b => b.BranchID).FirstOrDefault();
        items = items.Where(l => l.BranchID == branch);
    }

    var PTLessons = items.PTLesson()
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();
    var PILessons = items.Where(l => l.TrainingBySelf == 1)
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();
    var TrialLessons = items.TrialLesson()
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();

    %>
<canvas id="<%= _chartID %>" class="bar-chart"></canvas>
<script>
    $(function () {
        var barChartData = {
            labels: <%= JsonConvert.SerializeObject(_hourIdx.Select(h=>$"{h:00}:00")) %>,
            datasets: [{
                label: "P.T",
                backgroundColor: "rgba(245, 166, 35, .43)",
                data: <%= JsonConvert.SerializeObject(getDistribution(PTLessons)) %>
            }, {
                label: "P.I",
                backgroundColor: "rgba(238,170,170, .43)",
                data: <%= JsonConvert.SerializeObject(getDistribution(PILessons)) %>
            }, {
                label: "體驗",
                backgroundColor: "rgba(197,182,226, .43)",
                data: <%= JsonConvert.SerializeObject(getDistribution(TrialLessons)) %>
            }]
        };
        var chartConfig = {
            type: 'bar',
            data: barChartData,
            options: {
                responsive: true,
                legend: false,
                scales: {
                    xAxes: [{
                        stacked: true,
                        beginAtZero: true,
                        fontColor: '#05232d',
                        ticks: {
                            fontSize: 18,
                            fontStyle: 'bold'
                        }
                    }],
                    yAxes: [{
                        stacked: true,
                        beginAtZero: true,
                        fontColor: '#05232d',
                        ticks: {
                            fontSize: 20,
                            fontStyle: 'bold'
                        }
                    }]
                }
            }
        };

        var initGraph = $global.initGraph;
        $global.initGraph = function () {
            if (initGraph) {
                initGraph();
            }
            window.myBarChart = new Chart(document.getElementById("<%= _chartID %>"), chartConfig);
        };

    });
</script>
<%  Html.RenderPartial("~/Views/ConsoleHome/Shared/InitBarChartNoRegister.ascx"); %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    string _chartID = "lessonsBar" + DateTime.Now.Ticks;
    IEnumerable<int> _hourIdx;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _hourIdx = Enumerable.Range(7, 16);

    }

    class _Counting
    {
        public int Hour { get; set; }
        public int Count { get; set; }
    }

    IEnumerable<int> getDistribution(IEnumerable<_Counting> items)
    {
        foreach(var h in _hourIdx)
        {
            yield return items.Where(i => i.Hour == h).Select(i => i.Count).FirstOrDefault();
        }
    }

</script>
