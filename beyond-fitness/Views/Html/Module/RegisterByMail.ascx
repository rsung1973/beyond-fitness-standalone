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
<div id="registerByMailDialog" title="會員註冊" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <%  ViewBag.FormAction = Url.Action("CompleteRegister", "Html",new { MemberCode = _viewModel.MemberCode });
            Html.RenderPartial("~/Views/Account/Module/RegisterByMailForm.ascx"); %>
    </div>
    <script>

        $('#regesterDialog').dialog('close');

        $('#registerByMailDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "100%",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-user-circle'></i>  會員註冊</h4>",
            close: function (event, ui) {
                $('#registerByMailDialog').remove();
            }
        });

        $('#btnSend').on('click', function (evt) {

            var form = $(this)[0].form;
            if (!validateForm(form))
                return false;

            setLockPattern();

            showLoading();
            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    console.log(data);
                    $(data).appendTo($('body'));
                }
            });
        });

        $(function () {
            initLockScreen();
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    RegisterViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (RegisterViewModel)ViewBag.ViewModel;

    }

</script>
