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


<link href="<%= VirtualPathUtility.ToAbsolute("~/flot/custom.css") %>" rel="stylesheet" type="text/css">
<script src="<%= VirtualPathUtility.ToAbsolute("~/flot/jquery.flot.js") %>" type="text/javascript"></script>
<script type="text/javascript" src="<%= VirtualPathUtility.ToAbsolute("~/flot/jquery.flot.axislabels.js") %>"></script>

<script>

		function drawGraph(placeholder,data,ticks) {

		    if (!Array.isArray(data) || data.length == 0) {
		        placeholder.html('<div class="pie_light"><span>目前尚無資料</span></div>');
		        return;
		    }

		    placeholder.unbind();
		    $.plot(placeholder, data, {
		        series: {
		            lines: { show: true },
		            points: { show: true }
		        },
		        xaxis: {
		            font: {
		                size: 12,
		                lineHeight: 13,
		                weight: "bold",
		                family: "Verdana, Arial, Helvetica, Tahoma, sans-serif",
		                color: "#000"
		            },
		            axisLabelFontSizePixels: 18,
		            axisLabel: '月',
		            axisLabelUseCanvas: true,
		            axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
		            axisLabelPadding: 5,
		            ticks: ticks,
		        },
		        yaxis: {
		            font: {
		                size: 14,
		                lineHeight: 13,
		                weight: "bold",
		                family: "Verdana, Arial, Helvetica, Tahoma, sans-serif",
		                color: "#000"
		            },
		            axisLabelFontSizePixels: 16,
		            axisLabel: '％',
		            axisLabelUseCanvas: true,
		            axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
		            axisLabelPadding: 5,
		            ticks: 10,
		            min: 0,
		            //max: 100,
		            tickDecimals: 0
		        },
		        grid: {
		            backgroundColor: { colors: ["#ddd", "#333"] },
		            borderWidth: {
		                top: 1,
		                right: 1,
		                bottom: 2,
		                left: 2
		            }
		        }
		    });
		}

</script>
