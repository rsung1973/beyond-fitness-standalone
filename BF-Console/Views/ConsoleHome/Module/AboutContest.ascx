<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="col-sm-6 col-12">
    <h4 class="card-outbound-header">我的比賽</h4>
    <%  var contestant = _model.ExerciseGameContestant;
        if (contestant != null && contestant.ExerciseGamePersonalRank != null)
        {%>
    <div class="parallax-card bg-darkteal">
        <div class="body">
            <h4>目前第 
                                <%= contestant.ExerciseGamePersonalRank?.Rank    %>
                                名</h4>
        </div>
        <div class="chart-box">
            <%  Html.RenderPartial("~/Views/ConsoleHome/Module/GameRankRadarChart.ascx", contestant);   %>
        </div>
        <%  }
            else
            {
        %>
        <div class="parallax-card bg-darkteal">
            <div class="body">
                <h4>尚未參賽</h4>
            </div>
            <div class="chart-box text-center">
                <i class="zmdi livicon-evo" data-options="name: dislike.svg; size: 150px; style: original; strokeWidth:2px;"></i>
            </div>
        </div>
        <%  } %>
    </div>
</div>
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
