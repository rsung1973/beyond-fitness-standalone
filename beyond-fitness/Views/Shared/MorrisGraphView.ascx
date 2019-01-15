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


<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/morris/raphael.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/morris/morris.min.js") %>"></script>

<script>
    function drawTrendGraph(placeholder, data) {

        if (!Array.isArray(data) || data.length == 0) {
            $('#' + placeholder).html('<div class="pie_light"><span>目前尚無資料</span></div>');
            return;
        }

        Morris.Line({
            element: placeholder,
            data: data,
            xkey: 'ClassDate',
            ykeys: ['ActionLearning', 'PostureRedress', 'Training'],
            labels: ['動作學習', '姿勢矯正', '訓練']
        })

    }

    function drawFitnessGraph(placeholder, data) {

        if (!Array.isArray(data) || data.length == 0) {
            $('#' + placeholder).html('<div class="pie_light"><span>目前尚無資料</span></div>');
            return;
        }

        Morris.Line({
            element: placeholder,
            data: data,
            xkey: 'ClassDate',
            ykeys: ['Flexibility', 'Cardiopulmonary', 'Strength', 'Endurance', 'ExplosiveForce', 'SportsPerformance'],
            labels: ['柔軟度', '心肺', '肌力', '肌耐力', '爆發力', '運動表現']
        })

    }

</script>