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

    <!-- content goes here -->
    <h5 class="todo-group-title"><i class="fa fa-exclamation"></i>上課提醒 (<small class="num-of-tasks"><%= _model.Count() %></small>)</h5>
    <ul id="sortable2" class="todo">
        <%  foreach (var item in _model)
            { %>
        <li>
            <span class="handle"><i class="fa fa-heartbeat fa-2x text-danger"></i>&nbsp;&nbsp;</span>
            <p>
                <strong><%= item.ClassTime.Value.ToString("yyyy/M/d HH:mm") %>~<%= item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value).ToString("HH:mm") %>  </strong>
                <%  if (item.TrainingBySelf == 1)
                    { %>
                        自主訓練喔！
                <%  }
                    else
                    { %>
                        與<%= item.AsAttendingCoach.UserProfile.FullName() %>一起運動喔！
                <%  } %>
                <span><a href="http://line.naver.jp/R/msg/text/?LINE%E3%81%A7%E9%80%81%E3%82%8B%0D%0Ahttp%3A%2F%2Fline.naver.jp%2F">
                    <img src="<%= VirtualPathUtility.ToAbsolute("~/img/line/linebutton_84x20_zh-hant.png") %>" width="84" height="20" alt="用LINE傳送" /></a></span>
            </p>
        </li>
        <%  } %>
    </ul>
    <!-- end content -->


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
    }

</script>
