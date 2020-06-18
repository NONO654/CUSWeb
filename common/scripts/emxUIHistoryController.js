/*!================================================================
 *  JavaScript Constants
 *  emxUIHistoryController.js
 *  UI Level 3
 *  Requires: (nothing)
 *
 *  This file contains the class definition of the actionbar.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIHistoryController.js.rca 1.5.1.5 Wed Oct 22 15:47:47 2008 przemek Experimental przemek $
 *=================================================================
 */

//Globals
var objBackMenu = null;
var objForwardMenu = null;
var objOverflowMenu = null;
var objOFBackMenu = null;
var objOFForwardMenu = null;
var blnMenusInitialized = false;
var count = 0;
var backHistoryArr = null;
var forwardHistoryArr = null;

/**
 * This class represents a menu item
 * @author jwilliams
 * @param strUrl The url of the history item
 * @param strTargetlocation The frame to target
 * @param strWidth The width of the popup
 * @param strHeight The height of the popup
 * @param strCommandTitle The label for the history item
 * @return a emxUIHistoryItem object
 */
function emxUIHistoryItem(strUrl,strTargetlocation,strWidth,strHeight,strCommandTitle){
    this.url            = strUrl;
    this.targetlocation = strTargetlocation;
    this.strWidth       = strWidth;
    this.strHeight      = strHeight;
    this.label          = strCommandTitle
    return this;
}

/**
* @return Returns the url.
*/
emxUIHistoryItem.prototype.getUrl = function __getUrl(){
    return this.url;
}

/**
* @return Returns the target location.
*/
emxUIHistoryItem.prototype.getTargetlocation = function __getTargetlocation(){
    return this.targetlocation;
}

/**
* @return Returns the width.
*/
emxUIHistoryItem.prototype.getStrWidth = function __getStrWidth(){
    return this.strWidth;
}

/**
* @return Returns the height.
*/
emxUIHistoryItem.prototype.getStrHeight = function __getStrHeight(){
    return this.strHeight;
}


/**
 * This class represents a history controller
 * @author jwilliams
 * @return nothing
 */
function emxUIHistoryController(){
    this.historyBack    = new Array();
    this.historyForward = new Array();
    this.historyCurrent = new Array();
    this.isForwardSelected = true;
	this.isMenuItemClicked=false;
}

/**
* Set onload event
*/
emxUIHistoryController.prototype.init = function __init(){
	//History Hanlder is called befor emxUINavigator.init(); so delaying for 100 ms
    emxUICore.addEventHandler(window, "load", function () { setTimeout("historyControl.initialize()",100); } );
}

/**
* Initialize emxUIHistoryController
*/
emxUIHistoryController.prototype.initialize = function __initialize(){

    objBackMenu             = findMenu("AEFBackToolbarMenu");
    objForwardMenu          = findMenu("AEFForwardToolbarMenu");
    objOverflowMenu          = findMenu("emxUIToolbarOverflowButton");
	if(objOverflowMenu) {
		objOFBackMenu = findMenufromOtherMenu("AEFBackToolbarMenu", objOverflowMenu.menu);
		objOFForwardMenu = findMenufromOtherMenu("AEFForwardToolbarMenu", objOverflowMenu.menu);
	}

    blnMenusInitialized     = (objBackMenu && objForwardMenu)?true:false;

    try{
        disableBackMenu();
        disableForwardMenu();
        if(backHistoryArr){
        for(var i=0; i<backHistoryArr.length; i++ ){
            this.addBackItem(backHistoryArr[i]);
        }
        }
        if(forwardHistoryArr && forwardHistoryArr.length>0){
            this.historyForward = forwardHistoryArr;
            this.buildMenu(objForwardMenu, this.historyForward, "javascript:getTopWindow().historyControl.goForward");
            enableForwardMenu();
        }

    }catch(e){
        setTimeout("historyControl.initialize()",100);
    }

}

