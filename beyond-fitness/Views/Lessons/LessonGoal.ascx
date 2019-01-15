<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<h4>上課時間：<%= _model.ClassTime.Value.ToString("yyyy/MM/dd") %> <%= _model.ClassTime.Value.ToString("HH:mm") %> - <%= _model.ClassTime.Value.AddMinutes(_model.DurationInMinutes.Value).ToString("HH:mm") %></h4>
<%  if (_assessment == true)
    { %>
        <div class="row">
            <div class="col-md-2">
                <h4>體能顧問：</h4>
            </div>
            <div class="col-md-4">
                <% Html.RenderPartial("~/Views/Lessons/CoachSelector.ascx", new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _model.AttendingCoach }); %>
            </div>
        </div>
<%  }
    else
    { %>
        <h4>體能顧問：<%= _model.AsAttendingCoach.UserProfile.FullName() %></h4>
<%  } %>

<h4><span class="fa fa-tags"></span> 方案設計工具結果</h4>
<div class="panel panel-default">
    <table class="table">
        <tr class="info">
            <th>目標</th>
            <th>風格</th>
            <th>訓練水準</th>
        </tr>
        <tr>
            <td>減肥</td>
            <td>保守型</td>
            <td>初期</td>
        </tr>
    </table>
</div>
<h4>目前近況</h4>
<%  if (ViewBag.Preview == true)
    { %>
        <pre class="call-action call-action-boxed call-action-style4 clearfix"><%= String.IsNullOrEmpty(_model.RegisterLesson.UserProfile.RecentStatus) ? "目前尚無任何近況哦!!" : _model.RegisterLesson.UserProfile.RecentStatus %></pre>
<%  }
    else
    { %>
        <textarea class="form-control" name="recentStatus" rows="3"><%= _model.RegisterLesson.UserProfile.RecentStatus %></textarea>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    bool? _assessment;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _assessment = (bool?)ViewBag.Assessment;
    }

</script>
