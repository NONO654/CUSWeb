<%--  emxCommonSearch.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%!
  //CONSTANTS
  private static final String SEARCH_TABLE_TOOL_BAR = "APPGlobalSearchToolBar";
  private static final String ADDEXISTING_TABLE_TOOL_BAR = "APPGlobalAddExistingToolBar";
  private static final String OBJECTCHOOSER_TABLE_TOOL__BAR = "APPGlobalObjectChooserToolBar";
  private static final String GLOBAL_SEARCH_HEADING = "GlobalSearch.Heading";
  private static final String GLOBAL_SEARCH_HELPMARKER = "GlobalSearch.HelpMarker";
  private static final String GLOBAL_SEARCH_RES_HEADING = "GlobalSearchResult.Heading";
  private static final String GLOBAL_SEARCH_RES_HELPMARKER = "GlobalSearchResult.HelpMarker";
  private static final String ADD_EXISTING_HEADING = "AddExisting.Heading";
  private static final String ADD_EXISTING_RES_HEADING = "AddExistingResult.Heading";
  private static final String OBJECT_CHOOSER_HEADING = "ObjectChooser.Heading";
  private static final String OBJECT_CHOOSER_RES_HEADING = "ObjectChooserResult.Heading";
  private static final String MENU_COMMAND_LIST = "menuCommandList";
  private static final String PAGINATE_RANGE = "emxFramework.PaginationRange";
 %>

 <%
  try
  {
	ContextUtil.startTransaction(context, false);
	String ql = emxGetParameter(request, "queryLimit");
    if(ql == null || "null".equals(ql) || ql.trim().length() == 0)
    ql="100";
    String strMode = emxGetParameter(request, Search.REQ_PARAM_MODE);
	String strMenuName = emxGetParameter(request, Search.REQ_PARAM_MENU_NAME);
    String strCommand = emxGetParameter(request, Search.REQ_PARAM_COMMAND);
    String strSuiteKey = emxGetParameter(request, Search.REQ_PARAM_SUITE_KEY);
    //Reading the "selection" from request
    String strSelection = emxGetParameter(request, Search.REQ_PARAM_SELECTION);
    String strDir = strSuiteKey.toLowerCase();
    //Reading the "SubmitURL" from request
    String strSubmitURL = emxGetParameter(request, Search.REQ_PARAM_SUBMIT_URL);

    Search.basicValidation(request);
    String collection = emxGetParameter(request, "collection");
    String strHelpMarker = emxGetParameter(request, "HelpMarker");

    String strResourceBundle = getResourceBundle(context,application, strSuiteKey);

    String strGlobalSearchHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + GLOBAL_SEARCH_HEADING);
    String strGlobalSearchResultHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + GLOBAL_SEARCH_RES_HEADING);
    String strAddExistingHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + ADD_EXISTING_HEADING);
    String strAddExistingResultHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + ADD_EXISTING_RES_HEADING);
    String strObjectChooserHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + OBJECT_CHOOSER_HEADING);

    String strObjectChooserResultHeading = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + OBJECT_CHOOSER_RES_HEADING);

    String strheader = emxGetParameter(request, "searchheader");
    String objectId =  emxGetParameter(request, "objectId");
        
  
  	String pageTitle="emxFramework.GlobalSearch.Search";
  	pageTitle=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",context.getLocale(), pageTitle);
  	String windowTitle = pageTitle;
  	if(objectId!=null && !objectId.equals("null") && !objectId.equals("")) {
  		pageTitle=UIUtil.getWindowTitleName(context,null,objectId,pageTitle);
  	}

	/* Modified for Replace Requirement functionality. getting the showRevision parameter from the Replace Dialog chooser */
    String strRevision = emxGetParameter(request, "showRevision");
	String pagination = getProperty(context,PAGINATE_RANGE);

    if(strHelpMarker == null || "".equals(strHelpMarker)||"null".equalsIgnoreCase(strHelpMarker)) {
    	String strSearchHelpMarker = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + GLOBAL_SEARCH_HELPMARKER);
    	strHelpMarker=strSearchHelpMarker;
    }
    String strSearchResultHelpMarker = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + GLOBAL_SEARCH_RES_HELPMARKER);

    StringBuffer params = new StringBuffer("&Style=dialog&Export=false&PrinterFriendly=false&pagination=0&listMode=search");
    params.append("&suiteKey="+strSuiteKey);
    params.append("&CancelButton=true");

    StringBuffer sQueryString = new StringBuffer("");

    Enumeration eNumParameters = emxGetParameterNames(request);

    while(eNumParameters.hasMoreElements()) {
    	String strParamName = (String)eNumParameters.nextElement();
        	if(!"jsTreeID".equalsIgnoreCase(strParamName)) {
         		//For multi-valued parameters, we neet to pass on all the values to the target JSP
          		String strParamValues[] = emxGetParameterValues(request, strParamName);
                if (strParamValues != null) {
                	for (int i=0; i<strParamValues.length; i++) {
                    	sQueryString.append(  "&" + strParamName + "=" + strParamValues[i] );
              		}
                }
         	}
    }

    //String strQueryString  = Search.urlEncode(sQueryString.toString());
    String strQueryString  = sQueryString.toString();

    String strHeaderinfo = "";
    if (strMode.equals(Search.ADD_EXISTING)) {
    	strHeaderinfo = strAddExistingHeading;
       	//If "selection" is passed through request, take it else hard-code according to mode
       	if ( (strSelection != null) && (!strSelection.equals("")) ) {
        	params.append("&selection=");
            params.append(strSelection);
        } else {
      		params.append("&selection=multiple");
      	}
      	params.append("&toolbar=" + ADDEXISTING_TABLE_TOOL_BAR);
      	params.append("&header="+strAddExistingResultHeading);
      	//If "SubmitURL" is passed through request, take it else hard-code according to mode
      	if(strSubmitURL!=null&&(!strSubmitURL.equals(""))&&(!strSubmitURL.equals("null"))) {
			params.append("&SubmitURL="+strSubmitURL);
      	} else {
        	params.append("&SubmitURL=../components/emxCommonConnectObjects.jsp");
      	}
      	params.append("&CancelButton=true");
       	params.append("&" + strQueryString);
    } else if (strMode.equals(Search.CHOOSER)){
      	strHeaderinfo = strObjectChooserHeading;
       	//If "selection" is passed through request, take it else hard-code according to mode
       	if ( (strSelection != null) && (!strSelection.equals("")) ) {
        	params.append("&selection=");
            params.append(strSelection);
		} else {
      		params.append("&selection=single");
      	}
      	params.append("&toolbar=" + OBJECTCHOOSER_TABLE_TOOL__BAR);
      	//params.append("&bottomActionbar=" + OBJECTCHOOSER_TABLE_BOTTOM_ACTION_BAR);
      	params.append("&header="+strObjectChooserResultHeading);
      	if(strSubmitURL!=null&&(!strSubmitURL.equals(""))&&(!strSubmitURL.equals("null"))) {
			params.append("&SubmitURL="+strSubmitURL);
      	} else {
        	params.append("&SubmitURL=../components/emxCommonSelectObject.jsp");
      	}
	   	params.append("&CancelButton=true");
	   	params.append("&ShowRevision="+strRevision);
       	params.append("&" + strQueryString);

    } else if (strMode.equals(Search.PERSON_CHOOSER)){
		strHeaderinfo = strObjectChooserHeading;
       	//If "selection" is passed through request, take it else hard-code according to mode
       	if ( (strSelection != null) && (!strSelection.equals("")) ) {
        	params.append("&selection=");
            params.append(strSelection);
		} else {
      		params.append("&selection=single");
      	}
      	params.append("&toolbar=" + OBJECTCHOOSER_TABLE_TOOL__BAR);
      	params.append("&header="+strObjectChooserResultHeading);
        //If "SubmitURL" is passed through request, take it else hard-code according to mode
      	if(strSubmitURL!=null&&(!strSubmitURL.equals(""))&&(!strSubmitURL.equals("null"))) {
			params.append("&SubmitURL="+strSubmitURL);
      	} else {
        	params.append("&SubmitURL=../components/emxCommonSelectPerson.jsp");
      	}
      	params.append("&CancelButton=true");
      	params.append("&" + strQueryString);
    } else if (strMode.equals(Search.GLOBAL_SEARCH)) {
      	strHeaderinfo = strGlobalSearchHeading;
      	params.append("&selection=multiple");
      	params.append("&toolbar=" + SEARCH_TABLE_TOOL_BAR);
      	params.append("&header=" + strGlobalSearchResultHeading);
      	params.append("&CancelButton=true");
      	params.append("&" + strQueryString);
    } else if (strMode.equals(Search.COPY)) {
      	strHeaderinfo = strGlobalSearchHeading;
       	if ((strSelection != null) && (!strSelection.equals(""))) {
        	params.append("&selection=");
            params.append(strSelection);
        } else {
      		params.append("&selection=single");
      	}
      	params.append("&toolbar=APPGlobalAddExistingToolBar");
      	if(strheader!=null&&(!strheader.equals(""))&&(!strheader.equals("null"))) {
      		params.append("&header="+strheader);
      	} else {
      		params.append("&header=emxCommonSearch.Copy");
      	}
      	//If "SubmitURL" is passed through request, take it else hard-code according to mode
      	if(strSubmitURL!=null&&(!strSubmitURL.equals(""))&&(!strSubmitURL.equals("null"))) {
          	params.append("&SubmitURL="+strSubmitURL);
      	} else {
        	params.append("&SubmitURL=../components/emxCommonSearchUtil.jsp?isNewSearch=false");
      	}
      	params.append("&CancelButton=true");
      	params.append("&" + strQueryString);
    } else if (strMode.equals(Search.REPLACE)) {
      	strHeaderinfo = strGlobalSearchHeading;
       	if ( (strSelection != null) && (!strSelection.equals("")) ) {
        	params.append("&selection=");
            params.append(strSelection);
		} else {
      		params.append("&selection=single");
      	}
      	params.append("&toolbar=APPGlobalAddExistingToolBar");
        params.append("&header=emxCommonSearch.Replace");
      	//If "SubmitURL" is passed through request, take it else hard-code according to mode
      	if(strSubmitURL!=null&&(!strSubmitURL.equals(""))&&(!strSubmitURL.equals("null"))) {
			params.append("&SubmitURL="+strSubmitURL);
      	} else {
        	params.append("&SubmitURL=../components/emxCommonSearchUtil.jsp?isNewSearch=false");
      	}
      	params.append("&CancelButton=true");
      	params.append("&" + strQueryString);
    } else if (strMode.equals(Search.ADD_TO_COLLECTION)) {
      	strHeaderinfo = strAddExistingHeading;
       	if ( (strSelection != null) && (!strSelection.equals("")) ) {
        	params.append("&selection=");
            params.append(strSelection);
		} else {
      		params.append("&selection=multiple");
      	}
      	params.append("&toolbar=APPGlobalAddExistingToolBar");
      	params.append("&header="+strAddExistingResultHeading);
      	String timeStamp ="";
      	if (collection != null && !"null".equalsIgnoreCase(collection) && !"".equalsIgnoreCase(collection) &&
          "true".equalsIgnoreCase(collection)) {
        	timeStamp = emxGetParameter(request,"timeStamp");
        	HashMap tableData = tableBean.getTableData(timeStamp);
        	HashMap requestMap = tableBean.getRequestMap(tableData);
        	String sCollectionName  = (String)requestMap.get("treeLabel");
        	String objectName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(sCollectionName);
        	session.putValue("CollectionName", objectName);
      	}
    	String targetProcessPage = emxGetParameter(request,"targetProcessPage");
    	if(targetProcessPage != null && !"null".equals(targetProcessPage) && !targetProcessPage.equals("")) {
      		params.append("&SubmitURL="+targetProcessPage);
      		params.append("&collection="+collection);
      		params.append("&timeStamp="+timeStamp);
      		params.append("&CancelButton=true");
      		params.append("&" + strQueryString);
    	}
  	} else if (strMode.equals(Search.GENERIC)) {
      	strHeaderinfo = strAddExistingHeading;
      	params.append("&CancelButton=true");
      	params.append("&" + strQueryString);
    }

	String strParams = params.toString();
	session.putValue("params",strParams);

    List menuCommandList = Search.getMenuCommandList(application, request, context, strMenuName, (Vector)session.getValue("emxRoleList"), params.toString());

    if (strMode.equals(Search.CHOOSER) || strMode.equals(Search.PERSON_CHOOSER) || strMode.equals(Search.ADD_EXISTING)|| strMode.equals(Search.COPY) || strMode.equals(Search.REPLACE)) {
		List commandList =  Search.getCommandList(context,strCommand,request);

      	menuCommandList = Search.getFilteredCommandListInfo(request, menuCommandList, commandList);
	  	Search.validateMenuCommandList(request, menuCommandList);
    }

    session.removeAttribute(MENU_COMMAND_LIST);
    session.setAttribute(MENU_COMMAND_LIST, menuCommandList);
  	String commandName = emxGetParameter(request, "CommandName");

  	String strHREF = "";
  	int commandIndex = 0;
  	if(commandName != null && commandName.trim().length() != 0) {
    	for (int i = 0; i < menuCommandList.size(); i++) {
      		Map map = (Map)menuCommandList.get(i);

      		String strName = (String)map.get("COMMAND_NAME");
      		if(strName.equals(commandName)) {
        		strHREF = (String)map.get("COMMAND_HREF");
        		commandIndex = i;
      		}
    	}
  	} else {
    	strHREF = Search.getFirstHREF(menuCommandList);
  	}

  	session.putValue("searchHREF",strHREF);
  	String toolbarurl = "../common/emxToolbarJavaScript.jsp?";
  	toolbarurl += "helpMarker=" + strHelpMarker + "&objectId=" + objectId;
  	toolbarurl += "&suiteDir=" + strDir + "&PrinterFriendly=false";
  	toolbarurl += "&suiteKey=" + strSuiteKey;
  	toolbarurl += "&export=false&CurrencyConverter=false";
  
  	StringBuffer topURL = new StringBuffer(1024);
  	topURL.append("emxAppTopPageInclude.jsp").append("?phead=").append(XSSUtil.encodeForURL(context, strHeaderinfo));
  	topURL.append("&strfile=").append(XSSUtil.encodeForURL(context, strResourceBundle));
  	topURL.append("&help=").append(XSSUtil.encodeForURL(context, strHelpMarker));
  	topURL.append("&dir=").append(XSSUtil.encodeForURL(context, strDir));

	String bottomURL = "../common/emxUIGenericSearchFooterPage.jsp";
  	if ((bottomURL.indexOf("%") == -1) && (bottomURL.indexOf("+") == -1)) {
    	bottomURL = FrameworkUtil.encodeURLParamValues(bottomURL);
  	}

  	//Added for Query Limit Implementation
  	bottomURL += "?qlim=100";
