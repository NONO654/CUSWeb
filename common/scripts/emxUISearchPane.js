/*!================================================================
 *  JavaScript Search Pane
 *  emxUISearchPane.js
 *  Version 1.2
 *  Requires: emxUIConstants.js
 *  Last Updated: 19-Mar-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the code for the search pane.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUISearchPane.js.rca 1.6 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
 *=================================================================
 */
var localSearchPane = null;
var IMG_SEARCH = DIR_SMALL_ICONS + "iconSmallSearch.gif";
var IMG_TAB_TOP = DIR_SEARCHPANE + "utilSearchTabTop.gif";
var IMG_TAB_TOPSIDE = DIR_SEARCHPANE + "utilSearchTabTopSide.gif";
var IMG_TAB_SIDE = DIR_SEARCHPANE + "utilSearchTabSide.gif";
var IMG_ARROW = DIR_SEARCHPANE + "utilSearchPlus.gif";
var IMG_ARROW_EXPANDED = DIR_SEARCHPANE + "utilSearchMinus.gif";
//! Class jsSearchPane
//!     This object makes up the left pane of a search window.
function jsSearchPane(strStylesheet) {
	this.displayFrame = "searchPane";               
	this.items = new Array;                         
	this.scrollX = 0;                               
	this.scrollY = 0;
	this.selectedID = "0_0";                        
	this.stylesheet = getStyleSheet("emxUISearchPane");   
	this.tabs = new Array;                          
	this.addTab = _jsSearchPane_addTab;
	this.toggleExpand = _jsSearchPane_toggleExpand;
	this.draw = _jsSearchPane_draw;
	this.drawTab = _jsSearchPane_drawTab;
	this.refresh = _jsSearchPane_refresh;
	this.getScrollPosition = _jsSearchPane_getScrollPosition;
	this.setScrollPosition = _jsSearchPane_setScrollPosition;
	localSearchPane = this;
} 
//! Public Method jsSearchPane.addTab()
//!     This method adds a tab to the search pane.
function _jsSearchPane_addTab(strText) {
	var objTab = new jsSearchTab(strText);
	objTab.id = this.tabs.length;
	this.tabs[this.tabs.length] = objTab;
	if (objTab.id == 0) {
		objTab.expanded = true;
	} 
        return objTab;
} 
//! Method jsSearchPane.draw()
//!     This function draws the search tab on the frame identified by displayFrame.
function _jsSearchPane_draw() {
	var d = new jsDocument;
	d.writeHTMLHeader(this.stylesheet);
	d.write("<body onselectstart=\"return false\" oncontextmenu=\"return false;\">");
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
	this.setScrollPosition();
} 
//! Private Method jsSearchPane.drawTab()
//!     This function draws a tab and its links onto a jsDocument.
function _jsSearchPane_drawTab(d, objTab) {
	var strURL = "javascript:parent.localSearchPane.toggleExpand(" + objTab.id + ")";
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
	d.write("\" alt=\"\" border=\"0\" width=\"14\" height=\"15\" /><a href=\"");
	d.write(strURL);
	d.write("\"><img src=\"");
	d.write(objTab.expanded ? IMG_ARROW_EXPANDED : IMG_ARROW)
	d.write("\" border=\"0\" alt=\"*\" width=\"15\" vspace=\"5\" height=\"15\" /></a><img src=\"");
	d.write(IMG_SPACER);
	d.write("\" alt=\"\" border=\"0\" width=\"4\" height=\"15\" /></td><td><a class=\"tab\" href=\"");
	d.write(strURL);
	d.write("\">");
	d.write(objTab.text);
	d.write("</a></td><td width=\"41\" valign=\"top\"><img src=\"");
	d.write(IMG_TAB_SIDE);
	d.writeln("\" border=\"0\" alt=\"\" /></td></tr></table>");
	d.writeln("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
	d.write(IMG_SPACER);
	d.write("\" border=\"0\" height=\"6\" width=\"1\" /></td></tr></table>");
	if (objTab.expanded) {
		d.write("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"188\">");
		for (var i=0; i < objTab.menuitems.length; i++) {
			d.writeln("<tr><td width=\"11\"><img src=\"");
			d.write(IMG_SPACER);
			d.write("\" border=\"0\" alt=\"\" width=\"11\" height=\"1\" /></td><td>");
			d.write("<table border=\"0\"><tr><td valign=\"top\"><img src=\"");
			d.write(IMG_SEARCH);
			d.write("\" /></td><td");
			if (objTab.menuitems[i].id == this.selectedID) {
				d.write(" class=\"selected\"");
			} 
			d.write("><a class=\"menuitem\" href=\"javascript:parent.clickMenuItem('");
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
//! Private Method jsSearchPane.refresh()
//!     This function refreshes the view of the pane.
function _jsSearchPane_refresh() {
	this.getScrollPosition();
	this.draw();
} 
//! Private Method jsSearchPane.toggleExpand()
//!     This function expands/collapses a tab
function _jsSearchPane_toggleExpand(iID) {
	var objTab = this.tabs[iID];
	objTab.expanded = !objTab.expanded;
	this.refresh();
} 
//! Private Method jsSearchPane.getScrollPosition()
//!     This function gets the scrolling position of the window and saves it
//!     into a local variable.
function _jsSearchPane_getScrollPosition() {
        var win = findFrame(getTopWindow(), this.displayFrame);
        if (isNS4 || isNS6) {
                this.scrollX = win.pageXOffset;
                this.scrollY = win.pageYOffset;
        } else if (isIE) {
                this.scrollX = win.document.body.scrollLeft;
                this.scrollY = win.document.body.scrollTop;
        } 
} 
//! Private Method jsSearchPane.setScrollPosition()
//!     This function sets the scrolling position of the window from the saved
//!     values.
function _jsSearchPane_setScrollPosition() {
	var win = findFrame(getTopWindow(), this.displayFrame);
	win.scrollTo(this.scrollX, this.scrollY);
} 
//! Private Method jsSearchPane.setScrollPosition()
//!     This object represents one tab on the pane.
function jsSearchTab (strText) {
	this.expanded = false;          
	this.id = -1;                   
	this.menuitems = new Array;     
	this.text = strText;            
	this.addLink = _jsSearchTab_addLink;
} 
//! Private Method jsSearchPane.setScrollPosition()
//!     This method adds a link to the tab.
function _jsSearchTab_addLink(strText, strURL, strTarget) {
	var objMenuItem = new jsMenuItem(strText, strURL, strTarget);
	objMenuItem.id = this.id + "_" + this.menuitems.length;
	this.menuitems[this.menuitems.length] = objMenuItem;
	localSearchPane.items[objMenuItem.id] = objMenuItem;
	return objMenuItem;
} 
//! Class jsMenuItem
//!     This object represents a link on the pane.
function jsMenuItem (strText, strURL, strTarget) {
	this.target = strTarget;        
	this.text = strText;            
	this.url = strURL;              
} 
//! Private Function clickMenuItem()
//!     This functions launches the item that was clicked on.
function clickMenuItem(strMenuItemID) {
	var objMenuItem = localSearchPane.items[strMenuItemID];
	var objWin = findFrame(getTopWindow(), objMenuItem.target);
	if (!objWin) {
		window.open(objMenuItem.url, objMenuItem.target);
	} else {
		objWin.document.location.href = objMenuItem.url;
	} 
	localSearchPane.selectedID = strMenuItemID;
	setTimeout("localSearchPane.refresh()", 500);
} 
