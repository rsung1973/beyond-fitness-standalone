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
<h5 class="todo-group-title"><i class="fa fa-commenting"></i> 體能顧問悄悄話 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
    <%  if (_items.Count() > 0)
        { %>
            <ul id="sortable2" class="todo">
            <%  foreach (var item in _items)
                { %>
                <li>
                    <span class="handle">
                        <%  item.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "air air-top-left margin-top-5", @style = "width:40px" }); %></span>
                    <p class="notification-body">
                        <span class="from"><%= item.LessonTime.AsAttendingCoach.UserProfile.FullName() %> <i class="icon-paperclip"></i><a href="javascript:showLearnerLesson(<%= item.LessonID %>, true);" class="btn btn-xs txt-color-white bg-color-blueLight"><i class="fa fa-commenting-o"></i> 回覆</a></span>
                        <time><%= item.LessonTime.ClassTime %></time>
                        <span class="msg-body"><%= item.Remark %></span>
                    </p>
                </li>
            <%  } %>
            </ul>
    <%  } %>

<script>
    function showAttendee(lessonDate, hour) {
        pageParam.hour = hour;
        $('#loading').css('display', 'table');
        $('#attendeeList').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingMembers") %>', { 'lessonDate': lessonDate, 'hour': hour }, function () {
            $('#loading').css('display', 'none');
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    IQueryable<LessonPlan> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        _items = models.GetTable<RegisterLesson>()
            .Where(r => r.UID == _profile.UID)
            .Join(models.GetTable<LessonTime>(), r => r.RegisterGroupID, l => l.GroupID, (r, l) => l)
            .Select(r => r.LessonPlan)
            .Where(u => u.Remark != null && u.Remark.Length > 0)
            .OrderByDescending(u => u.LessonTime.ClassTime).Take(30);

    }

</script>
