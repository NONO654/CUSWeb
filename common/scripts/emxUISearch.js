/*!================================================================
 *  JavaScript Search Functions
 *  emxUISearch.js
 *  Requires: emxUIConstants.js
 *  Last Updated: 01-Dec-03, John M. Williams (JMW)
 *
 *  This file contains the code for the search.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUISearch.js.rca 1.26.2.1 Fri Nov  7 09:44:42 2008 ds-kvenkanna Experimental $
 *=================================================================
 */
//GLOBAL VARIABLES
var pageControl = new pageController();
var NAME = 0;
var VALUE = 1;
var CHECKED = 2;
var DISABLED = 3;
var strProtocol, strHost, strPort;
 







//
// Following method encodes the URI using javascript encodeURI function if the character encoding is UTF8
//
var isCharacterEncodingUTF8 = false;
function encodeURIIfCharacterEncodingUTF8 (strURI)
{
    var strResultURI = strURI;
    if (isCharacterEncodingUTF8)
    {
        strResultURI = encodeURI(strURI);
    }
    return strResultURI;
}




//
// The save search name is encoded with the unicode values separated with . (dot)
// Ex. if the save search name is 'ABC' then the encoded name will be '65.66.67'
//
function encodeSaveSearchName(strSaveSearchName)
{
    if (strSaveSearchName == null || strSaveSearchName.length <= 0)
    {
        return strSaveSearchName;
    }

    var strEncodedSaveSearchName = "";
    for (var i = 0; i < strSaveSearchName.length; i++)
    {
        strEncodedSaveSearchName += strSaveSearchName.charCodeAt(i);
        if (i < (strSaveSearchName.length - 1))
        {
            strEncodedSaveSearchName += ".";
        }
    }

    return strEncodedSaveSearchName;
}


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////   PageController Class    /////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
with(document.location){
    strProtocol = protocol;
    strHost = hostname;
    strPort = port
}

function pageController(){
        this.showingAdvanced = false;
        this.title = null;
        this.type = null;
        this.searchContentURL = "";
        this.savedSearchName = "";
        this.showErrMsg = false;
        this.doReload = false;
        this.doSubmit = false;
        this.arrFormVals = new Array();
        this.helpMarker = null;
        this.helpMarkerSuiteDir = null;
        this.queryLimit = null;
        this.pagination = null;
        this.baseQueryString = "";
	    
	    //added for Consolidated Search	    
	 
	    this.uniqueTable	     = "";
	    this.uniqueProgram	     = "";
	    this.uniqueExpandProgram = "";
	    this.uniqueRelationship  = "";  	
	    this.uniqueSortColumnName = "";
	    this.uniqueSelection 	  = "multiple";
	    
	    this.table 				= "";
	    this.program 			= "";	  
	    this.expandProgram 		= "";
	    this.relationship 	    = ""; 	  
	    this.sortColumnName 	= "";
	    this.selection 			= "";  
	    
	    this.requestedType		="*";
	    
	    this.defaultSearch 		= "AEFGeneralSearch";	     
	   
	   	   	    
	    this.tableSetting 		= "";
	    this.programSetting 	= "";
	    this.functionSetting 	= "";
	    this.searchType 		= "General";
	    
	    this.freezePane			= "";
	    
	    this.hideHeader			= "true";
	    this.hideFooter			= "true";
	    
	    this.searchProgram 		= "";
	    this.searchTable 		= "AEFConsolidatedSearchResults";	   
	    this.valuePair          = "";
	    this.enableReset	    = "true";
	    this.isContextSearch    = "";
	    // ended for Consolidated Search
	    //Added for Bug 368004
	    this.childWindows       = [];
}

pageController.prototype.pushChildWindows = function _pushChildWindows(childWindow)
{
	this.childWindows.push(childWindow);
}

pageController.prototype.clearChildWindows = function _clearChildWindows()
{
    for (var i = 0; i < this.childWindows.length; i++)
    {
        if(isMac && isIE)
        {
            eval("try { \
                if (pageControl.childWindows[i] && !pageControl.childWindows[i].closed) \
                    pageControl.childWindows[i].closeWindow(); \
            } catch(e) { \
            }");
         }else
         {
            try
            {
            	if (this.childWindows[i] && !this.childWindows[i].closed)
               		 this.childWindows[i].closeWindow();
            } catch(ex)
            {
            }
        }
    }

	this.childWindows = [];
}

function registerSearchWindows(childWindow)
{
	if(pageControl != null)	{
		pageControl.pushChildWindows(childWindow);
	}
}

pageController.prototype.setSearchProgram = function _setSearchProgram(param,value)
{
		var searchProgram = "";		
		if(this.program != null && this.program != "undefined" && this.program != "" && this.program != "null")	{				
				searchProgram = this.program;
		}		
		if(this.programSetting != null && this.programSetting != "undefined" && this.programSetting != "" && this.programSetting != "null")	{
				if(this.functionSetting != null && this.functionSetting != "undefined" && this.functionSetting != "" && this.functionSetting != "null"){					
					searchProgram = this.programSetting + ":" + this.functionSetting;
				}
		}
		
		if(searchProgram == null || searchProgram == "undefined" || searchProgram == "" || searchProgram == "null")	{				
			if(this.uniqueProgram != null && this.uniqueProgram != "undefined" && this.uniqueProgram != "" && this.uniqueProgram != "null")	{				
				searchProgram = this.uniqueProgram;
			}	
		}
	
	return this.searchProgram = searchProgram;
}

pageController.prototype.setSearchTable = function _setSearchTable()
{
		var searchTable = "";				
			
		if(this.table != null && this.table != "undefined" && this.table != "" && this.table != "null")	{					
				searchTable = this.table;
		}		
		if(this.tableSetting != null && this.tableSetting != "undefined" && this.tableSetting != "" && this.tableSetting != "null"){				
				searchTable = this.tableSetting;						
		}
		
		if(this.isContextSearch == "true" || searchTable == null || searchTable == "undefined" || searchTable == "" || searchTable == "null")	{				
			if(this.uniqueTable != null && this.uniqueTable != "undefined" && this.uniqueTable != "" && this.uniqueTable != "null")			
					searchTable =  this.uniqueTable;
		}			
		if(searchTable == null || searchTable == "undefined" || searchTable == "" || searchTable == "null")	{			
				searchTable = this.searchTable;				
		}
			
	return this.searchTable = searchTable;
}

