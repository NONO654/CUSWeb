//////////////////////////////Slider control///////////////////////////////////////
var url = "../programcentral/WorkCalendarUtil.jsp?mode=getWorkingHourRange";
var workingHourRange = emxUICore.getData(url);
var sTimeRange = emxUICore.parseJSON(workingHourRange);
sTimeRange = sTimeRange["workingHourRange"];
var steps = sTimeRange.split(",");

function loadTimeSlider(calendarId, relId, activeSliderId, otherSliderId, options){
	var mode;
	var min;
	var max;
	var values;
	var disabled;
    if (options !== null && options !== undefined) { 
    	mode = options["mode"];
    	min = options["min"];
    	max = options["max"];
    	values = options["values"];
    	disabled = options["disabled"];
    }
    if (min == null && min == undefined) { 
    	min = 0;
    }
    if (max == null && max == undefined) { 
    	max = 48;
    }
    if (disabled == null && disabled == undefined) { 
    	disabled = false;
    }
    if (values == null && values == undefined) { 
    	value = [18, 36];
    }

	var activeSlider = "#" + activeSliderId;
	var otherSlider = "#" + otherSliderId;
	$(activeSlider).slider({
		range: true,
		step: 1,
		min: min,
		max: max,
		values: values,
		disabled: disabled,
		slide: function (event, ui) {
			var workStart;
			var workFinish;
			var recessStart;
			var recessFinish;

			var minIndex = ui.values[0];
			var maxIndex = ui.values[1];

			var selectedHours = $( otherSlider ).slider( "option", "values" );
				if(mode === "Work Hours"){
				workStart = minIndex;
				workFinish = maxIndex;
				recessStart = selectedHours[0];
				recessFinish = selectedHours[1];
			}else if (mode === "Lunch Hours"){
				workStart = selectedHours[0];
				workFinish = selectedHours[1];
				recessStart = minIndex;
				recessFinish = maxIndex;
			}
			if( recessStart < workStart || recessFinish > workFinish){
		      	//alert("Recess hours must fall within Work hours");
				return false;
			}
			if(minIndex == maxIndex && mode === "Work Hours"){
				return false;
			}
			setSliderTooltip(activeSliderId, ui.values);
		},
		change: function( event, ui ) {
			var attrValue = this.attributes["value"].value;
			if (relId != null && relId !== undefined) {
				var minIndex = ui.values[0];
				var maxIndex = ui.values[1];
				var startTime = steps[minIndex];
				var finishTime = steps[maxIndex];
				if(mode === "Lunch Hours"){
					updateLunchHours(calendarId, relId, startTime, finishTime);	
				}else if(mode === "Work Hours"){
					updateWorkHours(calendarId, relId, startTime, finishTime);	
				}
			}
		}
	});
	values = $( activeSlider ).slider( "option", "values" );
	setSliderTooltip(activeSliderId, values);
}
function setSliderTooltip(sliderId, values){
	var sliderSelector = "#" + sliderId;
	var minIndex = values[0];
	var maxIndex = values[1];
	var diff = maxIndex - minIndex;
		if(diff == 0){
			$(sliderSelector + ' .ui-slider-handle:first').html('<div class="tooltip"><div class="tooltip-inner">' + 'No Recess' + '</div></div>');
			$(sliderSelector + ' .ui-slider-handle:last').html('');
	}else if(diff > 5){
			$(sliderSelector + ' .ui-slider-handle:first').html('<div class="tooltip"><div class="tooltip-inner">' + steps[minIndex] + '</div></div>');
			$(sliderSelector + ' .ui-slider-handle:last').html('<div class="tooltip"><div class="tooltip-inner">' + steps[maxIndex] + '</div></div>');
		}else{
			var range = steps[minIndex] + " - " + steps[maxIndex];
			$(sliderSelector + ' .ui-slider-handle:first').html('<div class="tooltip-range"><div class="tooltip-inner">' + range + '</div></div>');
			$(sliderSelector + ' .ui-slider-handle:last').html('');					
		}
	
}

