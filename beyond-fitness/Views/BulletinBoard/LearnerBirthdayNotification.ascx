<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <!-- content goes here -->
    <h5 class="todo-group-title"><i class="fa fa-birthday-cake"></i> 生日提醒 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
    <%  if (_items.Count() > 0)
        { %>
        <div>
            <ul class="notification-body">
                <%  foreach (var item in _items)
                    { %>
                <li>
                    <span class="padding-10">
                        <em class="badge padding-5 no-border-radius bg-color-darken pull-left margin-right-5">
                            <%  item.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %></em>
                        <span><%= item.FullName() %> <%= item.Birthday.Value.DayOfYear == DateTime.Today.DayOfYear ? "今天" : String.Format("{0:M月d日}",item.Birthday) %>生日喔！
                                                            <a href="http://line.me/R/msg/text/?在這特別的一天, 祝你生日快樂">
                                                                <img src="../img/line/linebutton_84x20_zh-hant.png" width="84" height="20" alt="用LINE傳送" /></a>
                        </span>
                    </span>
                </li>
                <%  } %>
            </ul>
        </div>
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
    DateTime? _lessonDate;
    IQueryable<UserProfile> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = DateTime.Today;   //(DateTime?)this.Model;

        _items = models.GetTable<UserProfile>().Where(u => u.Birthday.HasValue
                && u.Birthday.Value.DayOfYear >= _lessonDate.Value.DayOfYear
                && u.Birthday.Value.DayOfYear <= _lessonDate.Value.AddDays(7).DayOfYear)
            .OrderByDescending(u => u.Birthday.Value.DayOfYear);

    }

</script>
