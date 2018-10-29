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

<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.cust.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.resize.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.fillbetween.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.orderBar.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.pie.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.time.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/flot/jquery.flot.tooltip.min.js") %>"></script>

<script>

		function labelFormatter(label, series) {
		    return "<div style='font-size:8pt; text-align:center; padding:2px; color:white;'>" + label + "<br/>" + Math.round(series.percent) + "%</div>";
		}

		function drawPie(placeholder, data, options) {

		    if (!Array.isArray(data) || data.length == 0) {
		        placeholder.html('<div class="pie_light"><span>目前尚無資料</span></div>');
		        return;
		    }

		    var defaultOpts = {
		        'showLegend': true
		    };

		    $.extend(defaultOpts, options);

		    placeholder.unbind();
		    var plot = $.plot(placeholder, data, {
		        series: {
		            pie: {
		                show: true,
		                innerRadius: 0.5,
		                radius: 1,
		                label: {
		                    show: true,
		                    radius: 2 / 3,
		                    formatter: function (label, series) {
		                        return '<div style="font-size:11px;text-align:center;padding:4px;color:white;">' + label + '<br/>' + Math.round(series.percent) + '%</div>';
		                    },
		                    //threshold: 0.1
		                    background: {
		                        opacity: 0.5,
		                        color: "#000"
		                    }
		                }
		            }
		        },
		        legend: {
		            show: defaultOpts.showLegend,
		            noColumns: 1, // number of colums in legend table
		            labelFormatter: null, // fn: string -> string
		            labelBoxBorderColor: "#000", // border color for the little label boxes
		            container: null, // container (as jQuery object) to put legend in, null means default on top of graph
		            position: "ne", // position of default legend container within plot
		            margin: [5, 10], // distance from grid edge to default legend container within plot
		            backgroundColor: "#efefef", // null means auto-detect
		            backgroundOpacity: 1 // set to 0 to avoid background
		        },
		        grid: {
		            hoverable: true,
		            clickable: true
		        },
                colors: defaultOpts.colors,
		    });

		    placeholder.on('click',function (evt) {
		        plot.draw();
		    });

		    return plot;
        }

</script>
