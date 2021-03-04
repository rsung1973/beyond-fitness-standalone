<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%--<%  if (models.CheckCurrentQuestionnaireRequest(_model) || models.GetQuestionnaireRequest(_model.UserProfile).Count() > 0)
    {   %>
<div class="hp-info pull-right" id="<%= _contentID %>" onclick="$global.promptQuestionnaire(<%= _model.RegisterID %>);">
    <div class="hp-icon">
        <font color="red"><span class="fas fa-volume-up fa-spin"></span> </font>
    </div>
    <font color="red"><span class="hp-main">1</span></font>
    <font color="red"><span class="hp-sm">New</span></font>
    <%  Html.RenderPartial("~/Views/ClassFacet/Module/PromptQuestionnaire.ascx"); %>
    <script>
        $(function () {
            $global.removeQuestionnairePrompt = function () {
                $('#<%= _contentID %>').remove();
            };
        });
    </script>
</div>
<%  }  %>--%>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    String _contentID = "quest" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;

    }

</script>
