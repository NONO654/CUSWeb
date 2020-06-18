/*=================================================================
 *  JavaScript Page Component
 *  Requires: emxUIConstants.js, emxUICore.js
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIPage.js.rca 1.4 Wed Oct 22 15:47:55 2008 przemek Experimental przemek $
 *=================================================================
 */

/**
 * Model of a page.
 * @class
 */
function emxUIPage() {

    /**
     * Object to handle the event handlers.
     * @scope private
     */
    this.handlers = {
        resize: [],
        load: []
    };

    /**
     * Object to manage the page layout.
     * @scope private
     */
    this.layout = {
        init: function() {},
        reflow: function() {}
    };

};

/**
 * Initializes event handlers and settings. This
 * method is called when the window loads.
 * @constructor
 */
emxUIPage.prototype.init = function () {

    var objThis = this;

    window.onresize = function () {
        objThis.handleEvent("resize");
        objThis.layout.reflow();
    };

    this.handleEvent("load");
    this.layout.init();

};


/**
 * Adds an event handler to the page.
 * @scope public
 * @param strType The type of event to handle.
 * @param fnHandler The function
 */
emxUIPage.prototype.addEventHandler = function (strType, fnHandler) {

    switch(strType) {
        case "load":
        case "resize":
            this.handlers[strType].push(fnHandler);
            break;
        default:
            throw new Error("Event type \"" + strType + "\" not supported. (emxUIPage.prototype.addEventHandler)");

    } //End: switch(strType)

};

/**
 * Returns the page layout object.
 * @return The page layout object.
 */
emxUIPage.prototype.getLayout = function () {
    return this.layout;
};

/**
 * Handles page events.
 * @param strType The type of event to handler.
 * @param objEvent The event object.
 * @scope private
 */
emxUIPage.prototype.handleEvent = function (strType, objEvent) {

    if (this.handlers[strType]) {
        for (var i=0; i < this.handlers[strType].length; i++) {
            this.handlers[strType][i](objEvent);
        } //End: for
    } //End: if

};

/**
 * Sets the layout of the page.
 * @param objLayout A page layout object.
 */
emxUIPage.prototype.setLayout = function (objLayout) {
    this.layout = objLayout;
};

/*
 * Create the page object and initialize it on page load.
 */
var page = new emxUIPage();
window.onload = function () {
    page.init();
};
