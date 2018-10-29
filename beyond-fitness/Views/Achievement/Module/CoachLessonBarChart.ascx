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

        $global.updateCoachBarChart = function(formData) {
            showLoading();
            $.post('<%= Url.Action("InquireCoachBarChart", "Achievement") %>', formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if ($global.myCoachBarChart) {
                        $global.myCoachBarChart.data = data;
                        $global.myCoachBarChart.update();
                    } else {
                        chartConfig.data = data;
                        $global.myCoachBarChart = new Chart(ctx, chartConfig);
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
