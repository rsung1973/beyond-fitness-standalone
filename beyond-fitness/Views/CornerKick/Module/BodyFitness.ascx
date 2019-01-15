<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="goal-block">
    <h3>體能分析庫</h3>
    <div class="parallax-container" onclick="javascript:gtag('event', '體能分析庫', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});window.location.assign('<%= Url.Action("TrainingAnalysis","CornerKick") %>');">
        <div class="section no-pad-bot">
            <div class="container">
                <%  var contestant = _model.ExerciseGameContestant;
                    if (contestant != null && contestant.Status == (int)Naming.GeneralStatus.Successful
                        && contestant.ExerciseGameRank.Any(r => r.RankingScore.HasValue))
                    {
                        Html.RenderPartial("~/Views/CornerKick/Module/GameRankRadarChart.ascx", contestant);
                    }
                    else if (_model.PersonalExercisePurpose != null
                        && (_model.PersonalExercisePurpose.Cardiopulmonary.HasValue
                            || _model.PersonalExercisePurpose.Flexibility.HasValue
                            || _model.PersonalExercisePurpose.MuscleStrength.HasValue))
                    {
                        Html.RenderPartial("~/Views/CornerKick/Module/BodyPowerAbility.ascx", _model.PersonalExercisePurpose);
                    }
                    else
                    {
                        Html.RenderPartial("~/Views/CornerKick/Module/EmptyGameRankRadarChart.ascx", _model);
                    } %>
            </div>
        </div>
        <div class="parallax white"></div>
    </div>
</div>
<%  Html.RenderPartial("~/Views/Shared/InitBarChartNoRegister.ascx"); %>

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
