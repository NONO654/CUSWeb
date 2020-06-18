<%--  emxSearchConsolidatedView.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchConsolidatedView.jsp.rca 1.13.3.2 Wed Oct 22 15:48:26 2008 przemek Experimental przemek $
--%>

<%@ page import="java.util.*,java.io.*,com.matrixone.jdom.*,com.matrixone.jdom.output.*"%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
	String _href 				= "";
	String _helpMarker 			= "";
	String _helpMarkerSuiteDir 	= "";
	String _title 				= "";
	String _uniqueTable 		= "";
	String _searchType 			= "";	
	String _tableSetting 		= "";
	String _programSetting 		= "";   		
	String _function 			= "";   
	String _queryLimit 			= "";
	String _upperQueryLimit 	= "";
	String _submitLabel 		= "";
	String _applyLabel			= "";
	String _regSuite	   		= "";
	
	String _selection 			= "multiple";
	String _sortColumnName 		= "";   
	String _relationship 		= "";
	String _expandProgram 		= "";
	String _program      		= "";    
	
	String _doSearch 	 		= "";
	String _selectObject  		= "";
	String _callbackError 		= "";
	String _addedCallback		= "";
	String _searchButtonValue	= "";
	String _enoviaSearch		= "";
	String _collection			= "";
	String _clipboardCollection = "";
	// Added for Bug 346329
	String _doSearchCompare     = "";
	String _doSearchExport 		= "";
	String _doSearchPrinter		= "";
%>


<jsp:useBean id="consolidatedSearchBean" class="com.matrixone.apps.framework.ui.UISearch" scope="session"/>
<%
	boolean _submitLink			= true;
	boolean _applyLink			= true;
	boolean _enableApply		= false;
	boolean _enableDone 		= false;
	boolean	_isContextSearch	= false;
	String _language = request.getHeader("Accept-Language");
	//defaultSearch command to display the Search Criteria section
	String defaultSearch 	= emxGetParameter(request,"defaultSearch");
	String toolbar 		 	= emxGetParameter(request,"toolbar");
	String callbackFunction = emxGetParameter(request,"callbackFunction");	
	String strsubmitLink 	= emxGetParameter(request,"submitLink");
	String strapplyLink  	= emxGetParameter(request,"applyLink");	
	String showAdvanced  	= emxGetParameter(request, "showAdvanced");	
	String bReload 		 	= emxGetParameter(request,"bReload"); 
	String transactionType  = emxGetParameter(request, "TransactionType");
		   _uniqueTable     = emxGetParameter(request, "table");
		   _applyLabel      = emxGetParameter(request, "applyLabel");
		   _submitLabel     = emxGetParameter(request, "submitLabel");
			
		   _program 		= emxGetParameter(request, "program");		   
		   _selection       = emxGetParameter(request, "selection");
		   _sortColumnName  = emxGetParameter(request, "sortColumnName");
		   _relationship    = emxGetParameter(request, "relationship");
		   _expandProgram 	= emxGetParameter(request, "expandProgram");
	// Get the collection name to add it in session variable
	String strCollectionName = emxGetParameter(request,"CollectionName");
	
	if(showAdvanced == null || "".equals(showAdvanced)||"null".equals(showAdvanced)){
         showAdvanced = "false";
 	} 	
 	
	if("false".equals(strsubmitLink)){
   	 	_submitLink=false;
	}
	if("false".equals(strapplyLink)){
    	_applyLink = false;
	}	
	
	if(callbackFunction != null){
	    
	    _isContextSearch = true;
	   
	    if(_applyLink)
	        _enableApply = true;
		else
			 _enableApply = false;

	    if(_submitLink)
	        _enableDone = true;
		else
			_enableDone = false;
	}	
	
	boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));

	if(defaultSearch == null || "null".equals(defaultSearch) || "".equals(defaultSearch)){	
   	 	defaultSearch = "AEFGeneralSearch";
	}
	if(toolbar == null || "null".equals(toolbar) || "".equals(toolbar))	{
    	toolbar = "AEFSearchConsolidatedToolbar";
	}
	

