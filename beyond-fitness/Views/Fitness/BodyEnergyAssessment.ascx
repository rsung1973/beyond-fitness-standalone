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

<%--<header>
    <span class="widget-icon"><i class="fa fa-line-chart text-success"></i></span>
    <h2><%= String.Format("{0:yyyy/MM/dd}",_first.AssessmentDate) %> - <%= String.Format("{0:yyyy/MM/dd}",_last.AssessmentDate) %> 能量系統強度 </h2>

</header>--%>

<!-- widget div-->
<div class="no-padding">
    <!-- widget edit box -->
    <div class="jarviswidget-editbox">
    </div>
    <!-- end widget edit box -->

    <div class="widget-body">
        <!-- content -->
        <div class="row">
            <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                <div class="caption text-center">能量系統強度</div>
                <div id="<%= "bodyEnergy"+_first.AssessmentID %>" class="chart no-padding"></div>
            </div>
        </div>
        <!-- end content -->
    </div>

</div>
<!-- end widget div -->
<script>
    <%  if (_profile.Birthday.HasValue)
    {
        var energyData = _items
            .Select(g =>
                new
                {
                    g.LessonTime.ClassTime,
                    Item17 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 17).FirstOrDefault(),
                    Item16 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 16).FirstOrDefault(),
                })
            .Where(g => g.Item16 != null && g.Item17 != null)
            .Select(g =>
                new
                {
                    period = String.Format("{0:yyyy-MM-dd}", g.ClassTime),
                    energy = filterZero((int)((g.Item17.TotalAssessment - g.Item16.TotalAssessment) / (206.9m - (0.67m * (DateTime.Today.Year - _profile.Birthday.Value.Year)) - g.Item16.TotalAssessment) * 100 + 0.5m))
                }).ToArray();

      %>
    $(function () {
        var energyData = <%= JsonConvert.SerializeObject(energyData, new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;

        Morris.Line({
            element: '<%= "bodyEnergy" + _first.AssessmentID %>',
            data: energyData,
            xkey: 'period',
            yLabelFormat: function(y) {
                if (typeof(y) != 'undefined') {
                    return parseFloat(y) + '%';
                } else {
                    return '--';
                }
            },
            xLabelAngle: 30.0,
            ykeys: ['energy'],
            resize: true,
            labels: ['能量系統訓練強度']
        });
    });
    <%  } %>
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

    decimal? filterZero(decimal decVal)
    {
        return decVal > 0 ? decVal : (decimal?)null;
    }

    int? filterZero(int intVal)
    {
        return intVal > 0 ? intVal : (int?)null;
    }


</script>
