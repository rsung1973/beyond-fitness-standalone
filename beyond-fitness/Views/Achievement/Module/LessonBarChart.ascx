<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<canvas id="<%= _chartID %>" height="80"></canvas>
<%  Html.RenderPartial("~/Views/Shared/InitBarChart.ascx"); %>
<script>

    //debugger;
    $(function () {

        var ctx = document.getElementById('<%= _chartID %>').getContext('2d');

        <%--var barChartData = <%  Html.RenderPartial("~/Views/Achievement/Module/LessonBarChartData.ascx", _model); %>;--%>

        var chartConfig = {
            type: 'bar',
            data: null,
            options: {
                tooltips: {
                    mode: 'label'
                },
                legend: {
                    display: true,
                    labels: {
                        fontColor: '#D3D3D3'
                    }
                },
                responsive: true,
                scales: {
                    xAxes: [{
                        stacked: true,
                        ticks: {
                            fontColor: '#D3D3D3'
                        }
                    }],
                    yAxes: [{
                        stacked: true,
                        position: "left",
                        id: "y-axis-0",
                        ticks: {
                            beginAtZero: true,
                            fontColor: '#D3D3D3'
                        }
                    }]
                }
            }
        };

<%--        if ($global.chartJS == undefined) {
            loadScript('<%= VirtualPathUtility.ToAbsolute("~/js/plugin/chartjs2_7_2/chart.min.js") %>', function () {
                $global.chartJS = true;

                // Define a plugin to provide data labels
                Chart.plugins.register({
                    afterDatasetsDraw: function (chart) {
                        var ctx = chart.ctx;

                        chart.data.datasets.forEach(function (dataset, i) {
                            var meta = chart.getDatasetMeta(i);
                            if (!meta.hidden) {
                                meta.data.forEach(function (element, index) {
                                    // Draw the text in black, with the specified font
                                    ctx.fillStyle = '#D3D3D3';

                                    var fontSize = 12;
                                    var fontStyle = 'normal';
                                    var fontFamily = 'Helvetica Neue';
                                    ctx.font = Chart.helpers.fontString(fontSize, fontStyle, fontFamily);

                                    // Just naively convert to string for now
                                    var dataString = dataset.data[index].toString();

                                    // Make sure alignment settings are correct
                                    ctx.textAlign = 'center';
                                    ctx.textBaseline = 'middle';

                                    var padding = 5;
                                    var position = element.tooltipPosition();
                                    if (dataset.data[index] > 0) {
                                        ctx.fillText(dataString, position.x, position.y - (fontSize / 2) + padding);
                                    }
                                });
                            }
                        });
                    }
                });

                //$global.myBarChart = new Chart(ctx, chartConfig);   
            });
        } else {

            //$global.myBarChart = new Chart(ctx, chartConfig);   
        }--%>

        $global.updateBarChart = function(formData) {
            showLoading();
            $.post('<%= Url.Action("InquireBarChart", "Achievement") %>', formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if ($global.myBarChart) {
                        $global.myBarChart.data = data;
                        $global.myBarChart.update();
                    } else {
                        chartConfig.data = data;
                        $global.myBarChart = new Chart(ctx, chartConfig);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        };
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;
    String _chartID = "bar" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
