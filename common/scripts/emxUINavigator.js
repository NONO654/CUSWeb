/*=================================================================
 *  JavaScript Navigator Object
 *  emxUINavigator.js
 *  Version 1.0
 *  Requires: emxUIConstants.js, emxUICore.js
 *
 *  This file contains class definition for the main navigator window.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $Id: emxUINavigator.js.rca 1.8 Wed Oct 22 15:48:16 2008 przemek Experimental przemek $
 *=================================================================
 */

//=================================================================
// Constants
//=================================================================


var emxUINavigator = new emxUIObject;

emxUINavigator.IMG_BTN_SHRINK = emxUIConstants.DIR_IMAGES + "buttons/buttonShrinkTopFrame.gif";
emxUINavigator.IMG_BTN_GROW = emxUIConstants.DIR_IMAGES + "buttons/buttonGrowTopFrame.gif";

emxUINavigator.contentFrame = null;
emxUINavigator.shrunkDisplay = null;
emxUINavigator.grownDisplay = null;
emxUINavigator.toolbar = null;
emxUINavigator.grown = true;
emxUINavigator.button = null;
emxUINavigator.image = "";
emxUINavigator.text = "";
emxUINavigator.username = "";
emxUINavigator.contentURL = "about:blank";
emxUINavigator.smallLogo = "";

//constants
emxUINavigator.LAYOUT_GROWN = true;
emxUINavigator.LAYOUT_SHRUNK = false;

//add style sheet (NCZ, 22-Jul-03)
emxUINavigator.stylesheet = emxUICore.getStyleSheet("emxUINavigator");
//emxUICore.addStyleSheet("emxUINavigator");

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.createDOM()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method creates the DOM for the page.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.createDOM = function _emxUINavigator_createDOM() {

        //get the content frame (NCZ, 18-Jul-03)
        var contentFrame = document.getElementById("content");
        contentFrame.frameBorder = 0;
        if(this.contentURL.length >= 2048){
            var objForm = createRequestForm(this.contentURL);
            var strActionURL = this.contentURL.substring(0,this.contentURL.indexOf("?"));
            objForm.target = contentFrame.name;
            objForm.action = strActionURL;
            objForm.method = "post";
            objForm.submit();
           }else{                    
            contentFrame.src = this.contentURL;
            }

        //create the grown display (NCZ, 18-Jul-03)
        //this.grownDisplay = document.createElement("div");
        //this.grownDisplay.id = "divGrown";
        //this.grownDisplay.innerHTML = "<div id=\"divGrownLogo\"><img src=\"" + this.image + "\" border=\"0\" /></div>";
        this.grownDisplay = document.getElementById("divGrown");
        
        //create the shrunk display (NCZ, 18-Jul-03)
        //this.shrunkDisplay = document.createElement("div");
        //this.shrunkDisplay.id = "divShrunk";
        //this.shrunkDisplay.innerHTML = "<div id=\"divShrunkText\">" + this.text + "</div>";
        //this.shrunkDisplay.innerHTML = "<div id=\"divShrunkLogo\"><img src=\"" + this.smallLogo + "\" border=\"0\" /></div>";
        this.shrunkDisplay = document.getElementById("divShrunk");
        
        //create the image button (NCZ, 18-Jul-03)
        //this.button = document.createElement("img");
        //this.button.id = "imgButton";
        //this.button.onclick = new Function("emxUINavigator.toggleHeader()");
        //document.body.appendChild(this.button);
        
        //create the toolbar (NCZ, 18-Jul-03)
        //this.toolbarLayer = document.createElement("div");
        //this.toolbarLayer.id = "divToolbar";
        //this.toolbarLayer.className = "toolbar-container";
        //document.body.insertBefore(this.toolbarLayer, this.contentFrame);
        this.toolbarLayer = document.getElementById("divToolbar");
        
        //create container for buttons (NCZ, 21-Jul-03)
        //this.buttonsLayer = document.createElement("div");
        //this.buttonsLayer.id = "divToolbarButtons";
        //this.buttonsLayer.className = "toolbar-container";
        //document.body.appendChild(this.buttonsLayer);
        
}; //End: emxUINavigator.createDOM = function _emxUINavigator_createDOM()

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.createDragItem()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method creates the DOM for the page.
//
//  PARAMETERS
//      objElement (HTMLElement) - the element to create a duplicate of.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.createDragItem = function _emxUINavigator_createDragItem(objElement, intX, intY) {

        var objDiv = document.createElement("div");
        objDiv.style.cssText = "position: absolute; width: 100px; height: 25px; background-color: red; z-index: 10;";
        //objDiv.style.left 

        
}; //End: emxUINavigator.createDragItem = function _emxUINavigator_createDragItem()


