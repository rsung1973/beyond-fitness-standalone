<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile != null && _userProfile.CurrentUserRole.RoleID!=(int)Naming.RoleID.Learner)
    { %>
<li>
    <a href="<%= VirtualPathUtility.ToAbsolute("~/Lessons/QueryVip") + "?userName=" + _model.FullName() %>" title="我的學員"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-search fa-stack-1x"></i></span> 我的學員</a>
</li>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
        _model = (UserProfile)this.Model;
    }

</script>
