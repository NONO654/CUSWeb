/*!================================================================
 *  JavaScript Consolidated Search Functions
 *  emxUISearchConsolidatedUtils.js
 *  Requires: emxUIConstants.js
 *  Last Updated: 19-July-07, Senthilnathan.S.K (NQG)
 *
 *  This file contains the code for the search.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUISearchConsolidatedUtils.js.rca 1.15.3.2 Wed Oct 22 15:48:25 2008 przemek Experimental przemek $
 *=================================================================
 */
//GLOBAL VARIABLES

var counter				= 0;

var dragging			= false;
var objDiv				= null;
var tempY				= 0;

var previousTempY		= 0;
var dragCount			= 1;
var previous 			= 606;
var consolidatedSearch  = new ConsolidatedSearch(isIE);
var retainedSearch      = new RetainedSearch();

window.onresize = setResize;


var attachSearchEventHandler,detachSearchEventHandler;

attachSearchEventHandler = function (objElement, strEvent, fnHandler) {
	objElement.addEventListener(strEvent, fnHandler, false);
}
detachSearchEventHandler = function (objElement, strEvent, fnHandler) {
	objElement.removeEventListener(strEvent, fnHandler, false);
}


function ConsolidatedSearch (isIE)
{
	this.divPageHeader       = null;
	this.divSearchCriteria   = null;
	this.divSearchActionBar  = null;
	this.divSearchGrabber    = null;
	this.divSearchResults    = null;
	this.divSearchFooter     = null;
	this.isIE				 = isIE;
	this.callbackAppyImage   = null;
	this.callbackAppyText    = null;
	this.callbackDoneImage   = null;
	this.callbackDoneText    = null;

	this.callbackFunction    = null;

	this.searchCheck 	     = null;
	this.queryLimit			 = null;

	this.searchContent       = null;
	this.searchResults       = null;
	this.searchHidden        = null;

	this.searchCriteriaStyle = new Object();
	this.searchActionStyle   = new Object();
	this.searchGrabberStyle  = new Object();
	this.searchResultsStyle  = new Object();

	this.collectionsClicked  = false;

	this.resultShown   = false;

	this.windowHeight  = "600";
	this.minimumResultWindow ="50";
	this.minimumResultHeight = "0";

}

ConsolidatedSearch.prototype.setCallback = function _setCallback(callback)
{
	if(callback != null && callback != "undefined" && callback != "")
		this.callbackFunction = callback;
}

ConsolidatedSearch.prototype.getCallback = function _getCallback()
{
	return this.callbackFunction;
}

ConsolidatedSearch.prototype.init = function _init()
{
	this.divPageHeader       = document.getElementById("pageHeader");
	this.divSearchCriteria   = document.getElementById("searchCriteriaDiv");
	this.divSearchActionBar  = document.getElementById("searchActionBarDiv");
	this.divSearchGrabber    = document.getElementById("searchGrabberDiv");
	this.divSearchResults    = document.getElementById("searchResultsDiv");
	this.divSearchFooter     = document.getElementById("searchFooterDiv");

	this.callbackAppyImage   = document.getElementById("callbackAppyImage");
	this.callbackAppyText    = document.getElementById("callbackAppyText");
	this.callbackDoneImage   = document.getElementById("callbackDoneImage");
	this.callbackDoneText    = document.getElementById("callbackDoneText");

	this.searchCheck 	     = document.getElementById("searchCheck");
	this.queryLimit			 = document.getElementById("QueryLimit");

	this.searchContent       = document.getElementById("searchContent");
	this.searchResults       = document.getElementById("searchResults");
	this.searchHidden        = document.getElementById("searchHidden");

	this.storeStyles();
	assignSearchEventHandlers();

}

ConsolidatedSearch.prototype.setStyle = function _setStyle(fromStyle,toStyle)
{
	toStyle.visibility  	 = fromStyle.style.visibility;
    toStyle.height           = fromStyle.style.height;
    toStyle.width            = fromStyle.style.width;
    toStyle.bottom           = fromStyle.style.bottom;
	toStyle.backgroundColor  = fromStyle.style.backgroundColor;;
    toStyle.position		 = fromStyle.style.position;
    toStyle.zIndex	         = fromStyle.style.zIndex;
    toStyle.cursor 		     = fromStyle.style.cursor;
    toStyle.right	         = fromStyle.style.right;
    toStyle.left             = fromStyle.style.left;
}

