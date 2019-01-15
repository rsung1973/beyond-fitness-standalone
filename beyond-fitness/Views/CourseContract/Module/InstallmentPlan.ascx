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

<%  if (_viewModel.Lessons.HasValue)
    {   %>
<option value="">-- 請選擇分期轉開次數 --</option>
<option value="2" <%= _viewModel.Installments==2 ? "selected" : null %>>2次</option>
<option value="3" <%= _viewModel.Installments==3 ? "selected" : null %>>3次</option>
<%
        if (_profile.IsAuthorized(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager }))
        {   %>
<option value="4" <%= _viewModel.Installments==4 ? "selected" : null %>>4次</option>
<option value="5" <%= _viewModel.Installments==5 ? "selected" : null %>>5次</option>
<option value="6" <%= _viewModel.Installments==6 ? "selected" : null %>>6次</option>
<%      }
        else
        {
            if (_viewModel.Lessons >= 25)
            {   %>
<option value="4" <%= _viewModel.Installments==4 ? "selected" : null %>>4次</option>
<%
            }
            if (_viewModel.Lessons >= 75)
            {   %>
<option value="5" <%= _viewModel.Installments==5 ? "selected" : null %>>5次</option>
<%
            }
        }   %>
<%  }   %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractQueryViewModel _viewModel;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }

</script>
