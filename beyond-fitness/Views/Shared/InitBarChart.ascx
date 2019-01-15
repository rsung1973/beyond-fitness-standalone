<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script>

    //debugger;
    $(function () {

        if ($global.chartJS == undefined) {
            loadScript('<%= VirtualPathUtility.ToAbsolute("~/js/plugin/chartjs2_7_2/chart.min.js") %>', function () {
                $global.chartJS = true;

                // Define a plugin to provide data labels
                Chart.plugins.register({
                    afterDatasetsDraw: function (chart) {
                        var ctx = chart.ctx;

                        chart.data.datasets.forEach(function (dataset, i) {
                            var meta = chart.getDatasetMeta(i);
                            if (!meta.hidden) {
                                meta.data.forEach(function (element, index) {
                                    // Draw the text in black, with the specified font
                                    ctx.fillStyle = '#D3D3D3';

                                    var fontSize = 12;
                                    var fontStyle = 'normal';
                                    var fontFamily = 'Helvetica Neue';
                                    ctx.font = Chart.helpers.fontString(fontSize, fontStyle, fontFamily);

                                    // Just naively convert to string for now
                                    var dataString = '';
                                    if(dataset.data[index])
                                        dataString = dataset.data[index].toString();

                                    // Make sure alignment settings are correct
                                    ctx.textAlign = 'center';
                                    ctx.textBaseline = 'middle';

                                    var padding = 5;
                                    var position = element.tooltipPosition();
                                    if (dataset.data[index] > 0) {
                                        ctx.fillText(dataString, position.x, position.y - (fontSize / 2) + padding);
                                    }
                                });
                            }
                        });
                    }
                });

                if ($global.initGraph) {
                    $global.initGraph();
                }

            });
        } else {

        }

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