%>
<html>
  <head>
    <tite> ENOVIA </title>
    	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script> 
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
	    <script language="javascript" src="../common/scripts/emxUINavBar.js"></script>
	    <script language="javascript" src="../common/scripts/emxUIObjMgr.js"></script>
	    <script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
	    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
	    <script language="javascript" src="../common/scripts/emxUISearchPane.js"></script>
	    <script language="javascript" src="../common/scripts/emxUISearch.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <script language="JavaScript" src="../emxUIPageUtility.js"></script>   
             
        <link href="../common/styles/emxUIDefault.css" rel="stylesheet" />
        <link href="../common/styles/emxUIToolbar.css" rel="stylesheet" />
        <link href="../common/styles/emxUIMenu.css" rel="stylesheet" />
        <link href="../common/styles/emxUIDOMLayout.css" rel="stylesheet" />
        <link href="../common/styles/emxUIDialog.css" rel="stylesheet" />
  <script language="javascript" >
   var objSP = jsSearchPane("emxUISearchPane.css", true);

   function setWindowTitle(){
	   getTopWindow().document.title = "<%=XSSUtil.encodeForJavaScript(context, windowTitle)%>";
   }
   function doSearchOld() {
		var queryLimit = document.bottomCommonForm.QueryLimit.value;
      	var pagination = <%=pagination%>;
      	frames['searchPane'].document.editDataForm.queryLimit.value = queryLimit;
      	frames['searchPane'].document.editDataForm.pagination.value = pagination;
      	frames['searchPane'].document.editDataForm.target = "_top";
      	frames['searchPane'].document.editDataForm.action="../common/emxTable.jsp";
      	frames['searchPane'].document.editDataForm.submit();
   }
   
   function doSearch() {
		var queryLimit = document.bottomCommonForm.QueryLimit.value;
		var pagination = <%=pagination%>;

    	var objForm = frames['searchPane'].document.editDataForm;
    	objForm.target = "_top";

    	if (objForm.SaveQuery) { 
      		var queryId = "";
      		for(var i=0;i<objForm.elements.length;i++) {
        		if(objForm.elements[i].type == "radio" && objForm.elements[i].checked && objForm.elements[i].name =='queryId') {
          			queryId = objForm.elements[i].value;
        		}
      		}
      		if (queryId == "") {
         		alert ("<emxUtil:i18nScript localize='i18nId'>emxFramework.SavedQuery.ALERTPleaseSelectOneQuery </emxUtil:i18nScript>");
        		return;
      		} else {
        		var suiteKey = objForm.suiteKey.value;
        		objForm.action = 'emxSpecSavedQuerySearchProcess.jsp?queryId='+queryId+'&suiteKey='+suiteKey;
      		}
    	} else {
      		objForm.queryLimit.value = queryLimit;
      		objForm.pagination.value = pagination;
      		objForm.action="../components/emxCommonSearchProcess.jsp";
    	}
		if (jsDblClick()) {
			objForm.submit();
       	}
 	}

  	function validateLimit() {
   		var strQueryLimit = document.bottomCommonForm.QueryLimit.value;
    	if (strQueryLimit != "") {
      		if (isNaN(strQueryLimit) == true) {
			<%
        		String strNaNErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeNumeric","emxComponentsStringResource",acceptLanguage);
			%>
        		alert("<%=XSSUtil.encodeForJavaScript(context, strNaNErrorMsg)%>");
        		document.bottomCommonForm.QueryLimit.value = 100;
        		document.bottomCommonForm.QueryLimit.focus();
      		} else if (strQueryLimit > 32767) {
			<%
        		String strLimitSizeErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeLessThan","emxComponentsStringResource",acceptLanguage);
			%>
        		alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsg)%>");
        		document.bottomCommonForm.QueryLimit.value = 100;
        		document.bottomCommonForm.QueryLimit.focus();
      		} else if (strQueryLimit == 0) {
      		<%
        		String strLimitSizeErrorMsgZero = i18nNow.getI18nString("emxComponents.Search.Alert.Zero","emxComponentsStringResource",acceptLanguage);
      		%>
        		alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgZero)%>");
            	document.bottomCommonForm.QueryLimit.value = 100;
            	document.bottomCommonForm.QueryLimit.focus();
      		} else if (strQueryLimit < 0) {
        	<%
        		String strLimitSizeErrorMsgNegative = i18nNow.getI18nString("emxComponents.Search.Alert.Negative","emxComponentsStringResource",acceptLanguage);
			%>
        		alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgNegative)%>");
            	document.bottomCommonForm.QueryLimit.value = 100;
            	document.bottomCommonForm.QueryLimit.focus();
			} else {
           		document.bottomCommonForm.QueryLimit.value = strQueryLimit*1;
            	var decIndex = strQueryLimit.indexOf(".");
            	if(decIndex == -1) {
            		if(parent.searchPane.validateForm) {
                		if(parent.searchPane.validateForm()) {
                    		getTopWindow().doSearch();
                    	}
					} else {
                		getTopWindow().doSearch();
                	}
				}
            	if(decIndex != -1) {
				<%
            		String strLimitSizeErrorMsgDecimal = i18nNow.getI18nString("emxComponents.Search.Alert.Decimal","emxComponentsStringResource",acceptLanguage);
				%>
            		alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgDecimal)%>");
                	document.bottomCommonForm.QueryLimit.value = 100;
                	document.bottomCommonForm.QueryLimit.focus();
				}
 			}
    	} else {
        	if(strQueryLimit == "" || strQueryLimit.length == 0) {
          	<%
          		String strErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeNumeric","emxComponentsStringResource",acceptLanguage);
          	%>
            	alert("<%=XSSUtil.encodeForJavaScript(context, strErrorMsg)%>");
            	document.bottomCommonForm.QueryLimit.focus();
          	} else {
				var decIndex = strQueryLimit.indexOf(".");
              	if(decIndex == -1) {
                	if(parent.searchPane.validateForm) {
                    	if(parent.searchPane.validateForm()) {
                      		getTopWindow().doSearch();
                    	}
                  	} else {
                  		getTopWindow().doSearch();
                	}
               	}
              	if(decIndex != -1) {
                <%
                	String strLimitSizeErrorMsgDecimal2 = i18nNow.getI18nString("emxComponents.Search.Alert.Decimal","emxComponentsStringResource",acceptLanguage);
                %>
                	alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgDecimal2)%>");
                  	document.bottomCommonForm.QueryLimit.value = 100;
                  	document.bottomCommonForm.QueryLimit.focus();
				}
			}
		}
    	return;
	}
  </script>



  </head>
	<body onload="javascript:loadGenericSearchHeader('<%=topURL %>', '<%=XSSUtil.encodeForHTML(context, bottomURL)%>');setWindowTitle();">
		<div id="pageHeadDiv">
	    	<table>
	        	<tr>
	        		<td class="page-title">
	         			<h2 id="ph"></h2>
	        		</td>
	        		<td class="functions">
	        			<table>
	        					<tr>
	        						<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
	        					</tr>
	        			</table>
	        		</td>
	        	</tr>
	        </table>
	        <script language="JavaScript" src="<%=XSSUtil.encodeForHTML(context, toolbarurl)%>" type="text/javascript"></script>
	        <div class="toolbar-container" id="divToolbarContainer">
	        	<div id="divToolbar" class="toolbar-frame"></div>
	        </div>
		</div>
	
	    <div id="divPageBody">
	    	<div id="divSearchPane">
	        	<iframe name="searchBody" src="emxCommonSearchLinks.jsp?searchmode=<%=XSSUtil.encodeForHTML(context, strMode)%>&suiteKey=<%=XSSUtil.encodeForHTML(context, strSuiteKey)%>&commandIndex=<%=commandIndex%>" allowtransparency="true" frameborder="0"></iframe>
	        </div>
	        <div id="divSearchCriteria">
	        	<iframe name="searchPane" src="emxCommonSearchPane.jsp" allowtransparency="true" frameborder="0"></iframe>
	        </div>
		</div>
	   	<div id="divPageFoot"> </div>
	</body>
</html>     
<%
ContextUtil.commitTransaction(context);
} // End of try
catch(Exception ex) {
	ContextUtil.abortTransaction(context);
    session.putValue("error.message", ex.getMessage());
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
