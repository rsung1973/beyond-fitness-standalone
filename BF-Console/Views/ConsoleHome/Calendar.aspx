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
    <!-- Fullcalendar -->
    <link href="plugins/fullcalendar/fullcalendar.min.css" rel="stylesheet">

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        $(function () {
            $global.viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;

            for(var i=0;i<$global.onReady.length;i++) {
                $global.onReady[i]();
            }
        });
    </script>  
    <section class="content page-calendar">
        <%  ViewBag.BlockHeader = "我的行事曆";
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model); %>
        <!--行事曆-->
        <div class="container-fluid">
            <div class="card">
                <div class="row">
                    <div class="col-md-12 col-lg-4 col-xl-4">
                        <div class="body">
                            <%  Html.RenderPartial("~/Views/ConsoleHome/Module/EventDetails.ascx", _model); %>
                        </div>
                    </div>
                    <div class="col-md-12 col-lg-8 col-xl-8">
                        <div class="body">
                            <div class="row">
                                <div class="col-md-8 col-lg-8 col-sm-8 col-12">
                                    <button class="btn btn-default btn-simple btn-icon  btn-icon-mini btn-round waves-effect" id="today">今</button>
                                    <button class="btn btn-default btn-simple btn-icon  btn-icon-mini btn-round waves-effect" id="td">天</button>
                                    <button class="btn btn-default btn-simple btn-icon  btn-icon-mini btn-round waves-effect" id="ag">週</button>
                                    <button class="btn btn-default btn-simple btn-icon  btn-icon-mini btn-round waves-effect" id="mt">月</button>
                                </div>
                                <div class="col-md-4 col-lg-4 col-sm-4 col-12">
                                    <!--
                                 <div class="btn-group float-md-right">
                                    <button type="button" class="btn btn-default btn-simple dropdown-toggle btn-round" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <i class="zmdi zmdi-pin-drop"></i>
                                    <span class="caret"></span>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-right slideDown">
                                       <li>
                                          <a href="javascript:void(0);">全部</a>
                                       </li>
                                       <li>
                                          <a href="javascript:void(0);">南京</a>
                                       </li>
                                       <li>
                                          <a href="javascript:void(0);">信義</a>
                                       </li>
                                       <li>
                                          <a href="javascript:void(0);">忠孝</a>
                                       </li>
                                    </ul>
                                 </div>
                                 -->
                                    <div class="btn-group float-md-right">
                                        <button type="button" class="btn btn-default btn-simple dropdown-toggle btn-round" id="searchCoach">
                                            <i class="zmdi zmdi-account"></i>
                                            <span class="caret"></span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <%  Html.RenderPartial("~/Views/ConsoleHome/Module/MainCalendar.ascx", _model); %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- Fullcalendar Plugin js -->
    <script src="bundles/fullcalendarscripts.bundle.js"></script>
    <script src="plugins/fullcalendar/locale/zh-tw.js"></script>
    <!-- SweetAlert Plugin Js -->
    <script src="plugins/sweetalert/sweetalert.min.js"></script>
    <!-- Bootstrap datetimepicker Plugin Js -->
    <script src="plugins/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/bootstrap-datetimepicker/js/locales/bootstrap-datetimepicker.zh-TW.js"></script>
    <!-- Multi Select Plugin Js -->
    <script src="plugins/multi-select/js/jquery.multi-select.js"></script>
  
</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    DailyBookingQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
    }

</script>
