/*  IEFUIConstants.js

   Copyright Dassault Systemes, 1992-2007. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

*/
//IEF UI constants
var DIR_IMAGES = "../common/images/";
var DIR_APPLEVEL_IMAGES = "../common/images/";
var DIR_BUTTONS = DIR_APPLEVEL_IMAGES + "";
var DIR_UTIL = DIR_APPLEVEL_IMAGES;
var IMG_SPACER = DIR_IMAGES + "utilSpacer.gif";

var strUserAgent = navigator.userAgent.toLowerCase();
var isIE = detectIE();
var isMinIE5 = false,isMinIE55 = false,isMinIE6 = false,isMinIE9 = false,isMaxIE8 = false, isMaxIE7 = false; isIE11 = false;
if (isIE) {
        var reIE = new RegExp("msie (\\S*);");
        var regResult = reIE.test(strUserAgent);
		var fVer;
		if(!regResult){
			reIE = new RegExp("rv:(\\d*)");	
			fVer = parseFloat(reIE.test(strUserAgent)[1]);
		}
		else{
			fVer = parseFloat(regResult[1]);
		}
        isMinIE5 = fVer >= 5;
        isMinIE55 = fVer >= 5.5;
        isMinIE6 = fVer >= 6;
        isMinIE9 = fVer >= 9;
        isMaxIE8 = fVer <= 8;
        isMaxIE7 = fVer <= 7;
        isIE11 = fVer == 11;
} 
var isNS6 = strUserAgent.indexOf("netscape6") > -1 && strUserAgent.indexOf("opera") == -1;
var isMinNS6 = isNS6,isMinNS61 = false,isMinNS62 = false;
if (isNS6) {
        var reNS6 = new RegExp("netscape6\\/(\\S*)");
        reNS6.test(strUserAgent);
        var fVer = parseFloat(RegExp["$1"]);
        isMinNS6 = (fVer >= 6);
        isMinNS61 = (fVer >= 6.1);
        isMinNS62 = (fVer >= 6.2);
} 
var isNS4 = !isIE && !isNS6  && parseFloat(navigator.appVersion) < 5 && strUserAgent.indexOf("opera") == -1;
var isMinNS45 = false,isMinNS46 = false,isMinNS47 = false,isMinNS479 = false;
if (isNS4) {
        var fVer = parseFloat(navigator.appVersion);
        isMinNS45 = fVer >= 4.5;
        isMinNS46 = fVer >= 4.6;
        isMinNS47 = fVer >= 4.7;
        isMinNS479 = fVer >= 4.79;
} 
var isGecko = strUserAgent.indexOf("gecko") > -1;
var isMoz = isGecko || isNS6;
var isMinMoz092 = false,isMinMoz094 = false,isMinMoz098 = false,isMinMoz1 = false;
if (isMoz) {
        if (strUserAgent.indexOf("rv:") > -1) {
                var reMoz = new RegExp("rv:(\\d\\.\\d)([\\.\\d]*)");
                reMoz.test(strUserAgent);
                var fMajorVer = RegExp["$1"];
                var fMinorVer = RegExp["$2"];
                isMinMoz092 = (fMajorVer == 0.9 && fMinorVer >= 0.2) || (fMajorVer > 0.9);
                isMinMoz094 = (fMajorVer == 0.9 && fMinorVer >= 0.4) || (fMajorVer > 0.9);
                isMinMoz098 = (fMajorVer == 0.9 && fMinorVer >= 0.8) || (fMajorVer > 0.9);
                isMinMoz1 = (fMajorVer >= 1.0);
        } 
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
var isMac = navigator.platform.indexOf("Mac") > -1;
var isUnix = strUserAgent.indexOf("x11") > -1;
var isHPUX = strUserAgent.indexOf("hp-ux") > -1;
var isSunOS = strUserAgent.indexOf("sunos") > -1;

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
                this.write("<html><head>");
                this.write("<link rel=\"stylesheet\" href=\"");
                this.write(strStylesheet);
                this.write("\">");
                this.write("</head>");
        }; 
        this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + ">"); };
        this.writeHTMLFooter = function () { this.writeln("</body></html>"); };
} 
function detectIE() {
		var ua = window.navigator.userAgent;
        var msie = ua.indexOf('MSIE ');
        if (msie > 0) {
          // IE 10 or older => return
           return true;
        }
        var trident = ua.indexOf('Trident/');
        if (trident > 0) {
          // IE 11 => return
          return true;
        }
        var edge = ua.indexOf('Edge/');
        if (edge > 0) {
          // Edge (IE 12+) => return
          return true;
        }
		// other browser
		return false;
 }
