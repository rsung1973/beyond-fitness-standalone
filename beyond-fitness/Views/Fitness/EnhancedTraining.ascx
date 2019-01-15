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
                            <div class="caption text-center">增強式訓練</div>
                            <div id="<%= "enhancedTraining"+_first.AssessmentID %>" class="chart no-padding"></div>
                        </div>
                    </div>
                    <!-- end content -->
                </div>

            </div>
            <!-- end widget div -->
<script>
    <%

    var strengthData = _items
        .Select(g =>
            new
            {
                g.LessonTime.ClassTime,
                Item28 = g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 28).FirstOrDefault()
            })
        .Select(g =>
            new
            {
                period = String.Format("{0:yyyy-MM-dd}", g.ClassTime),
                strength = filterZero(g.Item28.TotalAssessment)
            }).ToArray();

      %>
    $(function () {
        var strengthData = <%= JsonConvert.SerializeObject(strengthData,new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;

        Morris.Line({
            element: '<%= "enhancedTraining"+_first.AssessmentID %>',
            data: strengthData,
            xkey: 'period',
            yLabelFormat: function(y) {
                if (typeof(y) != 'undefined') {
                    return parseFloat(y) + '次';
                } else {
                    return '--';
                }
            },
            xLabelAngle: 30.0,
            ykeys: ['strength'],
            resize: true,
            labels: ['增強式訓練']
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

    int? filterZero(int intVal)
    {
        return intVal > 0 ? intVal : (int?)null;
    }


</script>
