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
                <i class="fa fa-search"></i>
            </span>
        </span>
        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>課程管理></li>
            <li>我的學員</li>
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
        <i class="fa-fw fa fa-search"></i>課程管理
                     <span>>  
                     我的學員
                     </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <script>
        $(function () {
            <%--            $('#dateFrom').rules('add', {
                'required': true,
                'date': true,
                'messages': {
                    'required': "請輸入查詢起月"
                }
            });             --%>
            $global.listLessons = function (start, end, lessonDate, category) {
                if (lessonDate && lessonDate != '') {
                    $('#lessonInterval').text(lessonDate);
                } else {
                    $('#lessonInterval').text(start + ' ~ ' + end);
                }
                $.post('<%= Url.Action("QueryLessonList","Lessons") %>', { 'start': start, 'end': end, 'lessonDate': lessonDate, 'category': category }, function (data) {
                    $('#lessonList').html(data);
                })
            };
        });

    </script>

                <div class="row">
                    <article class="col-sm-12 col-md-6 col-lg-6">
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
                                <span class="widget-icon"> <i class="fa fa-search txt-color-white"></i> </span>
                                <h2> 查詢條件 </h2>
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
                                    <form id="pageForm" action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/QueryVip") %>" class="smart-form" method="post">
                                        <fieldset>
                                            <div class="row">
                                                <section class="col col-6">
                                                    <label class="input"> <i class="icon-append fa fa-user"></i>
                                                        <input type="text" class="input-lg" name="userName" id="userName" placeholder="請輸入學員姓名" value="<%= _viewModel.UserName %>" />
                                                    </label>
                                                    <%--<script>
                                                        $('#userName').on('change', function (evt) {
                                                            if ($('#userName').val()!='') {
                                                                $('select[name="lessonStatus"] option:eq(0)').prop('disabled', false);
                                                                $('select[name="lessonStatus"] option:eq(1)').prop('disabled', false);
                                                            }
                                                        });
                                                    </script>--%>
                                                </section>
                                                <section class="col col-6">
                                                    <label class="select">
                                                        <%  ViewBag.SelectIndication = "<option value=''>全部</option>";
                                                            Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "coachID", Name = "coachID",DefaultValue = _viewModel.CoachID }); %>
                                                        <i class="icon-append far fa-keyboard"></i>
                                                    </label>
                                                    <%--<script>
                                                        $('#coachID').on('change', function (evt) {
                                                            if ($(this).val() == '' && $('#userName').val()=='') {
                                                                $('select[name="lessonStatus"] option:eq(0)').prop('disabled', true);
                                                                $('select[name="lessonStatus"] option:eq(1)').prop('disabled', true);
                                                                $('select[name="lessonStatus"]').val('1');
                                                            } else {
                                                                $('select[name="lessonStatus"] option:eq(0)').prop('disabled', false);
                                                                $('select[name="lessonStatus"] option:eq(1)').prop('disabled', false);
                                                            }
                                                        });
                                                    </script>--%>
                                                </section>
                                            </div>
                                            <div class="row">
                                                <section class="col col-6">
                                                    <label class="input input-group">
                                                        <i class="icon-append far fa-calendar-alt"></i>
                                                        <input type="text" name="dateFrom" id="dateFrom" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢起日" value="<%= _viewModel.HasQuery==true ? String.Format("{0:yyyy/MM/dd}", _viewModel.DateFrom) : null %>" />
                                                    </label>
                                                </section>
                                                <section class="col col-6">
                                                    <%--<label class="select">
                                                        <select class="input-lg" name="monthInterval" id="monthInterval">
                                                            <option value="1">查詢區間1個月</option>
                                                            <option value="2">查詢區間2個月</option>
                                                        </select>
                                                        <i></i>
                                                    </label>--%>
                                                    <label class="input input-group">
                                                        <i class="icon-append far fa-calendar-alt"></i>
                                                        <input type="text" name="dateTo" id="dateTo" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢迄日" value="<%= _viewModel.HasQuery==true ? String.Format("{0:yyyy/MM/dd}", _viewModel.DateTo) : null %>" />
                                                    </label>
                                                </section>
                                            </div>
                                            <div class="row">
                                                <section class="col col-6">
                                                    <label class="select">
                                                        <select name="lessonStatus" class="input-lg">
                                                            <%--                                                            <option value="0" <%= !_viewModel.CoachID.HasValue && String.IsNullOrEmpty(_viewModel.UserName) ? "disabled" : null %>>全部狀態</option>
                                                            <option value="2" <%= !_viewModel.CoachID.HasValue && String.IsNullOrEmpty(_viewModel.UserName) ? "disabled" : null %>>教練已完成上課</option>
                                                            <option value="1" <%= !_viewModel.CoachID.HasValue && String.IsNullOrEmpty(_viewModel.UserName) ? "selected" : null %>>教練未完成上課</option>--%>
                                                            <option value="0">全部狀態</option>
                                                            <option value="2">教練已完成上課</option>
                                                            <option value="1">教練未完成上課</option>
                                                            <option value="3">學員尚未打卡</option>
                                                            <option value="4">P.I session</option>
                                                            <option value="5">S.T session</option>
                                                        </select>
                                                        <i class="icon-append far fa-keyboard"></i>
                                                    </label>
                                                </section>
                                            </div>
                                        </fieldset>
                                        <footer>
                                            <input type="hidden" name="branchID" />
                                            <button type="submit" name="submit" class="btn btn-primary">
                                                送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
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
                    <article class="col-sm-12 col-md-6 col-lg-6">
                        <!-- new widget -->
                        <div class="jarviswidget jarviswidget-color-darken" id="wid-id-3" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">

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
                                <span class="widget-icon"><i class="fa fa-calendar-alt"></i></span>
                                <h2>地點：<%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreText.ascx", _viewModel.BranchID); %> </h2>
                                <div class="widget-toolbar">
                                    <a href="<%= Url.Action("BookingTrialLesson","Lessons") %>" class="btn bg-color-pink"><i class="fa fa-fw fa-magic"></i> 預約體驗課程</a>
                                    <a class="btn btn-primary" href="<%= VirtualPathUtility.ToAbsolute("~/Lessons/BookingByCoach") %>"><i class="fa fa-fw fa-bookmark"></i> 預約上課時間</a>
                                    <a class="btn bg-color-teal" onclick="bookingSelfTraining();"><i class="fa fa-fw fa-university"></i> 預約教練P.I</a>
                                    <div class="btn-group">
                                        <button class="btn dropdown-toggle btn-xs btn-warning" data-toggle="dropdown">
                                            上課地點 <i class="fa fa-caret-down"></i>
                                        </button>
                                        <ul class="dropdown-menu pull-right">
                                            <li>
                                                <a onclick="sendQuery(null);">全部</a>
                                            </li>
                                            <%  foreach (var b in models.GetTable<BranchStore>())
                                                { %>
                                            <li>
                                                <a onclick="sendQuery(<%= b.BranchID %>);">小巨蛋</a>
                                            </li>
                                            <%  } %>
                                        </ul>
                                    </div>
                                </div>
                            </header>

                            <!-- widget div-->
                            <div>
                                <!-- widget edit box -->
                                <div class="jarviswidget-editbox bg-color-darken">
                                </div>
                                <!-- end widget edit box -->

                                <div class="widget-body bg-color-darken txt-color-white no-padding">
                                    <!-- content goes here -->
                                    <div class="widget-body-toolbar">

                                        <div id="calendar-buttons">

                                            <div class="btn-group">
                                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-prev"><i class="fa fa-chevron-left"></i></a>
                                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-next"><i class="fa fa-chevron-right"></i></a>
                                            </div>
                                        </div>
                                    </div>
                                    <%  ViewBag.ByQuery = true;
                                        Html.RenderPartial("~/Views/Lessons/LessonsCalendar.ascx",
                                            _viewModel.HasQuery==true 
                                            ? _lessonDate.HasValue 
                                                ? _lessonDate.Value 
                                                : _viewModel.DateFrom 
                                            : DateTime.Today); %>

                                    <!-- end content -->
                                </div>

                            </div>
                            <!-- end widget div -->
                        </div>
                        <!-- end widget -->

                    </article>
                </div>
                <!-- row -->
                <div class="row">
                    <article class="col-sm-12">
                        <!-- new widget -->
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
                                <span class="widget-icon"><i class="fa fa-rss text-success"></i></span>
                                <h2 id="lessonInterval"><%= _viewModel.HasQuery==true 
                                            ? _lessonDate.HasValue 
                                                ? _lessonDate.Value.ToString("yyyy/MM/dd") 
                                                :  String.Format("{0:yyyy/MM/dd} - {1:yyyy/MM/dd}",_viewModel.DateFrom,_viewModel.DateTo) 
                                            : null %></h2>

                                <ul class="nav nav-tabs pull-right in" id="myTab">
                                    <li class="active">
                                        <a data-toggle="tab" href="#s1"><i class="fa fa-list"></i><span>列表</span></a>
                                    </li>

                                    <li>
                                        <a data-toggle="tab" href="#s2"><i class="fa fa-bar-chart"></i><span>統計表</span></a>
                                    </li>
                                </ul>

                            </header>

                            <!-- widget div-->
                            <div class="no-padding" id="lessonList">
                                <%--<%  Html.RenderPartial("~/Views/Lessons/LessonTime/Module/QueryLessonList.ascx"); %>--%>
                            </div>
                            <!-- end widget div -->
                        </div>
                        <!-- end widget -->

                    </article>
                </div>

    <!-- Start Content -->
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
    <!-- End content -->

    <script>
    function revokeBooking(lessonID) {
        confirmIt({ title: '取消預約', message: '確定取消預約此課程?' }, function (evt) {
            $('#loading').css('display', 'table');
            $('<form method="post"/>')
                .appendTo($('body'))
                .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Lessons/RevokeBooking") %>')
                .append($('<input type="hidden" name="lessonID"/>').val(lessonID))
                .submit();
        });
    }

    function attendLesson(arg)
    {
        startLoading();
        var $form = $('<form method="post"/>')
            .appendTo($('body'))
            .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Attendance/TrainingPlan") %>');
        for (var key in arg) {
            $('<input type="hidden"/>')
            .prop('name', key).prop('value', arg[key]).appendTo($form);
        }
        $form.submit();
    }

        function sendQuery(branchID) {
            $('input[name="branchID"]').val(branchID);
            $('button[name="submit"]').click();
        }

        $(function () {

            $global.reload = function () {
                $('button[name="submit"]').click();
            };

            //showLoading();
        });
    </script>


</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    DailyBookingQueryViewModel _viewModel;
    DateTime? _lessonDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _lessonDate = (DateTime?)ViewBag.LessonDate;
    }

</script>
