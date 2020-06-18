/*=================================================================
 *  JavaScript Tooltips Component
 *  Requires: emxUIConstants.js, emxUICore.js
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUITooltips.js.rca 1.4 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
 *=================================================================
 */

/**
 * Contains constants for tooltips.
 * @scope public
 */
var emxUITooltips = {

    /**
     * Delay in milliseconds before showing a tip.
     * @scope public
     */
    SHOW_DELAY: 900,

    /**
     * The default width (in pixels) of all tooltips.
     * @scope public
     */
    DEFAULT_WIDTH: 200,

    /**
     * The number of pixels from the right of the cursor
     * to the left of the tooltip.
     * @scope public
     */
    OFFSET_X: 15,

    /**
     * The number of pixels from the top of the cursor
     * to the top of the tooltip.
     * @scope public
     */
    OFFSET_Y: 15,

    /**
     * Background color of the tooltip.
     * @scope public
     */
    BGCOLOR: "#ffffcc",
    
	/**
     * Border style of the tooltip.
     * @scope public
     */
    BORDER: "1px solid black",
    
    /**
     * Specifies the padding for the content inside tooltip.
     * @scope public
     */
    PADDING: "5px",
    
	/**
     * Specifies whether tooltip should move when cursor on 
     * the element is moved.
     * @scope public
     */
    MOVEWITHMOUSE: false
};


/**
 * Tooltip manager that controls all tooltips on the page.
 * @class
 * @scope protected
 */
function emxUITooltipManager() {

    /**
     * Array of tips for the page.
     * @scope protected
     */
    this.tips = new Array;

    /**
     * The timeoutID for showing a tooltip.
     * @scope private
     */
    this.timeoutId = null;

    /**
     * Indicates whether a tooltip is being displayed.
     * @scope private
     */
    this.showing = false;

    /**
     * The layer to use for displaying tooltips.
     * @scope private
     */
    this.layer = null;

    /**
     * Determines whether or not tooltips will be displayed.
     * @scope private
     */
    this.enabled = true;

    //add onload event handler
    var objThis = this;
    emxUICore.addEventHandler(window, "click", function () {
        var objEvent = emxUICore.getEvent();
        objThis.hideTooltip(objEvent);
    });

};

/**
 * Adds a tooltip for a particular DOM element.
 * @param objElement The DOM element to add the tooltip to.
 * @param strTip The HTML text to display in the tip.
 * @scope public
 */
emxUITooltipManager.prototype.addTooltipFor = function(objElement, strTip, cleanTip, objectEvent) {

    if (strTip == null) return;

    //assign tooltip information
    objElement.tipId = this.tips.length;
    this.tips.push(strTip);

    //assign event handlers
    var objThis = this;

    if(objectEvent){
		objThis.showTooltipFor(objElement, objectEvent);
	} else {
	    emxUICore.addEventHandler(objElement, "mouseover", function () {
	    	var objEvent =emxUICore.getEvent();  
	    	objThis.showTooltipFor(objElement, objEvent);
	    });
	}
    emxUICore.addEventHandler(objElement, "mouseout", function () {
        var objEvent = emxUICore.getEvent();
        objThis.hideTooltip(objEvent);
        if(cleanTip){
        	objThis.cleanUpTooltip();
        }
    });
    
    if(emxUITooltips.MOVEWITHMOUSE && emxUITooltips.MOVEWITHMOUSE == true){
	    emxUICore.addEventHandler(objElement, "mousemove", function () {
	    	 var objEvent = emxUICore.getEvent();
	         objThis.positionLayer(objEvent.clientX, objEvent.clientY);
	    });
    }
    
};


/**
 * Clears the timeout used to show tooltips.
 * @scope private
 */
emxUITooltipManager.prototype.clearTimeout = function () {
    clearTimeout(this.timeoutId);
};

/**
 * Creates the tooltip layer.
 * @scope private
 */
emxUITooltipManager.prototype.createLayer = function () {

    this.layer = document.createElement("div");
    this.layer.style.backgroundColor = emxUITooltips.BGCOLOR;
    this.layer.style.border = emxUITooltips.BORDER;
    this.layer.style.position = "absolute";
    this.layer.style.zIndex = 10;
    this.layer.style.visibility = "hidden";
    this.layer.style.padding = emxUITooltips.PADDING;

    document.body.appendChild(this.layer);

    //don't allow text selection
    this.layer.style.mozUserSelect = "none";
    this.layer.style.userSelect = "none";
    this.layer.style.cursor = "default";
    var objThis = this;

    emxUICore.addEventHandler(this.layer, "mouseout", function () {
        var objEvent = emxUICore.getEvent();
        objThis.hideTooltip(objEvent, true);
    });

    emxUICore.addEventHandler(this.layer, "mousedown", function () {
        var objEvent = emxUICore.getEvent();
        objThis.hideTooltip(objEvent, true);
    });

    emxUICore.addEventHandler(this.layer, "selectstart", function () {
        var objEvent = emxUICore.getEvent();
        objEvent.preventDefault();
    });


};