ConsolidatedSearch.prototype.storeStyles = function _storeStyles()
{

	this.setStyle( this.divSearchCriteria , this.searchCriteriaStyle );
	this.setStyle( this.divSearchActionBar, this.searchActionStyle );
	this.setStyle( this.divSearchGrabber  , this.searchGrabberStyle );
	this.setStyle( this.divSearchResults  , this.searchResultsStyle );
}


ConsolidatedSearch.prototype.resetDivs = function _resetDivs()
{
	 if(this.collectionsClicked)
	 {
	 	 if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        	getTopWindow().toolbars.setListLinks(false);
    	}
	 	this.collectionsClicked = false;
	 }
	 else
	 {
	 	if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        	getTopWindow().toolbars.setListLinks(retainedSearch.resultSelected);
    	}
	 	 return;
	 }


	 this.resetStyle( this.searchCriteriaStyle, this.divSearchCriteria);
	 this.resetStyle( this.searchActionStyle  , this.divSearchActionBar) ;
	 this.resetStyle( this.searchGrabberStyle , this.divSearchGrabber);
	 this.resetStyle( this.searchResultsStyle , this.divSearchResults);

	 if(this.isIE)
	 {
	 	height = emxUICore.getWindowHeight(window);
		this.divSearchCriteria.style.height = Math.abs(height-135) + "px";
	 }
}

ConsolidatedSearch.prototype.resetStyle = function _resetStyle(fromStyle,toStyle)
{
	toStyle.style.visibility  	 = fromStyle.visibility;
    toStyle.style.height         = fromStyle.height;
    toStyle.style.width          = fromStyle.width;
    toStyle.style.bottom         = fromStyle.bottom;
	toStyle.style.backgroundColor= fromStyle.backgroundColor;;
    toStyle.style.position		 = fromStyle.position;
    toStyle.style.zIndex	     = fromStyle.zIndex;
    toStyle.style.cursor 		 = fromStyle.cursor;
    toStyle.style.right	         = fromStyle.right;
    toStyle.style.left           = fromStyle.left;
}

ConsolidatedSearch.prototype.showResults = function _showResults()
{
	getTopWindow().turnOffProgressTop();

	if(this.resultShown)
		return;

	this.resultShown   = true;
    this.divSearchResults.style.visibility="visible";

    this.divSearchResults.style.height    ="190px";
    this.divSearchResults.style.width     ="100%";
    this.divSearchResults.style.bottom    ="37px";
    this.divSearchResults.style.position  ="absolute";

    this.divSearchGrabber.style.position  ="absolute";
	this.divSearchGrabber.style.visibility="visible";
    this.divSearchGrabber.style.height    ="7px";

	if(this.isIE)
	{
		this.divSearchGrabber.style.bottom    ="221px";
	}
	else
		this.divSearchGrabber.style.bottom    ="227px";


	this.divSearchGrabber.style.zIndex="1";


	this.divSearchActionBar.style.bottom  ="234px";

    this.divSearchCriteria.style.bottom   ="264px";

	currentWindow = emxUICore.getWindowHeight(window);

    if(isIE && emxUICore.getWindowHeight(window) > 150)
    {
    	var height = parseInt(this.divSearchCriteria.style.height)-parseInt(this.divSearchResults.style.height)-parseInt(this.divSearchGrabber.style.height);
    	var diff = currentWindow - previous;
    	previous = currentWindow;
    	this.divSearchCriteria.style.height = (height+diff)+"px";
    }
}


ConsolidatedSearch.prototype.prepareChangeToCollection = function _prepareChangeToCollection(header)
{
    if(consolidatedSearch.divPageHeader)
   		consolidatedSearch.divPageHeader.innerHTML = header;

	if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        	getTopWindow().toolbars.setListLinks(false);
    }

    if(pageControl)
    	pageControl.enableReset = "false";

    if(getTopWindow().retainedSearch)
    	 	getTopWindow().retainedSearch.clear();

    if(consolidatedSearch.searchCheck)
    	if(consolidatedSearch.searchCheck.checked)
    		consolidatedSearch.searchCheck.click();

    if(consolidatedSearch.queryLimit)
    	if(consolidatedSearch.queryLimit.value != 100)
    		consolidatedSearch.queryLimit.value = 100;

    this.collectionsClicked = true;
    this.resultShown        = false;
}



