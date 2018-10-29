<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li>
    <div class="smart-timeline-icon bg-color-teal">
        <i class="fa fa-microphone"></i>
    </div>
    <div class="smart-timeline-time">
        <img src="<%= VirtualPathUtility.ToAbsolute("~/img/extra.png") %>" width="50" height="50" />
    </div>
    <div class="smart-timeline-content">
        <div class="well well-sm display-inline bg-color-teal">
            <p><strong>為了讓您的體能顧問做出更優化的階段性調整，下方提供
                &lt;六個小問題&gt;
                請您回答補充，資料僅提供訓練使用，不會外洩，敬請放心填寫！</strong></p>
            <p>
                <button class="btn btn-xs bg-color-blueDark" onclick="javascript:(window.location.href='<%= Url.Action("Questionnaire","Interactivity",new { id = _model.Questionnaire.QuestionnaireID }) %>');"><i class="fa fa-volume-up"></i>說出您的想法</button>
            </p>
        </div>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QuestionnaireRequestEvent _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (QuestionnaireRequestEvent)this.Model;
    }

</script>
