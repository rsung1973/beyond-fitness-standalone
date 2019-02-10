<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
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
    <section class="content">
        <%  ViewBag.BlockHeader = "合約服務申請";
            ViewBag.InsertPartial = (Action)(() =>
            {
                Html.RenderPartial("~/Views/ConsoleHome/Shared/MyContractHeader.ascx", _model); ;
            });
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <!--服務申請-->
        <div class="container-fluid">
            <div class="card widget_3">
                <div class="header">
                    <h2><strong><%= _item.ContractOwner.RealName %></strong> <%= _item.ContractName() %> <span class="badge badge-danger"><i class="zmdi zmdi-pin"></i> <%= _item.CourseContractExtension.BranchStore.BranchName %></span> <a href="javascript:$global.showContractDetails('<%= _item.ContractID.EncryptKey() %>');" class="btn btn-simple btn-info btn-round float-right">更多資訊</a></h2>
                    <%  Html.RenderPartial("~/Views/ContractConsole/Indication/ContractDetails.ascx", _item); %>
                </div>
                <ul class="row clearfix list-unstyled m-b-0">
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/ContractService/ContractExtension.ascx", _item); %>
                    </li>
                    <!--
                  <li class="col-lg-3 col-md-6 col-sm-12">
                     <div class="body">
                        <div class="row">
                           <div class="col-8">
                              <h5 class="m-t-0">轉點</h5>
                              <span class="col-red"><i class="zmdi zmdi-block"></i> 合約已過期</span><br/>
                              <span class="col-red"><i class="zmdi zmdi-block"></i> 服務申請進行中</span><br/>                          
                              <span class="col-red"><i class="zmdi zmdi-block"></i> 費用未結清</span><br/>
                              <span class="col-red"><i class="zmdi zmdi-block"></i> 信義禁止轉點</span>
                           </div>
                           <div class="col-4 text-right">
                              <a href="javascript:showContractList();">
                                 <h2>0</h2>
                              </a>
                              <small class="info">待申請</small>
                              <p>
                                 <button class="btn btn-darkteal btn-icon btn-icon-mini btn-round waves-effect float-right" id="relocation"><i class="zmdi zmdi-plus"></i></button>
                              </p>
                           </div>
                        </div>
                     </div>
                  </li>
-->
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/ContractService/ContractTransference.ascx", _item); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/ContractService/ContractTermination.ascx", _item); %>
                    </li>
                    <li class="col-lg-3 col-md-6 col-sm-12">
                        <%  Html.RenderPartial("~/Views/ContractConsole/ContractService/ContractCoachReplacement.ascx", _item); %>
                    </li>
                </ul>
            </div>
        </div>
        <!--詳細資料-->
        <div class="container-fluid contract">
            <div class="row clearfix">
                <h4 class="card-outbound-header m-l-15">詳細資料</h4>
                <div class="col-lg-12">
                    <div class="card">
                        <div class="body">
                            <div class="table-responsive">
                                <%  Html.RenderPartial("~/Views/ContractConsole/ContractService/ContractServiceHistory.ascx", _item); %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </section>
    <script>
        function processContractService(keyID) {
            showLoading();
            $.post('<%= Url.Action("ProcessContractService", "ContractConsole") %>', { 'keyID': keyID }, function (data) {
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
