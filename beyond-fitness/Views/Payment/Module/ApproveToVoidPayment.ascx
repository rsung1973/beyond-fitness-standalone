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

<div id="<%= _dialog %>" title="待辦事項：作廢收款(<%= ViewBag.ViewAction %>)" class="bg-color-darken">
    <!-- content -->
    <%  Html.RenderPartial("~/Views/Payment/Module/PaymentTodoList.ascx", _model); %>
    <!-- end content -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-list-ol'></i>  待辦事項：作廢收款項目-<%= ((Naming.PaymentTransactionType)_viewModel.TransactionType).ToString() %>(<%= ViewBag.ViewAction %>)</h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function () {

            $global.approveToVoid = function (paymentID) {
                showLoading();
                $.post('<%= Url.Action("ApproveToVoidPaymentView","Payment") %>', { 'paymentID': paymentID }, function (data) {
                    hideLoading();
                    $('#<%= _dialog %>').dialog("close");
                    $(data).appendTo($('body'));
                });
            };

            $global.editToVoid = function (paymentID) {
                showLoading();
                $.post('<%= Url.Action("EditToVoidPaymentView","Payment") %>', { 'paymentID': paymentID }, function (data) {
                    hideLoading();
                    $('#<%= _dialog %>').dialog("close");
                    $(data).appendTo($('body'));
                });
            };
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
