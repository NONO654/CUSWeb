//-----------------------------------------------------------------
// Javascript Modal Dialog Version 1.0
// by Nicholas C. Zakas
//
// Adapted for MatrixOne, Inc. from code independently developed by
// Nicholas C. Zakas.
//-----------------------------------------------------------------
// Revision history:
//	June 4, 2001 - Released Version 1.0
//-----------------------------------------------------------------

//----------------------------------------------------------------
// 1: GLOBAL CONSTANTS
//----------------------------------------------------------------

//cheap browser detect
var isIE = navigator.userAgent.toLowerCase().indexOf('msie') > -1;

//popup window pointer
var winDialog = null;


//----------------------------------------------------------------
// 2: MAIN FUNCTION
//----------------------------------------------------------------

//-----------------------------------------------------------------
// Function showModalDialog()
// This function opens a modal dialog window and centers it.
//
// Parameters:
//	strURL (String) - the URL of the page to display.
//	iWidth (int) - the width of the window.
//	iHeight (int) - the height of the window.
//	bScrollbars (boolean) - do you want scrollbars?
// Returns:
//	False to stop Netscape from doing anything else.
//-----------------------------------------------------------------

function showModalDialog(strURL, iWidth, iHeight, bScrollbars) {

if ( iWidth < 100 ) { 
  iWidth = parseInt(iWidth/10 * 100);
  if ( iWidth > 600 ) iWidth = 600; 
} 


if ( iHeight < 100 ) {
  iHeight = parseInt(iHeight/10 * 100);
 // if ( iWidth == 600 && iHeight > 300) iHeight = 250; 
  if (iWidth == 600 && iHeight > 699 ) iHeight = 400; 
} 

 
  
	if (!winDialog || winDialog.closed) {
	
  	       
		
		//build up features string
		var strFeatures = "width=" + iWidth + ",height=" + iHeight + ",dependent=yes,resizable=yes,";
		
		//calculate center of the screen
		var winleft = parseInt((screen.width - iWidth) / 2);
		var wintop = parseInt((screen.height - iHeight) / 2);
			
		if (isIE)
			strFeatures += ",left=" + winleft + ",top=" + wintop;
		else
			strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;
		
		//are there scrollbars?
		if (bScrollbars) strFeatures += ",scrollbars=yes";
		//open the window
		winDialog = window.open(strURL, "EditWindow" + (new Date()).getTime(), strFeatures);
		// winDialog = window.open(strURL, "EditWindow", strFeatures);
		
		//capture the mouse
		captureMouse();
		
		//set focus to the dialog
		winDialog.focus();
 
                //return the window
		return winDialog;
	} else {
		if (winDialog) winDialog.focus();
	}

}

//----------------------------------------------------------------
// 3: HELPER FUNCTIONS
//----------------------------------------------------------------

//-----------------------------------------------------------------
// Function captureMouse()
// This function captures mouse actions to the window.
//
// Parameters:
//	None.
// Returns:
//	Nothing.
//-----------------------------------------------------------------
function captureMouse() {
	if (isIE) {
		//IE requires an object (not window) to capture events, so look for one
		
		for (i=0; i < getTopWindow().frames.length; i++) {
			var objCapture = getTopWindow().frames[i].document.body;
			captureObjectIE(objCapture);
			for (j=0; j < getTopWindow().frames[i].frames.length; j++) {
				var objCapture = getTopWindow().frames[i].frames[j].document.body;
				captureObjectIE(objCapture);
			}			
		}
	} else {
		//capture the events to the window
		getTopWindow().captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS)
	    		
		//assign the event handlers
		getTopWindow().onclick = checkFocus;
		getTopWindow().onmousedown = checkFocus;
		getTopWindow().onmouseup = checkFocus;
	 	getTopWindow().onfocus = checkFocus;	
	}
}

//-----------------------------------------------------------------
// Function captureObjectIE()
// This function captures mouse actions to the given object for IE.
//
// Parameters:
//	None.
// Returns:
//	Nothing.
//-----------------------------------------------------------------
function captureObjectIE(objCapture) {
	//capture the events to the document body
	objCapture.setCapture();

	//assign event handlers
	objCapture.onclick = checkFocus;
	objCapture.ondblclick = checkFocus;
	objCapture.onmouseover = checkFocus;
	objCapture.onmouseout = checkFocus;
	objCapture.onmousemove = checkFocus;
	objCapture.onmousedown = checkFocus;
	objCapture.onmouseup = checkFocus;
}

//-----------------------------------------------------------------
// Function releaseMouse()
// This function releases mouse actions from the window.
//
// Parameters:
//	None.
// Returns:
//	Nothing.
//-----------------------------------------------------------------
function releaseMouse() {
	if (isIE) {
		for (i=0; i < getTopWindow().frames.length; i++) {
			var objCapture = getTopWindow().frames[i].document.body;
			releaseObjectIE(objCapture);
			for (j=0; j < getTopWindow().frames[i].frames.length; j++) {
				var objCapture = getTopWindow().frames[i].frames[j].document.body;
				releaseObjectIE(objCapture);
			}	
		}
	} else {
		//capture the events to the window
		getTopWindow().releaseEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS)
	    		
		//assign the event handlers
		getTopWindow().onclick = null;
		getTopWindow().onmousedown = null;
		getTopWindow().onmouseup = null;
	 	getTopWindow().onfocus = null;		
	}
}

//-----------------------------------------------------------------
// Function releaseObjectIE()
// This function releases mouse actions to the given object for IE.
//
// Parameters:
//	None.
// Returns:
//	Nothing.
//-----------------------------------------------------------------
function releaseObjectIE(objCapture) {
	//capture the events to the document body
	objCapture.releaseCapture();

	//assign event handlers
	objCapture.onclick = null;
	objCapture.ondblclick = null;
	objCapture.onmouseover = null;
	objCapture.onmouseout = null;
	objCapture.onmousemove = null;
	objCapture.onmousedown = null;
	objCapture.onmouseup = null;
}



//----------------------------------------------------------------
// 4: EVENT HANDLING
//----------------------------------------------------------------

//-----------------------------------------------------------------
// Function checkFocus()
// This function checks to see if a window is open, then sets the focus
// to it.  If the window is closed, the mouse capture is released.
//
// Parameters:
//	None.
// Returns:
//	False to stop Netscape from doing anything else.
//-----------------------------------------------------------------
function checkFocus() {
	//if the dialog is open, set the focus to it
	if (winDialog)
		if (winDialog.closed)
			releaseMouse();
		else
			winDialog.focus();

	//stop Netscape from doing anything else
	return false;
}
