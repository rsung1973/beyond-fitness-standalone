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

<div id="<%= _dialog %>" title="個人記錄" class="bg-color-darken">
    <%  Html.RenderPartial("~/Views/ExerciseGame/Module/GameRankRadarChart.ascx", _model);
        ViewBag.ViewOnly = true;
        Html.RenderPartial("~/Views/ExerciseGame/Module/TestRecordList.ascx", models.GetTable<ExerciseGameResult>().Where(g => g.UID == _model.UID)); %>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: 'auto',
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-gamepad'></i>  個人記錄</h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
        }
    });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "testResult" + DateTime.Now.Ticks;
    ExerciseGameContestant _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ExerciseGameContestant)this.Model;
    }

</script>
