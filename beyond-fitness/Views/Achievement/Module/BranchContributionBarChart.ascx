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
<%--<%  Html.RenderPartial("~/Views/Shared/InitBarChart.ascx"); %>--%>
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
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            fontColor: '#D3D3D3'
                        },
                    }],
                    xAxes: [{
                        ticks: {
                            fontColor: '#D3D3D3'
                        },
                    }]
                }
            }
        };

        $global.updateBranchBarChart = function(formData) {
            showLoading();
            $.post('<%= Url.Action("InquireBranchContributionBarChart", "Achievement") %>', formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if ($global.myBranchBarChart) {
                        $global.myBranchBarChart.data = data;
                        $global.myBranchBarChart.update();
                    } else {
                        chartConfig.data = data;
                        $global.myBranchBarChart = new Chart(ctx, chartConfig);
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
    IQueryable<TuitionAchievement> _model;
    AchievementQueryViewModel _viewModel;
    String _chartID = "branchBar" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