pageController.prototype.setSearchExpandProgram = function _setSearchExpandProgram()
{
		var searchExpandprogram = "";				
			
		if(this.expandProgram != null && this.expandProgram != "undefined" && this.expandProgram != "" && this.expandProgram != "null")	{					
				searchExpandprogram = this.expandProgram;
		}		
		
		if(searchExpandprogram == null || searchExpandprogram == "undefined" || searchExpandprogram == "" || searchExpandprogram == "null")	{				
			if(this.uniqueExpandProgram != null && this.uniqueExpandProgram != "undefined" && this.uniqueExpandProgram != "" && this.uniqueExpandProgram != "null")			
					searchExpandprogram =  this.uniqueExpandProgram;
		}
		
	return this.expandProgram = searchExpandprogram;
}

pageController.prototype.setSearchRelationship = function _setSearchRelationship()
{
		var searchRelationship = "";				
			
		if(this.relationship != null && this.relationship != "undefined" && this.relationship != "" && this.relationship != "null")	{					
				searchRelationship = this.relationship;
		}		
		
		if(searchRelationship == null || searchRelationship == "undefined" || searchRelationship == "" || searchRelationship == "null")	{				
			if(this.uniqueRelationship != null && this.uniqueRelationship != "undefined" && this.uniqueRelationship != "" && this.uniqueRelationship != "null")			
					searchRelationship =  this.uniqueRelationship;
		}
	
		
	return this.relationship = searchRelationship;
}

pageController.prototype.setSearchSortColumnName = function _setSearchSortColumnName()
{
		var searchSortColumnName = "";				
			
		if(this.sortColumnName != null && this.sortColumnName != "undefined" && this.sortColumnName != "" && this.sortColumnName != "null")	{					
				searchSortColumnName = this.sortColumnName;
		}		
		
		if(this.isContextSearch == "true" || searchSortColumnName == null || searchSortColumnName == "undefined" || searchSortColumnName == "" || searchSortColumnName == "null")	{				
			if(this.uniqueSortColumnName != null && this.uniqueSortColumnName != "undefined" && this.uniqueSortColumnName != "" && this.uniqueSortColumnName != "null")			
					searchSortColumnName =  this.uniqueSortColumnName;
		}		

	return this.sortColumnName = searchSortColumnName;
}

pageController.prototype.setSearchSelection = function _setSearchSelection()
{
		var searchSelection = "";				
			
		if(this.selection != null && this.selection != "undefined" && this.selection != "" && this.selection != "null")	{					
				searchSelection = this.selection;
		}		
		
		if(searchSelection == null || searchSelection == "undefined" || searchSelection == "" || searchSelection == "null" || this.isContextSearch == "true")	{				
			if(this.uniqueSelection != null && this.uniqueSelection != "undefined" && this.uniqueSelection != "" && this.uniqueSelection != "null")			
					searchSelection =  this.uniqueSelection;		
			
		}			
	
	return this.selection = searchSelection;
}

pageController.prototype.giveValuePair = function _giveValuePair(param,value)
{		
		if(value != null && value != "" && value != "undefined" && value != "null") {
			return "&"+param+"="+value;
		 }	else {			
			return "";
		}
}

pageController.prototype.getValuePair = function _getValuePair()
{		
		return this.createValuePair();		
}

pageController.prototype.createValuePair = function _createValuePair()
{					
			this.setSearchTable();
			this.setSearchProgram();
			this.setSearchExpandProgram();
			this.setSearchSelection();
			this.setSearchSortColumnName();
			this.setSearchRelationship();
			
	     var valuePair = "table="+this.searchTable;			
			valuePair += this.giveValuePair("program",this.searchProgram);
			valuePair += this.giveValuePair("expandProgram",this.expandProgram);
			valuePair += this.giveValuePair("relationship",this.relationship);							
			valuePair += this.giveValuePair("selection",this.selection);
			valuePair += this.giveValuePair("sortColumnName",this.sortColumnName);
			valuePair += this.giveValuePair("requestedType",this.requestedType);
			valuePair += this.giveValuePair("hideHeader",this.hideHeader);
			valuePair += this.giveValuePair("hideFooter",this.hideFooter);			
											
			valuePair += this.giveValuePair("freezePane",this.freezePane);
			valuePair += this.giveValuePair("searchType","consolidatedSearch");			
			valuePair += this.giveValuePair("customize","false");			
			valuePair += this.giveValuePair("massUpdate","false");
			valuePair += this.giveValuePair("Export","false");
			valuePair += this.giveValuePair("PrinterFriendly","false");
			valuePair += this.giveValuePair("showClipboard","false");
			valuePair += this.giveValuePair("multiColumnSort","false");	
			valuePair += this.giveValuePair("expandLevelFilter","false");
			valuePair += this.giveValuePair("objectCompare","false");
			valuePair += this.giveValuePair("HelpMarker","false");				
			
		return this.valuePair = valuePair;

}

pageController.prototype.setURLDetails = function __setURLDetails(){ 
	   
	    
		if(this.baseQueryString == "" || this.baseQueryString == null || this.baseQueryString == "undefined")
			return;		

		var paramList = this.baseQueryString.split("&");
		
		for(var i = 0; i < paramList.length ; i++)
		{
			var valuePair = paramList[i].split("=");			
			
			if(valuePair.length == 2)
			{
				var param = valuePair[0];
				var value = valuePair[1];
				
				if(param == "type") continue;
				
				try{								
					eval("this."+param+"="+"value");
				}
				catch(e)
				{	
				}
			}	
			
			
		} 		
	   
}

pageController.prototype.storeUnique = function __storeUnique()
{
	try
	{
		this.setContextSearch(isCONTEXTSEARCH);
		this.setUniqueTable(CONSOLIDATED_UNIQUE_TABLE);
		this.setUniqueProgram(CONSOLIDATED_UNIQUE_PROGRAM);        
		this.setUniqueExpandProgram(CONSOLIDATED_UNIQUE_EXPANDPROGRAM);
		this.setUniqueRelationship(CONSOLIDATED_UNIQUE_RELATIONSHIP);
		this.setUniqueSortColumnName(CONSOLIDATED_UNIQUE_SORTCOLUMNNAME);
		this.setUniqueSelection(CONSOLIDATED_UNIQUE_SELECTION);	
	}catch(e){}
}

