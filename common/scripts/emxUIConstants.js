 /*!================================================================
 *  JavaScript Constants
 *  emxUIConstants.js
 *  Version 1.8
 *  UI Level 3
 *  Requires: (nothing)
 *  Last Updated: 11-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definition of the actionbar.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIConstants.js.rca 1.37.2.1 Tue Dec 16 04:55:36 2008 ds-smahapatra Experimental $
 *=================================================================
 */

// Try to consolidate browser detection at on place. Use emxUICore.js
var Browser = (function () {
	/*
	 * User Agent String for all the supported browser
	 *
	 *
	 * */
	var browsers = {
				"IE" : false,
				"FIREFOX" : false,
				"CHROME" : false,
				"MOZILLA_FAMILY": false,
				"SAFARI" : false,
				"MOBILE" : false
 			};


	detectBrowser = function(ua){
		var ie = /(msie|trident)/i.test(ua)
      , chrome = /chrome|crios/i.test(ua)
      , safari = /safari/i.test(ua) && !chrome
      , firefox = /firefox/i.test(ua)
      , mobile = /(Mobile)/i.test(ua) || /(Touch|Tablet PC*)/.test(ua);
		if(ie){
			browsers.IE=true;
		}else if (chrome){
			browsers.CHROME=true;
		}else if(safari){
			browsers.SAFARI=true;
		}else if(firefox){
			browsers.FIREFOX=true;
		}
		if(mobile){
			browsers.MOBILE = true;
		}
		if(chrome || safari || firefox){
			browsers.MOZILLA_FAMILY=true;
		}
	};
	detectBrowser(navigator.userAgent);
	return browsers;
}());

var DIR_IMAGES = "../common/images/";
var DIR_STYLES = "../common/styles/";
var DIR_APPLEVEL_STYLES = "../common/styles/";
var DIR_APPLEVEL_IMAGES = "../common/images/";
var DIR_TREE = DIR_IMAGES;
var DIR_NAVBAR = DIR_IMAGES;
var DIR_SEARCHPANE = DIR_IMAGES;
var DIR_BUTTONS = DIR_APPLEVEL_IMAGES + "";
var DIR_SMALL_ICONS = DIR_IMAGES+"";
var DIR_BIG_ICONS = DIR_IMAGES + "";
var DIR_UTIL = DIR_APPLEVEL_IMAGES;
var IMG_BULLET = DIR_IMAGES + "yellowbullet.gif";
var IMG_SPACER = DIR_IMAGES + "utilSpacer.gif";
var IMG_LOADING = DIR_IMAGES + "iconStatusLoading.gif";
var URL_MAIN = "../common/emxMainFrame.asp";
var URL_SHRUNK = "../common/emxShrunkFrame.asp";
var UI_LEVEL = 3;
var CALENDAR_START_DOW = 0;
var HIDDEN_FRAME_LIST = ["listHidden","postHidden","formViewHidden","formEditHidden","formCreateHidden","hiddenFrame","pagehidden","imageHidden","searchHidden"];


var strUserAgent = navigator.userAgent.toLowerCase();
var isKHTML = Browser.SAFARI || Browser.CHROME ;

var isIE = Browser.IE;
var isMoz = Browser.FIREFOX;
var isChrome = Browser.CHROME;

var isMac = navigator.platform.indexOf("Mac") > -1;
var isLinux = navigator.platform.indexOf("Linux") > -1;
var isUnix = strUserAgent.indexOf("x11") > -1;
var isHPUX = strUserAgent.indexOf("hp-ux") > -1;
var isSunOS = strUserAgent.indexOf("sunos") > -1;


//no more supported, should be removed after discussion with application team
var isNS4 = false;
var isMinIE5 = isMinIE51 = isMinIE52 = isMinIE55 = isMinIE6 = false;
var isMinMoz092 = isMinMoz094 = isMinMoz098 = isMinMoz1 = isMinMoz14 = isNS6 = isMinNS6 = isMinNS61 = isMinNS62 = false;
var isMinNS4 = isMinNS45 = isMinNS47 = isMinNS475 = isMinNS479 = isMinNS48 = false;
var isMaxMoz178 = false;
var isMinMoz17 = false;
var isMinMoz16 = false;
var isMinMoz18 = false;
var isMinMoz19 = false;
var isMinMoz1907 = false;

