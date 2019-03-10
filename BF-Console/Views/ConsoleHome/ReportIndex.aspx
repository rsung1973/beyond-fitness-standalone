<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">
    <!-- JQuery DataTable Css -->
    <link href="plugins/jquery-datatable/DataTables-1.10.18/css/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/Responsive-2.2.2/css/responsive.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/FixedColumns-3.2.5/css/fixedColumns.bootstrap4.min.css" rel="stylesheet">
    <!-- Bootstrap Datetimepick -->
    <link href="plugins/smartcalendar/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />
    <link href="css/smartcalendar-2.css" rel="stylesheet" />

    <!-- Custom Css -->
    <link rel="stylesheet" href="css/customelist.css?2" />
    <!-- jSignature -->
    <link rel="stylesheet" href="css/jsignature.css">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        $(function () {
            $global.viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;

            for (var i = 0; i < $global.onReady.length; i++) {
                $global.onReady[i]();
            }
        });
    </script>
    <!-- Main Content -->
    <section class="content file_manager">
        <%  ViewBag.BlockHeader = "我的下載";
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-lg-12">
                    <div class="card">
                        <ul class="nav nav-tabs">
                            <li class="nav-item"><a class="nav-link active" data-toggle="tab" href="#payment">收款</a></li>
                            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#learner">學生</a></li>
                            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#achivement">薪資</a></li>
                            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#trust">信託</a></li>
                            <li class="nav-item"><a class="nav-link" data-toggle="tab" href="#inventory">盤點</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">                        
                        <div class="tab-pane active" id="payment">
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">懶人包</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href='javascript:downloadPaymentReport(<%= JsonConvert.SerializeObject(new {
                                                            PayoffDateFrom = DateTime.Today,
                                                            PayoffDateTo = DateTime.Today,
                                                            BypassCondition = true,
                                                            InvoiceType = (Naming.InvoiceTypeDefinition?)null,
                                                        }) %>);'>
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: coins.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">收款清單</p>
                                                    <small>本日 <span class="date text-muted"><%= $"{DateTime.Today:yyyy/MM/dd}" %></span></small>
                                                </div>
                                            </a>
                                            <script>
                                                function downloadPaymentReport(viewModel) {
                                                    $('').launchDownload('<%= Url.Action("CreatePaymentInvoiceQueryXlsx","Payment") %>', viewModel, 'report', true);
                                                }
                                            </script>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href='javascript:downloadPaymentReport(<%= JsonConvert.SerializeObject(new
                                                        {
                                                            PayoffDateFrom = DateTime.Today.FirstDayOfMonth(),
                                                            PayoffDateTo = DateTime.Today.FirstDayOfMonth().AddMonths(1).AddDays(-1),
                                                            BypassCondition = true,
                                                            InvoiceType = (Naming.InvoiceTypeDefinition?)null,
                                                        }) %>);'>
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: us-dollar.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">收款清單</p>
                                                    <small>本月 <span class="date text-muted"><%= $"{DateTime.Today:yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href='javascript:downloadPaymentReport(<%= JsonConvert.SerializeObject(new 
                                                        {
                                                            PayoffDateFrom = DateTime.Today.FirstDayOfMonth().AddMonths(-1),
                                                            PayoffDateTo = DateTime.Today.FirstDayOfMonth().AddDays(-1),
                                                            BypassCondition = true,
                                                            InvoiceType = (Naming.InvoiceTypeDefinition?)null,
                                                        }) %>);'>
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: us-dollar.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">收款清單</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateMonthlyPaymentReportXlsx","Payment") %>', { 'settlementDate': '<%= $"{DateTime.Today.AddMonths(-1):yyyy/MM/dd}" %>' },'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: notebook.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">課程顧問費用會計明細帳</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateAccountsReveivableXlsx","Accounting") %>',{'BypassCondition':true},'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: dislike.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">催收帳款清單</p>
                                                    <small>截至目前 <span class="date text-muted"><%= $"{DateTime.Today:yyyy/MM/dd}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">自訂條件</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectPeriodPaymentReport();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: us-dollar.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">收款清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                            <script>
                                                function selectPeriodPaymentReport() {
                                                    showLoading();
                                                    $.post('<%= Url.Action("SelectPeriodReport","ReportConsole") %>', {}, function (data) {
                                                        hideLoading();
                                                        if ($.isPlainObject(data)) {
                                                            swal(data.message);
                                                        } else {
                                                            $global.doQuery = function (viewModel) {
                                                                viewModel.InvoiceType = null;
                                                                downloadPaymentReport(viewModel);
                                                            }
                                                            $(data).appendTo($('body'));
                                                        }
                                                    });
                                                }
                                            </script>                                        
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyAccountingReport();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: notebook.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">課程顧問費用會計明細帳</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                            <script>
                                                function selectMonthlyAccountingReport() {
                                                    showLoading();
                                                    $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                        hideLoading();
                                                        if ($.isPlainObject(data)) {
                                                            swal(data.message);

                                                        } else {
                                                            $global.doQuery = function (settlementDate) {
                                                                $('').launchDownload('<%= Url.Action("CreateMonthlyPaymentReportXlsx","Payment") %>', { 'settlementDate': settlementDate }, 'report',true);
                                                            }
                                                            $(data).appendTo($('body'));
                                                        }
                                                    });
                                                }
                                            </script>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane" id="learner">
                            <div class="row clearfix">
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateUnallocatedLearnerListXlsx","Learner") %>');">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: users.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">未指派體能顧問清單</p>
                                                    <small>截至今日 <span class="date text-muted"><%= $"{DateTime.Today:yyyy/MM/dd}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane" id="achivement">
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">懶人包</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateFullAchievementXlsx","Accounting") %>', { 'achievementDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>', 'bypassCondition': true ,'detailsOnly': false }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: piggybank.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">薪資清單</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateAchievementXlsx","Accounting") %>', { 'achievementDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>', 'bypassCondition': true ,'detailsOnly': true }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: list.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">上課清單</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">自訂條件</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyFullAchievement();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: piggybank.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">薪資清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                    <script>
                                        function selectMonthlyAchievement(detailsOnly) {
                                            showLoading();
                                            $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (settlementDate) {
                                                        $('').launchDownload('<%= Url.Action("CreateAchievementXlsx","Accounting") %>', { 'achievementDateFrom': settlementDate, 'bypassCondition': true, 'detailsOnly': detailsOnly }, 'report', true);
                                                    }
                                                    $(data).appendTo($('body'));
                                                }
                                            });
                                        }

                                        function selectMonthlyFullAchievement() {
                                            showLoading();
                                            $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (settlementDate) {
                                                        $('').launchDownload('<%= Url.Action("CreateFullAchievementXlsx","Accounting") %>', { 'achievementDateFrom': settlementDate, 'bypassCondition': true }, 'report', true);
                                                    }
                                                    $(data).appendTo($('body'));
                                                }
                                            });
                                        }
                                    </script>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyAchievement(true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: list.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">上課清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                    
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane" id="trust">
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">懶人包</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateTrustTrackXlsx","Accounting") %>', { 'trustDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth():yyyy/MM/dd}" %>' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: bank.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">信託請款表</p>
                                                    <small>本月 <span class="date text-muted"><%= $"{DateTime.Today:yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateTrustTrackXlsx","Accounting") %>', { 'trustDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: bank.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">信託請款表</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateTrustLessonXlsx","Accounting") %>', { 'trustDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: timer.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">已信託上課清單</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateTrustContractZip","Accounting") %>', { 'trustDateFrom': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: rocket.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">合約電子檔懶人包</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("CreateContractTrustSummaryXlsx","Accounting") %>',{'BypassCondition':true},'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: grid.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">信託盤點清單</p>
                                                    <small>截至信託月份 <span class="date text-muted"><%= $"{models.GetTable<Settlement>().OrderByDescending(s=>s.SettlementID).Select(s=>s.StartDate).FirstOrDefault():yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">自訂清單</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyTrust();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: bank.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">信託請款表</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                    <script>
                                        function selectMonthlyTrust() {
                                            showLoading();
                                            $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (settlementDate) {
                                                        $('').launchDownload('<%= Url.Action("CreateTrustTrackXlsx","Accounting") %>', { 'trustDateFrom': settlementDate }, 'report', true);
                                                    }
                                                    $(data).appendTo($('body'));
                                                }
                                            });
                                        }
                                    </script>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyTrustLessons();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: timer.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">已信託上課清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                    <script>
                                        function selectMonthlyTrustLessons() {
                                            showLoading();
                                            $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                            hideLoading();
                                            if ($.isPlainObject(data)) {
                                                swal(data.message);

                                            } else {
                                                $global.doQuery = function (settlementDate) {
                                                    $('').launchDownload('<%= Url.Action("CreateTrustLessonXlsx","Accounting") %>', { 'trustDateFrom': settlementDate }, 'report', true);
                                                    }
                                                    $(data).appendTo($('body'));
                                                }
                                            });
                                        }
                                    </script>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyTrustContract();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: rocket.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">合約電子檔懶人包</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <script>
                                    function selectMonthlyTrustContract() {
                                        showLoading();
                                        $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (settlementDate) {
                                                        $('').launchDownload('<%= Url.Action("CreateTrustContractZip","Accounting") %>', { 'trustDateFrom': settlementDate }, 'report', true);
                                                }
                                                $(data).appendTo($('body'));
                                            }
                                        });
                                    }
                                </script>

                            </div>
                        </div>
                        <div class="tab-pane" id="inventory">
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">懶人包</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("GetMonthlySettlement","Accounting") %>', { 'settlementDate': '<%= $"{DateTime.Today.AddMonths(-1):yyyy/MM/dd}" %>','initialDate':'2018/12/01' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: box.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">合約盤點清單</p>
                                                    <small>截至上月 <span class="date text-muted"><%= $"{DateTime.Today.AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>               
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:$('').launchDownload('<%= Url.Action("GetMonthlyLessonsSummary","Accounting") %>', { 'settlementDate': '<%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM/dd}" %>' }, 'report',true);">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: morph-clock.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">上課盤點清單</p>
                                                    <small>上月 <span class="date text-muted"><%= $"{DateTime.Today.FirstDayOfMonth().AddMonths(-1):yyyy/MM}" %></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row clearfix">
                                <div class="col-12">
                                    <h4 class="card-outbound-header">自訂條件</h4>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlySettlement();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: box.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">合約盤點清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectContractLessonsSummary();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: morph-clock.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">上課盤點清單</p>
                                                    <small>合約編號 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <div class="card">
                                        <div class="file">
                                            <a href="javascript:selectMonthlyLessonsSummary();">
                                                <div class="icon">
                                                    <i class="zmdi livicon livicon-evo" data-options="name: stopwatch.svg; size: 60px; style: original; strokeWidth:2px; autoPlay:true"></i>
                                                </div>
                                                <div class="file-name">
                                                    <p class="m-b-5 text-muted">上課盤點清單</p>
                                                    <small>自訂條件 <span class="date text-muted"><i class="zmdi zmdi-search"></i></span></small>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <script>
                                    function selectContractLessonsSummary() {
                                        showLoading();
                                        $.post('<%= Url.Action("SelectReportByContractNo","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (inputData) {
                                                        $('').launchDownload('<%= Url.Action("GetContractLessonsSummary","Report") %>', inputData, 'report', true);
                                                }
                                                $(data).appendTo($('body'));
                                            }
                                        });
                                    }

                                    function selectMonthlyLessonsSummary() {
                                        showLoading();
                                        $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    swal(data.message);

                                                } else {
                                                    $global.doQuery = function (settlementDate) {
                                                        $('').launchDownload('<%= Url.Action("GetMonthlyLessonsSummary","Accounting") %>', { 'settlementDate': settlementDate }, 'report', true);
                                                }
                                                $(data).appendTo($('body'));
                                            }
                                        });
                                    }
                                </script>
                                <script>
                                    function selectMonthlySettlement() {
                                        showLoading();
                                        $.post('<%= Url.Action("SelectMonthlyReport","ReportConsole") %>', {}, function (data) {
                                                        hideLoading();
                                                        if ($.isPlainObject(data)) {
                                                            swal(data.message);

                                                        } else {
                                                            $global.doQuery = function (settlementDate) {
                                                                $('').launchDownload('<%= Url.Action("GetMonthlySettlement","Accounting") %>', { 'settlementDate': settlementDate, 'initialDate': '2018/12/01' }, 'report', true);
                                                }
                                                $(data).appendTo($('body'));
                                            }
                                        });
                                    }
                                </script>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </section>

</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!--Sparkline Plugin Js-->
    <script src="plugins/jquery-sparkline/jquery.sparkline.js"></script>
    <!-- SweetAlert Plugin Js -->
    <script src="plugins/sweetalert/sweetalert.min.js"></script>
    <!-- Jquery DataTable Plugin Js -->
    <script src="bundles/datatablescripts.bundle.js"></script>
    <script src="plugins/jquery-datatable/Responsive-2.2.2/js/dataTables.responsive.min.js"></script>
    <script src="plugins/jquery-datatable/FixedColumns-3.2.5/js/dataTables.fixedColumns.min.js"></script>
    <!-- Bootstrap datetimepicker Plugin Js -->
    <%--    <script src="plugins/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/bootstrap-datetimepicker/js/locales/bootstrap-datetimepicker.zh-TW.js"></script>--%>
    <script src="plugins/smartcalendar/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/smartcalendar/js/locales-datetimepicker/bootstrap-datetimepicker.zh-TW.js"></script>

    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/KnobJS.ascx"); %>

    <script type="text/javascript">

</script>

</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    CourseContract _item;
    UserProfile _model;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
        _item = (CourseContract)ViewBag.DataItem;

    }

</script>