pageController.prototype.setSearchType = function __setSearchType(searchType){

	if(searchType != null && searchType != "undefined" && searchType != "" && searchType != "null")
        this.searchType = searchType;        
   
}

pageController.prototype.getSearchType = function __getSearchType(){
	
       return this.searchType;       
   
}

pageController.prototype.setUniqueTable = function __setUniqueTable(uniqueTable){

	if(uniqueTable != null && uniqueTable != "undefined" && uniqueTable != "" && uniqueTable != "null")
        this.uniqueTable = uniqueTable;        
   
}

pageController.prototype.getUniqueTable = function __getUniqueTable(){
	
       return this.uniqueTable;       
   
}

pageController.prototype.setUniqueProgram = function __setUniqueProgram(uniqueProgram){

	if(uniqueProgram != null && uniqueProgram != "undefined" && uniqueProgram != "" && uniqueProgram != "null")
        this.uniqueProgram = uniqueProgram;        
   
}

pageController.prototype.getUniqueProgram = function __getUniqueProgram(){
	
       this.uniqueProgram;       
   
}

pageController.prototype.setTable = function __setTable(table){

	if(table != null && table != "undefined" && table != "" && table != "null")
        this.table = table;       
 
}

pageController.prototype.setProgram = function __setProgram(program){

	if(program != null && program != "undefined" && program != "" && program != "null")
        this.programSetting = program; 
  
}

pageController.prototype.setFunction = function __setFunction(funct){
      
     if(funct != null && funct != "undefined" && funct != "" && funct != "null")
        this.functionSetting = funct;	
}

pageController.prototype.setExpandProgram = function __setExpandProgram(expandprogram){
      if(expandprogram != null && expandprogram != "undefined" && expandprogram != "" && expandprogram != "null")
        this.expandprogram = expandprogram;
}

pageController.prototype.setRelationship = function __setRelationship(relationship){
      if(relationship != null && relationship != "undefined" && relationship != "" && relationship != "null")  
        this.relationship = relationship;
}

pageController.prototype.setSortColumnName = function __setSortColumnName(sortColumnName){
       if(sortColumnName != null && sortColumnName != "undefined" && sortColumnName != "" && sortColumnName != "null") 
        this.sortColumnName = sortColumnName;
}

pageController.prototype.setSelection = function __setSelection(selection){
      if(selection != null && selection != "undefined" && selection != "" && selection != "null")  
        this.selection = selection;
}

pageController.prototype.setContextSearch = function __setContextSearch(isContext){
      if(isContext != null && isContext != "undefined" && isContext != "" && isContext != "null")  
        this.isContextSearch = isContext;
}

pageController.prototype.setUniqueExpandProgram = function __setUniqueExpandProgram(expandprogram){
      if(expandprogram != null && expandprogram != "undefined" && expandprogram != "" && expandprogram != "null")
        this.uniqueExpandProgram = expandprogram;
}

pageController.prototype.setUniqueRelationship = function __setUniqueRelationship(relationship){
      if(relationship != null && relationship != "undefined" && relationship != "" && relationship != "null")  
        this.uniqueRelationship = relationship;
}

pageController.prototype.setUniqueSortColumnName = function __setUniqueSortColumnName(sortColumnName){
       if(sortColumnName != null && sortColumnName != "undefined" && sortColumnName != "" && sortColumnName != "null") 
        this.uniqueSortColumnName = sortColumnName;
}

pageController.prototype.setUniqueSelection = function __setUniqueSelection(selection){
      if(selection != null && selection != "undefined" && selection != "" && selection != "null")  
        this.uniqueSelection = selection;
}


pageController.prototype.setURLProgram = function __setURLProgram(program){
      if(program != null && program != "undefined" && program != "" && program != "null")  
        this.program = program;
}


pageController.prototype.setRequestType = function __setRequestType(requestedType){
       if(requestedType != null && requestedType != "undefined" && requestedType != "" && requestedType != "null") 
        this.requestedType = requestedType;
}

pageController.prototype.setDefaultSearch = function __setDefaultSearch(defaultSearch){
       if(defaultSearch != null && defaultSearch != "undefined" && defaultSearch != "" && defaultSearch != "null") 
        this.defaultSearch = defaultSearch;
}


pageController.prototype.setTableSetting = function __setTableSetting(tableSetting){
       if(tableSetting != null && tableSetting != "undefined" && tableSetting != "" && tableSetting != "null") 
        this.tableSetting = tableSetting;
}

pageController.prototype.setHideHeader = function __setHideHeader(hideHeader){
       if(hideHeader != null && hideHeader != "undefined" && hideHeader != "" && hideHeader != "null")  
        this.hideHeader = hideHeader;
}

pageController.prototype.setHideFooter = function __setHideFooter(hideFooter){
       if(hideFooter != null && hideFooter != "undefined" && hideFooter != "" && hideFooter != "null") 
        this.hideFooter = hideFooter;
}

pageController.prototype.setValuePair = function __setValuePair(valuPair){
	if(valuPair != null && valuPair != "undefined" && valuPair != "" && valuPair != "null") 
        this.valuPair = valuPair;
}

/// End of set Methods:



//showingAdvanced
pageController.prototype.setShowingAdvanced = function __setShowingAdvanced(bln){
        this.showingAdvanced = bln;
}
pageController.prototype.getShowingAdvanced = function __getShowingAdvanced(){
        return this.showingAdvanced;
}
//title
pageController.prototype.setTitle = function __setTitle(txt){
        this.title = txt;
}
pageController.prototype.getTitle = function __getTitle(){
        return this.title;
}
//type
pageController.prototype.setType = function __setType(txt){
        this.type = txt;
}
pageController.prototype.getType = function __getType(){
        return this.type;
}
//searchContentURL
pageController.prototype.setSearchContentURL = function __setSearchContentURL(txt){
        this.searchContentURL = txt;       
        var url = txt.split('?');             
        if(url[1])  {
             this.setBaseQueryString(url[1]);             	
        }   
}
pageController.prototype.getSearchContentURL = function __getSearchContentURL(){
        return this.searchContentURL;
}
//querystring
pageController.prototype.setBaseQueryString = function __setBaseQueryString(txt){
        this.baseQueryString = txt;
        this.setURLDetails();
}
pageController.prototype.getBaseQueryString = function __getBaseQueryString(){
        return this.baseQueryString;
}
//savedSearchName
pageController.prototype.setSavedSearchName = function __setSavedSearchName(txt){
        this.savedSearchName = txt;
}
pageController.prototype.getSavedSearchName = function __getSavedSearchName(){
        return this.savedSearchName;
}
pageController.prototype.clearSavedSearchName = function __clearSavedSearchName(){
        this.savedSearchName = "";
}
//showErrMsg
pageController.prototype.setShowErrMsg = function __setShowErrMsg(bln){
        this.showErrMsg = bln;
}

