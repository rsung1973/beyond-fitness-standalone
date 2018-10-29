<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form action="<%= VirtualPathUtility.ToAbsolute("~/Account/ForgetPassword") %>" id="pageForm" method="post" class="smart-form">

    <fieldset>
        <div class="row">
        </div>
        <section>
            <label class="input">
                <i class="icon-append fa fa-envelope-o"></i>
                <input type="email" maxlength="256" class="input-lg" name="email" id="email" placeholder="請輸入註冊時的E-mail" />
            </label>
        </section>
    </fieldset>

    <footer>
        <button type="button" id="btnSend" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
    </footer>

    <% Html.RenderPartial("~/Views/Shared/Success.ascx"); %>
</form>

<script>

    $('#btnSend').on('click', function (evt) {

        var form = $(this)[0].form;
        if (!validateForm(form))
            return false;

        showLoading();
        $($(this)[0].form).ajaxSubmit({
            success: function (data) {
                hideLoading();
                $('#successMsg').remove();
                $(form).append(data);
            }
        });
    });

<%--        $(function () {
            $('#email').rules('add', {
                'required': true,
                'email': true,
                messages: {
                    'required': '請輸入您的 email address',
                    'email': '請輸入合法的 email address'
                }
            });
        });--%>

</script>

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
