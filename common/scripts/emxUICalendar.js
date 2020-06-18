/*!================================================================
 *  JavaScript Calendar Utility
 *  emxUICalendar.js
 *  Version 1.0
 *  Requires: emxUIConstants.js
 *
 *  This file contains classes and methods for the framework
 *  popup calendar picker.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUICalendar.js.rca 1.27 Wed Oct 22 15:48:10 2008 przemek Experimental przemek $
 *=================================================================
 */

var localCalendars = new Array;
var URL_GET_CALENDAR_SELECT = "../common/emxCalendarSetting.jsp";
var URL_GET_CALENDAR_LOAD = "../common/emxCalendarLoad.jsp";
function formatYear(strYear) {
	var iYear = parseInt(strYear);
	if(!Browser.MOBILE && !Browser.SAFARI && !Browser.EDGE ){
		return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,{year : 'numeric'}).format(Date.UTC(iYear,5));
	}else{
		return strYear;
	}
}
//! Class emxUICalendar
//!     This class is a calendar.
function emxUICalendar(objTargetFrame) {
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.container = null;
        this.document = document;
        this.emxClassName = "emxUICalendar";
        this.id = localCalendars.length;
        this.today = new Date();
        this.curDate = new Date(this.today);
        this.curDate.setYear(this.curDate.getFullYear());
        this.monthMenu = new emxUICalendarMonthMenu(this);
        this.selectedDate = new Date(this.curDate);
        this.tdMonth = null;
        this.tdYear = null;
        this.tblCalendarGrid = null;
        this.yearMenu = new emxUICalendarYearMenu(this);
        if (objTargetFrame) {
                this.yearMenu.ownerWindow = objTargetFrame;
                this.monthMenu.ownerWindow = objTargetFrame;
                this.yearMenu.displayWindow = objTargetFrame;
                this.monthMenu.displayWindow = objTargetFrame;
                this.targetFrame = objTargetFrame;
        }
}
emxUICalendar.prototype = new emxUIObject;
emxUICalendar.IMG_LEFT_ARROW = emxUIConstants.DIR_IMAGES + "utilCalendarLeftArrow.gif";
emxUICalendar.IMG_RIGHT_ARROW = emxUIConstants.DIR_IMAGES + "utilCalendarRightArrow.gif";
emxUICalendar.CSS_FILE = emxUICore.getStyleSheet("emxUICalendar");
//! Private Method emxUICalendar.draw()
//!     This method draws the HTML code for the calendar onto the display frame.
emxUICalendar.prototype.draw = function _emxUICalendar_draw(objContainer) {
        var objDoc = (this.targetFrame != null ? this.targetFrame.document : this.document);
        this.container = objContainer;
        this.container.className = "calendar-container";
        var objBuf= new emxUIStringBuffer;
        this.drawCalendar(objBuf);
        this.container.innerHTML = objBuf;
        this.tdYear = objDoc.getElementById("tdYear");
        this.tdYear1 = objDoc.getElementById("tdYear1");
        this.tdMonth = objDoc.getElementById("tdMonth");
        this.tdResetDate = objDoc.getElementById("tdResetDate");
        this.tblCalendarGrid = objDoc.getElementById("tblCalendarGrid");
        var objThis = this;
        this.tdYear.onkeypress = function (event) { objThis.fireEvent("yearchange",event); };
        this.tdYear1.onmouseover = function () { objThis.fireEvent("yearmouseover"); };
        this.tdYear1.onmouseout = function () { objThis.fireEvent("yearmouseout"); };
        this.tdYear1.onclick = function () { objThis.fireEvent("yearclick"); };
        this.tdMonth.onmouseover = function () { objThis.fireEvent("monthmouseover"); };
        this.tdMonth.onmouseout = function () { objThis.fireEvent("monthmouseout"); };
        this.tdMonth.onclick = function () { objThis.fireEvent("monthclick"); };
        this.tdResetDate.onclick = function () { objThis.fireEvent("resetclick"); };
        this.registerEventHandler("selectday", function (objEvent) { objThis.handleEvent("selectday", objEvent); });
        this.registerEventHandler("monthclick", function (objEvent) { objThis.handleEvent("monthclick", objEvent); });
        this.registerEventHandler("yearclick", function (objEvent) { objThis.handleEvent("yearclick", objEvent); });
        this.registerEventHandler("yearchange", function (objEvent) { objThis.handleEvent("yearchange", objEvent); });
        this.registerEventHandler("resetclick", function (objEvent) { objThis.handleEvent("resetclick", objEvent); });

        this.yearMenu.init(objDoc);
        this.monthMenu.init(objDoc);
        this.refresh(true); //added for performance improvement.
};
//! Private Method emxUICalendar.drawCalendar()
//!     This method draws the HTML code for the calendar.
emxUICalendar.prototype.drawCalendar = function _emxUICalendar_drawCalendar(objBuf) {
        objBuf.writeln("<table border=\"0\" cellpadding=\"0\" cellspacing=\"2\" width=\"225\">");
        objBuf.write("<tr><td>");
        this.drawHeader(objBuf);
        objBuf.writeln("</td></tr>");
        objBuf.writeln("<tr><td class=\"calendarBody\">");
        objBuf.writeln("<table border=\"0\" cellpadding=\"0\" cellspacing=\"2\" width=\"225\" id=\"tblCalendarGrid\">");
        objBuf.writeln("<thead><tr>");
        for (var i=0; i < emxUIConstants.ARR_SHORT_DAY_NAMES.length; i++) {
                var intCurDay = (i + emxUIConstants.CALENDAR_START_DOW) % 7;
                objBuf.write("<th height=\"20\" width=\"32\" class=\"day-name\">");
                objBuf.write(emxUIConstants.ARR_SHORT_DAY_NAMES[intCurDay]);
                objBuf.write("</th>");
        }
        objBuf.writeln("</tr></thead><tbody>");
        for (var i=0; i < 6; i++) {
                objBuf.writeln("<tr>");
                for (var j=0; j < 7; j++) {
                        objBuf.write("<td height=\"20\" class=\"empty\">&nbsp;</td>");
                }
                objBuf.writeln("</tr>");
        }
        objBuf.writeln("<tr><td id=\"tdResetDate\" colspan=\"7\"><button name=\"today-date\" class=\"btn-default today\" type=\"submit\">");
        objBuf.writeln(emxUIConstants.STR_TODAY);
        objBuf.writeln("</button></td></tr>");
        objBuf.writeln("</tbody></table>");
        objBuf.writeln("</td></tr>");
        objBuf.writeln("</table>");
};
//! Private Method emxUICalendar.drawHeader()
//!     This method  draws the calendar header.
emxUICalendar.prototype.drawHeader = function _emxUICalendar_drawHeader(objBuf) {
        objBuf.writeln("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\" height=\"20\" class=\"calendarHead\"><tr>");
        objBuf.write("<td id=\"tdMonth\" width=\"120\">&nbsp;</td><td width=\"1\"><img src=\"");
        objBuf.write(emxUIConstants.IMG_SPACER);
		objBuf.write("\" width=\"1\" height=\"1\" /></td><td><input size=\"5\" type=\"text\" id=\"tdYear\" oncontextmenu=\"return false;\"/></td><td id=\"tdYear1\"></td></tr></table>");
};
//! Private Method emxUICalendar.handleEvent()
//!     This method handles events.
emxUICalendar.prototype.handleEvent = function _emxUICalendar_handleEvent(strType, objEvent) {
        switch(strType) {
                case "selectday":
                        this.setSelectedDate(new Date(objEvent.currentTarget.dateValue));
                        this.refresh();
                        break;
                case "todayclick":
                        this.setSelectedDate(new Date);
                        this.refresh();
                        break;
                case "monthclick":
                        //this.monthMenu.show(this.tdMonth, "down");
                		this.monthMenu.show(this.tdMonth, "calendar-down");
                		this.yearMenu.hide();
                        break;
                case "yearclick":
                        //this.yearMenu.show(this.tdYear, "down");
                        this.yearMenu.show(this.tdYear, "calendar-down");
                        this.monthMenu.hide();
                        break;
                case "yearchange":
                    //this.yearMenu.show(this.tdYear, "down");
                	var e = objEvent || window.event;
                	var charCode = (e.which) ? e.which : e.keyCode;
                	var selectedYear = parseInt(this.tdYear.value);
                	var selectedTextLen = this.tdYear.value.substring(this.tdYear.selectionStart,this.tdYear.selectionEnd).length;
                	if(selectedTextLen != 0){
                		if((charCode > 31 && (charCode < 48 || charCode > 57)) || ((selectedTextLen == 4 || this.tdYear.selectionEnd == 1)&& charCode == 48)){
                			e.preventDefault();
                		}
                	}
                	else if((this.tdYear.value.length > 3 && charCode != 8 && charCode != 46 && charCode != 13) || (charCode > 31 && (charCode < 48 || charCode > 57)) || (this.tdYear.value.length == 0 && charCode == 48)){
                    	e.preventDefault();
                    }else if (e.keyCode == 13 && selectedYear >= 1000 && selectedYear <= 9999 ) {
                    	this.setYear(selectedYear);
                		//this.refresh(); //modified by DI7. setYear already doing refresh.
                    }
                    break;
                case "resetclick":
                	    var strURL = URL_GET_CALENDAR_LOAD;
                	    var strData = emxUICore.getData(strURL);
                        var arrData = strData.split("|");
                        this.setYear(parseInt(arrData[0]));
                        this.setMonth(parseInt(arrData[1]));
                		break;

        }
};
//! Private Method emxUICalendar.moveMonth()
//!     This method moves the month being displayed by the calendar.
emxUICalendar.prototype.moveMonth = function _emxUICalendar_moveMonth(intIncrement) {
        this.curDate.addMonths(intIncrement);
        this.refresh();
};
//! Private Method emxUICalendar.moveYear()
//!     This method moves the year being displayed by the calendar.
emxUICalendar.prototype.moveYear = function _emxUICalendar_moveYear(intIncrement) {
        this.curDate.addYears(intIncrement);
        this.refresh();
};
//! Private Method emxUICalendar.refresh()
//!     This method refreshes the view of the calendar.
emxUICalendar.prototype.refresh = function _emxUICalendar_refresh(invokeCalJPO) {
        this.disable();
        this.tdMonth.innerHTML = emxUIConstants.ARR_LONG_MONTH_NAMES[this.curDate.getMonth()];
        this.tdYear.value = this.curDate.getFullYear();
        var objTempDate = new Date(this.curDate.setDate(1));
        var intStartDay = objTempDate.getDay();
        if (intStartDay != emxUIConstants.CALENDAR_START_DOW) {
                do  {
                        objTempDate.addDays(-1);
                } while (objTempDate.getDay() != emxUIConstants.CALENDAR_START_DOW);
        }

        //!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
        var calStartDate = "";
        var calEndDate = "";
        calStartDate = new Date(objTempDate);
        calEndDate = new Date(objTempDate);
        calEndDate.addDays(42);

	if(invokeCalJPO){ //Added for performance improvement
        calStartDate_msValue = calStartDate.getTime();
        calEndDate_msValue = calEndDate.getTime();
        if(REQUESTMAP.CalendarProgram != null && REQUESTMAP.CalendarFunction != null && REQUESTMAP.CalendarProgram != 'undefined' && REQUESTMAP.CalendarFunction != 'undefined'){
	        	if(REQUESTMAP.InputType=="textbox" && REQUESTMAP.format=="date" && REQUESTMAP.CalendarProgram != "" && REQUESTMAP.CalendarFunction != "")
	        		startEnhCalAjaxCall(calStartDate_msValue,calEndDate_msValue);
        }
	}

        //End:For Enhanced Calendar Control:AEF:nr2:20-11-09

        for (var i=0; i < 6; i++) {
                var objRow = this.tblCalendarGrid.tBodies[0].rows[i];
                for (var j=0; j < 7; j++) {
                        var objCell = objRow.cells[j];
                        var intCurDay = (j + emxUIConstants.CALENDAR_START_DOW) % 7;
                        var blnIsEmpty = (i == 0 && Date.isDayBefore(intCurDay, intStartDay)) || (objTempDate.getMonth() != this.curDate.getMonth());
                    	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        var index = calNonWDindex(this,objTempDate);
                        if(index != -1){
                        	var calCellColor = arrNonWorkingDayColor[index].split("|")[0];
                        }
                    	//!End:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        if (blnIsEmpty){
                        	if(index == -1){
                        		objCell.style.backgroundColor = "";
                        		objCell.className = "empty";
                        	}
                        	else{
                        	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        		objCell.style.backgroundColor = calCellColor;
                        		}
                        	//!End:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        } else if (objTempDate.isDateEqual(this.selectedDate)){
                        		objCell.style.backgroundColor = "";
                        		objCell.className = "day selected";
                        } else if (objTempDate.isDateEqual(this.today)){
                        	if(index == -1){
                        		objCell.style.backgroundColor = "";
                        		objCell.className = "today";
                        	}
                        	else{
                               	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
                               		objCell.style.backgroundColor = calCellColor;
                               	}
                            	//!End:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        } else {
                        	if(index == -1){
                        		objCell.style.backgroundColor = "";
                        		objCell.className = "day";
                        	}
                        	else{
                               	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
                        			objCell.style.backgroundColor = calCellColor;
                               	}
                            	//!End
                        }
                        objCell.innerHTML = objTempDate.getDate();
                        var objThis = this;
                        objCell.dateValue = objTempDate.toString();
                        objCell.onclick = function () {
                                objThis.fireEvent("selectday", emxUICore.getEvent(objThis.parentWindow));
                        };
                        objCell.onmouseover = function () {
                                objThis.fireEvent("daymouseover", emxUICore.getEvent(objThis.parentWindow));
                        };
                        objCell.onmouseout = function () {
                                objThis.fireEvent("daymouseout", emxUICore.getEvent(objThis.parentWindow));
                        };
                        if(!Browser.MOBILE && !Browser.SAFARI && !Browser.EDGE){
                        var options = { year: "numeric", month: "short", day: "numeric" };
						objCell.title = Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(objTempDate);
                        }
						else{
							objCell.title = emxUIConstants.ARR_LONG_MONTH_NAMES[objTempDate.getMonth()] + " " + objTempDate.getDate() + ", " + objTempDate.getFullYear();
                		}
                        var tempObjDate = objTempDate.getDate();
                        objTempDate.addDays(1);
                        if(objTempDate.getDate() == tempObjDate ){
                        	objTempDate.addDays(1);
                        }
                }
        }
        //Added By Nishant - For Calendar Control So that soes not cache
        	arrCalDates = [];
        //End - For Calendar Control
        this.enable();
};
//! Private Method emxUICalendar.setCurrentDate()
//!     This method sets the current date of the calendar (the one
//!     being displayed).
emxUICalendar.prototype.setCurrentDate = function _emxUICalendar_setCurrentDate(objDate) {
        this.curDate = new Date(objDate);
        this.curDate.setYear(this.curDate.getFullYear());
};
//! Private Method emxUICalendar.setSelectedDate()
//!     This method sets the selected date of the calendar.
emxUICalendar.prototype.setSelectedDate = function _emxUICalendar_setSelectedDate(objDate) {
        this.selectedDate = new Date(objDate);
        this.selectedDate.setYear(this.selectedDate.getFullYear());
};
//! Private Method emxUICalendar.setMonth()
//!     This method sets the month being displayed by the calendar.
emxUICalendar.prototype.setMonth = function _emxUICalendar_setMonth(intMonth) {
        if (typeof intMonth != "number") {
                throw new Error("Required parameter intMonth is null or not a number. (emxUICalendar.js::emxUICalendar.prototype.setMonth)");
        } else if (intMonth > 11 || intMonth < 0) {
                throw new Error("Required parameter intMonth must be a value between 0 and 11. (emxUICalendar.js::emxUICalendar.prototype.setMonth)");
        }
        this.curDate.setMonth(intMonth);
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
        clickedOnCalIcon = "true";
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09
        this.refresh(true);//Added for performance improvement.
};
//! Private Method emxUICalendar.setYear()
//!     This method sets the year being displayed by the calendar.
emxUICalendar.prototype.setYear = function _emxUICalendar_setYear(intYear) {
        if (typeof intYear != "number") {
                throw new Error("Required parameter intYear is null or not a number. (emxUICalendar.js::emxUICalendar.prototype.setYear)");
        }
        this.curDate.setFullYear(intYear);
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
        clickedOnCalIcon = "true";
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09
        this.refresh(true); //Added for performance improvement.
};
//! Class emxUICalendarMonthMenuItem
//!     This object represents an item on a month menu.
function emxUICalendarMonthMenuItem(strText) {
        this.superclass = emxUICoreMenuLink;
        this.superclass(null, strText);
        delete this.superclass;
        this.emxClassName = "emxUICalendarMonthMenuItem";
}
emxUICalendarMonthMenuItem.prototype = new emxUICoreMenuLink;
//! Method emxUICalendarMonthMenuItem.click()
//!     This method handles the click event for this object.
emxUICalendarMonthMenuItem.prototype.click = function _emxUICalendarMonthMenuItem_click() {
        if (!this.dead) {
                this.parent.hide(true);
                this.parent.calendar.setMonth(this.index);
        }
};
//! Class emxUICalendarMonthMenu
//!     This object represents a month menu.
function emxUICalendarMonthMenu(objCalendar) {
        this.superclass = emxUICorePopupMenu;
        this.superclass();
        delete this.superclass;
        this.calendar = objCalendar;
        this.cssClass = "monthmenu";
        this.emxClassName = "emxUICalendarMonthMenu";
        this.maxHeight = -1;
        this.stylesheet = emxUICalendar.CSS_FILE;
        this.widthConstant = 125;
        this.build();
}
emxUICalendarMonthMenu.prototype = new emxUICorePopupMenu;
//! Private Method emxUICalendarMonthMenu.build()
//!     This method builds the month menu.
emxUICalendarMonthMenu.prototype.build = function _emxUICalendarMonthMenu_build() {
        for (var i=0; i < emxUIConstants.ARR_LONG_MONTH_NAMES.length; i++) {
                this.addItem(new emxUICalendarMonthMenuItem(emxUIConstants.ARR_LONG_MONTH_NAMES[i]));
        }
};
//! Class emxUICalendarYearMenuItem
//!     This object represents an item on a year menu.
function emxUICalendarYearMenuItem(strText) {
        this.superclass = emxUICoreMenuLink;
        this.superclass(null, formatYear(strText),null,null,strText);
        delete this.superclass;
        this.emxClassName = "emxUICalendarYearMenuItem";
}
emxUICalendarYearMenuItem.prototype = new emxUICoreMenuLink;
//! Method emxUICalendarYearMenuItem.click()
//!     This method handles the click event for this object.
emxUICalendarYearMenuItem.prototype.click = function _emxUICalendarYearMenuItem_click() {
        if (!this.dead) {
                this.parent.hide(true);
                this.parent.calendar.setYear(parseInt(this.text));
        }
};
//! Class emxUICalendarYearMenuSeparator
//!     This object represents a separator on the year menu
function emxUICalendarYearMenuSeparator() {
        this.superclass = emxUICoreMenuSeparator;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUICalendarYearMenuSeparator";
}
emxUICalendarYearMenuSeparator.prototype = new emxUICoreMenuSeparator;
//! Class emxUICalendarYearMenu
//!     This object represents a month menu.
function emxUICalendarYearMenu(objCalendar) {
        this.superclass = emxUICorePopupMenu;
        this.superclass();
        delete this.superclass;
        this.calendar = objCalendar;
        this.cssClass = "yearmenu";
        this.emxClassName = "emxUICalendarYearMenu";
        this.maxHeight = -1;
        this.stylesheet = emxUICalendar.CSS_FILE;
        this.widthConstant = 75;
        this.build();
}
emxUICalendarYearMenu.prototype = new emxUICorePopupMenu;
//! Private Method emxUICalendarYearMenu.build()
//!     This method builds the month menu.
emxUICalendarYearMenu.prototype.build = function _emxUICalendarYearMenu_build() {
        for (var i=0; i < emxUIConstants.CALENDAR_YEARS_BEFORE + emxUIConstants.CALENDAR_YEARS_AFTER + 1; i++) {
                this.addItem(new emxUICalendarYearMenuItem(i));
        }
        this.addItem(new emxUICalendarYearMenuSeparator());
        this.addItem(new emxUICalendarYearMenuItem((new Date).getFullYear()));
        if (emxUIConstants.CALENDAR_CUSTOM_YEARS.length > 0) {
                this.addItem(new emxUICalendarYearMenuSeparator());
                for (var i=0; i < emxUIConstants.CALENDAR_CUSTOM_YEARS.length; i++) {
                        this.addItem(new emxUICalendarYearMenuItem(emxUIConstants.CALENDAR_CUSTOM_YEARS[i]));
                }
        }
};
//! Private Method emxUICalendarYearMenu.rebuild()
//!     This method builds the month menu.
emxUICalendarYearMenu.prototype.rebuild = function _emxUICalendarYearMenu_rebuild() {
        var intStartYear = this.calendar.curDate.getFullYear() - emxUIConstants.CALENDAR_YEARS_BEFORE;
        if(intStartYear<1000){
        	intStartYear = intStartYear + (1000 - intStartYear);
        }
        var intEndYear = this.calendar.curDate.getFullYear() + emxUIConstants.CALENDAR_YEARS_AFTER + 1;
        if(intEndYear>9999){
        	intStartYear = intStartYear - (intEndYear - 10000);
        }
        for (var i=0; i < emxUIConstants.CALENDAR_YEARS_BEFORE + emxUIConstants.CALENDAR_YEARS_AFTER + 1; i++) {
                var objItem = this.items[i];
                objItem.text = parseInt(intStartYear);
				objItem.value = intStartYear;
                //objItem.rowElement.cells[0].innerHTML = intStartYear++;
				objItem.rowElement.getElementsByTagName("label")[0].innerHTML = formatYear(intStartYear++);

        }
};
//! Private Method emxUICalendarYearMenu.show()
//!     This method shows the menu.
emxUICalendarYearMenu.prototype.emxUICoreMenuShow = emxUICalendarYearMenu.prototype.show;
emxUICalendarYearMenu.prototype.show = function _emxUICalendarYearMenu_show(objRef, strDir) {
        this.rebuild();
        this.emxUICoreMenuShow(objRef, strDir);
};

