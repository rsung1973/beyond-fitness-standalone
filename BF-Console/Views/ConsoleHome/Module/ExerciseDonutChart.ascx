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

<%  if (_model.Count() > 0)
    {%>
<div id="<%= _chartID %>" class="dashboard-donut-chart"></div>
<%
    var items = _model.GroupBy(l => l.RegisterLesson.UID)
            .Select(g => new { g.Key, TotalMinutes = (decimal?)g.Sum(l => l.DurationInMinutes) })
            .Where(s => s.TotalMinutes > 0)
            .OrderByDescending(s => s.TotalMinutes)
            .ThenByDescending(s => s.Key)
            .Take(5).ToArray();

    var totalMinutes = items.Sum(s => s.TotalMinutes) ?? 1m;
    var userTable = models.GetTable<UserProfile>();
    var result = items.Select(s => new
    {
        label = userTable.Where(u => u.UID == s.Key).First().FullName(),
        value = Math.Round(s.TotalMinutes.Value * 100 / totalMinutes)
    });

    var working = models.GetTable<CoachWorkplace>();
    CoachWorkplace work;
    var colors = items
        .Select(s => working.Where(w => w.CoachID == s.Key).Count() > 1
            ? "#a4a4a4"
            : (work = working.Where(w => w.CoachID == s.Key).First()).BranchID == (int)Naming.BranchName.南京
                ? "#eeaaaa"
                : work.BranchID == (int)Naming.BranchName.忠孝
                    ? "#93e3ff"
                    : "#c5b6e2").ToArray();
%>
<script>
    $(function () {
        Morris.Donut({
            element: '<%= _chartID %>',
                data: <%= JsonConvert.SerializeObject(result)  %>,
                //                colors: ['#93e3ff', '#b0dd91', '#ffe699', '#f8cbad', '#a4a4a4'],
                colors: <%= JsonConvert.SerializeObject(colors)  %>,
            formatter: function (y) {
                return y + '%'
            }
        });
    });
</script>
<%  }
    else
    {%>
<div class="pie_chart">
    <div class="pie_light">
        目前沒有<br />
        <span>相關累計運動時間</span>
    </div>
</div>

<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;
    String _chartID = $"exerciseDonut{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
    }


</script>
