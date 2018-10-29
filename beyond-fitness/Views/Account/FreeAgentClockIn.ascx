<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_items.Count() > 0)
    {
        if (_items.Count() > 1)
        { %>
            <span class="dropdown">
                <a class="btn-system btn-small dropdown-toggle" id="freeAgentClockIn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">自由教練打卡 <i class="far fa-check-square" aria-hidden="true"></i></a>
                <ul class="dropdown-menu" aria-labelledby="freeAgentClockIn">
                    <%  foreach (var item in _items)
                        { %>
                            <li><a onclick="clockIn(<%= item.CoachID %>);"><%= item.UserProfile.FullName() %></a></li>
                    <%  } %>
                </ul>
            </span>
    <%  }
        else
        {   %>
            <a class="btn-system btn-small" onclick="clockIn(<%= _items.First().CoachID %>);">自由教練打卡 <i class="far fa-check-square" aria-hidden="true"></i></a>
    <%  }
            %>
<script>
    function clockIn(coachID) {
        $('#loading').css('display', 'table');
        $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/FreeAgentClockIn") %>', { 'coachID': coachID }, function (data) {
            if (data.result) {
                $('#clockIn').load('<%= VirtualPathUtility.ToAbsolute("~/Account/FreeAgentClockIn") %>', { 'coachID': coachID }, function () { });
                showAttendee(pageParam.lessonDate, pageParam.hour);
                smartAlert('自由教練打卡完成!!');
            } else {
                smartAlert(data.message);
            }
            $('#loading').css('display', 'none');
        });
    }
</script>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<ServingCoach> _items;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _items = models.GetTable<LessonTime>()
            .Where(l => l.ClassTime >= DateTime.Today && l.ClassTime < DateTime.Today.AddDays(1))
            .Where(l => l.LessonAttendance == null)
            .Select(l => l.AsAttendingCoach);
        if (_model.IsFreeAgent())
        {
            _items = _items.Where(s => s.CoachID == _model.UID);
        }
        else
        {
            _items = _items.Where(s => s.UserProfile.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.FreeAgent));
        }
    }

</script>