// to reinitialize year and month menus when toolbar is redrawn
emxUICalendar.prototype.reInitCalendarMenus = function _emxUICalendar_reInitCalendarMenus(){
	var objDoc = (this.targetFrame != null ? this.targetFrame.document : this.document);
	this.yearMenu.init(objDoc);
	this.monthMenu.init(objDoc);
	//this.refresh();
};

//! Class emxUIPopupCalendar
//!     This class is a popup calendar.
function emxUIPopupCalendar(strInputName, objDocument, objTargetFrame) {
        this.superclass = emxUICalendar;
        this.superclass(objTargetFrame);
        delete this.superclass;
        this.emxClassName = "emxUIPopupCalendar";
        this.document = objDocument;
        this.layer = null;
        this.popup = null;
        this.form = null;
        this.hiddenField = null;
        this.inputName = strInputName;
        this.field = null;
        this.hiddenField = null;
        this.initialized = false;
        this.remember = false;

        localCalendars[strInputName] = this;
}
emxUIPopupCalendar.prototype = new emxUICalendar;
emxUIPopupCalendar.prevDate = null;
//! Public Class Method emxUIPopupCalendar.callback()
//!     This method assigns the input fields for the calendar.
//!     This includes duplicating the field if necessary.
emxUIPopupCalendar.callback = function _emxUIPopupCalendar_callback(fnCallback) {
        var arrTemp = new Array;
        var strArgs = "";
        for (var i=1; i < arguments.length; i++) {
                arrTemp[arrTemp.length] = arguments[i];
                strArgs += "arrTemp[" + (i-1) + "],";
        }
        strArgs = strArgs.substring(0, strArgs.length-1);
        return function () {
                        eval("fnCallback(" + strArgs + ")");
               }
};
//! Private Method emxUIPopupCalendar.assignInputs()
//!     This method assigns the input fields for the calendar.
//!     This includes duplicating the field if necessary.
emxUIPopupCalendar.prototype.assignInputs = function _emxUIPopupCalendar_assignInputs(objDocument, objForm) {
	var found = false;
	for(var i=0;i<objForm.elements.length;i++){
		if(this.inputName == objForm.elements[i].name){
			found = true;
			this.field = objForm.elements[i];
		}
		if((this.inputName + "_msvalue") == objForm.elements[i].name)
			this.hiddenField = objForm.elements[i];
	}
        var dateField;
        if(typeof this.field=='undefined' || !this.field || !found){
        	dateField = getFieldFromOverflowmenu(this.inputName, "date");
        	this.field = dateField[0];
        	this.hiddenField = dateField[1];
        }

};
//! Private Method emxUIPopupCalendar.draw()
//!     This method draws the HTML code for the calendar onto the display frame.
emxUIPopupCalendar.prototype.emxUICalendarDraw = emxUIPopupCalendar.prototype.draw;
emxUIPopupCalendar.prototype.draw = function _emxUIPopupCalendar_draw(objContainer) {
        /*if (isMinIE55 && isWin) {
                this.popup = window.createPopup();
                var objDoc = this.document = this.popup.document;
                this.parentWindow = this.document.parentWindow;
                this.yearMenu.ownerWindow = this.parentWindow;
                this.monthMenu.ownerWindow = this.parentWindow;
                objBody = this.document.body;
                objBody.style.cssText = "margin: 0px;";
                objBody.scroll = "no";
                objDoc.createStyleSheet(emxUICore.getStyleSheet(emxUIConstants.CSS_DEFAULT));
                objDoc.createStyleSheet(emxUICalendar.CSS_FILE);
                objBody.innerHTML = "";
                objContainer = objBody;
        }*/
		if (isMinIE55 && isWin){
			this.parentWindow = this.targetFrame != null ? this.targetFrame : window;
			this.yearMenu.ownerWindow = this.parentWindow;
			this.monthMenu.ownerWindow = this.parentWindow;
		}
        this.emxUICalendarDraw(objContainer);
        emxUICore.addEventHandler(objContainer, "contextmenu", cancelEvent);
        emxUICore.addEventHandler(objContainer, "selectstart", cancelEvent);
        /*if (isMinIE55 && isWin) {
                this.layer.innerHTML = objContainer.innerHTML;
        }*/
};
//! Private Method emxUIPopupCalendar.handleEvent()
//!     This method handles events.
emxUIPopupCalendar.prototype.emxUICalendarHandleEvent = emxUIPopupCalendar.prototype.handleEvent;
emxUIPopupCalendar.prototype.handleEvent = function _emxUIPopupCalendar_handleEvent(strType, objEvent) {
        switch(strType) {
                case "selectday":
                        this.setSelectedDate(new Date(objEvent.currentTarget.dateValue));
                        this.selectDay(this.selectedDate);
                        this.hide();
                        this.refresh();
                        break;
                case "todayclick":
                        this.setSelectedDate(new Date());
                        this.selectDay(this.selectedDate);
                        this.hide();
                        this.refresh();
                        break;
                default:
                        this.emxUICalendarHandleEvent(strType, objEvent);
        }
};
//! Private Method emxUIPopupCalendar.hide()
//!     This method hides the popup calendar.
emxUIPopupCalendar.prototype.hide = function _emxUIPopupCalendar_hide() {
        /*if (isMinIE55 && isWin) {
                this.popup.hide();
        } else {
                emxUICore.hide(this.layer);
        }*/
        hide_IE(this.layer);
        this.monthMenu.hide();
        this.yearMenu.hide();
        this.setCurrentDate(this.selectedDate);
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
//This condition is added since otherwise refresh is called at all events which in turn
        if(clickedOnCalIcon == "true")
        	this.refresh();
        clickedOnCalIcon = "false";
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09
        //this.refresh();
        this.fireEvent("hide");

        var fnTemp = this.fnTemp;
        emxUICore.iterateFrames(function (objFrame) {
        	if(objFrame){
        		if(isIE){
        	    	objFrame.document.onmouseup = null;
        	    } else {
        	    	objFrame.removeEventListener("mouseup", fnTemp, false);
        	    }
        	}
        });
};
//! Private Method emxUIPopupCalendar.isCalendarElement()
//!     This method determines if a given element is contained within
//!     this calendar layer.
emxUIPopupCalendar.prototype.isCalendarElement = function _emxUIPopupCalendar_isCalendarElement(objElement) {
        var objElem = objElement;
        while(objElem && objElem != this.layer && objElem != this.yearMenu.layer && objElem != this.monthMenu.layer) {
                objElem = objElem.parentNode;
        }
        return (objElem == this.layer || objElem == this.yearMenu.layer || objElem == this.monthMenu.layer);
};
//! Private Method emxUIPopupCalendar.selectDay()
//!     This method selects a day on the calendar.
emxUIPopupCalendar.prototype.selectDay = function _emxUIPopupCalendar_selectDay(objDate) {
        this.selectedDate = new Date(objDate);
        emxUIPopupCalendar.prevDate = new Date(objDate);
        this.field.emxDateValue = this.selectedDate.getTime();
        var strURL = URL_GET_CALENDAR_SELECT;
        strURL = emxUICore.addURLParam(strURL, "day=" + objDate.getDate());
        strURL = emxUICore.addURLParam(strURL, "mon=" + (objDate.getMonth()+1));
        strURL = emxUICore.addURLParam(strURL, "year=" + objDate.getFullYear());
        var strData = emxUICore.getData(strURL);
        this.setInputValue(trim(strData));
};
//! Private Method emxUIPopupCalendar.show()
//!     This method shows the popup calendar.
emxUIPopupCalendar.prototype.show = function _emxUIPopupCalendar_show(objDocument, objForm, strInitialDate) {
        if (!this.field || !isNewCal) {
                this.assignInputs(objDocument, objForm);
        }
        var strURL = URL_GET_CALENDAR_LOAD;
        if (this.remember && emxUIPopupCalendar.prevDate) {
                strURL = addURLParam(strURL, "date=" + (emxUIPopupCalendar.prevDate.getMonth()+1) + "/" + emxUIPopupCalendar.prevDate.getDate() + "/" + emxUIPopupCalendar.prevDate.getFullYear() + " 12:00:00 PM");
        } else  {
                strURL = addURLParam(strURL, "date=" + escape(strInitialDate));
        }
        var strData = emxUICore.getData(strURL);
        var arrData = strData.split("|");
        this.setInitialDate(parseInt(arrData[0]), parseInt(arrData[1]), parseInt(arrData[2]));
        if (!this.layer) {
                if (this.targetFrame != null) {
                        this.layer = this.targetFrame.document.createElement("div");
                        this.layer.style.visibility = "hidden";
                        this.layer.style.position = "absolute";
                        this.layer.style.zIndex = 1001;
                        //this.layer.style.width = "230px";
                        this.targetFrame.document.body.insertBefore(this.layer, this.targetFrame.document.body.firstChild);
                        this.draw(this.layer);
                } else {
                        this.layer = objDocument.createElement("div");
                        this.layer.style.visibility = "hidden";
                        this.layer.style.position = "absolute";
                        this.layer.style.zIndex = 1001;
                        //this.layer.style.width = "230px";
                        objDocument.body.insertBefore(this.layer, objDocument.body.firstChild);
                        this.draw(this.layer);
                }

        }
        if(!isNewCal && this.yearMenu.layer.innerHTML == ""){
        	this.reInitCalendarMenus();
        }
        /*if (isMinIE55 && isWin) {
                var objThis = this;
                this.popup.show(0, this.field.offsetHeight, this.layer.offsetWidth, this.layer.offsetHeight, this.field);
                setTimeout(function () {
                        if (objThis.popup.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, emxUICoreMenu.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        }
                }, emxUICoreMenu.WATCH_DELAY);
        } else {*/
                var intY = 0, intX = 0;
                var isSlideIn = window.document.location.href.indexOf("targetLocation=slidein") != -1;
                if (this.targetFrame != null) {
                        intY = 0;
                        intX = emxUICore.getActualLeft(this.field) + this.targetFrame.document.body.scrollLeft;
                        if (intX + this.layer.offsetWidth > this.targetFrame.document.body.scrollLeft + emxUICore.getWinWidth()) {
                                intX = emxUICore.getWinWidth() - this.layer.offsetWidth  + this.targetFrame.document.body.scrollLeft;
                        }
                } else {
                		//Added for bug no 346599
                        if(this.field && this.field.nextSibling && (this.field.nextSibling.id == 'formDateChooser'
                        	|| (this.field.nextSibling.nextSibling && this.field.nextSibling.nextSibling.id == 'formDateChooser'))){

                        	intY = dateChooserYPos;
                        	intX = dateChooserXPos;
                        }else{
                        	intY = emxUICore.getActualTop(this.field) + this.field.offsetHeight;
                            if(!isSlideIn){
                            	intX = emxUICore.getActualLeft(this.field) + this.field.offsetWidth+16;
                            } else {
                            	intX = emxUICore.getActualLeft(this.field) + document.body.scrollLeft;
                            }
                            //code added to adjust the calendar height for forms
                		var headerHeight = document.getElementById('pageHeadDiv') ? document.getElementById('pageHeadDiv').offsetHeight : 0;
	                    var scrlTop = document.getElementById("divPageBody") ? document.getElementById("divPageBody").scrollTop : document.body.scrollTop;

                            if(headerHeight && scrlTop){
    		                      if (intY - scrlTop > headerHeight) {
    		                    	  intY = intY-scrlTop-(this.field.offsetHeight/2);
    		                       }
                            }
                         }
                		var pageFrameHeight = findFrame(getTopWindow(),'pagecontent');
                		if(pageFrameHeight){
                			if(intY + this.layer.offsetHeight + 125> emxUICore.getWinHeight(pageFrameHeight)){
                		             intY = intY - this.layer.offsetHeight-this.field.offsetHeight;
                		}
                		}
                		else{
                        if (intY + this.layer.offsetHeight + this.field.offsetHeight > emxUICore.getWinHeight()) {
                                intY = intY - this.layer.offsetHeight;
                        }
                		}
                		if(isSlideIn){
	                        if (intX + this.layer.offsetWidth > document.body.scrollLeft + emxUICore.getWinWidth()) {
	                                intX = emxUICore.getWinWidth() - this.layer.offsetWidth  + document.body.scrollLeft;
	                        }


                		}

                        //slidein
                        //make sure it's not off the top of the page
                        if (intY < document.body.scrollTop) {
                                intY = document.body.scrollTop;
                        }
                        if(!isSlideIn){
                        	if((intX+this.layer.offsetWidth) > document.documentElement.scrollWidth){
                         	   intX=document.documentElement.scrollWidth-this.layer.offsetWidth-16;
                          }
                        }else {
                        	if ((document.body.scrollLeft + emxUICore.getWinWidth()) - (intX + this.layer.offsetWidth) < 16) {
                            	intX -= 16;
                            }
                        }
              }
                var deltaWidth = isIE ? 300:250;
				if(isMaxIE8) {
					if(this.field.parentNode &&
                    	this.field.parentNode.parentNode &&
                    	this.field.parentNode.parentNode.parentNode &&
                    	this.field.parentNode.parentNode.parentNode.className == "mmenu-border") {
                    	intX = intX - deltaWidth;
					}
				} else{
                if(this.field.offsetParent &&
                		this.field.offsetParent.offsetParent &&
                		this.field.offsetParent.offsetParent.offsetParent &&
                		this.field.offsetParent.offsetParent.offsetParent.className == "mmenu-border"){
                               	intX = intX - deltaWidth;
                }
                }
				var page_xOffset = typeof pageXOffset != "undefined" ? pageXOffset : (document.documentElement ? document.documentElement.scrollLeft : null);
				var page_yOffset = typeof pageYOffset != "undefined" ? pageYOffset : (document.documentElement ? document.documentElement.scrollTop : null);
				if(page_xOffset != null && intX < page_xOffset){
					intX = emxUICore.getActualLeft(this.field) + this.field.offsetWidth + 16;
				}
				if(page_yOffset != null && intY < page_yOffset){
					intY = emxUICore.getActualTop(this.field) + this.field.offsetHeight;
				}

                emxUICore.moveTo(this.layer, intX, intY);
                emxUICore.show(this.layer);
                var objThis = this;
                var fnTemp = function () {
						if(isIE){
							var win = this.parentWindow;
							if(win && win.event){
								var objTarget = win.event.target;
								if(!objTarget){
									objTarget = win.event.srcElement;
								}
								if (objThis.isCalendarElement(objTarget)){
									win.event.cancelBubble = true;
								} else {
									objThis.hide();
								}
							}
						}else{
							var objEvent = emxUICore.getEvent();
							if (objThis.isCalendarElement(objEvent.target)){
								objEvent.stopPropagation();
							} else {
								objThis.hide();
							}
						}
		        };
		        this.fnTemp = fnTemp;
                attachEventHandler(window,"scroll", function () { objThis.hide(); }, true);
                emxUICore.iterateFrames(function (objFrame) {
                	if(objFrame){
                		if(isIE){
                	    	/*if(objFrame.document.onmousedown){
                	    		objFrame.document.onmousedown.call();
                	    	}*/

                	    	objFrame.document.onmousedown = fnTemp;
                	    } else {
                	    	objFrame.addEventListener("mousedown", fnTemp, false);
                	    }
                	}
                });
        //}
};
//Added for bug no 346599
var dateChooserYPos;
var dateChooserXPos;
// This function sets the cursor position for datechooser in large forms when datechooser is clicked
function setPositionForCalendar(){
	var objEvent = emxUICore.getEvent();
	dateChooserYPos = objEvent.clientY;
	dateChooserXPos = objEvent.clientX;
}

