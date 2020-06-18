/**
The Dateline class
@since 0.0.1
@author tws, lkd
@requires jQuery
*/

/**
Dateline is the control at the top of the timeline used to scroll through time

    var myDateline = new Dateline();//this whole year
    var myDateline = new Dateline('1/1/2011', '6/13/2011');//specific dates
    var myDateline = new Dateline('October 13, 1975 11:13:00', '12/31/2011');//any valid date string

 
@class Dateline
@module timeline
@constructor
@param {Date,String} startDate The start date
@param {Date,String} endDate The end date
@return {Object} Dateline
*/
var Dateline = function (startDate, endDate) {
	this.template = {
		year: function (str) {return jQuery('<div class="year"><div class="label-ctn">&#160;'+ str +'</div></div>')},
		month: function (obj) {return jQuery('<div class="month large"><div class="label-ctn">&#160;<span class="l-label">' + obj.large +'</span><span class="m-label">'+ obj.medium +'</span><span class="s-label">'+ obj.small +'</span></div></div>')},
		week: function (obj) {return jQuery('<div class="week large"><div class="label-ctn">&#160;<span class="l-label">' + obj.large +'</span><span class="m-label">'+ obj.medium +'</span><span class="s-label">'+ obj.small +'</span></div></div>')},
		day: function (obj) {return jQuery('<div class="day medium"><div class="txt label-ctn">&#160;<span class="l-label">' + obj.large +'</span><span class="m-label">'+ obj.medium +'</span><span class="s-label">'+ obj.small +'</span></div></div>')}
	};
	this.start = this.getStartDate(startDate);
	this.end = this.getEndDate(endDate);
	this.ONE_DAY = 1000 * 60 * 60 * 24;
	this.MONTH_LONG_NAMES 	= ["January","February","March","April","May","June","July","August","September","October","November","December"];
	this.MONTH_SHORT_NAMES 	= ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
	this.DAY_LONG_NAMES 	= ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
	this.DAY_SHORT_NAMES 	= ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
	this.CALENDAR_LABELS 	= ["Month","Day","Year","Week"];

	return this;
};
Dateline.prototype.draw = function ($elm) {
	var dt, currentYear, currentMonth, currentWeek, dayNow,
	currentDay, currentDate, totalDays, index = 0,
	$year, $month, $week, $day;
	dayNow = new Date().toLocaleDateString();
	totalDays = this.getDayCount();
	dt = new Date(this.start.getTime());
	for (; index < totalDays; index++) {
		if (currentYear != dt.getFullYear()) {
			currentYear = dt.getFullYear();
			$year = this.template.year(currentYear);
			$elm.append($year);
		}
		if (currentMonth != dt.getMonth()) {
			currentMonth = dt.getMonth();//add l10n here
			$month = this.template.month( {
				large : bpsWidgetConstants.str[this.MONTH_LONG_NAMES[currentMonth]] + " " + currentYear,
				medium : bpsWidgetConstants.str[this.MONTH_SHORT_NAMES[currentMonth]] + " " + currentYear,
				small : bpsWidgetConstants.str[this.MONTH_SHORT_NAMES[currentMonth]]
			});
			$year.append($month);
		}
	
		currentDay = dt.getDay();
		currentDate = dt.getDate();
		$day = this.template.day({
			large : bpsWidgetConstants.str[this.DAY_LONG_NAMES[currentDay]] + " " + currentDate,
			medium : bpsWidgetConstants.str[this.DAY_SHORT_NAMES[currentDay]] + " " + currentDate,
			small : currentDate
		});
		if (dt.toLocaleDateString() == dayNow) {
			$day.addClass('today');
		}
		if (currentWeek != dt.bpsGetWeek()) {
			currentWeek = dt.bpsGetWeek();
			$week = this.template.week({
				large : bpsWidgetConstants.str[this.CALENDAR_LABELS[3]] + " " + currentWeek,
				medium : bpsWidgetConstants.str[this.CALENDAR_LABELS[3]].substring(0,1) + " " + currentWeek,
				small : currentWeek
			});
			$day.append($week);
			$day.addClass('monday');
		}
		$month.append($day);
		
		dt.setDate(dt.getDate()+1)
	};
};
Dateline.prototype.getStartDate = function (startDate) {//startDate or 1st of this year
	if (startDate) {
		return new Date(startDate); 
	} else {
		var thisYear = new Date().getFullYear();
	    return new Date(thisYear, 0, 1);
	}
};
Dateline.prototype.getEndDate = function (endDate) {//endDate or last day of this year
	if (endDate) {
		return new Date(endDate); 
	} else {
		var thisYear = new Date().getFullYear();
	    return new Date(thisYear, 11, 31, 23, 59, 59, 999);
	}
};
Dateline.prototype.getDayCount = function () {
    var date1_ms = this.start.getTime();
    var date2_ms = this.end.getTime();
    // Calculate the difference in milliseconds
    var difference_ms = Math.abs(date1_ms - date2_ms);
    // Convert back to days and return
    return Math.round(difference_ms/this.ONE_DAY);
};
Date.prototype.bpsGetWeek = function(){
	// Create a copy of this date object
	var target  = new Date(this.valueOf());

	// ISO week date weeks start on monday
	// so correct the day number
	var dayNr   = (this.getDay() + 6) % 7;

	// ISO 8601 states that week 1 is the week
	// with the first thursday of that year.
	// Set the target date to the thursday in the target week
	target.setDate(target.getDate() - dayNr + 3);

	// Store the millisecond value of the target date
	var firstThursday = target.valueOf();

	// Set the target to the first thursday of the year
	// First set the target to january first
	target.setMonth(0, 1);
	// Not a thursday? Correct the date to the next thursday
	if (target.getDay() != 4) {
		target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7);
	}

	// The weeknumber is the number of weeks between the 
	// first thursday of the year and the thursday in the target week
	return 1 + Math.ceil((firstThursday - target) / 604800000); // 604800000 = 7 * 24 * 3600 * 1000
}