if (isIE) {
        var reIE = new RegExp("msie (\\S*);");
        var regResult = reIE.exec(strUserAgent);
		var fVer;
		if(!regResult){
			reIE = new RegExp("rv:(\\d*)");	
			fVer = parseFloat(reIE.exec(strUserAgent)[1]);
		}
		else{
			fVer = parseFloat(regResult[1]);
		}
		isMinIE5 = fVer >= 5;
        isMinIE51 = fVer >= 5.1;
        isMinIE52 = fVer >= 5.2;
        isMinIE55 = fVer >= 5.5;
        isMinIE6 = fVer >= 6;
        isMaxIE7 = fVer < 8;
        isMinIE9 = fVer > 8;
        isMinIE10 = fVer > 9;
} else if (isMoz) {
        isNS6 = isMinNS6 = true;
        if (strUserAgent.indexOf("rv:") > -1) {
                (new RegExp("rv:(\\d\\.\\d)([\\.\\d]*)")).test(strUserAgent);
                var fMajorVer = RegExp["$1"];
                var fMinorVer = RegExp["$2"];
				isMinMoz092 = isMinNS61 = (fMajorVer == 0.9 && fMinorVer >= 0.2) || (fMajorVer > 0.9);
                isMinMoz094 = isMinNS62 = (fMajorVer == 0.9 && fMinorVer >= 0.4) || (fMajorVer > 0.9);
                isMinMoz098 = (fMajorVer == 0.9 && fMinorVer >= 0.8) || (fMajorVer > 0.9);
                isMinMoz1 = (fMajorVer >= 1.0);
                isMinMoz14 = (fMajorVer >= 1.4);
                isMinMoz16 = (fMajorVer >= 1.6);
                isMinMoz17 = (fMajorVer >= 1.7);
                isMinMoz18 = (fMajorVer >= 1.8);
				isMinMoz19 = (fMajorVer >= 1.9);
                if (fMinorVer != null)
                {
					if (isMinMoz18)
					{
							var minorVerNum = fMinorVer.substring(1);
		                	isMaxMoz18 = ((isMinMoz14 || isMinMoz16) && !(isMinMoz17))|| (isMinMoz17 && minorVerNum <= 8);
					}
					else{
                     	var minorVerNum = fMinorVer.substring(1);
	                		isMaxMoz178 = ((isMinMoz14 || isMinMoz16) && !(isMinMoz17))|| (isMinMoz17 && minorVerNum <= 8);
                    }

                  	if (isMinMoz19)
					{
							var minorVerNum1 = fMinorVer.substring(1,2);
							var minorVerNum2 = fMinorVer.substring(3);
							isMinMoz1907 = ( minorVerNum2 >= 7 || minorVerNum1 >=1  );

					}
                 }
        }
} else if (isNS4) {
        var fVer = parseFloat(navigator.appVersion);
        isMinNS4 = true;
        isMinNS45 = fVer >= 4.5;
        isMinNS46 = fVer >= 4.6;
        isMinNS47 = fVer >= 4.7;
        isMinNS479 = fVer >= 4.79;
        isMinNS48 = fVer >= 4.8;
}
var isWin = navigator.platform.indexOf("Win") > -1;
var isWinNT = false,isWin95 = false,isWin98 = false,isWin2000 = false,isWinME = false,isWinXP = false;
if (isWin) {
        if (isIE) {
                isWinNT = strUserAgent.indexOf("windows nt 4.0") > -1;
                isWin95 = strUserAgent.indexOf("windows 95") > -1;
                isWin98 = strUserAgent.indexOf("windows 98") > -1;
                isWin2000 = strUserAgent.indexOf("windows nt 5.0") > -1;
                isWinME = strUserAgent.indexOf("win 9x 4.90") > -1;
                isWinXP = strUserAgent.indexOf("windows nt 5.1") > -1;
        } else if (isMoz) {
                isWinNT = strUserAgent.indexOf("winnt4.0") > -1;
                isWin95 = strUserAgent.indexOf("win95") > -1;
                isWin98 = strUserAgent.indexOf("win98") > -1;
                isWin2000 = strUserAgent.indexOf("windows nt 5.0") > -1;
                isWinME = strUserAgent.indexOf("win 9x 4.90") > -1;
                isWinXP = strUserAgent.indexOf("windows nt 5.1") > -1;
        } else if (isNS4) {
                isWinNT = strUserAgent.indexOf("winnt") > -1;
                isWin95 = strUserAgent.indexOf("win95") > -1;
                isWin98 = strUserAgent.indexOf("win98") > -1;
                isWin2000 = strUserAgent.indexOf("windows nt 5.0") > -1;
                isWinME = strUserAgent.indexOf("win 9x 4.90") > -1;
        }
}
//no more supported, should be removed after discussion with application team




