/*!================================================================
 *  JavaScript Modal Dialog
 *  emxUIModal.js
 *  Version 1.5
 *  Requires: emxUIConstants.js
 *  Last Updated: 28-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definition of the structure tree.
 *
 *  Copyright (c) 1992-2010 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIModal.js.rca 1.43 Tue Oct 28 18:55:06 2008 przemek Experimental przemek $
 *=================================================================
 */ 
var bPageHistory = false;
var strUserAgent_M = navigator.userAgent.toLowerCase();
var isIE_M = (strUserAgent_M.indexOf("msie") > -1 || strUserAgent_M.indexOf("trident") > -1) && strUserAgent_M.indexOf("opera") == -1;
var isMinIE5_M = false,isMinIE55_M = false,isMinIE6_M = false;
if (isIE_M) {
    var reIE_M = new RegExp("msie (\\S*);");
    reIE_M.test(strUserAgent_M);
    var fVer_M = parseFloat(RegExp["$1"]);
    isMinIE5_M = fVer_M >= 5;
    isMinIE55_M = fVer_M >= 5.5;
    isMinIE6_M = fVer_M >= 6;
}
var isNS6_M = strUserAgent_M.indexOf("netscape6") > -1 && strUserAgent_M.indexOf("opera") == -1;
var isMinNS6_M = isNS6_M,isMinNS61_M = false,isMinNS62_M = false;
if (isNS6_M) {
    var reNS6_M = new RegExp("netscape6\\/(\\S*)");
    reNS6_M.test(strUserAgent_M);
    var fVer_M = parseFloat(RegExp["$1"]);
    isMinNS6_M = (fVer_M >= 6);
    isMinNS61_M = (fVer_M >= 6.1);
    isMinNS62_M = (fVer_M >= 6.2);
}
var isNS4_M = !isIE_M && !isNS6_M  && parseFloat(navigator.appVersion) < 5 && strUserAgent_M.indexOf("opera") == -1;

var isGecko_M = strUserAgent_M.indexOf("gecko") > -1;
var isMoz_M = isGecko_M || isNS6_M;
var isMac_M = navigator.platform.indexOf("Mac") > -1;
var isSAF_M = strUserAgent_M.indexOf("safari") > -1;

var strProtocol, strHost, strPort;

with(document.location){
    strProtocol = protocol;
    strHost = hostname;
    strPort = port
}

//! Class emxUIModalDialog
//!     This class represents a modal dialog window. This class
//!     should not be instantiated directly by a developer.
function emxUIModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars) {
        if (isIE_M) {
                return new emxUIIEModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars);
        } else {
                return new emxUIMozillaModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars);
        }
}

var i=0;
//! Public Function showModalDialog()
//!     This function opens a modal dialog window and centers it.
function showIEFModalDialog(strURL, intWidth, intHeight, bScrollbars) {

	i=0;
	closeIEFModalDialog();
	
	if ((isMac_M  && isSAF_M)|| (isIE_M) || (!top.modalDialog || top.modalDialog.contentWindow.closed)) {

		var objModalDialog = new emxUIModalDialog(self, strURL, intWidth, intHeight, bScrollbars);
		objModalDialog.show();
	} 
	else
	{
		if (top.modalDialog) {
			top.modalDialog.show();
		}
	}
}

function closeIEFModalDialog() {
	try
	{
	if (top.modalDialog && !top.modalDialog.contentWindow.closed)
	{
		try
		{
			top.modalDialog.contentWindow.closeModalDialog();
		}
		catch(error)
		{
			top.modalDialog.contentWindow.close();
		}

		if (i < 10 && isIE_M && top.modalDialog && !top.modalDialog.contentWindow.closed)
							{
			i++;
			//IE 8 issue : Modal dialog close is not closing the Top Window
			sleep(100);
			closeIEFModalDialog();
                }
        }
}
	catch(error)
	{
		return;
	}
}

//!private function
function sleep(millis)
{
	var date = new Date();
	var curDate = null;

	do { curDate = new Date(); }
	while(curDate-date < millis);
}