//-----------------------------------------------------------------
//! Protected Method emxUINavigator.grow()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method grows the top banner of the app.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.grow = function _emxUINavigator_grow() {

        //hide the shrunk display (NCZ, 18-Jul-03)
        //if (this.shrunkDisplay.parentNode == document.body) {
        //        document.body.removeChild(this.shrunkDisplay);
        //} //End: if (this.shrunkDisplay.parentNode != null)
        
        //show the grown display (NCZ, 18-Jul-03)
        //document.body.insertBefore(this.grownDisplay, this.toolbarLayer);
        
        //change image for the button (NCZ, 18-Jul-03)
        //this.button.src = emxUINavigator.IMG_BTN_SHRINK;
        
        //set the height of the content frame (NCZ, 18-Jul-03)
        //this.contentFrame.style.height = (emxUICore.getWindowHeight() - this.grownDisplay.offsetHeight - this.toolbarLayer.offsetHeight) + "px";

        //move the menubar (NCZ, 21-Jul-03)
        //this.menu.moveTo(0, 63);
        //this.toolbar.container.style.top = "63px";

        //set the grown flag (NCZ, 18-Jul-03)
        this.grown = true;
}; //End: emxUINavigator.grow = function _emxUINavigator_grow()

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.init()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method initializes the object.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.init = function _emxUINavigator_init() {

        //create the DOM (NCZ, 18-Jul-03)
        this.createDOM();
        
        //initialize the toolbar (NCZ, 21-Jul-03)
		$("#divToolbar").html("");
        this.toolbar.init("divToolbar");
        
        //initialize the menu (NCZ, 21-Jul-03)
        //this.menu.init();

        //initialize the display (NCZ, 18-Jul-03)
        if (this.grown) {
                this.grow();
        } else {
                this.shrink();
        } //End: contentFrame
        
}; //End: emxUINavigator.init = function _emxUINavigator_init()

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.resize()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method toggles shrinking/growing the header.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.resize = function _emxUINavigator_resize() {
	    //TO add mask to globaltoolbar if windowshade opened and browser is resized
		if(typeof addMaskToGlobalToolbar == 'function'){
		addMaskToGlobalToolbar();
		}
        if (this.grown) {
                this.grow();
        } else {
                this.shrink();
        } //End: if (this.grown)
        
}; //End: emxUINavigator.resize = function _emxUINavigator_resize()

emxUINavigator.resizeTimeout = null;

emxUINavigator.redrawToolbar = function _emxUINavigator_redrawToolbar() {
		
	clearTimeout(this.resizeTimeout);
	
	this.resizeTimeout = setTimeout(function _delayed_redraw() {
		 emxUINavigator.toolbar.drawToolbar("divToolbar");
		 
	},500); 
    
};

