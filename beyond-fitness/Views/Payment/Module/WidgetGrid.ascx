<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<section class="">
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  ViewBag.ShowFooter = false;
                            Html.RenderAction("InquirePayment", "Payment",
                                new
                                {
                                    HandlerID = _profile.UID,
                                    InvoiceType = (int?)null,
                                    IsCancelled = false,
                                    PayoffDateFrom = DateTime.Today.AddMonths(-3)
                                });
                            //Html.RenderPartial("~/Views/Payment/Module/PaymentInvoiceList.ascx",
                            //    models.GetTable<Payment>()
                            //        .Where(p => p.HandlerID == _profile.UID)
                            //        .Where(p => p.PayoffDate >= DateTime.Today.AddMonths(-3))
                            //        .Join(models.GetTable<InvoiceItem>(), p => p.InvoiceID, i => i.InvoiceID, (p, i) => p)); 
                            %>
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
                    <h2>作廢收款清單</h2>
                    <div class="widget-toolbar">
                        <a onclick="voidPayment();" class="btn btn-primary" id="deletePaymentDialog_link"><i class="fa fa-fw fa-minus"></i>作廢收款</a>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  
                            Html.RenderAction("InquirePayment", "Payment",
                                new
                                {
                                    HandlerID = _profile.UID,
                                    InvoiceType = (int?)null,
                                    IsCancelled = true,
                                    PayoffDateFrom = DateTime.Today.AddMonths(-3)
                                });

                            //var items = models.GetTable<Payment>()
                            //    .Where(p => p.VoidPayment != null)
                            //    .Where(p => p.VoidPayment.HandlerID == _profile.UID);
                            //Html.RenderPartial("~/Views/Payment/Module/PaymentCancellationList.ascx", items);   
                            %>
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

    function editPayment() {
        showLoading();
        $.post('<%= Url.Action("EditPaymentForContract","Payment") %>', {}, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function voidPayment() {
        showLoading();
        $.post('<%= Url.Action("VoidPayment","Payment") %>', {}, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
    }

</script>