/**
* @param intDepth Integer defining how far back to go
* @return Returns a history item or null.
*/
emxUIHistoryController.prototype.getBack = function __getBack(intDepth){
    var intTimes = (intDepth > 0)?intDepth:1;
    if(this.historyBack.length == 0){
        return null;
    }
    while(intTimes > 0){
        var objItem     = this.historyBack.pop();
        var objCurrent  = this.historyCurrent.pop();
        this.historyCurrent.push(objItem);
        this.historyForward.push(objCurrent);
        if(objForwardMenu.menu.items.length<this.historyForward.length){
            this.historyForward.shift();
        }

        intTimes--;
    }
	//added for bug 335178 Begin
	var treeUrl="../common/emxTree.jsp";
	var menuItemUrl=objItem.url;
	var menuItemUrlPos=menuItemUrl.indexOf("?");
	if(treeUrl==menuItemUrl.substring(0,menuItemUrlPos)){
		this.isMenuItemClicked=true;
	}
	//added for bug 335178 End
    if(this.historyBack.length == 0){
        disableBackMenu();
    }
    return objItem;
}

/**
* @param intDepth Integer defining how far forward to go
* @return Returns a history item or null.
*/
emxUIHistoryController.prototype.getForward = function __getForward(intDepth){
    //this.isForwardSelected = false;
    var intTimes = (intDepth > 0)?intDepth:1;
    if(this.historyForward.length == 0){
        return null;
    }

    var counter = 1;
    while(intTimes > 0){
        var objItem     = this.historyForward.pop();

        if (counter == intDepth)
        {
            var objCurrent  = this.historyCurrent.pop();

            this.historyCurrent.push(objItem);
            this.historyBack.push(objCurrent);
        }
        else {
            this.historyBack.push(objItem);
        }
        counter++;
//Commented code for the Bug No:335178 1 Begin
        //this.historyCurrent.push(objItem);
//Commented code for the Bug No:335178 1 End

        intTimes--;
        }
	//added for bug 335178 Begin
	var treeUrl="../common/emxTree.jsp";
	var menuItemUrl=objItem.url;
	var menuItemUrlPos=menuItemUrl.indexOf("?");
	if(treeUrl==menuItemUrl.substring(0,menuItemUrlPos)){
		this.isMenuItemClicked=true;
	}
	//added for bug 335178 End
    if(this.historyForward.length == 0){
        disableForwardMenu();
    }
    return objItem;
}

/**
* Adds a history item to the history arrays
* Updates the back and forward menus
* @param objItem A history item
*/
emxUIHistoryController.prototype.addBackItem = function __addBackItem(objItem){
    //Commented code for the Bug No:335178 1 Begin
     if(count == 1 && !this.isForwardSelected){
		this.isForwardSelected = true;
        count = 0;
        return;
    }
    //Commented code for the Bug No:335178 1 End
    //check if menus have been initialized
    if(!blnMenusInitialized){
        objBackMenu             = findMenu("AEFBackToolbarMenu");
        objForwardMenu          = findMenu("AEFForwardToolbarMenu");
        blnMenusInitialized     = true;
    }

	if(!objOverflowMenu) {
		objOverflowMenu          = findMenu("emxUIToolbarOverflowButton");
		if(objOverflowMenu) {
			objOFBackMenu = findMenufromOtherMenu("AEFBackToolbarMenu", objOverflowMenu.menu);
			objOFForwardMenu = findMenufromOtherMenu("AEFForwardToolbarMenu", objOverflowMenu.menu);
		}
	}

    //do not add the same page
    if(this.historyCurrent.length > 0){
        //getTopWindow().document.title += this.historyCurrent[0].url.replace(/&DefaultCategory=/g,"") == objItem.url.replace(/&DefaultCategory=/g,"")
        //compare the url comming in to the "current" url
        if(objItem.url == this.historyCurrent[0].url){
            return;
        }
        /* //recheck with the "&DefaultCategory=" string removed
        if(this.historyCurrent[0].url.replace(/&DefaultCategory=/g,"") == objItem.url.replace(/&DefaultCategory=/g,"")){
            return;
        }
        */

        //if we have passed the previous tests
        //move the current history to the back array
        this.historyBack.push(this.historyCurrent.pop());
        if(objBackMenu.menu.items.length < this.historyBack.length){
            this.historyBack.shift();
        }
    }

    if (this.isForwardSelected)
    {
        var clearUrl = "emxPageHistorySessionProcess.jsp?mode=forwardHistory&action=removeAll";
        var oXMLHTTP = emxUICore.createHttpRequest();
        oXMLHTTP.open("post", clearUrl, false);
        oXMLHTTP.send("");

        //Emptying the forward history array.
        this.historyForward = new Array();
        disableForwardMenu();
    }

    //place the new item in the current array
    this.historyCurrent.push(objItem);

    //rebuild menus
    this.setMenuItems();
    this.isForwardSelected = true;
}

