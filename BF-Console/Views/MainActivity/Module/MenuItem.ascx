﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="BFConsole.Views.MainActivity.Resources" %>

<li><a href="<%= Url.Action("AboutUs") %>"><%: NamingItem.AboutUs %></a></li>
<li><a href="<%= Url.Action("FindUs") %>"><%: NamingItem.FindUs %></a></li>
<li><a href="<%= Url.Action("FAQ") %>"><%: NamingItem.FAQ %></a></li>
<li><a href="<%= Url.Action("Blog") %>"><%: NamingItem.Blog %></a></li>
<li><a href="<%= Url.Action("JoinUs") %>"><%: NamingItem.JoinUs %></a></li>
<li class="pull-right">
    <%  if (ViewBag.Lang == null || ViewBag.Lang == "zh-TW")
        {   %>
    <a href="javascript:changeLanguage('en-US');" class="btn-link2">EN <i class="zmdi zmdi-globe-alt"></i></a>
    <%  }
        else
        {   %>
    <a href="javascript:changeLanguage('zh-TW');" class="btn-link2">繁 <i class="zmdi zmdi-globe-alt"></i></a>
    <%  } %>
    <a href="<%= Url.Action("BookNow") %>" class="btn btn-default btn-round"><%: NamingItem.BookNow %></a>
</li>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }


</script>