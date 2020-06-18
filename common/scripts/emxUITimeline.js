/*=================================================================
 *  JavaScript Timeline Component
 *  Requires: emxUIConstants.js, emxUICore.js
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUITimeline.js.rca 1.10 Wed Oct 22 15:47:56 2008 przemek Experimental przemek $
 *=================================================================
 */

/**
 * Roadmap object.
 * @class
 */
function emxUIRoadmap(intIntervalType) {

    /**
     * Sets the type of intervals for the map.
     * @scope private
     */
    this.intervalType = intIntervalType;

    /**
     * Array of roadmap item objects
     * @scope protected
     */
    this.items = [];

    /**
     * Array of emxUIRoadmapYearSection objects.
     * @scope protected
     */
    this.yearSections = [];

    /**
     * The date of the earliest milestone for any item.
     * @scope protected
     */
    this.firstDate = new Date();

    /**
     * The date of the latest milestone for any item.
     * @scope protected
     */
    this.lastDate = null;
    
    /**
     * Determines if tooltips should be shown or not.
     * @scope protected
     */
    this.showTooltips = true;
    
    /**
     * Timeline to determine all years and intervals
     * @scope protected
     */
    this.timeline = null;
    
    //generate the intervals
    this.generateIntervals();
}

emxUIRoadmap.INTERVAL_WEEKS = 0;
emxUIRoadmap.INTERVAL_MONTHS = 1;
emxUIRoadmap.INTERVAL_THIRDS = 2;
emxUIRoadmap.INTERVAL_QUARTERS = 3;
emxUIRoadmap.INTERVAL_HALVES = 4;
emxUIRoadmap.INTERVAL_YEARS = 5;

emxUIRoadmap.INTERVALS = [53, 12, 3, 4, 2, 1];

/**
 * Sets whether or not tooltips should be displayed.
 * @param blnShow True to show tooltips, false if not.
 * @scope public
 */
emxUIRoadmap.prototype.setShowTooltips = function (blnShow) {
    this.showTooltips = blnShow;
};
 
/**
 * Creates the timeline object.
 * @scope protected
 * @return The timeline object.
 */
emxUIRoadmap.prototype.createTimeline = function () {
    this.timeline = new emxUIRoadmapTimeline(this.intervalType, this.firstDate, this.lastDate);
    return this.timeline;
};

/**
 * Returns the timeline object.
 * @scope public
 * @return The timeline object.
 */
emxUIRoadmap.prototype.getTimeline = function () {
    return this.timeline;
};

/**
 * Adds an item to the roadmap.
 * @param objItem The item to add.
 * @scope public
 */
emxUIRoadmap.prototype.addItem = function (objItem) {
    this.items.push(objItem);

    //determine if there needs to be new first and last dates
    if (objItem.firstDate.getTime() < this.firstDate.getTime()) {
        this.firstDate = objItem.firstDate;
    }

    if (this.lastDate == null || objItem.lastDate.getTime() > this.lastDate.getTime()) {
        this.lastDate = objItem.lastDate;
    }
};

/**
 * Adds a year section to the roadmap year.
 * @param objSection The emxUIRoadmapSection object to add.
 * @scope public
 */
emxUIRoadmap.prototype.addYearSection = function (objSection) {
    this.yearSections.push(objSection);
};

/**
 * Sets up the intervals for the roadmap.
 * @scope private
 */
emxUIRoadmap.prototype.generateIntervals = function () {
    var intCount = emxUIRoadmap.INTERVALS[this.intervalType];
    
    for (var i=0; i < intCount; i++) {
        this.addYearSection(new emxUIRoadmapSection(i+1));
    }
};

/**
 * Represents a section of a year on a roadmap.
 * @class
 */
function emxUIRoadmapSection(strLabel) {

    /**
     * The label to display for the section.
     * @scope private
     */
    this.label = strLabel;
    
    /**
     * The start of the year section.
     * @scope private
     */
    this.startDate = null;
    
    /**
     * The end of the year section.
     * @scope private
     */
    this.endDate = null;
}

/**
 * Returns the label for this section.
 * @return The label for this section.
 * @scope public
 */
emxUIRoadmapSection.prototype.getLabel = function () {
    return this.label;
};

/**
 * Returns the start date for this section.
 * @return The start date for this section.
 * @scope public
 */
emxUIRoadmapSection.prototype.getStartDate = function () {
    return this.startDate;
};

/**
 * Returns the end date for this section.
 * @return The end date for this section.
 * @scope public
 */
emxUIRoadmapSection.prototype.getEndDate = function () {
    return this.endDate;
};

/**
 * Sets the start date for this section.
 * @param objDate The start date for this section.
 * @scope public
 */
emxUIRoadmapSection.prototype.setStartDate = function (objDate) {
    this.startDate = objDate;
};

/**
 * Sets the end date for this section.
 * @param objDate The end date for this section.
 * @scope public
 */
emxUIRoadmapSection.prototype.setEndDate = function (objDate) {
    this.endDate = objDate;
};

/**
 * Sets the label for the section
 * @scope public
 * @param strLabel The new label for the section.
 */
emxUIRoadmapSection.prototype.setLabel = function (strLabel) {
    this.label = strLabel;
};

/**
 * A timeline of dates to display on a roadmap.
 * @scope public
 * @class
 */
function emxUIRoadmapTimeline(intIntervalType, objFirstDate, objLastDate) {

   /**
    * The type of intervals to use per year.
    * @scope private
    */
   this.intervalType = intIntervalType;
   
   /**
    * Array of year objects in the timeline.
    * @scope public
    */
   this.years = new Array;
   
   /**
    * The earliest date on the timeline.
    * @scope private
    */
   this.firstDate = objFirstDate;
   
   /**
    * The latest date on the timeline.
    * @scope private
    */
   this.lastDate = objLastDate;
   
   //calculate all the intervals
   this.calculateAllIntervals();
};

/**
 * Calculates the intervals and years for the timeline.
 * @scope private
 */
emxUIRoadmapTimeline.prototype.calculateAllIntervals = function () {
    switch(this.intervalType) {
        case emxUIRoadmap.INTERVAL_WEEKS:
            this.calculateWeekIntervals();
            break;
        case emxUIRoadmap.INTERVAL_MONTHS:
            this.calculateMonthBasedIntervals(12);
            break;
        case emxUIRoadmap.INTERVAL_THIRDS:
            this.calculateMonthBasedIntervals(3);
            break;
        case emxUIRoadmap.INTERVAL_QUARTERS:
            this.calculateMonthBasedIntervals(4);
            break;
        case emxUIRoadmap.INTERVAL_HALVES:
            this.calculateMonthBasedIntervals(2);
            break;
        case emxUIRoadmap.INTERVAL_YEARS:
            this.calculateMonthBasedIntervals(1);
            break;
        default:
            throw new Error("Invalid interval type.");       
    }
};