try {
    ContextUtil.startTransaction(context, updateTransaction);    
    
    HashMap hashMap = consolidatedSearchBean.getCommandDetails(context,defaultSearch);    
    
    MapList commandList = new MapList();
    commandList.add(hashMap);
    
    UIToolbar.translateAndEncode(context, commandList, null, null,request.getHeader("Accept-Language"));   
    
     _href				    = UIToolbar.getHRef(hashMap);    
    _title 	        		= UIToolbar.getLabel(hashMap);      
    _regSuite 	    	    = UIToolbar.getSetting(hashMap,"Registered Suite");   
    _searchType  		    = UIToolbar.getSetting(hashMap,"Search Type");
    _tableSetting 	   		= UIToolbar.getSetting(hashMap,"table");
    _program     		    = UIToolbar.getSetting(hashMap,"program");
    _function     	        = UIToolbar.getSetting(hashMap,"function");
    _helpMarker    			= UIToolbar.getSetting(hashMap,"Help Marker");
    
    
    if (_href != null && !"".equals(_href)&& !"null".equals(_href)) {        
        if(_href.indexOf("?") != -1)
        	_href = _href + "&CollectionName="+strCollectionName;
        else
           _href = _href + "?CollectionName="+strCollectionName;
    } 
    // Added for Bug no 346725
    _href = FrameworkUtil.encodeURLParamValues(_href);
    // Till here
    if(_helpMarker == null || "".equals(_helpMarker) ||"null".equals(_helpMarker)){
        _helpMarker = "";
    }
    if(_searchType == null || "".equals(_searchType)||"null".equals(_searchType)){
        _searchType = "Consolidated";
	} 
    if (_regSuite != null && !"".equals(_regSuite)&& !"null".equals(_regSuite)) {
        _helpMarkerSuiteDir = UINavigatorUtil.getRegisteredDirectory(context,_regSuite);
    }  
    
    if(_helpMarkerSuiteDir == null || "".equals(_helpMarkerSuiteDir)||"null".equals(_helpMarkerSuiteDir)){
   	 	_helpMarkerSuiteDir = "common";
    } 
    
    if(_title == null || "".equals(_title)||"null".equals(_title)){
        _title = "General";
	}     
    
    _queryLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.QueryLimit");
    if( (_queryLimit == null) || ("null".equals(_queryLimit)) || ("".equals(_queryLimit))) {
        _queryLimit="100";
    }

    _upperQueryLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.UpperQueryLimit");
    if( (_upperQueryLimit == null) || ("null".equals(_upperQueryLimit)) || ("".equals(_upperQueryLimit))) {
        //this number must not excede 32767
        _upperQueryLimit="1000";
    } 
    
    if(_submitLabel != null && !"".equals(_submitLabel )){
        _submitLabel = EnoviaResourceBundle.getProperty(context, _regSuite, _submitLabel, _language);
    }
    
    if(_applyLabel != null && !"".equals(_applyLabel )) {
        _applyLabel = EnoviaResourceBundle.getProperty(context, _regSuite, _applyLabel, _language);
    }
 
    
    if(_submitLabel == null ||  "".equals(_submitLabel) || "null".equals(_submitLabel))
        _submitLabel  = UINavigatorUtil.getI18nString("emxFramework.Consolidate.Button.Done","emxFrameworkStringResource",_language);
    
    if(_applyLabel == null || "".equals(_applyLabel) || "null".equals(_applyLabel))
        _applyLabel  = UINavigatorUtil.getI18nString("emxFramework.Consolidate.Button.Apply","emxFrameworkStringResource",_language);
    
     _doSearch 	    = UINavigatorUtil.getI18nString("emxFramework.Consolidate.DoSearch","emxFrameworkStringResource",_language);
     _selectObject   = UINavigatorUtil.getI18nString("emxFramework.Consolidate.SelectSearch","emxFrameworkStringResource",_language);
     _callbackError = UINavigatorUtil.getI18nString("emxFramework.Consolidate.CallbackError","emxFrameworkStringResource",_language);
     _addedCallback = UINavigatorUtil.getI18nString("emxFramework.Consolidate.AddedCallback","emxFrameworkStringResource",_language);
     
     _searchButtonValue = UINavigatorUtil.getI18nString("emxFramework.Consolidate.Button.Search","emxFrameworkStringResource",_language);
     _enoviaSearch		= UINavigatorUtil.getI18nString("emxFramework.Login.Title","emxFrameworkStringResource",_language);
     
     
     _collection 	      = UINavigatorUtil.getI18nString("emxFramework.Collections.Collections","emxFrameworkStringResource",_language);
     _clipboardCollection = UINavigatorUtil.getI18nString("emxFramework.ClipBoardCollection.NameLabel","emxFrameworkStringResource",_language);
     
     // Added for Bug 346329
     _doSearchCompare 	= UINavigatorUtil.getI18nString("emxFramework.Consolidate.DoSearchCompare","emxFrameworkStringResource",_language);
     _doSearchExport 	= UINavigatorUtil.getI18nString("emxFramework.Consolidate.DoSearchExport","emxFrameworkStringResource",_language);
     _doSearchPrinter 	= UINavigatorUtil.getI18nString("emxFramework.Consolidate.DoSearchPrinter","emxFrameworkStringResource",_language);
    
     
     _enoviaSearch	= _enoviaSearch +"  "+ _searchButtonValue + ": " + _title;
    ContextUtil.commitTransaction(context);
    // End: Get Data
	} 
