<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<header id="header">
    <div id="logo-group">

        <!-- PLACE YOUR LOGO HERE -->
        <span id="logo">
            <img src="~/img/logo.png" alt="SmartAdmin" runat="server" style="width:130px;" />
        </span>
        <!-- END LOGO PLACEHOLDER -->
        <%--<%  Html.RenderPartial("~/Views/BulletinBoard/ActivityNotification.ascx"); %>--%>

    </div>

    <!-- pulled right: nav area -->
    <div class="pull-right">

        <!-- collapse menu button -->
        <div id="hide-menu" class="btn-header pull-right">
            <span><a href="javascript:void(0);" data-action="toggleMenu" title="Collapse Menu"><i class="fa fa-reorder"></i></a></span>
        </div>
        <!-- end collapse menu -->

        <!-- #MOBILE -->
        <!-- Top menu profile link : this shows only when top menu is active -->
        <%  if (_userProfile == null || _userProfile.LevelID == (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                Html.RenderPartial("~/Views/Layout/SignIn.ascx");
            }
            else
            {
                Html.RenderPartial("~/Views/Layout/SignOut.ascx",_userProfile);
            }   %>

        <!-- logout button -->
        <div id="logout" class="btn-header transparent pull-right">
            <span><a href="<%= Url.Action("Logout","Account") %>" title="Sign Out" data-action="userLogout" data-logout-msg="為了安全起見，建議您登出後將網頁關閉！"><i class="fa fa-sign-out"></i></a></span>
        </div>
        <!-- end logout button -->

    </div>
    <!-- end pulled right: nav area -->

</header>
<!-- END HEADER -->


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _userProfile = Context.GetUser();
    }

</script>
