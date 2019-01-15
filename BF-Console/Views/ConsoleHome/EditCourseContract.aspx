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
        <%  ViewBag.BlockHeader = "編輯合約";
            ViewBag.InsertPartial = (Action)(() =>
            {
                Html.RenderPartial("~/Views/ConsoleHome/Shared/MyContractHeader.ascx", _model); ;
            });
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <!--合約基本資料-->
        <div class="container-fluid">
            <div class="card">
                <div class="header">
                    <%  Html.RenderPartial("~/Views/ContractConsole/Editing/SelectConsultant.ascx", _model); %>
                </div>
                <div class="body">
                    <div class="row clearfix">
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <select class="form-control show-tick" name="ContractType">
                                <option value="">-- 請選擇合約類型 --</option>
                                <%  foreach (var item in models.GetTable<CourseContractType>().Where(c => c.TypeID < 5))
                                    { %>
                                <option value="<%= item.TypeID %>"><%= item.TypeName %></option>
                                <%  } %>
                            </select>
                            <script>
                                $(function () {
                                    $('select[name="ContractType"]').val('<%= _viewModel.ContractType %>');
                                    $('select[name="ContractType"]').on('change', function (event) {
                                        $global.viewModel.ContractType = $(this).val();
                                    });
                                });
                            </script>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <select class="form-control show-tick" name="Renewal">
                                <option value="" selected="">-- 是否為舊學員續約 --</option>
                                <option value="True">是</option>
                                <option value="False">否</option>
                            </select>
                            <script>
                                $(function () {
                                    $('select[name="Renewal"]').val('<%= _viewModel.Renewal %>');
                                    $('select[name="Renewal"]').on('change', function (event) {
                                        $global.viewModel.Renewal = $(this).val();
                                    });
                                });
                            </script>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <select class="form-control show-tick" name="BranchID">
                                <option value="">-- 請選擇上課場所 --</option>
                                <%  if (_model.IsAssistant() || _model.IsOfficer())
                                    {
                                    }
                                    else
                                    {
                                        ViewBag.IntentStore = models.GetTable<CoachWorkplace>().Where(w=>w.CoachID==_model.UID).Select(w => w.BranchID).ToArray();
                                    }
                                    Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID);
                                %>                            
                            </select>
                            <script>
                                $(function () {
                                    $('select[name="BranchID"]').val('<%= _viewModel.BranchID %>');
                                    $('select[name="BranchID"]').on('change', function (event) {
                                        $global.viewModel.BranchID = $(this).val();
                                    });
                                });
                            </script>
                            <%--<label class="material-icons help-error-text">clear 請選擇上課場所</label>--%>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <select class="form-control show-tick" name="DurationInMinutes">
                                <option value="">-- 請選擇上課時間長度 --</option>
                                <option value="60">60分鐘</option>
                                <option value="90">90分鐘</option>
                            </select>
                            <script>
                                $(function () {
                                    $('select[name="DurationInMinutes"]').val('<%= _viewModel.DurationInMinutes %>');
                                    $('select[name="DurationInMinutes"]').on('change', function (event) {
                                        $global.viewModel.DurationInMinutes = $(this).val();
                                    });
                                });
                            </script>
                            <%--<label class="material-icons help-error-text">clear 請選擇上課時間長度</label>--%>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <div class="input-group">
                                <input type="text" class="form-control form-control-danger" name="Lessons" placeholder="購買堂數" />
                                <span class="input-group-addon">
                                    <i class="zmdi zmdi-shopping-cart-plus"></i>
                                </span>
                            </div>
                            <script>
                                $(function () {
                                    $('input[name="Lessons"]').val('<%= _viewModel.Lessons %>');
                                    $('input[name="Lessons"]').on('change', function (event) {
                                        $global.viewModel.Lessons = $(this).val();
                                        calcTotalCost();
                                        loadInstallments($global.viewModel.Lessons);
                                    });
                                });
                            </script>
                            <%--<label class="material-icons help-error-text">clear 請輸入購買堂數</label>--%>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                            <%  Html.RenderPartial("~/Views/ContractConsole/Editing/SelectLessonPrice.ascx", _model); %>
                        </div>
                        <div class="col-md-12 text-right" id="costSummary">
                            <%  Html.RenderPartial("~/Views/ContractConsole/Editing/TotalCostSummary.ascx", model: _viewModel.TotalCost ?? 0); %>
                        </div>
                        <script>
                            function calcTotalCost() {
                                if ($global.viewModel.PriceID && $global.viewModel.Lessons) {
                                    $.post('<%= Url.Action("CalculateTotalCost", "ContractConsole") %>', $global.viewModel, function (data) {
                                        if ($.isPlainObject(data)) {
                                            alert(data.message);
                                        } else {
                                            $('#costSummary').empty()
                                                .append(data);
                                        }
                                    });
                                }
                            }
                        </script>
                    </div>
                </div>
            </div>
        </div>
        <!--學生基本資料-->
        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="header">
                            <h2><strong>學生基本資料</strong></h2>
                            <div class="col-md-8 col-lg-8 col-8 float-right">
                                <div class="input-group">
                                    <%  ViewBag.SearchAction = Url.Action("SearchContractMember", "ContractConsole");
                                        Html.RenderPartial("~/Views/ConsoleEvent/Module/SearchLearner.ascx"); %>
                                </div>
                            </div>
                        </div>
                        <div class="body" id="contractMember">
                            <%  Html.RenderPartial("~/Views/ContractConsole/Editing/ListContractMember.ascx",_model); %>
                        </div>
                        <input type="hidden" name="OwnerID" />
                        <script>
                            function loadMemberList() {
                                showLoading();
                                $.post('<%= Url.Action("ListContractMember", "ContractConsole") %>', $global.viewModel, function (data) {
                                    hideLoading();
                                    if ($.isPlainObject(data)) {
                                        alert(data.message);
                                    } else {
                                        $('#contractMember').empty()
                                            .append(data);
                                    }
                                });
                            }
                        </script>
                    </div>
                </div>
            </div>
        </div>
        <!--其他增補說明-->
        <div class="container-fluid">
            <div class="card">
                <div class="header">
                    <h2><strong>其他增補說明</strong></h2>
                </div>
                <div class="body">
                    <div class="row clearfix">
                        <div class="col-lg-3 col-md-3 col-sm-12 col-12">
                            <div class="checkbox">
                                <input id="checkbox1" type="checkbox" name="InstallmentPlan" value="<%= true %>" <%= _viewModel.InstallmentPlan==true ? "checked" : null %> onclick="checkInstallmentPlan();">
                                <label for="checkbox1">合約分期轉開</label>
                            </div>
                        </div>
                        <div class="col-lg-9 col-md-9 col-sm-12 col-12 installments">
                            <select class="form-control show-tick" name="Installments" onchange="installmentPlanRemark();">
                            </select>
                            <script>

                                function installmentPlanRemark() {
                                    var $installments = $('select[name="Installments"]');
                                    $global.viewModel.Installments = $installments.val();
                                    if ($installments.val() != '') {
                                        var $remark = $('textarea[name="Remark"]');
                                        var remark = $remark.val();
                                        var idx = remark.indexOf('本合約總共購買');
                                        var content = '本合約總共購買' + $('input[name="Lessons"]').val() + '堂，分期轉開次數' + $installments.val() + '次。';
                                        if (idx > 0) {
                                            $remark.val(remark.substr(0, idx) + content);
                                        } else {
                                            $remark.val(content);
                                        }
                                    }
                                }

                                function checkInstallmentPlan() {
                                    var $installmentPlan = $('input[name="InstallmentPlan"]');
                                    var $installments = $('.installments');
                                    if ($installmentPlan.is(':checked')) {
                                        $installments.css('display', 'block');
                                        $global.viewModel.InstallmentPlan = true;
                                    } else {
                                        $installments.css('display', 'none');
                                        $global.viewModel.InstallmentPlan = false;
                                    }
                                }

                                $(function () {
                                    checkInstallmentPlan();
                                });

                                function loadInstallments(lessons, installments) {
                                    var $installments = $('select[name="Installments"]');
                                    if (!installments) {
                                        installments = $installments.val();
                                    }
                                    $installments.empty();
                                    if (lessons == '' || isNaN(Number(lessons))) {
                                        return;
                                    }
                                    showLoading();
                                    $.post('<%= Url.Action("LoadInstallmentPlan","CourseContract") %>', { 'lessons': lessons, 'installments': installments }, function (data) {
                                        hideLoading();
                                        if ($.isPlainObject(data)) {
                                            swal(data.message);
                                        } else {
                                            $(data).appendTo($installments);
                                            $installments.selectpicker('refresh');
                                        }
                                    });
                                }
                        <%  if (_viewModel.InstallmentPlan == true || _viewModel.Lessons > 0)
                                {   %>
                                $(function () {
                                    loadInstallments('<%= _viewModel.Lessons %>', '<%= _viewModel.Installments %>');
                                });
                        <%  }   %>

                            </script>
                        </div>
                    </div>
                    <div class="row clearfix">
                        <div class="col-sm-12">
                            <div class="form-group">
                                <textarea rows="4" class="form-control no-resize" name="Remark" placeholder="請輸入任何想補充的事項..."><%= _viewModel.Remark %></textarea>
                            </div>
                        </div>
                        <div class="col-sm-12">
                            <button type="button" class="btn bg-darkteal btn-round float-right next" onclick="commitContract();">確定，不後悔</button>
                            <button type="button" class="btn btn-danger btn-round btn-simple save" onclick="saveContract();">暫時存檔</button>
                            <script>
                                function saveContract() {
                                    clearErrors();
                                    $.post('<%= Url.Action("SaveContract", "ContractConsole", _viewModel.ContractID) %>', $global.viewModel, function (data) {
                                        if ($.isPlainObject(data)) {
                                            swal(data.message);
                                        }
                                        else {
                                            $(data).appendTo($('body'));
                                        }
                                    });
                                }
                                function commitContract() {
                                    clearErrors();
                                    $.post('<%= Url.Action("CommitContract", "ContractConsole", _viewModel.ContractID) %>', $global.viewModel, function (data) {
                                        if ($.isPlainObject(data)) {
                                            swal(data.message);
                                        }
                                        else {
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
    UserProfile _model;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;

    }

</script>
