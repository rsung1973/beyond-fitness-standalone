<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  var items = models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID)
                    .TotalLessons(models)
                    .Where(l => l.ClassTime >= startDate && l.ClassTime < endDate);
   
    foreach (var item in items)
    {
        if (item.IsPTSession())
        {   %>
<div class="added-event type1" data-date="<%= $"{item.ClassTime:yyyy-MM-dd}" %>" data-title="<%= $"{item.ClassTime:yyyy-MM-dd HH:mm}" %>-<%= $"{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}" %>【P.T】" data-event-id="<%= item.LessonID %>" data-link="#"></div>
    <%  }
        else if (item.IsPISession())
        {   %>
<div class="added-event type1" data-date="<%= $"{item.ClassTime:yyyy-MM-dd}" %>" data-title="<%= $"{item.ClassTime:yyyy-MM-dd HH:mm}" %>-<%= $"{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}" %>【P.I】" data-event-id="<%= item.LessonID %>" data-link="#"></div>
    <%  }
        else if (item.IsTrialLesson())
        {   %>
<div class="added-event type3" data-date="<%= $"{item.ClassTime:yyyy-MM-dd}" %>" data-title="<%= $"{item.ClassTime:yyyy-MM-dd HH:mm}" %>-<%= $"{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}" %>【體驗檢測】" data-event-id="<%= item.LessonID %>" data-link="#"></div>
    <%  }
        else if (item.IsSTSession())
        {   %>
<div class="added-event type1" data-date="<%= $"{item.ClassTime:yyyy-MM-dd}" %>" data-title="<%= $"{item.ClassTime:yyyy-MM-dd HH:mm}" %>-<%= $"{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}" %>【S.T】" data-event-id="<%= item.LessonID %>" data-link="#"></div>
    <%  }
    }   %>
<%
    var eventItems = models.GetTable<UserEvent>()
        .Where(t => (t.StartDate >= startDate && t.StartDate < endDate)
                || (t.EndDate >= startDate && t.EndDate < endDate)
                || (t.StartDate < startDate && t.EndDate >= endDate))
        .Where(t => !t.EventType.HasValue)
        .Where(t => !t.SystemEventID.HasValue)
        .Where(t => t.UID == _model.UID);

    foreach (var item in eventItems)
    {
        for (var d = new DateTime(Math.Max(item.StartDate.Date.Ticks,startDate.Value.Ticks)); d < new DateTime(Math.Min(item.EndDate.Date.AddDays(1).Ticks,endDate.Value.Ticks)); d = d.AddDays(1))
        {
            var hasLesson = items.Any(l => l.ClassTime >= d && l.ClassTime < d.AddDays(1));   %>
<div class="<%= $"added-event type{(hasLesson ? 2 : 4)}" %>" data-date="<%= $"{d:yyyy-MM-dd}" %>" data-title="<%= (item.StartDate-d).TotalHours>0 ? $"{item.StartDate:yyyy-MM-dd HH:mm}" : $"{d:yyyy-MM-dd}" %> <%= item.Title %>" data-event-id="<%= item.EventID %>" data-link="#"></div>
    <%  }%>
<%  }

%>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    DateTime? startDate, endDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        startDate = ViewBag.StartDate ?? new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        endDate = startDate.Value.AddMonths(1);

    }

</script>
