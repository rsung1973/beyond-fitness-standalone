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

<div class="col-xs-6 col-sm-5">
    <h1>
        <span class="semi-bold"><%= _model.FullName() %></span>
    </h1>
    <p class="font-md">關於<%= _model.UserName ?? _model.FullName() %>...</p>
    <p>
        <%= _model.RecentStatus.HtmlBreakLine() %>
    </p>
</div>
<div class="col-xs-12 col-sm-3">
    <%  Html.RenderPartial("~/Views/Member/ContactInfo.ascx", _model); %>
    <%  Html.RenderPartial("~/Views/Member/UserAssessmentInfo.ascx", _model); %>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
    }

</script>
