<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">
    <div class="col-md-12">
        <%
            int? lessons = models.GetTable<RegisterLesson>().Where(l => l.UID == _model.UID)
                .Sum(l => (int?)l.Lessons);
            int? attendances = models.GetTable<RegisterLesson>().Where(l => l.UID == _model.UID)
                .Sum(l => (int?)l.LessonTime.Where(t => t.LessonAttendance != null).Count());
             %>
        <p class="text-right">總上課次數/剩餘上課次數：<%= lessons %>/<%= lessons-attendances %> </p>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

    }

</script>
