<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile.IsAssistant())
    { %>
<%--<li>
    <a href="<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/ConfigureAll") %>" title="基本資料"><i class="fa fa-lg fa-fw fa-database"></i><span class="menu-item-parent">基本資料</span></a>
</li>--%>
<%  } %>

<li>
    <a href="#"><i class="fa fa-lg fa-fw fa-tasks"></i><span class="menu-item-parent">顧問服務費</span></a>
    <ul>
        <li>
            <a href="../../../front-end/pricing-arena.html" target="_blank"><i class="fa fa-fw fa-th-list"></i>南京小巨蛋</a>
        </li>
        <li>
            <a href="../../../front-end/pricing-101.html" target="_blank"><i class="fa fa-fw fa-th-list"></i>Enhanced 101</a>
        </li>
        <li>
            <a href="../../../front-end/pricing-sogo.html" target="_blank"><i class="fa fa-fw fa-th-list"></i>忠孝</a>
        </li>
    </ul>
</li>
<%  if (_userProfile.EmployeeWelfare != null && _userProfile.EmployeeWelfare.MonthlyGiftLessons > 0)
    { %>
<li>
    <a href="<%= Url.Action("LearnerIndex", "CornerKick") %>" target="_blank"><i class="fa fa-lg fa-fw fa-address-card "></i><span class="menu-item-parent">學員儀表板</span></a>
</li>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;
    ModelSource<UserProfile> models;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser().LoadInstance(models);
    }

</script>