ConsolidatedSearch.prototype.changeToCollection = function _changeToCollection(header,contentURL,resultsURL)
{

	this.prepareChangeToCollection(header);

	getTopWindow().turnOnProgressTop();

	if(this.divSearchCriteria)
	{
	   this.divSearchCriteria.style.bottom ="37px";
	   height = emxUICore.getWindowHeight(window);
	   this.divSearchCriteria.style.height = Math.abs(height-105) + "px";
	}

	searchContent       = findFrame(getTopWindow(),"searchContent");
	searchResults       = findFrame(getTopWindow(),"searchResults");

	if(this.divSearchActionBar)
	   this.divSearchActionBar.style.visibility="hidden";

	if(this.divSearchGrabber)
	   this.divSearchGrabber.style.visibility="hidden";

	if(this.divSearchResults)
	   this.divSearchResults.style.visibility="hidden";

	if(searchContent)
	   searchContent.location.href =contentURL;

	if(searchResults)
	   searchResults.location.href =resultsURL;
}


function RetainedSearch()
{
	this.array = new Array();
	this.retainedChecked = false;
	this.oid   = new Array();
	this.relid = new Array();
	this.id    = new Array();
	this.resultSelected = false;
}

RetainedSearch.prototype.setSelected = function _setSelected(bool)
{
	this.resultSelected = bool;
}

RetainedSearch.prototype.getSelected = function _getSelected()
{
	return this.resultSelected;
}

RetainedSearch.prototype.setChecked = function _setChecked(bool)
{
	this.retainedChecked = bool;
}

RetainedSearch.prototype.getChecked = function _getChecked()
{
	return this.retainedChecked;
}

RetainedSearch.prototype.add = function _add(item)
{
	this.array.push(item);
}

RetainedSearch.prototype.get = function _get()
{
	return this.array;
}

RetainedSearch.prototype.length = function _length()
{
	return this.array.length;
}

RetainedSearch.prototype.isObjectId = function _isObjectId(idOrNot) {
        try {
           	var idArray = idOrNot.split(".");
			for(var i = 0; i < idArray.length ; i++) {
				if(isNaN(idArray[i]))
					return false;
          	}
            return true;
        } catch (ex) {
            return false;
        }
}

RetainedSearch.prototype.storeSelected = function _storeSelected(str,sep)
{

	var array = str.split(sep);
	this.clear();
	this.setSelected( str.length > 1);
	resetToolbarLink(str.length > 1);

	for(var i = 0 ; i < array.length ; i++)
	{
		if("" == array[i])
			continue;

		var strID = array[i];

		var aId = strID.split("|");

		 var relid = aId[0];
    	if (relid == null || relid == "null") {
        		relid = "";
    		}
    	var oid = aId[1];
   		var id = aId[3];

   		if(!this.isObjectId(oid)) {
			this.clear();
			resetToolbarLink(false);
   			return;
   		}

		this.oid.push(oid);
		this.relid.push(relid);
		this.id.push(id);

		var ids = new Array(oid,relid,id);
		this.array.push(ids);
	}
}

RetainedSearch.prototype.getSelectedOIDs = function _getSelectedOIDs()
{
	var array = this.oid;
	var selectedIds = "";
	if(array != null && array != "undefined" && this.retainedChecked)  {
         selectedIds = this.oid;
    }
    return selectedIds;
}

RetainedSearch.prototype.getSelectedIDs = function _getSelectedIDs()
{
	var array = this.id;
	var selectedIds = "";
	if(array != null && array != "undefined" && this.retainedChecked)  {
         selectedIds = this.id;
    }
    return selectedIds;
}

RetainedSearch.prototype.getSelectedRELIDs = function _getSelectedRELIDs()
{
	var array = this.relid;
	var selectedIds = "";
	if(array != null && array != "undefined" && this.retainedChecked)  {
         selectedIds = this.relid;
    }
    return selectedIds;
}

RetainedSearch.prototype.clear = function _clear()
{
	this.array = new Array();
	this.oid = new Array();
	this.relid = new Array();
	this.id = new Array();
	this.resultSelected = false;
}


