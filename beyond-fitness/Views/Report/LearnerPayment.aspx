<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-dollar-sign"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>人員管理></li>
            <li>學員付款紀錄查詢</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
                ribbon for further usability

                Example below:

                <span class="ribbon-button-alignment pull-right">
                <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
                <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
                <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
                </span> -->

    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-dollar-sign"></i>報表管理
                            <span>>  
                                付款紀錄表
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">
        <article class="col-sm-12 col-md-12 col-lg-12">
            <!-- new widget -->
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-4" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
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
                    <span class="widget-icon"><i class="fa fa-search txt-color-white"></i></span>
                    <h2>查詢條件 </h2>
                    <!-- <div class="widget-toolbar">
                              add: non-hidden - to disable auto hide
                              
                              </div>-->
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
                        <form id="pageForm" action="<%= VirtualPathUtility.ToAbsolute("~/Report/LearnerPayment") %>" class="smart-form" method="post">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label class="input">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" name="userName" class="input-lg" value="<%= _viewModel.UserName %>" placeholder="請輸入學員姓名"/>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="select">
                                            <%  var inputItem = new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _viewModel.CoachID };
                                                ViewBag.SelectIndication = "<option value=''>請選擇體能顧問</option>";
                                                ViewBag.ByAuthorization = true;
                                                Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="select">
                                            <select class="input-lg" name="payoff">
                                                <option>是否已付款</option>
                                                <option value="true" <%= _viewModel.Payoff==true ? "selected" : null %>>是</option>
                                                <option value="false" <%= _viewModel.Payoff==false ? "selected" : null %>>否</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                            <script>
                                                $(function () {
                                                    $('select[name="payoff"]').on('change', function (evt) {
                                                        if ($(this).val() == 'true') {
                                                            $('.byDate').css('display', 'block');
                                                        } else {
                                                            $('.byDate').css('display', 'none');
                                                        }
                                                    });
                                                });
                                            </script>
                                        </label>
                                    </section>
                                </div>
                                <div class="row byDate" style="<%= _viewModel.Payoff!=true ? "display: none;" : null %>">
                                    <section class="col col-6">
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="dateFrom" id="dateFrom" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢起日" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.DateFrom) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="dateTo" id="dateTo" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢迄日" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.DateTo) %>" />
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="submit" name="hasQuery" value="true" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                            </footer>
                            <%--<div class="message">
                                <i class="fa fa-check fa-lg"></i>
                                <p>
                                    Your comment was successfully added!
                                </p>
                            </div>--%>
                        </form>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
    </div>
    <!-- end row -->

    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">

            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-0" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
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
                    <h2>學員付款紀錄列表</h2>
                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body no-padding">
                        <!-- content -->
                        <%  Html.RenderPartial("~/Views/Report/PaymentList.ascx", _model); %>

                        <!-- end content -->
                    </div>

                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->


    </div>


    <script>

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LearnerPaymentViewModel _viewModel;
    IQueryable<RegisterLesson> _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (LearnerPaymentViewModel)ViewBag.ViewModel;
        _model = (IQueryable<RegisterLesson>)this.Model;

    }



</script>
