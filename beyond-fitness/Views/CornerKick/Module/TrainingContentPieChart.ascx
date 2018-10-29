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

    <canvas id="<%= _chartID %>" class="chart-box"></canvas>
<%  var items = models.GetTable<TrainingStage>()
        .Select(s => new
        {
            s.Stage,
            TotalMinutes = _model.Where(t => t.StageID == s.StageID).Sum(t => t.TotalMinutes) ?? 0
        }).ToArray();

    var total = items.Sum(t => t.TotalMinutes);

    IQueryable<TrainingExecutionStage> compareTo = (IQueryable<TrainingExecutionStage>)ViewBag.CompareTo;
    var compareToItems = models.GetTable<TrainingStage>()
        .Select(s => new
        {
            s.Stage,
            TotalMinutes = compareTo.Where(t => t.StageID == s.StageID).Sum(t => t.TotalMinutes) ?? 0
        }).ToArray();

    var totalCompareTo = compareToItems.Sum(t => t.TotalMinutes);
    if (totalCompareTo == 0)
        totalCompareTo = 1m;

     %>
<script>
    $(function () {
        
        var PieConfig = {
            type: 'pie',
            data: {
                datasets: [{
                    data: <%= JsonConvert.SerializeObject(items.Select(t=>Math.Round(t.TotalMinutes*100/total)).ToArray()) %>,
                    dataCompareTo: <%= JsonConvert.SerializeObject(compareToItems.Select(t=>Math.Round(t.TotalMinutes*100/totalCompareTo)).ToArray()) %>,
                    backgroundColor: [
                        'rgba(245, 166, 35, .8)',
                        'rgba(255, 78, 100, .8)',
                        'rgba(126, 211, 33, .8)',
                        'rgba(74, 144, 226, .8)',
                        'rgba(244, 237, 0, .8)',
                    ],
                    label: '',
                    borderWidth: [1, 1, 1, 1],
                }],
                labels: <%= JsonConvert.SerializeObject(items.Select(t=>t.Stage).ToArray()) %>,
            },
            options: {
                responsive: true,
                legend: {
                    display: false
                },

                title: {
                    display: false
                },
                animation: {
                    animateScale: true,
                    animateRotate: true
                }
            }
        };

        var initGraph = $global.initGraph;
        $global.initGraph = function() {
            if(initGraph) {
                initGraph();
            }
            window.myPieChart = new Chart(document.getElementById("<%= _chartID %>"), PieConfig);
            $global.call('showPieChartBottom');
        };

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    string _chartID = "pieChart" + DateTime.Now.Ticks;
    IQueryable<TrainingExecutionStage> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TrainingExecutionStage>)this.Model;

    }

</script>
