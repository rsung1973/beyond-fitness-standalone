/*
|--------------------------------------------------------------------------
	SmartCalendar - Multipurpose Date Time Picker Calendar
|--------------------------------------------------------------------------
*/
document.addEventListener("touchstart", function() {},false);
(function ($) {
	"use strict";

	var dt = new Date();
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setDaysOfWeekDisabled) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime").datetimepicker({
		format: "dd MM yyyy - hh:ii",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});

/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setDaysOfWeekDisabled) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTimeStyle2").datetimepicker({
		format: "dd MM yyyy - HH:ii:P",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (day view) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime2").datetimepicker({
		format: "dd M, yyyy - hh:ii",
		startView: 1,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (day view) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime2Style2").datetimepicker({
		format: "dd M, yyyy - HH:ii P",
		startView: 1,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (12-month overview and setDaysOfWeekDisabled) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime3").datetimepicker({
		format: "mm-dd-yyyy - hh:ii",
		startView: 3,
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (12-month overview and setDaysOfWeekDisabled) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime3Style2").datetimepicker({
		format: "mm-dd-yyyy - HH:ii P",
		startView: 3,
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (10-year overview) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime4").datetimepicker({
		format: "dd-mm-yyyy - hh:ii",
		startView: 4,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (10-year overview) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime4Style2").datetimepicker({
		format: "dd-mm-yyyy - HH:ii P",
		startView: 4,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (timezone and setDaysOfWeekDisabled) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime5").datetimepicker({
		format: "yyyy-dd-mm - hh:ii Z",
		timezone: "GMT +10",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (timezone and setDaysOfWeekDisabled) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime5Style2").datetimepicker({
		format: "yyyy-dd-mm - HH:ii P Z",
		timezone: "GMT +10",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setStartDate) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime6").datetimepicker({
		format: "yyyy-mm-dd - hh:ii",
		startDate: '2020-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setStartDate) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime6Style2").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		startDate: '2020-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (select back Date) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime7").datetimepicker({
		format: "yyyy, M, dd - hh:ii",
		startDate: '0d',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (select back Date) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime7Style2").datetimepicker({
		format: "yyyy, M, dd - HH:ii P",
		startDate: '0d',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setEndDate) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime8").datetimepicker({
		format: "yyyy, MM, dd - hh:ii",
		startDate: dt,
		endDate: '2028-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setEndDate) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime8Style2").datetimepicker({
		format: "yyyy, MM, dd - HH:ii P",
		startDate: dt,
		endDate: '2028-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setHoursDisabled) Style-1
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime9").datetimepicker({
		format: "M, dd, yyyy - hh:ii",
		startDate: dt,
		hoursDisabled: '1,2,3,4,5,6,7,8',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setHoursDisabled) Style-2
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime9Style2").datetimepicker({
		format: "M, dd, yyyy - HH:ii P",
		startDate: dt,
		hoursDisabled: '1,2,3,4,5,6,7,8',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	
})(jQuery);

/*
|--------------------------------------------------------------------------
	End
|--------------------------------------------------------------------------
*/