if(typeof emxUIConstants == "undefined"){

	var uiconstantscache = typeof sessionStorage != "undefined" ? sessionStorage.getItem('uiConstantsCache') : null;
	if(uiconstantscache){
		uiconstantscache= JSON.parse(uiconstantscache);
		var emxUIConstants = uiconstantscache;
	}else{
		document.write("<scri" + "pt language=\"JavaScript\" type=\"text/javascript\" src=\"../common/emxUIConstantsJavaScriptInclude.jsp\"></scr" + "ipt>");
	}
}

//! Public Method Array.pop()
//!     This methods pops an item off the back of the array. This
//!     only is used in IE 5.0 because it doesn
//!     pop() method.
if (!Array.prototype.pop) {
        Array.prototype.pop = function () {
                var objItem = this[this.length-1];
                this.length--;
                return objItem;
        }
}
//! Public Method Array.push()
//!     This methods pushes an item onto the back of the array. This
//!     only is used in IE 5.0 because it doesn
//!     push() method.
if (!Array.prototype.push) {
        Array.prototype.push = function (objItem) {
                this[this.length] = objItem;
        }
}
//! Public Method Array.find()
//!     This methods finds the given item and returns its index in
//!     the array.
Array.prototype.find = function (objItem) {
        var bFound = false;
        for (var i=0; i  < this.length && !bFound; i++) {
                if (this[i] == objItem) {
                        bFound = true;
                }
        }
        if (bFound) {
                return i-1;
        } else {
                return -1;
        }
}
//! Public Method Array.remove()
//!     This methods finds the given item and removes it from the array.
//!     It does nothing if the item is not found.
Array.prototype.remove = function (objItem) {
        var iPos = this.find(objItem);
        if (iPos > -1) {
                for (var i= iPos + 1; i < this.length; i++) {
                        this[i-1] = this[i];
                }
                this.length--;
        }
}
//! Public Method String.htmlEncode()
//!     This method converts a string into an HTML string by replacing
//!     all illegal characters with appropriate entities.
String.prototype.htmlEncode = function (blnAll) {
        var strTemp = this;
        if (blnAll) {
                strTemp = strTemp.replace(new RegExp("&", "g"), "&amp;");
                strTemp = strTemp.replace(new RegExp("\\\"", "g"), "&quot;");
                strTemp = strTemp.replace(new RegExp("\\\'", "g"), "&apos;");
        }
        strTemp = strTemp.replace(new RegExp("<", "g"), "&lt;");
        strTemp = strTemp.replace(new RegExp(">'", "g"), "&gt;");
        return strTemp;
}
function jsDocument() {
        this.text = new Array;
        for (var i=0; i < arguments.length; i++) {
                this.text[i] = arguments[i];
        }
        this.write = function (str) { this.text[this.text.length] = str; };
        this.writeln = function (str) { this.text[this.text.length] = str + "\n"; };
        this.toString = function () { return this.text.join(""); };
        this.clear = function () { delete this.text; this.text = new Array; };
        this.writeHTMLHeader = function (strStylesheet) {
                this.write("<!DOCTYPE html><html><head>");
                this.write("<link rel=\"stylesheet\" href=\"");
                this.write(getStyleSheet("emxUIDefault"));
                this.write("\">");
                this.write("<link rel=\"stylesheet\" href=\"");
                this.write(strStylesheet);
                this.write("\">");
                //Modified For Bug : 348007
                this.write("<link rel=\"stylesheet\" href=\"");
                this.write(getStyleSheet("emxUIMenu"));
                this.write("\">");
				this.write("<script type=\"text/javascript\" src=\"../common/scripts/emxUICore.js\"></script>");
                this.write("</head>");
        };
        this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + ">"); };
        this.writeHTMLFooter = function () { this.writeln("</body></html>"); };
}
//! Public Function findFrame()
//!     This function finds a frame with a given name.
function findFrame(objWindow, strName) {
        if (strName == "_top") {
                return getTopWindow();
        } else if (strName == "_self") {
                return self;
        } else if (strName == "_parent") {
                return parent;
        } else {
                var objFrame = null;
                try
                {
                	if(objWindow && objWindow.frames){
                		for (var i = 0; i < objWindow.frames.length && !objFrame; i++) {
							try {
								if (objWindow.frames[i] && objWindow.frames[i].name && objWindow.frames[i].name == strName) {
									objFrame = objWindow.frames[i];
								}
							} catch(ex){
							}
                          }
                	}

                }
                catch(e) {
					if(e.description && e.description.search(/Denied/i) == -1)
					{
						  if(-2146828218 != e.number && -2147418094 != e.number)
						  {
							if(e.description == ""){
								alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
					    				+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
					    				+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
					    				+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message);
							} else if(-2147024891!= e.number){
								alert(e.description);
						    }
	                   }
	                }
                }

                if (!objFrame) {
                	try
                	{
                		if(objWindow && objWindow.frames){
                			for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
                                objFrame = findFrame(objWindow.frames[i], strName);
                			}
                		}
                  }
					catch(e)
					{
						if(e.description && e.description.search(/Denied/i) == -1)
						{
						  if(-2146828218 != e.number && -2147418094 != e.number)
						  {
							if(e.description == ""){
								alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
					    				+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
					    				+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
					    				+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message);
							} else if(-2147024891!= e.number){
								alert(e.description);
							}
						}
                  }
                }
                }
            	return objFrame;
        }
}
//! Public Function openerFindFrame()
//!     This function finds a frame from current window or its
//!     getWindowOpener() with a given name.
function openerFindFrame(objWindow, strName) {

		var objFrame = null;
		try{
			objFrame = findFrame(objWindow, strName);
	        var objOpenerWindow = null;
	        if (!objFrame){
	                if (objWindow && objWindow.getWindowOpener() && !objWindow.getWindowOpener().closed){
	                        objOpenerWindow = objWindow.getWindowOpener().getTopWindow();
	                        if (objOpenerWindow) {
	                                objFrame = openerFindFrame(objOpenerWindow, strName)
	                        }
	                }
	        }
	    }
	    catch(e){
		// ignore any error (function returns null)
	    }
        return objFrame;
}
//! Public Function addURLParam()
//!     This function adds a parameter to a URL.
function addURLParam(strURL, strParam) {
        var strNewURL = strURL;
        if (strNewURL.indexOf(strParam) == -1){
                strNewURL += (strNewURL.indexOf('?') > -1 ? '&' : '?') + strParam;
        }
        return strNewURL;
}
//! Public Function addUniqueURLParam()
//!     This function adds a parameter to a URL if not existing.
function addUniqueURLParam(strURL, strParam) {
        var strNewURL = strURL;
        var arrayParamNameValue = new Array;
        if (strParam && strParam.indexOf("=") != -1){
                arrayParamNameValue = strParam.split('=');
                strParamName = arrayParamNameValue[0];
                if (strNewURL.indexOf(strParamName + "=") == -1){
                        strNewURL += (strNewURL.indexOf('?') > -1 ? '&' : '?') + strParam;
                }
        }
        return strNewURL;
}
//! Public Function showError()
//!     This function displays an alert with error text.
function showError(strError) {
        alert(emxUIConstants.STR_ERROR_HEADER + strError);
}
//! Public Function showConfirmation()
//!     This function displays a confirmation box with confirmation text.
function showConfirmation(strConfirm) {
        return confirm(STR_CONFIRM_HEADER + strConfirm);
}
//! Public Function doNothing()
//!     This function is assigned to an event in order to block its occurance.
function doNothing() {
        return false;
}
//! Private Function getStyleSheet()
//!     This function creates the style sheet string for a given style sheet prefix.
function getStyleSheet(strCSSPrefix, cssPath) {
        var strCSSFile = "";
        if(cssPath){
        	strCSSFile = cssPath + strCSSPrefix;
        }else{
        	strCSSFile = DIR_STYLES + strCSSPrefix;
        }
        if (isUnix) {
                strCSSFile += "_Unix.css";
        } else {
                strCSSFile += ".css";
        }
        return strCSSFile;
}
//! Public Function addStyleSheet()
//!     This function adds a style sheet to the given document.
//! we have to refactor this method as not to take cssPath once we move all the CSS from main folder into common/styles folder
function addStyleSheet(strCSSPrefix, cssPath) {
        var strCSSFile = getStyleSheet(strCSSPrefix, cssPath);
        document.write("<link rel=\"stylesheet\" type=\"text/css\" ");
        document.write("href=\"" + strCSSFile + "\">");
}

