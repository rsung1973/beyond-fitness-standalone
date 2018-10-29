<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div id="<%= _dialog %>" title="未上傳發票清單" class="bg-color-darken">
    <!-- content -->
    <%  Html.RenderPartial("~/Views/Invoice/Module/SimpleInvoiceItemList.ascx"); %>
    <!-- end content -->
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "600",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-list-ol'></i> 未上傳發票清單</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "invoiceItems" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
