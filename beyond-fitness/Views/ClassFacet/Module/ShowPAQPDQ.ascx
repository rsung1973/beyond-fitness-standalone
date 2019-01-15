<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<h5><a onclick="$global.editPDQ(<%= _model.UID %>);"><u>修改PAQ&PDQ ...</u></a></h5>
<div class="alert alert-warning">
    <%  foreach (var pdq in _pdqConclusion)
                { %>
    <i class="fa fa-info-circle"></i><%= pdq.Question %>
    <%  var pTask = pdq.PDQTask.Where(q => q.UID == _model.UID).FirstOrDefault();
                        if (pTask != null)
                        {
                            Writer.Write(pTask.SuggestionID.HasValue ? pTask.PDQSuggestion.Suggestion : pTask.PDQAnswer);
                        } %><br />
    <%  } %>
</div>
<div class="alert alert-info">
    <strong>
        <i class="fa fa-check-circle"></i>目標 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.GoalAboutPDQ!=null ? _model.PDQUserAssessment.GoalAboutPDQ.Goal : null %><br />
        <i class="fa fa-check-circle"></i>風格 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.StyleAboutPDQ!=null ? _model.PDQUserAssessment.StyleAboutPDQ.Style : null %><br />
        <i class="fa fa-check-circle"></i>訓練水準 - <%= _model.PDQUserAssessment!=null && _model.PDQUserAssessment.TrainingLevelAboutPDQ!=null ? _model.PDQUserAssessment.TrainingLevelAboutPDQ.TrainingLevel : null %>
    </strong>
</div>
<script>
    $(function () {
        if (!$global.editPDQ) {
            $global.editPDQDone = function () {
                window.location.reload();
            };
            $global.editPDQ = function (uid) {
                showLoading();
                $.post('<%= Url.Action("PDQ","Learner") %>', { 'uid': uid }, function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                });
            };
        }
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    IQueryable<PDQQuestion> _pdqConclusion;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _pdqConclusion = models.GetTable<PDQGroup>().Where(g => g.ConclusionID.HasValue)
            .Select(g => g.PDQConclusion);
    }

   
</script>
