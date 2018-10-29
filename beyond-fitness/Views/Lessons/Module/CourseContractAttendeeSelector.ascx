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
        var contract = item.RegisterLessonContract.CourseContract;
        var lessonCount = contract.RemainedLessonCount();
        bool pdqStatus = completePDQ(item);
        bool groupComplete = item.GroupingMemberCount == item.GroupingLesson.RegisterLesson.Count ? true : false;
        bool questionnaireStatus = item.QuestionnaireRequest.Any(q => !q.Status.HasValue && !q.PDQTask.Any());
        bool revisionStatus = contract.RevisionList.Any(c => c.CourseContract.Status < (int)Naming.CourseContractStatus.已生效);

        var pastReserved = item.LessonTime.Count(l => l.ClassTime < DateTime.Today.AddDays(1) && l.LessonAttendance == null);
        var incomingReserved = item.LessonTime.Count(l => l.ClassTime >= DateTime.Today);

        var validContract = contract.Expiration.Value >= DateTime.Today;
        var bookingCount = contract.CourseContractType.ContractCode == "CFA"
                ? contract.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count())
                : item.GroupingLesson.LessonTime.Count;
        var totalPaid = contract.TotalPaidAmount();
        var payoffStatus = contract.TotalCost / contract.Lessons * (bookingCount + 1) <= totalPaid;

%>
<label class="<%= lessonCount>0 && pdqStatus && groupComplete && !questionnaireStatus && validContract && payoffStatus && !revisionStatus ? "radio" : "radio state-disabled" %>">
    <input type="radio" name="registerID" value="<%= item.RegisterID %>" <%= lessonCount>0 && pdqStatus && groupComplete && !questionnaireStatus && validContract && payoffStatus && !revisionStatus ? null : "disabled" %> />
    <i></i>
    <%  if (item.RegisterLessonContract != null)
        {   %>
    <%= String.Join("｜", contract.CourseContractMember.Select(m=>m.UserProfile).ToArray()
                                     .Select(u=>u.UID==item.UID ? "<b class='text-warning'>"+u.FullName()+"</b>" : u.FullName())) %> / <%= contract.CourseContractExtension.BranchStore.BranchName %> /【<%= contract.CourseContractType.TypeName %>(<%= contract.LessonPriceType.DurationInMinutes %>分鐘)】/ 剩餘<%= lessonCount %>堂 / 購買<%= contract.Lessons %>堂
                            <%  if (pastReserved > 0)
                                {   %>
                                    （已預約未完成上課<%= pastReserved %>堂）   
                            <%  } %>
    <%  }
        else
        {   %>
    <%= item.UserProfile.FullName() %>「<%= item.Lessons %>堂-<%= item.LessonPriceType.Description %>」
                        <%  if (item.GroupingMemberCount > 1)
                            {   %>
    <li class="fa fa-group"></li>
    團體《<%= String.Join("·", models.GetTable<GroupingLesson>().Where(g => g.GroupID == item.RegisterGroupID)
                                                        .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterID != item.RegisterID),
                                                            g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                                                        .Select(r => r.UserProfile.RealName)) %>》
                        <%  }
                            else
                            {   %>
    <li class="fa fa-child"></li>
    個人
                        <%  } %>(剩餘<%= lessonCount %>堂
                            <%  if (incomingReserved > 0)
                                { %>
                                    [已預約<%= incomingReserved %>堂]
                            <%  } %>
    <%  if (pastReserved > 0)
        { %>
                                    [已預約未完成上課<%= pastReserved %>堂]
                            <%  } %>
                            )
                    <%  } %>
    <%  if (!pdqStatus)
        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        PDQ尚未登打或登打不完全！</span>
    <%  }
        if (revisionStatus)
        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        合約服務申請進行中！</span>
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
        if (!validContract)
        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        合約尚未生效或已過期！
    </span>
    <%  }
        if (!payoffStatus)
        { %>
    <span class="label label-danger">
        <li class="fa fa-exclamation-triangle"></li>
        合約繳款餘額不足！（未繳清：<%= String.Format("{0:##,###,###,###}",contract.TotalCost-totalPaid) %>元）
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

    bool hasPayment(RegisterLesson lesson)
    {
        if (lesson.LessonPriceType.ListPrice > 0)
        {
            if (lesson.GroupingMemberCount > 1)
            {
                foreach (var r in lesson.GroupingLesson.RegisterLesson)
                {
                    if (r.IntuitionCharge == null || r.IntuitionCharge.TuitionInstallment.Count() == 0)
                        return false;
                }
                return true;
            }
            else
            {
                return lesson.IntuitionCharge != null
                    && lesson.IntuitionCharge.TuitionInstallment.Count() > 0;
            }
        }
        return true;
    }

</script>
