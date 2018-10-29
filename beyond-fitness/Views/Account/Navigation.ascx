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

<%  if (_userProfile.IsAuthorizedSysAdmin())
    {
        Html.RenderPartial("~/Views/SiteAction/SystemAdmin.ascx", _userProfile);
    }
    else if (_userProfile.IsOfficer())
    {
        Html.RenderPartial("~/Views/SiteAction/Officer.ascx", _userProfile);
    }
    else if (_userProfile.IsCoach())
    {
        Html.RenderPartial("~/Views/SiteAction/Coach.ascx", _userProfile);
    }
    else if (_userProfile.IsFreeAgent())
    {
        Html.RenderPartial("~/Views/SiteAction/FreeAgent.ascx", _userProfile);
    }
    else if (_userProfile.IsAssistant())
    {
        Html.RenderPartial("~/Views/SiteAction/Assistant.ascx", _userProfile);
    }
    else if (_userProfile.IsAccounting())
    {
        Html.RenderPartial("~/Views/SiteAction/Accounting.ascx", _userProfile);
    }
    else if (_userProfile.IsLearner())
    {
        Html.RenderPartial("~/Views/SiteAction/Learner.ascx", _userProfile);
    }
    else if (_userProfile.IsServitor())
    {
        Html.RenderPartial("~/Views/SiteAction/Servitor.ascx", _userProfile);
    }
    else
    {
        Html.RenderPartial("~/Views/SiteAction/Guest.ascx", _userProfile);
    }
    %>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
    }

</script>
