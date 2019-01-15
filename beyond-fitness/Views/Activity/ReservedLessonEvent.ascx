<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li>
    <div class="smart-timeline-icon">
        <% _model.Lesson.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "" }); %>
    </div>
    <div class="smart-timeline-time">
        <small><%= _model.Lesson.ClassTime.Value.ToString("yyyy/MM/dd HH:mm") %>~<%= _model.Lesson.ClassTime.Value.AddMinutes(_model.Lesson.DurationInMinutes.Value).ToString("HH:mm") %></small>
    </div>
    <div class="smart-timeline-content">
        <div class="well well-sm display-inline bg-color-pinkDark">
            <p>提醒您記得<strong> <%= _model.Lesson.ClassTime.Value.ToString("yyyy/MM/dd HH:mm") %>~<%= _model.Lesson.ClassTime.Value.AddMinutes(_model.Lesson.DurationInMinutes.Value).ToString("HH:mm") %></strong>
                <%  if (_model.Lesson.TrainingBySelf == 1)
                    { %>
                        自主訓練喔！
                <%  }
                    else
                    { %>
                        與<%= _model.Lesson.AsAttendingCoach.UserProfile.FullName() %>一起運動喔！
                <%  } %>
            </p>
            <p>
                <button class="btn btn-xs btn-default" onclick="showLearnerLesson(<%= _model.Lesson.LessonID %>,true);"><i class="fa fa-gift"></i> 預先確認上課內容</button>
                <%  if (!_model.Lesson.LessonPlan.CommitAttendance.HasValue && _model.Lesson.ClassTime<DateTime.Today.AddDays(1))
                    { %>
                <button class="btn btn-xs btn-success" onclick="learnerAttendLesson(<%= _model.Lesson.LessonID %>);"><i class="fa fa-check"></i> 上課打卡</button>
                <%  } %>
            </p>
            <p>
                <button class="btn btn-xs btn-info" onclick="assessLearnerHealth(<%= _model.Lesson.LessonID %>,<%= _model.Profile.UID %>);"><i class="fa fa-history"></i>確認健康指數</button>
            </p>
        </div>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonEvent _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonEvent)this.Model;
    }

</script>
