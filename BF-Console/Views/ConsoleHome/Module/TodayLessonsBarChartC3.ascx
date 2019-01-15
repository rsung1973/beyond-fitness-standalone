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

<%  var items = models.GetTable<LessonTime>().Where(l => l.ClassTime >= DateTime.Today && l.ClassTime < DateTime.Today.AddDays(1));
    if(_model.IsManager() || _model.IsViceManager())
    {
        var branch = models.GetTable<BranchStore>().Where(b => b.ManagerID == _model.UID || b.ViceManagerID == _model.UID)
                .Select(b => b.BranchID).FirstOrDefault();
        items = items.Where(l => l.BranchID == branch);
    }

    var PTLessons = items.PTLesson()
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();
    var PILessons = items.Where(l => l.TrainingBySelf == 1)
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();
    var TrialLessons = items.TrialLesson()
            .Select(l => l.ClassTime.Value.Hour)
            .GroupBy(h => h)
            .Select(g => new _Counting { Hour = g.Key, Count = g.Count() })
            .ToList();

    %>
<div id="<%= _chartID %>" class="c3"></div>
<script>

    $(function () {
        var chart = c3.generate({
            bindto: '#<%= _chartID %>', // id of chart wrapper
            data: {
                columns: [
                    // each columns data
                    ['data1'],
                    ['data2'],
                    ['data3'],
                ],
                type: 'bar', // default type of chart
                groups: [
                    ['data1', 'data2', 'data3']
                ],
                colors: {
                    'data1': '#ffe6aa',
                    'data2': '#c5b6e2',
                    'data3': '#eeaaaa'
                },
                names: {
                    // name of each serie
                    'data1': 'P.T',
                    'data2': 'P.I',
                    'data3': '體驗'
                },
                labels: true,
            },
            axis: {
                x: {
                    type: 'category',
                    // name of each category
                    categories: <%= JsonConvert.SerializeObject(_hourIdx.Select(h=>$"{h:00}:00")) %>
                },
            },
            bar: {
                width: 25
            },
            legend: {
                show: true, //hide legend
            },
            padding: {
                bottom: 0,
                top: 0
            },
            grid: {
                x: {
                    show: false
                },
                y: {
                    show: true
                }
            }
        });

        setTimeout(function () {
            chart.load({
                columns: [<%= JsonConvert.SerializeObject(getDistributionC3("data1",PTLessons)) %>]
            });
        }, 1000);

        setTimeout(function () {
            chart.load({
                columns: [<%= JsonConvert.SerializeObject(getDistributionC3("data2",PILessons)) %>]
            });
        }, 1500);

        setTimeout(function () {
            chart.load({
                columns: [<%= JsonConvert.SerializeObject(getDistributionC3("data3",TrialLessons)) %>]
            });
        }, 2000);

        setTimeout(function () {
            chart.groups([['data1', 'data2', 'data3']])
        }, 2500);
    });
</script>
<%  Html.RenderPartial("~/Views/ConsoleHome/Shared/InitBarChartNoRegister.ascx"); %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    string _chartID = "lessonsBar" + DateTime.Now.Ticks;
    IEnumerable<int> _hourIdx;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _hourIdx = Enumerable.Range(7, 16);

    }

    class _Counting
    {
        public int Hour { get; set; }
        public int Count { get; set; }
    }

    IEnumerable<int> getDistribution(IEnumerable<_Counting> items)
    {
        foreach(var h in _hourIdx)
        {
            yield return items.Where(i => i.Hour == h).Select(i => i.Count).FirstOrDefault();
        }
    }

    IEnumerable<object> getDistributionC3(String columnName,IEnumerable<_Counting> items)
    {
        List<object> result = new List<object>();
        result.Add(columnName);
        foreach(var h in _hourIdx)
        {
            result.Add(items.Where(i => i.Hour == h).Select(i => i.Count).FirstOrDefault());
        }
        return result;
    }

</script>
