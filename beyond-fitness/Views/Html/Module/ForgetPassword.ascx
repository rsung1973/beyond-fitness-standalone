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
<div id="forgetPasswdDialog" title="忘記密碼" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <%  Html.RenderPartial("~/Views/Account/Module/ForgetPasswordForm.ascx"); %>
    </div>
    <!-- dialog-message -->
    <script>
        $('#forgetPasswdDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-key'></i>  忘記密碼</h4>",
            close: function (event, ui) {
                $('#forgetPasswdDialog').remove();
            }
        });
    </script>
</div>
<!-- ui-dialog -->

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