/**
 * Calculates the start and end dates for month-based intervals.
 * @param intSplit The number of intervals in a given year.
 * @scope private
 */
emxUIRoadmapTimeline.prototype.calculateMonthBasedIntervals = function (intSplit) {
    var intStartYear = this.firstDate.getFullYear();
    var intYears = this.lastDate.getFullYear() - this.firstDate.getFullYear() + 1;
    var intMonthsPerInterval = 12/intSplit;
    var objYear;
    
    for (var i=0; i < intYears; i++) {
        
        objYear = new emxUIRoadmapYear(intStartYear+i);
                    
        for (var j=0, intYearSection = 0; j < intSplit; j++, intYearSection++) {
            var intStartMonth = j*intMonthsPerInterval;
            var intEndMonth = intStartMonth + intMonthsPerInterval-1;
            var objStartDate = new Date(intStartYear+i, intStartMonth, 1);
            
            var objEndDate = new Date(intStartYear+i, intEndMonth, 28);
            while (objEndDate.getMonth() == intEndMonth) {
                objEndDate.setDate(objEndDate.getDate()+1);
            }
            objEndDate.setDate(0);
            objEndDate.setHours(12);
            objStartDate.setHours(12);
            
            if (objEndDate.valueOf() >= this.firstDate.valueOf() && 
                  objStartDate.valueOf() <= this.lastDate.valueOf()) {
            
                objYear.addInterval(new emxUIRoadmapInterval(objStartDate, objEndDate, intYearSection));
            }   
        }
        
        this.years.push(objYear);
    }    
};

/**
 * Calculates the start and end dates for week intervals.
 * @scope private
 */
emxUIRoadmapTimeline.prototype.calculateWeekIntervals = function () {
    var intStartYear = this.firstDate.getFullYear();
    var intLastYear = this.lastDate.getFullYear();
    var intYears = this.lastDate.getFullYear() - this.firstDate.getFullYear() + 1;
    var objFirstDay, objLastDay;  
    var objYearLastDay;
    var objYear, intLastWeekNum = -1;
    
    for (var i=0; i < intYears; i++) {
    
        objYear = new emxUIRoadmapYear(intStartYear+i);
        
        objFirstDay = new Date(intStartYear+i, 0, 1);
        objLastDay = new Date(intStartYear+i, 0, 6 - objFirstDay.getDay() + 1);
        objLastDay.setHours(12);
        objFirstDay.setHours(12);
        var intWeekNum =  objLastDay.getDate() > 2 ? 1 : 0;
        //fix for date in previous year's ISO week
        if (intWeekNum == 0 && i == 0 && this.firstDate.getMonth() == 11 && this.firstDate.getDate() > 25) {
        var objFirstYear = new emxUIRoadmapYear(intStartYear-1);
            objFirstYear.addInterval(new emxUIRoadmapWeekInterval(objFirstDay, objLastDay, 52));
            this.years.push(objFirstYear);
        }
               
        //main date loop
        do {
            
            if (intWeekNum > 0 && objLastDay >= this.firstDate && objFirstDay <= this.lastDate) {
                
                objYear.addInterval(new emxUIRoadmapWeekInterval(objFirstDay, objLastDay, intWeekNum));
                intLastWeekNum = intWeekNum;
                
            //if the first and last days of the week are both past the last date
            //in the timeline, then exit the loop
            } else if (objFirstDay > this.lastDate && objLastDay > this.lastDate) {
                break;
            }

            objFirstDay = new Date(intStartYear+i, objLastDay.getMonth(), objLastDay.getDate() + 1);
            objLastDay = new Date(objFirstDay.getFullYear(), objFirstDay.getMonth(), objFirstDay.getDate() + 6);
            objLastDay.setHours(12);
            objFirstDay.setHours(12);
            
            intWeekNum++;        
        } while(objLastDay.getFullYear() == intStartYear+i)
        
        //check to see if this is a week where some days are in one year and some are in the next (Dec/Jan)
        if (objFirstDay.getFullYear() == intStartYear+i && objLastDay.getFullYear() != intStartYear+i) {
            
            var objOrigLastDay = new Date(objLastDay.getTime());
            objOrigLastDay.setHours(12);
            while(objLastDay.getFullYear() != intStartYear+i) {
                objLastDay.setDate(objLastDay.getDate() - 1);
            }
           //if the day is Wednesday or greater, add it to this year
            if (objLastDay.getDay() > 2) {
                if (intLastWeekNum > 50 && intLastWeekNum < 53) {
                    objYear.addInterval(new emxUIRoadmapWeekInterval(objFirstDay, objOrigLastDay, intWeekNum));
                }
            } else {
                if (i == intYears-1) {
                    this.years.push(objYear);
                    objYear = new emxUIRoadmapYear(intStartYear + intYears);
                    objYear.addInterval(new emxUIRoadmapWeekInterval(objFirstDay, objOrigLastDay, 1));
                } 
                /*Begin of add:Infosys for Bug # 302852 on 5/4/2005*/
                else {
                    objYearLastDay = new Date(objFirstDay.getFullYear(), 11, 31);
                    objYearLastDay.setHours(12);
                    objYear.addInterval(new emxUIRoadmapWeekInterval(objFirstDay,objYearLastDay, intWeekNum));
                   }
                /*End of add:Infosys for Bug # 302852 on 5/4/2005*/
            }                        
        }
        
        this.years.push(objYear);
    }      
    
};

/**
 * Locates a given date within the time line.
 * @scope protected
 * @param objDate The date to find.
 * @return An array containing the year, the interval, and the overall interval position.
 */
emxUIRoadmapTimeline.prototype.findInInterval = function(objDate) {

    var intPos = 0;
    for (var i=0; i < this.years.length; i++) {
        for (var j=0; j < this.years[i].intervals.length; j++, intPos++) {
            if (this.years[i].intervals[j].startDate.valueOf() <= objDate.valueOf() 
                  && this.years[i].intervals[j].endDate.valueOf() >= objDate.valueOf()) {
                return [i,j,intPos];   
            }
        }
    };
    
    return -1;

};

/**
 * Represents a year on the roadmap.
 * @class
 * @scope public
 */
