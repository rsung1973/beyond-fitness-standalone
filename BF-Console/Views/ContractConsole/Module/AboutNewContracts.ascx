<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  if (_model.IsAssistant() || _model.IsOfficer())
    {
        Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContractsByOfficer.ascx", _model);
    }
    else if (_model.IsManager() || _model.IsViceManager())
    {
        Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContractsByBranch.ascx", _model);
    }
    else
    {
        ViewBag.EnableToCreate = false;
        Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContractsByCoach.ascx", _model);
    }
    %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