//! Public Function appendStyleSheet()
//!     This function appends a style sheet to the given document.
//! we have to refactor this method as not to take cssPath once we move all the CSS from main folder into common/styles folder
function appendStyleSheet(strCSSPrefix, cssPath) {
	var link = document.createElement('link');
	var strCSSFile = getStyleSheet(strCSSPrefix, cssPath);
    link.setAttribute('rel', 'stylesheet');
    link.setAttribute('type', 'text/css');
    link.setAttribute('href', strCSSFile);
    document.getElementsByTagName('head')[0].appendChild(link);
}

//! Public Function turnOffProgress()
//!     This function changes the progress clock so that it disappears.
function turnOffProgress() {
	try{
		var isfound = false;
		if(parent.turnOffProgressTop){
			parent.turnOffProgressTop();
		}else if(getTopWindow().turnOffProgressTop){
			getTopWindow().turnOffProgressTop();
			isfound = true;
		}
		if((document.getElementById('imgProgressDiv')) != null)
		{
			document.getElementById('imgProgressDiv').style.visibility = 'hidden';
			isfound = true;		
		}
		else if((document.getElementById('imgLoadingProgressDiv')) != null){
			document.getElementById('imgLoadingProgressDiv').style.visibility = 'hidden';
			isFound=true;
		}
		else if((parent.frames[0])!=null && (parent.frames[0].document.getElementById('imgProgressDiv')) != null)
		{
			parent.frames[0].document.getElementById('imgProgressDiv').style.visibility = 'hidden';
			isfound = true;		
		}
		else if ((parent.frames[1])!=null &&  (parent.frames[1].document.getElementById('imgProgressDiv')) != null)
		{
			parent.frames[1].document.getElementById('imgProgressDiv').style.visibility = 'hidden';
			isfound = true;		
		}
		else if((getTopWindow().document != null) && (getTopWindow().document.getElementById('imgProgressDiv')) != null)
		{
			getTopWindow().document.getElementById('imgProgressDiv').style.visibility = 'hidden';
			isfound = true;		
		}
		else if((parent.document != null)) {
			if(parent.document.getElementById('imgProgressDiv') != null){
			parent.document.getElementById('imgProgressDiv').style.visibility = 'hidden';
			}else if(parent.document.getElementById('imgProgressDivChannel')!=null){
				jQuery(parent.document).find('div#imgProgressDivChannel').each(function(elem, value){value.style.visibility = 'hidden';});
			}
			isfound = true;		
		}
		if((document.getElementById('imgProgressDivChannel')) != null)
		{
			document.getElementById('imgProgressDivChannel').style.visibility = 'hidden';
			document.getElementById("imgLoadingProgressDiv").style.visibility = 'hidden';
			isfound = true;		
	    }
		else if((parent.frames[0])!=null && (parent.frames[0].document.getElementById('imgProgressDivChannel')) != null)
		{
			parent.frames[0].document.getElementById('imgProgressDivChannel').style.visibility = 'hidden';
			parent.frames[0].document.getElementById("imgLoadingProgressDiv").style.visibility = 'hidden';
		    isfound = true;		
	    }
		else if ((parent.frames[1])!=null &&  (parent.frames[1].document.getElementById('imgProgressDivChannel')) != null)
		{
			parent.frames[1].document.getElementById('imgProgressDivChannel').style.visibility = 'hidden';
			parent.frames[1].document.getElementById('imgLoadingProgressDiv').style.visibility = 'hidden';
		    isfound = true;		
	    }
		else if((getTopWindow().document != null) && (getTopWindow().document.getElementById('imgProgressDivChannel')) != null)
		{
			getTopWindow().document.getElementById('imgProgressDivChannel').style.visibility = 'hidden';
			getTopWindow().document.getElementById('imgLoadingProgressDiv').style.visibility = 'hidden';
		    isfound = true;		
	    }
		else if((parent.document != null) && (parent.document.getElementById('imgProgressDivChannel')) != null) {
			parent.document.getElementById('imgProgressDivChannel').style.visibility = 'hidden';
			parent.document.getElementById('imgLoadingProgressDiv').style.visibility = 'hidden';
		    isfound = true;		
	    }
	    if(portalMode == "true"){
			toggleProgress('hidden');
		    isfound = true;		
	    }
		if(!isfound)
		{
			setTimeout("turnOffProgress()", 500);
		}
	}catch(e){
		//do nothing
	}
}

