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
                        <form action="<%= Url.Action("InquireInvoiceMedia","Invoice") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label class="label">分店</label>
                                        <label class="select">
                                            <select name="BranchID">
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", _viewModel.BranchID ?? -1); %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">所屬年度</label>
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
                                    <section class="col col-4">
                                        <label class="label">所屬月份</label>
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
                                <button type="button" name="btnSend" class="btn btn-primary" onclick="inquireTaxCsv();">
                                    下載 <i class="fa fa-download" aria-hidden="true"></i>
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
</section>

<script>
    function inquireTaxCsv() {
        $('#queryForm').launchDownload('<%= Url.Action("InquireInvoiceMedia","Invoice") %>');
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