function searchResultObject(action)
{
	this.oids    = new Array();
	this.relids  = new Array();
	this.action  = action;
}

searchResultObject.prototype.setAction = function _setAction (action)
{
	if(action != null && action != "null" && action != "undefined" && value != "")
		this.action = action;
}

searchResultObject.prototype.getAction = function _getAction ()
{
	return this.action;
}

searchResultObject.prototype.setOids = function _setOids (array)
{
	for(var i = 0 ; i < array.length; i++)
	{
		this.oids.push(array[i]);
	}
}

searchResultObject.prototype.setRELids = function _setRELids (array)
{
	for(var i = 0 ; i < array.length; i++)
	{
		this.relids.push(array[i]);
	}
}

searchResultObject.prototype.getOids = function _getOids ()
{
	return this.oids;
}

searchResultObject.prototype.getRELids = function _getRELids (array)
{
	return this.relids;
}


function enableApply(bool)
{
	var applyImage = consolidatedSearch.callbackAppyImage;
    var applyText  = consolidatedSearch.callbackAppyText ;

     if(applyImage && bool == "true" ) {
        	applyImage.style.visibility ="visible";
      } else if(applyImage) {
        	applyImage.style.display ="none";
     }

     if(applyText && bool == "true" ) {
        	applyText.style.visibility ="visible";
      } else if(applyText){
        	applyText.style.display ="none";
     }
}

function enableDone(bool)
{
	var doneImage = consolidatedSearch.callbackDoneImage;
    var doneText = consolidatedSearch.callbackDoneText;

      if(doneImage && bool == "true" ) {
        	doneImage.style.visibility ="visible";
        } else if(doneImage) {
        	doneImage.style.display ="none";
       }

      if(doneText && bool == "true" ){
        	doneText.style.visibility ="visible";
        } else if(doneText){
        	doneText.style.display ="none";
       }
}

function doCheckboxState(objCheckbox)
{
	retainedSearch.setChecked(objCheckbox.checked);
}

function enablesave ()
{
    setTimeout(function(){
    getTopWindow().setSaveFunctionality(true);
	 }, 1000);

 }

function trimWhitespace(strString)
{
    strString = strString.replace(/^[\s\u3000]*/g, "");
    return strString.replace(/[\s\u3000]+$/g, "");
}


function onLoadSearchContent()
{
	getTopWindow().turnOffProgressTop();
}
function doDone()
{
	if(!retainedSearch.getSelected())
	{
		alert(ALERT_SELECT_OBJECT);
		return;
	}
	var searchReturn = new searchResultObject("done");
	searchReturn.setOids(retainedSearch.oid);
	searchReturn.setRELids(retainedSearch.relid);
	var callbackFunction = consolidatedSearch.getCallback();
    var callback = eval("getTopWindow().getWindowOpener()."+callbackFunction);

   try {
    		var status = callback(searchReturn);

    		if(status != 0)	{
    			alert(ALERT_CALLBACK_ERROR);
    		}
    		else  {
    			alert(CONSOLIDATED_ADDED_CALLBACK);
    			getTopWindow().closeWindow();
    		}

       } catch(e) {
    	alert(ALERT_CALLBACK_ERROR +" "+ e.message);
    }
}

function doApply()
{

	if(!retainedSearch.getSelected())
	{
		alert(ALERT_SELECT_OBJECT);
		return;
	}
	var searchReturn = new searchResultObject("apply");
	searchReturn.setOids(retainedSearch.oid);
	searchReturn.setRELids(retainedSearch.relid);
	var callbackFunction = consolidatedSearch.getCallback();
    var callback = eval("getTopWindow().getWindowOpener()."+callbackFunction);

    try {
    		var status = callback(searchReturn);

    		if(status != 0)	{
    			alert(ALERT_CALLBACK_ERROR);
    		}
    		else {
    			alert(CONSOLIDATED_ADDED_CALLBACK);
    		}

       } catch(e) {
    	alert(ALERT_CALLBACK_ERROR +" "+ e.message);
    }
}