//! Public Function showDialog()
//!     This function shows a generic dialog.
//!     This function is considered public and may be used
//!     by developers.
function showDialog(strURL) {
        showModalDialog(strURL, 570, 520,true);
}
//! Public Function showListDialog()
//!     This function shows a generic list dialog.
//!     This function is considered public and may be used
//!     by developers.
function showListDialog(strURL) {
        showModalDialog(strURL, 730, 450,true);
}
//! Public Function showTreeDialog()
//!     This function shows a generic tree dialog.
function showTreeDialog(strURL) {
        showModalDialog(strURL, 400, 400,true);
}
//! Public Function showWizard()
//!     This function shows a wizard dialog.
//!     This function is considered public and may be used
//!     by developers.
function showWizard(strURL) {
        showModalDialog(strURL, 780, 500,true);
}
//! Public Function showDetailsPopup()
//!     This function shows a details tree in a popup window.
//!     This function is considered public and may be used
//!     by developers.
function showDetailsPopup(strURL) {
        showNonModalDialog(strURL, 875, 550,true);
}
//! Public Function showSearch()
//!     This function shows a search dialog.
//!     This function is considered public and may be used
//!     by developers.
function showSearch(strURL) {
        showNonModalDialog(strURL, 700, 500,true);
}
//! Public Function showChooser()
//!     This function shows a chooser dialog.
//!     This function is considered public and may be used
//!     by developers.
function showChooser(strURL,intWidth,intHeight) {
        if(intWidth == null || intWidth=="" ) {
                intWidth="700";
        }
        if(intHeight == null || intHeight=="" ) {
                intHeight="500";
        }
        showModalDialog(strURL, intWidth, intHeight,true);
}
//! Public Function showPrinterFriendlyPage()
//!     This function shows a printer-friendly page.
//!     This function is considered public and may be used
//!     by developers.
function showPrinterFriendlyPage(strURL) {
        var strFeatures = "scrollbars=yes,toolbar=yes,location=no";
        if (isNS4_M) {
                strFeatures += ",resizable=no";
        } else {
                strFeatures += ",resizable=yes";
        }
        var objWindow = window.open(strURL, "PF" + (new Date()).getTime(), strFeatures);
        if ( typeof(objWindow) != "undefined" && objWindow != null ){
        	registerChildWindows(objWindow, top);
        	objWindow.focus();
        }
}
//! Public Function showPopupListPage()
//!     This function shows a popup list page.
function showPopupListPage(strURL) {
    showNonModalDialog(strURL, 700, 500,true);
}
//! Public Function showModalDetailsPopup()
//!     This function is a wrapper for showModalDialog.
function showModalDetailsPopup(strURL) {
        showModalDialog(strURL, 760,600,true);
}

//! Public Function showNonModalDialog()
//!     This function shows a non-modal (regular) dialog.
//parameter returnWindow should be true to get new NonModalDialog window opened
//When this function is assigned to an href don't use returnWindow parameter
function showIEFNonModalDialog(strURL, intWidth, intHeight, bScrollbars,returnWindow) {
    var winObj = showAndGetNonModalDialog(strURL, intWidth, intHeight, bScrollbars);
    if(typeof returnWindow!='undefined' && returnWindow){
    	return winObj;
    }    
}

//Added for Bug : 347649
function getMaxFeatures(scrollbars){

	var strFeatures ="";
 	if (isIE_M) {
      strFeatures ="width="+(window.screen.availWidth-10)+",height="+(window.screen.availHeight-35)+",left="+(0)+",top="+(0);
 	} else {
      strFeatures ="width="+window.screen.width+",height="+window.screen.height+",screenX=0,screenY=0";
 	}
 	     	
 	if (scrollbars) {
       strFeatures += ",scrollbars=yes";
    }
    
    if (isNS4_M) {
       strFeatures += ",resizable=no";
    } else {
       strFeatures += ",resizable=yes";
    }
   
 	return strFeatures;

}

