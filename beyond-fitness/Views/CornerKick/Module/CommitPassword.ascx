<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script>
    alert('密碼已更新!!');
    window.location.href = '<%= Url.Action("Settings","CornerKick",new { learnerSettings = true }) %>';
<%--<%  if (_viewModel.UUID == null)
    { %>
    window.location.href = '<%= Url.Action("Settings","CornerKick",new { learnerSettings = true }) %>';
    <%  }
    else
    {   %>
    window.location.href = '<%= Url.Action("Login","CornerKick") %>';
<%  }   %>--%>
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    RegisterViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (RegisterViewModel)ViewBag.ViewModel;
    }


</script>
