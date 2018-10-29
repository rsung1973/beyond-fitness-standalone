<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-12 text-center">
    <label class="label text-lightgray">每月累計運動時間曲線圖</label>
    <div id="<%= _chartID %>Legend" class="line-legend text-right"></div>
    <div id="<%= _chartID %>Graph" class="chart no-padding"></div>
</div>
<script>
    $(function () {
        $.post('<%= Url.Action("LearnerExerciseGraphData","Training",new { _model.UID }) %>', {}, function (data) {

            var chart = Morris.Line({
                element: '<%= _chartID %>Graph',
                data: data,
                xkey: 'period',
                xLabelAngle: 30.0,
                yLabelFormat: function (y) {
                    if (typeof (y) != 'undefined') {
                        return parseFloat(y) + ' min';
                    } else {
                        return '-- min';
                    }
                },
                parseTime: false,
                ykeys: ['pt', 'pi', 'st'],
                resize: true,
                labels: ['P.T', 'P.I', 'S.T'],
                hideHover: false,
                lineColors: ['rgba(184,227,243,.43)', 'rgba(255,7,7,.43)', 'rgba(253,236,184,.43)']

            });

            chart.options.labels.forEach(function (label, i) {
                var legendItem = $('<span></span>').text(label).prepend('<i>&nbsp;</i>');
                legendItem.find('i').css('backgroundColor', chart.options.lineColors[i]);
                $('#<%= _chartID %>Legend').append(legendItem)
            });

            <%  if(ViewBag.ViewOnly!=true)
                {   %>

            $global.drawLearnerExerciseGraph = function () {
                $.post('<%= Url.Action("LearnerExerciseGraphData","Training",new { _model.UID }) %>', {}, function (data) {
                    chart.setData(data, true);
                });
            };
            <%  }   %>
        });
    });

</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    LessonTime _item;
    String _chartID = "learnerExercise" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
    }

</script>
