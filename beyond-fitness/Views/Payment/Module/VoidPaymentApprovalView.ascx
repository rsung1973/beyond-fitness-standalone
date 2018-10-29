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
<div id="<%= _dialog %>" title="作廢收款" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form class="smart-form" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-12" id="queryResult">
                        <%  ViewBag.ShowHandler = false;
                            Html.RenderPartial("~/Views/Payment/Module/PaymentTodoList.ascx",_model); %>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <section>
                    <label class="label">備註</label>
                    <textarea class="form-control" name="Remark" placeholder="請輸入備註" rows="3"><%= _viewModel.Remark %></textarea>
                </section>
            </fieldset>
        </form>
    </div>
    <script>
        console.log('debug...');
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  作廢收款</h4></div>",
            buttons: [
        <%  if (_viewModel.Status == (int)Naming.CourseContractStatus.草稿)
            {   %>
                {
                    html: "<i class='fa fa-check' aria-hidden='true'></i>&nbsp; 確認審核",
                    "class": "btn btn-primary",
                    click: function () {
                        showLoading();
                        $.post('<%= Url.Action("ExecuteVoidPaymentStatus", "Payment", new { _viewModel.PaymentID, Status = (int)Naming.CourseContractStatus.待審核 }) %>', {}, function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('作廢收款待審核!!');
                                showLoading();
                                window.location.href = '<%= Url.Action("Index", "CoachFacet",new { showTodoTab = true }) %>';
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        });
                    }
                },
        <%  }
            else if (_viewModel.Status == (int)Naming.CourseContractStatus.待審核)
            {   %>
                {
                    html: "<i class='fa fa-times' aria-hidden='true'></i>&nbsp; 退件",
                    "class": "btn bg-color-red",
                    click: function () {
                        showLoading();
                        $.post('<%= Url.Action("ExecuteVoidPaymentStatus", "Payment", new { _viewModel.PaymentID, Status = (int)Naming.CourseContractStatus.草稿, Drawback = true }) %>', {}, function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('作廢收款已退件!!');
                                showLoading();
                                window.location.href = '<%= Url.Action("Index", "CoachFacet",new { showTodoTab = true }) %>';
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        });
                    }
                },
                {
                    html: "<i class='fa fa-check' aria-hidden='true'></i>&nbsp; 確認審核",
                    "class": "btn btn-primary",
                    click: function () {
                        showLoading();
                        $.post('<%= Url.Action("ExecuteVoidPaymentStatus", "Payment", new { _viewModel.PaymentID, Status = (int)Naming.CourseContractStatus.已生效 }) %>', {}, function (data) {
                            hideLoading();
                            if (data.result) {
                                alert('作廢收款審核完成!!');
                                showLoading();
                                if (data.invoiceID) {
                                    $('').launchDownload('<%= Url.Action("PrintIndex","Invoice") %>', { 'invoiceID': data.invoiceID,'docType':<%= (int)Naming.DocumentTypeDefinition.E_Allowance %> });
                                }
                                else {
                                    window.location.href = '<%= Url.Action("Index", "CoachFacet",new { showTodoTab = true }) %>';
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        });
                    }
                }
        <%  }   %>
            ],
            close: function () {
                $('#<%= _dialog %>').remove();
                showLoading();
                window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
            }
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "voidPayment" + DateTime.Now.Ticks;
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