function emxUIRoadmapYear(intYear) {

    /**
     * The actual year.
     * @scope private
     */
    this.year = intYear;
    
    /**
     * Array of intervals for the year.
     * @scope protected
     */
    this.intervals = new Array;
}

/**
 * Adds an interval to the roadmap year.
 * @scope public
 * @param objInterval The interval object to add.
 */
emxUIRoadmapYear.prototype.addInterval = function (objInterval) {
    this.intervals.push(objInterval);
};

/**
 * Returns the numeric value of the roadmap year.
 * @scope public
 */
emxUIRoadmapYear.prototype.valueOf = function () {
    return this.year;
};

/**
 * Returns the string value of the roadmap year.
 * @scope public
 */
emxUIRoadmapYear.prototype.toString = function() {
    return this.year.toString();
};

/**
 * Represents an interval on a timeline.
 * @scope public
 * @class
 */
function emxUIRoadmapInterval(objStartDate, objEndDate, intYearSectionIndex) {

    /**
     * The day on which the interval starts.
     * @scope private
     */
    this.startDate = objStartDate;
    
    /**
     * The day on which the interval ends.
     * @scope private
     */
    this.endDate = objEndDate;
    
    /**
     * The index of the year section containing the label for this interval.
     * @scope protected
     */
    this.yearSectionIndex = intYearSectionIndex;
}

/**
 * Returns the starting date of the interval.
 * @scope public
 * @return The starting date of the interval.
 */
emxUIRoadmapInterval.prototype.getStartDate = function () {
    return this.startDate;
};

/**
 * Returns the ending date of the interval.
 * @scope public
 * @return The ending date of the interval.
 */
emxUIRoadmapInterval.prototype.getEndDate = function () {
    return this.endDate;
};

/**
 * Returns the number of days in the interval.
 * @scope public
 * @return The number of days in the interval.
 */
emxUIRoadmapInterval.prototype.getDayCount = function () {
    return (this.endDate.valueOf() - this.startDate.valueOf()) / 86400000 + 1;
};

/**
 * Custom interval for use with weeks.
 * @scope public
 * @class
 */
function emxUIRoadmapWeekInterval(objStartDate, objEndDate, intWeek) {

    /*
     * Inherit from emxUIRoadmapInterval
     */
    emxUIRoadmapInterval.call(this, objStartDate, objEndDate, intWeek-1);
    
    /**
     * The number of the week for the year.
     * @scope private
     */
    this.week = intWeek;
}

emxUIRoadmapWeekInterval.prototype = new emxUIRoadmapInterval;

/**
 * Returns the week number for the interval.
 * @scope public
 * @return The week number for the interval.
 */
emxUIRoadmapWeekInterval.prototype.getWeek = function () {
    return this.week;
};


/**
 * A popup menu for the roadmap.
 * @scope protected
 */
function emxUIRoadmapMenu() {
    emxUIMenu.apply(this);
}

emxUIRoadmapMenu.prototype = new emxUIMenu;

/**
 * Displays the popup menu.
 * @param intX The x-coordinate to show the popup menu at.
 * @param intY The y-coordinate to show the popup menu at.
 * @scope protected
 */
emxUIRoadmapMenu.prototype.show = function _emxUICorePopupMenu_show(intX, intY) {
        var objThis = this;
        if (isMinIE55 && isWin) {

                this.popup.show(intX, intY, this.finalWidth + 4, this.finalHeight, document.body);
                this.timeoutID = setTimeout(function () {
                        if (objThis.popup.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, emxUICoreMenu.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        } 
                }, emxUICoreMenu.WATCH_DELAY);
        } else {
                if (this.ownerWindow != this.displayWindow) {
                        if (!this.displayWindow.document.getElementById("menu" + this.uniqueID)) {
                                this.createDOM(this.displayWindow.document);
                                this.layer.id = "menu" + this.uniqueID;
                        } 
                }
                
                var intFinalX = intX + this.templateInnerLayer.offsetWidth;
                var intFinalY = intY + this.finalHeight;
                if (intFinalX > getTimeLineWindowWidth(this.displayWindow) + this.displayWindow.document.body.scrollLeft) {
                        intX = this.displayWindow.document.body.scrollLeft + getTimeLineWindowWidth(this.displayWindow) - this.layer.offsetWidth;
                } else if (intX < 0) {
                        intX = 0;
                } 
                if (intFinalY > getTimeLineWindowHeight(this.displayWindow) + this.displayWindow.document.body.scrollTop) {
                        intY = this.displayWindow.document.body.scrollTop + getTimeLineWindowHeight(this.displayWindow) - this.layer.offsetHeight;
                } else if (intY < 0) {
                        intY = 0;
                } 
                emxUICore.moveTo(this.layer, intX, intY);
                emxUICore.show(this.layer);                
                this.fnTemp = fnTemp = function () { objThis.hide();};
                emxUICore.iterateFrames(function (objFrame) { 
                                objFrame.addEventListener("mousedown", fnTemp, false); 
                                if (!isUnix) objFrame.addEventListener("resize", fnTemp, false); 
                });
        } 
        this.visible = true;
        this.fireEvent("show");
}; 


 
/**
 * Layout control for a roadmap page.
 * @class
 */
function emxUIRoadmapLayout(objRoadmap) {

    /**
     * Pointer to roadmap object.
     * @scope private
     */
    this.roadmap = objRoadmap;

    /**
     * Pointer to page header layer.
     * @scope private
     */
    this.pageHeader = null;

    /**
     * Pointer to roadmap header layer.
     * @scope private
     */
    this.roadmapHeader = null;

    /**
     * Pointer to roadmap header container layer.
     * @scope private
     */
    this.roadmapHeaderContainer = null;

    /**
     * Pointer to roadmap body layer.
     * @scope private
     */
    this.roadmapBody = null;
    
    /**
     * Tooltip manager object.
     * @scope private
     */
    this.tooltipManager = new emxUITooltipManager();

};
emxUIRoadmapLayout.PIXEL_SIZE = 48;

emxUIRoadmapLayout.VSPACE_BETWEEN = 32;

emxUIRoadmapLayout.INTERVAL_WIDTH = new Array;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_WEEKS] = 96;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_MONTHS] = 96;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_THIRDS] = 96;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_QUARTERS] = 96;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_HALVES] = 96;
emxUIRoadmapLayout.INTERVAL_WIDTH[emxUIRoadmap.INTERVAL_YEARS] = 366;

