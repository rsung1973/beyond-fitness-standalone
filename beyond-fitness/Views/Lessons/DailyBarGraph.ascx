<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/morris/raphael.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/morris/morris.min.js") %>"></script>


<div class="well bg-color-darken ">
    <div id="bar-graph" class="chart no-padding"></div>
</div>

<script>

    var $p;

    function plotData(lessonDate) {

        $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingPlot") %>', { 'lessonDate': lessonDate }, function (data) {

            if ($('#bar-graph').length) {

                $p = Morris.Bar({
                    element: 'bar-graph',
                    data: data,
                    xkey: 'x',
                    ykeys: ['y'],
                    labels: ['人'],
                    barColors: function (row, series, type) {
                        if (type === 'bar') {
                            var red = Math.ceil(150 * row.y / this.ymax);
                            return 'rgb(' + red + ',0,0)';
                        } else {
                            return '#000';
                        }
                    }
                });

            }

        });
    }

    function plotQueryData() {

        $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/QueryBookingPlot") %>', { }, function (data) {

            if ($('#bar-graph').length) {

                $p = Morris.Bar({
                    element: 'bar-graph',
                    data: data,
                    xkey: 'x',
                    ykeys: ['y'],
                    labels: ['人'],
                    barColors: function (row, series, type) {
                        if (type === 'bar') {
                            var red = Math.ceil(150 * row.y / this.ymax);
                            return 'rgb(' + red + ',0,0)';
                        } else {
                            return '#000';
                        }
                    }
                });

            }

        });
    }

<%--    $(function () {

        plotData('<%= _lessonDate.Value.ToString("yyyy-MM-dd") %>');
        // Add the Flot version string to the footer

        $("#footer").prepend("Flot " + $.plot.version + " &ndash; ");
    });--%>

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DateTime? _lessonDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = (DateTime?)this.Model;
    }

</script>
