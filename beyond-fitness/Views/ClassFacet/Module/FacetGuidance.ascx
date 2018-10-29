<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<header>
    <span class="widget-icon"><i class="fa fa-edit"></i></span>
    <h2><%= _lesson.UserProfile.FullName() %> <%--目前狀態：<%= _model.CurrentLessonStatus() %>--%></h2>
    <ul class="nav nav-tabs pull-right">
        <%  int idx = 0;
            foreach (var item in _model.GroupingLesson.RegisterLesson)
            { %>
        <li class="<%= idx++ ==0 ? "active" : null %>">
            <a data-toggle="tab" href="#" onclick="showLessonWidget(<%= _model.LessonID %>,<%= item.RegisterID %>);" ><span class="badge bg-color-blue txt-color-white"><i class="<%= item.UserProfile.UserProfileExtension.Gender == "F" ? "fa fa-female" : "fa fa-male" %>"></i></span><%= item.UserProfile.FullName() %></span></a>
        </li>
        <%  } %>
    </ul>
    <div class="widget-toolbar">
        <%  if (!_model.ContractTrustTrack.Any(t => t.SettlementID.HasValue) && _model.LessonAttendance==null)
            {   %>
        <a onclick="rebookingByCoach();" class="btn bg-color-yellow" id="modifyBookingDialog_link">修改時間</a>
        <%  } %>
        <%  if ((/*_model.RegisterLesson.RegisterLessonEnterprise!=null 
                && _model.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status==(int)Naming.LessonPriceStatus.自主訓練 
                &&*/
                _model.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.自主訓練
                && _model.ClassTime < DateTime.Today.AddDays(1)) && _model.LessonAttendance == null
                && _model.TrainingBySelf != 2)
            { %>
        <a onclick="attendLesson(<%= _model.LessonID %>);" class="btn btn-success"><i class="far fa-fw fa-check-square"></i>完成上課</a>
        <%  } %>
        <a href="javascript:showUndone(<%= _model.LessonID %>,-1);" class="btn btn-default" rel="tooltip" data-placement="bottom" data-original-title="<span class='label bg-color-darken font-md'>前往上一筆未完成資料</span>" data-html="true"><i class="fa fa-arrow-circle-left fa-lg"></i></a>
        <a href="javascript:showUndone(<%= _model.LessonID %>,1);" class="btn btn-default" rel="tooltip" data-placement="bottom" data-original-title="<span class='label bg-color-darken font-md'>前往下一筆未完成資料</span>" data-html="true"><i class="fa fa-arrow-circle-right  fa-lg"></i></a>
    </div>
</header>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    RegisterLesson _lesson;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        if (ViewBag.RegisterID != null)
        {
            _lesson = _model.GroupingLesson.RegisterLesson.Where(r => r.RegisterID == (int?)ViewBag.RegisterID).First();
        }
        else
        {
            _lesson = _model.GroupingLesson.RegisterLesson.First();
        }
    }

</script>
