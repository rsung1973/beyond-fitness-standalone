<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  foreach(var g in _model.GroupBy(v=>v.EventTime.Value.Date))
    {
        var items = g.ToList();
        Html.RenderPartial("~/Views/ConsoleHome/Module/DailyEventItems.ascx", items);
    }   %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    List<CalendarEventItem> _model;
    DateTime? startDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (List<CalendarEventItem>)this.Model;
    }


</script>
