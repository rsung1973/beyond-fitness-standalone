<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  String basePath = VirtualPathUtility.ToAbsolute("~/"); %>

<!-- IMPORTANT: APP CONFIG -->
<script src="<%= basePath + "js/app.config.js" %>"></script>

<!-- JS TOUCH : include this plugin for mobile drag / drop touch events-->
<%  if (Request.ServerVariables["HTTP_USER_AGENT"] == null || !Request.ServerVariables["HTTP_USER_AGENT"].ToLower().Contains("android"))
    { %>
<script src="<%= basePath + "js/plugin/jquery-touch/jquery.ui.touch-punch.min.js" %>"></script>
<%  } %>

<!-- BOOTSTRAP JS -->
<script src="<%= basePath + "js/bootstrap/bootstrap.min.js" %>"></script>

<!-- CUSTOM NOTIFICATION -->
<script src="<%= basePath + "js/notification/SmartNotification.min.js" %>"></script>

<!-- JARVIS WIDGETS -->
<script src="<%= basePath + "js/smartwidgets/jarvis.widget.min.js" %>"></script>

<!-- EASY PIE CHARTS -->
<script src="<%= basePath + "js/plugin/easy-pie-chart/jquery.easy-pie-chart.min.js" %>"></script>

<!-- SPARKLINES -->
<script src="<%= basePath + "js/plugin/sparkline/jquery.sparkline.min.js" %>"></script>

<!-- JQUERY MASKED INPUT -->
<script src="<%= basePath + "js/plugin/masked-input/jquery.maskedinput.min.js" %>"></script>

<!-- JQUERY SELECT2 INPUT -->
<script src="<%= basePath + "js/plugin/select2/select2.min.js" %>"></script>

<!-- JQUERY UI + Bootstrap Slider -->
<script src="<%= basePath + "js/plugin/bootstrap-slider/bootstrap-slider.min.js" %>"></script>

<!-- browser msie issue fix -->
<script src="<%= basePath + "js/plugin/msie-fix/jquery.mb.browser.min.js" %>"></script>

<!-- FastClick: For mobile devices -->
<script src="<%= basePath + "js/plugin/fastclick/fastclick.min.js" %>"></script>

<!--[if IE 8]>

		<h1>Your browser is out of date, please update your browser by going to www.microsoft.com/download</h1>

		<![endif]-->

<!-- MAIN APP JS FILE -->
<script src="<%= basePath + "js/app.min.js" %>"></script>

<!-- ENHANCEMENT PLUGINS : NOT A REQUIREMENT -->
<!-- Voice command : plugin -->
<script src="<%= basePath + "js/speech/voicecommand.min.js" %>"></script>

<!-- SmartChat UI : plugin -->
<script src="<%= basePath + "js/smart-chat-ui/smart.chat.ui.min.js" %>"></script>
<script src="<%= basePath + "js/smart-chat-ui/smart.chat.manager.min.js" %>"></script>

<!-- PAGE RELATED PLUGIN(S) 
		<script src="..."></script>-->

<script type="text/javascript">

    // DO NOT REMOVE : GLOBAL FUNCTIONS!

    $(document).ready(function () {

        pageSetUp();

        /*
         * Autostart Carousel
         */
        $('.carousel.slide').carousel({
            interval: 2000,
            cycle: true
        });
        $('.carousel.fade').carousel({
            interval: 2000,
            cycle: true
        });

        // Fill all progress bars with animation

        $('.progress-bar').progressbar({
            display_text: 'fill'
        });

    })

</script>
<script type="text/javascript">

	// DO NOT REMOVE : GLOBAL FUNCTIONS!
    $(document).ready(function () {
        pageSetUp();
    });

</script>

<!-- Your GOOGLE ANALYTICS CODE Below -->
<script type="text/javascript">
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-84335528-1']);
    _gaq.push(['_trackPageview']);

    (function () {
        var ga = document.createElement('script');
        ga.type = 'text/javascript';
        ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(ga, s);
    })();

</script>
<script>
            //-----月曆模組------//
        $('.form_datetime').datetimepicker({
            language: 'zh-TW',
            weekStart: 1,
            todayBtn: 1,
            autoclose: 1,
            clearBtn: 1,
            todayHighlight: 1,
            startView: 2,
            forceParse: 0,
            showMeridian: 1
        });
        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });
        $('.form_time').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 0,
            minuteStep: 30,
            forceParse: 0
        });

        $('.form_month').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 0,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 3,
            minView: 3,
            forceParse: 0
        });

        $('.input_time').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 1,
            minView: 0,
            minuteStep: 30,
            forceParse: 0
        });

<%--        $('.form_time').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 0,
            maxView: 2,
            forceParse: 0,
            minuteStep: 30,
            startDate: '<%= DateTime.Today.AddHours(8).ToString("yyyy-MM-dd HH:mm") %>',
            showMeridian: false
        });--%>

        $('.form_month').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            //todayBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 3,
            minView: 3,
            forceParse: 0
        });
</script>

