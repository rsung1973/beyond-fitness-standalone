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
        <form action="<%= Url.Action("CommitToVoidPayment","Payment") %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-8">
                        <label class="label">發票號碼</label>
                        <label class="input">
                            <i class="icon-append far fa-copy"></i>
                            <input type="text" name="InvoiceNo" maxlength="20" placeholder="請輸入發票號碼" />
                        </label>
                    </section>
                    <section class="col col-2">
                        <label class="label">&nbsp;</label>
                        <button onclick="inquirePayment();" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                    </section>
                    <script>
                        function inquirePayment() {
                            var $form = $('#<%= _dialog %> form');
                            clearErrors();
                            showLoading();
                            $.post('<%= Url.Action("ListPaymentByInvoice","Payment") %>', $form.serializeObject(), function (data) {
                                hideLoading();
                                $('#queryResult').html(data);
                            });
                        }
                    </script>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-12" id="queryResult">
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <section>
                    <label class="label">備註</label>
                    <textarea class="form-control" name="Remark" placeholder="請輸入備註" rows="3"></textarea>
                </section>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  作廢收款</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    if ($form.find('input[name="VoidID"]').length == 0) {
                        alert('請查詢可作廢的發票收款資料');
                    }
                    else if (confirm("請再次確認作廢資料正確")) {
                        $form.ajaxSubmit({
                            beforeSubmit: function () {
                                showLoading();
                            },
                            success: function (data) {
                                hideLoading();
                                if ($.isPlainObject(data)) {
                                    if (data.result) {
                                        alert(data.message);
                                        <%--$('#<%= _dialog %>').dialog('close');--%>
                                        showLoading();
                                        if (data.invoiceID) {
                                            $('').launchDownload('<%= Url.Action("PrintIndex","Invoice") %>', { 'invoiceID': data.invoiceID,'docType':<%= (int)Naming.DocumentTypeDefinition.E_Allowance %> });
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
                            }
                        });
                    }
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "voidPayment" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