catch (Exception ex) 
{
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
        emxNavErrorObject.addMessage(ex.toString().trim());
        %>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    <%
    }
}

%>

<html>
<head>
	 
	<script language="JavaScript" src="scripts/emxUIConstants.js"></script>
    <script language="JavaScript" src="scripts/emxUICore.js"></script>
    <script language="JavaScript" src="scripts/emxUISearchConsolidatedUtils.js"></script>
    <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
    <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>   
    <script language="JavaScript" src="scripts/emxUIModal.js"></script>    
    <script language="JavaScript" src="scripts/emxUISearch.js"></script>      
       
	<script type="text/javascript" language="JavaScript" src="scripts/emxUIModal.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUIPopups.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxSearchGeneral.js"></script>
	<script language="JavaScript" src="scripts/emxUISearchUtils.js" type="text/javascript"></script>
   	<%@ include file="emxSearchConstantsInclude.inc"%>
   	<%@include file = "emxUIConstantsInclude.inc"%>
    <script type="text/javascript">
	addStyleSheet("emxUIContainedInSearch");
	addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIDialog.css");   
	</script>
  <script type="text/javascript">
  
  	// To set the current criteria href to the pageController . which is used in emxUISearch.js resetSearchCriteria method
		
   var CONSOLIDATED_UNIQUE_TABLE          = "<xss:encodeForJavaScript><%=_uniqueTable%></xss:encodeForJavaScript>";
   var CONSOLIDATED_UNIQUE_PROGRAM  	  = "<xss:encodeForJavaScript><%=_program%></xss:encodeForJavaScript>";
   var CONSOLIDATED_UNIQUE_EXPANDPROGRAM  = "<xss:encodeForJavaScript><%=_expandProgram%></xss:encodeForJavaScript>";
   var CONSOLIDATED_UNIQUE_SORTCOLUMNNAME = "<xss:encodeForJavaScript><%=_sortColumnName%></xss:encodeForJavaScript>";
   var CONSOLIDATED_UNIQUE_RELATIONSHIP	  = "<xss:encodeForJavaScript><%=_relationship%></xss:encodeForJavaScript>";
   var CONSOLIDATED_UNIQUE_SELECTION	  = "<xss:encodeForJavaScript><%=_selection%></xss:encodeForJavaScript>"; 
   //XSSOK
   var CONSOLIDATED_ADDED_CALLBACK        ="<%=_addedCallback%>";
   
   //XSSOK
   var ALERT_DO_SEARCH					  ="<%=_doSearch%>";   
   //XSSOK
   var ALERT_SELECT_OBJECT				  ="<%=_selectObject%>"; 
   //XSSOK
   var ALERT_CALLBACK_ERROR   			  ="<%=_callbackError%>"; 
   
   //XSSOK
   var COLLECTIONS						  ="<%=_collection%>";
   //XSSOK
   var CLIPBOARD_COLLECTIONS			  ="<%=_clipboardCollection%>";
   
   //XSSOK
   var isCONTEXTSEARCH					  ="<%=_isContextSearch%>";
   
   // Added for Bug 346329
   
   //XSSOK
   var ALERT_DO_SEARCHCOMPARE			  = "<%=_doSearchCompare%>";
   //XSSOK
   var ALERT_DO_SEARCHEXPORT			  ="<%=_doSearchExport%>";
   //XSSOK
   var ALERT_DO_SEARCHPRINTER			  = "<%=_doSearchPrinter%>";
 
	if(pageControl)
	{
	   	pageControl.setUniqueTable(CONSOLIDATED_UNIQUE_TABLE);
		pageControl.setUniqueProgram(CONSOLIDATED_UNIQUE_PROGRAM);        
		pageControl.setUniqueExpandProgram(CONSOLIDATED_UNIQUE_EXPANDPROGRAM);
		pageControl.setUniqueRelationship(CONSOLIDATED_UNIQUE_RELATIONSHIP);
		pageControl.setUniqueSortColumnName(CONSOLIDATED_UNIQUE_SORTCOLUMNNAME);
		pageControl.setUniqueSelection(CONSOLIDATED_UNIQUE_SELECTION);		
		pageControl.setSearchContentURL("<%=_href%>");//XSSOK    
        pageControl.setDefaultSearch("<xss:encodeForJavaScript><%=defaultSearch%></xss:encodeForJavaScript>");
        //XSSOK
        pageControl.setHelpMarker("<%= _helpMarker %>");
        pageControl.setShowingAdvanced("<xss:encodeForJavaScript><%= showAdvanced %></xss:encodeForJavaScript>");
        pageControl.setTitle("<xss:encodeForJavaScript><%=_title%></xss:encodeForJavaScript>");            
        //XSSOK
        pageControl.setHelpMarkerSuiteDir("<%= _helpMarkerSuiteDir %>");
        //XSSOK
        pageControl.setTableSetting("<%=_tableSetting %>");	 
        pageControl.setProgram("<xss:encodeForJavaScript><%=_program%></xss:encodeForJavaScript>");	
        pageControl.setFunction("<xss:encodeForJavaScript><%=_function%></xss:encodeForJavaScript>");        
        //XSSOK
        pageControl.setSearchType("<%=_searchType%>");
        pageControl.createValuePair();
        pageControl.setWindowTitle();
        	  		
	}
	
	<%-- These i18n strings must come before emxUISearchUtils.js --%>

   //i18n strings 
   var QueryLimitNumberFormat = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitNumberFormat</emxUtil:i18nScript>";
   //XSSOK
   var QueryLimitMaxAllowed = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitMaxAllowed</emxUtil:i18nScript> <%= _upperQueryLimit %>";
  
   //XSSOK
   var upperQueryLimit = <%= _upperQueryLimit %>;  
  
   emxUICore.addEventHandler(window, "load", enablesave);   
   emxUICore.addEventHandler(window, "load", load);       

	function submitList(strURL, strTarget, strRowSelect, bPopup, iWidth, iHeight, confirmationMessage, strMethod) {	
		consolidatedSubmitList(strURL, strTarget, strRowSelect, bPopup, iWidth, iHeight, confirmationMessage, "post");
	} 
	
	function turnOffProgressTop() {		
      if((document.getElementById('imgProgressDiv')) != null) {
          document.getElementById('imgProgressDiv').style.visibility = 'hidden';
      }else {
          setTimeout("turnOffProgressTop()", 500);
       }
    }
		
	function turnOnProgressTop() {		
      if((document.getElementById('imgProgressDiv')) != null)   {
          document.getElementById('imgProgressDiv').style.visibility = 'visible';
      }else{
     	  setTimeout("turnOnProgressTop()", 500);
     }    
   }   
  
    function load()  {  	
  		setTimeout("consolidatedSearch.init()",400);  		
  		//XSSOK
  		setTimeout("enableDone('<%=_enableDone%>')",500);
		//XSSOK
		setTimeout("enableApply('<%=_enableApply%>')",500);
  		setTimeout("consolidatedSearch.setCallback('<xss:encodeForJavaScript><%=callbackFunction%></xss:encodeForJavaScript>')",500);	
   }
    
   </script>
   <link rel="stylesheet" href="styles/emxUISearchConsolidated.css"/>    	
