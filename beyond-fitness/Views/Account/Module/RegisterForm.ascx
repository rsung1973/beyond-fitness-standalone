<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form action="<%= _formAction %>" id="regester-form" class="smart-form" method="post">
    <%=  Html.AntiForgeryToken() %>
    <fieldset>
        <section>
            <label class="input">
                <i class="icon-append fa fa-tag"></i>
                <input type="text" name="MemberCode" id="MemberCode" class="input-lg" maxlength="20" placeholder="請輸入會員編號" value="<%: this.Model %>" />
            </label>
        </section>
    </fieldset>
    <footer>
        <button type="button" id="btnSend" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
    </footer>
</form>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _formAction;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _formAction = ViewBag.FormAction ?? VirtualPathUtility.ToAbsolute("~/Account/RegisterByMail");
    }

</script>
