/*!================================================================
 *  JavaScript Preferences Pane
 *  emxUIPreferencesPane.js
 *  Version 1.4
 *  Requires: emxUIConstants.js
 *  Last Updated: 26-Mar-03, Jean Binjour
 *
 *  This file contains the code for the preferences pane.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIPreferencesPane.js.rca 1.7 Wed Oct 22 15:48:12 2008 przemek Experimental przemek $
 *=================================================================
 */
var localPreferencesPane = null;
var IMG_SEARCH = "images/iconSmallPreferences.gif";
var IMG_TAB_TOP = DIR_UTIL + "utilSearchTabTop.gif";
var IMG_TAB_TOPSIDE = DIR_UTIL + "utilSearchTabTopSide.gif";
var IMG_TAB_SIDE = DIR_UTIL + "utilSearchTabSide.gif";
var IMG_ARROW = DIR_UTIL + "utilSearchPlus.gif";
var IMG_ARROW_EXPANDED = DIR_UTIL + "utilSearchMinus.gif";

//! Class jsPreferencesPane
//!     This object makes up the left pane of a search window.
function jsPreferencesPane(strStylesheet, bShowTabs) {
        this.displayFrame = "preferencesPane";                          
        this.items = new Array;                                         
        this.scrollX = 0;                                               
        this.scrollY = 0;
        this.selectedID = "0_0";                                        
        this.showTabs = bShowTabs ? bShowTabs : true;                   
        this.stylesheet = getStyleSheet("emxUIPreferencesPane");        
        this.tabs = new Array;                                          
        this.addTab = _jsPreferencesPane_addTab;
        this.toggleExpand = _jsPreferencesPane_toggleExpand;
        this.draw = _jsPreferencesPane_draw;
        this.drawTab = _jsPreferencesPane_drawTab;
        this.refresh = _jsPreferencesPane_refresh;
        this.getScrollPosition = _jsPreferencesPane_getScrollPosition;
        this.setScrollPosition = _jsPreferencesPane_setScrollPosition;
        localPreferencesPane = this;
} 
//! Public Method jsPreferencesPane.addTab()
//!     This method adds a tab to the search pane.
function _jsPreferencesPane_addTab(strText) {
        var objTab = new jsPreferencesTab(strText);
        objTab.id = this.tabs.length;
        this.tabs[this.tabs.length] = objTab;
        if (objTab.id == 0){
                objTab.expanded = true;
        } 
        return objTab;
} 
//! Public Method jsPreferencesPane.draw()
//!     This function draws the search tab on the frame identified by displayFrame.
function _jsPreferencesPane_draw() {
        var d = new jsDocument;
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body class=\"preferences-accordion\" onselectstart=\"return false\" oncontextmenu=\"return false;\">");
        for (var i=0; i < this.tabs.length; i++) {
                this.drawTab(d, this.tabs[i]);
        } 
        d.writeHTMLFooter();
        var objWin = findFrame(getTopWindow(), this.displayFrame);
        with (objWin.document) {
                open();
                write(d);
                close();
        } 
        var windobj = this ;
		objWin.document.onreadystatechange = function(){
			if(objWin.document.readyState === 'complete'){
				windobj.setScrollPosition();
			}
		}
} 
//! Private Method jsPreferencesPane.drawTab()
//!     This function draws a tab and its links onto a jsDocument.
function _jsPreferencesPane_drawTab(d, objTab) {
        var strURL = "javascript:parent.localPreferencesPane.toggleExpand(" + objTab.id + ")";
        if (this.showTabs) {
                d.write("<table border=\"0\" width=\"188\" cellpadding=\"0\" cellspacing=\"0\">");
                d.write("<tr><td width=\"16\" background=\"");
                d.write(IMG_TAB_TOP);
                d.write("\"><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" border=\"0\" alt=\"\" width=\"16\" height=\"9\" /></td><td background=\"");
                d.write(IMG_TAB_TOP);
                d.write("\"><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" border=\"0\" alt=\"\" width=\"16\" height=\"9\" /></td><td width=\"27\" valign=\"top\"><img src=\"");
                d.write(IMG_TAB_TOPSIDE);
                d.writeln("\" border=\"0\" alt=\"\" /></td></tr>");
                d.write("<tr><td width=\"33\" valign=\"top\"><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" alt=\"\" border=\"0\" width=\"14\" height=\"15\" /><a onclick=\"");
                d.write(strURL);
                d.write("\"><img src=\"");
                d.write(objTab.expanded ? IMG_ARROW_EXPANDED : IMG_ARROW)
                d.write("\" border=\"0\" alt=\"*\" width=\"15\" vspace=\"5\" height=\"15\" /></a><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" alt=\"\" border=\"0\" width=\"4\" height=\"15\" /></td><td><a class=\"tab\" onclick=\"");
                d.write(strURL);
                d.write("\">");
                d.write(objTab.text);
                d.write("</a></td><td width=\"41\" valign=\"top\"><img src=\"");
                d.write(IMG_TAB_SIDE);
                d.writeln("\" border=\"0\" alt=\"\" /></td></tr></table>");
                d.writeln("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" border=\"0\" height=\"6\" width=\"1\" /></td></tr></table>");
        } 
        if (objTab.expanded || !this.showTabs) {
                d.write("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"188\">");
                for (var i=0; i < objTab.menuitems.length; i++) {
                        d.writeln("<tr><td width=\"11\"><img src=\"");
                        d.write(IMG_SPACER);
                        d.write("\" border=\"0\" alt=\"\" width=\"11\" height=\"1\" /></td><td>");
                        d.write("<table border=\"0\"><tr><td valign=\"top\">");
                        d.write("</td><td");
                        if (objTab.menuitems[i].id == this.selectedID) {
                                d.write(" class=\"selected\"");
                        } 
                        d.write("><a class=\"menuitem\" onclick=\"javascript:parent.clickMenuItem('");
                        d.write(objTab.menuitems[i].id);
                        d.write("')\">");
                        d.write(objTab.menuitems[i].text);
                        d.write("</a></td></tr></table>");
                        d.write("</td></tr>");
                } 
                d.write("<tr><td><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" width=\"5\" height=\"10\" /></td><td><img src=\"");
                d.write(IMG_SPACER);
                d.write("\" width=\"5\" height=\"10\" /></td></tr>");
                d.writeln("</table>")
        } 
} 
//! Private Method jsPreferencesPane.refresh()
//!     This function refreshes the view of the pane.
function _jsPreferencesPane_refresh() {
        this.getScrollPosition();
        this.draw();
} 
//! Private Method jsPreferencesPane.toggleExpand()
//!     This function expands/collapses a tab
function _jsPreferencesPane_toggleExpand(iID) {
        var objTab = this.tabs[iID];
        objTab.expanded = !objTab.expanded;
        this.refresh();
} 
//! Private Method jsPreferencesPane.getScrollPosition()
//!     This function gets the scrolling position of the window and saves it
//!     into a local variable.
function _jsPreferencesPane_getScrollPosition() {
        var win = findFrame(getTopWindow(), this.displayFrame);
        if (isIE) {
            this.scrollX = jQuery(win).scrollLeft();
            this.scrollY = jQuery(win).scrollTop();            
        }else{
                this.scrollX = win.pageXOffset;
                this.scrollY = win.pageYOffset;
        } 
} 
//! Private Method jsPreferencesPane.setScrollPosition()
//!     This function sets the scrolling position of the window from the saved
//!     values.
function _jsPreferencesPane_setScrollPosition() {
        var win = findFrame(getTopWindow(), this.displayFrame);
        win.scrollTo(this.scrollX, this.scrollY);
} 
//! Private Method jsPreferencesPane.setScrollPosition()
//!     This object represents one tab on the pane.
function jsPreferencesTab (strText) {
        this.expanded = false;          
        this.id = -1;                   
        this.menuitems = new Array;     
        this.text = strText;            
        this.addLink = _jsPreferencesTab_addLink;
} 
//! Private Method jsPreferencesPane.setScrollPosition()
//!     This method adds a link to the tab.
function _jsPreferencesTab_addLink(strText, strURL, strTarget,strMarker,strSuite) {
        var objMenuItem = new jsMenuItem(strText, strURL, strTarget,strMarker,strSuite);
        objMenuItem.id = this.id + "_" + this.menuitems.length;
        this.menuitems[this.menuitems.length] = objMenuItem;
        localPreferencesPane.items[objMenuItem.id] = objMenuItem;
        return objMenuItem;
} 
//! Class jsMenuItem
//!     This object represents a link on the pane.
function jsMenuItem (strText, strURL, strTarget,strMarker,strSuite) {
        this.target = strTarget;        
        this.text = strText;    
        this.url = strURL;      
        this.helpMarker = strMarker;       
        this.registeredSuite = strSuite;        
} 
//! Private Function clickMenuItem()
//!     This functions launches the item that was clicked on.
function clickMenuItem(strMenuItemID) {
        var objMenuItem = localPreferencesPane.items[strMenuItemID];
        var objWin = findFrame(getTopWindow(), objMenuItem.target);
        if (!objWin) {
                window.open(objMenuItem.url, objMenuItem.target);
        } else {
                objWin.document.location.href = objMenuItem.url;
        } 
        var strQueryString = "?SuiteDirectory=" + objMenuItem.registeredSuite;
        strQueryString += "&HelpMarker=" + objMenuItem.helpMarker; 
        var headerURL = "../common/emxPreferencesHead.jsp" + strQueryString; 
    	var dph = document.getElementById("pageHeadDiv");
    	dph.innerHTML = emxUICore.getData(headerURL);         
        localPreferencesPane.selectedID = strMenuItemID;
        setTimeout("localPreferencesPane.refresh()", 500);
} 

function loadPreferences() {
	var dph = document.getElementById("pageHeadDiv");
	dph.innerHTML = emxUICore.getData("../common/emxPreferencesHead.jsp");
}
