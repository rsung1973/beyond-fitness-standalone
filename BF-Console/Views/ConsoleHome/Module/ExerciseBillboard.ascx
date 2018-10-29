<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  
    var items = _model.GroupBy(l => l.RegisterLesson.UID)
        .Select(g => new { g.Key, TotalMinutes = (decimal?)g.Sum(l => l.DurationInMinutes) })
            .Where(s => s.TotalMinutes > 0)
            .OrderByDescending(s => s.TotalMinutes)
            .ThenByDescending(s => s.Key)
            .Take(5).ToArray();
%>
<table class="table m-t-15 m-b-0">
    <tbody>
        <%  int idx = 0;
            DateTime dateFrom = DateTime.Today.FirstDayOfMonth().AddMonths(-1);
            DateTime dateTo = DateTime.Today.AddMonths(-1).AddDays(1);
            foreach (var g in items)
            {
                var coach = models.GetTable<UserProfile>().Where(u => u.UID == g.Key).First();  %>
        <tr>
            <td>
                <%  
                    var workPlace = models.GetTable<CoachWorkplace>().Where(p => p.CoachID == coach.UID);
                    var w = workPlace.FirstOrDefault();
                    if (w == null || workPlace.Count() > 1)
                    {
                %>
                <%  }
                    else if (w.BranchID == (int)Naming.BranchName.信義)
                    {   %>
                <span class='badge round bg-purple'><%= w.BranchStore.BranchName %></span>
                <%  }
                    else if (w.BranchID == (int)Naming.BranchName.南京)
                    {   %>
                <span class='badge round bg-vivid_red'><%= w.BranchStore.BranchName %></span>
                <%  }
                    else
                    {   %>
                <span class='badge round bg-blue'><%= w.BranchStore.BranchName %></span>
                <%  } %>
                <%= coach.RealName %><small>(<%= coach.Nickname %>)</small>
                <%  if (idx == 0)
                    {   %>
                <i class="zmdi livicon-evo" data-options="name: trophy.svg; size: 24px; style: original; autoPlay:true"></i>
                <%  }
                    idx++; %>
            </td>
            <td><%= (int)(g.TotalMinutes/60) %>：<%= $"{g.TotalMinutes%60:00}" %>
                <%  if (ViewBag.CompareToLastMonth == true)
                    {
                        var lessons = models.GetTable<RegisterLesson>().Where(r => r.UID == g.Key);
                        var totalMinutesLastMonth = models.PromptMemberExerciseLessons(lessons)
                                .Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateTo)
                                .Sum(l => l.DurationInMinutes) ?? 0;
                        if (g.TotalMinutes > totalMinutesLastMonth)
                        {   %>
                <i class="zmdi zmdi-caret-up text-danger"></i>
                <%      }
                        else if (g.TotalMinutes < totalMinutesLastMonth)
                        {              %>
                <i class="zmdi zmdi-caret-down text-success"></i>
                    <%  }
                    }%>
            </td>
        </tr>
        <%  }
            for (; idx < 5; idx++)
            {   %>
        <tr>
            <td>--</td>
            <td>--</td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
    }


</script>