emxUINavigator.resizeToolbar = function _emxUINavigator_resizeToolbar() {
	clearTimeout(this.resizeGTTimeout);
	
	this.resizeGTTimeout = setTimeout(function _delayed_redraw() {
		
		adjustLeftSlideIn();		
		
		var winwidth = (jQuery('#pageHeadDiv')).width();

		/*var winwidth;
		var gtb = document.getElementById("globalToolbar");
		if(gtb){
			winwidth = gtb.
		}*/
		if(!isMobile){
		if(winwidth < 1040){
			jQuery('#AEFWelcomeToolbar').css("display","none");
			if(winwidth < 750){
				jQuery('#AEFAppLabelHolder').css("display","none");
				if(winwidth < 640){
					jQuery('#AEFBrandLogoHolder').css("display","none");					
				}else{
					jQuery('#AEFBrandLogoHolder').css("display","inline-block");
				}
			} else {
				var applh = jQuery('#AEFAppLabelHolder'); 
				applh.css("display","inline-block");
					var adjustedName = adjustAppName(applh.data("appName"));
					var brandName = applh.data("brandName");
					setAdjustedAppLabel(brandName, adjustedName);				}
		} else {
			jQuery('#AEFWelcomeToolbar').css("display","inline-block");
			jQuery('#AEFBrandLogoHolder').css("display","inline-block");
			var applh = jQuery('#AEFAppLabelHolder'); 
			applh.css("display","inline-block");
					var tempname = applh.data("appName");
						var adjustedName = adjustAppName(tempname);
				var brandName = applh.data("brandName");
				setAdjustedAppLabel(brandName, adjustedName);
				}
		}
		
		/*var srchwidth = jQuery('#GTBsearchDiv').innerWidth();
		var srchcxtwidth = jQuery('.search-context').innerWidth();
		var srchactionswidth = jQuery('.search-actions').innerWidth();
		var searchinput = jQuery('.search-input')[0]; 
		if(searchinput){
			//searchinput.style.left = srchcxtwidth + "px";
		}
		var tbwidth = srchwidth - srchcxtwidth - srchactionswidth;
		var searchinputbox = jQuery('#GlobalNewTEXT')[0];
		if(searchinputbox){
			//searchinputbox.style.width = tbwidth + "px";
		}*/
	},500); 
};
//-----------------------------------------------------------------
//! Protected Method emxUINavigator.setContent()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 21-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method sets the URL of the content frame.
//
//  PARAMETERS
//      strURL (String) - the url to use.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.setContent = function _emxUINavigator_setContent(strURL) {
        
        //set the URL (NCZ, 21-Jul-03)
        this.contentURL = strURL;
                
}; //End: emxUINavigator.setContent = function _emxUINavigator_setContent(strURL)

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.setLayout()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method sets the layout of the page to either grown or shrunk.
//
//  PARAMETERS
//      blnMode (boolean) - either emxUINavigator.LAYOUT_GROWN or emxUINavigator.LAYOUT_SHRUNK.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.setLayout = function _emxUINavigator_setLayout(blnMode) {
        this.grown = blnMode;
}; //End: emxUINavigator.setLayout = function _emxUINavigator_setLayout(blnMode)

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.setLogo()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method sets the image of the navigator page.
//
//  PARAMETERS
//      strImage (String) - the image to use.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.setLogo = function _emxUINavigator_setLogo(strImage) {
        this.image = strImage;
}; //End: emxUINavigator.setLogo = function _emxUINavigator_setLogo(strImage)

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.setSmallLogo()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 5-Aug-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method sets the small logo of the navigator page.
//
//  PARAMETERS
//      strImage (String) - the image to use.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.setSmallLogo = function _emxUINavigator_setSmallLogo(strImage) {
        this.smallLogo = strImage;
}; //End: emxUINavigator.setSmallLogo = function _emxUINavigator_setSmallLogo(strImage)

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.setText()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method sets the text to display when the header is shrunk.
//
//  PARAMETERS
//      setText (String) - the text to use.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.setText = function _emxUINavigator_setText(strText) {
        this.text = strText;
}; //End: emxUINavigator.setText = function _emxUINavigator_setText(strText)

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.shrink()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method shrinks the top banner of the app.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.shrink = function _emxUINavigator_shrink() {
        
        //set the height of the content frame (NCZ, 18-Jul-03)
        //this.contentFrame.style.height = (emxUICore.getWindowHeight() - this.toolbarLayer.parentNode.offsetHeight) + "px";

        //set the grown flag (NCZ, 18-Jul-03)
        this.grown = false;
}; //End: emxUINavigator.shrink = function _emxUINavigator_shrink()

//-----------------------------------------------------------------
//! Protected Method emxUINavigator.toggleHeader()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 18-Jul-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method toggles shrinking/growing the header.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUINavigator.toggleHeader = function _emxUINavigator_toggleHeader() {

        if (this.grown) {
                this.shrink();
        } else {
                this.grow();
        } //End: if (this.grown)
        
}; //End: emxUINavigator.toggleHeader = function _emxUINavigator_toggleHeader()


//Initialization
emxUINavigator.toolbar = new emxUIToolbar(emxUIToolbar.MODE_NORMAL,"Global");
emxUINavigator.toolbar.maxWidth = -1;

//for showing the coachmark
emxUINavigator.loadCoachmark = function _emxUINavigator_loadCoachmark(force) {
	if(jQuery('div.ds-coachmark').length == 0){
		UWA.Data.proxies.passport = crossproxy;
	    require(['DS/Coachmark/Coachmark'], function(i3DXCoachmark){
	        i3DXCoachmark.init({
	            myAppsBaseURL: emxUINavigator.myAppsURL, //where the �Do not show again� may be retrieved and stored. Right now it's not feasisble. localstorage is used as alternative
	            parentEltSelector: 'body',
	            forceDisplay: force,
	            lang: clntlang
	        });
	    });
	}
};
/*=================================================================
 *  emxUIShortcutsButton Class Definition
 *=================================================================
 */

