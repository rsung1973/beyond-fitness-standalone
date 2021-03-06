﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<li>
    <a href="#" title="報表管理"><i class="fa fa-lg fa-fw fa-calculator"></i><span class="menu-item-parent">報表管理</span></a>
    <ul>
<%--        <%  if (_userProfile.IsManager())
            { %>
        <li>
            <a href="<%= Url.Action("AchievementIndex", "Accounting") %>"><i class="fa fa-fw fa-trophy"></i>業績統計表</a>
        </li>
        <%  } %>--%>
        <%  if (_userProfile.IsOfficer())
            { %>
        <li>
            <a href="<%= Url.Action("TrustIndex", "Accounting") %>"><i class="far fa-fw fa-file-excel"></i>信託請款表</a>
        </li>
        <%  } %>
        <li>
            <a href="<%= Url.Action("QuestionnaireIndex","Report") %>"><i class="fas fa-volume-up fa-spin"></i>階段性調整計畫報表</a>
        </li>
        <li>
            <a href="<%= Url.Action("BonusAwardList","Report") %>"><i class="fa fa-fw fa-gift"></i>Beyond幣累積兌換表</a>
        </li>
        <%--<li>
            <a href="<%= Url.Action("AverageFitness", "Activity") %>"><i class="fa fa-fw fa-heartbeat"></i>體能檢測表</a>
        </li>--%>
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