// Netscape-Specific Constants
attachEventHandler = function (objElement, strEvent, fnHandler) {
	objElement.addEventListener(strEvent, fnHandler, false);
}
detachEventHandler = function (objElement, strEvent, fnHandler) {
	objElement.removeEventListener(strEvent, fnHandler, false);
}

//! Private Method emxUIPopupCalendar.show2()
//!     This method shows the popup calendar without assigning inputs.
emxUIPopupCalendar.prototype.show2 = function _emxUIPopupCalendar_show2(objDocument, objForm, strInitialDate) {
        this.assignInputs(objDocument, objForm);
        var strURL = URL_GET_CALENDAR_LOAD;
        if (this.remember && emxUIPopupCalendar.prevDate) {
                strURL = addURLParam(strURL, "date=" + (emxUIPopupCalendar.prevDate.getMonth()+1) + "/" + emxUIPopupCalendar.prevDate.getDate() + "/" + emxUIPopupCalendar.prevDate.getFullYear() + " 12:00:00 PM");
        } else {
                strURL = addURLParam(strURL, "date=" + escape(strInitialDate));
        }
        var strData = emxUICore.getData(strURL);
        var arrData = strData.split("|");
        this.setInitialDate(parseInt(arrData[0]), parseInt(arrData[1]), parseInt(arrData[2]));
        if (!this.layer) {
                if (this.targetFrame != null) {
                        this.layer = this.targetFrame.document.createElement("div");
                        this.layer.style.visibility = "hidden";
                        this.layer.style.position = "absolute";
                        this.layer.style.zIndex = 2;
                        this.layer.style.width = "230px";
                        this.targetFrame.document.body.insertBefore(this.layer, this.targetFrame.document.body.firstChild);
                        this.draw(this.layer);
                } else {
                        this.layer = objDocument.createElement("div");
                        this.layer.style.visibility = "hidden";
                        this.layer.style.position = "absolute";
                        this.layer.style.zIndex = 2;
                        this.layer.style.width = "230px";
                        objDocument.body.insertBefore(this.layer, objDocument.body.firstChild);
                        this.draw(this.layer);
                }
        }
        /*if (isMinIE55 && isWin) {
                var objThis = this;
                this.popup.show(0, this.field.offsetHeight, this.layer.offsetWidth, this.layer.offsetHeight, this.field);
                setTimeout(function () {
                        if (objThis.popup.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, emxUICoreMenu.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        }
                }, emxUICoreMenu.WATCH_DELAY);
        } else {*/
                if (this.targetFrame != null) {
                        intY = 0;
                        intX = emxUICore.getActualLeft(this.field) + this.targetFrame.document.body.scrollLeft;
                        if (intX + this.layer.offsetWidth > this.targetFrame.document.body.scrollLeft + emxUICore.getWindowWidth()) {
                                intX = emxUICore.getWindowWidth() - this.layer.offsetWidth  + this.targetFrame.document.body.scrollLeft;
                        }
                } else {
                        intY = emxUICore.getActualTop(this.field) + this.field.offsetHeight;
                        intX = emxUICore.getActualLeft(this.field) + document.body.scrollLeft;
                        if (intY + this.layer.offsetHeight > document.body.scrollTop + emxUICore.getWindowHeight()) {
                                intY = intY - this.field.offsetHeight - this.layer.offsetHeight;
                        }
                        if (intX + this.layer.offsetWidth > document.body.scrollLeft + emxUICore.getWindowWidth()) {
                                intX = emxUICore.getWindowWidth() - this.layer.offsetWidth  + document.body.scrollLeft - 16;
                        }
                        //make sure it's not off the top of the page
                        if (intY < document.body.scrollTop) {
                                intY = document.body.scrollTop;
                        }
                        if ((document.body.scrollLeft + emxUICore.getWindowWidth()) - (intX + this.layer.offsetWidth) < 16) {
                        	intX -= 16;
                        }


                }
                emxUICore.moveTo(this.layer, intX, intY);
                emxUICore.show(this.layer);
                var objThis = this;
                var fnTemp = function () {
						if(isIE){
							var objTarget = null;
							if(window.event){
								objTarget = window.event.target;
								if(!objTarget){
									objTarget = window.event.srcElement;
								}
								if (objThis.isCalendarElement(objTarget)){
									window.event.cancelBubble = true;
								} else {
									objThis.hide();
								}
							}
						}else{
							var objEvent = emxUICore.getEvent();
							if (objThis.isCalendarElement(objEvent.target)){
								objEvent.stopPropagation();
							} else {
								objThis.hide();
							}
						}
		        };
	            attachEventHandler(window,"scroll", function () { objThis.hide(); }, true);
	            emxUICore.iterateFrames(function (objFrame) {
	            	if(objFrame){
	            		if(isIE){
		        	    	objFrame.document.onmousedown = fnTemp;
		        	    } else {
		        	    	window.addEventListener("mousedown", fnTemp, false);
		        	    }
	            	}
	            });

        //}
};
//! Protected Method emxUIPopupCalendar.setInitialDate()
//!     This method sets the initial date value of the calendar.
emxUIPopupCalendar.prototype.setInitialDate = function _emxUIPopupCalendar_setInitialDate(intYear, intMonth, intDay) {
        if (!this.initialized) {
                this.setSelectedDate(new Date(intYear, intMonth, intDay));
                this.setCurrentDate(new Date(intYear, intMonth, intDay));
                this.initialized = true;
        } else if (this.remember && emxUIPopupCalendar.prevDate) {
                this.setSelectedDate(new Date(emxUIPopupCalendar.prevDate));
                this.setCurrentDate(new Date(emxUIPopupCalendar.prevDate));
        }
};
//! Private Method emxUIPopupCalendar.setInputValue()
//!     This method sets the input field values.
emxUIPopupCalendar.prototype.setInputValue = function _emxUIPopupCalendar_setInputValue(strVisibleValue, strHiddenValue) {
        this.field.value = strVisibleValue;
        if (this.hiddenField) {
                this.hiddenField.value = this.selectedDate.getTime() + 12 * 60 * 60 * 1000;
        }
        this.callback();
};
//! Public Function showCalendar()
//!     This function shows the calendar picker.
//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
var REQUESTMAP = "";
var clickedOnCalIcon = "false";
var calStartDate_msValue= "";
var calEndDate_msValue = "";
var arrCalDates = new Array();
var arrNonWorkingDayIden = new Array();
var arrNonWorkingDayColor = new Array();
var isNewCal = true;

