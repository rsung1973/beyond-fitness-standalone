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
                <i class="fa fa-calculator"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>報表管理></li>
            <li>課程統計報表</li>
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
        <i class="fa-fw fa fa-trophy"></i>報表管理
                            <span>>  
                                業績統計報表
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <div class="row">
        <article class="col-sm-12 col-md-12 col-lg-12">
            <!-- new widget -->
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-4" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
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
                        <form method="post" id="pageForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label"></label>
                                        <label class="select">
                                            <%  var inputItem = new InputViewModel { Id = "coachID", Name = "coachID" };
                                                ViewBag.SelectIndication = "<option value=''>全部</option>";
                                                Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label>請選擇上課地點</label>
                                        <label class="select">
                                            <select class="input-lg" name="branchID" id="branchID">
                                                <option value="">全部</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: 0); %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                                <div class="row">
                                    <% DateTime dateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                                    <section class="col col-6">
                                        <label class="label">&nbsp;</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="dateFrom" id="dateFrom" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= dateFrom.ToString("yyyy/MM/dd") %>' />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">&nbsp;</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="dateTo" id="dateTo" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value='<%= dateFrom.AddMonths(1).AddDays(-1).ToString("yyyy/MM/dd") %>' />
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="button" onclick="showAchievement();" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                            </footer>
                            <div class="message">
                                <i class="fa fa-check fa-lg"></i>
                                <p>
                                    Your comment was successfully added!
                                </p>
                            </div>
                        </form>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
<%--        <article class="col-sm-12 col-md-6 col-lg-6">
            <!-- new widget -->
            <div class="jarviswidget jarviswidget-color-darken" id="priceType" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
                <%  Html.RenderAction("ListLessonPriceType", "Report"); %>
            </div>
            <!-- end widget -->
        </article>--%>
    </div>
    <div class="row">
        <div id="lessonAttendance">
        </div>

        <div id="registerLesson">
        </div>
    </div>


    <script>
        function showAchievement() {
            var loadingCount = 2;
            showLoading(true);
<%--            $('#priceType').load('<%= Url.Action("ListLessonPriceType","Report") %>', function () {
                loadingCount--;
                if (loadingCount <= 0)
                    hideLoading();
            });--%>

            $('#lessonAttendance').load('<%= Url.Action("ListLessonAttendance","Report") %>',
                {
                    'coachID': $('#coachID').val(),
                    'dateFrom': $('#dateFrom').val(),
                    'dateTo': $('#dateTo').val(),
                    'branchID': $('#branchID').val()
                }, function () {
                    loadingCount--;
                    if (loadingCount <= 0)
                        hideLoading();
                });

            $('#registerLesson').load('<%= Url.Action("ListRegisterLesson","Report") %>',
                {
                    'coachID': $('#coachID').val(),
                    'dateFrom': $('#dateFrom').val(),
                    'dateTo': $('#dateTo').val(),
                    'branchID': $('#branchID').val()
                }, function () {
                    loadingCount--;
                    if (loadingCount <= 0)
                        hideLoading();
                });
        }

        function showAttendanceAchievement(coachID) {
            $.post('<%= Url.Action("ListLessonAttendanceModal","Report") %>', {
                'coachID': coachID,
                'dateFrom': $('#dateFrom').val(),
                'dateTo': $('#dateTo').val(),
                'branchID': $('#branchID').val()
            }, function (data) {
                $(data).appendTo($('#content'));
            });
        }

        function showLessonTuitionInstallment(coachID) {
            $.post('<%= Url.Action("ListRegisterLessonModal","Report") %>', {
                'coachID': coachID,
                'dateFrom': $('#dateFrom').val(),
                'dateTo': $('#dateTo').val(),
                'branchID': $('#branchID').val()
            }, function (data) {
                $(data).appendTo($('#content'));
            });
        }

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