pageController.prototype.getShowErrMsg = function __getShowErrMsg(){
        return this.showErrMsg;
}
//doReload
pageController.prototype.setDoReload = function __setDoReload(bln){
        this.doReload = bln;
}

pageController.prototype.getDoReload = function __getDoReload(){
        return this.doReload;
}
//doSubmit
pageController.prototype.setDoSubmit = function __setDoSubmit(bln){
        this.doSubmit = bln;
}

pageController.prototype.getDoSubmit = function __getDoSubmit(){
        return this.doSubmit;
}
//arrFormVals
pageController.prototype.clearArrFormVals = function __clearArrFormVals(){
        this.arrFormVals.length = 0;
}

pageController.prototype.addToArrFormVals = function __addToArrFormVals(arrVal){
        this.arrFormVals[this.arrFormVals.length] = arrVal;
}

pageController.prototype.getArrFormValsLength = function __getArrFormValsLength(){
        return this.arrFormVals.length;
}
//This Method sets the window title
pageController.prototype.setWindowTitle = function __setWindowTitle(sTitle){
            if(sTitle) {
                getTopWindow().document.title = STR_SEARCH_TITLE + sTitle;
            }else {
                getTopWindow().document.title = STR_SEARCH_TITLE + this.title;
            }

}
//This Method sets the searchHeader pageHeader text
pageController.prototype.setPageHeaderText = function __setPageHeaderText(sTitle){
        var searchHeader = findFrame(getTopWindow(),"searchHead");               
        var heading = null;         
       
        if(searchHeader && searchHeader.document)        {        
       		heading = searchHeader.document.getElementById("pageHeader");
        }
        else  {
        	heading = document.getElementById("pageHeader");
        }        
        
        if(heading) {
            if(sTitle) {
                heading.innerHTML = STR_SEARCH_TITLE + sTitle;
            }else {
                heading.innerHTML = STR_SEARCH_TITLE + this.title;
            }
        }
}
//This Method sets the helpMarker
pageController.prototype.setHelpMarker = function __setHelpMarker(str){
        this.helpMarker = str;
}
//This Method sets help marker suite directory
pageController.prototype.setHelpMarkerSuiteDir = function __setHelpMarkerSuiteDir(str){
        this.helpMarkerSuiteDir = str;
}
//This Method opens help
pageController.prototype.openHelp = function __openHelp(){
        openHelp(this.helpMarker,this.helpMarkerSuiteDir,STR_SEARCH_LANG,STR_SEARCH_LANG_ONLINE);
}
//This Method sets the queryLimit
pageController.prototype.setQueryLimit = function __setQueryLimit(strNum){
        this.queryLimit = strNum;
}
//This Method gets the queryLimit
pageController.prototype.getQueryLimit = function __getQueryLimit(){
        return this.queryLimit;
}
//This Method sets the pagination
pageController.prototype.setPagination = function __setPagination(strNum){
        this.pagination = strNum;
}
//This Method gets the pagination
pageController.prototype.getPagination = function __getPagination(){
        return this.pagination;
}
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////End PageController Class////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

//This function determines where the search will open.
function findSearchFrame(){
    //arguments[0] is the url of the search page
    //arguments[1] is the targetFrame name
    //arguments[2] is the page title
    //arguments[3] is the commandName
    //arguments[4] is the helpMarker parameter
    //arguments[5] is the helpMarker suiteDir parameter
    //arguments[6] is the toolbar Enhancement Code Usage
   
    //Added for Search Component Consolidated View Feature
    //arguments[7] is the type of search {  Consolidate or General - Default is General }    
    //arguments[8] is the type of search  table setting
    //arguments[9] is the type of search  program setting
    //arguments[10] is the type of search function setting     
   
       
    pageControl = new pageController();
    var toolbar=arguments[0];
	if(toolbar.indexOf("toolbar") != -1)	{
     	toolbar = toolbar.substring(toolbar.indexOf("toolbar"),toolbar.length);
    	 
    	toolbar = toolbar.substring(0,toolbar.indexOf("&"));
    	
    }
    else  {
    	toolbar ="";
    }    
    
    if(arguments.length){
    //debugger
        //determine if the search window is already open
        var targetFrame = findFrame(getTopWindow(),arguments[1]);
        
        //if open target frame
        //TODO change the frame and iframe to proper terminologies.
        if(targetFrame){
        	pageControl.clearChildWindows();
            targetFrame.location.href = arguments[0];
           	if(getTopWindow().consolidatedSearch){
           			if(getTopWindow().turnOnProgressTop)
     					getTopWindow().turnOnProgressTop();    
           			getTopWindow().consolidatedSearch.resetDivs();
					//added for bug 343719
           			getTopWindow().registerEvent();          			
           			getTopWindow().setResize();    
           			pageControl.storeUnique();  	 	 			      
           	}          
            
            //store content url
            pageControl.setSearchContentURL(arguments[0]);
                        
            //disable/enable actions menu items
            setSaveFunctionality((arguments[0].indexOf("emxSearchManage.jsp") == -1));
            
            //is there a title to set?
            if(arguments[2]){
                //store title
                pageControl.setTitle(arguments[2]);
                
                //set window Title
                pageControl.setWindowTitle();
                
                //set Page Header
                pageControl.setPageHeaderText();
            }
            
            //is there a helpMarker to set?
            if(arguments[4]){
               //store the helpMarker
                pageControl.setHelpMarker(arguments[4]); 
            }
            
            //is there a helpMarker suiteDir to set?
            if(arguments[5]){
               //store the helpMarker
                pageControl.setHelpMarkerSuiteDir(arguments[5]); 
            }
             //Setting table
            if(arguments[8]){
               //store the table
                pageControl.setTableSetting(arguments[8]); 
            }
             //Setting program
            if(arguments[9]){
               //store the program
                pageControl.setProgram(arguments[9]); 
            }
             //Setting function
            if(arguments[10]){
               //store the function
                pageControl.setFunction(arguments[10]); 
            }            
        if(getTopWindow().consolidatedSearch)  
            pageControl.createValuePair();
        //else call showNonModal
        }else{
			   var url = arguments[0].split('?'); 
               //Modified the code below to add if and else condition for Toolbar Enhancements code
               if(arguments[6]!=null && "null" != arguments[6])
               {                     
                     if("Consolidate" == arguments[7]){
           			  	  
           			  	  showNonModalSearch("../common/emxSearchConsolidatedView.jsp?defaultSearch=" + arguments[3]+"&"+url[1]+ "&"+arguments[6]+"&"+toolbar);
           			  	 
           		 	  }
					  else 
				      {           		 	             		 		 
           		 		 showNonModalSearch("../common/emxSearch.jsp?defaultSearch=" + arguments[3] + "&"+arguments[6]+"&"+toolbar);
           		 		 pageControl.setSearchType("General");
           			  }              
                  
               }
               else
               {                   
                      if("Consolidate" == arguments[7]){      			  		
           			  		
           			  		showNonModalSearch("../common/emxSearchConsolidatedView.jsp?defaultSearch=" + arguments[3]+"&"+url[1]+"&"+toolbar);
           			  		
           			  }else {
           		 			
           		 			showNonModalSearch("../common/emxSearch.jsp?defaultSearch=" + arguments[3]+"&"+toolbar);
           		 			pageControl.setSearchType("General");
           			  }                  
               }
        }
    } 
}


