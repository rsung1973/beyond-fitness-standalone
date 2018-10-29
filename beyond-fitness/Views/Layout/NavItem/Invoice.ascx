<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile != null)
    { %>
<li>
    <a href="#" title="電子發票管理"><i class="fa fa-lg fa-fw fa-qrcode"></i><span class="menu-item-parent">發票管理</span></a>
    <ul>
        <%--<li>
            <a href="<%= Url.Action("PrintIndex","Invoice") %>" title="電子發票列印"><i class="fa fa-lg fa-fw fa-print"></i>電子發票列印</a>
        </li>--%>
        <%  if (_userProfile.IsSysAdmin())
            { %>
        <li>
            <a href="<%= Url.Action("VacantNoIndex", "Invoice") %>" title="空白電子發票下載"><i class="fa fa-lg fa-fw fa-cloud-download-alt"></i>空白電子發票下載</a>
        </li>
        <%  }
            if (_userProfile.IsAssistant())
            {   %>
        <li>
            <a href="<%= Url.Action("TurnkeyIndex", "Invoice") %>" title="電子發票上傳紀錄查詢"><i class="fas fa-lg fa-fw fa-cloud-upload-alt"></i>電子發票上傳紀錄查詢</a>
        </li>
        <%  }
            if (_userProfile.IsAccounting() || _userProfile.IsSysAdmin())
            { %>
        <li>
            <a href="<%= Url.Action("InvoiceNoIndex", "Invoice") %>" title="電子發票號碼維護"><i class="fa fa-lg fa-fw fa-qrcode"></i>電子發票號碼維護</a>
        </li>
        <%  } %>
    </ul>
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