/**
* controls the back functionality
* @param intDepth Integer defining how far back to go
*/
emxUIHistoryController.prototype.goBack = function __goBack(intDepth){
    var level = (intDepth > 0)?intDepth:1
    var objPage = this.getBack(intDepth);
    var forwardCmdCnt = 0;
    if(objForwardMenu){
        forwardCmdCnt = objForwardMenu.menu.items.length;
    }
    var url = "emxPageHistorySessionProcess.jsp?mode=backHistory&action=goBack&depth="+level+"&forwardCmdCnt="+forwardCmdCnt;
    var oXMLHTTP = emxUICore.createHttpRequest();
    oXMLHTTP.open("post", url, false);
    oXMLHTTP.send("");
    if(objPage != null){
        this.openWindow(objPage);
        this.setMenuItems();
    }
}

/**
* controls the forward functionality
* @param intDepth Integer defining how far forward to go
*/
emxUIHistoryController.prototype.goForward = function __goForward(intDepth){
    var level = (intDepth > 0)?intDepth:1
    var objPage = this.getForward(intDepth);
    var url = "emxPageHistorySessionProcess.jsp?mode=forwardHistory&action=goForward&depth="+level;
    var oXMLHTTP = emxUICore.createHttpRequest();
    oXMLHTTP.open("post", url, false);
    oXMLHTTP.send("");
    if(objPage != null){
        this.openWindow(objPage);
        this.setMenuItems();
    }
}

/**
* Controls setting the back and forward menus
*/
emxUIHistoryController.prototype.setMenuItems = function __setMenuItems(){
    //back menu
    if(objBackMenu != null){
        this.buildMenu(objBackMenu, this.historyBack, "javascript:getTopWindow().historyControl.goBack");

        //enable Menu
        if(this.historyBack.length > 0){
            enableBackMenu();
        }

    }

    //forward menu
    if(objForwardMenu != null){
        this.buildMenu(objForwardMenu, this.historyForward, "javascript:getTopWindow().historyControl.goForward");

        //enable Menu
        if(this.historyForward.length > 0){
            enableForwardMenu();
        }
    }
}

/**
* Builds a back or forward menu
* @param objMenu The history menu
* @param arrHistory The history array of menu items
* @param strFunction The function name for the menu item to call
*/
emxUIHistoryController.prototype.buildMenu = function __buildMenu(objMenu, arrHistory, strFunction){
    //get the history array length
    var intHistoryLength = arrHistory.length-1;

    //get the menu size
    var intObjMenuLength = objMenu.menu.items.length;

    //clear labels and hrefs
    for(var i = 0; i < intObjMenuLength; i++) {
        objMenu.menu.items[i].rowElement.childNodes[0].innerHTML = "";
        objMenu.menu.items[i].url = "javascript:void(null)";
        objMenu.menu.items[i].rowElement.childNodes[0].title = "";
    }
    //set labels, hrefs and title

    for(var i = 0; (intHistoryLength >=0 && i < intObjMenuLength && arrHistory[intHistoryLength]); i++, intHistoryLength--){
    objMenu.menu.items[i].rowElement.childNodes[0].innerHTML = arrHistory[intHistoryLength].label;
    objMenu.menu.items[i].rowElement.childNodes[0].noWrap = "nowrap";
    objMenu.menu.items[i].rowElement.childNodes[0].title = arrHistory[intHistoryLength].label;
        objMenu.menu.items[i].url = strFunction +"(" + (i+1) +")";
    }

}

