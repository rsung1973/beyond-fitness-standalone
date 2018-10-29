<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form action="<%= _formAction %>" id="pageForm" class="smart-form" method="post">

    <% Html.RenderPartial("~/Views/Account/RegisterItem.ascx", _model); %>

    <footer class="text-right">
        <button type="button" id="btnUpdateProfile" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
        <button type="button" id="btnCancelUpdateProfile" class="btn bg-color-blueLight">
            取消
        </button>
    </footer>
</form>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    RegisterViewModel _model;
    String _formAction;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (RegisterViewModel)this.Model;
        _formAction = ViewBag.FormAction ?? VirtualPathUtility.ToAbsolute("~/Account/EditMySelf");
    }

</script>
