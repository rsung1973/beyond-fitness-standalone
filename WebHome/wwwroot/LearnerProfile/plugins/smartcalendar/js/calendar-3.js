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
	Book Restaurant Table (setDaysOfWeekDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime").datetimepicker({
		format: "dd MM yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (day view)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime2").datetimepicker({
		format: "dd M, yyyy - HH:ii P",
		showMeridian: true,
		startView: 1,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (12-month overview and setDaysOfWeekDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime3").datetimepicker({
		format: "mm-dd-yyyy - HH:ii P",
		showMeridian: true,
		startView: 3,
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (10-year overview)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime4").datetimepicker({
		format: "dd-mm-yyyy - HH:ii P",
		showMeridian: true,
		startView: 4,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (timezone and setDaysOfWeekDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime5").datetimepicker({
		format: "yyyy-dd-mm - HH:ii P Z",
		showMeridian: true,
		timezone: "GMT +10",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setStartDate)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime6").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: '2020-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (select back Date)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime7").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: '0d',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setEndDate)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime8").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: dt,
		endDate: '2028-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (setHoursDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime9").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
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