//! Public Function showAndGetNonModalDialog()
//!     This function shows a non-modal (regular) dialog and returns the window object.
function showAndGetNonModalDialog(strURL, intWidth, intHeight, bScrollbars) {
		var strFeatures = "";		
		
		if(intWidth == "Max"  || intHeight == "Max")
		{
			strFeatures = getMaxFeatures(bScrollbars);
		}else
		{
	        strFeatures = "width=" + intWidth + ",height=" + intHeight;
	        var intLeft = parseInt((screen.width - intWidth) / 2);
	        var intTop = parseInt((screen.height - intHeight) / 2);	        
	        if (isIE_M) {
	                strFeatures += ",left=" + intLeft + ",top=" + intTop;
	        } else{
	                strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
	        }
	        if (isNS4_M) {
	                strFeatures += ",resizable=no";
	        } else {
	                strFeatures += ",resizable=yes";
	        }
	        // Passing an additional parameter for scrollbars
	        if (bScrollbars)
	        {
	             strFeatures += ",scrollbars=yes";
	        }
		}
		strURL = addSuiteDirectory(strURL);
        var objWindow = null;
        if(isIE_M && encodeURIComponent(strURL).length >= 2048){
        	objWindow = window.open("emxBlank.jsp", "NonModalWindow" + (new Date()).getTime(), strFeatures);
	        var strActionURL = strURL.substring(0,strURL.indexOf("?"));
	        var objForm = createRequestForm(strURL);
	        objForm.target = objWindow.name;
		    objForm.action = strActionURL;
		    objForm.method = "post";
		    objForm.submit();
        }else{
        	objWindow = window.open(strURL, "NonModalWindow" + (new Date()).getTime(), strFeatures);
        }        
        registerChildWindows(objWindow, top);
        objWindow.focus();
        return objWindow;
}
//added for bug 351827
function createRequestForm(query) {
   var FORM_DATA = new Object();
   var objHiddenWindow = findFrame(top, "submitHiddenFrame");
   if(objHiddenWindow == null){
   		objHiddenWindow = document.createElement("IFRAME");   		
   		objHiddenWindow.width="0%" ;
   		objHiddenWindow.height="0%" ;   		
   		objHiddenWindow.name = "submitHiddenFrame";
   		objHiddenWindow.src = "emxBlank.jsp";
   		document.body.appendChild(objHiddenWindow);
	}
   var docfrag = objHiddenWindow.document.createDocumentFragment();
   var objForm    = objHiddenWindow.document.createElement('form');
   objForm.name   = "postHiddenForm";
   objForm.id   = "postHiddenForm";
   
   docfrag.appendChild(objForm);
   var oldform = objHiddenWindow.document.getElementById("postHiddenForm");
   if(oldform){
		objHiddenWindow.document.body.removeChild(oldform);
   }
   objHiddenWindow.document.body.appendChild(docfrag);
  	
  var separator = ',';
  query = query.substring((query.indexOf('?')) + 1);
  if (query.length < 1) { return false; }  
  var keypairs = new Object();
  var numKP = 1;
  while (query.indexOf('&') > -1)
   {
    keypairs[numKP] = query.substring(0,query.indexOf('&'));
    query = query.substring((query.indexOf('&')) + 1);
    numKP++;  
  }
  keypairs[numKP] = query;
  for (i in keypairs)
  {
    keyName = keypairs[i].substring(0,keypairs[i].indexOf('='));
    keyValue = keypairs[i].substring((keypairs[i].indexOf('=')) + 1);
    while (keyValue.indexOf('+') > -1)
    {
      keyValue = keyValue.substring(0,keyValue.indexOf('+')) + ' ' + keyValue.substring(keyValue.indexOf('+') + 1);
    }
    keyValue = unescape(keyValue);
    var hiddenEle = document.createElement("input");
    hiddenEle.setAttribute("type","hidden");
    hiddenEle.setAttribute("name", keyName);
    hiddenEle.setAttribute("value", keyValue);
    objForm.appendChild(hiddenEle);
    FORM_DATA[keyName] = keyValue;	
  }   
  return objForm;
}
//! Public Function showAndGetNonModalDialogWithName()
//!     This function shows a non-modal (regular) dialog with a name and returns the window object.
function showAndGetNonModalDialogWithName(strURL, strName, intWidth, intHeight, bScrollbars) {

	var strFeatures = "";
	
	if(intWidth == "Max" || intHeight == "Max")
	{
		strFeatures = getMaxFeatures(bScrollbars);
	}else
	{
	
	    strFeatures = "width=" + intWidth + ",height=" + intHeight;
	    var intLeft = parseInt((screen.width - intWidth) / 2);
	    var intTop = parseInt((screen.height - intHeight) / 2);	    
	    if (isIE_M) {
	            strFeatures += ",left=" + intLeft + ",top=" + intTop;
	    } else{
	            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
	    }
	    if (isNS4_M) {
	            strFeatures += ",resizable=no";
	    } else {
	            strFeatures += ",resizable=yes";
	    }
	    // Passing an additional parameter for scrollbars
	    if (bScrollbars)
	    {
	         strFeatures += ",scrollbars=yes";
	    }
	 }
	strURL = addSuiteDirectory(strURL);
    var objWindow = window.open(strURL, strName, strFeatures);
    registerChildWindows(objWindow, top);
    objWindow.focus();
    return objWindow;
}

