<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  foreach (var item in _items)
    {
        var contract = item.RegisterLessonEnterprise.EnterpriseCourseContract;
        bool expired = contract.Expiration.Value < DateTime.Today;
        bool pdqStatus = completePDQ(item);
        bool groupComplete = item.GroupingMemberCount == item.GroupingLesson.RegisterLesson.Count || item.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status!=(int)Naming.LessonPriceStatus.團體學員課程  ? true : false;
        bool questionnaireStatus = item.QuestionnaireRequest.Any(q => !q.Status.HasValue && !q.PDQTask.Any());
        var pastReserved = item.LessonTime.Count(l => l.ClassTime < DateTime.Today.AddDays(1) && l.LessonAttendance == null);
        var incomingReserved = item.LessonTime.Count(l => l.ClassTime >= DateTime.Today);
        var lessonCount = item.Lessons - item.GroupingLesson.LessonTime.Count;
%>
<label class="<%= lessonCount>0 && pdqStatus && groupComplete && !questionnaireStatus ? "radio" : "radio state-disabled" %>">
    <input type="radio" name="RegisterID" value="<%= item.RegisterID %>" <%= lessonCount>0 && pdqStatus && groupComplete && !questionnaireStatus && !expired ? null : "disabled" %> />
    <i></i>

    <%= String.Join("｜", item.GroupingLesson.RegisterLesson.Select(m=>m.UserProfile).ToArray()
                                .Select(u=>u.UID==item.UID ? "<b class='text-warning'>"+u.FullName()+"</b>" : u.FullName())) %>【<%= item.RegisterLessonEnterprise.EnterpriseCourseContract.Subject %>(<%= item.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Description %>)】/ 剩餘<%= lessonCount %>堂 / 購買<%= item.RegisterLessonEnterprise.EnterpriseCourseContent.Lessons %>堂
                    <%  if (pastReserved > 0)
                        {   %>
                            （已預約未完成上課<%= pastReserved %>堂）   
                    <%  } %>

    <%  if (!pdqStatus)
                        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        PDQ尚未登打或登打不完全！</span>
    <%  }
                        if (!groupComplete)
                        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        請設定團體學員！</span>
    <%  }
                        if (questionnaireStatus)
                        { %>
    <span class="label label-warning" onclick="$global.promptQuestionnaire(<%= item.RegisterID %>);$global.call('closeDialog');">
        <li class="fa fa-exclamation-triangle"></li>
        階段性調整計劃未填寫，請 <u>立即填寫!</u> 階段性調整計劃。
    </span>
    <%  }
        if (expired)
        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        企業方案合約已過期!!
    </span>
    <%  } %>
</label>
<%  }   %>
<%  Html.RenderPartial("~/Views/ClassFacet/Module/PromptQuestionnaire.ascx"); %>

<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<RegisterLesson> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _items = (IQueryable<RegisterLesson>)this.Model;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

    bool completePDQ(RegisterLesson lesson)
    {
        return lesson.UserProfile.PDQTask
            .Select(t => t.PDQQuestion)
            .Where(q => q.PDQQuestionExtension == null).Count() >= 20;
    }

</script>
