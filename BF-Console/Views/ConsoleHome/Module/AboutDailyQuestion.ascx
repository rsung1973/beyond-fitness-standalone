<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  var questItems = models.PromptDailyQuestion();
    var questCount = questItems.Count();
    var answered = questItems.Where(q => models.GetTable<PDQTask>().Any(t => t.QuestionID == q.QuestionID));
    var taskItems = models.GetTable<PDQTask>().Where(t => t.PDQQuestion.GroupID == 6);
    var rightAns = taskItems.Where(t => t.PDQSuggestion.RightAnswer == true);
    %>
<div class="col-sm-6 col-12">
    <h4 class="card-outbound-header">運動小學堂</h4>
    <div class="parallax-img-card">
        <div class="body">
            <h4>目前已編寫題目卷<span class="col-lime"> <%= questCount %> </span>張囉！</h4>
            <p class="col-white">答題率已達 <span class="col-lime"><%= Math.Round(answered.Count()*100m / questCount) %>%</span>，成績單正確率<span class="col-lime"> <%= Math.Round(rightAns.Count()*100m / taskItems.Count())%>%</span></p>
        </div>
        <div class="parallax">
            <img src="images/carousel/qa-background.jpg"></div>
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
