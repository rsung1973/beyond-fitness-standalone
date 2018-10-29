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


<%--<link rel='stylesheet' href='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/lib/custom/jquery-ui.min.css")  %>' />
<link href='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/fullcalendar.css")  %>' rel='stylesheet' />
<link href='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/fullcalendar.print.css")  %>' rel='stylesheet' media='print' />

<script type="text/javascript" src='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/lib/moment.min.js") %>'></script>
<script type="text/javascript" src='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/fullcalendar.min.js") %>'></script>
<script type="text/javascript" src='<%= VirtualPathUtility.ToAbsolute("~/fullcalendar-2.8.0/lang-all.js") %>'></script>--%>

<%--<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/moment/moment.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/fullcalendar/jquery.fullcalendar.min.js") %>"></script>
<script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/fullcalendar/lang-all.js") %>"></script>--%>


<div id='calendar'></div>

<script>

    $(document).ready(function () {

        var lessonDate = '<%= String.Format("{0:yyyy-MM-dd}",_lessonDate) %>';
        var category = '<%= (String)ViewBag.Category %>';

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
                defaultDate: '<%= _lessonDate.HasValue ? _lessonDate.Value.ToString("yyyy-MM-dd") : DateTime.Today.ToString("yyyy-MM-dd") %>',

                events: '<%= VirtualPathUtility.ToAbsolute(ViewBag.ByQuery==true ? "~/Lessons/QueryBookingEvents" : "~/Lessons/BookingEvents") %>',
                viewRender: function (view, element) {
                    hideLoading();
                    if ($global.listLessons) {
                        $global.listLessons(view.start.format('YYYY-MM-DD'), view.end.format('YYYY-MM-DD'), lessonDate, category);
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
                dayClick: function (calEvent, jsEvent, view) {
                    if (calEvent.start) {
                        window.location.href = '<%= VirtualPathUtility.ToAbsolute(ViewBag.ByQuery==true ? "~/Lessons/QueryVip" : "~/Account/Coach") %>' + '?lessonDate=' + calEvent.format('YYYY-MM-DD');
                    }
                },
                eventClick: function (calEvent, jsEvent, view) {
                    window.location.href = '<%= VirtualPathUtility.ToAbsolute(ViewBag.ByQuery==true ? "~/Lessons/QueryVip" : "~/Account/Coach") %>' + '?lessonDate=' + calEvent.start.format('YYYY-MM-DD') + '&category=' + calEvent.id;

                }
            });

        }

        /* hide default buttons */
        $('.fc-toolbar .fc-right, .fc-toolbar .fc-center').hide();

        // calendar prev
        $('#calendar-buttons #btn-prev').click(function () {
            showLoading();
            category = null;
            lessonDate = null;
            $('.fc-prev-button').click();
            return false;
        });

        // calendar next
        $('#calendar-buttons #btn-next').click(function () {
            showLoading();
            category = null;
            lessonDate = null;
            $('.fc-next-button').click();
            return false;
        });

        // calendar today
        $('#calendar-buttons #btn-today').click(function () {
            showLoading();
            category = null;
            lessonDate = null;
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
      
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DateTime? _lessonDate;
    IQueryable<LessonTime> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _lessonDate = (DateTime?)ViewBag.LessonDate;
        if(!_lessonDate.HasValue)
            _lessonDate = this.Model as DateTime?;
    }

</script>
