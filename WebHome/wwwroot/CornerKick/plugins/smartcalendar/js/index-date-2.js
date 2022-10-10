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
	Date of Birth all Future Date Disabled (Style-1 - Format: dd MM, yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth").datepicker({
		format: "dd MM, yyyy",
		endDate: "0d",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Date of Birth all Future Date Disabled (Style-2 - Format: dd M, yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth2").datepicker({
		format: "dd M, yyyy",
		endDate: "0d",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Date of Birth all Future Date Disabled (Style-3 - Format: MM dd, yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth3").datepicker({
		format: "MM dd, yyyy",
		endDate: "0d",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Date of Birth all Future Date Disabled (Style-4 - Format: M dd, yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth4").datepicker({
		format: "M dd, yyyy",
		endDate: "0d",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Any Date Select Past Present Future (Style-5 - Format: mm-dd-yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth5").datepicker({
		format: "mm-dd-yyyy",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Any Date Select Past Present Future (Style-6 - Format: dd-mm-yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth6").datepicker({
		format: "dd-mm-yyyy",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	All Past Date Disabled (Style-7 - Format: mm/dd/yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth7").datepicker({
		format: "mm/dd/yyyy",
		startDate: "0d",
		startView: 2,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	All Past Date Disabled (Style-8 - Format: dd/mm/yyyy)
|--------------------------------------------------------------------------
*/
	$("#dateOfBirth8").datepicker({
		format: "dd/mm/yyyy",
		startDate: "0d",
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