<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li>
    <a href="#" title="收款管理"><i class="fas fa-lg fa-fw fa-donate"></i><span class="menu-item-parent">收款管理</span></a>
    <ul>
        <li>
            <a href="<%= Url.Action("QueryIndex", "Payment") %>" title="收款/作廢紀錄查詢"><i class="fa fa-lg fa-fw fa-search"></i>收款/作廢紀錄查詢</a>
        </li>
        <li>
            <a href="<%= Url.Action("ReceivableIndex", "Accounting") %>"><i class="far fa-fw fa-file-excel"></i>應收帳款催收表</a>
        </li>
    </ul>
</li>

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