emxUIRoadmapLayout.LINE_X_OFFSET = 16;
emxUIRoadmapLayout.ICON_X_OFFSET = -8;
emxUIRoadmapLayout.ICON_Y_OFFSET = 10;
emxUIRoadmapLayout.LINE_Y_OFFSET = 12;
emxUIRoadmapLayout.DETAILS_HEIGHT = emxUIRoadmapLayout.PIXEL_SIZE;

emxUIRoadmapLayout.IMG_LEFT_ARROW = emxUIConstants.DIR_IMAGES + "utilRoadmapLeftArrow.gif";
emxUIRoadmapLayout.IMG_RIGHT_ARROW = emxUIConstants.DIR_IMAGES + "utilRoadmapRightArrow.gif";
emxUIRoadmapLayout.ARROW_Y_OFFSET = 4;
emxUIRoadmapLayout.ARROW_X_OFFSET = 20;

/**
 * Initializes the pointers to various parts of the page.
 * @scope protected
 */
emxUIRoadmapLayout.prototype.init = function () {
    this.pageHeader = document.getElementById("pageHeadDiv");
    this.roadmap.createTimeline();

    this.initRoadmapHeader();
    this.initRoadmapBody();

    this.reflow();
};

/**
 * Initializes roadmap header.
 * @scope private
 */
emxUIRoadmapLayout.prototype.initRoadmapHeader = function () {
    this.roadmapHeaderContainer = document.createElement("div");
    this.roadmapHeaderContainer.id = "divRoadmapHeadContainer";
    this.roadmapHeaderContainer.style.overflow = "hidden";
    this.roadmapHeaderContainer.style.width = "100%";
    this.roadmapHeaderContainer.style.position = "absolute";
    this.roadmapHeaderContainer.style.left = "0px";

    this.roadmapHeader = document.createElement("div");
    this.roadmapHeader.id = "divRoadmapHead";
    this.roadmapHeaderContainer.appendChild(this.roadmapHeader);

    var objTable = document.createElement("table");
    objTable.id = "tableRoadmapHead";
    objTable.border = 0;
    objTable.cellPadding = 0;
    objTable.cellSpacing = 0;
    objTable.style.tableLayout = "fixed";

    objTable.createTHead();
    var objRow = objTable.tHead.insertRow(0);
    objRow.id = "trSecondHeaders";

    var objTimeline = this.roadmap.timeline;
    
    for (var i=0; i < objTimeline.years.length; i++) {
        var objTH = document.createElement("th");
        objTH.innerHTML = objTimeline.years[i];
        objTH.colSpan = objTimeline.years[i].intervals.length;       
        objRow.appendChild(objTH);
    }
    
    var intTableWidth = 0;
    var intIntervalWidth = emxUIRoadmapLayout.INTERVAL_WIDTH[objTimeline.intervalType];
    
    if (this.roadmap.yearSections.length > 1) {
        objRow = objTable.tHead.insertRow(1);
        objRow.id = "trFirstHeaders";

        for (var i=0; i < objTimeline.years.length; i++) {
            for (var j=0; j < objTimeline.years[i].intervals.length; j++) {
                var objTH = document.createElement("th");
                objTH.innerHTML = this.roadmap.yearSections[objTimeline.years[i].intervals[j].yearSectionIndex].getLabel();
                objTH.style.width = intIntervalWidth + "px";
                intTableWidth += intIntervalWidth;
                objRow.appendChild(objTH);
            }

        }
    } else {
        intTableWidth = intIntervalWidth * objTimeline.years.length;
    }

    objTable.style.width = intTableWidth + "px";
    this.roadmapHeader.appendChild(objTable);
    document.body.appendChild(this.roadmapHeaderContainer);

};

/**
 * Initializes roadmap body.
 * @scope private
 */
