<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="體能分析表" class="bg-color-darken">
    <% Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessmentReport.ascx", _model); %>

    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: 'auto',
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-warning'></i> 體能分析表</h4></div>",
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;
    String _dialog;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
        _dialog = "learnerAssessment" + DateTime.Now.Ticks;
    }

</script>
