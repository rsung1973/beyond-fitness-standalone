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

<div class="row">
    <div class="caption text-center">能量/肌力系統強度</div>
    <div id="<%= "muscleStrength"+_first.AssessmentID %>" class="chart no-padding"></div>
</div>

<script>
    <%

    var strengthData = _items
        .Select(g =>
            new
            {
                g.LessonTime.ClassTime,
                Item17 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 17).FirstOrDefault(),
                Item16 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 16).FirstOrDefault(),
                Item52 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 52).FirstOrDefault()
            })
        .Select(g =>
            new
            {
                period = String.Format("{0:yyyy-MM-dd}", g.ClassTime),
                energy = _profile.Birthday.HasValue && g.Item16 != null && g.Item17 != null ? filterZero((g.Item17.TotalAssessment - g.Item16.TotalAssessment) / (206.9m - (0.67m * (DateTime.Today.Year - _profile.Birthday.Value.Year) - g.Item16.TotalAssessment) * 100 + 0.5m)) : null,
                strength = g.Item52 != null ? filterZero(g.Item52.TotalAssessment) : null
            }).ToArray();

      %>
    $(function () {
        var strengthData = <%= JsonConvert.SerializeObject(strengthData,new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;

        Morris.Line({
            element: '<%= "muscleStrength"+_first.AssessmentID %>',
            data: strengthData,
            xkey: 'period',
            yLabelFormat: function(y) {
                if (typeof(y) != 'undefined') {
                    return parseFloat(y) + '%';
                } else {
                    return '--';
                }
            },
            xLabelAngle: 30.0,
            ykeys: ['energy','strength'],
            resize: true,
            labels: ['能量','肌力']
        });

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonFitnessAssessment> _model;
    IQueryable<LessonFitnessAssessment> _items;
    LessonFitnessAssessment _first;
    LessonFitnessAssessment _last;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonFitnessAssessment>)this.Model;
        _items = _model.OrderBy(r => r.AssessmentID);
        _first = _items.First();
        _last = _model.OrderByDescending(r => r.AssessmentID).First();
        _profile = _first.UserProfile;
    }

    decimal? filterZero(decimal? decVal)
    {
        return decVal > 0 ? decVal : (decimal?)null;
    }

    int? filterZero(int? intVal)
    {
        return intVal > 0 ? intVal : (int?)null;
    }


</script>
