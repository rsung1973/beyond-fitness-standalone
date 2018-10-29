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
<%  if (_items.Count() > 0)
    { %>
    <ul class="notification-body">
        <%  foreach (var item in _items)
            { %>
            <li>
                <span class="unread">
                    <a onclick="lessonCommentActivity(event,<%= item.CommentID %>);" class="msg">
                        <%  item.Speaker.RenderUserPicture(Writer, new { @class = "air air-top-left margin-top-5", @style = "width:40px" }); %>
                        <span class="from"><%= item.Speaker.FullName() %> <i class="icon-paperclip"></i></span>
                        <time><%= item.CommentDate %><span class="news_msg"></span></time>
                        <span class="msg-body"><%= item.Comment %> </span>
                    </a>
                </span>
            </li>
        <%  } %>
    </ul>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    IQueryable<LessonComment> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        if (_profile.IsSysAdmin())
        {
            _items = models.GetTable<LessonComment>()
                .Where(u => u.Status == (int)Naming.IncommingMessageStatus.未讀 || u.CommentDate >= DateTime.Today.AddDays(-7))
                .Where(u => u.Speaker.ServingCoach == null)
                .OrderByDescending(u => u.CommentDate);
        }
        else
        {
            _items = models.GetTable<LessonComment>().Where(u => u.HearerID == _profile.UID)
                .Where(u => u.Status == (int)Naming.IncommingMessageStatus.未讀 || u.CommentDate >= DateTime.Today.AddDays(-7))
                .OrderByDescending(u => u.CommentDate);
        }

    }

</script>