//Addde extra argument requestMap in showCalendar method
//End
function showCalendar(strFormName, strInputName,strInitialDate, blnRemember, fnCallback, objWindow, objTargetFrame,requestMapObj) {

	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
	if(requestMapObj != null && requestMapObj != 'undefined'){
		REQUESTMAP = requestMapObj;

		if(typeof(REQUESTMAP) != "object"){
			//alert("Is an Object");
			REQUESTMAP = eval("(" + (REQUESTMAP) + ")");
		}
	}
	//!End:For Enhanced Calendar Control:AEF:nr2:20-11-09

	if(strFormName == "editDataForm" || strFormName == "emxCreateForm") {
            try {
            var value = eval(document.forms[strFormName].elements[strInputName + 'AmPm']).value;
            if(value && value != "") {
                strInitialDate = value;
                localCalendars[strInputName] = null;
            }
            }catch(ex) {
                //do nothing
            }
        }
        objWindow = objWindow || self;
        var objForm = emxUICore.getNamedForm(objWindow, strFormName);
        var objCal = localCalendars[strInputName];
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
        clickedOnCalIcon = "true";
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09

        if(!objCal) {
                objCal = new emxUIPopupCalendar(strInputName, objWindow.document, objTargetFrame);
                isNewCal = true;
        }else{
        	//objCal.draw(objCal.layer);
        	isNewCal = false;
        }
        objCal.remember = !!blnRemember;
        objCal.callback = fnCallback || new Function();

        objCal.show(objWindow.document, objForm, strInitialDate);
        if(strFormName == "editDataForm") {
            try {
                eval(document.forms['editDataForm'].elements[strInputName + 'AmPm']).value = "";
            }catch(e) {
            }
        }

}
//! Public Function showCalendar2()
//!     This function shows the calendar picker without assigning input information.
function showCalendar2(strFormName, strInputName, strInitialDate, blnRemember, fnCallback, objWindow, objTargetFrame,requestMapObj) {
	//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
	if(requestMapObj != null && requestMapObj != 'undefined'){
		REQUESTMAP = requestMapObj;

		//Convert REQUESTMAp to Object
		if(typeof(REQUESTMAP) != "object"){
			REQUESTMAP = eval("(" + (REQUESTMAP) + ")");
		}
	}
	//!End:For Enhanced Calendar Control:AEF:nr2:20-11-09

		objWindow = objWindow || self;
        var objForm = objWindow.document.forms[strFormName];
        var objCal = localCalendars[strInputName];
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
        clickedOnCalIcon = "true";
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09

        if(!objCal) {
                objCal = new emxUIPopupCalendar(strInputName, objWindow.document, objTargetFrame);
        }
        objCal.remember = !!blnRemember;
        objCal.callback = fnCallback || new Function();
        objCal.show2(objWindow.document, objForm, strInitialDate);
}
//! Private Function trim
//!     This method trims the leading and trailing whitespace characters
//!     from a string.
function trim(strString) {
	if(strString != null) {
        strString = strString.replace(/^\s*/g, "");
        strString = strString.replace(/\s+$/g, "");
	}
	return strString;
}

