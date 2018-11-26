<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="row clearfix">
    <div class="col-md-11 col-lg-12 col-9">
    </div>
    <div class="col-md-11 col-lg-12 col-3">
        <button class="btn btn-default hidden-lg-up m-t-0 float-right" data-toggle="collapse" data-target="#open-events" aria-expanded="false" aria-controls="collapseExample"><i class="zmdi zmdi-chevron-down"></i></button>
    </div>
</div>
<div class="collapse-xs collapse-sm collapse" id="open-events">
    <button id="btnLoadEvents" class="btn btn-darkteal btn-round waves-effect float-right">載入更多 ...</button>
</div>
<script>
    function loadEvents(dateFrom, dateTo) {
        showLoading();
        $.post('<%= Url.Action("CalendarEventItems", "ConsoleHome", new { KeyID = _model.UID.EncryptKey() }) %>', { 'dateFrom': dateFrom, 'dateTo': dateTo }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#btnLoadEvents').before(data);
            }
        });
    }

    function deleteLesson(keyID) {
        deleteData(function (onSuccess) {
            showLoading();
            $.post('<%= Url.Action("RevokeBooking", "ConsoleEvent") %>', { 'keyID': keyID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        if ($global.target) {
                            $global.target.remove();
                        } else {
                            refreshEvents();
                        }
                        refetchCalendarEvents();
                        $global.closeAllModal();
                        onSuccess();
                    } else {
                        swal(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        });
    }

    function deleteUserEvent(keyID) {
        deleteData(function (onSuccess) {
            showLoading();
            $.post('<%= Url.Action("RevokeCoachEvent", "ConsoleEvent") %>', { 'keyID': keyID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        if ($global.target && $global.target.length > 0) {
                            $global.target.remove();
                        } else {
                            refreshEvents();
                        }
                        refetchCalendarEvents();
                        $global.closeAllModal();
                        onSuccess();
                    } else {
                        swal(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        });
    }

    function bookingCustomEvent(args) {
        showLoading();
        $.post('<%= Url.Action("BookingCustomEvent", "ConsoleEvent") %>', args, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                swal(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    var refreshEvents;

    $(function () {
        var eventStart = moment('<%= $"{startDate:yyyy-MM-dd}" %>');
        var dateFrom = moment('<%= $"{startDate:yyyy-MM-dd}" %>');
        var dateTo = moment('<%= $"{startDate:yyyy-MM-dd}" %>');

        refreshEvents = function () {
            $('#open-events .event-name').remove();
            $('#open-events hr').remove();
            loadEvents(eventStart.format('YYYY-MM-DD'), dateTo.format('YYYY-MM-DD'));
<%--            dateFrom = moment('<%= $"{startDate:yyyy-MM-dd}" %>');
            dateTo = moment('<%= $"{startDate:yyyy-MM-dd}" %>');
            loadEvents(dateFrom.format('YYYY-MM-DD'), dateTo.format('YYYY-MM-DD'));
            dateFrom.add(1, 'd');
            dateTo.add(1, 'd');--%>
        };

        loadEvents(dateFrom.format('YYYY-MM-DD'), dateTo.format('YYYY-MM-DD'));
        dateFrom.add(1, 'd');
        dateTo.add(1, 'd');

        $('#btnLoadEvents').click(function () {
            loadEvents(dateFrom.format('YYYY-MM-DD'), dateTo.format('YYYY-MM-DD'));
            dateFrom.add(1, 'd');
            dateTo.add(1, 'd');
        });
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    DateTime? startDate;
    DailyBookingQueryViewModel _viewModel;
    
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        startDate = _viewModel.DateFrom ?? DateTime.Today;
    }


</script>
