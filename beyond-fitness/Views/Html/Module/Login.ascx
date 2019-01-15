<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<!-- ui-dialog -->
<%  if (!(_confirmedID == true && String.IsNullOrEmpty(_defaultPID)))
    { %>
<div id="loginDialog" title="登入" class="bg-color-darken">
    <%  if (_confirmedID == true)
        { %>
    <div id="photoInfo" class="info text-center">
        <%  Html.RenderPartial("~/Views/Html/Module/LoginPhoto.ascx"); %>
    </div>
    <%  } %>
    <div class="panel panel-default bg-color-darken">
        <%  ViewBag.FormAction = Url.Action("LoginByForm", "Html");
            Html.RenderPartial("~/Views/Account/Module/LoginForm.ascx"); %>
        <!-- dialog-message -->
    </div>
    <script>

        $('#loginDialog').dialog({
            autoOpen: true,
            resizable: true,
            modal: true,
            width: "100%",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-power-off'></i>  登入</h4>",
            close: function (event, ui) {
                $('#loginDialog').remove();
            }
        });

        $('#btnLogin').on('click', function (evt) {

            var form = $(this)[0].form;
            if (!validateForm(form))
                return false;

            checkLockPattern();

            showLoading();
            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                }
            });
        });

        $(function () {
            initLockScreen();
        });

    <%  if (_confirmedID == true)
        { %>
        $('#confirmedID').css('display', 'none');
    <%  } %>

    </script>
</div>
<%  } %>
<!-- ui-dialog -->

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    bool? _confirmedID;
    String _defaultPID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _confirmedID = (bool?)this.Model;
        HttpCookie cookie = Context.Request.Cookies["userID"];
        if (cookie != null)
        {
            _defaultPID = cookie.Value; // "**********";
        }
    }

</script>