//This function opens a reusable window
function showNonModalSearch(strURL){
    var sWindowName = strProtocol+strHost+strPort;
    //windowName can contain only alphanumeric or underscore (_) characters
    // replacing all other characters with underscore.
    sWindowName = sWindowName.replace(/\W/g, "_");
    var objWindow = window.open(strURL, "NonModalSearchWindow"+sWindowName,"width=700,height=530,resizable=yes");
    registerChildWindows(objWindow, getTopWindow());
    objWindow.focus();
}

//This function turns on or off save menu items
function setSaveFunctionality(bln){
	var headerFrame = findFrame(getTopWindow(),"searchView");
    //if(headerFrame)    {     
    	//if (headerFrame && headerFrame.toolbars && headerFrame.toolbars.setListLinks) {    		
        //		headerFrame.toolbars.setListLinks(bln);
    	//} 
    	//else
	//if(!isIE){
		
       if (headerFrame && headerFrame.toolbars && headerFrame.toolbars.setListLinks) {   			        
           headerFrame.toolbars.setListLinks(bln);
           parent.ids = bln ? "_dummyids_" : "";
       }
     //}

    //}   

} 
/////////////////// FORM FIELD STORAGE //////////////////////////////////   
//arrFormVals is an Array in the form of
//arrFormVals[i](String "field name", [Array (int,int)] or String "field value")
//where Array (int,int) is an array of selected indexes for select menus
//example
//arrFormVals[0] = new Array("field_1", new Array(1,2,4));

//also this array should maintain the same order of elements
//form[1] should equal arrFormVals[1]

function storeFormVals(){

    //reset array
    pageControl.clearArrFormVals();
    
    //loop through form and store values
    var myForm = arguments[0];
    var formLen = myForm.elements.length;
    for(var i = 0; i < formLen; i++){
        addFormValues(myForm[i]);
    }
}

function addFormValues(formfield){

    //select the appropriate data to save
    switch (formfield.type){
    
        //text fields
        //store value
        case "text" :
        case "textarea" :
        case "hidden" :
            pageControl.addToArrFormVals(new Array(formfield.name,formfield.value,null,formfield.disabled));
        break;
        
        //radio or checkbox
        //store checked boolean
        case "radio" :
        case "checkbox" :
            pageControl.addToArrFormVals(new Array(formfield.name, formfield.value, formfield.checked));
        break;
        
        //select menus
        //store array of selected indexes
        case "select-multiple" :
        case "select-one" :
            var arrSelectValues = new Array();
            for(var i = 0; i < formfield.options.length; i++){
                if(formfield.options[i].selected == true){
                    arrSelectValues[arrSelectValues.length] = new Array(i,formfield.options[i].value);
                }
            }
                
            pageControl.addToArrFormVals(new Array(formfield.name,arrSelectValues));
        break;
        
        default :
            pageControl.addToArrFormVals(new Array(formfield.name,formfield.value));
        break;
        
    }
}
    
function rebuildForm(){

    //if doSubmit use hidden content frame
    //find the form
    var bodyFrame = null;
     var theForm = null;
    if(pageControl.getDoSubmit()){
        bodyFrame = findFrame(getTopWindow(),"searchContent");
    }else{
        bodyFrame = findFrame(getTopWindow(),"searchContent");
    }
    
 	 if (bodyFrame && bodyFrame.contentWindow) { 	 	
 	 	  theForm = bodyFrame.contentWindow.document.forms[0];
 	 	  bodyFrame = bodyFrame.contentWindow; 	 	  	 
 	 }
 	 else if(bodyFrame)  {    
		   theForm = bodyFrame.document.forms[0];
 	 }	 
    
    //for each item in arrFormVals array, based on type check for formfield and set value
    var arrLen = pageControl.getArrFormValsLength();
    if(arrLen != theForm.elements.length && arrLen != theForm.elements.length-1){
        pageControl.setShowErrMsg(true);
    }
    
    
    for(var i = 0; i < arrLen; i++){
        var foundElement = false;
        
        try{
            //get the formfield
            var formElement = bodyFrame.document.getElementsByName(pageControl.arrFormVals[i][NAME]);
            var formElementCount = formElement.length;
            
            for(var j = 0; j < formElementCount; j++){

                switch (formElement[j].type){
                    
                    //text
                    case "text" :
                    case "textarea" :
                    case "hidden" :
                        foundElement = setText(formElement[j], pageControl.arrFormVals[i]);
                    break;
                    
                    //checked
                    case "radio" :
                    case "checkbox" :  
                        foundElement = setChecked(formElement[j], pageControl.arrFormVals[i]);
                    break;                  
                    
                    //select
                    case "select-multiple" :
                    case "select-one" :          
                        foundElement = setSelect(formElement[j], pageControl.arrFormVals[i])
                    break;
                    
                    default:
                        foundElement = true;
                    break;          
                }
                
                //if we found a match break out of loop
                if(foundElement){
                    break;
                }
                
                //if this is the last element and we didn't find
                //a match set Alert
                if(!foundElement && j == formElementCount-1){
                    pageControl.setShowErrMsg(true);
                }
            }
        }catch(e){
                pageControl.setShowErrMsg(true);
        }
    }


    
    if(pageControl.getShowErrMsg()){
        alert(STR_SEARCH_RESAVE_FORM_DATA);
        pageControl.setShowErrMsg(false);
    }
}

