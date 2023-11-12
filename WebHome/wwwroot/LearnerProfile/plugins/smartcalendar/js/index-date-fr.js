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
	Book Hotel Room (Style-1)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date").datepicker({
		language:  'fr',
		format: "dd MM yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date").datepicker({
		language:  'fr',
		format: "dd MM yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-2)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date2").datepicker({
		language:  'fr',
		format: "M dd, yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date2").datepicker({
		language:  'fr',
		format: "M dd, yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-3 - Format: mm-dd-yyyy)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date3").datepicker({
		language:  'fr',
		format: "mm-dd-yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date3").datepicker({
		language:  'fr',
		format: "mm-dd-yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-4 - Format: dd-mm-yyyy)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date4").datepicker({
		language:  'fr',
		format: "dd-mm-yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date4").datepicker({
		language:  'fr',
		format: "dd-mm-yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-5 - Format: yyyy-dd-mm)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date5").datepicker({
		language:  'fr',
		format: "yyyy-dd-mm",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date5").datepicker({
		language:  'fr',
		format: "yyyy-dd-mm",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-6 - Format: yyyy-mm-dd)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date6").datepicker({
		language:  'fr',
		format: "yyyy-mm-dd",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date6").datepicker({
		language:  'fr',
		format: "yyyy-mm-dd",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-7 - Format: mm/dd/yyyy)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date7").datepicker({
		language:  'fr',
		format: "mm/dd/yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
	
	$("#checkout-Date7").datepicker({
		language:  'fr',
		format: "mm/dd/yyyy",
		startDate: "0d",
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-8 - Format: mm/dd/yyyy)
|--------------------------------------------------------------------------
*/
	$("#reservation-Date8").datepicker({
		language:  'fr',
		format: "mm/dd/yyyy",
		startDate: "0d",
		todayBtn: "linked",
		clearBtn: true,
		todayHighlight: true,
		autoclose: true
	});

		
})(jQuery);

/*
|--------------------------------------------------------------------------
	End
|--------------------------------------------------------------------------
*/