//-----------------------------------------------------------------
//! Class emxUIShortcutsButton
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 30-Jun-03
//
//  EDITOR(S)
//
//  INHERITS FROM
//      emxUIToolbarButton
//
//  DESCRIPTION
// !    This object represents a separator on a toolbar.
//
//  PARAMETERS
//      intFormat (int) - the format for the button. One of
//              emxUIToolbar.ICON_ONLY, emxUIToolbar.TEXT_ONLY,
//              or emxUIToolbar.ICON_AND_TEXT.
//      strIcon (String) - the icon for the button.
//      strText (String) - the text for the button.
//      strURL (String) - the URL for the button.
//      strTarget (String) - the name of the target for the URL (optional).
//
//  SUPPORTED EVENTS
//      click, mouseover, mouseout
//-----------------------------------------------------------------
function emxUIShortcutsButton (intFormat, strIcon, strText, strURL, strTarget) {
        
        //---------------------------------------------------------------------------------
        // Inherit Properties from emxUIToolbarButton
        //---------------------------------------------------------------------------------
        this.superclass = emxUIToolbarButton;
        this.superclass(intFormat, strIcon, strText, strURL, strTarget);
        delete this.superclass;
        //---------------------------------------------------------------------------------
            
        //---------------------------------------------------------------------------------
        // Private Properties
        //---------------------------------------------------------------------------------
        this.emxClassName = "emxUIShortcutsButton";       //internal class name (NCZ, 30-Jun-03)
        //---------------------------------------------------------------------------------
    
} //End: function emxUIShortcutsButton ()

//inherit methods from emxUIToolbarButton
emxUIShortcutsButton.prototype = new emxUIToolbarButton;

//-----------------------------------------------------------------
//! Private Method emxUIShortcutsButton.createDOM()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 30-Jun-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This methods creates the DOM for the item.
//
//  PARAMETERS
//!     (none)
//
//  RETURNS
//!     The DOM element representing this menu item.
//-----------------------------------------------------------------
emxUIShortcutsButton.prototype.emxUIToolbarButtonCreateDOM = emxUIShortcutsButton.prototype.createDOM;
emxUIShortcutsButton.prototype.createDOM = function _emxUIShortcutsButton_createDOM() {

        //call original method (NCZ, 4-Sep-03)
        this.emxUIToolbarButtonCreateDOM();
        
        var objThis = this;

        //set event handlers so this is a drop target (NCZ, 4-Sep-03)
        this.element.ondragover = function () {
        
                //get the text in the datatransfer object (NCZ, 4-Sep-03)
                var strText = window.event.dataTransfer.getData("text");
                
                //make sure it begins with "EMX:" (NCZ, 4-Sep-03)
                if (strText.indexOf("EMX:::") == 0) {

                        window.event.returnValue = false;
                        objThis.fireEvent("dragover", window.event);
                } //End: if (strText.indexOf("EMX:") == 0)        
        
        };  
        
        this.element.ondragenter = function () {
                window.event.returnValue = false;        
        };
        
        this.element.ondragleave = function () {

                //get the text in the datatransfer object (NCZ, 4-Sep-03)
                var strText = window.event.dataTransfer.getData("text");
                
                //make sure it begins with "EMX:" (NCZ, 4-Sep-03)
                if (strText.indexOf("EMX:::") == 0) {
                        objThis.fireEvent("dragout", window.event);
                } //End: if (strText.indexOf("EMX:") == 0)        
        
        };  
        
        this.element.ondrop =  function () {
                objThis.fireEvent("drop", window.event);   
        };  

}; //End: emxUIShortcutsButton.prototype.createDOM = function _emxUIShortcutsButton_createDOM()

