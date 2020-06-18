/*!================================================================
 *  JavaScript ActionBar
 *  emxUIActionbar.js
 *  Version 2.3
 *  UI Level 3
 *  Requires: emxUIConstants.js
 *  Last Updated: 20-Mar-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definition of the actionbar.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIActionbar.js.rca 1.27 Wed Oct 22 15:47:54 2008 przemek Experimental przemek $
 *=================================================================
 */
var localActionBar = null;
var IMG_PREV_ARROW = DIR_BUTTONS + "buttonActionbarPrev.gif";
var IMG_NEXT_ARROW = DIR_BUTTONS + "buttonActionbarNext.gif";
var IMG_PREV_GRAY_ARROW = DIR_BUTTONS + "buttonActionbarPrevDisabled.gif";
var IMG_NEXT_GRAY_ARROW = DIR_BUTTONS + "buttonActionbarNextDisabled.gif";
var IMG_SCROLL_UP = DIR_UTIL + "utilActionbarScrollUp.gif";
var IMG_SCROLL_DOWN = DIR_UTIL + "utilActionbarScrollDown.gif";
var IMG_BULLET = DIR_UTIL + "utilNavBarBullet.gif";
var CSS_CONTEXTUAL = "contextual";
var NUM_VISIBLE_LINKS = 4;
var LOC_TOP = 57;
var LOC_LEFT = 10;
var WATCH_DELAY = 50;
var POPUP_WIDTH = 200;
var POPUP_ITEM_HEIGHT = 20;
var POPUP_MAX_HEIGHT = 300;
var DELAY_BETWEEN = 50;
var SCROLL_DISTANCE = 10;
//! Class jsActionBar
//!     This class encapsulates the Action Bar object.
function jsActionBar() {
        this.links = new Array;
        this.selectedLayer = -1;
        this.actionsLayers = new Array;
        this.top = LOC_TOP;
        this.left = LOC_LEFT;
        this.visibleLinks = 4;
        this.addLink = _jsActionBar_addLink;
        this.createLayer = _jsActionBar_createLayer;
        this.draw = _jsActionBar_draw;
        this.drawLink = _jsActionBar_drawLink;
        this.switchTo = _jsActionBar_switchTo;
        localActionBar = this;
}
//! Public Method jsActionBar.addLink()
//!     This method adds a link to the control.
function _jsActionBar_addLink(strText, strURL, strTarget) {
        var objLink = new jsLink(strText, strURL, strTarget)
        objLink.id = this.links.length;
        this.links[this.links.length] = objLink;
        this.links[strText] = objLink;
        return objLink;
}
//! Private Method jsActionBar.createLayer()
//!     This method draws a set number of tabs onto a jsDocument.
function _jsActionBar_createLayer(d, iStart, iStop) {
        var isPrev = (iStart > 0);
        var isNext = (iStop < this.links.length);
        var strName = "strip" + this.actionsLayers.length;
        var curLeft = 0;
        var bodyNode, divStrip;
        this.actionsLayers[this.actionsLayers.length] = strName;
        d.write("<style>");
        d.write("#" + strName + " {position: absolute; top: " + this.top + "px; left: " + this.left + "px; visibility: " + (isPrev ? "hidden" : "visible")+ "; width: 1%; }");
        d.write("</style>");
        d.write("<div id=\"");
        d.write(strName);
        d.write("\">");
        d.write("<table border=\"0\"><tr>");
        for (var i=iStart; i < this.links.length && i < iStop; i++) {
                this.drawLink(d, this.links[i], i);
        }
        if (isPrev || isNext){
                d.write("<td nowrap>");
        }
        if (isPrev) {
                d.write("<a href=\"javascript:localActionBar.switchTo('");
                d.write(this.actionsLayers[this.actionsLayers.length - 2]);
                d.write("', '");
                d.write(strName);
                d.write("')\"><img src=\"");
                d.write(IMG_PREV_ARROW);
                d.write("\" border=\"0\"></a>");
        } else {
                if (isNext) {
                        d.write("<td nowrap ><img src=\"");
                        d.write(IMG_PREV_GRAY_ARROW);
                        d.write("\" border=\"0\">");
                }
        }
        if (isNext) {
                d.write("<a href=\"javascript:localActionBar.switchTo('strip");
                d.write(this.actionsLayers.length);
                d.write("', '");
                d.write(strName);
                d.write("')\"><img src=\"");
                d.write(IMG_NEXT_ARROW);
                d.write("\" border=\"0\"></a>");
        } else {
                if (isPrev) {
                        d.write("<img src=\"");
                        d.write(IMG_NEXT_GRAY_ARROW);
                        d.write("\" border=\"0\">");
                }
        }
        if (isPrev || isNext) {
                d.write("</td>");
        }
        d.write("</tr></table>");
        d.writeln("</div>");
}
//! Private Method jsActionBar.draw()
//!     This method draws the Action Bar onto the screen.
function _jsActionBar_draw() {
        var d = new jsDocument;
        var numLayers = Math.ceil(this.links.length / this.visibleLinks);
        for (var i=0; i < numLayers; i++){
                this.createLayer(d, 0 + (this.visibleLinks * i), this.visibleLinks + (this.visibleLinks * i));
        }
        document.write(d);
}
//! Private Method jsActionBar.drawLink()
//!     This method draws an individual link onto a jsDocument.
function _jsActionBar_drawLink(d, objLink) {
        var strURL = "javascript:clickLink(" + objLink.id + ")";
        d.write("<td><img src=\"");
        d.write(IMG_BULLET);
        d.write("\" border=\"0\" alt=\"*\" /></td><td nowrap=\"nowrap\"><a class=\"");
        d.write(CSS_CONTEXTUAL);
        d.write("\" href=\"");
        d.write(strURL);
        d.write("\">");
        d.write(objLink.text);
        d.write("</a></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"20\" width=\"5\" alt=\"\" /></td>");
}
//! Private Method jsActionBar.switchTo()
//!     This method toggles between the two tab layers.
function _jsActionBar_switchTo(strIDTo, strIDFrom) {
        if (isIE) {
                document.all[strIDFrom].style.visibility = "hidden";
                document.all[strIDTo].style.visibility = "visible";
        } else if (isNS4) {
                document.layers[strIDFrom].visibility = "hide";
                document.layers[strIDTo].visibility = "show";
        } else if (isNS6 || isMinMoz1 ) {
                document.getElementById(strIDFrom).style.visibility = "hidden";
                document.getElementById(strIDTo).style.visibility = "visible";
        }
}
//! Class jsLink
//!     This class represents a single link.
function jsLink (strText, strURL, strTarget) {
        this.isJS = (strURL.toLowerCase().indexOf("javascript:") == 0);
        this.text = strText;
        this.url = strURL;
        this.target = strTarget;
}
//! Private Function clickLink()
//!     This function handles clicking on links.
function clickLink(iLinkID) {
        var objLink = localActionBar.links[iLinkID];
        if (objLink.isJS) {
                eval(objLink.url);
        } else {
                var objTargetWindow = null;
                switch(objLink.target) {
                        case "_top" :
                                objTargetWindow = getTopWindow();
                                break;
                        case "_parent":
                                objTargetWindow = parent;
                                break;
                        case "_self":
                                objTargetWindow = self;
                                break;
                        default:
                                objTargetWindow = objLink.target ? findFrame(getTopWindow(), objLink.target) : self;
                }
                objTargetWindow.document.location.href = objLink.url;
        }
}

//! Private Function showError()
//!     This function displays javascript alert messages to the user.
function showError(errMessage){
        alert(fnReplaceString(errMessage));
}
//! Private Function fnReplaceString()
//!     This function removes plus sign and replace with spaces.
function fnReplaceString(str){
        var dest="";
        var len=str.length;
        var index=0;
        var code=null;
        for(var i=0;i<len; i++){
                var ch=str.charAt(i);
                if(ch=="+"){
                        code=" ";
                }
                if(code!=null){
                        dest+=str.substring(index,i)+code;
                        index=i+1;
                        code=null;
                }
        }
        if(index<len){
                dest+=str.substring(index,len);
                return dest;
        }
}