function submitSearch(url,selectedIds)
{
 	var theForm = null;
 	var doc = null;
 	var bodyFrame = findFrame(getTopWindow(),"searchContent");

	if(bodyFrame && bodyFrame.contentWindow)
	{
		doc = bodyFrame.contentWindow.document;
		theForm = bodyFrame.contentWindow.document.forms[0];
		bodyFrame = bodyFrame.contentWindow;
	}
	else if(bodyFrame)
	{
		doc	= bodyFrame.document;
		theForm = bodyFrame.document.forms[0];
		bodyFrame = bodyFrame;
	}

   if(doc.getElementById("selectedIds"))
	{
		doc.getElementById("selectedIds").value=selectedIds;
	}
	else
	{
		var obj = doc.createElement("input");
		obj.setAttribute("type","hidden");
		obj.setAttribute("name","selectedIds");
		obj.setAttribute("id","selectedIds");
		obj.setAttribute("value",selectedIds);
		theForm.appendChild(obj);
	}

    theForm.target = "searchResults";
    theForm.method = "post";
    theForm.action = url;
    theForm.submit();

}


function doGenericSearch()
{

    var theForm = null;

    if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        	getTopWindow().toolbars.setListLinks(false);
    }

    var QLimit = parseInt(getTopWindow().document.getElementById("QueryLimit").value, 10);
    var bodyFrame = findFrame(getTopWindow(),"searchContent");

	if(bodyFrame && bodyFrame.contentWindow)
	{
		theForm = bodyFrame.contentWindow.document.forms[0];
		bodyFrame = bodyFrame.contentWindow;
	}
	else if(bodyFrame)
	{
		theForm = bodyFrame.document.forms[0];
		bodyFrame = bodyFrame;
	}

	if(bodyFrame.document.forms[0].QueryLimit){
        bodyFrame.document.forms[0].QueryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.document.forms[0].queryLimit){
        bodyFrame.document.forms[0].queryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.validateForm) {
        if(!bodyFrame.validateForm(bodyFrame.document.forms[0]))
    		return;
    }

    theForm.target = "searchHidden";

    theForm.action = "../common/emxConsolidatedSearchProcess.jsp";

    theForm.submit();


}

function submitFreezePaneData(strURL, strTarget, strRowSelect, bPopup, bModal, iWidth, iHeight, confirmationMessage, strPopupSize)
{
	var searchResults = findFrame(getTopWindow(),"searchResults");
	var searchContent =	findFrame(getTopWindow(),"searchContent");

	if(consolidatedSearch.collectionsClicked)
	{
		if(searchContent){
			if(searchContent.submitFreezePaneData) {
					searchContent.submitFreezePaneData(strURL, strTarget, strRowSelect, bPopup, bModal, iWidth, iHeight, confirmationMessage, strPopupSize);
					return;			}
			}
	}else {
		if(searchResults){
			if(searchResults.submitFreezePaneData) {
					searchResults.submitFreezePaneData(strURL, strTarget, strRowSelect, bPopup, bModal, iWidth, iHeight, confirmationMessage, strPopupSize);
					return; }
			}
	}
	alert(ALERT_DO_SEARCH);
}


function consolidatedSubmitList(strURL, strTarget, strRowSelect, bPopup, iWidth, iHeight, confirmationMessage, strMethod)
{

	var searchResults = findFrame(getTopWindow(),"searchResults");
	var searchContent =	findFrame(getTopWindow(),"searchContent");

	if(consolidatedSearch.collectionsClicked)
	{
		if(searchContent){
			if(searchContent.submitList) {
					searchContent.submitList(strURL, strTarget, strRowSelect, bPopup, iWidth, iHeight, confirmationMessage, strMethod);
					return;			}
			}
	}else {
		if(searchResults){
			if(searchResults.submitList) {
					searchResults.submitList(strURL, strTarget, strRowSelect, bPopup, iWidth, iHeight, confirmationMessage, strMethod);
					return; }
			}
	}

	//Modified for 346329
	alert(ALERT_DO_SEARCHCOMPARE);

}

function openCollections()
{
	var collectionsParams = "program=emxAEFCollection:getCollections&table=AEFCollectionsConsolidated&objectBased=false&hideHeader=true&hideFooter=true&selection=multiple&sortColumnName=Name&sortDirection=ascending&uiType=StructureBrowser&searchType=consolidatedSearch";
	var collectionsURL     = "emxIndentedTable.jsp?" + collectionsParams;

	consolidatedSearch.changeToCollection(STR_SEARCH_TITLE + COLLECTIONS,collectionsURL,"emxBlank.jsp");
}

