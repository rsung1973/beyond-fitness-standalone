<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">

    <%  if (_model.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
        {
            Html.RenderPartial("~/Views/Member/CoachSelfLesson.ascx", _model.UserProfile);
        }
        else
        {
            Html.RenderPartial("~/Views/Member/LessonCount.ascx", _model.UserProfile);
        } %>
    <div class="col-xs-8 col-sm-5">
        <h1>
            <span class="semi-bold"><a href="<%= VirtualPathUtility.ToAbsolute("~/Member/ShowLearner/") + _model.UID %>"><%= _model.UserProfile.FullName() %></a></span>
        </h1>
        <p class="font-md"><a onclick="flipflop();" ><i class="fa fa-eye-slash fa-2x closeureye"></i></a> 關於<%= _model.UserProfile.UserName ?? _model.UserProfile.FullName() %>...</p>
        <p style="display:none;">
            <img src="<%= VirtualPathUtility.ToAbsolute("~/img/confidential.png") %>" width="40%"/>
        </p>
        <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
            { %>
        <p class="alert alert-danger secret-info">
            <strong>
                <%  foreach (var pdq in _pdqConclusion)
                { %>
                <i class="fa fa-info-circle"></i><%= pdq.Question %>
                <%  var pTask = pdq.PDQTask.Where(q => q.UID == _model.UID).FirstOrDefault();
                        if (pTask != null)
                        {
                            Writer.Write(pTask.SuggestionID.HasValue ? pTask.PDQSuggestion.Suggestion : pTask.PDQAnswer);
                        } %><br />
                <%  } %>
            </strong>
        </p>
        <%  } %>
        <p class="secret-info">
            <%= _model.UserProfile.RecentStatus!=null ? _model.UserProfile.RecentStatus.Replace("\n","<br/>") : null %>
            <%--<form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitPlan") %>" class="smart-form" method="post">
                <fieldset>
                    <section>
                        <label class="textarea">
                            <textarea rows="3" id="recentStatus" name="recentStatus" class="custom-scroll"><%= _model.UserProfile.RecentStatus %></textarea>
                        </label>
                        <div class="note">
                            <strong>Note:</strong> 最多輸入250個中英文字
                        </div>
                    </section>
                </fieldset>
                <p class="text-right">
                    <button type="button" name="submit" class="btn btn-primary btn-sm" id="btnUpdateStatus" onclick="commitPlan();">
                        <i class="fa fa-reply"></i>更新
                    </button>
                </p>
            </form>--%>
        </p>
        <p class="text-right">
            <button type="button" name="editStatus" onclick="editRecentStatus(<%= _model.UID %>);" class="btn btn-primary btn-sm">
                <i class="fa fa-reply"></i>更新個人近況
            </button>
            <%  if (ViewBag.PreviewLesson != true)
                { %>
            <button type="button" name="editHealth" onclick="editHealth(<%= _model.RegisterID %>)" class="btn btn-primary btn-sm" id="btn-chat">
                <i class="fa fa-history"></i>更新身體基本指數
            </button>
            <%  } %>
        </p>
    </div>
    <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
        { %>
    <div class="col-xs-12 col-sm-4">
        <%  Html.RenderPartial("~/Views/Member/ContactInfo.ascx", _model.UserProfile); %>
        <%  Html.RenderPartial("~/Views/Member/UserAssessmentInfo.ascx", _model.UserProfile); %>
    </div>
    <%  } %>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    LessonTime _item;
    IQueryable<PDQQuestion> _pdqConclusion;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
        _pdqConclusion = models.GetTable<PDQGroup>().Where(g => g.ConclusionID.HasValue)
            .Select(g => g.PDQConclusion);

    }

</script>
