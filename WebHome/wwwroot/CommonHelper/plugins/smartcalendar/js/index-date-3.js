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
	Book Resort (setDaysOfWeekDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date").datepicker({
		format: "dd MM yyyy",
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort
|--------------------------------------------------------------------------
*/
	$("#reservation-Date2").datepicker({
		format: "dd M, yyyy",
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort (12-month overview and setDaysOfWeekDisabled)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date3").datepicker({
		format: "mm-dd-yyyy",
		startView: 1,
		startDate: dt,
		daysOfWeekDisabled: [0,6],
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort (10-year overview)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date4").datepicker({
		format: "dd-mm-yyyy",
		startView: 2,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort (10-year overview)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date5").datepicker({
		format: "MM, yyyy",
		startView: 2,
		minViewMode: 1,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort (setStartDate)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date6").datepicker({
		format: "yyyy-mm-dd",
		startDate: '2020-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Resort (setEndDate)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date7").datepicker({
		format: "yyyy-mm-dd",
		startDate: dt,
		endDate: '2028-06-15',
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Project Launch date (Style 1)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date8").datepicker({
		format: "MM, yyyy",
		startDate: dt,
		startView: 2,
		minViewMode: 1,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Project Launch date (Style 2)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date9").datepicker({
		format: "dd MM, yyyy",
		startDate: dt,
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	
})(jQuery);

/*
|--------------------------------------------------------------------------
	End
|--------------------------------------------------------------------------
*/