/**
	Method: showNonModalDialogWithName(strURL, intWidth, intHeight, bScrollbars, strWindowName, bReturn)
	strURL : URL to be launched
	intWidth : width of the window
	intHeight : height of the window
	bScrollbars : whether to display scroll bars when the page content is more than the window size
	strWindowName : user defined window name. If this is not passed, default window name will be used with the combination of strProtocol+strHost+strPort
					user can pass empty string if the default windown name to be used
	bReturn : whether to return the window object created or not. By default, this method returns the window object.
*/
function showNonModalDialogWithName(strURL, intWidth, intHeight, bScrollbars, strWindowName, bReturn) {
    var sWindowName = "";
    if(typeof strWindowName != "undefined" && strWindowName != ""){
    	sWindowName = strWindowName;
    } else {
    	sWindowName = strProtocol+strHost+strPort;
    }
    sWindowName = sWindowName.replace(/\W/g, "_");
     var strFeatures = "";
     
     if(intWidth == "Max" || intHeight == "Max")
	 {
		strFeatures = getMaxFeatures(bScrollbars);
	 }else
	 {     
	    var strFeatures = "width=" + intWidth + ",height=" + intHeight;
	    var intLeft = parseInt((screen.width - intWidth) / 2);
	    var intTop = parseInt((screen.height - intHeight) / 2);
	    
	    if (isIE_M) {
	            strFeatures += ",left=" + intLeft + ",top=" + intTop;
	    } else{
	            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
	    }
	    if (isNS4_M) {
	            strFeatures += ",resizable=no";
	    } else {
	            strFeatures += ",resizable=yes";
	    }
	    // Passing an additional parameter for scrollbars
	    if (bScrollbars)
	    {
	         strFeatures += ",scrollbars=yes";
	    }
    }
    
    strURL = addSuiteDirectory(strURL);

    var objWindow = window.open(strURL, sWindowName, strFeatures);
    registerChildWindows(objWindow, top);
    objWindow.focus();
    if(bReturn != false){
    return objWindow;
    }
}

