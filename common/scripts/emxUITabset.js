/*!================================================================
 *  JavaScript Tab Set Component
 *  emxUITabset.js
 *  Version 1.0
 *  Requires: emxUICore.js
 *  Last Updated: 12-May-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the definition of the tabset component.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $Id: emxUITabset.js.rca 1.4.2.1 Fri Nov 14 07:55:12 2008 ds-arajendiran Experimental $
 *=================================================================
 */
//! Class emxUITabset
//!     This class represents a tabset. A tabset can be placed anywhere
//!     on a page by specifying its container.
function emxUITabset() { 
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.container = null;                  
        this.element = null;                    
        this.emxClassName = "emxUITabset";      
        this.selectedID = 0;                   
        this.tabs = new Array;                  
        this.lastTab = null;
} 
emxUITabset.prototype = new emxUIObject;
//! Public Method emxUITabset.addTab()
//!     This method adds a tab to the tabset.
emxUITabset.prototype.addTab = function _emxUITabset_addTab(objTab) {
        if (!(objTab instanceof emxUITab)) {
                throw new Error("Required parameter objTab is null or not of type emxUITab. (emxUITabset.prototype.addTab)");
        } 
        objTab.index = this.tabs.length;
		this.channelIndex =  this.tabs.length;	
        objTab.parent = this;
        this.tabs.push(objTab);
        return objTab;
}; 
//! Public Method emxUITabset.getDOM()
//!     This method gets the DOM representation of the tabset.
emxUITabset.prototype.getDOM = function _emxUITabset_getDOM() {
        this.element = document.createElement("div");
        this.element.className = "tabset-background";
        var objTable = document.createElement("table");
        objTable.cellPadding = 0;
        objTable.cellSpacing = 0;
        objTable.border = 0;
        this.element.appendChild(objTable);
        var objTBody = document.createElement("tbody");
        objTable.appendChild(objTBody);
        var objTR = document.createElement("tr");
        objTBody.appendChild(objTR);
        var objThis = this;
        for (var i=0; i < this.tabs.length; i++) {
                objTR.appendChild(this.tabs[i].getDOM());
        } 
        return this.element; 
}; 
//! Protected Method emxUITabset.handleEvent()
//!     This method handles the various events for this object.
emxUITabset.prototype.handleEvent = function _emxUITabset_handleEvent(strType, intTabID) {
        if (typeof strType != "string") {
                throw new Error("Required parameter strType is null or not a string. (emxUITabset.prototype.handleEvent)");
        } 
        switch(strType) {
                case "click":
                        if (this.selectedID != intTabID) {
                                this.tabs[this.selectedID].sendToBack();
                                this.tabs[intTabID].bringToFront();
                                this.lastTab = this.tabs[intTabID];
                                this.selectedID = intTabID;     
                        } 
                        break;
        } 
}; 
//! Protected Method emxUITabset.init()
//!     This function gathers the required information for the
//!     tabset object.
emxUITabset.prototype.init = function _emxUITabset_init() {
        this.container.appendChild(this.getDOM());
        for (var i=0; i < this.tabs.length; i++) {
                if (this.selectedID == i) {
                        this.tabs[i].bringToFront();
                } else {
                        this.tabs[i].sendToBack();
                } 
        } 
        var objThis = this;
}; 
//! Class emxUITab
//!     This class represents a tab on the tab set.
function emxUITab(strText) {
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUITab";                 
        this.index = -1;                                
		this.channelIndex = -1;
        this.text = strText;                            
        this.tabName = "";
} 
emxUITab.prototype = new emxUIObject;
//! Private Method emxUITab.bringToFront()
//!     This method brings the tab to the front of the other tabs.
emxUITab.prototype.bringToFront = function _emxUITab_bringToFront() {
        this.element.className = "tab-active";
}; 
//! Private Method emxUITab.click()
//!     This method simulates a click on the tab.
emxUITab.prototype.click = function _emxUITab_click() {
		var index = this.index == -1 ? this.channelIndex : this.index;		
        this.parent.handleEvent("click", index);
        this.fireEvent("click");
}; 
//! Private Method emxUITab.getDOM()
//!     This method creates the DOM representation of the tab.
emxUITab.prototype.getDOM = function _emxUITab_getDOM() {
        this.element = document.createElement("td");
        this.element.className = "tab-inactive";
        this.element.innerHTML = this.text;
        this.element.onselectstart = cancelEvent;
        this.element.style.MozUserSelect = "none";
        this.element.oncontextmenu = cancelEvent;
        var objThis = this;
        this.element.onclick = function () { objThis.click(); };
        return this.element;
}; 
//! Private Method emxUITab.sendToBack()
//!     This method sends the tab to the back of the other tabs.
emxUITab.prototype.sendToBack = function _emxUITab_sendToBack() {
        this.element.className = "tab-inactive";
}; 
