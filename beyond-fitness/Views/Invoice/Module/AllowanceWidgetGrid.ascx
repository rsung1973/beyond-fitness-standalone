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
                        <form action="<%= Url.Action("InquireInvoiceToCommitAllowance","Invoice",new { InvoiceType = (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票 }) %>" method="post" id="queryForm" class="smart-form">
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
                                            <input type="text" name="InvoiceNo" class="form-control input" maxlength="20" placeholder="請輸入發票號碼" />
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
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇發票起日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <%  var dateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                                            <input type="text" name="DateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇發票迄日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="DateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" />
                                        </label>
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
                        <%  Html.RenderPartial("~/Views/Invoice/Module/InvoiceItemList.ascx", _model);  %>
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