function openClipboardItems()
{
	var clipboardURL = "emxIndentedTable.jsp?program=emxAEFCollection:getObjects&treeLabel=mxClipboardCollections&objectBased=true&hideHeader=true&hideFooter=true&sortColumnName=Name&searchType=consolidatedSearch";

	var selection ="&selection=multiple";
	var table	  ="&table=AEFConsolidatedSearchResults";
	var sortColumnName	="&sortColumnName=";

	if(isCONTEXTSEARCH == "true")	{
		if(CONSOLIDATED_UNIQUE_SELECTION != null && CONSOLIDATED_UNIQUE_SELECTION != "undefined" && CONSOLIDATED_UNIQUE_SELECTION != "" && CONSOLIDATED_UNIQUE_SELECTION != "null")
			selection = "&selection=" + CONSOLIDATED_UNIQUE_SELECTION;

		if(CONSOLIDATED_UNIQUE_TABLE != null && CONSOLIDATED_UNIQUE_TABLE != "undefined" && CONSOLIDATED_UNIQUE_TABLE != "" && CONSOLIDATED_UNIQUE_TABLE != "null")
			table = "&table=" + CONSOLIDATED_UNIQUE_TABLE;

		if(CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != null && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "undefined" && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "" && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "null")
			sortColumnName = "&sortColumnName=" + CONSOLIDATED_UNIQUE_SORTCOLUMNNAME;
	}

	clipboardURL += table + selection + sortColumnName;

	consolidatedSearch.changeToCollection(STR_SEARCH_TITLE + CLIPBOARD_COLLECTIONS,clipboardURL,"emxBlank.jsp");

}

function collectionItems(collectionName)
{
	var itemsURL = "emxIndentedTable.jsp?program=emxAEFCollection:getObjects&objectBased=true&hideHeader=true&hideFooter=true&searchType=consolidatedSearch";
	var treeLabel =	"&treeLabel="+collectionName;
	var label     = STR_SEARCH_TITLE + collectionName;
	var selection ="&selection=multiple";
	var table	  ="&table=AEFConsolidatedSearchResults";
	var sortColumnName	="&sortColumnName=";

	if(isCONTEXTSEARCH == "true")	{
		if(CONSOLIDATED_UNIQUE_SELECTION != null && CONSOLIDATED_UNIQUE_SELECTION != "undefined" && CONSOLIDATED_UNIQUE_SELECTION != "" && CONSOLIDATED_UNIQUE_SELECTION != "null")
			selection = "&selection=" + CONSOLIDATED_UNIQUE_SELECTION;

		if(CONSOLIDATED_UNIQUE_TABLE != null && CONSOLIDATED_UNIQUE_TABLE != "undefined" && CONSOLIDATED_UNIQUE_TABLE != "" && CONSOLIDATED_UNIQUE_TABLE != "null")
			table = "&table=" + CONSOLIDATED_UNIQUE_TABLE;

		if(CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != null && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "undefined" && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "" && CONSOLIDATED_UNIQUE_SORTCOLUMNNAME != "null")
			sortColumnName = "&sortColumnName=" + CONSOLIDATED_UNIQUE_SORTCOLUMNNAME;
	}

	itemsURL += treeLabel + table + selection + sortColumnName;
	consolidatedSearch.changeToCollection(label,itemsURL,"emxBlank.jsp");
}

function exportData()
{
	var searchResults = findFrame(getTopWindow(),"searchResults");
	var searchContent =	findFrame(getTopWindow(),"searchContent");

	if(consolidatedSearch.collectionsClicked)
	{
		if(searchContent){
			if(searchContent.exportData) {
					searchContent.exportData();
					return;			}
			}
	}else {
		if(searchResults){
			if(searchResults.exportData) {
					searchResults.exportData();
					return; }
			}
	}
	// Modified for Bug 346329
	alert(ALERT_DO_SEARCHEXPORT);
}




