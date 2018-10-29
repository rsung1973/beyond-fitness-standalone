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

<%  foreach (var item in _items)
    {
        var lessonCount = item.RemainedLessonCount();

        var pastReserved = item.LessonTime.Count(l => l.ClassTime < DateTime.Today.AddDays(1) && l.LessonAttendance == null);
        var incomingReserved = item.LessonTime.Count(l => l.ClassTime >= DateTime.Today);

        var bookingCount = item.GroupingLesson.LessonTime.Count;

%>
<label class="<%= lessonCount>0 ? "radio" : "radio state-disabled" %>">
    <input type="radio" name="registerID" value="<%= item.RegisterID %>" <%= lessonCount>0 ? null : "disabled" %> />
    <i></i>
    <%= item.UserProfile.FullName() %> / 剩餘<%= lessonCount %>堂 / 截至本月<%= item.Lessons %>堂
          
    <%  if (incomingReserved > 0)
        { %>
            (已預約<%= incomingReserved %>堂)
    <%  } %>
    <%  if (pastReserved > 0)
        { %>
            (已預約未完成上課<%= pastReserved %>堂)
    <%  } %>
</label>
<%  }   %>


<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<RegisterLesson> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _items = (IQueryable<RegisterLesson>)this.Model;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
