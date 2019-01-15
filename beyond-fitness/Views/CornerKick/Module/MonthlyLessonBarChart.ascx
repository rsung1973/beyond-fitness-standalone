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

    <canvas id="<%= _chartID %>"></canvas>
<%  
    DateTime endDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(1);
    DateTime startDate = endDate.AddMonths(-12);
     %>
<script>
    $(function () {

        var barChartData = {
            labels: <%= JsonConvert.SerializeObject(getLabels(startDate,endDate)) %>,
            datasets: [{
                backgroundColor: "<%= _model.UserProfileExtension.Gender=="F" ? "rgba(253,92,99, .43)" : "rgba(0,97,210,.43)" %>",
                pointBackgroundColor: "<%= _model.UserProfileExtension.Gender=="F" ? "rgba(253,92,99, 1)" : "rgba(0,97,210, 1)" %>",
                hoverPointBackgroundColor: "#fff",
                pointHighlightStroke: "rgba(151,187,205, 1)",
                data: <%= JsonConvert.SerializeObject(getData(startDate,endDate)) %>,
            }]
        };
        
        var BarConfig = {
            type: 'bar',
            data: barChartData,
            options: {
                responsive: true,
                legend: {
                    display: false,
                },
                title: {
                    display: false,
                }
            }
        };

        var initGraph = $global.initGraph;
        $global.initGraph = function() {
            if(initGraph) {
                initGraph();
            }
            window.myBarChart = new Chart(document.getElementById("<%= _chartID %>"), BarConfig);
        };

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    string _chartID = "barChart" + DateTime.Now.Ticks;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

    }

    IEnumerable<String> getLabels(DateTime startDate, DateTime endDate)
    {
        for (DateTime t = startDate; t < endDate; t = t.AddMonths(1))
        {
            yield return $"{t:yyyy/MM}";
        }
    }

    IEnumerable<int> getData(DateTime startDate, DateTime endDate)
    {
        for (DateTime t = startDate; t < endDate; t = t.AddMonths(1))
        {
            yield return _model.TotalLessonMinutes(models, t, t.AddMonths(1));
        }
    }

</script>
