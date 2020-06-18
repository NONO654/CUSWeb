/*!================================================================
 *  JavaScript Mouse Events
 *  emxUIMouseEvents.js
 *  Version 1.0
 *  Last Updated: 24-Apr-04, Saurabh Gupta 
 *
 *  This file contains the functions required for capturing & releasing the mouse events.
 *
 *  Copyright (c) 1992-2018 Enovia Dassault Systemes Technologies Limited. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of Enovia MatrixOne Technologies Limited. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *=================================================================
 */
 
 

//! Function captureMouseEvents()
//!     This function captures mouse actions to the window.

function captureMouseEvents() {
      
      var isIE = navigator.userAgent.toLowerCase().indexOf("msie") > -1 && navigator.userAgent.toLowerCase().indexOf("opera") == -1;
      
      if (isIE)
      {
      		parent.document.body.setCapture();
      }      
      else
      {
      		parent.window.captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP);
	        parent.window.onclick = false;
	        parent.window.onmousedown = false;
	        parent.window.onmouseup = false;      
      }
} 


//! Function releaseMouseEvents()
//!     This function releases mouse actions from the window.

function releaseMouseEvents() {
      var isIE = navigator.userAgent.toLowerCase().indexOf("msie") > -1 && navigator.userAgent.toLowerCase().indexOf("opera") == -1;
      
      if (isIE)
      {
      		parent.document.body.releaseCapture();  
      }      
      else
      {
      		parent.window.releaseEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP);
	        parent.window.onclick = null;
	        parent.window.onmousedown = null;
	        parent.window.onmouseup = null;   
      }  
} 
