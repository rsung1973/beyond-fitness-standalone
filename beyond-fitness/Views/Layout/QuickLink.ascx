<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
    <!-- /well -->
    <div class="well bg-color-darken txt-color-white padding-10">
        <h5 class="margin-top-0"><i class="fa fa-envelope"></i> 聯絡我們</h5>
        <ul class="no-padding no-margin">
            <ul class="icons-list">
                <li>
                    <a title="電話" href="tel:+886227152733"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-phone fa-stack-1x"></i></span>(02)2715-2733</a>
                </li>
                <li>
                    <a title="地址"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-map-marker fa-stack-1x"></i></span>台北市松山區南京東路四段17號B1</a>
                </li>
                <li>
                    <a title="Email" href="mailto:info@beyond-fitness.tw"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-envelope-o fa-stack-1x"></i></span>info@beyond-fitness.tw</a>
                </li>
            </ul>
        </ul>
    </div>
    <!-- /well -->
    <!-- /well -->
    <div class="well bg-color-darken txt-color-white padding-10">
        <h5 class="margin-top-0"><i class="fa fa-external-link"></i>  快速功能</h5>
        <ul class="no-padding no-margin">
            <p class="no-margin">
                <ul class="icons-list">
                    <li>
                        <a title="忘記密碼" href="<%= VirtualPathUtility.ToAbsolute("~/Account/ForgetPassword") %>"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-key fa-stack-1x"></i></span>忘記密碼</a>
                    </li>
                    <li>
                        <a title="註冊" href="<%= VirtualPathUtility.ToAbsolute("~/Account/Register") %>"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-user fa-stack-1x"></i></span>會員註冊</a>
                    </li>
                    <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Login.ascx"); %>
                </ul>
            </p>
        </ul>
    </div>
    <!-- /well -->
</article>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = this.Context.GetUser();
    }

</script>