//! Public Function registerChildWindows()
//!     This function registers a child window with the parent
//!     window in order to keep track and close when a logout occurs.
function registerChildWindows(objChild, objParent) {
    try{
        var limit = 10;
        //make sure we have the childWindows array
        while(!objParent.childWindows && limit > 0){
            limit--;
            //modified for bug : 347120
            if(objParent.opener)
            	objParent = objParent.opener.top;
            else if(top.opener)
            	objParent = top.opener.top;
        }
        //make a local pointer so we can just call top.childWindows later
        //objChild represents a newly created window and is therefore equal to "top"
        if (objParent.childWindows) {
        objChild.childWindows = objParent.childWindows;
        objParent.childWindows[objParent.childWindows.length] = objChild;
        }
        else if (objParent.top.opener != null) {
            if(!objParent.opener.closed) {
                var objParentTop = objParent.opener.top;
                registerChildWindows(objChild, objParentTop);
            }
        }
    }catch(e){
	   if(-2146828218 != e.number && -2147418094 != e.number && -2147417848 != e.number)
	   {
    	if(e.description == ""){
		alert("An exception occurred in the script. Error name: " + e.name
		+ ". Error description: " + e.description
		+ ". Error number: " + e.number
		+ ". Error message: " + e.message)          	
        } else {
        throw new Error("registerChildWindows had the following error: " + e.description);
    }         
}
	
}
}
//! Public Function closeAllChildWindows()
//!     This function closes all registered child windows.
function closeAllChildWindows() {
    var isMac = navigator.platform.indexOf("Mac") > -1;
    var isIE = navigator.userAgent.indexOf("MSIE") > -1;
    //close all windows that are stored in childWindows
    if(bPageHistory == true) {
        bPageHistory = false;
        return;
    }
    if (top.childWindows)
    {
        for (var i=0; i < top.childWindows.length; i++)
        {
            if(isMac && isIE)
            {
                eval("try { \
                    if (top.childWindows[i] && !top.childWindows[i].closed) \
                        top.childWindows[i].close(); \
                } catch(e) { \
                }");
             }else{
                    try
                    {
                if (top.childWindows[i] && !top.childWindows[i].closed)
                    top.childWindows[i].close();
                } catch(ex) {
                }
                
            }
        }
    }
}
//! Public Function addSuiteDirectory()
//!     This function add the URL parameter "emxSuiteDirectory"
//!     to the URL, if it is "emxTree.jsp?.."
function addSuiteDirectory(strURL) {
        var strNewURL = strURL;
        if (strNewURL.indexOf("emxTree.jsp?") > -1){
                var strLoc = document.location.href;
                var strParam;
                var intIndex = strLoc.lastIndexOf("/");
                strLoc = strLoc.substring(0,intIndex);
                intIndex = strLoc.lastIndexOf("/");
                strLoc = strLoc.substring(intIndex+1,strLoc.length);
                if (strLoc) {
                        strParam = "emxSuiteDirectory=" + strLoc;
                    if (strNewURL.indexOf("emxSuiteDirectory=") == -1) {
                                strNewURL += (strNewURL.indexOf('?') > -1 ? '&' : '?') + strParam;
                        }
                }
    }
        return strNewURL;
}

//------------------------------------------------------------
function emxUICoreModalDialog(strURL, intWidth, intHeight, blnScrollbars) {
        this.contentWindow = null;
        this.height = intHeight;
        this.parentWindow = null;
        this.scrollbars = !!blnScrollbars;
        this.url = strURL;
        this.width = intWidth;
}

emxUICoreModalDialog.prototype.capture = function () {

};

emxUICoreModalDialog.prototype.captureMouse = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for capture. (emxUICoreModalDialog.prototype.captureMouse)");
        }
        if (objWindow.frames.length > 0) {
                for (var i=0; i < (objWindow.frames.length-1); i++) {
                        this.captureMouse(objWindow.frames[i]);
                }
        }
            this.capture(objWindow);
};

emxUICoreModalDialog.prototype.counter = 0;
emxUICoreModalDialog.prototype.checkFocus = function () {
    try{
                if (this.contentWindow && !this.contentWindow.closed) {

                    if (this.contentWindow.modalDialog && this.contentWindow.modalDialog.contentWindow
                            && !this.contentWindow.modalDialog.contentWindow.closed) {
                            this.contentWindow.modalDialog.checkFocus();
                    } else {
                            this.show();
                    }
                
        } else {
                this.release(this.parentWindow);
                this.releaseMouse(this.parentWindow);
        }
        }catch(e){
            //need to resolve timing of access to window
            this.counter++;
            if(this.counter < 10){
                    var oThis = this;
                    setTimeout(function(){oThis.checkFocus();},500);
            }else{
        //Change the condition for Bug#376863
		if(-2146828218 != e.number && -2147418094 != e.number)
		{
    	if(e.description != ""){
		alert("An exception occurred in the script. Error name: " + e.name
		+ ". Error description: " + e.description
		+ ". Error number: " + e.number
		+ ". Error message: " + e.message)          	
        }
        //Start:25-08-09:OEP:Bug#376863 
        //else {                    
            //        alert(e.description);
           // }
        //End:OEP   
        }
        }
        }
};

