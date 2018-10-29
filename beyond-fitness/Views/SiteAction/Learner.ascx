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
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Professional") %>" title="專業體能訓練"><i class="fa fa-lg fa-fw fa-heartbeat"></i><span class="menu-item-parent">專業訓練</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Blog") %>" title="專業知識"><i class="fa fa-lg fa-fw fa-puzzle-piece"></i><span class="menu-item-parent">專業知識</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Rental") %>" title="場地租借"><i class="fa fa-lg fa-fw fa-at"></i><span class="menu-item-parent">場地租借</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Products") %>" title="相關商品"><i class="fa fa-lg fa-fw fa-product-hunt"></i><span class="menu-item-parent">相關商品</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Cooperation") %>" title="相關合作"><i class="fa fa-lg fa-fw fa-link"></i><span class="menu-item-parent">相關合作</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" title="聯絡我們"><i class="fa fa-lg fa-fw fa fa-envelope"></i><span class="menu-item-parent">聯絡我們</span></a>
        </li>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Location") %>" title="服務據點"><i class="fa fa-lg fa-fw fa-map-marker"></i><span class="menu-item-parent">服務據點</span></a>
        </li>
        <% Html.RenderPartial("~/Views/Layout/NavItem/TimeLine.ascx", _userProfile); %>
        <li>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Logout") %>" title="登出"><i class="fa fa-lg fa-fw fa-sign-out"></i><span class="menu-item-parent">登出</span></a>
        </li>
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
