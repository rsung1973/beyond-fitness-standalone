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
<script type="text/javascript" src="<%= VirtualPathUtility.ToAbsolute("~/flot/jquery.flot.pie.js") %>"></script>

<script>

		function labelFormatter(label, series) {
		    return "<div style='font-size:8pt; text-align:center; padding:2px; color:white;'>" + label + "<br/>" + Math.round(series.percent) + "%</div>";
		}

		function drawPie(placeholder,data) {

		    if (!Array.isArray(data) || data.length == 0) {
		        placeholder.html('<div class="pie_light"><span>目前尚無資料</span></div>');
		        return;
		    }

		    placeholder.unbind();
		    $.plot(placeholder, data, {
		        series: {
		            pie: {
		                show: true,
		                radius: 1,
		                label: {
		                    show: true,
		                    radius: 3 / 4,
		                    formatter: labelFormatter,
		                    background: {
		                        opacity: 0.5,
		                        color: "#000"
		                    }
		                }
		            }
		        },
		        legend: {
		            show: false
		        },
		        grid: {
		            hoverable: true,
		            clickable: false
		        }
		    });
		}

</script>