//! Public Function turnOnProgress()
//!     This function changes the progress clock so that it reappears.
function turnOnProgress(strImage) {
	
	try{
		var isfound=false;
		if(parent.turnOnProgressTop)
			parent.turnOnProgressTop();
		else if(getTopWindow().turnOnProgressTop)
			getTopWindow().turnOnProgressTop();

		if((document.getElementById('imgProgressDiv')) != null)
		{
			document.getElementById('imgProgressDiv').style.visibility = 'visible';
		    isfound = true;		
		}
		else if((document.getElementById('imgLoadingProgressDiv')) != null){
			document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			isFound=true;
		}
		else if ((parent.frames[0])!=null && (parent.frames[0].document.getElementById('imgProgressDiv')) != null)
		{
			parent.frames[0].document.getElementById('imgProgressDiv').style.visibility = 'visible';
		    isfound = true;		
		}
		else if ((parent.frames[1])!=null && parent.frames[1].document && (parent.frames[1].document.getElementById('imgProgressDiv')) != null)
		{
			parent.frames[1].document.getElementById('imgProgressDiv').style.visibility = 'visible';
		    isfound = true;		
		}
		else if((getTopWindow().document != null) && (getTopWindow().document.getElementById('imgProgressDiv')) != null)
		{
			getTopWindow().document.getElementById('imgProgressDiv').style.visibility = 'visible';
		    isfound = true;		
		}
		else if((parent.document != null)) {
			if(parent.document.getElementById('imgProgressDiv') != null){
			parent.document.getElementById('imgProgressDiv').style.visibility = 'visible';
			}else if(parent.document.getElementById('imgProgressDivChannel')!=null){
				parent.document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			}
		    isfound = true;		
	    }
		if((document.getElementById('imgProgressDivChannel')) != null)
		{
			document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			document.getElementById('imgLoadingProgressDiv').innerHTML = emxUIConstants.STR_LOADING;
		    isfound = true;		
	    }
		else if ((parent.frames[0])!=null && (parent.frames[0].document.getElementById('imgProgressDivChannel')) != null)
		{
			parent.frames[0].document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			parent.frames[0].document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			parent.frames[0].document.getElementById('imgLoadingProgressDiv').innerHTML = emxUIConstants.STR_LOADING;
		    isfound = true;		
	    }
		else if ((parent.frames[1])!=null && parent.frames[1].document && (parent.frames[1].document.getElementById('imgProgressDivChannel')) != null)
		{
			parent.frames[1].document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			parent.frames[1].document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			parent.frames[1].document.getElementById('imgLoadingProgressDiv').innerHTML = emxUIConstants.STR_LOADING;
		    isfound = true;		
	    }
		else if((getTopWindow().document != null) && (getTopWindow().document.getElementById('imgProgressDivChannel')) != null)
		{
			getTopWindow().document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			getTopWindow().document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			getTopWindow().document.getElementById('imgLoadingProgressDiv').style.innerHTML = emxUIConstants.STR_LOADING;
		    isfound = true;		
	    }
		else if((parent.document != null) && (parent.document.getElementById('imgProgressDivChannel')) != null) {
			parent.document.getElementById('imgProgressDivChannel').style.visibility = 'visible';
			parent.document.getElementById('imgLoadingProgressDiv').style.visibility = 'visible';
			parent.document.getElementById('imgLoadingProgressDiv').innerHTML = emxUIConstants.STR_LOADING;
		    isfound = true;		
		}
		if(!isFound)
		{

			setTimeout("turnOnProgress()", 500);
		}
	}catch(e){
			//do nothing
	}
}