emxUIRoadmapLayout.prototype.initRoadmapBody = function () {

    //Step 1: build container
    this.roadmapBody = document.createElement("div");
    this.roadmapBody.id = "divRoadmapBody";
    this.roadmapBody.style.position = "absolute";
    this.roadmapBody.style.left = "0px";
    this.roadmapBody.style.width = "100%";
    this.roadmapBody.onscroll = function () { page.getLayout().syncScroll(); };


    //Step 2: build table
    var objTable = document.createElement("table");
    objTable.border = 0;
    objTable.cellPadding = 0;
    objTable.cellSpacing = 0;
    objTable.id = "tableRoadmapBody";
    //objTable.style.tableLayout = "fixed";
    
    var objRow = objTable.insertRow(0);

    objTable.style.height = Math.max(500,(emxUIRoadmapLayout.VSPACE_BETWEEN +  emxUIRoadmapLayout.DETAILS_HEIGHT + (emxUIRoadmapLayout.LINE_Y_OFFSET * 3)) * this.roadmap.items.length) + "px";
    //objTable.style.height = "500px";
    
    var intTableWidth = 0;

    var objTimeline = this.roadmap.timeline;
    var intIntervalWidth = emxUIRoadmapLayout.INTERVAL_WIDTH[objTimeline.intervalType];
        
    for (var i=0; i < objTimeline.years.length; i++) {
        for (var j=0; j < objTimeline.years[i].intervals.length; j++) {
            var objTD = document.createElement("td");
            objTD.innerHTML = "&nbsp;";
            objTD.className = j % 2 == 0 ? "even" : "odd";
            objTD.style.width = intIntervalWidth + "px";
            intTableWidth += intIntervalWidth;
            objRow.appendChild(objTD);
        }
    }

    objTable.style.width = intTableWidth + "px";
    this.roadmapBody.appendChild(objTable);
    document.body.appendChild(this.roadmapBody);

    //Step 3: build map
   
    var intLastPos = emxUIRoadmapLayout.VSPACE_BETWEEN;

    for (var i=0; i < this.roadmap.items.length; i++) {
        var objItem = this.roadmap.items[i];
        objItem.render(this.roadmapBody);
        
        //sort the milestones
        objItem.milestones.sort(compareMilestones);
        
        this.tooltipManager.addTooltipFor(objItem.node.firstChild, objItem.tooltip);
        
        var objIntervalInfo1 = objTimeline.findInInterval(objItem.firstDate);
        var objIntervalInfo2 = objTimeline.findInInterval(objItem.lastDate);
        
        var intPos1 = this.intervalToPos(objIntervalInfo1, objItem.firstDate); // + emxUIRoadmapLayout.LINE_X_OFFSET;
        var intPos2 = this.intervalToPos(objIntervalInfo2, objItem.lastDate); // + emxUIRoadmapLayout.LINE_X_OFFSET;
        
        var objItemImage = objItem.node.childNodes[0];
        var objItemDesc = objItem.node.childNodes[1];
        var intTextWidth = objItemDesc.offsetWidth;                
        
        objItemImage.style.position = "absolute";
        objItemImage.style.top = "0px";
        objItemDesc.style.position = "absolute";
        objItemDesc.style.top = "0px";
        objItemImage.style.left = "0px";
        objItemDesc.style.left = emxUIRoadmapLayout.PIXEL_SIZE+"px";
        
        objItem.node.style.left = intPos1 + "px";
        objItem.node.style.top = intLastPos+"px";
        

        intLastPos += emxUIRoadmapLayout.DETAILS_HEIGHT + emxUIRoadmapLayout.LINE_Y_OFFSET;

        objItem.line.style.top = intLastPos + "px";
        objItem.line.style.left = (intPos1) + "px";
        objItem.line.style.width = (intPos2-intPos1) + "px";
       
        if (objItem.moreMilestonesLeft) {
            var objLeftImage = document.createElement("img");
            objLeftImage.src = emxUIRoadmapLayout.IMG_LEFT_ARROW;
            objLeftImage.style.position = "absolute";
            objLeftImage.style.top = (intLastPos - emxUIRoadmapLayout.ARROW_Y_OFFSET) + "px";
            objLeftImage.style.left = "0px";
            objLeftImage.style.zIndex = 11;
            objItem.line.style.width = (parseInt(objItem.line.style.width) + parseInt(objItem.line.style.left) - 16) + "px";
            objItem.line.style.left = 16 + "px";
            this.roadmapBody.appendChild(objLeftImage);
        }
        
         if (objItem.moreMilestonesRight) {
            var objRightImage = document.createElement("img");
            objRightImage.src = emxUIRoadmapLayout.IMG_RIGHT_ARROW;
            objRightImage.style.position = "absolute";
            objRightImage.style.top =(intLastPos - emxUIRoadmapLayout.ARROW_Y_OFFSET) +"px";
            objRightImage.style.left = (intTableWidth - emxUIRoadmapLayout.ARROW_X_OFFSET)+"px";    
            
            objRightImage.style.zIndex = 11;
            objItem.line.style.width = (intTableWidth - parseInt(objItem.line.style.left) - 16)+ "px";
                    
            this.roadmapBody.appendChild(objRightImage);
        }

        var anchorPos = -1;
        
        var intLastLeft = 0;
        var objMulti = null;
        var arrMilestones = new Array;
        var objMilestoneAnchor = objItem.milestones[objItem.anchor];
        var objLast = null;
               
       //check for milestones to be combined
        for (var j=0; j < objItem.milestones.length; j++) {
            var objMilestone = objItem.milestones[j];
            var objIntervalInfo = objTimeline.findInInterval(objMilestone.getDate());       
            var intLeft = this.intervalToPos(objIntervalInfo, objMilestone.getDate());

            if ((intLeft - intLastLeft) < 12 && j > 0) {
                if (objMulti == null) {
                    objMulti = new emxUIRoadmapMultiMilestone();
                    objLast = arrMilestones.pop();
                    objMulti.addMilestone(objLast);
                    if (objLast == objMilestoneAnchor) {
                        objMilestoneAnchor = objMulti;
                    }
                    
                }
                
                objMulti.addMilestone(objMilestone);
                
                if (j == objItem.anchor) {
                    objMilestoneAnchor = objMulti;
                }  
                
            } else {
                if (objMulti != null) {
                    arrMilestones.push(objMulti);
                    objMulti = null;
                }
                
                arrMilestones.push(objMilestone);
                          
            }
            //Begin of Add by Vibhu,Infosys for Bug303408 on 2nd May,05
            if(j == objItem.milestones.length-1 && objMulti !=null)
            {
                arrMilestones.push(objMulti);
            }
            //End of Add by Vibhu,Infosys for Bug303408 on 2nd May,05
            intLastLeft = intLeft;

        }
        
        //lay out the milestones
        for (var j=0; j < arrMilestones.length; j++){
            var objMilestone = arrMilestones[j];       
            objMilestone.render(this.roadmapBody);
            var objIntervalInfo = objTimeline.findInInterval(objMilestone.getDate());       
            var intLeft = this.intervalToPos(objIntervalInfo, objMilestone.getDate());
            
            objMilestone.node.style.left = (intLeft + emxUIRoadmapLayout.ICON_X_OFFSET) +"px";
            objMilestone.node.style.top = intLastPos + emxUIRoadmapLayout.ICON_Y_OFFSET +"px";
            
            this.tooltipManager.addTooltipFor(objMilestone.node, objMilestone.tooltip);            
            
            var objDiv = document.createElement("div");
            objDiv.className = "roadmap-tick";
            objDiv.style.position = "absolute";
            objDiv.style.left = intLeft +"px";
            objDiv.style.top = intLastPos+"px";
            this.roadmapBody.appendChild(objDiv);

            if (objMilestoneAnchor == objMilestone) {
                        
                //make sure the description text is always visible
                if (intTextWidth + emxUIRoadmapLayout.PIXEL_SIZE + intLeft > intTableWidth && intTableWidth > getTimeLineWindowWidth()) {
                    if (intLeft - intTextWidth - 24 > intTableWidth) {
                        objItem.node.style.left = (intTableWidth - intTextWidth - emxUIRoadmapLayout.PIXEL_SIZE - 10)+"px";
                    } else {
                        objItem.node.style.left = (intLeft - intTextWidth - 24 - 5)+"px";
                    }
                    objItemDesc.style.left = "0px";
                    objItemDesc.style.width = intTextWidth +"px";
                    objItemImage.style.left = (intTextWidth+5) + "px";
                } else {
                
                    if (intLeft - 24 > 5) {
                        objItem.node.style.left = (intLeft - 24)+"px";
                    } else {
                        objItem.node.style.left = 5 +"px";
                    }
                    objItemImage.style.left = "0px";
                    objItemDesc.style.left = emxUIRoadmapLayout.PIXEL_SIZE+"px";
                }
            }
        }

        intLastPos += objItem.line.offsetHeight + emxUIRoadmapLayout.VSPACE_BETWEEN;
    }
    
    this.tooltipManager.enabled = this.roadmap.showTooltips;


};

/**
 * Converts an interval number into a position on the screen.
 * @scope private
 * @param objIntervalInfo An array of the year index, interval index, and overall
 *           interval position.
 * @param objDate The date to locate in the interval.
 * @return The x-coordinate of the interval on the screen.
 */