function setText(formfield, val){
    if(formfield.name == val[NAME]){
        formfield.value = val[VALUE];
        formfield.disabled = val[DISABLED];
        return true;
    }
    return false;
}

function setChecked(formfield, val){
    if(formfield.name == val[NAME] && (formfield.value == val[VALUE] || formfield.value == unescape(val[VALUE]))){
        formfield.checked = val[CHECKED];
        return true
    }
    return false;
}

function setSelect(formfield, arrOpts){

    if(formfield.name == arrOpts[NAME]){
        //clear current selections
        var formfieldOptsLen = formfield.options.length;
        for(var i = 0; i < formfieldOptsLen; i++){
            formfield.options[i].selected = false;
        }
        //reset
        var arrOptsLen = arrOpts[VALUE].length;
        for(var i = 0; i < arrOptsLen; i++){
            if(formfield.options[arrOpts[VALUE][i][0]].value == arrOpts[VALUE][i][1] || formfield.options[arrOpts[VALUE][i][0]].value == unescape(arrOpts[VALUE][i][1])){
                formfield.options[arrOpts[VALUE][i][0]].selected = true;
            }else{
                return false;
            }
        }
        return true;
    }
    return false;
}
///////////////////////////////////////////////////////////////////

function reviseSearch(){
//debugger
    //if doSubmit use hidden content frame
    var searchViewFrame = null;
    if(pageControl.getDoSubmit()){
        searchViewFrame = findFrame(getTopWindow(),"searchContent");
    }else{
        searchViewFrame = findFrame(getTopWindow(),"searchView");
    }
    //querystring
    var querystring = escape(pageControl.getSearchContentURL());

    var qStr = pageControl.getSearchContentURL();
    qStr = qStr.substring(qStr.indexOf("title"),qStr.length);
    qStr = qStr.substring(0,qStr.indexOf("&"));
    // get searchViewUrl
    var searchViewUrl = "url=" +querystring+"&"+qStr;
    
     if(!searchViewFrame) {
        searchViewFrame = findFrame(getTopWindow(),"searchContent");
        searchViewUrl = pageControl.getSearchContentURL();
     }
  var baseQueryString = pageControl.getBaseQueryString();
    if(baseQueryString.length > 0)
        searchViewUrl +="&" + baseQueryString;
    
    //if hidden submit use only the
    if(pageControl.getDoSubmit()){
        searchViewUrl = pageControl.getSearchContentURL();
    }
    
    pageControl.setDoReload(true);
    //pageControl.setSavedSearchName("");

    //var footerFrame = findFrame(getTopWindow(), "searchFoot");
    //if (footerFrame) {
        var queryLimitObj = getTopWindow().document.getElementById("QueryLimit");
        if (queryLimitObj) {
            sQueryLimit = queryLimitObj.value;
            searchViewUrl += "&queryLimit=" + sQueryLimit;
        }
    //}
    if(searchViewFrame && !pageControl.getDoSubmit()) {   
    var searchQueryParams = searchViewUrl.split("&");
    var searchViewForm = searchViewFrame.document.createElement("FORM");
    for(var i=0;i<searchQueryParams.length;i++){
    	var searchQueryParam = searchQueryParams[i];
    	var searchQueryParamNameValue = searchQueryParam.split("=",2);
    	var searchQueryParamName = searchQueryParamNameValue[0];
    	var searchQueryParamValue = searchQueryParamNameValue[1];
    	
    	var searchQueryParamElem = document.createElement("INPUT");
    	searchQueryParamElem.setAttribute("type","hidden");
    	searchQueryParamElem.setAttribute("name","searchQueryParamName");
    	searchQueryParamElem.setAttribute("value","searchQueryParamValue");
    	searchViewForm.appendChild(searchQueryParamElem);
    }
    searchViewForm.setAttribute("action","../common/emxSearchView.jsp");
    searchViewForm.setAttribute("method","post");
    
    searchViewFrame.document.body.appendChild(searchViewForm);
    searchViewForm.submit();
    }else{
    searchViewFrame.location.href = searchViewUrl;
    }
    //NOTE add footer values
} 

function loadSearchFormFields(){
    setTimeout("checkReloadFlag()",500);
}

function checkReloadFlag(){
    if(pageControl.getDoReload())
        rebuildForm();
        
    if(pageControl.getDoSubmit()){
        //find the form
        var bodyFrame = findFrame(getTopWindow(),"searchContent");
        if(bodyFrame && getTopWindow().doGenericSearch) {        	 	        	
        	getTopWindow().doGenericSearch();        	
        }
        else if(bodyFrame)  {          
        	bodyFrame.doSearch();
        }
        
    }        
        
    pageControl.setDoSubmit(false);    
    pageControl.setDoReload(false);
}

function getAdvancedSearch(bln, objDiv){
    
    //get type
    var emxType = pageControl.getType();
   
    if(emxType == null || emxType == ""){
        alert(STR_SEARCH_SELECT_TYPE);
        return false;
    }
    
    if(!pageControl.getShowingAdvanced() || bln){
        var url = "../common/emxSearchGetAdvanced.jsp?type=" + emxType;
        var myXMLHTTPRequest = emxUICore.createHttpRequest();
        myXMLHTTPRequest.open("GET", url, false);
        myXMLHTTPRequest.send(null);
        
        //write back to div
        objDiv.innerHTML = myXMLHTTPRequest.responseText;
    }  
    return true;      
}