emxUICoreModalDialog.prototype.getFeatureString = function () {
        return "";
};

//Added for Bug : 347649
emxUICoreModalDialog.prototype.getMaxFeatures = function () 
{
		var strFeatures ="";
        if (isIE_M) {
         	 strFeatures ="width="+(window.screen.availWidth-10)+",height="+(window.screen.availHeight-35)+",left="+(0)+",top="+(0);
     	} else {
          	 strFeatures ="width="+window.screen.width+",height="+window.screen.height+",resizable=yes,screenX=0,screenY=0,modal=yes";
     	}
     	     	
     	if (this.scrollbars) {
           strFeatures += ",scrollbars=yes";
        }          	
     	return strFeatures;
};

emxUICoreModalDialog.prototype.release = function () {

};

emxUICoreModalDialog.prototype.releaseMouse = function (objWindow) {
        if (!objWindow) {
                objWindow = this.parentWindow;
        }
        if (objWindow.frames.length > 0) {
                for (var i=0; i < (objWindow.frames.length-1); i++) {
                        this.releaseMouse(objWindow.frames[i]);
                }
        }
            this.release(objWindow);
};

emxUICoreModalDialog.prototype.show = function () {
        if (!this.contentWindow || this.contentWindow.closed) {
                this.parentWindow.top.modalDialog = this;
                this.contentWindow = window.open(this.url, "ModalDialog" + (new Date()).getTime(), this.getFeatureString());
                registerChildWindows(this.contentWindow, top);
                this.capture(this.parentWindow);
                this.captureMouse(this.parentWindow);
                //Addded for Bug 368004
                if(top.registerSearchWindows) {
                	top.registerSearchWindows(this.contentWindow);
                }
        }

        if (!this.contentWindow) {
                throw new Error("The modal dialog failed to create the new window. (emxUICoreModalDialog.prototype.show)");
        }

        this.contentWindow.focus();
};


//-----------------------------------------------------------------


function emxUIMozillaModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars) {
        emxUICoreModalDialog.call(this, strURL, intWidth, intHeight, blnScrollbars);
        this.parentWindow = objParent.top;

        var objThis = this;
        this.fnTemp = function (objEvent) {
                objThis.checkFocus();
                objEvent.stopPropagation();
                objEvent.preventDefault();
        };
}

emxUIMozillaModalDialog.prototype = new emxUICoreModalDialog;

emxUIMozillaModalDialog.prototype.getFeatureString = function () {

		if( this.width == "Max" || this.height == "Max"){
			return this.getMaxFeatures();
		}
		
        var strFeatures = "width=" + this.width + ",height=" + this.height;
        strFeatures += ",resizable=yes,modal=yes";
      	try{
        	var intLeft = parseInt((screen.width - this.width) / 2);    
        	var intTop = parseInt((screen.height - this.height) / 2);    
       		strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
        }
        catch(e)
        {
        	strFeatures += ",screenX=212,screenY=84";
        }        
       
        if (this.scrollbars) {
                strFeatures += ",scrollbars=yes";
        }
        return strFeatures;
};

emxUIMozillaModalDialog.prototype.capture = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for release. (emxUIMozillaModalDialog.prototype.release)");
        }
        if (typeof objWindow.name =="string" && objWindow.name.toLowerCase().indexOf("hidden") > -1) return;
        objWindow.addEventListener("click", this.fnTemp, true);
        objWindow.addEventListener("mousedown", this.fnTemp, true);
        objWindow.addEventListener("mouseup", this.fnTemp, true);
        objWindow.addEventListener("focus", this.fnTemp, true);
};

