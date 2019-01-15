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
<div id="regesterDialog" title="會員註冊" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <%  ViewBag.FormAction = Url.Action("RegisterByMail", "Html");
            Html.RenderPartial("~/Views/Account/Module/RegisterForm.ascx"); %>
    </div>
    <script>
        $('#regesterDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-user-circle'></i>  會員註冊</h4>",
            close: function (event, ui) {
                $('#regesterDialog').remove();
            }
        });

        $('#btnSend').on('click', function (evt) {

            var form = $(this)[0].form;
            if (!validateForm(form))
                return false;

            showLoading();
            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                }
            });
        });
    </script>
</div>

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