//-----------------------------------------------------------------
//! Private Method emxUIShortcutsButton.handleEvent()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 30-Jun-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method handles the events for this object.
//
//  PARAMETERS
//      strType (String) - the type of event.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUIShortcutsButton.prototype.emxUIToolbarButtonHandleEvent = emxUIShortcutsButton.prototype.handleEvent;
emxUIShortcutsButton.prototype.handleEvent = function _emxUIShortcutsButton_handleEvent(strType, objEvent) {
        
        
        switch(strType) {
        
                case "dragover":
                        emxUICore.addClass(this.element, "button-drag-hover");                
                        break;
                        
                case "dragout":
                        emxUICore.removeClass(this.element, "button-drag-hover");                
                        break;
                        
                case "drop":
                
                        //remove the class (NCZ, 9-Sep-03)
                        emxUICore.removeClass(this.element, "button-drag-hover");
                        
                        //get the data (NCZ, 9-Sep-03)
                        var strData = objEvent.dataTransfer.getData("text");
                        
                        //split into an array (NCZ, 9-Sep-03)
                        var arrData = strData.split(":::");
                        
                        //add shortcut (NCZ, 9-Sep-03)                        
                        this.addShortcut(arrData[1], arrData[2], arrData[3], arrData[4]);
                        break;                        
        
                default:
                        this.emxUIToolbarButtonHandleEvent(strType, objEvent);
        } //End: switch(strType)

}; //End: emxUIShortcutsButton.prototype.handleEvent = function _emxUIShortcutsButton_handleEvent(strType)

//-----------------------------------------------------------------
//! Private Method emxUIShortcutsButton.init()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 7-Aug-03
//
//  EDITOR(S)
//
//  OVERRIDES
//      emxUICoreToolbarItem.init()
//
//  DESCRIPTION
//!     This method initializes the item.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUIShortcutsButton.prototype.emxUIToolbarButtonInit = emxUIShortcutsButton.prototype.init;
emxUIShortcutsButton.prototype.init = function _emxUIShortcutsButton_init() {
        
        //call the default (NCZ, 9-Sep-03)
        this.emxUIToolbarButtonInit();
        
        //register additional event handlers (NCZ, 9-Sep-03)
        var objThis = this;
        this.registerEventHandler("drop", function (objEvent) { objThis.handleEvent("drop", objEvent) });
        this.registerEventHandler("dragover", function (objEvent) { objThis.handleEvent("dragover", objEvent) });
        this.registerEventHandler("dragout", function (objEvent) { objThis.handleEvent("dragout", objEvent) });

}; //End: emxUIShortcutsButton.prototype.init = function _emxUIShortcutsButton_init()

//-----------------------------------------------------------------
//! Private Method emxUIShortcutsButton.addShortcut()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.5+
//      Mozilla 1.0.1+ (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 7-Aug-03
//
//  EDITOR(S)
//
//  DESCRIPTION
//!     This method adds a new shortcut to the menu.
//
//  PARAMETERS
//      strIcon (String) - the icon to display in the menu.
//      strText (String) - the text to display in the menu.
//      strURL (String) - the URL for the menu.
//      strTarget (String) - the target for the URL.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUIShortcutsButton.prototype.addShortcut = function _emxUIShortcutsButton_addShortcut(strIcon, strText, strURL, strTarget) {

        //create menu item (NCZ, 8-Sep-03)
        var objItem = new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, strIcon, strText, strURL, strTarget);
        
        //add it to this button's menu (NCZ, 8-Sep-03)
        this.menu.addItem(objItem);
        
        //rebuild the menu (NCZ, 8-Sep-03)
        this.menu.createDOM();

}; //End: emxUIShortcutsButton.prototype.addShortcut = function _emxUIShortcutsButton_addShortcut(strIcon, strText, strURL)

//add global event handlers (NCZ, 4-Sep-03)
emxUICore.addEventHandler(window, "load", function () { emxUINavigator.init(); emxUINavigator.resizeToolbar();});
emxUICore.addEventHandler(window, "resize", function () { emxUINavigator.resizeToolbar(); emxUINavigator.resize(); $('#ieMenuCoverForObjectTag').remove();$('.north-bgnd').removeClass('active');});
//$('#leftPanelMenu,.menu-panel').css('display','none');
emxUIToolbar.IMG_MENU_ARROW = emxUIConstants.DIR_IMAGES + "utilNavMenuArrow.gif";
emxUIToolbar.IMG_CHEVRON = emxUIConstants.DIR_IMAGES + "utilNavigatorToolbarChevron.gif";


