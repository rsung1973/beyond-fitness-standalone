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
        <form action="<%= Url.Action("CommitPaymentForPISession","Payment",new { _viewModel.PaymentID }) %>" class="smart-form" method="post" autofocus>
            <input type="hidden" name="errorMsg" />
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">收款類別</label>
                        <label class="select">
                            <select name="TransactionType">
                                <option value="1">體能顧問費</option>
                                <option value="2" selected>自主訓練</option>
                                <option value="3">飲品</option>
                                <option value="4">運動商品</option>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                        <script>
                            $('#<%= _dialog %> select[name="TransactionType"]').on('change', function (evt) {
                                showLoading();
                                $.post('<%= Url.Action("EditPayment","Payment") %>', { 'TransactionType': $(this).val() }, function (data) {
                                hideLoading();
                                $('#<%= _dialog %>').dialog('close');
                                $(data).appendTo($('body'));
                            });
                        });
                        </script>
                    </section>
                    <section class="col col-6">
                        <label class="label">分店</label>
                        <label class="select">
                            <select name="SellerID">
                                <%  BranchStore branch = null;
                                    if(_profile.IsManager() || _profile.IsViceManager())
                                    {
                                        branch = models.GetTable<BranchStore>().Where(b => b.ManagerID == _profile.UID || b.ViceManagerID == _profile.UID).FirstOrDefault();
                                    }
                                    else if(_profile.IsCoach())
                                    {
                                        ViewBag.DataItems = models.GetTable<CoachWorkplace>().Where(c => c.CoachID == _profile.UID)
                                                                .Select(w => w.BranchStore);
                                        branch = models.GetTable<CoachWorkplace>().Where(w => w.CoachID == _profile.UID).Select(w => w.BranchStore).FirstOrDefault();
                                    }
                                    Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: branch != null ? branch.BranchID : -1); %>
                            </select>
                            <i class="icon-append fa fa-at"></i>
                            <script>
                                console.log('debug...');
                                $('#<%= _dialog %> select[name="SellerID"]').on('change', function (evt) {
                                    showLoading();
                                    $('#PISessionList').load('<%= Url.Action("ListUnpaidPISession", "Payment") %>', { 'branchID': $(this).val() }, function (data) {
                                        hideLoading();
                                    });
                                });
                            </script>
                        </label>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-12" id="PISessionList">
                        <%  Html.RenderAction("ListUnpaidPISession", "Payment", new { branchID =  branch!=null ? branch.BranchID : 1 }); %>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-7">
                        <label class="label">收款方式</label>
                        <!--<label class="select">
                            <select name="PaymentType">
                                <option value="現金">現金</option>
                                <option value="刷卡">刷卡</option>
                                <option value="轉帳">轉帳</option>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>-->
                        <div class="inline-group">
                            <label class="radio">
                                <input type="radio" name="PaymentType" value="現金" />
                                <i></i>現金</label>
                            <label class="radio">
                                <input type="radio" name="PaymentType" value="刷卡"/>
                                <i></i>刷卡</label>
                            <label class="radio">
                                <input type="radio" name="PaymentType" value="轉帳"/>
                                <i></i>轉帳</label>
                        </div>
                        <%--<script>
                            $('#<%= _dialog %> input:radio[name="PaymentType"][value="<%= _viewModel.PaymentType %>"]').prop('checked',true);
                        </script>--%>
                    </section>
                    <section class="col col-5">
                        <label class="label">發票類型</label>
                        <div class="inline-group">
                            <%  if (_profile.IsAssistant() || _profile.IsSysAdmin())
                                {   %>
                            <label class="radio">
                                <input type="radio" name="InvoiceType" value="<%= (int)Naming.InvoiceTypeDefinition.二聯式 %>" <%= _viewModel.InvoiceType != Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 ? "checked" : null %> />
                                <i></i>紙本</label>
                            <%  }
                                else
                                {
                                    _viewModel.InvoiceType = Naming.InvoiceTypeDefinition.一般稅額計算之電子發票;
                                } %>
                            <label class="radio">
                                <input type="radio" name="InvoiceType" value="<%= (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 %>" <%= _viewModel.InvoiceType==Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 ? "checked" : null %> />
                                <i></i>電子</label>
                        </div>
                    </section>
                    <script>
                        function initial() {
                            if ($('#<%= _dialog %> input[name="InvoiceType"][value="<%= (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 %>"]').is(':checked')) {
                                $('.eInvoice-dialog').css('display', 'block');
                                $('.paper-invoice').css('display', 'none');
                                $('.eInvoice-disable').prop('disabled', true);
                                $('#<%= _dialog %> input[name="PayoffDate"]').val('<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>');
                            } else {
                                $('.eInvoice-dialog').css('display', 'none');
                                $('.paper-invoice').css('display', 'block');
                                $('.eInvoice-disable').prop('disabled', false);
                            }
                        }

                        $('#<%= _dialog %> input[name="InvoiceType"]').on('click', function (evt) {
                            initial();
                        });

                        <%  if(!(_profile.IsAssistant() || _profile.IsManager()))
                            {   %>
                        $('#<%= _dialog %> input[name="PayoffDate"]').prop('disabled', true);
                        <%  }
                            else
                            {   %>
                        $('#<%= _dialog %> input[name="PayoffDate"]').addClass('eInvoice-disable');
                        <%  }   %>
                    </script>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">收款日期</label>
                        <label class="input">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" name="PayoffDate" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.PayoffDate) %>' />
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">收款金額</label>
                        <label class="input">
                            <i class="icon-append fa fa-dollar-sign"></i>
                            <input type="number" name="PayoffAmount" maxlength="10" placeholder="請輸入收款金額" value="300" />
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
                    <section class="col col-6 paper-invoice">
                        <label class="label">發票號碼</label>
                        <label class="input">
                            <i class="icon-append fa fa-qrcode"></i>
                            <input type="text" name="InvoiceNo" maxlength="20" placeholder="請輸入發票號碼" value="<%= _viewModel.InvoiceNo %>" />
                        </label>
                    </section>
                </div>
             </fieldset>
            <fieldset>
                <div class="row eInvoice-dialog">
                    <section class="col col-4">
                        <label class="label">載具類型</label>
                        <label class="select">
                            <i class="icon-append fa fa-user"></i>
                            <select name="CarrierType">
                                <option value="">不使用</option>
                                <option value="3J0002">手機條碼</option>
                                <option value="CQ0001">自然人憑證條碼</option>
                            </select>
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">載具號碼</label>
                        <label class="input">
                            <i class="icon-append fa fa-barcode"></i>
                            <input type="text" name="CarrierId1" maxlength="20" placeholder="請輸入載具號碼" value="<%= _viewModel.CarrierId1 %>" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">發票捐贈愛心碼</label>
                        <label class="input">
                            <i class="icon-append fa fa-heart"></i>
                            <input type="text" name="NPOBAN" maxlength="10" placeholder="請輸入發票捐贈愛心碼" value="<%= _viewModel.NPOBAN %>" />
                        </label>
                    </section>
                </div>
                <input type="hidden" name="errorMessage" />
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

        function commitPayoff(invoiceNow) {

            if (confirm("請再次確認收款資料正確?")) {
                clearErrors();
                var $form = $('#<%= _dialog %> form');
                var formData = $form.serializeObject();
                formData.InvoiceNow = invoiceNow;

                showLoading();
                $.post('<%= Url.Action("CommitPaymentForPISession","Payment",new { _viewModel.PaymentID }) %>', formData, function (data) {
                    hideLoading();
                    if ($.isPlainObject(data)) {
                        if (data.result) {
                            if (invoiceNow) {
                                window.open('<%= Url.Action("GetInvoicePDF","Invoice") %>' + '?InvoiceID=' + data.InvoiceID);
                            }
                            alert('收款資料已生效!!');
                            <%--$('#<%= _dialog %>').dialog('close');--%>
                            showLoading();
                            if (data.InvoiceType == 7) {
                                $('').launchDownload('<%= Url.Action("PrintIndex","Invoice") %>', { 'invoiceNo': data.invoiceNo });
                            }
                            else {
                                window.location.href = '<%= Url.Action("PaymentIndex","Payment") %>';
                            }
                        } else {
                            alert(data.message);
                        }
                    } else {
                        $(data).appendTo($('body')).remove();
                    }
                });
            }

        }

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  編輯收款</h4></div>",
            buttons: [<%--{
                html: "<i class='fa fa-qrcode'></i>&nbsp; 確定產生發票",
                "class": "btn btn-primary eInvoice-dialog",
                click: function () {
                    commitPayoff(true);
                }
            },--%> {
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    commitPayoff(false);
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
            open: function (event, ui) {
                initial();
            },
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
