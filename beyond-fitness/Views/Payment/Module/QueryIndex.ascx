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

<section id="widget-grid" class="">
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <span class="widget-icon"><i class="fa fa-search"></i></span>
                    <h2>查詢條件</h2>
                </header>
                <!-- widget div-->
                <div>
                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->
                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                        <form id="queryForm" action="<%= Url.Action("InquirePayment","Payment") %>" method="post" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-6 col-md-3">
                                        <label class="label">依收款人查詢</label>
                                        <label class="select">
                                            <select class="input" name="HandlerID">
                                                <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsAccounting() || _profile.IsServitor() || _profile.IsOfficer())
                                                    { %>
                                                <option value="">全部</option>
                                                <%  } %>
                                                <%  if (_profile.IsAssistant() || _profile.IsAccounting() || _profile.IsServitor() || _profile.IsOfficer())
                                                    {
                                                        Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", models.GetTable<ServingCoach>());
                                                    }
                                                    else if (_profile.IsManager() || _profile.IsViceManager())
                                                    {
                                                        Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", _profile.GetServingCoachInSameStore(models));
                                                    }
                                                    else
                                                    {
                                                        Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", models.GetTable<ServingCoach>().Where(c => c.CoachID == _profile.UID));
                                                    } %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-3">
                                        <label class="label">或依學員姓名(暱稱)查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" name="UserName" class="form-control input" maxlength="20" placeholder="請輸入學員姓名"/>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-3">
                                        <label class="label">或依合約編號查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-copy"></i>
                                            <input type="text" name="ContractNo" class="form-control input" maxlength="20" placeholder="請輸入合約編號">
                                        </label>
                                    </section>
                                <%  if (_profile.IsAssistant() || _profile.IsAccounting() || _profile.IsServitor() || _profile.IsOfficer())
                                    { %>
                                    <section class="col col-xs-12 col-sm-6 col-md-3">
                                        <label class="label">或依分店查詢</label>
                                        <label class="select">
                                            <select name="BranchID">
                                                <option value="">全部</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: -1);    %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                <%  }
                                    else
                                    {
                                        //ViewBag.DataItems = models.GetTable<CoachWorkplace>().Where(w => w.CoachID == _profile.UID)
                                            //.Select(w => w.BranchStore);
                                        //Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: -1);
                                    }   %>
                                </div>
                            </fieldset>
                            <fieldset>
                                <label class="label"><i class="fa fa-tags"></i>更多查詢條件</label>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">收款品項</label>
                                        <label class="select">
                                            <select class="input" name="TransactionType">
                                                <option value="">全部</option>
                                                <option value="1">體能顧問費</option>
                                                <option value="2">自主訓練</option>
                                                <option value="3">飲品</option>
                                                <option value="4">運動商品</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">狀態</label>
                                        <label class="select">
                                            <select class="input" name="Status">
                                                <option value="">全部</option>
                                                <option value="1201">退件（作廢）</option>
                                                <option value="1204">待審核（作廢）</option>
                                                <%--<option value="1205">已生效</option>--%>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-6 col-md-4">
                                        <label class="label">發票類型</label>
                                        <label class="select">
                                            <select class="input" name="InvoiceType">
                                                <option value="">全部</option>
                                                <option value="2">紙本</option>
                                                <option value="7">電子</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <%--<section class="col col-xs-12 col-sm-6 col-md-3">
                                        <label class="label">發票狀態</label>
                                        <label class="select">
                                            <select class="input" name="IsCancelled">
                                                <option value="">全部</option>
                                                <option value="<%= false %>">已開立</option>
                                                <option value="<%= true %>">已作廢</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>--%>
                                    <section class="col col-xs-12 col-sm-6 col-md-4">
                                        <label class="label">發票號碼</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-qrcode"></i>
                                            <input type="text" name="InvoiceNo" class="form-control input" maxlength="20" placeholder="請輸入發票號碼"/>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-4">
                                        <label class="label">買受人統編</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-copy"></i>
                                            <input type="text" name="BuyerReceiptNo" class="form-control input" maxlength="10" placeholder="請輸入買受人統編"/>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">請選擇查詢起日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <%  var dateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                                            <input type="text" name="PayoffDateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">請選擇查詢迄日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="PayoffDateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button onclick="inquirePayment();" type="button" name="submit" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                                <button type="reset" name="cancel" class="btn btn-default">
                                    清除 <i class="fa fa-undo" aria-hidden="true"></i>
                                </button>
                            </footer>
                        </form>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->
    </div>
    <!-- end row -->
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <h2>收款清單</h2>
                    <div class="widget-toolbar">
                        <a id="btnDownload" onclick="downloadPayment();" style="display:none;" class="btn btn-primary"><i class="fa fa-fw fa-cloud-download-alt"></i>下載檔案</a>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="paymentList">
                        <%  ViewBag.ViewModel = new PaymentQueryViewModel { };
                            Html.RenderPartial("~/Views/Payment/Module/PaymentInvoiceList.ascx", models.GetTable<Payment>().Where(p => false)); %>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->
    </div>
    <!-- end row -->
</section>
<script>
    function inquirePayment() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        $('#btnDownload').css('display', 'none');
        $form.ajaxSubmit({
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                $('#paymentList').empty()
                    .append($(data));
            }
        });
    }

    function downloadPayment() {
        $('#queryForm').launchDownload('<%= Url.Action("CreatePaymentInvoiceQueryXlsx","Payment") %>');
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
    }

</script>
