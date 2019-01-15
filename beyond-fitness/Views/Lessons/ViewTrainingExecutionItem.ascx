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

<%  foreach (var g in _groups)
    { %>

<div class="col-sm-12">
    <table class="table" width="100%">
        <thead>
            <tr>
                <th data-class="expand" class="col-xs-2 col-sm-2">動作</th>
                <th data-hide="phone" class="col-xs-2 col-sm-2">實際/目標次數</th>
                <th data-hide="phone" class="col-xs-2 col-sm-2">實際/目標強度</th>
                <th data-hide="phone" class="col-xs-2 col-sm-2">加強說明</th>
            </tr>
        </thead>
        <tbody>

            <% foreach (var item in g)
                {
                    Html.RenderPartial("~/Views/Lessons/ViewTrainingItem.ascx", item);
                }

                TrainingItem breakItem = g.Last();
                %>
        </tbody>
    </table>
</div>
<%  if (!String.IsNullOrEmpty(breakItem.ExecutionFeedBack))
    { %>
<div class="col-sm-12">
    <div class="chat-body no-padding profile-message">
        <ul>
            <li class="message">
                <% _model.TrainingPlan.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online" }); %>
                <span class="message-text">
                    <a class="username" href="<%= VirtualPathUtility.ToAbsolute("~/Account/ViewProfile/") + _model.TrainingPlan.LessonTime.AttendingCoach %>"><%= _model.TrainingPlan.LessonTime.AsAttendingCoach.UserProfile.FullName() %></a>
                    <%= breakItem.Remark %>
                </span>
            </li>
                    <li class="message message-reply">
                        <% _model.TrainingPlan.LessonTime.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "authorImg" }); %>
                        <span class="message-text">
                            <a class="username" href="<%= VirtualPathUtility.ToAbsolute("~/Account/ViewProfile/") + _model.TrainingPlan.LessonTime.RegisterLesson.UID %>"><%= _model.TrainingPlan.LessonTime.RegisterLesson.UserProfile.GetVipName() %></a>
                            <%= breakItem.ExecutionFeedBack %>
                        </span>

                        <ul class="list-inline font-xs">
                            <li>
                                <a class="text-muted"><%= String.Format("{0:yyyy/MM/dd HH:mm}", breakItem.ExecutionFeedBackDate) %></a>
                            </li>
                        </ul>
                    </li>
            <%--<li>
                <div class="input-group wall-comment-reply">
                    <input name="conclusion" type="text" class="form-control" placeholder="Type your message here..."/>
                    <span class="input-group-btn">
                        <button class="btn btn-primary" onclick="updateConclusion(<%= _model.TrainingPlan.LessonID %>);">
                            <i class="fa fa-reply"></i>回覆
                        </button>
                    </span>
                </div>
            </li>--%>
        </ul>
    </div>
</div>
<%  } %>

<div class="col-sm-12">
    <hr/>
</div>

<%  } %>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;
    List<List<TrainingItem>> _groups;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
        _groups = new List<List<TrainingItem>>();
        List<TrainingItem> items = new List<TrainingItem>();
        foreach(var item in _model.TrainingItem.OrderBy(t=>t.Sequence))
        {
            if(String.IsNullOrEmpty(item.BreakIntervalInSecond))
            {
                items.Add(item);
            }
            else
            {
                items.Add(item);
                _groups.Add(items);
                items = new List<TrainingItem>();
            }
        }
        if(items.Count>0)
        {
            _groups.Add(items);
        }
    }





</script>
