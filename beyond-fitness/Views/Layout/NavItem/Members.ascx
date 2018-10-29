<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile != null
&& (_userProfile.CurrentUserRole.RoleID == (int)Naming.RoleID.Administrator
    || _userProfile.IsAssistant()
    || _userProfile.IsOfficer()))
    { %>
<li>
    <a href="#" title="人員管理"><i class="fas fa-lg fa-fw fa-users"></i><span class="menu-item-parent">人員管理</span></a>
    <ul>
        <li>
            <a href="<%= Url.Action("Index","Learner") %>"><i class="fa fa-fw fa-user"></i>學員管理</a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListCoaches") %>"><i class="fa fa-fw fa-user-secret"></i>員工管理</a>
        </li>
    </ul>
</li>
<%  }
    else if(_userProfile.IsCoach())
    { %>
<li>
    <a href="<%= Url.Action("Index","Learner") %>" title="學員管理"><i class="fa fa-lg fa-fw fa-user"></i><span class="menu-item-parent">學員管理</span></a>
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
