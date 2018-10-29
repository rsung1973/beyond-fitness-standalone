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

<div id="<%= _dialog %>" title="企業合作方案收款清單" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <!-- widget options:
                  usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                  data-widget-colorbutton="false"
                  data-widget-editbutton="false"
                  data-widget-togglebutton="false"
                  data-widget-deletebutton="false"
                  data-widget-fullscreenbutton="false"
                  data-widget-custombutton="false"
                  data-widget-collapsed="true"
                  data-widget-sortable="false"

                  -->
        <header>
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>企業合作方案收款清單</h2>
            <div class="widget-toolbar">
                <a onclick="editPayment();" class="btn btn-primary" id="modifyPaymentDialog_link"><i class="fa fa-fw fa-plus"></i>新增收款</a>
            </div>
        </header>
        <!-- widget div-->
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding itemList">
                <%  Html.RenderPartial("~/Views/EnterpriseProgram/Module/PaymentItemList.ascx", _model); %>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: true,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-dollar-sign'></i> 企業合作方案收款清單</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        function listEnterprisePayment() {
            showLoading();
            var $itemList = $('#<%= _dialog %> .itemList');
            $itemList.empty();
            $itemList.load('<%= Url.Action("EnterprisePaymentList","EnterpriseProgram",new { _model.ContractID, itemsOnly = true }) %>', { }, function (data) {
                hideLoading();
            });
        }

        function editPayment() {
            showLoading();
            $.post('<%= Url.Action("EditPaymentForEnterprise","Payment",new { _model.ContractID }) %>', {}, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function deletePayment(id) {
            var event = event || window.event;

            if (confirm("確定刪除此企業收款記錄?")) {
                showLoading();
                $.post('<%= Url.Action("DeleteEnterprisePayment","Payment",new { _model.ContractID }) %>', { 'paymentID': id }, function (data) {
                    hideLoading();
                    if ($.isPlainObject(data)) {
                        if (data.result) {
                            $(event.target).closest('tr').remove();
                            alert('收款資料已刪除!!');
                        } else {
                            alert(data.message);
                        }
                    } else {
                        $(data).appendTo($('body')).remove();
                    }
                });
            }
        }

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "enterprisePayment" + DateTime.Now.Ticks;
    EnterpriseCourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (EnterpriseCourseContract)this.Model;
    }

</script>