var toggleSliderState = function (index){
	var workHourSliderSelector = "#divWorkHours" + index;
	var lunchHourSliderSelector = "#divLunchHours" + index;
	var isDisabled = $(workHourSliderSelector).slider("option", "disabled");
	if(isDisabled){
		$(workHourSliderSelector).slider("option", "disabled", false);
		$(lunchHourSliderSelector).slider("option", "disabled", false);																		
	}else{
		$(workHourSliderSelector).slider("option", "disabled", true);
		$(lunchHourSliderSelector).slider("option", "disabled", true);																		
	}
}

////////////Workweek Fields////////////////////////////////////////

function updateExceptionType (calendarId, eventRelId, newExceptionType){
	var relId = eventRelId;
	//Append a unique number to avoid caching in IE
	var date = new Date();
	var uniqueNumber = date.getMilliseconds();
	var url = "../programcentral/WorkCalendarUtil.jsp?mode=updateWorkWeek&newExceptionType=" + newExceptionType + "&objectId=" + calendarId + "&relId=" + relId + "&uniqueNumber=" + uniqueNumber;
	var response = emxUICore.getData(url);
	var target = window.parent;	
	refreshDatePicker(calendarId, target);
	displaySelectedDateInfo(new Date(), target);
}
function updateWorkHours(calendarId, eventRelId, startTime, finishTime){
	//Append a unique number to avoid caching in IE
	var date = new Date();
	var uniqueNumber = date.getMilliseconds();
	var url = "../programcentral/WorkCalendarUtil.jsp?mode=updateWorkWeek&startTime=" + startTime + "&finishTime=" + finishTime + "&objectId=" + calendarId + "&relId=" + eventRelId + "&uniqueNumber=" + uniqueNumber;
	var response = emxUICore.getData(url);
	var target = window.parent;	
	refreshDatePicker(calendarId, target);
	displaySelectedDateInfo(new Date(), target);
}
function updateLunchHours(calendarId, eventRelId, startTime, finishTime){
	//Append a unique number to avoid caching in IE
	var date = new Date();
	var uniqueNumber = date.getMilliseconds();
	var url = "../programcentral/WorkCalendarUtil.jsp?mode=updateWorkWeek&lunchStartTime=" + startTime + "&lunchFinishTime=" + finishTime + "&objectId=" + calendarId +  "&relId=" + eventRelId + "&uniqueNumber=" + uniqueNumber;
	var response = emxUICore.getData(url);
	var target = window.parent;	
	refreshDatePicker(calendarId, target);
	displaySelectedDateInfo(new Date(), target);
}
function getSelectedWorkingHours(){
	var value = $( "#divWorkHours" ).slider( "option", "values" );
	var minIndex = steps[value[0]];
	var maxIndex = steps[value[1]];
	var workingHours = minIndex + ";" +  maxIndex;
	return workingHours;
}
function getSelectedLunchHours(){
	var value = $( "#divLunchHours" ).slider( "option", "values" );
	var minIndex = steps[value[0]];
	var maxIndex = steps[value[1]];
	var lunchHours = minIndex + ";" +  maxIndex;
	return lunchHours;
}

///////////Exception Creation Fields///////////////////////////////////
function getExceptionType(){
	var val = $("input[name=exceptionTypeRadio]:checked").val();
	return val;
}

function getFrequency(){
	var val = $("input[name=recurrenceTypeRadio]:checked").val();
	return val;
}

function getMonthlyRecurringDate(){
	var val = $( "#monthlyRecurringDate" ).val();
	return val;
}

function getMonthlyRecurrringWeekOfMonth(){
	var val = $( "#monthlyRecurringWeekOfMonth" ).val();
	return val;
}

function getMonthlyRecurrringDayOfWeek(){
	var val = $( "#monthlyRecurringDayOfWeek" ).val();
	return val;
}

