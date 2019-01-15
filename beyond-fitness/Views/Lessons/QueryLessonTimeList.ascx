<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<%  foreach (var item in _model)
    { %>
        <label class="radio">
            <input type="radio" name="sourceID" value="<%= item.LessonID %>" />
            <i></i><%= item.RegisterLesson.UserProfile.FullName() %>「<%= String.Format("{0:yyyy/MM/dd HH:mm}",item.ClassTime) %>-<%= String.Format("{0:HH:mm}",item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value)) %>」課表
            <%  if( item.RegisterLesson.GroupingMemberCount>1)
                {   %>
                        <li class="fa fa-group"></li>
                        團體《<%= String.Join("·", models.GetTable<GroupingLesson>().Where(g => g.GroupID == item.RegisterLesson.RegisterGroupID)
                                                .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterID != item.RegisterLesson.RegisterID),
                                                    g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                                                .Select(r => r.UserProfile.RealName)) %>》
            <%  }
                else
                {   %>
            <%      if (item.TrainingBySelf == 1)
                    {   %>
                        (P.I session)
                <%  }
                    else
                    {   %>
                        <li class="fa fa-child"></li>個人
                <%  }
                } %>
            <a class="btn btn-success btn-sm" onclick="showRecentLessons(<%= item.RegisterLesson.UID %>,<%= item.LessonID %>);">檢視課表</a>
        </label>
<%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DailyBookingQueryViewModel _viewModel;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _model = (IQueryable<LessonTime>)this.Model;
        ViewBag.CloneLesson = true;
    }

</script>
