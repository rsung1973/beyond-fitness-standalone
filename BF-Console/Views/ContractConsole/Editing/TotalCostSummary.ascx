<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<p><b>專業顧問建置與諮詢費：</b> <%= $"{(_viewModel.TotalCost*8+5)/10:##,###,###}" %></p>
<p>教練課程費：<%= $"{(_viewModel.TotalCost*2+5)/10:##,###,###}" %></p>
<h3 class="text-right col-blush">專業顧問服務總費用：<%= String.Format("{0:##,###,###,###}",_viewModel.TotalCost) %></h3>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
    }


</script>