emxUIRoadmapLayout.prototype.intervalToPos = function (objIntervalInfo, objDate) {

    var intIntervalWidth = emxUIRoadmapLayout.INTERVAL_WIDTH[this.roadmap.intervalType];
    var objInterval = this.roadmap.timeline.years[objIntervalInfo[0]].intervals[objIntervalInfo[1]];
    var intDaysIn = (objDate.valueOf() - objInterval.startDate.valueOf()) / 86400000;
    var intDayWidth = Math.floor(intIntervalWidth / objInterval.getDayCount());
    return (objIntervalInfo[2] * intIntervalWidth) + (intDaysIn * intDayWidth) + Math.floor(intDayWidth/2);

};

/**
 * Reflows the page based on new window dimensions.
 * @public

 */
emxUIRoadmapLayout.prototype.reflow = function () {


    this.roadmapHeaderContainer.style.top = this.pageHeader.offsetHeight + "px";
    this.roadmapBody.style.top = (this.pageHeader.offsetHeight + this.roadmapHeader.offsetHeight) + "px";
   
    this.roadmapBody.style.height = (getTimeLineWindowHeight() - parseInt(this.roadmapBody.style.top)) + "px" ;
   
    		
    this.roadmapHeaderContainer.style.width = getTimeLineWindowWidth() + "px";
    this.roadmapBody.style.width = getTimeLineWindowWidth() + "px";

    if (this.roadmapBody.firstChild.offsetWidth > getTimeLineWindowWidth()
            || this.roadmapBody.firstChild.offsetHeight > getTimeLineWindowHeight()) {

        this.roadmapBody.style.overflow = "scroll";
    } else {
        this.roadmapBody.style.overflow = "hidden";
    }

    this.syncScroll();

};

/**
 * Synchronizes the scrolling between the header and body
 * of the roadmap.
 * @scope private
 */
emxUIRoadmapLayout.prototype.syncScroll = function () {
    this.roadmapHeader.style.marginLeft = -this.roadmapBody.scrollLeft + "px";
};

/**
 * Represents a roadmap for an individual
 * product.
 * @class
 */
function emxUIRoadmapProduct(strName, strMarketingName, strImage, strURL, strProjectURL, strTooltip) {

    /**
     * The image to display for the product.
     * @scope private
     */
    this.image = strImage;

    /**
     * The markting name for the product.
     * @scope private
     */
    this.marketingName = strMarketingName;

    /**
     * Array of emxUIRoadmapMilestone objects.
     * @scope protected.
     */
    this.milestones = [];

    /**
     * The name of the product object.
     * @scope private
     */
    this.name = strName;

    /**
     * The DOM representation of the product roadmap.
     * @scope protected
     */
    this.node = null;

    /**
     * The line for the roadmap.
     * @scope protected
     */
    this.line = null;


    /**
     * The date of the first milestone.
     * @scope protected
     */
    this.firstDate = null;


    /**
     * The date of the last milestone.
     * @scope protected
     */
    this.lastDate = null;

    /**
     * The URL with product information.
     * @scope protected
     */
    this.url = strURL;

    /**
     * The URL with project information.
     * @scope protected
     */
    this.projectURL = strProjectURL;

    /**
     * The index of the milestone above which the
     * product image and information should appear.
     * @scope protected
     */
    this.anchor = 0;
    
    /**
     * The tooltip to display for the product.
     * @scope protected
     */
    this.tooltip = null;
    
    /**
     * Flag indicating if there's a milestone just
     * off the screen to the left.
     * @scope protected
     */
    this.moreMilestonesLeft = false;
    
    /**
     * Flag indicating if there's a milestone just
     * off the screen to the right.
     * @scope protected
     */
    this.moreMilestonesRight = false;

}

/**
 * Adds a milestone to the roadmap.
 * @param objMilestone The emxUIRoadmapMilestone object to add.
 */
emxUIRoadmapProduct.prototype.addMilestone = function (objMilestone) {

    this.milestones.push(objMilestone);

    if (!this.firstDate || (this.firstDate.getTime() > objMilestone.getDate().getTime())) {
        this.firstDate = objMilestone.getDate();
    }

    if (!this.lastDate || (this.lastDate.getTime() < objMilestone.getDate().getTime())) {
        this.lastDate = objMilestone.getDate();
    }
    
    return objMilestone;

};

/**
 * Returns the product name.
 * @return The product name.
 */
emxUIRoadmapProduct.prototype.getName = function () {
    return this.name;
};

/**
 * Sets whether there is a milestone just off the screen
 * to the left.
 * @scope public
 * @param blnFlag True if there is a milestone off the screen to the left.
 */
emxUIRoadmapProduct.prototype.setMoreMilestonesLeft = function (blnFlag) {
    this.moreMilestonesLeft = blnFlag;
};

/**
 * Sets whether there is a milestone just off the screen
 * to the right.
 * @scope public
 * @param blnFlag True if there is a milestone off the screen to the right.
 */
emxUIRoadmapProduct.prototype.setMoreMilestonesRight = function (blnFlag) {
    this.moreMilestonesRight = blnFlag;
};



/**
 * Returns the product marketing name.
 * @return The product marketing name.
 */
emxUIRoadmapProduct.prototype.getMarketingName = function () {
    return this.marketingName;
};

/**
 * Renders the product roadmap on the given parent node.
 * @param objParent The DOM node to build upon.
 */
emxUIRoadmapProduct.prototype.render = function (objParent) {

    //create line
    this.line = document.createElement("div");
    this.line.className = "roadmap-line";
    this.line.style.position = "absolute";

    var objThis = this;
    this.line.onclick = function () {
        emxUICore.link(objThis.projectURL);
    };

    objParent.appendChild(this.line);

    //for (var i=0; i < this.milestones.length; i++) {
    //    this.milestones[i].render(objParent);
    //}

    //create display panel
    this.node = document.createElement("div");
    this.node.style.position = "absolute";

    var objA = document.createElement("a");
    objA.href = this.url;
    var objImg = document.createElement("img");
    objImg.border = "0";
    objImg.src = this.image;
    objImg.className = "product-image";

    objA.appendChild(objImg);
    this.node.appendChild(objA);

    var objDiv = document.createElement("div");
    
    objDiv.className = "product-info";
    objDiv.innerHTML = "<span class=\"product-name\">" + this.marketingName + "</span><br /><a href=\""
        + this.url + "\" class=\"object\">" + this.name + "</a><br /><span class=\"product-dates\">"
        + (this.firstDate.getMonth()+1) + "/" + this.firstDate.getFullYear() + " - "
        + (this.lastDate.getMonth()+1) + "/" + this.lastDate.getFullYear() + "</span>";
    this.node.appendChild(objDiv);

    objParent.appendChild(this.node);

};


