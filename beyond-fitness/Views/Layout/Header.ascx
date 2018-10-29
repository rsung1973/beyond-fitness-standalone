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
            <img src="~/img/logo.png" alt="SmartAdmin" runat="server" />
        </span>
        <!-- END LOGO PLACEHOLDER -->

<%--        <!-- Note: The activity badge color changes when clicked and resets the number to 0
				Suggestion: You may want to set a flag when this happens to tick off all checked messages / notifications -->
        <span id="activity" class="activity-dropdown"><i class="fa fa-user"></i><b class="badge">21 </b></span>

        <!-- AJAX-DROPDOWN : control this dropdown height, look and feel from the LESS variable file -->
        <div class="ajax-dropdown">

            <!-- the ID links are fetched via AJAX to the ajax container "ajax-notifications" -->
            <div class="btn-group btn-group-justified" data-toggle="buttons">
                <label class="btn btn-default">
                    <input type="radio" name="activity" id="ajax/notify/mail.html">
                    個人訊息 (14)
                </label>
                <label class="btn btn-default">
                    <input type="radio" name="activity" id="ajax/notify/notifications.html">
                    提醒通知 (3)
                </label>
            </div>

            <!-- notification content -->
            <div class="ajax-notifications custom-scroll">

                <div class="alert alert-transparent">
                    <h4>在這邊有許多有趣的訊息喔！</h4>
                    This blank page message helps protect your privacy, or you can show the first message here automatically.
                </div>

                <i class="fa fa-lock fa-4x fa-border"></i>

            </div>
            <!-- end notification content -->

            <!-- footer: refresh area -->
            <span>最後更新時間: 2016/07/23 9:43AM
						<button type="button" data-loading-text="<i class='fa fa-refresh fa-spin'></i> Loading..." class="btn btn-xs btn-default pull-right">
                            <i class="fa fa-refresh"></i>
                        </button>
            </span>
            <!-- end footer -->

        </div>
        <!-- END AJAX-DROPDOWN -->--%>
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
            <span><a href="login.html" title="Sign Out" data-action="userLogout" data-logout-msg="為了安全起見，建議您登出後將網頁關閉！"><i class="fa fa-sign-out"></i></a></span>
        </div>
        <!-- end logout button -->

        <!-- multiple lang dropdown : find all flags in the flags page -->
        <ul class="header-dropdown-list hidden-xs">
            <li>
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                    <img runat="server" src="~/img/blank.gif" class="flag flag-tw" alt="United States">
                    <span>中文 </span><i class="fa fa-angle-down"></i></a>
            </li>
        </ul>
        <!-- end multiple lang -->
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
