<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>


<div id='calendar'></div>

<script>

    function renderLessonCalender() {

        if ($("#calendar").length) {
            var date = new Date();
            var d = date.getDate();
            var m = date.getMonth();
            var y = date.getFullYear();

            var calendar = $('#calendar').fullCalendar({
                lang: 'zh-TW',
                editable: false,
                draggable: false,
                selectable: false,
                selectHelper: true,
                unselectAuto: false,
                disableResizing: false,
                height: "auto",

                header: {
                    left: 'title', //,today
                    center: 'prev, next, today',
                    right: 'month, agendaWeek, agenDay' //month, agendaDay,
                },

                select: function (start, end, allDay) {
                    var title = prompt('Event Title:');
                    if (title) {
                        calendar.fullCalendar('renderEvent', {
                            title: title,
                            start: start,
                            end: end,
                            allDay: allDay
                        }, true // make the event "stick"
                        );
                    }
                    calendar.fullCalendar('unselect');
                },
                defaultDate: '<%= String.Format("{0:yyyy-MM-dd}",_lessonDate) %>',

                events: '<%= _eventsUrl %>',

                eventRender: function (event, element, icon) {
                    if (!event.description == "") {
                        element.find('.fc-title').append("<br/><span class='ultra-light'>" + event.description + "</span>");
                    }
                    if (!event.icon == "") {
                        element.find('.fc-title').append("<i class='air air-top-right fa " + event.icon + " '></i>");
                    }
                },
                viewRender: function (view, element) {
                    hideLoading();
                },
                dayClick: function (calEvent, jsEvent, view) {
                    if (calEvent && calendarEventHandler.dayClick) {
                        calendarEventHandler.dayClick(calEvent);    /*calEvent.format('YYYY-MM-DD')*/
                    }
                },
                eventClick: function (calEvent, jsEvent, view) {
                    if (calendarEventHandler.eventClick)
                        calendarEventHandler.eventClick(calEvent);  /*calEvent.start.format('YYYY-MM-DD')*/
                }
            });

            //debugger;
            /* hide default buttons */
            $('.fc-toolbar .fc-right, .fc-toolbar .fc-center').hide();

        }
      
    }

    var calendarEventHandler = {};

    function initializeCalendar() {

        // calendar prev
        $('#calendar-buttons #btn-prev').click(function () {
            showLoading();
            $('.fc-prev-button').click();
            return false;
        });

        // calendar next
        $('#calendar-buttons #btn-next').click(function () {
            showLoading();
            $('.fc-next-button').click();
            return false;
        });

        // calendar today
        $('#calendar-buttons #btn-today').click(function () {
            $('.fc-button-today').click();
            return false;
        });

        // calendar month
        $('#mt').click(function () {
            $('#calendar').fullCalendar('changeView', 'month');
        });

        // calendar agenda week
        $('#ag').click(function () {
            $('#calendar').fullCalendar('changeView', 'agendaWeek');
        });

        // calendar agenda day
        $('#td').click(function () {
            $('#calendar').fullCalendar('changeView', 'agendaDay');
        });
    }

    $(function () {
        initializeCalendar();
        renderLessonCalender();
    });

    function drawLessonCalender() {
        $('#calendar').fullCalendar('destroy');
        renderLessonCalender();
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _items;
    DateTime? _lessonDate;
    String _eventsUrl;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = (DateTime?)ViewBag.LessonDate ?? DateTime.Today;
        _eventsUrl = ViewBag.EventsUrl;
    }

</script>
