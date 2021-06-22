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

<div id="<%= _dialog %>" title="編輯收款" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitPaymentForEnterprise","Payment",new { _viewModel.PaymentID,_viewModel.ContractID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">收款日期</label>
                        <label class="input">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" name="PayoffDate" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.PayoffDate) %>' />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">發票類型</label>
                        <div class="inline-group">
                            <label class="radio">
                                <input type="radio" name="InvoiceType" value="<%= (int)Naming.InvoiceTypeDefinition.二聯式 %>" <%= _viewModel.InvoiceType!=Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 ? "checked" : null %> />
                                <i></i>紙本</label>
                            <%--<label class="radio">
                                <input type="radio" disabled="disabled" name="InvoiceType" value="<%= (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 %>" <%= _viewModel.InvoiceType==Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 ? "checked" : null %> />
                                <i></i>電子</label>--%>
                        </div>
                    </section>
                </div>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">開立分店</label>
                        <label class="select">
                            <select name="SellerID">
                                <%  var w = models.GetTable<CoachWorkplace>().Where(c => c.CoachID == _profile.UID).FirstOrDefault();
                                    Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: w != null ? w.BranchID : -1); %>
                            </select>
                            <i class="icon-append fa fa-at"></i>
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">收款方式</label>
                        <label class="select">
                            <select name="PaymentType">
                                <option value="現金">現金</option>
                                <option value="刷卡">刷卡</option>
                                <option value="轉帳">轉帳</option>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                        <script>
                            $('#<%= _dialog %> select[name="PaymentType"]').val('<%= _viewModel.PaymentType %>');
                        </script>
                    </section>
                    <section class="col col-4">
                        <label class="label">收款金額</label>
                        <label class="input">
                            <i class="icon-append fa fa-dollar-sign"></i>
                            <input type="number" name="PayoffAmount" maxlength="10" placeholder="請輸入收款金額" value="<%= _viewModel.PayoffAmount %>" />
                        </label>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">買受人統編</label>
                        <label class="input">
                            <i class="icon-append fa fa-user"></i>
                            <input type="number" name="BuyerReceiptNo" maxlength="10" placeholder="請輸入買受人統編" value="<%= _viewModel.BuyerReceiptNo %>" />
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">發票號碼</label>
                        <label class="input">
                            <i class="icon-append fa fa-qrcode"></i>
                            <input type="text" name="InvoiceNo" maxlength="20" placeholder="請輸入發票號碼" value="<%= _viewModel.InvoiceNo %>" />
                        </label>
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
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "100%",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  編輯收款</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    if (confirm("請再次確認收款資料正確?")) {
                        clearErrors();
                        var $form = $('#<%= _dialog %> form');
                        $form.ajaxSubmit({
                            beforeSubmit: function () {
                                showLoading();
                            },
                            success: function (data) {
                                hideLoading();
                                if ($.isPlainObject(data)) {
                                    if (data.result) {
                                        alert('收款資料已生效!!');
                                        listEnterprisePayment();
                                        $('#<%= _dialog %>').dialog('close');
                                    } else {
                                        alert(data.message);
                                    }
                                } else {
                                    $(data).appendTo($('body')).remove();
                                }
                            }
                        });
                    }
                }
            }
            <%--, {
                html: "<i class='fa fa-qrcode'></i>&nbsp; 確定產生發票",
                "class": "btn btn-primary",
                click: function () {
                    if (confirm("請再次確認收款資料正確")) {
                        $(this).dialog("close");
                        window.location.href = "invoicelist.html";
                    }
                }
            }--%>],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            startDate: '<%= String.Format("{0:yyyy-MM-01}",DateTime.Today) %>',
            endDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>',
            forceParse: 0
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "payment" + DateTime.Now.Ticks;
    PaymentViewModel _viewModel;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (PaymentViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }

</script>
