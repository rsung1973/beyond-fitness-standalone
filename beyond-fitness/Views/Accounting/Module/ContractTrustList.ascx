<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

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
                <h2>預收款信託清單</h2>
                <div class="widget-toolbar">
                    <a id="btnDownloadTrustLesson" onclick="downloadTrustLesson();" class="btn bg-color-green"><i class="fa fa-fw fa-clipboard-list"></i>當月上課清單</a>
                   <!-- <a id="btnDownloadContractTrustSummary" onclick="downloadContractTrustSummary();" class="btn btn-danger"><i class="fa fa-fw fa-file"></i>信託盤點表</a>-->
                    <a id="btnDownloadTrustContract" onclick="downloadTrustContract();" style="display: none;" class="btn btn-primary"><i class="fa fa-fw fa-file-archive"></i>信託合約下載</a>
                    <a id="btnDownloadTrustTrack" onclick="downloadTrustTrack();" style="display: none;" class="btn btn-warning"><i class="fa fa-fw fa-file-excel"></i>當月信託報表</a>
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
                    <%  Html.RenderPartial("~/Views/Accounting/Module/ContractTrustTrackList.ascx", _model); %>
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
                <h2>彙總表</h2>
                <div class="widget-toolbar">
                    <%--<a id="btnDownloadTrustSummary" onclick="downloadTrustSummary();" style="display: none;" class="btn btn-primary"><i class="fa fa-fw fa-cloud-download-alt"></i>下載</a>--%>
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
                    <%  Html.RenderPartial("~/Views/Accounting/Module/ContractTrustSummaryList.ascx", _model); %>
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

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "contractTrust" + DateTime.Now.Ticks;
    IQueryable<ContractTrustTrack> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<ContractTrustTrack>)this.Model;
    }

</script>