function getYearlyRecurringDate(){
	var val = $( "#yearlyRecurringDate" ).val();
	return val;
}

function getYearlyRecurrringWeekOfMonth(){
	var val = $( "#yearlyRecurringWeekOfMonth" ).val();
	return val;
}

function getYearlyRecurrringDayOfWeek(){
	var val = $( "#yearlyRecurringDayOfWeek" ).val();
	return val;
}

function getYearlyRecurrringMonthOfYear(){
	var selectedPattern = getYearlyRecurringPattern();
	var val = "";
	if("yearlyRecurringDate" === selectedPattern){
		val = $( "#yearlyrecurringMonthOfYear1" ).val();	
	}else{
		val = $( "#yearlyrecurringMonthOfYear2" ).val();	
	}
	return val;
}

function getMonthlyRecurringPattern(){
	var pattern = $("input[name=monthlyRecurringPattern]:checked").val();
	return pattern;
}

function getYearlyRecurringPattern(){
	var pattern = $("input[name=yearlyRecurringPattern]:checked").val();
	return pattern;
}

function enableAllOptions(optionListId){
  	var optionList = document.getElementById(optionListId);
  	var options = optionList.options;
  	for (var index = 0; index < options.length; index++) {
  		options[index].disabled = false; 
  	}
  };
function populateMonths(optionList){
	var selectedIndex = optionList.selectedIndex;
	var date = selectedIndex + 1;
	enableAllOptions("yearlyrecurringMonthOfYear1");
	var options = document.getElementById("yearlyrecurringMonthOfYear1").options;
	if(date === 31){
		options[1].disabled = true;
		options[3].disabled = true;
		options[5].disabled = true;
		options[8].disabled = true;
		options[10].disabled = true;
    }else if(date > 29){
		options[1].disabled = true;
	}
};

/////////////////////jQuery UI DatePicker/////////////////////////////////

var isTimeRangeValid = function (){
	var selectedWorkHours = $( "#divWorkHours" ).slider( "option", "values" );
	var selectedRecessHours = $( "#divLunchHours" ).slider( "option", "values" );
	
	var workStart = selectedWorkHours[0];
	var workFinish = selectedWorkHours[1];

	var recessStart = selectedRecessHours[0];
	var recessFinish = selectedRecessHours[1];
	
	if( workStart < recessStart && workFinish > recessFinish ){
		return true;
	}
	return false;
}

var displaySelectedDateInfo = function(date, target){
	if(date == null || date == undefined){
		date = new Date();
	}
	
	var month = date.getMonth();
	var year = date.getFullYear();
  	var day = date.getDate();
  	var key = year + "/" + month + "/" + day;

	//Append a unique number to avoid caching in IE 
	var now = new Date();
	var uniqueNumber = now.getMilliseconds();
	var url = "../programcentral/WorkCalendarUtil.jsp?mode=getEventInfoBydate&day=" + day + "&month=" + month + "&year=" + year +  "&uniqueNumber=" + uniqueNumber;
	var response = emxUICore.getData(url);
	var responseJSONObject = emxUICore.parseJSON(response);

	var dateStyle = responseJSONObject[key + "_css"];
	if(typeof dateStyle === 'undefined'){	dateStyle = '';	}
	  
	var eventName = responseJSONObject[key + "_event"];
	if(typeof eventName === 'undefined'){	eventName = '';	}
	  
	var eventStartTime = responseJSONObject[key + "_eventStartTime"];
    if(typeof eventStartTime === 'undefined'){	eventStartTime = '';	}

	var eventFinishTime = responseJSONObject[key + "_eventFinishTime"];
	if(typeof eventFinishTime === 'undefined'){	eventFinishTime = '';	}
		 
	var eventExceptionType = responseJSONObject[key + "_eventExceptionType"];
	if(typeof eventExceptionType === 'undefined'){	eventExceptionType = '';}
	
	var translatedMonthString = responseJSONObject["translatedMonthString"];
	var monthNamesShort = translatedMonthString.split(",");
	var monthNames = monthNamesShort;
	
	var translatedExceptionType = responseJSONObject["translatedExceptionType"];
	
		
	var eventHeader = monthNames[month] + " " + day + ", " + year + " "+"is"+" " + translatedExceptionType;
	var eventTimings = "";
	if("Working" === eventExceptionType){
		
		var translated_Working_Timings = responseJSONObject["translated_Working_Timings"];
	  eventTimings = translated_Working_Timings+" " + eventStartTime + " - " + eventFinishTime;
	}
	if(target == null || target == undefined){
		$('#divEventInfoHeader').html(eventHeader);
		$('#divEventWorkHours').html(eventTimings);
	}else{
		target.$('#divEventInfoHeader').html(eventHeader);
		target.$('#divEventWorkHours').html(eventTimings);
	}
};

