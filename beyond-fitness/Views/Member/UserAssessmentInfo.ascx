<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<h1><small>方案設計工具結果</small></h1>
<ul class="list-unstyled">
    <li>
        <p class="text-muted">
            目標 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.GoalAboutPDQ!=null ? _model.PDQUserAssessment.GoalAboutPDQ.Goal : null %>
        </p>
    </li>
    <li>
        <p class="text-muted">
            風格 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.StyleAboutPDQ!=null ? _model.PDQUserAssessment.StyleAboutPDQ.Style : null %>
        </p>
    </li>
    <li>
        <p class="text-muted">
            訓練水準 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.TrainingLevelAboutPDQ!=null ? _model.PDQUserAssessment.TrainingLevelAboutPDQ.TrainingLevel : null %>
        </p>
    </li>
</ul>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