//!Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
//!These functions below are to implement Ajax call to a jsp which calls a JPO

function calNonWDindex(calObj,tempObjDate){
	var iFound= -1;
	if(arrCalDates == null || arrCalDates == 'undefined')
		return -1;

	for(var i=0;i<arrCalDates.length && arrCalDates != null && arrCalDates != "undefined";i++){
		if(tempObjDate.getFullYear() == arrCalDates[i].getFullYear() && tempObjDate.getMonth() == arrCalDates[i].getUTCMonth()
                  && tempObjDate.getDate() == arrCalDates[i].getUTCDate()){
			iFound = i;
			break;
		}
	}
	return iFound;
}

function startEnhCalAjaxCall(calStartDate,calEndDate){
	var queryString = createQuery(calStartDate,calEndDate);
	var retValfromServer = emxUICore.getData(queryString);
	parseResult(retValfromServer);
}

function createQuery(calStartDate,calEndDate){
	if(typeof(REQUESTMAP) != "object"){
		requestMapObj = eval("(" + (REQUESTMAP) + ")");
	}
	else
		var requestMapObj = REQUESTMAP;

	if(typeof(requestMapObj) == 'object'){
		var querystring = "../common/emxCallCalendarControlJPO.jsp?";
		querystring += "&currtimeStamp=" + (new Date).getTime();
		querystring += "&CalendarProgram=" + requestMapObj.CalendarProgram;
		querystring += "&CalendarFunction=" + requestMapObj.CalendarFunction;
		querystring += "&calBeanTimeStamp=" + requestMapObj.calBeanTimeStamp;
		querystring += "&objectId=" + requestMapObj.objectId;
		querystring += "&relationId=" + requestMapObj.relationId;
		querystring += "&calStartDate=" + calStartDate;
		querystring += "&calEndDate=" + calEndDate;
		querystring += "&componentType=" + requestMapObj.componentType;
		//Added:25-01-10:nr2:IR-035216V6R2011
		querystring += "&columnName=" + requestMapObj.columnName;
		//End:25-01-10:nr2:IR-035216V6R2011
		querystring += "&mode=" + requestMapObj.mode;

	}
	return querystring;
}
function parseResult(retValfromServer){
	var retVal = retValfromServer.split(",");

	for(var i=0;i<retVal.length;i++){
		arrCalDates[i] = new Date(retVal[i].split("|")[0]*1);
		arrNonWorkingDayIden[i] = retVal[i].split("|")[1];
		arrNonWorkingDayColor[i] = retVal[i].split("|")[2] + "|" + retVal[i].split("|")[3];
	}
}
//This function added for specific to IE8 ..Slide-In page shrinking if it has Date Picker
function hide_IE(objElement) {
  if(isIE){
  	setTimeout(function(){ objElement.style.visibility = "hidden";},20);
}else{
  	objElement.style.visibility = "hidden";}
};

//!End Function here
