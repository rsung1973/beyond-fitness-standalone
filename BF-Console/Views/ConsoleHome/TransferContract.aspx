﻿<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

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
        <%  ViewBag.BlockHeader = "合約轉讓";
            ViewBag.InsertPartial = (Action)(() =>
            {
                Html.RenderPartial("~/Views/ConsoleHome/Shared/MyContractHeader.ascx", _model); ;
            });
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <div class="container-fluid">
            <div class="card widget_2">
                <%  
                    ViewBag.ApplyService = (Action<String>)(viewID =>
                    {
                        ViewBag.ViewID = viewID;
                        Html.RenderPartial("~/Views/ContractConsole/ContractService/DoTransferringContract.ascx", _item);
                    });
                    Html.RenderPartial("~/Views/ContractConsole/ContractService/ApplyContractService.ascx", _item); %>
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