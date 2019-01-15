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

            <%--<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/chartjs2_7_2/chart.min.js") %>"></script>--%>
            <%  if (_item != null && _item.Status == (int)Naming.GeneralStatus.Successful)
                {
                    var rankItems = _item.ExerciseGameRank.Where(r => r.RankingScore.HasValue);
                    if (rankItems.Count() > 0)
                    {
                        var exerciseItems = models.GetTable<ExerciseGameItem>();    %>
                        <div style="width:600px;"><canvas id="<%= _chartID %>"></canvas></div>
                        <script>
                            $(function () {
                                var RadarConfig = {
                                    type: 'radar',
                                    data: {
                                        labels: <%= JsonConvert.SerializeObject(exerciseItems.Select(x=>x.Exercise).ToArray()) %>,
                                        datasets: [{
                                            label: "分佈圖",
                                            backgroundColor: "rgba(233,157,201,.43)",
                                            pointBackgroundColor: "rgba(220,220,220,1)",
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
                                                beginAtZero: true,
                                                backdropColor: '#FAF0E6',
                                                //maxTicksLimit: 10,
                                                //max: 10,
                                                fontSize: 10,
                                                //backdropPaddingX: 5,
                                                //backdropPaddingY: 5
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

                                if($global.chartJS==undefined) {
                                    loadScript('<%= VirtualPathUtility.ToAbsolute("~/js/plugin/chartjs2_7_2/chart.min.js") %>',function() { 
                                        $global.chartJS=true;
                                        window.myRadar = new Chart(document.getElementById("<%= _chartID %>"), RadarConfig);
                                    });
                                } else {
                                    window.myRadar = new Chart(document.getElementById("<%= _chartID %>"), RadarConfig);
                                }
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