//This overloaded opens help
function openHelp(){
	 alert("Help functionality is not being implemented here");
//	var childWindow = null;
//
//	directory = pageControl.helpMarkerSuiteDir;
//	pageTopic = pageControl.helpMarker ;
//	langStr   = STR_SEARCH_LANG;
//
//	directory = directory.toLowerCase();
//    var url = "../doc/" +  directory + "/" + langStr + "/wwhelp/wwhimpl/js/html/wwhelp.htm?context=" + directory + "&topic=" + pageTopic;
//    alert("3333333333");
//    if(!checkURL(url)){
//    	alert("3333333333");
//        url = "../doc/" +  directory + "/" + langStr + "/ENOHelp.htm?context=" + directory + "&topic=" + pageTopic;
//    }
//
//    if ((childWindow == null) || (childWindow.closed))
//    {
//        childWindow = window.open(url,"helpwin","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
//        childWindow.focus();
//    } else {
//        childWindow.location.replace(url);
//        childWindow.focus();
//    }
//    return;
}

function checkURL(url){
    var xmlhttp = emxUICore.createHttpRequest();
    xmlhttp.open("GET", url, false);
    xmlhttp.send(null);
    return xmlhttp.status==200;
}

function openPrinterFriendlyPage()
{
	var searchResults = findFrame(getTopWindow(),"searchResults");
	var searchContent =	findFrame(getTopWindow(),"searchContent");

	if(consolidatedSearch.collectionsClicked)
	{
		if(searchContent){
			if(searchContent.openPrinterFriendlyPage) {
					searchContent.openPrinterFriendlyPage();
					return;			}
			}
	}else {
		if(searchResults){
			if(searchResults.openPrinterFriendlyPage) {
					searchResults.openPrinterFriendlyPage();
					return; }
			}
	}
	// Modified for Bug 346329
	alert(ALERT_DO_SEARCHPRINTER);
}


function refreshSearchResutls()
{

	getTopWindow().turnOnProgressTop();

	if(retainedSearch)
		retainedSearch.clear();

	 if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        	getTopWindow().toolbars.setListLinks(false);
    }

	var searchResults = findFrame(getTopWindow(),"searchResults");
	var searchContent =	findFrame(getTopWindow(),"searchContent");

	if(consolidatedSearch.collectionsClicked)
	{
		if(searchContent){
			searchContent.location.href = searchContent.location.href;
			return;
		}
	}else {
		if(searchResults){
			searchResults.location.href = searchResults.location.href;
			return;
		}
	}
}


function resetSearchCriteria()
{
	var	searchViewUrl = null;

	var targetFrame = findFrame(getTopWindow(),"searchContent");
	var reset = "true";

	if(pageControl)
    	reset = pageControl.enableReset;

	 if(targetFrame && reset == "true")
	 {

	 	getTopWindow().turnOnProgressTop();
	 	if(targetFrame.contentWindow)
	 	{
	 		searchViewUrl = pageControl.getSearchContentURL();
	 		targetFrame.setAttribute("src", searchViewUrl);
	 		return;
	 	}
	 	else
	 	{
	 		searchViewUrl = pageControl.getSearchContentURL();
	 		targetFrame.location.href =  searchViewUrl;
	 		return;
	 	}
	 }
}


var previousY = 0;
var counting  = 1;

