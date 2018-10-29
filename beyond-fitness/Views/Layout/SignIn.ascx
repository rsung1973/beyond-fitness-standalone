<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<ul id="mobile-profile-img" class="header-dropdown-list hidden-xs padding-5">
    <li class="">
        <a href="#" class="dropdown-toggle no-margin userdropdown" data-toggle="dropdown">
            <img src="~/img/avatars/male.png" class="online" runat="server" />
        </a>
        <ul class="dropdown-menu pull-right">
            <li>
                <a href="<%= FormsAuthentication.LoginUrl %>" class="padding-10 padding-top-5 padding-bottom-5"><i class="fa fa-sign-in fa-lg"></i><strong><u>L</u>ogin</strong></a>
            </li>
        </ul>
    </li>
</ul>


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
