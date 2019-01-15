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

<%  if (_item != null && _item.Status == (int)Naming.GeneralStatus.Successful)
    {
        var rankItems = _item.ExerciseGameRank.Where(r => r.RankingScore.HasValue);
        if (rankItems.Count() > 0)
        {
            var exerciseItems = models.GetTable<ExerciseGameItem>();    %>
    <canvas id="<%= _chartID %>" class="chart-box"></canvas>
<script>
    $(function () {
        var RadarConfig = {
            type: 'radar',
            data: {
                labels: <%= JsonConvert.SerializeObject(exerciseItems.Select(x=>x.Exercise).ToArray()) %>,
                datasets: [{
                    label: "分佈圖",
                    backgroundColor: "<%= _item.UserProfile.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,.43)" : "rgba(0,97,210,.43)" %>",
                    pointBackgroundColor: "<%= _item.UserProfile.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,1)" : "rgba(0,97,210,1)" %>",
                    data: <%= JsonConvert.SerializeObject(exerciseItems.Select(x=>x.ExerciseGameRank.Where(r=>r.UID==_item.UID).Select(r=>r.RankingScore).FirstOrDefault()).ToArray()) %>,
                }]
            },
            options: {
                 legend: {
                     display: false
                 },
                 scale: {
                     reverse: false,
                     display: true,
                     ticks: {
                         showLabelBackdrop: false,
                         beginAtZero: true,
                         backdropColor: '#e6f1ff',
                         maxTicksLimit: 5,
                         max: 10,
                         fontSize: 5,
                         backdropPaddingX: 5,
                         backdropPaddingY: 5
                     },
                     gridLines: {
                         color: "#fff",
                         lineWidth: 1
                     },
                     pointLabels: {
                         fontSize: 12,
                         fontColor: "#fff"
                     }
                 }
             }        };

        var initGraph = $global.initGraph;
        $global.initGraph = function() {
            if(initGraph) {
                initGraph();
            }
            window.myRadar = new Chart(document.getElementById("<%= _chartID %>"), RadarConfig);
            $global.call('showRadarChartBottom');
        };

    });
</script>
        <%  } %>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    ExerciseGameContestant _model;
    ExerciseGameContestant _item;
    string _chartID = "radarChart" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = _model = (ExerciseGameContestant)this.Model;
    }

</script>