function resizeDivs(objDiv){
    sliderDiv = objDiv;

    if(!dragging) return;

    if(counting == 1)
    	previousY = tempY-3;

    diff = previousY - tempY;

    var searchResultHeigtht = parseInt(consolidatedSearch.divSearchResults.style.height );
   	var SearchGrabberBottom = 	parseInt(consolidatedSearch.divSearchGrabber.style.bottom);
   	var SearchActionBarBottom = parseInt(consolidatedSearch.divSearchActionBar.style.bottom);
   	var SearchCriteriaBottom =	parseInt(consolidatedSearch.divSearchCriteria.style.bottom);
   	var SearchCriteriaHeight =	parseInt(consolidatedSearch.divSearchCriteria.style.height);
      try{
		     consolidatedSearch.divSearchResults.style.height    = (parseInt(consolidatedSearch.divSearchResults.style.height ) + diff )+"px";
		     consolidatedSearch.divSearchGrabber.style.bottom     = parseInt(consolidatedSearch.divSearchGrabber.style.bottom)+diff+"px";
		     consolidatedSearch.divSearchActionBar.style.bottom   = (parseInt(consolidatedSearch.divSearchActionBar.style.bottom) + diff )+"px";
		     consolidatedSearch.divSearchCriteria.style.bottom    = (parseInt(consolidatedSearch.divSearchCriteria.style.bottom) + diff )+"px";

		    if(isIE)
		    {
		        consolidatedSearch.divSearchCriteria.style.height    = (parseInt(consolidatedSearch.divSearchCriteria.style.height)-diff)+"px";
		        consolidatedSearch.divSearchResults.style.bottom    = "37px";
		    }
   		}catch(e){

   			 consolidatedSearch.divSearchResults.style.height     = searchResultHeigtht+"px";
		     consolidatedSearch.divSearchGrabber.style.bottom     = SearchGrabberBottom+"px";
		     consolidatedSearch.divSearchActionBar.style.bottom   = SearchActionBarBottom+"px";
		     consolidatedSearch.divSearchCriteria.style.bottom    = SearchCriteriaBottom+"px";

		    if(isIE)
		    {
		        consolidatedSearch.divSearchCriteria.style.height   = SearchCriteriaHeight+"px";
		        consolidatedSearch.divSearchResults.style.bottom    = "37px";
		    }

   		}
    previousY = tempY;
    counting++;
    setTimeout("resizeDivs(sliderDiv)",100);
}



function assignSearchEventHandlers()
{
    attachSearchEventHandler(consolidatedSearch.divSearchCriteria, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.divSearchCriteria, "mouseup", stopDragging);

    attachSearchEventHandler(consolidatedSearch.divSearchActionBar, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.divSearchActionBar, "mouseup", stopDragging);

    attachSearchEventHandler(consolidatedSearch.divSearchGrabber, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.divSearchGrabber, "mouseup", stopDragging);

    attachSearchEventHandler(consolidatedSearch.divSearchResults, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.divSearchResults, "mouseup", stopDragging);
    attachSearchEventHandler(consolidatedSearch.searchContent, "load", onLoadSearchContent);
    attachSearchEventHandler(consolidatedSearch.searchContent.contentWindow.document, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.searchContent.contentWindow.document, "mouseup", stopDragging);
    attachSearchEventHandler(window, "resize", getMouseXY);
}


function setDragging(objDiv)
{
   	dragging = true;
   	resizeDivs(objDiv);
}

function stopDragging(stop)
{
   	dragging = false;
}

function getMouseXY(event)
{
    if (isIE) {
    	tempY = event.clientY;
    }
  	else {
    	tempY = event.pageY;
    }

 	if (tempY < 0) 	{tempY = 0 	}

	return tempY;
}

function getMouseFreeze(event)
{
	  if (isIE) {
    		tempY = previousY + event.clientY;
       }
  		else {
    		tempY = previousY + event.pageY;//event.pageY;
    	}
        if (tempY < 0) 	{tempY = 0 	}
		return tempY;
}


function setResize()
{
    var searchCriteriaDiv = document.getElementById("searchCriteriaDiv");

    if(!isIE && !searchCriteriaDiv || parseInt(emxUICore.getWindowHeight(window))< 250)
    	return;

    counting = 1;
     var height = parseInt(searchCriteriaDiv.style.height);
     var diff = emxUICore.getWindowHeight(window) - previous;

     if(height+diff<5)
     return;

     previous = emxUICore.getWindowHeight(window);
     searchCriteriaDiv.style.height = (height+diff)+"px";
}


function setSize()
{
    var searchCriteriaDiv = document.getElementById("searchCriteriaDiv");
     if(isIE)
     {
     	searchCriteriaDiv.style.height="470px";
     	searchCriteriaDiv.style.overflow="auto";
     }
}

//added for bug 343719
function registereContent()
{
	attachSearchEventHandler(consolidatedSearch.searchContent.contentWindow.document, "mousemove", getMouseXY);
    attachSearchEventHandler(consolidatedSearch.searchContent.contentWindow.document, "mouseup", stopDragging);
}

//added for bug 343719
function registerEvent()
{
   setTimeout("registereContent();",400);
}

function resetToolbarLink(bool)
{
	if (getTopWindow().toolbars && getTopWindow().toolbars.setListLinks) {
        		getTopWindow().toolbars.setListLinks(bool);
    }
}
