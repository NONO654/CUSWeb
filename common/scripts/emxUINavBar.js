/*!================================================================
 *  JavaScript Navigation Bar
 *  emxUINavBar.js
 *  Version 1.6
 *  Requires: emxUIConstants.js
 *  Last Updated: 5-Jun-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains class definition for the navbar.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUINavBar.js.rca 1.22 Wed Oct 22 15:48:52 2008 przemek Experimental przemek $
 *=================================================================
 */
var IMG_ARROW = DIR_NAVBAR + "utilNavBarPlus.gif";
var IMG_ARROW_EXPANDED = DIR_NAVBAR + "utilNavBarMinus.gif";
var IMG_TAB_TOP = DIR_NAVBAR + "utilNavBarTabTop.gif";
var IMG_TAB_SIDE = DIR_NAVBAR + "utilNavBarTabSide.gif";
var IMG_TAB_TOPSIDE = DIR_NAVBAR + "utilNavBarTabTopSide.gif";
var IMG_BULLET = DIR_NAVBAR + "utilNavBarBullet.gif";
var URL_MAIN = "./emxNavigatorMainFrameset.jsp";
var URL_SHRUNK = "./emxNavigatorShrunkFrameset.jsp";
//! Class jsNavBar
//!    This object encapsulates the NavBar object.
function jsNavBar(strName, strStylesheet) {
        this.displayFrame = "navBarDisplay";
        this.menus = new Array;
        this.name = strName;
        this.scrollX = 0;
        this.scrollY = 0;
        this.selectedID = -1;
        this.stylesheet = getStyleSheet("emxUINavbar");
        this.addMenu = _jsNavBar_addMenu;
        this.getScrollPosition = _jsNavBar_getScrollPosition;
        this.draw = _jsNavBar_draw;
        this.drawMenu = _jsNavBar_drawMenu;
        this.drawMenuItem = _jsNavBar_drawMenuItem;
        this.refresh = _jsNavBar_refresh;
        this.setScrollPosition = _jsNavBar_setScrollPosition;
}
//! Public Method jsNavBar.addMenu()
//!     This method creates a new menu on the navbar.
function _jsNavBar_addMenu(strTitle,menuName) {
        var objMenu = new jsNavBarMenu(strTitle,menuName);
        objMenu.id = this.menus.length;
        this.menus[this.menus.length] = objMenu;
        return objMenu;
}
//! Private Method jsNavBar.drawMenu()
//!     This method draws the header for a menu.
function _jsNavBar_drawMenu(d, objMenu) {
        var strURL = "javascript:getTopWindow().clickMenu('" + this.name + "', " + objMenu.id + ")";
        d.write("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"130\">");
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
        d.write("\" border=\"0\" alt=\"\" /></td></tr>");
        d.write("<tr><td width=\"16\" valign=\"top\"><a href=\"");
        d.write(strURL);
        d.write("\"><img src=\"");
        d.write(objMenu.expanded ? IMG_ARROW_EXPANDED : IMG_ARROW);
        d.write("\" border=\"0\" alt=\"*\" width=\"15\" height=\"15\" /></a></td><td><a class=\"menu\" href=\"");
        d.write(strURL);
        d.write("\">");
        d.write(objMenu.title);
        d.write("</a></td><td width=\"27\" valign=\"top\"><img src=\"");
        d.write(IMG_TAB_SIDE);
        d.write("\" border=\"0\" alt=\"\" /></td></tr></table>");
        d.write("&nbsp;");
}
//! Private Method jsNavBar.drawMenuItem()
//!     This method creates a new menu on the navbar.
function _jsNavBar_drawMenuItem(d, objMenuItem) {
        var strURL = "javascript:getTopWindow().clickMenuItem('" + this.name + "', " + objMenuItem.menuID + ", " + objMenuItem.id + ")";
        d.write("<tr class=\"lightBorder\"><td colspan=\"2\"><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" width=\"1\" height=\"1\" /></td></tr>");
        d.write("<tr valign=\"top\"><td align=\"center\" valign=\"top\"><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" width=\"16\" height=\"4\" alt=\"\" border=\"0\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" width=\"4\" height=\"4\" border=\"0\" alt=\"\" /></td></tr><tr valign=\"top\"><td width=\"16\" align=\"center\"><img src=\"");
        d.write(IMG_BULLET);
        d.write("\" alt=\"*\" border=\"0\" /></td><td><a href=\"");
        d.write(strURL);
        d.write("\">");
        d.write(objMenuItem.title);
        d.write("</a></td></tr><tr valign=\"top\"><td align=\"center\" valign=\"top\"><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" width=\"16\" height=\"4\" alt=\"\" border=\"0\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" width=\"4\" height=\"4\" border=\"0\" alt=\"\" /></td></tr>");
        d.write("<tr class=\"darkBorder\"><td colspan=\"2\"><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" width=\"1\" height=\"1\" /></td></tr>");
}
//! Public Method jsNavBar.draw()
//!     This method draws the main view of the navbar.
function _jsNavBar_draw() {
        var d = new jsDocument;
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body onload=\"getTopWindow().objMgr.getNavBar('" + this.name + "').setScrollPosition()\">");
        for (var i=0; i < this.menus.length; i++) {
                this.drawMenu(d, this.menus[i]);
                if (this.menus[i].expanded) {
                        d.write("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">");
                        for (var j=0; j < this.menus[i].items.length; j++){
                                this.drawMenuItem(d, this.menus[i].items[j]);
                        }
                        d.write("<tr><td><img src=\"");
                        d.write(IMG_SPACER);
                        d.write("\" width=\"5\" height=\"10\" /></td><td></td></tr>");
                        d.write("</table>");
                }
        }
        d.writeHTMLFooter();
        var frameDisplay = findFrame(getTopWindow(), this.displayFrame);
        with (frameDisplay.document) {
                open();
                write(d);
                close();
        }
}
//! Private Method jsNavBar.getScrollPosition()
//!     This method gets the scroll position of the navbar.
function _jsNavBar_getScrollPosition() {
        var frameDisplay = findFrame(getTopWindow(), this.displayFrame);
        if (!isIE) {
                this.scrollX = frameDisplay.pageXOffset;
                this.scrollY = frameDisplay.pageYOffset;
        } else {
                this.scrollX = frameDisplay.document.body.scrollLeft;
                this.scrollY = frameDisplay.document.body.scrollTop;
        }
}
//! Private Method jsNavBar.refresh()
function _jsNavBar_refresh() {
        this.getScrollPosition();
        this.draw();
        this.setScrollPosition();
}
//! Private Method jsNavBar.setScrollPosition()
//!     This method sets the scroll position of the navbar.
function _jsNavBar_setScrollPosition() {
        var frameDisplay = findFrame(getTopWindow(), this.displayFrame);
        frameDisplay.scrollTo(this.scrollX, this.scrollY);
}
//! Class jsNavBarMenu
function jsNavBarMenu(strTitle,menuName) {
        this.expanded = false;
        this.id = -1;
        this.items = new Array;
        this.menuName = menuName;
        this.title = strTitle;
        this.addItem = _jsNavBarMenu_addItem;
}
//! Public Method jsNavBarMenu.addItem()
//!     This method adds a menu item to the menu.
function _jsNavBarMenu_addItem(strTitle, strURL, strTarget,menuCommandName,strWidth,strHeight,strSuiteDir) {
        var objMenuItem = new jsNavBarMenuItem(strTitle, strURL, strTarget,menuCommandName,strWidth,strHeight,strSuiteDir);
        objMenuItem.id = this.items.length;
        objMenuItem.menuID = this.id;
        this.items[this.items.length] = objMenuItem;
        return objMenuItem;
}
//! Class jsNavBarMenuItem
//!     This object represents a menu item on the navbar
function jsNavBarMenuItem (strTitle, strURL, strTarget,menuCommandName,strWidth,strHeight,strSuiteDir) {
        this.commandName = menuCommandName;
        this.height = strHeight;
        this.id = -1;
        this.menuID = -1;
        this.title = strTitle;
        this.target = strTarget;
        this.url = strURL;
        this.width = strWidth;
        this.registeredSuite=strSuiteDir;
        var reJS = new RegExp("javascript:", "gi");
        this.isJS = reJS.test(this.url);
}
//! Private Function clickMenu()
//!     This functions handles the clicks of the menu, which expands or
//!     collapses the individual menu.
function clickMenu(strName, iMenuID) {
        var navbar = objMgr.getNavBar(strName);
        navbar.menus[iMenuID].expanded = !navbar.menus[iMenuID].expanded;
        navbar.refresh();
}
//! Private Function clickMenuItem()
//!     This functions handles the clicks of the menu items.
function clickMenuItem(strName, iMenuID, iMenuItemID) {
    //debugger;
        var objNavBar = objMgr.getNavBar(strName);
        var objMenuItem = objNavBar.menus[iMenuID].items[iMenuItemID];
        var objMenuAppName = objNavBar.menus[iMenuID].title;
        var objCommandTitle=objMenuItem.title;
        var objSuite=objMenuItem.registeredSuite;
        if (objMenuItem.url.indexOf('javascript:') > -1) {
                eval(objMenuItem.url);
                addNavBarPageHistory(objMenuAppName,objMenuItem.url,objNavBar.menus[iMenuID].menuName,objMenuItem.commandName,"popup",objCommandTitle,"menu",objMenuItem.width,objMenuItem.height,objSuite);
        } else {
                var objFrame = findFrame(getTopWindow(), objMenuItem.target);
                objFrame.document.location.href = objMenuItem.url;
                addNavBarPageHistory(objMenuAppName,objMenuItem.url,objNavBar.menus[iMenuID].menuName,objMenuItem.commandName,objFrame.name,objCommandTitle,"menu",objMenuItem.width,objMenuItem.height,objSuite);
        }
}
//! Public Function hideNavBar()
//!     This functions hides the navbar.
function hideNavBar(bNavBarMulti) {
        var frameContent = findFrame(getTopWindow(), "content");
        var frameNavBar = findFrame(getTopWindow(), "navbar");
        var frameTreeDisplay = findFrame(getTopWindow(), "treeDisplay");
        var frameMain = findFrame(getTopWindow(), "mainFrame");
        var strContentURL = frameContent.document.location.href;
        objMgr.URLs['navbar'] = frameNavBar.document.location.href;
        if (frameTreeDisplay) {
                strContentURL = addURLParam(strContentURL, "tree=true");
        } else {
                strContentURL = addURLParam(strContentURL, "tree=false");
        }
        strContentURL = addURLParam(strContentURL, "collapseNavbar=true");
        var strMainURL;
        strMainURL =  URL_SHRUNK;
        objMgr.URLs['content'] = strContentURL;
        frameMain.document.location.href = strMainURL;
}
//! Public Function showNavBar()
//!     This functions shows the navbar.
function showNavBar(bNavBarMulti) {
        var frameContent = findFrame(getTopWindow(), "content");
        var frameNavBar = findFrame(getTopWindow(), "navbar");
        var frameTreeDisplay = findFrame(getTopWindow(), "treeDisplay");
        var frameMain = findFrame(getTopWindow(), "mainFrame");
        var strContentURL = frameContent.document.location.href;
        strContentURL = addURLParam(strContentURL, (frameTreeDisplay ? "tree=true" : "tree=false"));
        var strMainURL;
        if (arguments.length > 0) {
                strMainURL =  URL_MAIN + "?multi=" + (bNavBarMulti ? "yes" : "no");
                objMgr.URLs['content'] = strContentURL;
        } else {
                strMainURL =  URL_MAIN + "?navbar="+objMgr.URLs['navbar']+"&emxcontenturl="+strContentURL;
        }
        frameMain.document.location.href = strMainURL;
}
//! Public Function hideTopFrame()
//!     This functions hides the top frame.
function hideTopFrame(strAppName) {
        topFrameset.rows = "54,*";
        frames[0].document.location.href = "../asp/AppHeader.asp?app=" + strAppName + "&shrunk=yes";
}
//! Public Function showTopFrame()
//!     This functions shows the top frame.
function showTopFrame(strAppName) {
        frames[0].document.location.href = "../asp/AppHeader.asp?app=" + strAppName;
        topFrameset.rows = "93,*";
}
//! Public Function showContent()
//!     ?
function showContent(strAltURL) {
	var objFrame = findFrame(getTopWindow(), "content");
	var strURL = (objMgr.URLs['content'] ? objMgr.URLs['content'] : strAltURL);
	objFrame.document.location.href = strURL;
}
//! Public Function showContent()
//!     Submits to a hidden frame which add item to session.
function addNavBarPageHistory(strTitle,strURL,strMenu,strCommand,strTarget,objCommandTitle,linkType,width,height,strSuite) {
        if(!isIE){
           strTitle=escape(strTitle);
        }        
        objCommandTitle=encodeURIComponent(objCommandTitle); 
        strTitle=encodeURIComponent(strTitle);
        var strFinalURL = "emxPageHistoryProcess.jsp?pageURL="+escape(strURL)+"&width="+width+"&height="+height+"&AppName="+strTitle+"&menuName="+strMenu+"&commandName="+strCommand+"&targetLocation="+strTarget+"&CommandTitle="+objCommandTitle+"&linkType="+linkType+"&suiteDir="+strSuite+"&myDeskSuiteDir="+strSuite;
        getTopWindow().hiddenFrame.location.href = strFinalURL;
}
