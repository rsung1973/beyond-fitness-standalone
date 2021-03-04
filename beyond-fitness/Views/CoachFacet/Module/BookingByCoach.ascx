<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="新增行事曆" class="bg-color-darken">
    <div class="row padding-10">
        <ul class="nav nav-tabs">
            <%--<li>
                <a href="#bookingclass_tab" data-toggle="tab">預約課程</a>
            </li>--%>
            <li class="active">
                <a href="#selfevent_tab" data-toggle="tab">個人行程</a>
            </li>
        </ul>
        <div class="tab-content padding-top-10">
            <%--<div class="tab-pane fade" id="bookingclass_tab">
                <form class="smart-form" id="bookingForm" autofocus>
                    <fieldset>
                        <div class="row">
                            <section class="col col-4">
                                <label class="label">請選擇課程類別</label>
                                <label class="select">
                                    <select id="lessonType">
                                        <option value="0">P.T session</option>
                                        <option value="1">P.I session</option>
                                        <option value="3">體驗課程</option>
                                        <option value="5">點數兌換課程</option>
                                        <option value="2">教練P.I</option>
                                        <option value="4">企業方案</option>
                                        <option value="6">員工福利課程</option>
                                    </select>
                                    <script>
                                        $('#lessonType').on('change', function (evt) {
                                            console.log('debug...');
                                            var lessonType = $(this).val();

                                            $('input[name="userName"]').val('');
                                            $('#attendeeSelector').empty();
                                            var $branch = $('select[name="BranchID"]');
                                            $branch.find("option:contains('其他')").remove();

                                            switch (lessonType) {
                                                case '0':
                                                    $('.part0').css('display', 'block');
                                                    break;
                                                case '1':
                                                    $('.part0').css('display', 'block');
                                                    break;
                                                case '2':
                                                    $('.part0').css('display', 'none');
                                                    $branch.append($('<option value="-1">其他</option>'));
                                                    break;
                                                case '3':
                                                case '4':
                                                    $('.part0').css('display', 'block');
                                                    break;
                                                case '5':
                                                    $('.part0').css('display', 'none');
                                                    showLoading();
                                                    $('#attendeeSelector').load('<%= Url.Action("BonusLessonSelector","CoachFacet") %>', {}, function (data) {
                                                        hideLoading();
                                                    });
                                                    break;
                                                case '6':
                                                    $('.part0').css('display', 'none');
                                                    showLoading();
                                                    $('#attendeeSelector').load('<%= Url.Action("GiftLessonSelector","CoachFacet") %>', {}, function (data) {
                                                        hideLoading();
                                                    });
                                                    break;

                                            }
                                        });
                                        $(function () {

                                        });
                                    </script>
                                    <i class="icon-append far fa-clock"></i>
                                </label>
                            </section>
                            <section class="col col-4">
                                <label class="label">請選擇開始時間</label>
                                <label class="input">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" name="ClassDate" id="classDate" class="form-control input date input_time" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" value="<%= String.Format("{0:yyyy/MM/dd HH:mm}",_viewModel.LessonDate) %>" placeholder="請輸入上課開始時間" />
                                </label>
                            </section>
                            <section class="col col-4">
                                <label class="label">請選擇上課地點</label>
                                <label class="select">
                                    <select name="BranchID">
                                        <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID); %>
                                    </select>
                                    <i class="icon-append far fa-keyboard"></i>
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset class="part0">
                        <label class="label">依學員姓名(暱稱)查詢</label>
                        <div class="row">
                            <section class="col col-10">
                                <label class="input">
                                    <i class="icon-prepend fa fa-search"></i>
                                    <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名(暱稱)" />
                                    <script>
                                        $('#btnAttendeeQuery').on('click', function (evt) {
                                            var userName = $('input[name="userName"]').val();
                                            console.log('debug...');

                                            clearErrors();
                                            showLoading();
                                            if ($('#lessonType').val() == '0') {
                                                $('#attendeeSelector').load('<%= Url.Action("AttendeeSelector","CoachFacet") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            } else if ($('#lessonType').val() == '1') {
                                                $('#attendeeSelector').load('<%= Url.Action("VipSelector","CoachFacet") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            } else if ($('#lessonType').val() == '3') {
                                                $('#attendeeSelector').load('<%= Url.Action("TrialLearnerSelector","CoachFacet") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            } else if ($('#lessonType').val() == '4') {
                                                $('#attendeeSelector').load('<%= Url.Action("AttendeeSelector","EnterpriseProgram") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            } else if ($('#lessonType').val() == '5') {
                                                $('#attendeeSelector').load('<%= Url.Action("BonusLessonSelector","CoachFacet") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            } else if ($('#lessonType').val() == '6') {
                                                $('#attendeeSelector').load('<%= Url.Action("GiftLessonSelector","CoachFacet") %>', { 'userName': userName }, function (data) {
                                                    hideLoading();
                                                });
                                            }
                                        });
                                    </script>
                                </label>
                            </section>
                            <section class="col col-2">
                                <button id="btnAttendeeQuery" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="row">
                            <section id="attendeeSelector" class="col col-12">
                            </section>
                        </div>
                    </fieldset>
                    <input type="hidden" name="CoachID" value="<%= _viewModel.CoachID %>" />
                </form>
                <script>
                    $(function () {
                        $global.commitBooking = function (callback) {
                            var lessonType = $('#lessonType').val();
                            clearErrors();
                            switch (lessonType) {
                                case '0':
                                case '6':
                                    $.post('<%= Url.Action("CommitBookingByCoach","Lessons") %>', $('#bookingForm').serialize(), function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;
                                case '1':
                                    $.post('<%= Url.Action("CommitBookingByCoach","Lessons") %>', $('#bookingForm').serialize() + '&trainingBySelf=1', function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;
                                case '2':
                                    $.post('<%= Url.Action("CommitBookingSelfTraining","Lessons") %>', $('#bookingForm').serialize(), function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;
                                case '3':
                                    $.post('<%= Url.Action("CommitTrialLesson","CoachFacet") %>', $('#bookingForm').serialize(), function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;
                                case '4':
                                    $.post('<%= Url.Action("CommitBookingByCoach","EnterpriseProgram") %>', $('#bookingForm').serialize(), function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;
                                case '5':
                                    $.post('<%= Url.Action("CommitBonusLesson","Lessons") %>', $('#bookingForm').serialize(), function (data) {
                                        if (data.result) {
                                            smartAlert(data.message);
                                            callback();
                                        } else {
                                            $(data).appendTo('body').remove();
                                        }
                                    });
                                    break;

                            }
                        };

                        $global.closeDialog = function () {
                            $('#<%= _dialogID %>').dialog('close');
                        };

                    });

                    $('.input_time').datetimepicker({
                        language: 'zh-TW',
                        weekStart: 0,
                        todayBtn: 1,
                        clearBtn: 1,
                        autoclose: 1,
                        todayHighlight: 1,
                        startView: 1,
                        minView: 0,
                        minuteStep: 30,
                        forceParse: 0,
                        startDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>'
                    });
                </script>
            </div>--%>
            <div class="tab-pane fade in active" id="selfevent_tab">
                <%  Html.RenderAction("EditCoachEvent","CoachFacet",new { UID = _viewModel.CoachID,StartDate = _viewModel.LessonDate,EndDate = _viewModel.LessonDate }); %>
            </div>
        </div>
    </div>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    FullCalendarViewModel _viewModel;
    UserProfile _profile;
    String _dialogID = "bookingDialog" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (FullCalendarViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }

</script>
