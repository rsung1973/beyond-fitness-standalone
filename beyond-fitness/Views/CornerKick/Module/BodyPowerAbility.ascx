<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<canvas id="<%= _chartID %>" class="chart-box"></canvas>
<script>
    $(function () {
        //debugger;
        var RadarConfig = {
            type: 'radar',
            data: {
                labels: ["柔軟度", "相對肌力", "心肺適能"],
                datasets: [{
                    label: "分佈圖",
                    backgroundColor: "<%= _item.UserProfile.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,.43)" : "rgba(0,97,210,.43)" %>",
                    pointBackgroundColor: "<%= _item.UserProfile.UserProfileExtension.Gender=="F" ? "rgba(253,92,99,1)" : "rgba(0,97,210,1)" %>",
                    data: <%= _item!=null ? $"[{_item.Flexibility},{_item.MuscleStrength},{_item.Cardiopulmonary}]" : "[, , ]"  %>,
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
                        max: 5,
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

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    PersonalExercisePurpose _item;
    string _chartID = "radarChart" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _item = (PersonalExercisePurpose)this.Model;
    }

</script>