///////////////////// Save Search Functions //////////////////////////////////
//save and save as
function processSaveSearch(){
	if (!verifyQueryLimit()) {
		return false;
	}
    if(pageControl.getSavedSearchName() == ""){
        showModalDialog("../common/emxSearchSaveDialog.jsp", 400, 200,true);
    }else{
        saveSearch(pageControl.getSavedSearchName(), "update");
    }
}  
  
function processSaveAsSearch(){
	if (!verifyQueryLimit()) {
		return false;
	}
	if(getTopWindow().pageControl.getSavedSearchName){
      		var collectionSavedName = getTopWindow().pageControl.getSavedSearchName();
      	}
	var url = "../common/emxSearchSaveAsDialog.jsp";
	if(getTopWindow().pageControl.defaultSearch === "AEFSavedSearches") {
		url += "?collectionSavedName=" + collectionSavedName;
	}
    showModalDialog(url, 400, 325,true);
}

function saveSearch(strName, strSaveType, collectionSavedName)
{
   
    //check that the url is the same in both the pageController and bodyFrame
    //if not then reset
    getTopWindow().validateURL();
    
    //set Saved Search Name
    pageControl.setSavedSearchName(strName);
    
    //build xml doc from formfields
    var xmlData = buildXMLfromForm();
    var url = "../common/emxSearchSaveProcessor.jsp";
        url += "?saveType=" + strSaveType;
        url += "&saveName=" + encodeURIIfCharacterEncodingUTF8(encodeSaveSearchName(strName));
        if(pageControl.defaultSearch === "AEFSavedSearches") {
        	url+= "&collectionSavedName="+encodeURIIfCharacterEncodingUTF8(encodeSaveSearchName(collectionSavedName));
    	}       
        
    
    var oXMLHTTP = emxUICore.createHttpRequest();
    oXMLHTTP.open("post", url, false);
    oXMLHTTP.send(xmlData);
    
    //run tests then...
    return oXMLHTTP.responseText;
}  

function deleteSearch(strName, strSaveType){
    var xmlData = "<root/>"        
    var url = "../common/emxSearchSaveProcessor.jsp";
        url += "?saveType=" + strSaveType;
        url += "&saveName=" + encodeURIIfCharacterEncodingUTF8(encodeSaveSearchName(strName));



    var oXMLHTTP = emxUICore.createHttpRequest();
    oXMLHTTP.open("post", url, false);
    oXMLHTTP.send(xmlData);
    return oXMLHTTP.responseText;
}

function buildXMLfromForm(){
    var NAME = 0;
    var VALUE = 1;
    var CHECKED = 2;
    var contentFrame = findFrame(getTopWindow(), "searchContent");
	var theForm = null;
	if(contentFrame &&  contentFrame.document)	{	
		theForm = contentFrame.document.forms[0];		
	}
	else if(contentFrame &&  contentFrame.contentWindow.document)	{
		theForm = contentFrame.contentWindow.document.forms[0];			
	}    
    //save formData
    storeFormVals(theForm);

    var xmlData = emxUICore.createXMLDOM();
    xmlData.loadXML("<root/>");
    
    //root
    var root = xmlData.documentElement;
    
    //command
    var command = xmlData.createElement("command");
    root.appendChild(command);
    //jsp
    var jsp = xmlData.createElement("jsp");
    root.appendChild(jsp);
    //params
        //for each
    for (var e in pageControl){
        if(!(typeof pageControl[e] == "function" || typeof pageControl[e] == "object")){
            var param = xmlData.createElement("param");
            param.setAttribute("name", e);
            var tn = xmlData.createTextNode(""+pageControl[e]);
            param.appendChild(tn);
            root.appendChild(param);
        }
    }
        
    
    
    //formdata node
    var formData = xmlData.createElement("formData");
    root.appendChild(formData);
    
    //for each arrFormArray
    
    var arrLen = pageControl.getArrFormValsLength();
    for (var i = 0; i < arrLen; i++){
            var formfield = xmlData.createElement("formfield");
            formfield.setAttribute("name", pageControl.arrFormVals[i][NAME]);
            //boolean value?
            if(typeof pageControl.arrFormVals[i][CHECKED] == "boolean"){
                formfield.setAttribute("type", "boolean");
                formfield.setAttribute("checked", pageControl.arrFormVals[i][CHECKED]);
            }else if(typeof pageControl.arrFormVals[i][DISABLED] == "boolean"){
                formfield.setAttribute("type", "string");
                formfield.setAttribute("disabled", (pageControl.arrFormVals[i][DISABLED])?"true":"false");
            }else{
                formfield.setAttribute("type", (typeof pageControl.arrFormVals[i][VALUE]));
            }
            
            //string value
            if(typeof pageControl.arrFormVals[i][VALUE] == "string"){
                    
                //boolean value (checkbox?)
                if(typeof pageControl.arrFormVals[i][CHECKED] == "boolean"){
                    var tn = xmlData.createTextNode(encodeURI(pageControl.arrFormVals[i][VALUE]));
                    formfield.appendChild(tn);
                }else{
                    var tn = xmlData.createTextNode(encodeURI(pageControl.arrFormVals[i][VALUE]));
                    formfield.appendChild(tn);
                }
            }
            
            //object (array) values
            if(typeof pageControl.arrFormVals[i][VALUE] == "object"){
                var objLen = pageControl.arrFormVals[i][VALUE].length;
                for(var j = 0; j < objLen; j++){
                    var valNode = xmlData.createElement("value");
                    var tmpStr = pageControl.arrFormVals[i][VALUE][j][0] + ",\"" + encodeURI(pageControl.arrFormVals[i][VALUE][j][1]) + "\"";

                    var tn = xmlData.createTextNode(tmpStr);
                    valNode.appendChild(tn);
                    formfield.appendChild(valNode);
                }
                
            }
            
            
            //add to formdata
            formData.appendChild(formfield);
    }

    return xmlData.xml;
}