emxUIMozillaModalDialog.prototype.release = function (objWindow) {
        if (!objWindow) {
                return;
                throw new Error("No window provided for release. (emxUIMozillaModalDialog.prototype.release)");
        }
        if (typeof objWindow.name =="string" && objWindow != objWindow.top && objWindow.name.toLowerCase().indexOf("hidden") > -1) return;
        try{
            objWindow.removeEventListener("click", this.fnTemp, true);
            objWindow.removeEventListener("mousedown", this.fnTemp, true);
            objWindow.removeEventListener("mouseup", this.fnTemp, true);
            objWindow.removeEventListener("focus", this.fnTemp, true);
        }catch (objError) {
        }
};

//-----------------------------------------------------------------

function emxUIIEModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars) {
        emxUICoreModalDialog.call(this, strURL, intWidth, intHeight, blnScrollbars);
        this.parentWindow = objParent;

        var objThis = this;
        this.fnTemp = function () {
                objThis.checkFocus();
                return false;
        };
}

emxUIIEModalDialog.prototype = new emxUICoreModalDialog;

emxUIIEModalDialog.prototype.getFeatureString = function () {		
		
		if(this.width == "Max" || this.height == "Max"){
			return this.getMaxFeatures();
		}
        var strFeatures = "width=" + this.width + ",height=" + this.height + ",resizable=yes";
        var intLeft = parseInt((screen.width - this.width) / 2);
        var intTop = parseInt((screen.height - this.height) / 2);
        strFeatures += ",left=" + intLeft + ",top=" + intTop;
        if (this.scrollbars) {
                strFeatures += ",scrollbars=yes";
        }
        return strFeatures;
};

emxUIIEModalDialog.prototype.capture = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for release. (emxUIIEModalDialog.prototype.release)");
        }
        var objCapture = objWindow.document.body;
        if (!objCapture) return;
        objCapture.setCapture();
        objCapture.onclick = this.fnTemp;
        objCapture.ondblclick = this.fnTemp;
        objCapture.onmouseover = this.fnTemp;
        objCapture.onmouseout = this.fnTemp;
        objCapture.onmousemove = this.fnTemp;
        objCapture.onmousedown = this.fnTemp;
        objCapture.onmouseup = this.fnTemp;
        objCapture.onfocus = this.fnTemp;
        objCapture.oncontextmenu = this.fnTemp;
};

emxUIIEModalDialog.prototype.release = function (objWindow) {
        if (!objWindow) {
                return;
                throw new Error("No window provided for release. (emxUIIEModalDialog.prototype.release)");
        }
        var objCapture = objWindow.document.body;
        if (!objCapture) return;
        objCapture.releaseCapture();
        objCapture.onclick = null;
        objCapture.ondblclick = null;
        objCapture.onmouseover = null;
        objCapture.onmouseout = null;
        objCapture.onmousemove = null;
        objCapture.onmousedown = null;
        objCapture.onmouseup = null;
        objCapture.onfocus = null;
        objCapture.oncontextmenu = null;
};

emxUIIEModalDialog.prototype.show = function () {
        if (!this.contentWindow || this.contentWindow.closed) {
                this.parentWindow.top.modalDialog = this;
                this.contentWindow = window.open(this.url, "ModalDialog" + (new Date()).getTime(), this.getFeatureString());
                registerChildWindows(this.contentWindow, top);
        }
        if (!this.contentWindow) {
                throw new Error("The modal dialog failed to create the new window. (emxUICoreModalDialog.prototype.show)");
        }
        this.capture(this.parentWindow);
        this.captureMouse(this.parentWindow);
        //Added for Bug 368004
        if(top.registerSearchWindows) {
           top.registerSearchWindows(this.contentWindow);
        }
        this.contentWindow.focus();
};

//! Public Function closePopupWindow(win)
//!     This function closes windows.
function closePopupWindow(win) {
    if (win.opener) {
        win.opener = null;
    }
    win.open('emxCloseWindow.jsp', '_self');
}
