<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<ul class="nav nav-tabs">
    <%  int idx = 0;
        foreach (var item in _model.RegisterLesson)
        {
            idx++;%>
            <li class='<%= idx==1 ? "active" : null %>'><a id='<%= "toggleTab-" + idx %>' data-target='<%= "#tab-" + idx %>' role="tab" data-toggle="tab"><i class="fa fa-th-list"></i><%= item.UserProfile.FullName() %></a></li>
    <%  } %>
</ul>
<!-- Tab panels -->
<div class="tab-content">
    <!-- Tab Content 1 -->
    <%  idx = 0;
        foreach (var item in _model.RegisterLesson)
        {
            idx++;%>
            <div class='<%= idx==1 ? "tab-pane fade in active" : "tab-pane fade" %>' id='<%= "tab-" + idx %>'>
                <%  ViewBag.ShowPerson = true; ViewBag.Argument = new ArgumentModel { Model = _model.LessonTime, PartialViewName = "~/Views/Lessons/LessonGoal.ascx" };
                            Html.RenderPartial("~/Views/Member/MemberInfo.ascx", item.UserProfile); %>
            </div>
    <%  } %>
    <!-- Tab Content 2 -->
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    GroupingLesson _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (GroupingLesson)this.Model;
    }

</script>