var toppos = 0;
var leftpos = 212;
var isPanelOpen = true;
var StructureNavigator = {
		currButton: emxUIConstants.STR_NAV_CLOSE,
        cols :null,
	
	getCurrButton: function _getCurrButton(){
		return this.currButton;
	},

	setCurrButton: function _setCurrButton(currMode){
		this.currButton = currMode;
	},
	
	getCols:function _getCols(){
		return this.cols;
	},
	
	setCols:function _setCols(cols){
		this.cols = cols;
	}
}

function expandMenuData(){
 	
	 if(emxUIConstants.STORAGE_SUPPORTED){
			var json =  jQuery.parseJSON(localStorage.getItem('menuCache'));
			var expandedMenus = json.expanded;
			
			for(var i=0;i<expandedMenus.length;i++)
			{
				jQuery(expandedMenus[i]).trigger('expand');
			}
		}
}
	function initializeSlideIns(){
		if(getTopWindow().getWindowOpener()){
			var isExtendedHeaderPresent =jQuery(getTopWindow().document).find("#ExtpageHeadDiv").css("display") == "block";
			if(isTreePage(emxUINavigator.contentURL) && isExtendedHeaderPresent){
				var divph = document.getElementById("ExtpageHeadDiv");
				toppos = jQuery('#ExtpageHeadDiv').height();
				jQuery("div#panelToggle").show();
				jQuery("div#pageContentDiv").css('left',leftpos);
				jQuery("div#panelToggle").css('top',toppos);
			}else{
				var headheight = "0px";
				$("div#panelSlideIn").css('top',headheight);
				$("div#pageContentDiv").css('top',headheight);
			}
		}else{
			jQuery('li[id!=""]').mouseover(function(){jQuery(this).removeClass('button-hover');});
			jQuery("div#GlobalMenuSlideIn").css('left','-350px');
			if(getTopWindow().isfromIFWE){
				toppos = 0;
			} else {
			if(emxUIConstants.TOPFRAME_ENABLED){
					toppos = jQuery('#topbar').height() + jQuery('#navBar').height();
				}else{
					var divph = document.getElementById("pageHeadDiv");
					divph.style.display='block';
					toppos = jQuery('#pageHeadDiv').height();
				}
		    }
			jQuery("div#pageContentDiv").css('left',leftpos);
			jQuery("div#pageContentDiv").css('top',toppos);
			jQuery("div#leftPanelMenu").css('top',toppos);
			jQuery("div#mydeskpanel").css('top',toppos);
			jQuery("div#panelToggle").css('top',toppos);
			jQuery("div#GlobalMenuSlideIn").css('top',toppos);
			
			jQuery("div#rightSlideIn").css('top',toppos);
			jQuery("div#leftSlideIn").css('top',toppos);
			jQuery("div#GlobalMenuSlideIn").css('top',toppos);
		}
		jQuery("div#panelToggle" ).click(function() {
			if(!getTopWindow().getWindowOpener()){
				if(jQuery("div#mydeskpanel").is(':visible')){
					emxUICore.addToClientCache(this);
				} 
			}else{
			 emxUICore.addToClientCache(this); 
			}
			togglePanel();	
		});
		jQuery("#panelToggle").bind("expand",function(e){
			togglePanel();
		});
	}
	function togglePanel(){
		if(isPanelOpen){
			isPanelOpen = false;
			closePanel();
		} else {
			isPanelOpen = true;
			openPanel();
		}
	}
	function openPanel(){
		jQuery("div#leftPanelMenu").css('left', '16px');
		jQuery("div#leftPanelMenu").css("pointer-events","auto");		
		if(!getTopWindow().getWindowOpener()){
			jQuery("div#mydeskpanel").css('left', '16px');		
		}
		jQuery("div#pageContentDiv").css('left', '212px');
		
		if(jQuery("div#leftPanelMenu").is(':visible')){
			if(isMobile){
		      jQuery("div#pageContentDiv").css('left', 33 + jQuery("div#leftPanelMenu").width()+ jQuery("div#mx_divGrabber").width() +'px');		
			  jQuery("div#mx_divGrabber").css('left',16 + jQuery("div#leftPanelMenu").width()+ jQuery("div#mx_divGrabber").width() +'px');
		   }else{
			jQuery("div#pageContentDiv").css('left', 16 + jQuery("div#leftPanelMenu").width()+ jQuery("div#mx_divGrabber").width() +'px');		
			jQuery("div#mx_divGrabber").css('left',jQuery("div#pageContentDiv").css("left"));
		  }
		}
		
		jQuery("div#divExtendedHeaderContent").css('left','0px');
		jQuery("div#panelToggle").addClass("open").attr('title',emxUIConstants.STR_HIDE);
		jQuery("div#panelToggle").removeClass("closed");
	}

	function closePanel(){
		jQuery("div#leftPanelMenu").css('left', "-"+jQuery("div#leftPanelMenu").width() +'px');
		jQuery("div#leftPanelMenu").css("pointer-events","none");
		jQuery("div#mx_divGrabber").css('left', "-"+jQuery("div#leftPanelMenu").width() +'px');
		if(!getTopWindow().getWindowOpener()){
			jQuery("div#mydeskpanel").css('left', '-212px');
		}
		jQuery("div#pageContentDiv").css('left', '16px');
		jQuery("div#divExtendedHeaderContent").css('left','0px');
		jQuery('#content').contents().find('#middle').css('float','right');
		jQuery("div#panelToggle").removeClass("open");
		jQuery("div#panelToggle").addClass("closed").attr('title',emxUIConstants.STR_SHOW);
	}
	function showStructureTree(){
		if (jQuery("div#treeBar")) {
			jQuery("div#treeBar").show();
		}
		jQuery("button#catButton").removeClass("toggle-active");
		jQuery("button#catButton").addClass("toggle-inactive");
		jQuery("button#strucButton").removeClass("toggle-inactive");
		jQuery("button#strucButton").addClass("toggle-active");
		jQuery("div#catMenu").hide();
		jQuery("div#leftPanelTree").show();
	}
	function showCategoryTree() {
		if (jQuery("div#treeBar")) {
			jQuery("div#treeBar").hide();
		}
		jQuery("button#catButton").removeClass("toggle-inactive");
		jQuery("button#catButton").addClass("toggle-active");
		jQuery("button#strucButton").removeClass("toggle-active");
		jQuery("button#strucButton").addClass("toggle-inactive");
		jQuery("div#catMenu").show();
		jQuery("div#leftPanelTree").hide();
}
	function setScrollTopOnClose() {
		if(getTopWindow().isMobile){		
			localStorage.setItem("isMobile", true);
			window.addEventListener('scroll', function() {
		       if (window.scrollY == 0) {	
		    	   //set scrolltop to zero to handle virtualkeyboard issue.
		    	   jQuery(".navigator.no-footer").scrollTop(0);			                           
		        }
		    });
		}     
	}
	
	function loadDelegatedUI(){
		require([
			'DS/ENOOSLCIssueConsumer/ENOOSLCReqConsumer'
			],function(ENOOSLCReqConsumer){
			var ENOOSLCReqConObj = new ENOOSLCReqConsumer();
			ENOOSLCReqConObj.setup();
			ENOOSLCReqConObj.launchDelegatedUI(ENOOSLCReqConObj.createIssuePostProcessSlidein);
	    	
	    });
	}

	function loadDelegatedUIAddExists(){
		require([
			'DS/ENOOSLCIssueConsumer/ENOOSLCReqConsumer'
			],function(ENOOSLCReqConsumer){
			var ENOOSLCReqConObj = new ENOOSLCReqConsumer();
			ENOOSLCReqConObj.setup();
			ENOOSLCReqConObj.launchDelegatedUI(ENOOSLCReqConObj.addExistingPostProcess);
	    });
	}	
	
  function launchDelegatedUI(varTargetWindow){
	require(['DS/ENOChgOSLCConsumer/scripts/ENOECMOSLCConsumer'],function(ENOECMOSLCConsumer){
			var enoECMOSLCConsumer = new ENOECMOSLCConsumer();
			enoECMOSLCConsumer.targetWindow = varTargetWindow;
			enoECMOSLCConsumer.setup();
			enoECMOSLCConsumer.loadDelegatedUICreate(enoECMOSLCConsumer.createChangePostProcessCommon);
			
		});
	
 }	
	
function loadDelegatedUIChangeRequest(){
	require([
		'DS/ENOOSLCIssueConsumer/ENOOSLCChangeRequestConsumer'
		],function(ENOOSLCChangeRequestConsumer){
		var ENOOSLCCRConObj = new ENOOSLCChangeRequestConsumer();
		ENOOSLCCRConObj.setup();
		ENOOSLCCRConObj.launchDelegatedUI(ENOOSLCCRConObj.addExistingPostProcess);

    });
}
