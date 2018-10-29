<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<div id="updateProfileDialog" title="修改個人資料" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <%  ViewBag.FormAction = Url.Action("CommitMySelf", "Html",new { UID = _viewModel.UID });
            Html.RenderPartial("~/Views/Account/Module/EditMySelfForm.ascx", _viewModel); %>
    </div>
    <script>

        $('#updateProfileDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-cogs'></i>  修改個人資料</h4>",
            close: function (event, ui) {
                $('#updateProfileDialog').remove();
            }
        });

        $(function () {
            initLockScreen();
        });

        $('#btnUpdateProfile').on('click', function (evt) {

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

        $('#btnCancelUpdateProfile').on('click', function (evt) {
            $('#updateProfileDialog').dialog('close');
        });

    </script>
</div>
<!-- ui-dialog -->

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
