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
<%--    <link href="plugins/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />
    <link href="css/datetimepicker.css" rel="stylesheet" />--%>
    <link href="plugins/smartcalendar/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />
    <link href="css/smartcalendar-2.css" rel="stylesheet" />

    <!-- Custom Css -->
    <link rel="stylesheet" href="css/customelist.css?2" />

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
    <section class="content">
        <%  ViewBag.BlockHeader = "我的合約";
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model); %>

        <%  if (_model.IsCoach())
            {   %>
        <!--我的合約-->
        <div class="container-fluid">
            <div class="card widget_3">
                <ul class="row clearfix list-unstyled m-b-0">
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutExpiringByCoach.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutNewContractsByCoach.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutContractServicesByCoach.ascx", _model); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutPaymentByCoach.ascx", _model); %>
                    </li>
                </ul>
                <ul class="row clearfix list-unstyled m-b-0">
                    <%
                        var newContracts = _effectiveItems
                            .Where(c=>c.Expiration>=DateTime.Today)
                            .Where(c => !c.Renewal.HasValue || c.Renewal == false);
                        var renewContracts = _effectiveItems
                            .Where(c=>c.Expiration>=DateTime.Today)
                            .Where(c => c.Renewal.HasValue && c.Renewal == true);%>
                    <li class="col-lg-9 col-md-6 col-sm-12">
                        <div class="body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-12">
                                    <div class="info-box-2">
                                        <div class="content">
                                            <div class="sparkline-pie"><%= newContracts.Count() %>,<%= renewContracts.Count() %></div>
                                            <h6 class="m-t-20">新約 V.S. 續約</h6>
                                            <p class="displayblock m-b-0"><span class="col-amber"><%= newContracts.Count() %></span> / <span class="col-grey"><%= renewContracts.Count() %></span></p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-12">
                                    <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutInstallment.ascx", _effectiveItems); %>
                                </div>
                            </div>
                        </div>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/Module/AboutReceivablesByCoach.ascx", _model); %>
                    </li>
                </ul>
            </div>
        </div>
        <%  } %>

        <%  if (_model.IsViceManager() || _model.IsManager())
            {
                Html.RenderPartial("~/Views/ContractConsole/Module/ContractByBranch.ascx", _model);
            }
            else if (_model.IsAssistant() || _model.IsOfficer())
            {
                Html.RenderPartial("~/Views/ContractConsole/Module/ContractByOfficer.ascx", _model);
            }   %>

        <%  Html.RenderPartial("~/Views/ContractConsole/Module/ContractDetails.ascx", _model); %>
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
        var dtLearner;
        var dtPaymentList;
        $(function() {
            $.scrollUp({
                animation: 'fade',
                scrollImg: {
                    active: true,
                    type: 'background',
                    src: 'images/top.png'
                }
            });
            //$(".ls-toggle-btn").click();
        });

        //合約新開立與續約比例
        $('.sparkline-pie').sparkline('html', {
            type: 'pie',
            offset: 90,
            width: '100px',
            height: '100px',
            sliceColors: ['#ffe6aa', '#cbd1d9']
        })

        //開啟小日曆
        $('.date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            forceParse: 0,
            startDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>'
        });

        //新增合約
        $('#editcontract').on('click', function(event) {
            window.location.href = 'contract-edit.html';
        });


        //點選合約詳細資料更多
        $('.mb_colsble').on('click', function(event) {
            var $collapseArea = $('.mb_colsble');
            var $list = $collapseArea.find('.mb_list');
            console.log($list);
            var $titleArea = $collapseArea.find('.tit');
            $titleArea.on('click', function(e) {
                if ($collapseArea.hasClass('open')) {
                    $list.slideToggle(undefined, function() {
                        $collapseArea.toggleClass('open');
                    });
                } else {
                    $collapseArea.toggleClass('open');
                    $list.slideToggle();
                }
                return false;
            });
        });

        //點選刪除功能
        this.deleteData = function() {
            swal({
                title: "不後悔?",
                text: "刪除後資料將無法回覆!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "確定, 不後悔",
                cancelButtonText: "不, 點錯了",
                closeOnConfirm: false,
                closeOnCancel: false
            }, function(isConfirm) {
                if (isConfirm) {
                    swal("刪除成功!", "資料已經刪除 Bye!", "success");
                } else {
                    swal("取消成功", "你的資料現在非常安全 :)", "error");
                }
            });
        };

        //搜尋體能顧問
        this.showSearchCoach = function() {
            $("#searchCoachModal").modal('show');
        };

        //顯示合約學生清單
        $('#detailContractModal').on('shown.bs.modal', function() {
            if (dtLearner != undefined) {
                dtLearner.destroy();
            }
            dtLearner = $('.dataTable-learner').DataTable({
                "ajax": 'ajax/data/learnerlist.json',
                "filter": false,
                "bPaginate": false,
                "info": false,
                "order": [
                    [0, 'asc'],
                    [1, 'asc']
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _PAGE_ / _PAGES_",
                    "infoEmpty": "顯示 0 到 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                }
            });

        })

        //顯示合約學生清單
        $('#collapseLearnerlist').on('shown.bs.collapse', function(event) {
            if (dtLearner != undefined) {
                dtLearner.destroy();
            }
            dtLearner = $('.dataTable-learner').DataTable({
                "ajax": 'ajax/data/learnerlist.json',
                "filter": false,
                "bPaginate": false,
                "info": false,
                "order": [
                    [0, 'asc'],
                    [1, 'asc']
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _PAGE_ / _PAGES_",
                    "infoEmpty": "顯示 0 到 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                }
            });
        })

        //顯示合約已收款發票清單
        $('#collapseInvoiceList').on('shown.bs.collapse', function(event) {
            if (dtPaymentList != undefined) {
                dtPaymentList.destroy();
            }

            dtPaymentList = $('.dataTable-invoiceList').DataTable({
                "ajax": 'ajax/data/invoicelist.json',
                "filter": false,
                "bPaginate": false,
                "info": false,
                "order": [
                    [0, 'desc'],
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _PAGE_ / _PAGES_",
                    "infoEmpty": "顯示 0 到 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                },
                "columnDefs": [{
                        targets: [5, 6, 7],
                        className: "align-right"

                    },
                    {
                        targets: [2, 3, 4, 10],
                        className: "align-center"

                    }
                ],
            });
        })
    </script>


    <script>

        function processContract(keyID) {
            showLoading();
            $.post('<%= Url.Action("ProcessContract", "ContractConsole") %>', { 'keyID': keyID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

    </script>

</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    CourseContractQueryViewModel _viewModel;
    IQueryable<CourseContract> _effectiveItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;

        _effectiveItems = models.PromptEffectiveContract()
            .Where(c => c.FitnessConsultant == _model.UID);
    }

</script>