function importSavedSearchXML(strAction){

    //get searchName
    var strName = pageControl.getSavedSearchName();//escape???
    if(trimWhitespace(strName).length == 0){
        alert(STR_SEARCH_EMPTY_NAME);
        return;
    }
    var result = "";
    
    //get xml data
    var url = "../common/emxSearchGetSavedSearch.jsp";
        
        url += "?saveName=" + encodeURIIfCharacterEncodingUTF8(encodeSaveSearchName(strName));

    
    //add a timestamp to prevent caching
    var timestamp = (new Date()).getTime();
        url += "&timestamp=" + timestamp;


    // load the xml file
    var myXMLHTTPRequest = emxUICore.createHttpRequest();
    myXMLHTTPRequest.open("GET", url, false);
    myXMLHTTPRequest.send(null);
    
    //load xml into DOM
    var xmlDoc = emxUICore.createXMLDOM();
    xmlDoc.loadXML(myXMLHTTPRequest.responseText);
    
    //test for valid xml???
    if (isIE) {
            if (xmlDoc.parseError != 0) {
                    findFrame(getTopWindow(),"searchHidden").document.write(myXMLHTTPRequest.responseText);
                    return;
            } 
    } else {
            if (xmlDoc.documentElement.tagName == "parsererror") {
                    findFrame(getTopWindow(),"searchHidden").document.write(myXMLHTTPRequest.responseText);
                    return;
            } 
    }
    if (xmlDoc.documentElement.tagName == "FullSearch"){
		var stuff = xmlDoc.getElementsByTagName("stuff")[0];
		var strJsonStuff = stuff.firstChild.xml;
		var strJsonVal = decodeURIComponent(decodeURIComponent(strJsonStuff));
		var param = eval('(' + strJsonVal + ')');
		var search = param.search;
		var filters = param.filters;
		var objParam = param.objParameter;
		var strObjParam = "";
		for(var paramName in objParam){
			if(objParam[paramName] != null && typeof objParam[paramName] == "string"){
				strObjParam = strObjParam + "&" + paramName + "=" + encodeURIComponent(objParam[paramName]);
			}			
		}
		var strParam = search.replace(/&amp;/g,"&");
		var strFilterJSON = emxUICore.toJSONString(filters).replace(/\"/g,"'");
		var searchURL = "";
		strFilterJSON = strReplaceAll(strFilterJSON,"&amp;","&");
		strFilterJSON = encodeURIComponent(strFilterJSON);
		if(strAction != null && strAction =="edit"){
			searchURL = "../common/emxFullSearch.jsp?showInitialResults=false&"+strParam+"&ftsFilters="+strFilterJSON; 
		}else{
			searchURL = "../common/emxFullSearch.jsp?showInitialResults=true&"+strObjParam+"&ftsFilters="+strFilterJSON;
		}
		 
    	findFrame(getTopWindow(),"_self").document.location.href = searchURL;
        return;
    } 
    
    //store doSubmit
    var localDoSubmit = pageControl.getDoSubmit();
    
    //create new pageController
    pageControl = new pageController();
    
    //reset doSubmit
    pageControl.setDoSubmit(localDoSubmit);
            
    //extract and set pageControl values
    evalTransform(myXMLHTTPRequest, xmlDoc, "../common/emxSearchSetParams.xsl");
    
    //extract and set arrFormVals
    evalTransform(myXMLHTTPRequest, xmlDoc, "../common/emxSearchSetFormArray.xsl");   
    
    //load the saved search
    reviseSearch();
}

function createXSLTProcessor() {
    if (!isIE){
            return new XSLTProcessor();
    }
}

function evalTransform(oHTTPReq ,oXML, strXSLFile){
    //get the xslt file
    oHTTPReq.open("GET", strXSLFile, false);
    oHTTPReq.send(null);
    
    //create DOM
    var xslStylesheet = emxUICore.createXMLDOM();
    
    //load stylesheet
    xslStylesheet.loadXML(oHTTPReq.responseText);
    
    //create the xslt processor
    var xsltProcessor = createXSLTProcessor();
    
    //transform and evaluate
    if(isIE){
            result = oXML.transformNode(xslStylesheet);
            eval(result);
    }else{
            xsltProcessor.importStylesheet(xslStylesheet);
            result = xsltProcessor.transformToDocument(oXML);
            eval(result.documentElement.childNodes[0].nodeValue);
    }
}


function validateURL(){
    //check that the bodyFrame url is the same as the pageController url
    //if different set the pageController url to bodyFrame url
    var bodyFrameURL = null;
    var bodyFrame = findFrame(getTopWindow(),"searchContent"); 
    if(bodyFrame && bodyFrame.document){
    	 bodyFrameURL = bodyFrame.document.location.href;
    }
    else if(bodyFrame) {    	
    	bodyFrameURL = bodyFrame.getAttribute("src");    	
    }  
    var pageControlURL = pageControl.getSearchContentURL();
    if(!compareURLs(pageControlURL,bodyFrameURL)){
        var tmpURL = getRelativeURL(bodyFrameURL);
        if(tmpURL != pageControlURL){
            pageControl.setSearchContentURL(tmpURL);
        }
    }
}

            
function compareURLs(a,b){
    //if there is no ../ in url just return true
    //we don't want to handle this case
    if(a.indexOf("../") == -1){
        return true;
    }
    var url_1 = a.substring(3);     //a holds a relative url "../appName/file.jsp?param=x"
    var iStart = b.indexOf(url_1)   //b holds a full url "http://host/app..."
    if(iStart > -1){
        return (b.substring(iStart) == url_1);
    }
    return false;
}


function getRelativeURL(strURL){
    var url = pageControl.getSearchContentURL();
    var appDir = url.substring(3,url.indexOf("/",3))
    var iStart = strURL.indexOf(appDir);
    if(iStart > -1){
        return "../" + strURL.substring(iStart);
    }
    return url;
}


// This method will clear the value of the field

function clearField(fieldName)
{
	var content = findFrame(window,"searchContent");
	if(content != undefined)
	{
		var field = content.document.getElementsByName(fieldName);
		if(field != null)
		{
			field[0].value = "";
		}
	}
}

function strReplaceAll(str, from, to){
	if(from == to){
		return str;
	}
	if (str != null && str != "") {
		var ind = str.indexOf(from);
		while (ind > -1) {
			str = str.replace(from, to);
			ind = str.indexOf(from);
		}
	}
	return str;
}

