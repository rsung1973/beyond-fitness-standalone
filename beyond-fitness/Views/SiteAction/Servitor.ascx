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
            <a href="#" title="收款管理"><i class="fa fa-lg fa-fw fa-dollar-sign"></i><span class="menu-item-parent">收款管理</span></a>
            <ul>
                <li>
                    <a href="<%= Url.Action("PaymentIndex","Payment") %>" title="收款新增/作廢"><i class="fa fa-lg fa-fw fa-dollar-sign"></i>收款新增/作廢</a>
                </li>
                <li>
                    <a href="<%= Url.Action("QueryIndex", "Payment") %>" title="收款/作廢紀錄查詢"><i class="fa fa-lg fa-fw fa-search"></i>收款/作廢紀錄查詢</a>
                </li>
            </ul>
        </li>
        <li>
            <a href="#" title="上稿管理"><i class="fa fa-lg fa-fw fa-edit"></i><span class="menu-item-parent">上稿管理</span></a>
            <ul>
                <li>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Publish") %>"><i class="fa fa-fw fa-puzzle-piece"></i>專業知識</a>
                </li>
            </ul>
        </li>
    </ul>
</nav>

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
