<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-xs-12 col-sm-6 col-sm-md-6 text-center">
    <label class="label text-lightgray">本次訓練時間比例</label>
<%  if (_model == null)
    { %>
    <div>資料未建立!!</div>
<%  }
    else
    { %>
    <div id="<%= _chartID %>" class="chart-large has-legend-unique"></div>
    <script>
        $(function () {
            $.post('<%= Url.Action("CurrentLessonContentPieData", "Training", new { _model.ExecutionID }) %>', {}, function (data) {
                var plot = drawPie($('#<%= _chartID %>'), data, { 'showLegend': false, 'colors': ['#FDB45C', '#a90329', '#9ACD32', '#1ca9c9'] });

                <%  if(ViewBag.ViewOnly!=true)
                    {   %>
                $global.drawCurrentLessonPie = function () {
                    $.post('<%= Url.Action("CurrentLessonContentPieData", "Training", new { _model.ExecutionID }) %>', {}, function (data) {
                        plot.setData(data);
                        plot.draw();
                    });
                };
                <%  }   %>
            });
        });
    </script>
    <%  } %>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingExecution _model;
    String _chartID = "currentLessonPie" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as TrainingExecution;
    }

</script>
