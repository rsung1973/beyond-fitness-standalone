<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<canvas id="<%= _chartID %>"></canvas>
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
                        //stacked: true,
                        ticks: {
                            fontColor: '#D3D3D3'
                        }
                    }],
                    yAxes: [{
                        //stacked: true,
                        //position: "left",
                        //id: "y-axis-0",
                        ticks: {
                            beginAtZero: true,
                            fontColor: '#D3D3D3'
                        }
                    }]
                }
            }
        };

        $global.updateLearnerToCompleteBarChart = function(formData) {
            showLoading();
            $.post('<%= Url.Action("InquireLearnerToCompleteBarChart", "Achievement") %>', formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if ($global.myLearnerBarChart) {
                        $global.myLearnerBarChart.data = data;
                        $global.myLearnerBarChart.update();
                    } else {
                        chartConfig.data = data;
                        $global.myLearnerBarChart = new Chart(ctx, chartConfig);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        };

        <%  if(_model!=null)
            {   %>
        chartConfig.data = <%  Html.RenderPartial("~/Views/Achievement/Module/LearnerToCompleteBarChartData.ascx", _model); %>;
        $global.myLearnerBarChart = new Chart(ctx, chartConfig);
        <%  }   %>

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
