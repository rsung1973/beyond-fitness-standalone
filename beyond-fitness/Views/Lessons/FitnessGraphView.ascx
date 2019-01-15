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


<div class="stack-container">
    <div id="fitnessGraph" class="stack-placeholder"></div>
</div>

<script>

    $(function () {
        var lessonDate = <%= JsonConvert.SerializeObject(new
                    {
                        start = _lessonDate.Value.ToString("yyyy-MM-dd"),
                        end = _endQueryDate.Value.ToString("yyyy-MM-dd")
                    }) %>;

        $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/FitnessGraph") %>', lessonDate, function (data) {
            //drawGraph($("#fitnessholder"),data.data,data.ticks);
            drawFitnessGraph('fitnessGraph',data);
        });
    });


</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DateTime? _lessonDate;
    DateTime? _endQueryDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = (DateTime?)ViewBag.LessonDate;
        _endQueryDate = (DateTime?)ViewBag.EndQueryDate ?? _lessonDate;
    }

</script>
