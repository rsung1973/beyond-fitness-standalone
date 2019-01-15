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

<div id="<%= _dialog %>" title="待辦事項：收款項目(待勾記)" class="bg-color-darken">
    <!-- content -->
    <%  ViewBag.ViewAction = "勾記";
        Html.RenderPartial("~/Views/Payment/Module/PaymentTodoList.ascx", _model); %>
    <!-- end content -->
    <script>

        $(function () {
            $global.done = false;
        });

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-list-ol'></i>  待辦事項：收款項目-<%= ((Naming.PaymentTransactionType)_viewModel.TransactionType).ToString() %>(待勾記)</h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
                if ($global.done) {
                    showLoading();
                    window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
                }
            }
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "auditPayment" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;
    PaymentViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<Payment>)this.Model;
        _viewModel = (PaymentViewModel)ViewBag.ViewModel;

    }

</script>
