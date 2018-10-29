<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  if (_items != null && _items.Count() > 0)
    {     %>
<table class="table">
    <tr class="info">
        <th class="col-xs-1 col-md-3 text-center">時間</th>
        <%--<th class="col-xs-9 col-md-2 text-center">學員</th>--%>
        <%--<th class="col-xs-2 col-md-7">功能</th>--%>
    </tr>
    <%  foreach (var item in _items)
        { %>
    <tr>
        <td class="text-center"><%= item.Hour %>:00 - <%= item.Hour + 1 %>:00</td>
        <%--<td class="text-center"><%= item.RegisterLesson.GroupingMemberCount > 1
                         ? String.Join("<br/>", item.RegisterLesson.GroupingLesson.RegisterLesson.Select(l => l.UserProfile.RealName))
                         : item.RegisterLesson.UserProfile.FullName() %></td>--%>
        <%--<td>
            <%
                if (item.LessonTime.LessonAttendance == null && item.RegisterLesson.UserProfile.LevelID == (int)Naming.MemberStatusDefinition.Anonymous)
                { %>
                    <a onclick="revokeBooking(<%= item.LessonID %>);" class="btn btn-system btn-small">取消預約 <i class="fa fa-calendar-alt-times-o" aria-hidden="true"></i></a>
            <%  } %>
        </td>--%>
    </tr>
    <%  } %>
</table>
<%  } %>
<%--<script>

    function revokeBooking(lessonID) {
        confirmIt({ title: '取消預約', message: '確定取消預約此課程?' }, function (evt) {
            $('#loading').css('display', 'table');
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/RevokeBookingByFreeAgent") %>', { lessonID: lessonID }, function (data) {
                if (data.result) {
                    $('#dailyBooking').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingList") %>', { 'lessonDate': pageParam.lessonDate }, function () { });
                    plotData(pageParam.lessonDate);
                    showAttendee(pageParam.lessonDate, pageParam.hour);
                    $('#calendar').fullCalendar('refetchEvents');
                    $('#clockIn').load('<%= VirtualPathUtility.ToAbsolute("~/Account/FreeAgentClockIn") %>', { 'lessonDate': pageParam.lessonDate }, function () { });

                } else {
                    smartAlert(data.message);
                }
                $('#loading').css('display', 'none');
            });
        });
    }

</script>--%>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DateTime? _lessonDate;
    IQueryable<LessonTimeExpansion> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = ((IQueryable<LessonTimeExpansion>)this.Model).OrderBy(t => t.ClassDate).ThenBy(t => t.Hour);
    }

</script>
