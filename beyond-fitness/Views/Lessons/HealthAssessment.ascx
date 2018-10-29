<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_profile != null)
    { %>
<div class="tab-content">
    <div class='tab-pane active'>
        <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <% Html.RenderPartial("~/Views/Lessons/LearnerHealthAssessment.ascx", _groups.First()); %>
        </div>
    </div>
</div>
<%  }
    else
    { %>
<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
        <ul class="nav nav-tabs">
            <%  int idx = 0;
                foreach (var item in _groups)
                {
                    idx++; %>
                    <li class='<%= idx == 1 ? "active" : null %>'>
                        <a href="#<%= _tabPrefix + idx %>" data-toggle="tab">
                            <span class="<%= idx == 1 ? "badge bg-color-blue txt-color-white" : "badge bg-color-blueDark txt-color-white" %>">
                                <i class="<%= item.UserProfile.UserProfileExtension.Gender == "F" ? "fa fa-female" : "fa fa-male" %>"></i></span><%= item.UserProfile.FullName() %></a>
                    </li>
            <%      
                } %>
        </ul>
        <div class="tab-content">
            <%  idx = 0;
                foreach (var item in _groups)
                {
                    idx++;%>
                    <div class='<%= idx == 1 ? "tab-pane active" : "tab-pane" %>' id='<%= _tabPrefix + idx %>'>
                        <% Html.RenderPartial("~/Views/Lessons/LearnerHealthAssessment.ascx", item); %>
                    </div>
            <%  } %>
        </div>
</div>
<%  } %>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTime _model;
    List<LessonFitnessAssessment> _groups;
    String _tabPrefix = "tab-health";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTime)this.Model;
        _profile = (UserProfile)ViewBag.Profile;
        if (_profile != null)
        {
            _groups = _model.LessonFitnessAssessment.Where(f => f.UID == _profile.UID).ToList();
        }
        else
        {
            _groups = _model.LessonFitnessAssessment.ToList();
        }
    }

</script>
