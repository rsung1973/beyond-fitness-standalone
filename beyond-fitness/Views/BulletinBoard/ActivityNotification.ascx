<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<!-- Note: The activity badge color changes when clicked and resets the number to 0
				Suggestion: You may want to set a flag when this happens to tick off all checked messages / notifications -->
<span id="activity" class="activity-dropdown"><i class="fa fa-user"></i><b class="badge"><%= _items.Count() + _comments.Count() %> </b></span>
<!-- AJAX-DROPDOWN : control this dropdown height, look and feel from the LESS variable file -->
<div class="ajax-dropdown">
    <!-- the ID links are fetched via AJAX to the ajax container "ajax-notifications" -->
    <div class="btn-group btn-group-justified" data-toggle="buttons">
        <label class="btn btn-default">
            <input type="radio" name="activity" id="<%= Url.Action("IncomingLearnerRemarkActivity","BulletinBoard") %>">運動留言板 (<%= _comments.Count() %>)</label>
        <label class="btn btn-default">
            <input type="radio" name="activity" id="<%= Url.Action("IncomingQuestionnaireActivity","BulletinBoard") %>">階段性調整計劃 (<%= _items.Count() %>)</label>
    </div>
    <!-- notification content -->
    <div class="ajax-notifications custom-scroll">
        <div class="alert alert-transparent">
            <h4>在這邊有許多有趣的訊息喔！為了保護您的訊息不被他人所直接觀看，請您點選上方類別後才可查看相關訊息！</h4>
        </div>
        <i class="fa fa-lock fa-4x fa-border"></i>
    </div>
    <!-- end notification content -->
    <!-- footer: refresh area -->
    <span>最後更新時間: <%= DateTime.Now.ToString() %>
               <button type="button" data-loading-text="<i class='fa fa-refresh fa-spin'></i> Loading..." class="btn btn-xs btn-default pull-right">
                   <i class="fa fa-refresh"></i>
               </button>
    </span>
    <!-- end footer -->
</div>
<!-- END AJAX-DROPDOWN -->


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    IQueryable<QuestionnaireRequest> _items;
    IQueryable<LessonComment> _comments;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _profile = Context.GetUser();

        IQueryable<QuestionnaireRequest> questItems = models.GetTable<QuestionnaireRequest>().Where(q => q.PDQTask.Count > 0);

        if (_profile.IsSysAdmin())
        {
            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀);
            _comments = models.GetTable<LessonComment>()
                .Where(u => u.Status == (int)Naming.IncommingMessageStatus.未讀 || u.CommentDate >= DateTime.Today.AddDays(-7))
                .Where(u => u.Speaker.ServingCoach == null);

        }
        else
        {
            var uid = models.GetTable<LearnerFitnessAdvisor>().Where(l => l.CoachID == _profile.UID).Select(l => l.UID);
            questItems = questItems.Where(q => uid.Contains(q.UID));

            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀);
            _comments = models.GetTable<LessonComment>().Where(u => u.HearerID == _profile.UID)
                .Where(u => u.Status == (int)Naming.IncommingMessageStatus.未讀 || u.CommentDate >= DateTime.Today.AddDays(-7));
        }

    }

</script>