/**
 * Sets the milestone to anchor the product image and
 * information to.
 * @scope public
 */
emxUIRoadmapProduct.prototype.setMilestoneAnchor = function (intIndex) {
    this.anchor = intIndex;
};

/**
 * Sets the tooltip for the product.
 * @param strTooltip An HTML string containing the tooltip.
 */
emxUIRoadmapProduct.prototype.setTooltip = function (strTooltip) {
    this.tooltip = strTooltip;
};

/**
 * A visual representation of a roadmap milestone.
 * @class
 */
function emxUIRoadmapMilestone(strIcon, strLabel, strDate, strURL) {

    /**
     * The date for this milestone.
     * @scope private
     */
    this.date = new Date(Date.parse(strDate));

    /**
     * The label for this milestone.
     * @scope private
     */
    this.label = strLabel;

    /**
     * The icon for this milestone.
     * @scope private
     */
    this.icon = emxUICore.getIcon(strIcon);


    /**
     * The DOM representation of the milestone.
     * @scope protected
     */
    this.node = null;
    
    /**
     * The tooltip to display for the product.
     * @scope protected
     */
    this.tooltip = null;    

    /**
     * The URL for this milestone's details.
     * @scope private
     */
    this.url = strURL;

}

/**
 * Returns the date for this milestone.
 * @return The date for this milestone.
 */
emxUIRoadmapMilestone.prototype.getDate = function () {
    return this.date;
};

/**
 * Renders the milestone on the given parent node.
 * @param objParent The DOM node to build upon.
 */
emxUIRoadmapMilestone.prototype.render = function (objParent) {

    this.node = document.createElement("a");
    this.node.href = this.url;
    this.node.style.position = "absolute";

    var objImg = document.createElement("img");
    objImg.border = 0;
    objImg.height = 16;
    objImg.width = 16;
    objImg.src = this.icon;
    this.node.appendChild(objImg);

    objParent.appendChild(this.node);

};

/**
 * Sets the tooltip for the milestone.
 * @param strTooltip An HTML string containing the tooltip.
 */
emxUIRoadmapMilestone.prototype.setTooltip = function (strTooltip) {
    this.tooltip = "<div>" + strTooltip + "</div>";
};

/**
 * A visual representation of multiple roadmap milestones.
 * @class
 */
function emxUIRoadmapMultiMilestone() {


    /**
     * The icon for this milestone.
     * @scope private
     */
    this.icon = emxUICore.getIcon("iconStatusMulti.gif");


    /**
     * The DOM representation of the milestone.
     * @scope protected
     */
    this.node = null;
    
    /**
     * The tooltip to display for the product.
     * @scope protected
     */
    this.tooltip = null;    

    /**
     * The milestones represented by this.
     * @scope private
     */
    this.milestones = new Array;
    
    /**
     * The popup menu for the multi milestone.
     * @scope private
     */
    this.menu = new emxUIRoadmapMenu;

}

/**
 * Adds a milestone.
 * @param objMilestone The milestone to add.
 * @return The milestone.
 * @scope public
 */
emxUIRoadmapMultiMilestone.prototype.addMilestone = function (objMilestone) {
    this.milestones.push(objMilestone);
    
    this.menu.addItem(new emxUIMenuItem(objMilestone.icon, objMilestone.label, objMilestone.url));
    
    this.addTooltip(objMilestone.tooltip);
    
    return objMilestone;
};

/**
 * Renders the multi milestone on the given parent node.
 * @param objParent The DOM node to build upon.
 */
emxUIRoadmapMultiMilestone.prototype.render = function (objParent) {

    this.menu.init();

    this.node = document.createElement("img");
    this.node.style.position = "absolute";
    this.node.style.cursor = "pointer";
    this.node.border = 0;
    this.node.src = this.icon

    var objThis = this;
    this.node.onclick = function () {
        var objEvent = emxUICore.getEvent();
        objThis.menu.show(objEvent.clientX, objEvent.clientY);
    };
    
    objParent.appendChild(this.node);

};

/**
 * Adds the tooltip for the milestone.
 * @param strTooltip An HTML string containing the tooltip.
 */
emxUIRoadmapMultiMilestone.prototype.addTooltip = function (strTooltip) {

    if (this.tooltip == null) {
        this.tooltip = strTooltip;
    } else {
        if (strTooltip != null) {
            this.tooltip += strTooltip;
        }
    }
    
};

/**
 * Returns the date of the first milestone.
 * @return The date of the first milestone.
 */
emxUIRoadmapMultiMilestone.prototype.getDate = function () {
    return this.milestones[0].getDate();
};


/**
 * Compares two milestones to see which one comes first.
 * @param objMilestone1 The first milestone.
 * @param objMilestone2 The second milestone.
 * @return 0 if equal, 1 if the first milestone comes after the second,
 *         -1 if the first milestone comes before the second.
 */
function compareMilestones(objMilestone1, objMilestone2) {
    if (objMilestone1.date > objMilestone2.date) {
        return 1;
    } else if (objMilestone1.date < objMilestone2.date) {
        return -1;
    } else {
        return 0;
    }
}

/**
 * Resets the Timeline Chart.
 */
function resetRoadmap(){
    for(resetIndex=4; resetIndex<document.roadmap.length; resetIndex++){
        document.roadmap.elements[resetIndex].value="";
    }
    document.roadmap.submit();
  }


/**
 * Sets the value of the form field.
 * @param fieldName Name of the field
 * @param fieldValue The value to be set.
 */
function setFieldValue(fieldName, fieldValue){
    document.forms[0].elements[fieldName].value=fieldValue;
  }

/**
 * Gets the value of the passed form field.
 * @param fieldName Name of the field
 * @return The value of the field.
 */
function getFieldValue(fieldName){
 	return document.forms[0].elements[fieldName].value;
 }

/**
 * Submits the form.
 */
function submitForm(){
    document.forms[0].submit();
  }

/**
 * This function is used to dispaly the timeline filter.
 * @param url The filter url.
 * @param timetamp The timestamp.
 * @param suiteKey The application suite key.
 */
  function showFilter(url,timetamp,suiteKey){
    if(url.indexOf('?') == -1){
      url +="?";
    } else {
     url += "&";
    }
    url += "timestamp="+timetamp;
    url += "&suiteKey="+suiteKey;

    showModalDialog(url, 600, 400, true)
  }

