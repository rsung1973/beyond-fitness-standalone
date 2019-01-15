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
<script>

    //debugger;
    $(function () {

        var ctx = document.getElementById('<%= _chartID %>').getContext('2d');

        var chartConfig = {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: null,
                    backgroundColor:
                        [<%  if (_branch.BranchID == 1)
    {   %>
                        'rgba(146, 203, 128, .8)',
                            'rgba(69, 167, 52, .8)',
                            'rgba(59, 109, 44, .8)',
                            'rgba(18, 35, 16, .8)',
                    <%      }
    else if (_branch.BranchID == 2)
    {   %>
                        'rgba(223, 152, 134, 1)',
                            'rgba(209, 109, 82, 1)',
                            'rgba(182, 76, 47, 1)',
                            'rgba(122, 51, 31, 1)',
                    <%      }
    else
    {   %>
                        'rgba(161, 221, 219, .8)',
                            'rgba(76, 191, 188, .8)',
                            'rgba(47, 131, 128, .8)',
                            'rgba(27, 75, 73, .8)',
                    <%      }   %>
                        ],
                    label: '',
                    borderWidth: [1, 1, 1,1]
                }],
                labels: [
                    '續約合約',
                        '新合約',
                        'P.I',
                        '其他'
                ]
            },
            options: {
                responsive: true,
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        fontColor: '#D3D3D3'
                    }
                },

                title: {
                    display: true,
                    text: '<%= _branch.BranchName + "(%)" %>',
                    fontColor: '#D3D3D3'
                },
                animation: {
                    animateScale: true,
                    animateRotate: true
                }
            }
        };

        if (!$global.updateBranchDonut) {
            $global.updateBranchDonut = [];
            $global.myBranchDonut = [];
        }

        $global.updateBranchDonut[<%= _branch.BranchID %>] = function (formData) {
            showLoading();
            $.post('<%= Url.Action("InquireBranchContributionDonut", "Achievement",new { _branch.BranchID }) %>', formData, function (data) {
                hideLoading();
                if (Array.isArray(data)) {
                    if ($global.myBranchDonut[<%= _branch.BranchID %>]) {
                        $global.myBranchDonut[<%= _branch.BranchID %>].data.datasets[0].data = data;
                        $global.myBranchDonut[<%= _branch.BranchID %>].update();
                    } else {
                        chartConfig.data.datasets[0].data = data;
                        $global.myBranchDonut[<%= _branch.BranchID %>] = new Chart(ctx, chartConfig);
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
    String _chartID;
    BranchStore _branch;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
        _branch = (BranchStore)ViewBag.BranchStore;
        if (_branch == null)
            _branch = models.GetTable<BranchStore>().First();
        _chartID = $"donut{DateTime.Now.Ticks}_{_branch.BranchID}";
    }

</script>
