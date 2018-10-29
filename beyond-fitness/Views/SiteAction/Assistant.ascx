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

<nav>
    <ul>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Calendar.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Members.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Contract.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Payment.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Invoice.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Achievement.ascx", _userProfile); %>
        <%--<% Html.RenderPartial("~/Views/Layout/NavItem/Lessons.ascx", _userProfile); %>--%>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Report.ascx", _userProfile); %>
        <% Html.RenderPartial("~/Views/Layout/NavItem/Professional.ascx", _userProfile); %>
        <%--<li>
            <a href="<%= Url.Action("PriceList","Information") %>"><i class="fa fa-lg fa-fw fa-tasks"></i>顧問費用表</a>
        </li>--%>
        <% Html.RenderPartial("~/Views/Layout/NavItem/SystemInfo.ascx", _userProfile); %>

        <%--<li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>" title="登出"><i class="fa fa-lg fa-fw fa-sign-out"></i><span class="menu-item-parent">登出</span></a>
        </li>--%>
    </ul>
</nav>

<% Html.RenderPartial("~/Views/Shared/Loading.ascx"); %>

<script>
    $('#logout').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_logout').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#coach').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_coach').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#member').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_member').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#pub').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });
    $('#m_pub').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });

    $('.learner').on('click', function (evt) {
        $('#loading').css('display', 'table');
    });


    <%--
    $(function () {
        window.history.forward();
    });--%>
</script>


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
