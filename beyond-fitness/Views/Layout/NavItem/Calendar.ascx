<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>

<%  if (_userProfile != null
    && (_userProfile.IsSysAdmin() || _userProfile.IsCoach() || _userProfile.IsAssistant() || _userProfile.IsOfficer()))
    { %>
<li>
    <a href="<%= Url.Action("Index","CoachFacet",new { KeyID = _userProfile.IsCoach() || _userProfile.IsAssistant() ? _userProfile.UID.EncryptKey() : null }) %>" title="行事曆"><i class="far fa-lg fa-fw fa-calendar-check"></i><span class="menu-item-parent">行事曆</span></a>
</li>
<%  } %>

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