/**
 * This function splits the passed string into string array using the delimiter.
 * @param stringValue The string with delimiter.
 * @param charDelim The delimiter character.
 */
 function split(stringValue, charDelim){
    arr = new Array();
    tmpChar = stringValue.charAt(stringValue.length);
    if((tmpChar == charDelim) && (stringValue.length != 0))
    {
      stringValue.substring(0, stringValue.length-1);
    }

    arrayIndex=0;
    start = 0;
    delimIndex = stringValue.indexOf(charDelim);
    while(delimIndex != -1)
    {
      arr[arrayIndex++] = stringValue.substring(start, delimIndex);
      start = delimIndex+1;
      delimIndex = stringValue.indexOf(charDelim, delimIndex+2);
    }

    arr[arrayIndex] = stringValue.substring(start, stringValue.length);

    return arr;
  }

/**
 * This function splits the passed string into string array using the delimiter.
 * @param stringValue The string with delimiter.
 * @param charDelim The delimiter character.
 */
  function stringArrayContains(stringArray, stringValue){
    for(arrayIndex=0; arrayIndex<stringArray.length; arrayIndex++)
    {
      if(stringArray[arrayIndex] == stringValue)
        return true;
    }
    return false;
  }

/**
 * This function is called when done button is clicked on timeline filter.
 */
  function doneFilter(){
      applyFilter();
      getTopWindow().closeWindow();
  }

/**
 * This function is called when apply button is clicked on timeline filter.
 */
  function applyFilter(){
    newValue = "";
  //Begin of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005
      parent.window.getWindowOpener().setFieldValue("fromDate", document.roadmapFilter.fromDate.value);
      parent.window.getWindowOpener().setFieldValue("fromDate_msvalue", document.roadmapFilter.fromDate_msvalue.value);
      parent.window.getWindowOpener().setFieldValue("toDate", document.roadmapFilter.toDate.value);
      parent.window.getWindowOpener().setFieldValue("toDate_msvalue", document.roadmapFilter.toDate_msvalue.value);
     fieldIndex = 4;
    while(fieldIndex < document.roadmapFilter.length)
    {
        fieldIndex++;
        tmpElement = document.roadmapFilter.elements[fieldIndex];
        fieldName = tmpElement.name;
        tmpElement = eval("document.roadmapFilter.elements['"+fieldName+"']");
        newValue = "";
            for(i=0; i<tmpElement.length; i++) {
              if(tmpElement[i].checked)
              {
                if(newValue != "")
                  newValue += "|";
                newValue += tmpElement[i].value;
              }
            }
        parent.window.getWindowOpener().setFieldValue(fieldName, newValue);
        fieldIndex += tmpElement.length;
    }
    parent.window.getWindowOpener().submitForm();
  }
//End of Modify by:Raman,Infosys for Bug#303034 on 5/6/2005

/**
 * This function is used to clear the filter selections.
 */
  function clearFilters(){
    for(i=0; i<document.roadmapFilter.length; i++)
    {
      strType = document.roadmapFilter.elements[i].type;
      if(strType == "checkbox")
        document.roadmapFilter.elements[i].checked = false;
      else
        document.roadmapFilter.elements[i].value = "";
    }
  } 

/**
 * This function is used to cancel the filter page.
 */
 function doCancel() {
        getTopWindow().closeWindow();
    }


//Begin of add by:Raman,Infosys for Bug#303034 on 5/6/2005

/*
 *This method is called on click of a checkbox in RoadMap Auto Filter.
 */

function doFilterItemCheckboxClick(objFilterItemCheckbox,formName)
{

    var objForm = document.forms[formName];
    var filterHeaderCheckboxObject = objForm.elements[objFilterItemCheckbox.name + '_filter'];

    var filterCheckboxObject = objForm.elements[objFilterItemCheckbox.name];
    var checkHeader=0;

    if (objFilterItemCheckbox.checked ==false)
    {
        filterHeaderCheckboxObject.checked =false ;
    } 
    else 
    {
        if (filterCheckboxObject.length == null || (filterCheckboxObject.length == "undefined"))
        {
            filterHeaderCheckboxObject.checked = true;
        } 
        else 
        {
            for (var i = 0; i < filterCheckboxObject.length; i++)
            {
                if (filterCheckboxObject[i].checked == true)
                {
                   checkHeader++;
                }
            }
            
            if (checkHeader == filterCheckboxObject.length)
	    {
	         filterHeaderCheckboxObject.checked = true;
	    }
	    else
	    {
	          filterHeaderCheckboxObject.checked = false;
    
	    }
        }

    }
}

/*
 *This method is called on click of header checkbox in RoadMap Auto Filter.
 */

function doFilterCheckboxClick(objFilterCheckbox,columnName,formName)
{

    var objForm = document.forms[formName];
    var filterItemCheckboxObject = objForm.elements[columnName];

    if (objFilterCheckbox.checked == false && filterItemCheckboxObject)
    {
        // Un check all the filter values for this item
        if (filterItemCheckboxObject.length == null || (filterItemCheckboxObject.length == "undefined"))
        {
            if (filterItemCheckboxObject.checked == true)
            {
                filterItemCheckboxObject.checked = false;
            }
        } 
        else 
        {
            for (var i = 0; i < filterItemCheckboxObject.length; i++)
            {
                if (filterItemCheckboxObject[i].checked == true)
                {
                    filterItemCheckboxObject[i].checked = false;
                }
            }
        }
        
    }
    else if (filterItemCheckboxObject)
    {

	if (filterItemCheckboxObject.length == null || (filterItemCheckboxObject.length == "undefined"))
	{
	     filterItemCheckboxObject.checked = true;
	}
	else 
	{
	     for (var i = 0; i < filterItemCheckboxObject.length; i++)
	     {
		filterItemCheckboxObject[i].checked = true;
	     }
	}
     }
}
 
function getTimeLineWindowHeight(objWin) {
     objWin = (objWin == null ? window : objWin);
     if (isIE) {
             return objWin.document.documentElement.clientHeight;
     } else {        	
     
             return objWin.innerHeight;
     }
}
function getTimeLineWindowWidth(objWin) {
     objWin = (objWin == null ? window : objWin);
     if (isIE) {
     	return objWin.document.documentElement.clientWidth;
     } else {
             return objWin.innerWidth;
     }
}

//End of add by:Raman,Infosys for Bug#303034 on 5/6/2005
