<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_item != null)
    { %>
<h4 class="font-md">
    <strong><%= _item.Lessons
                    -_item.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/) %> / <%= _item.Lessons %></strong>
    <br />
    <small>剩餘/購買上課次數</small>
    <br />
    <strong><%= _item.GroupingLesson.LessonTime.Count(l=>l.LessonAttendance== null && l.ClassTime<DateTime.Today.AddDays(1)) %> / 
            <%= _item.GroupingLesson.LessonTime.Count(l=>l.ClassTime>=DateTime.Today) %></strong>
    <br />
    <small>未完成/已預約 上課數</small>
</h4>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _model;
    RegisterLesson _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _item = _model.RegisterLesson.OrderByDescending(r => r.RegisterID).FirstOrDefault();
    }

</script>
