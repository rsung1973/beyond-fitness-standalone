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
<script>
    $(function () {
        var RadarConfig = {
            type: 'radar',
            data: {
                labels: ["身體質量", "相對肌力", "爆發力", "柔軟度", "心肺適能"],
                datasets: [{
                    label: "分佈圖",
                    backgroundColor: "<%= _model.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,.43)" : "rgba(0,97,210,.43)" %>",
                    pointBackgroundColor: "<%= _model.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,1)" : "rgba(0,97,210,1)" %>",
                    data: [0, 0, 0, 0, 0],
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
                        backdropColor: '#0061d2',
                        maxTicksLimit: 5,
                        max: 10,
                        fontSize: 5,
                        backdropPaddingX: 5,
                        backdropPaddingY: 5
                    },
                    gridLines: {
                        color: "#888888",
                        lineWidth: 1
                    },
                    pointLabels: {
                        fontSize: 12,
                        fontColor: "#AAAAAA"
                    }
                }
            }
        };

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

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    string _chartID = "radarChart" + DateTime.Now.Ticks;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