/**
 * Hides the currently displayed tooltip.
 * @param objEvent The event object for the mouse event.
 * @param blnForce Forces the tooltip to hide.
 * @scope protected
 */
emxUITooltipManager.prototype.hideTooltip = function(objEvent, blnForce) {

    if (!this.enabled) return;

    if (this.layer) {
        if (!this.isOverLayer(objEvent.clientX, objEvent.clientY) || blnForce) {
            this.layer.style.visibility = "hidden";
            this.showing = false;
        }
    }

    this.clearTimeout();
};

emxUITooltipManager.prototype.cleanUpTooltip = function() {
	this.layer = null;
}

/**
 * Determines if the given coordinates are over the tooltip layer.
 * @param intX The x-coordinate to check.
 * @param intY The y-coorindate to check.
 * @scope private
 */
emxUITooltipManager.prototype.isOverLayer = function (intX, intY) {

    var intLeft = parseInt(this.layer.style.left);
    var intTop = parseInt(this.layer.style.top);

    return !(intX < intLeft || intX > intLeft + this.layer.offsetWidth
           || intY < intTop || intY > intTop + this.layer.offsetHeight);

};

/**
 * Begins the process of showing a tooltip for
 * a particular DOM element.
 * @param objElement The element whose tip should be displayed.
 * @param objEvent The event object for a mouse event.
 * @scope public
 */
emxUITooltipManager.prototype.showTooltipFor = function(objElement, objEvent) {

    if (!this.enabled) return;

    if (typeof objElement.tipId == "number") {

        /*
         * If the tip is already showing, just move it over to
         * show it in the new position. Otherwise, wait before showing.
         */
        if (this.showing) {
            this.showTooltip(objElement, objEvent.clientX, objEvent.clientY);
        } else {
            var objThis = this;
            var intX = objEvent.clientX, intY = objEvent.clientY;

            //show tip after a given delay
            this.timeoutId = setTimeout(function () {
                objThis.showTooltip(objElement, intX, intY);
            }, emxUITooltips.SHOW_DELAY);
        }
    }
};

/**
 * Shows a given tooltip.
 * @param objElement The element whose tip should be displayed.
 * @param intX The x-coordinate of the mouse event.
 * @param intY The y-coordinate of the mouse event.
 * @scope private
 */
emxUITooltipManager.prototype.showTooltip = function(objElement, intX, intY) {

    if (!this.enabled) return;

    if (!this.layer) {
        this.createLayer();
    }

    this.layer.innerHTML = this.tips[objElement.tipId];
    this.positionLayer(intX, intY);

    this.layer.style.visibility = "visible";
    this.showing = true;

    this.clearTimeout();

};

/**
 * Places the layer into an appropriate position for the given coordinates.
 * @param intX The x-coordinate of the mouse event.
 * @param intY The y-coordinate of the mouse event.
 * @scope private
 */
emxUITooltipManager.prototype.positionLayer = function (intX, intY) {
	if(!this.layer) return;

    //position the layer (NCZ, 9/3/02)
    this.layer.style.left = 0 + "px";
    this.layer.style.top = 0 + "px";

    //add offset to each coordinate (NCZ, 9/3/02)
    intX += emxUITooltips.OFFSET_X + document.body.scrollLeft;
    intY += emxUITooltips.OFFSET_Y + document.body.scrollTop;

    //make sure that all of the tooltip is visible (NCZ, 9/3/02)
    if ((intX + this.layer.offsetWidth) > (document.body.clientWidth + document.body.scrollLeft)) {

        //move it so that the right edge of the tooltip lines up with the right edge of the window (NCZ, 9/3/02)
        intX = (document.body.clientWidth + document.body.scrollLeft) - this.layer.offsetWidth - 5;

    } //End: if ((intX + ...)

    var intWindowHeight = document.body.clientHeight || window.innerHeight;

    //make sure that all of the tooltip is visible (NCZ, 9/3/02)
    if ((intY + this.layer.offsetHeight) > (intWindowHeight + document.body.scrollTop)) {

        //move it so that the bottom edge of the tooltip lines up with bottom edge of the window (NCZ, 9/3/02)
        intY = (document.body.clientHeight + document.body.scrollTop) - this.layer.offsetHeight;

    } //End: if ((intY + ...)

    //position the layer (NCZ, 9/3/02)
    this.layer.style.left = intX + "px";
    this.layer.style.top = intY + "px";

};
