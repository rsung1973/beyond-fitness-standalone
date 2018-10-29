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
<%@ Import Namespace="Newtonsoft.Json" %>

    <!-- content goes here -->
<h5 class="todo-group-title"><i class="fa fa-volume-off"></i> 未填寫學員滿意度問卷 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
    <%  if (_items.Count() > 0)
        { %>
        <div class="custom-scroll" style="height: 200px; overflow-y: scroll;">
            <ul class="notification-body">
                <%  foreach (var item in _items)
                    { %>
                <li>
                    <span class="padding-10">
                        <em class="badge padding-5 no-border-radius bg-color-darken pull-left margin-right-5">
                            <a href="<%= Url.Action("ShowLearner","Member", new { id = item.UID }) %>">
                                <%  item.UserProfile.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %></a>
                        </em>
                        <time>
                            <a href="http://line.me/R/msg/text/?Hi <%= item.UserProfile.FullName() %>, 請記得登入http%3A%2F%2Fwww.beyond-fitness.tw%2F填寫課後滿意度問卷喔！">
                                <img src="../img/line/linebutton_84x20_zh-hant.png" width="84" height="20" alt="用LINE傳送" />
                            </a>
                        </time>
                        <span><%= item.UserProfile.FullName() %>尚未填寫上課滿意度問卷
                                                            <br/>
                            <span class="font-xs text-muted"><i>提醒您通知學員登入系統後填寫滿意度問卷才可預約下一次上課！</i></span>
                        </span>
                    </span>
                </li>
                <%  } %>
            </ul>
        </div>
    <%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    IQueryable<QuestionnaireRequest> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        IQueryable<QuestionnaireRequest> questItems = models.GetTable<QuestionnaireRequest>();

        if (_profile.IsSysAdmin())
        {
            _items = questItems.Where(q => q.PDQTask.Count == 0)
                .OrderByDescending(q => q.QuestionnaireID)
                .Take(60);
        }
        else
        {
            questItems = questItems.Where(q => q.RegisterLesson.AdvisorID == _profile.UID);
            _items = questItems.Where(q => q.PDQTask.Count == 0)
                .OrderByDescending(q => q.QuestionnaireID)
                .Take(30);
        }

    }

</script>
