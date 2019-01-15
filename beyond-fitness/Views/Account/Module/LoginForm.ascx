<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/LockScreen.ascx" TagPrefix="uc1" TagName="LockScreen" %>

<form action="<%= _formAction %>" id="login-form" class="smart-form" method="post">
    <%= Html!=null ? Html.AntiForgeryToken() : null %>
    <fieldset id="confirmedID">
        <section>
            <label class="input">
                <i class="icon-append fa fa-envelope-o "></i>
                <input class="form-control input-lg" maxlength="256" placeholder="請輸入註冊時的E-mail" type="email" name="PID" id="PID" value="<%= _defaultPID %>" />
                <input type="hidden" name="returnUrl" value="<%= Request["returnUrl"] %>" />
            </label>
        </section>
        <section style="display:none;">
            <label class="checkbox">
                <input type="checkbox" name="RememberMe" id="RememberMe" value="true" <%= String.IsNullOrEmpty(_defaultPID) ? "checked" : "checked" %> />
                <i></i>Remember Me</label>
        </section>
    </fieldset>
    <fieldset>
        <ul id="myTab1" class="nav nav-tabs bordered">
            <li class="active">
                <a href="#pw1" data-toggle="tab"><i class="fa fa-picture-o  fa-lg fa-gear"></i>圖形密碼</a>
            </li>
            <li>
                <a href="#pw2" data-toggle="tab"><i class="fa fa-keyboard-o  fa-lg fa-gear"></i>文字密碼</a>
            </li>
        </ul>
        <div id="myTabContent1" class="tab-content padding-10">

            <div class="tab-pane fade in active" id="pw1">
                <uc1:lockscreen runat="server" id="lockScreen" />
                <label id="lockPattern-error" class="error" for="lockPattern" style="display: none;"></label>
            </div>

            <div class="tab-pane fade" id="pw2">
                <fieldset>
                    <section>
                        <label class="input">
                            <i class="icon-append fa fa-lock "></i>
                            <input class="form-control input-lg" maxlength="10" placeholder="請輸入註冊時的密碼" type="password" name="password" id="password" />
                        </label>
                    </section>
                </fieldset>
            </div>
        </div>
    </fieldset>

    <footer class="text-right">
        <button type="button" id="btnLogin" name="btnLogin" class="btn btn-primary" autofocus>
            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
        </button>
    </footer>
</form>

<script>

    function checkLockPattern() {
        if ($('#pw1').css('display') == 'block') {
            var userPath = $appLock.getUserPath();
            if (userPath == null) {
                $('#lockPattern-error').css('display', 'block');
                $('#lockPattern-error').text('請輸入圖形密碼!!');
                return false;
            } else {
                $('#password').val(userPath);
            }
        }
        return true;
    }

        $(function () {

            var $commentForm = $("#login-form").validate({
                // Rules for form validation
                rules: {
                    PID: {
                        required: true,
                        email: true
                    },
                    password: {
                        required: true,
                        'maxlength': 20
                    }
                },

                // Messages for form validation
                messages: {
                    PID: {
                        required: '請輸入您的 email address',
                        email: '請輸入合法的 email address'
                    },
                    password: {
                        required: '請輸入您的文字密碼',
                    }
                },

                // Ajax form submition
                submitHandler: function (form) {

                    if (checkLockPattern()) {

                        //$(form).submit();

                        showLoading(false, function () {
                            //$(form).ajaxSubmit({
                            //    success: function () {
                            //        //$("#login-form").addClass('submited');
                            //    }
                            //});
                        });

                        return true;
                    }

                    return false;

                },

                // Do not change code below
                errorPlacement: function (error, element) {
                    error.insertAfter(element.parent());
                }
            });

        });

</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
        String _defaultPID;
    String _formAction;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _formAction = ViewBag.FormAction ?? FormsAuthentication.LoginUrl;

        HttpCookie cookie = Context.Request.Cookies["userID"];
        if (cookie != null)
        {
            _defaultPID = cookie.Value; // "**********";
        }

    }

</script>
