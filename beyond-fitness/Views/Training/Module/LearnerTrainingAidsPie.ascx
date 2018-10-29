<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-xs-12 col-sm-6 col-md-6 text-center">
    <label class="label text-lightgray">器材使用率</label>
    <div id="<%= _chartID %>" class="chart-large has-legend-unique"></div>
    <script>
        $(function () {
            $.post('<%= Url.Action("LearnerTrainingAidsPieData","Training",new { _model.UID }) %>', {}, function (data) {
                var plot = drawPie($('#<%= _chartID %>'), data, { 'showLegend': false });
                <%  if(ViewBag.ViewOnly!=true)
                    {   %>
                $global.drawTrainingAidsPie = function () {
                    $.post('<%= Url.Action("LearnerTrainingAidsPieData","Training",new { _model.UID }) %>', {}, function (data) {
                        plot.setData(data);
                        plot.draw();
                    });
                };
                <%  }   %>
            });
        });
    </script>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    String _chartID = "trainingAidsPie" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
    }

</script>