</head>

<body scrollbar="no" border="0" onload="setSize();turnOffProgress();"> 
	<form name="emxSearchComponentForm" >
	 <div id="searchHead">		
		 <table border="0" width="100%" cellspacing="0" cellpadding="0" >
		 	<caption><img src="images/utilSpacer.gif" width="1" height="8"/></caption>           	     	
          	<tr> 
          		<td style="visibility:hidden;"><img src="images/utilSpacer.gif" width="1" height="1"/></td>          		     		    		
            	<td width="1%" nowrap class="pageHeader"><span class="pageHeader" id="pageHeader"><%=_enoviaSearch %></span></td>
            	<td nowrap class="pageHeader"><div id="imgProgressDiv">&nbsp;&nbsp;&nbsp;<img src="../common/images/utilProgressBlue.gif" width="34" height="28" name="progress" align=absmiddle/></div></td>
                <td style="visibility:hidden;"><img src="images/utilSpacer.gif" width="1" height="1"/></td>  
            </tr>
         </table>	
					
			<div id="searchToolbarDiv"> 
					<table border="0" cellspacing="2" cellpadding="0" width="100%">
						<tr>
							<td width="99%">
								<jsp:include page = "emxToolbar.jsp" flush="true">
									<jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>    								
    								<jsp:param name="export" value="true"/>
   								 	<jsp:param name="PrinterFriendly" value="true"/>
   								 	<jsp:param name="uiType" value="ConsolidatedSearch"/>
   								 	<jsp:param name="searchType" value="Consolidated"/>
   								 </jsp:include>    							
      						</td>
      					</tr>
      				</table>
      		</div>
		</div> 
		
		<div id="searchCriteriaDiv" >
			<iframe style="width:100%;height:100%"  src="<%=_href%>" id="searchContent" name="searchContent" frameborder="no" marginwidth="0" marginheight="0">
			</iframe>			
		</div>
		<div id="searchActionBarDiv" style="visibility:visible;height:30px;bottom:30px">
			<table align="right">
				<tr valign="middle">
					<td>
						<emxUtil:i18n localize="i18nId">emxFramework.Consolidate.Button.LimitTo</emxUtil:i18n><input type="textbox" size="3" name="QueryLimit" id="QueryLimit" value="<%=_queryLimit%>" /> <emxUtil:i18n localize="i18nId">emxFramework.Consolidate.Button.Results</emxUtil:i18n></input>
					</td>
					<td>&nbsp;&nbsp;</td>
					<td>
						<input onclick="doCheckboxState(this);" type="checkbox" id="searchCheck" name="searchCheck"><img border="0" src="images/iconRetainedSearch.gif"/><emxUtil:i18n localize="i18nId">emxFramework.Consolidate.Button.Retainselectedresults</emxUtil:i18n></input>	
					</td>	
					<td>&nbsp;&nbsp;</td>	
					<td>
						<input type="button" id="searchButton" name="searchButton" value="<%=_searchButtonValue %>" onclick="doConsolidatedFind();"/>	
					</td>
					<td>&nbsp;&nbsp;</td>
				</tr>
			</table>
		</div> 
		
		<div id="searchGrabberDiv" style="visibility:visibile" onMouseDown="setDragging(this);" onMouseUp="stopDragging(this);" >
		
		</div>
		
		<div id="searchResultsDiv"  onmouseup="stopDragging()" style="visibility:hidden;z-index:2">
			<iframe onMouseUp="stopDragging(this);" src="emxBlank.jsp" name="searchResults" id="searchResults" style="position:absolute;width:100%;height:100%" border="0" frameborder="0">
			
			</iframe> 		
		</div>
		<div id="searchFooterDiv">
            <table border="0" cellspacing="0" cellpadding="0"  align="right">
              	<tr>
              		<td>&nbsp;&nbsp;</td>
                	<td id="callbackAppyImage" style="visibility:hidden" ><a href="javascript:getTopWindow().doApply();"><img border="0" src="images/buttonDialogApply.gif" /></a></td>
                	<td id="callbackAppyText" style="visibility:hidden" nowrap>&nbsp;<a class="button" href="javascript:getTopWindow().doApply();"><xss:encodeForHTML><%=_applyLabel %></xss:encodeForHTML></a></td>

              		<td>&nbsp;&nbsp;</td>
                	<td id="callbackDoneImage" style="visibility:hidden"><a href="javascript:getTopWindow().doDone();"><img border="0" src="images/buttonSearchDone.gif"/></a></td>
                	<td id="callbackDoneText" style="visibility:hidden" nowrap>&nbsp;<a class="button" href="javascript:getTopWindow().doDone();"><xss:encodeForHTML><%=_submitLabel %></xss:encodeForHTML></a></td>
              					
                	<td>&nbsp;&nbsp;</td>
                	<td><a href="javascript:getTopWindow().closeWindow()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>" src="images/buttonSearchCancel.gif"/></a></td>
                	<td nowrap>&nbsp;<a class="button" onClick="javascript:getTopWindow().closeWindow()"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></a></td>
                			
              	</tr>
            </table>
	 </div>	 
  </form>  
  <iframe src="emxBlank.jsp" width="0" height="0" style="visibility:hidden;display:none;width=0px;height=0px" name="searchHidden" id="searchHidden"  border="0" frameborder="0"></iframe>
</body>
</html>

