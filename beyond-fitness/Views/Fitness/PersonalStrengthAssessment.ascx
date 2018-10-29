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


<header>
    <span class="widget-icon"><i class="fa fa-line-chart text-success"></i></span>
    <h2><%= String.Format("{0:yyyy/MM/dd}",_first.AssessmentDate) %> - <%= String.Format("{0:yyyy/MM/dd}",_last.AssessmentDate) %> 肌力系統強度 </h2>

</header>

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
                <div class="caption text-center">肌力總訓練</div>
                <div id="<%= "strengthGraph"+_first.AssessmentID %>" class="chart no-padding"></div>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                <div class="caption text-center">上肢肌力總訓練</div>
                <div id="<%= "upperLimbsGraph"+_first.AssessmentID %>" class="chart no-padding"></div>
            </div>
            <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                <div class="caption text-center">下肢肌力總訓練</div>
                <div id="<%= "lowerLimbsGraph"+_first.AssessmentID %>" class="chart no-padding"></div>
            </div>
        </div>
        <!-- end content -->
    </div>

</div>
<!-- end widget div -->
<script>
    <%

    var upperLimbs = models.GetTable<FitnessAssessmentItem>().Where(r => r.ItemID == 25 || r.ItemID == 26 || r.ItemID == 34 || r.ItemID == 35).ToArray();
    var upperLimbsID = upperLimbs.Select(r => r.ItemID).ToArray();
    var lowerLimbs = models.GetTable<FitnessAssessmentItem>().Where(r => r.ItemID == 23 || r.ItemID == 24).ToArray();
    var lowerLimbsID = lowerLimbs.Select(r => r.ItemID).ToArray();


    var strengthData = _items.Select(g =>
            new
            {
                period = String.Format("{0:yyyy-MM-dd}", g.LessonTime.ClassTime),
                up = filterZero(g.LessonFitnessAssessmentReport.Where(r => upperLimbsID.Contains(r.ItemID)).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
                down = filterZero(g.LessonFitnessAssessmentReport.Where(r => lowerLimbsID.Contains(r.ItemID)).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
                olympic = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 29).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1)))
            }).ToArray();

    var upperLimbsData = _items.Select(g => new
    {
        period = String.Format("{0:yyyy-MM-dd}", g.LessonTime.ClassTime),
        _25 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 25).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
        _26 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 26).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
        _34 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 34).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
        _35 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 35).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1)))
    }).ToArray();

    var lowerLimbsData = _items.Select(g => new
    {
        period = String.Format("{0:yyyy-MM-dd}", g.LessonTime.ClassTime),
        _23 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 23).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1))),
        _24 = filterZero(g.LessonFitnessAssessmentReport.Where(r => r.ItemID == 24).Sum(r => ((r.TotalAssessment ?? 0) + (r.SingleAssessment ?? 0) * (r.ByTimes ?? 0)) * (r.BySingleSide == true ? 2 : 1)))
    }).ToArray();

      %>
    $(function () {
        drawPersonalAssessment<%= _first.AssessmentID %>()
    });

    function drawPersonalAssessment<%= _first.AssessmentID %>() {
        var strengthData = <%= JsonConvert.SerializeObject(strengthData,new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;
        var lowerLimbsData = <%= JsonConvert.SerializeObject(lowerLimbsData,new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;
        var upperLimbsData = <%= JsonConvert.SerializeObject(upperLimbsData,new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore }) %>;

        Morris.Line({
            element: '<%= "strengthGraph" + _first.AssessmentID %>' ,
            data: strengthData,
            xkey: 'period',
            xLabelAngle: 30.0,
            yLabelFormat: function(y) {
                if (typeof(y) != 'undefined') {
                    return parseFloat(y) + ' KG';
                } else {
                    return '-- KG';
                }

            },
            ykeys: ['up', 'down','olympic'],
            resize: true,
            labels: ['上肢', '下肢','奧林匹克爆發']
        });

        Morris.Line({
            element: '<%= "upperLimbsGraph" + _first.AssessmentID %>',
            data: upperLimbsData,
            xkey: 'period',
            xLabelAngle: 30.0,
            yLabelFormat: function(y) {
                if (y) {
                    return parseFloat(y) + ' KG';
                } else {
                    return '-- KG';
                }            },
            ykeys: ['_25', '_26','_34','_35'],
            resize: true,
            labels: ['上肢水平推', '上肢水平拉', '上肢垂直推', '上肢垂直拉']
        });

        Morris.Line({
            element: '<%= "lowerLimbsGraph" + _first.AssessmentID %>',
            data: lowerLimbsData,
            xkey: 'period',
            xLabelAngle: 30.0,
            yLabelFormat: function(y) {
                if (y) {
                    return parseFloat(y) + ' KG';
                } else {
                    return '-- KG';
                }            },
            ykeys: ['_23', '_24'],
            resize: true,
            labels: ['下肢推', '下肢拉']
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonFitnessAssessment> _model;
    IQueryable<LessonFitnessAssessment> _items;
    LessonFitnessAssessment _first;
    LessonFitnessAssessment _last;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonFitnessAssessment>)this.Model;
        _items = _model.OrderBy(r => r.AssessmentID);
        _first = _items.First();
        _last = _model.OrderByDescending(r => r.AssessmentID).First();
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
