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
	$("#reservation-DateTime").datetimepicker({
		format: "dd MM yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime").datetimepicker({
		format: "dd MM yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-2)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime2").datetimepicker({
		format: "M dd, yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime2").datetimepicker({
		format: "M dd, yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-3 - Format: mm-dd-yyyy - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime3").datetimepicker({
		format: "mm-dd-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime3").datetimepicker({
		format: "mm-dd-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-4 - Format: dd-mm-yyyy - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime4").datetimepicker({
		format: "dd-mm-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime4").datetimepicker({
		format: "dd-mm-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-5 - Format: yyyy-dd-mm - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime5").datetimepicker({
		format: "yyyy-dd-mm - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime5").datetimepicker({
		format: "yyyy-dd-mm - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-6 - Format: yyyy-mm-dd - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime6").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime6").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Hotel Room (Style-7 - Format: yyyy-mm-dd - HH:ii - 24 hours)
|--------------------------------------------------------------------------
*/
	$("#reservation-DateTime7").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
	
	$("#checkout-DateTime7").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-1)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime").datetimepicker({
		format: "dd MM yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-2)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime2").datetimepicker({
		format: "dd M, yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-3 - Format: mm-dd-yyyy - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime3").datetimepicker({
		format: "mm-dd-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-4 - Format: dd-mm-yyyy - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime4").datetimepicker({
		format: "dd-mm-yyyy - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-5 - Format: yyyy-dd-mm - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime5").datetimepicker({
		format: "yyyy-dd-mm - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-6 - Format: yyyy-mm-dd - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime6").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		showMeridian: true,
		startDate: dt,
		todayBtn: "linked",
		todayHighlight: true,
		autoclose: true,
		minuteStep: 5
	});
		
/*
|--------------------------------------------------------------------------
	Book Restaurant Table (Style-7 - Format: yyyy-mm-dd - HH:ii)
|--------------------------------------------------------------------------
*/
	$("#reservationTable-DateTime7").datetimepicker({
		format: "yyyy-mm-dd - HH:ii P",
		startDate: dt,
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