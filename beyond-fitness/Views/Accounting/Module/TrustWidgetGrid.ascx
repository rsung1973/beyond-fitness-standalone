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
                        <form action="<%= Url.Action("InquireTrust","Accounting") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇信託資料月份</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="TrustYearMonth" readonly="readonly" class="form-control date form_month" data-date-format="yyyy/mm" placeholder="請輸入查詢月份" value='<%= _viewModel.TrustYearMonth %>' />
                                        </label>
                                    </section>
                                    <%--<section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇信託資料迄月</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="TrustDateTo" readonly="readonly" class="form-control date form_month" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢迄月" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.TrustDateTo) %>' />
                                        </label>
                                    </section>--%>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇信託類別</label>
                                        <label class="select">
                                            <select class="input" name="TrustType">
                                                <option value="">全部</option>
                                                <option value="B">新增（B）</option>
                                                <option value="N">返還（N）</option>
                                                <option value="T">轉入（T）</option>
                                                <option value="S">終止（S）</option>
                                                <option value="X">轉讓（X）</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button onclick="inquireTrust();" type="button" name="btnSend" class="btn btn-primary">
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
    <div id="trustList">
        <%  ViewBag.DataItems = models.GetTable<Settlement>().Where(s => false);
            Html.RenderPartial("~/Views/Accounting/Module/ContractTrustList.ascx", models.GetTable<ContractTrustTrack>().Where(t => false)); %>
    </div>

</section>

<script>
    //debugger;
    function inquireTrust() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();
        $('#btnDownloadTrustTrack').css('display', 'none');
        $('#btnDownloadTrustContract').css('display', 'none');
        $('#btnDownloadTrustSummary').css('display', 'none');
        //$('#btnDownloadTrustLesson').css('display', 'none');

        showLoading();
        $('#trustList').load('<%= Url.Action("InquireContractTrust","Accounting") %>', formData, function (data) {
            hideLoading();
        });

    }

    function downloadTrustTrack() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateTrustTrackXlsx","Accounting") %>');
    }

    function downloadTrustContract() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateTrustContractZip","Accounting") %>');
    }


    function downloadTrustSummary() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateTrustSummaryXlsx","Accounting") %>');
    }

    function downloadTrustLesson() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateTrustLessonXlsx","Accounting") %>');
    }

    function downloadContractTrustSummary() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateContractTrustSummaryXlsx","Accounting") %>');
    }
    

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    TrustQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (TrustQueryViewModel)ViewBag.ViewModel;
    }

</script>
