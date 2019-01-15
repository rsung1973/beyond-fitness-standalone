<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Register Src="~/Views/Shared/LockScreen.ascx" TagPrefix="uc1" TagName="LockScreen" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<ul id="myTab1" class="nav nav-tabs bordered">
    <li class="active">
        <a href="#pw1" data-toggle="tab"><i class="fa fa-picture-o  fa-lg fa-gear"></i>圖形密碼</a>
    </li>
    <li>
        <a href="#pw2" data-toggle="tab"><i class="fa fa-keyboard-o  fa-lg fa-gear"></i>文字密碼</a>
    </li>
</ul>
<div id="setPwdTabContent" class="tab-content padding-10">
    <div class="tab-pane fade in active" id="pw1">
        <uc1:LockScreen runat="server" ID="lockScreen" />
        <label id="lockPattern-error" class="error" for="lockPattern" style="display: none;"></label>
    </div>
    <input type="text" name="lockPattern" id="lockPattern" style="display: none" />
    <div class="tab-pane fade" id="pw2">
        <fieldset>
            <section>
                <label class="input">
                    <i class="icon-append fa fa-lock "></i>
                    <input class="form-control input-lg" maxlength="10" placeholder="請輸入密碼" type="password" name="Password" id="password" />
                </label>
            </section>
        </fieldset>
        <fieldset>
            <section>
                <label class="input">
                    <i class="icon-append fa fa-lock "></i>
                    <input class="form-control input-lg" maxlength="10" placeholder="請再次密碼" type="password" name="Password2" id="password2" />
                </label>
            </section>
        </fieldset>
    </div>
</div>

<script>

    function setLockPattern() {
        if ($('#pw1').css('display') == 'block') {
            var userPath = $appLock.getUserPath();
            if (userPath == null) {
                $('#lockPattern-error').css('display', 'block');
                $('#lockPattern-error').text('請您設定圖形密碼!!');
                return false;
            } else if (userPath.length < 9) {
                $('#lockPattern-error').css('display', 'block');
                $('#lockPattern-error').text('您設定圖形的密碼過短!!');
                return false;
            } else {
                $('#lockPattern').val(userPath);
            }
        }
        return true;
    }

    $(function () {

        if (typeof ($pageFormValidator) !== 'undefined') {
            $pageFormValidator.settings.submitHandler = function (form) {

                return setLockPattern();
                //$(form).submit();
                //return true;
            };

            $.validator.addMethod("confirmPassword", function (value, element, pwd) {
                return $(element).val() == pwd.val();
            }, "密碼確認錯誤!!");

            $('#password').rules('add', {
                'required': {
                    param: true,
                    depends: function (elment) {
                        return $('input[name="lockPattern"]').val() == '';
                    }
                },
                'maxlength': 20,
                'messages': {
                    required: '請輸入您的文字密碼'
                }
            });

            $('#password2').rules('add', {
                'required': false,
                'confirmPassword': $('#password')
            });
        }

    });
</script>
<script runat="server">

    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }


</script>
