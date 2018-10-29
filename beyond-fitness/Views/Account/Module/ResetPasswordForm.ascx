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

    <fieldset>
        <section>
            <label class="input state-disabled">
                <i class="icon-append fa fa-envelope-o"></i>
                <input class="form-control input-lg" disabled="disabled" value="<%= _viewModel.PID %>" type="email" name="PID" id="PID">
            </label>
        </section>

    </fieldset>
    <fieldset>
        <% Html.RenderPartial("~/Views/Shared/SetPassword.ascx"); %>
    </fieldset>

    <footer class="text-right">
        <button type="submit" name="submit" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
    </footer>
</form>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PasswordViewModel _viewModel;
    String _formAction;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (PasswordViewModel)ViewBag.ViewModel;
        _formAction = ViewBag.FormAction ?? Url.Action("ResetPass", "Account", new { PID = _viewModel.PID });
    }

</script>