/**
* Opens the menu item in the appropriate frame or window
* @param objPage The history item to open
*/
emxUIHistoryController.prototype.openWindow = function __openWindow(objPage){
    var strUrl              = objPage.getUrl();
    var strTargetlocation   = objPage.getTargetlocation();
    var strWidth            = objPage.getStrWidth();
    var strHeight           = objPage.getStrHeight();
    count = 1;

    //Set default window width and height
    if(strWidth=="" || strWidth=="undefined")
    {
        strWidth="600";
    }

    if(strHeight=="" || strHeight=="undefined")
    {
        strHeight="600";
    }


    var frameTop = getTopWindow();
    var objFrame;
    var childWindow=null;

    //Use the topmost frame to open any new window in case the popup need to refresh the parent page
    if(strTargetlocation=="popup")
    {
        objFrame = findFrame(frameTop, "hiddenFrame");
        if(objFrame){
            var strFeatures = "width=" + strWidth + ",height=" + strHeight;
            childWindow=objFrame.window.open(strUrl,"popupwindow",strFeatures);
            childWindow.focus();
        }
    } else if(strTargetlocation=="_top") {
        frameTop.document.location.href = strUrl;
        frameTop.focus();
    }else{
        objFrame = findFrame(frameTop, "content");
        if(objFrame)
        {
            objFrame.document.location.href = strUrl;
            objFrame.focus();
        }
    }
}

//Functions
/**
* Finds the toolbar menu item by its command name
* @param strCommand The command name
*/
function findMenu(strCommand){
	return findMenufromOtherMenu(strCommand, getTopWindow().objMainToolbar);
}

function findMenufromOtherMenu(strCommand, mainmenu){
    var menuLen = mainmenu.items.length;
    for(var i = 0; i < menuLen; i++){
        if(mainmenu.items[i].command == strCommand){
            return mainmenu.items[i];
        }
    }
return null;
}

/**
* disable back menu
*/
function disableBackMenu(){
    if(objBackMenu.buttonElement) {
	objBackMenu.buttonElement.innerHTML=objBackMenu.buttonElement.innerHTML.replace("backarrow.png","backarrowdisabled.png");
	objBackMenu.buttonElement.style.color="#cccccc";
	objBackMenu.menuElement.innerHTML=objBackMenu.menuElement.innerHTML.replace("utilNavMenuArrow.gif","utilNavMenuArrowDisabled.gif");
    	objBackMenu.disable();
    } else if(objOFBackMenu){
        objOFBackMenu.disable();
    }
}

/**
* enable back menu
*/
function enableBackMenu(){
    if(objBackMenu.buttonElement) {
    	objBackMenu.buttonElement.innerHTML=objBackMenu.buttonElement.innerHTML.replace("backarrowdisabled.png","backarrow.png");
    	objBackMenu.buttonElement.style.color="#ffffff";
    	objBackMenu.menuElement.innerHTML=objBackMenu.menuElement.innerHTML.replace("utilNavMenuArrowDisabled.gif","utilNavMenuArrow.gif");
        objBackMenu.enable();
    } else if(objOFBackMenu){
            objOFBackMenu.enable();

    }
}

/**
* disable forward menu
*/
function disableForwardMenu(){
    if(objForwardMenu.buttonElement) {
    	objForwardMenu.buttonElement.innerHTML=objForwardMenu.buttonElement.innerHTML.replace("forwardarrow.png","forwardarrowdisabled.png");
    	objForwardMenu.buttonElement.style.color="#cccccc";
    	objForwardMenu.menuElement.innerHTML=objForwardMenu.menuElement.innerHTML.replace("utilNavMenuArrow.gif","utilNavMenuArrowDisabled.gif");
        objForwardMenu.disable();
    } else if(objOFForwardMenu){
            objOFForwardMenu.disable();
    }
}

/**
* enable forward menu
*/
function enableForwardMenu(){
    if(objForwardMenu.buttonElement) {
    	objForwardMenu.buttonElement.innerHTML=objForwardMenu.buttonElement.innerHTML.replace("forwardarrowdisabled.png","forwardarrow.png");
    	objForwardMenu.buttonElement.style.color="#ffffff";
    	objForwardMenu.menuElement.innerHTML=objForwardMenu.menuElement.innerHTML.replace("utilNavMenuArrowDisabled.gif","utilNavMenuArrow.gif");
        objForwardMenu.enable();
    } else if(objOFForwardMenu){
            objOFForwardMenu.enable();
    }
}

var historyControl = new  emxUIHistoryController;
historyControl.init();
//to create new items
//getTopWindow().historyControl.addBackItem(new getTopWindow().emxUIHistoryItem(strUrl,strTargetlocation,strWidth,strHeight,strMenuText));

//to go back
//getTopWindow().historyControl.goBack();