var getMonthlyEvents = function(calendarId, year, month){
	  //Append a unique number to avoid caching in IE 
	  var date = new Date();
	  var uniqueNumber = date.getMilliseconds();
	  var url = "../programcentral/WorkCalendarUtil.jsp?mode=getCalendarMonthlyEvents&month=" + month + "&year=" + year + "&objectId=" + calendarId + "&uniqueNumber=" + uniqueNumber;
	  var response = emxUICore.getData(url);
	  var responseJSONObject = emxUICore.parseJSON(response);
	  return responseJSONObject;
};

var loadDatePicker = function (calendarId, target) {
  	var today = new Date();
  	var month = today.getMonth();
  	var year = today.getFullYear();
  	var responseJSONObject = getMonthlyEvents(calendarId, year, month);
	var datepicker;
  	if(target == null || target == undefined){
		datepicker = $("#datepicker");
	}else{
		datepicker = target.$("#datepicker");
	}

	var monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
	
	var key = "translatedatePicker";
	var strURL = "../programcentral/WorkCalendarUtil.jsp?mode=translateMonthsForWorkCalendar&key="+key;
	var responseText = emxUICore.getData(strURL);
	var responseTranslatedJSONObject = emxUICore.parseJSON(responseText);
	var translatedMonthString = responseTranslatedJSONObject["translatedMonthString"];
	var translatedWkDayString = responseTranslatedJSONObject["translatedWkDayString"];
	var monthNamesShort = translatedMonthString.split(",");
	var dayNamesMin = translatedWkDayString.split(",");
	var translatedCurrentText = responseTranslatedJSONObject["translatedCurrentText"];
	
  	datepicker.datepicker({
		changeMonth: true,
		changeYear: true,
		showWeek: false,
		showButtonPanel: true,
		numberOfMonths: 1,
        showOtherMonths: false,
        monthNames : monthNames,
        monthNamesShort: monthNamesShort,
        dayNamesMin: dayNamesMin,
        currentText: translatedCurrentText,
        selectOtherMonths: false,
        onChangeMonthYear: function (year, month) {
        	month = month - 1;
        	responseJSONObject = getMonthlyEvents(calendarId, year, month);
        },
        onSelect: function (date, t) {
        	var oDate = new Date(date);
        	displaySelectedDateInfo(oDate, target);
        },
	    beforeShowDay: function (date) {
	    	var key = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate();
			var dateStyle = responseJSONObject[key + "_css"];
            if(typeof dateStyle === 'undefined'){	dateStyle = '';	}
            var eventName = responseJSONObject[key + "_event"];
            if(typeof eventName === 'undefined'){	eventName = '';	}
            return [true, dateStyle, eventName];
        }
    });
};

var refreshDatePicker = function (calendarId, target) {
	target.$("#datepicker").datepicker("destroy");
	loadDatePicker(calendarId, target);
	//refreshDatePicker(target);
};
