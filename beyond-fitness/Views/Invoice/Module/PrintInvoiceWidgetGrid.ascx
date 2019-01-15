<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

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
                        <form action="<%= Url.Action("InquireInvoice","Invoice") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                        <label class="label">依收款人查詢</label>
                                        <label class="select">
                                            <select class="input" name="HandlerID">
                                                <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsAccounting())
                                                    { %>
                                                <option value="">全部</option>
                                                <%  } %>
                                                <%  if (_profile.IsAssistant() || _profile.IsAccounting())
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
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                        <label class="label">或依發票號碼查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-qrcode"></i>
                                            <input type="text" name="InvoiceNo" class="form-control input" maxlength="20" placeholder="請輸入發票號碼"/>
                                        </label>
                                    </section>
                                    <%  if (_profile.IsAssistant() || _profile.IsAccounting())
                                    { %>
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
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
                                    <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇發票／折讓(作廢)起日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <%  var dateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                                            <input type="text" name="DateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇發票／折讓(作廢)迄日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="DateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇發票是否已列印</label>
                                        <label class="select">
                                            <select class="input" name="IsPrinted">
                                                <option value="">全部</option>
                                                <option value="<%= false %>">否</option>
                                                <option value="<%= true %>">是</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇證明聯種類</label>
                                        <label class="select">
                                            <select class="input" name="DocType">
                                                <option value="<%= (int)Naming.DocumentTypeDefinition.E_Invoice %>">電子發票</option>
                                                <option value="<%= (int)Naming.DocumentTypeDefinition.E_Allowance %>">折讓證明單</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <label class="label"><i class="fa fa-tags"></i>印表機選項</label>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">分店</label>
                                        <label class="select">
                                            <select name="CompanyID">
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _profile.ServingCoach!=null && _profile.ServingCoach.CoachWorkplace.Count>0 ? _profile.ServingCoach.CoachWorkplace.First().BranchID : -1); %>
                                            </select>
                                            <i class="icon-append fa fa-at"></i>
                                        </label>
                                        <script>
                                            function getPrinterIP() {
                                                $.post('<%= Url.Action("GetPrinterIP","Invoice") %>', { 'companyID': $('select[name="CompanyID"]').val() }, function (data) {
                                                    $('input[name="PrinterIP"]').val(data.printerIP);
                                                });
                                            }
                                            $('select[name="CompanyID"]').on('change', function (evt) {
                                                getPrinterIP();
                                            });
                                            $(function () {
                                                getPrinterIP();
                                            });
                                        </script>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">印表機IP</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-wifi"></i>
                                            <input type="text" name="PrinterIP" class="form-control input" maxlength="20" placeholder="請輸入印表機IP"/>
                                        </label>
                                        <script>
                                            function updatePrinterIP() {
                                                $.post('<%= Url.Action("UpdatePrinterIP","Invoice") %>', { 'companyID': $('select[name="CompanyID"]').val(), 'printerIP': $('input[name="PrinterIP"]').val() }, function (data) {
                                                    if (data.result) {
                                                        alert('印表機IP已設定!!');
                                                    }
                                                });
                                            }
                                            $('input[name="PrinterIP"]').on('change', function (evt) {
                                                updatePrinterIP();
                                            });
                                        </script>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button onclick="inquireInvoice();" type="button" name="btnSend" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                                <button type="reset" name="btnCancel" class="btn btn-default">
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
    <div class="row">
        <a onclick="testPrintInvoice(23417);"><h2><u>發票測試列印(請於列印發票前點選此連結進行測試列印)</u></h2></a>
    </div>
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                        <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager())
                            { %>
                        <a id="btnDownload" onclick="printAll();" style="display: none;" class="btn btn-primary"><i class="fa fa-fw fa-print"></i>整批列印</a>
                        <%  } %>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="invoiceList">
                        <%  if (_viewModel.DocType == Naming.DocumentTypeDefinition.E_Allowance)
                            {
                                Html.RenderPartial("~/Views/Invoice/Module/AllowanceItemList.ascx", _model);
                            }
                            else
                            {
                                Html.RenderPartial("~/Views/Invoice/Module/InvoiceItemList.ascx", _model);
                            } %>
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
    function inquireInvoice() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        $form.ajaxSubmit({
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                $('#invoiceList').empty()
                    .append($(data));
            }
        });
    }

    function testPrintInvoice(invoiceID) {
        var event = event || window.event;
        var printerIP = $('input[name="PrinterIP"]').val();
        if (!printerIP || printerIP == '') {
            alert('請先設定印表機IP!!');
            return;
        }
        <%  if(WebHome.Properties.Settings.Default.UseSSL)
            {  %>
        $('<form>').launchDownload('<%= "http://210.65.88.44/WebInvoice" + Url.Action("LoadInvoiceImageByUID", "Invoice",new { _profile.UID,t = DateTime.Now.Ticks }) %>', { 'invoiceID': invoiceID, 'printerIP': printerIP }, '_blank');
        <%  }
            else
            {   %> 
        $('<form>').launchDownload('<%= Url.Action("LoadInvoiceImage", "Invoice",new { t = DateTime.Now.Ticks }) %>', { 'invoiceID': invoiceID, 'printerIP': printerIP }, '_blank');
        <%  }   %>
    }


    function printInvoice(invoiceID) {
        var event = event || window.event;
        var printerIP = $('input[name="PrinterIP"]').val();
        if (!printerIP || printerIP == '') {
            alert('請先設定印表機IP!!');
            return;
        }
        <%  if(WebHome.Properties.Settings.Default.UseSSL)
            {  %>
        $('<form>').launchDownload('<%= "http://210.65.88.44/WebInvoice" + Url.Action("LoadInvoiceImageByUID", "Invoice",new { _profile.UID,t = DateTime.Now.Ticks }) %>', { 'invoiceID': invoiceID, 'printerIP': printerIP }, '_blank');
        <%  }
            else
            {   %> 
        $('<form>').launchDownload('<%= Url.Action("LoadInvoiceImage", "Invoice",new { t = DateTime.Now.Ticks }) %>', { 'invoiceID': invoiceID, 'printerIP': printerIP }, '_blank');
        <%  }   %>
        $(event.target).closest('a').after('<span>已列印</span>').remove();
    }

    function printAllowance(allowanceID) {
        var printerIP = $('input[name="PrinterIP"]').val();
        if (!printerIP || printerIP == '') {
            alert('請先設定印表機IP!!');
            return;
        }
        <%  if(WebHome.Properties.Settings.Default.UseSSL)
            {  %>
        $('<form>').launchDownload('<%= "http://210.65.88.44/WebInvoice" + Url.Action("PrintAllowanceImageByUID", "Invoice",new { _profile.UID,t = DateTime.Now.Ticks }) %>', { 'allowanceID': allowanceID, 'printerIP': printerIP }, '_blank');
        <%  }
            else
            {   %> 
        $('<form>').launchDownload('<%= Url.Action("PrintAllowanceImage", "Invoice") %>', { 'allowanceID': allowanceID, 'printerIP': printerIP }, '_blank');
        <%  }   %>

    }

    function printAll() {
        <%--$('#queryForm').launchDownload('<%= Url.Action("PrintAll","Invoice") %>');--%>
        var printerIP = $('input[name="PrinterIP"]').val();
        if (!printerIP || printerIP == '') {
            alert('請先設定印表機IP!!');
            return;
        }
        $('#queryForm').launchDownload('<%= Url.Action("PrintAllInvoice","Invoice") %>');
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    InvoiceQueryViewModel _viewModel;
    IQueryable<Payment> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser().LoadInstance(models);
        _viewModel = (InvoiceQueryViewModel)ViewBag.ViewModel;
        _model = (IQueryable<Payment>)this.Model;
    }

</script>
