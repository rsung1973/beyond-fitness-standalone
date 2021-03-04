<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div>
    <div class="widget-body bg-color-darken txt-color-white no-padding">
        <!-- content goes here -->
        <div class="widget-body-toolbar">
            <div id="calendar<%= _suffix %>-buttons" class="calendar-buttons">
                <div class="btn-group">
                    <a href="javascript:void(0)" class="btn btn-default today">今日</a>
                    <a href="javascript:void(0)" class="btn btn-default td">天</a>
                    <a href="javascript:void(0)" class="btn btn-default ag">週</a>
                    <a href="javascript:void(0)" class="btn btn-default mt">月</a>
                </div>
                <div class="btn-group">
                    <a href="javascript:void(0)" class="btn btn-default btn-prev"><i class="fa fa-chevron-left fa-lg"></i></a>
                    <a href="javascript:void(0)" class="btn btn-default btn-next"><i class="fa fa-chevron-right fa-lg"></i></a>
                </div>
            </div>
        </div>
        <div id="calendar<%= _suffix %>" class="calendar"></div>
        <!-- end content -->
    </div>
</div>

<script>

    $(function () {

        function renderFullCalendar(defaultDate, defaultView) {
            if ($("#calendar<%= _suffix %>").length) {

                showLoading();

                var date = new Date();
                var d = date.getDate();
                var m = date.getMonth();
                var y = date.getFullYear();

                var calendar = $('#calendar<%= _suffix %>').fullCalendar({
                    lang: 'zh-TW',
                    draggable: true,
                    selectable: false,
                    selectHelper: true,
                    unselectAuto: false,
                    disableResizing: false,
                    allDaySlot: true,
                    allDayText: '本日總計',
                    editable: false,
                    height: "auto",
                    defaultView: defaultView,
                    defaultDate: defaultDate,
                    eventLimit: 4,

                    businessHours: {
                        start: '08:00',
                        end: '22:00',
                        dow: [1, 2, 3, 4, 5, 6, 0]
                    },
                    minTime: "07:00:00",
                    maxTime: "23:00:00",
                    header: {
                        left: 'title', //,today
                        //left: 'prev, next, today',
                        //right: 'month, agendaWeek, agenDay' //month, agendaDay,
                    },
                    events: function (start, end, timezone, callback) {

                        $global.viewModel.DateFrom = start.format('YYYY-MM-DD');
                        $global.viewModel.DateTo = end.format('YYYY-MM-DD');
                        $global.viewModel.DefaultView = defaultView;
                        if ($global.viewModel.QueryType == 'attendee') {
                            $.post('<%= Url.Action("VipLessonEvents","CoachFacet") %>', $global.viewModel, function (data) {
                                callback(data);
                            });
                        } else {
                            $.post('<%= Url.Action("CalendarEvents","CoachFacet") %>', $global.viewModel, function (data) {
                                callback(data);
                            });
                        }
                    },

                    eventRender: function (event, element, icon) {
                        if (!event.description == "") {
                            element.find('.fc-title').append("<br/><span class='ultra-light'>" + event.description + "</span>");
                        }
                        if (!event.icon == "") {
                            element.find('.fc-title').append("<i class='air air-top-right fa " + event.icon + " '></i>");
                        }
                    },

                    eventClick: function (calEvent, jsEvent, view) {
                        if (calEvent._allDay == true) {
                            if (calEvent.id.indexOf('my')==0) {
                                showLoading();
                                $.post('<%= Url.Action("UserEventDialog","CoachFacet") %>', { 'eventID': calEvent.lessonID, 'uid': $global.viewModel.CoachID }, function (data) {
                                    hideLoading();
                                    if (data) {
                                        var $dialog = $(data);
                                        $dialog.appendTo('body');
                                    }
                                });
                            }
                            else {
                                $global.viewModel.Category = calEvent.id;
                                $global.viewModel.LessonDate = calEvent.start.format('YYYY-MM-DD');
                                $.post('<%= Url.Action("DailyBookingList","CoachFacet") %>', $global.viewModel, function (data) {
                                    if (data) {
                                        var $dialog = $(data);
                                        $dialog.dialog({
                                            width: "auto",
                                            height: "auto",
                                            resizable: true,
                                            modal: true,
                                            closeText: "關閉",
                                            title: "<h4 class='modal-title'><i class='icon-append fa fa-list-ol'></i> " + $global.viewModel.LessonDate + "</h4>",
                                            close: function (evt, ui) {
                                                $dialog.remove();
                                            }
                                        });
                                    }
                                });
                            }
                        } else {
                            if (calEvent.id.indexOf('my') == 0) {
                                showLoading();
                                $.post('<%= Url.Action("UserEventDialog","CoachFacet") %>', { 'eventID': calEvent.lessonID, 'uid': $global.viewModel.CoachID }, function (data) {
                                    hideLoading();
                                    if (data) {
                                        var $dialog = $(data);
                                        $dialog.appendTo('body');
                                    }
                                });
                            } else {
                                $.post('<%= Url.Action("BookingEventDialog","CoachFacet") %>', { 'lessonID': calEvent.lessonID }, function (data) {
                                    if (data) {
                                        var $dialog = $(data);
                                        $dialog.appendTo('body');
                                    }
                                });
                            }
                        }
                    },

                    dayClick: function (date, allDay, jsEvent, view) {

                        if (!$global.viewModel.CoachID) {
                            smartAlert("請先選擇體能顧問!!");
                            return;
                        }

                        $global.viewModel.LessonDate = date.format('YYYY-MM-DD HH:mm:ss');
                        $global.viewModel.DefaultDate = $global.viewModel.LessonDate;
                        $.post('<%= Url.Action("BookingByCoach","CoachFacet") %>',$global.viewModel,function(data){
                            if(data) {
                                var $dialog = $(data);
                                $dialog.dialog({
                                        width: "80%",
                                        height: "auto",
                                        resizable : true,
                                        modal : true,
                                        closeText: "關閉",
                                        title: "<div class='modal-title'><h4><i class='fa fa-warning'></i> 新增行事曆</h4></div>",
                                        buttons : [{
                                            html : "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                                            "class" : "btn btn-primary",
                                            click: function () {
                                                var f = function () {
                                                    $global.renderFullCalendar();
                                                    $dialog.dialog("close");
                                                };
                                                if ($('#bookingclass_tab.in.active').length > 0) {
                                                    $global.commitBooking(f);
                                                } else {
                                                    $global.commitCoachEvent(f);
                                                }
                                            }
                                        }],
                                        close: function (evt, ui) {
                                                        $dialog.remove();
                                                }
                                });
                            }
                        });
                    },
                    eventDrop: function (calEvent, delta, revertFunc, jsEvent, ui, view) {

                        showLoading();
                        if (calEvent.id.indexOf('my') == 0) {
                            $.post('<%= Url.Action("UpdateCoachEvent","CoachFacet") %>',
                                    {
                                        'eventID': calEvent.lessonID,
                                        'startDate': calEvent.start.format('YYYY-MM-DD HH:mm:ss'),
                                        'endDate': calEvent.end.format('YYYY-MM-DD HH:mm:ss'),
                                        'uid': $global.viewModel.CoachID
                                    }, function (data) {
                                        hideLoading();
                                        if (data.result) {
                                            smartAlert(data.message);
                                        } else {
                                            revertFunc();
                                            var $dialog = $(data);
                                            $dialog.appendTo('body').remove();
                                        }
                                    });
                        } else {
                            hideLoading();
                            revertFunc();
                            <%--$.post('<%= Url.Action("UpdateBookingByCoach","CoachFacet") %>',
                                {
                                    'lessonID': calEvent.lessonID,
                                    'classTimeStart': calEvent.start.format('YYYY-MM-DD HH:mm:ss'),
                                    'classTimeEnd': calEvent.end.format('YYYY-MM-DD HH:mm:ss'),
                                }, function (data) {
                                    hideLoading();
                                    if (data.result) {
                                        smartAlert(data.message);
                                    } else {
                                        revertFunc();
                                        var $dialog = $(data);
                                        $dialog.appendTo('body').remove();
                                    }
                                });--%>
                        }
                    },
                    eventResize: function (calEvent, delta, revertFunc, jsEvent, ui, view) {

                        showLoading();
                        if (calEvent.id.indexOf('my') == 0) {
                            $.post('<%= Url.Action("UpdateCoachEvent","CoachFacet") %>',
                                {
                                    'eventID': calEvent.lessonID,
                                    'startDate': calEvent.start.format('YYYY-MM-DD HH:mm:ss'),
                                    'endDate': calEvent.end.format('YYYY-MM-DD HH:mm:ss'),
                                    'uid': $global.viewModel.CoachID
                                }, function (data) {
                                    hideLoading();
                                    if (data.result) {
                                        smartAlert(data.message);
                                    } else {
                                        revertFunc();
                                        var $dialog = $(data);
                                        $dialog.appendTo('body').remove();
                                    }
                                });
                        } else {
                            hideLoading();
                            revertFunc();
<%--                            $.post('<%= Url.Action("UpdateBookingByCoach","CoachFacet") %>',
                                {
                                    'lessonID': calEvent.lessonID,
                                    'classTimeStart': calEvent.start.format('YYYY-MM-DD HH:mm:ss'),
                                    'classTimeEnd': calEvent.end.format('YYYY-MM-DD HH:mm:ss'),
                                }, function (data) {
                                    hideLoading();
                                    if (data.result) {
                                        smartAlert(data.message);
                                    } else {
                                        revertFunc();
                                        var $dialog = $(data);
                                        $dialog.appendTo('body').remove();
                                    }
                                });--%>
                        }
                    },
                    windowResize: function (event, ui) {
                        $('#calendar<%= _suffix %>').fullCalendar('render');
                    },
                    eventAfterAllRender: function (view) {
                        hideLoading();
                    },
                });

            }

            /* hide default buttons */
            $('.fc-toolbar .fc-right, .fc-toolbar .fc-center').hide();

        }

        $global.renderFullCalendar = function() {
            $('#calendar<%= _suffix %>').fullCalendar('destroy');
            renderFullCalendar($global.viewModel.DefaultDate, $global.viewModel.DefaultView);
        };


        $global.onReady.push(function() {
                $global.viewModel.DefaultDate = '<%= _viewModel.DefaultDate.HasValue ? _viewModel.DefaultDate.Value.ToString("yyyy-MM-dd") : DateTime.Today.ToString("yyyy-MM-dd") %>';
                $global.viewModel.DefaultView = '<%= _viewModel.DefaultView %>';
            renderFullCalendar($global.viewModel.DefaultDate, $global.viewModel.DefaultView);
            });

        // calendar prev
        $('#calendar<%= _suffix %>-buttons .btn-prev').click(function () {
            $('.fc-prev-button').click();
            showLoading();
            return false;
        });

        // calendar next
        $('#calendar<%= _suffix %>-buttons .btn-next').click(function () {
            $('.fc-next-button').click();
            showLoading();
            return false;
        });

        // calendar today
        $('#calendar<%= _suffix %>-buttons .today').click(function () {
            $('.fc-today-button').click();
            return false;
        });

        // calendar month
        $('#calendar<%= _suffix %>-buttons .mt').click(function () {
            <%--var v = $('#calendar<%= _suffix %>').fullCalendar('getView');--%>
            $global.viewModel.DefaultDate = $('#calendar<%= _suffix %>').fullCalendar('getDate').format('YYYY-MM-DD');
            $('#calendar<%= _suffix %>').fullCalendar('destroy');
            renderFullCalendar($global.viewModel.DefaultDate, 'month');
        });

        // calendar agenda week
        $('#calendar<%= _suffix %>-buttons .ag').click(function () {
            $global.viewModel.DefaultDate = $('#calendar<%= _suffix %>').fullCalendar('getDate').format('YYYY-MM-DD');
            $('#calendar<%= _suffix %>').fullCalendar('destroy');
            renderFullCalendar($global.viewModel.DefaultDate, 'agendaWeek');

        });

        // calendar agenda day
        $('#calendar<%= _suffix %>-buttons .td').click(function () {
            $global.viewModel.DefaultDate = $('#calendar<%= _suffix %>').fullCalendar('getDate').format('YYYY-MM-DD');
            $('#calendar<%= _suffix %>').fullCalendar('destroy');
            renderFullCalendar($global.viewModel.DefaultDate, 'agendaDay');
        });

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    String _suffix = DateTime.Now.Ticks.ToString();
    FullCalendarViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (FullCalendarViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();

    }

</script>
