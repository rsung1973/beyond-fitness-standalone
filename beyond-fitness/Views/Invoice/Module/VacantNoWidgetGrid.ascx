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
                        <form action="<%= Url.Action("InquireVacantNo","Invoice") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">發票年度</label>
                                        <label class="select">
                                            <select class="input" name="Year">
                                                <%  for (int year = DateTime.Today.Year; year >= 2017; year--)
                                                    { %>
                                                <option value="<%= year %>"><%= year %></option>
                                                <%  } %>
                                            </select>
                                            <i class="icon-append far fa-clock"></i>
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">發票期別</label>
                                        <label class="select">
                                            <select class="input" name="PeriodNo">
                                                <option value="1">01-02月</option>
                                                <option value="2">03-04月</option>
                                                <option value="3">05-06月</option>
                                                <option value="4">07-08月</option>
                                                <option value="5">09-10月</option>
                                                <option value="6">11-12月</option>
                                            </select>
                                            <i class="icon-append far fa-clock"></i>
                                        </label>
                                        <%  if (_viewModel.PeriodNo.HasValue)
                                            { %>
                                        <script>
                                            $('#queryForm select[name="PeriodNo"]').val('<%= _viewModel.PeriodNo %>');
                                        </script>
                                        <%  } %>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="button" name="btnSend" class="btn btn-primary" onclick="inquireVacantNo();">
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
                    <h2>結果清單</h2>
                </header>
                <!-- widget div-->
                <div>
                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->
                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="vacantNoList" >
                        <%  Html.RenderPartial("~/Views/Invoice/Module/VacantNoList.ascx", models.GetTable<BranchStore>().Where(b => false)); %>
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
    function inquireVacantNo() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        $form.ajaxSubmit({
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                $('#vacantNoList').empty()
                    .append($(data));
            }
        });
    }

    function downloadCsv(branchID) {
        var $form = $('#queryForm');
        $form.launchDownload('<%= Url.Action("DownloadVacantNoCsv","Invoice") %>', { 'branchID': branchID });
    }

    function processE0402(branchID) {
        var $form = $('#queryForm');
        var $formData = $form.serializeObject();
        $formData.BranchID = branchID;

        showLoading();
        $.post('<%= Url.Action("ProcessE0402","Invoice") %>', $formData, function (data) {
            hideLoading();
            if (data.result) {
                alert('資料已送出，請檢查Turnkey!!');
            } else {
                alert(data.message);
            }
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    InvoiceNoViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (InvoiceNoViewModel)ViewBag.ViewModel;
    }

</script>
