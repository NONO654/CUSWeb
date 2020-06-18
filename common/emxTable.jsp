<%-- emxTable.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>
<%@include file = "emxNavigatorCheckReadAccess.inc"%>
<%@page import  ="com.matrixone.apps.domain.util.MqlUtil"%>
<%



if(UINavigatorUtil.isMobile(context)) {
	//In Mobile devices, we render Classic table as SB. And, the parameter names are inconsitent. i.e., in CT submitLabel is used as SubmitLabel. 
	// in 14x, remove this block and unify these parameter names in both classic table and SB
	String submitLabel = emxGetParameter(request, "SubmitLabel");
	String cancelLabel = emxGetParameter(request, "CancelLabel");
	String submitURL = emxGetParameter(request, "SubmitURL");
	//XSSOK: forward is not a new request.
%>
<!-- //XSSOK -->
	<jsp:forward page="emxIndentedTable.jsp"> <jsp:param name="submitLabel" value="<%=submitLabel %>"/> <jsp:param name="cancelLabel" value="<%=cancelLabel %>"/> <jsp:param name="submitURL" value="<%=submitURL %>"/>
	</jsp:forward>
<%
}
%>
<%@include file = "../emxTagLibInclude.inc"%>
<%
  String tableType = emxGetParameter(request, "tableType");
  if (UIUtil.isNullOrEmpty(tableType)) {
    try {
      tableType = EnoviaResourceBundle.getProperty(context, "emxFramework.Table.Type");
      if (tableType.equalsIgnoreCase("classic") == false && tableType.equalsIgnoreCase("new") == false)
        throw new Exception();
    }
    catch (Exception e) {
      tableType = "classic";
    }
  }
  if (tableType.equalsIgnoreCase("new")) {
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    requestMap = UINavigatorUtil.appendURLParams(context, requestMap, "StructureBrowser");
    // do this so silverlight callback to emxIndentedTable will get table def
    requestMap.put("tableType", "new");
    StringBuffer buf = new StringBuffer();
    for (Map.Entry ent : (java.util.Set<Map.Entry>)requestMap.entrySet()) {
      buf.append("&");
      buf.append(ent.getKey());
      buf.append("=");
      buf.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(ent.getValue().toString()));
    }
    String url = "emxIndentedTable.jsp?" + buf;
    response.sendRedirect(url);
    return;
  }
%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil,
				com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers,
                com.matrixone.apps.domain.util.XSSUtil" 
%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String portalMode = emxGetParameter(request, "portalMode");
String listMode = emxGetParameter(request, "listMode");
String findMxLink = emxGetParameter(request, "findMxLink");
String showTabHeader = emxGetParameter(request, "showTabHeader");
//User Defined Table
String strCustomize = emxGetParameter(request,"customize");

// Added for passing the parameter showClipboard to all tables
String strshowClipboard = emxGetParameter(request,"showClipboard");
String timeStamp = tableBean.getTimeStamp();
String strCustomizationEnabled ="enable";
String objectId = "";
objectId=emxGetParameter(request, "objectId");
String header = "";
String strTitle="";
String pageTitle="";
HashMap hmpTableData = null;
Vector userRoleList = PersonUtil.getAssignments(context);

String strSortColumnName = emxGetParameter(request, "sortColumnName");
String disableSorting =  emxGetParameter(request, "disableSorting");
String submitMethod = request.getMethod();
 //End User Defined Table
// Collect all the parameters passed-in and forward them to Table frames.

//modified for 310470 (forwarding parameter TransactionType)
//String appendParams = "timeStamp=" + timeStamp + "&portalCmdName=" + emxGetParameter(request, "portalCmdName") + "&TransactionType=" +emxGetParameter(request, "TransactionType")+"&sortColumnName=" + strSortColumnName+"&findMxLink="+findMxLink+"&uiType=table" +"&customize="+strCustomize+"&multiColumnSort="+emxGetParameter(request, "multiColumnSort")+"&showRMB=" + emxGetParameter(request, "showRMB");
 //Added to append the showRMB and uitype for table for RMB Feature
 String categoryTreeName =  emxGetParameter(request, "categoryTreeName");
 String treemode =  emxGetParameter(request, "treemode");
 String appendParams = "timeStamp=" + XSSUtil.encodeForURL(context, timeStamp)  + "&portalCmdName=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "portalCmdName")) + "&TransactionType=" +XSSUtil.encodeForURL(context, emxGetParameter(request, "TransactionType"))+"&sortColumnName=" + XSSUtil.encodeForURL(context, strSortColumnName)+"&findMxLink="+XSSUtil.encodeForURL(context, findMxLink)+"&uiType=table" +"&customize="+XSSUtil.encodeForURL(context, strCustomize)+"&multiColumnSort="+XSSUtil.encodeForURL(context, emxGetParameter(request, "multiColumnSort"))+"&showRMB=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "showRMB")) +"&showClipboard="+XSSUtil.encodeForURL(context, strshowClipboard)+"&massPromoteDemote=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "massPromoteDemote"))+"&disableSorting=" + XSSUtil.encodeForURL(context, disableSorting) + "&submitMethod=" + XSSUtil.encodeForURL(context, submitMethod) + "&categoryTreeName=" + XSSUtil.encodeForURL(context, categoryTreeName);
 if(treemode != null && "structure".equals(treemode)){
	 String isRoot =  emxGetParameter(request, "isRoot");
	 appendParams += "&treemode=structure&isRoot=" + XSSUtil.encodeForURL(context, isRoot);
 }
 if("true".equalsIgnoreCase(emxGetParameter(request, "isStructure"))){
     appendParams += "&isStructure=true";
 }
//modified for bug 299547
String otherToolbarParameters = emxGetParameter(request, "otherToolbarParameters");
StringList toolbarParameters = FrameworkUtil.splitString(otherToolbarParameters,",");
for(int i = 0; i < toolbarParameters.size(); i++){
    String currentParameter = (String)toolbarParameters.get(i);
    String[] parameterValues = emxGetParameterValues(request, currentParameter);
    String appendString = "";
    if(parameterValues != null ) {
      for(int j = 0; j < parameterValues.length; j++){
          if(j==0){
              appendString += (String)parameterValues[j];
          }else{
              appendString += "~sep~" + XSSUtil.encodeForURL(context, (String)parameterValues[j]);
          }
      }
    }
    appendParams +=  "&" + XSSUtil.encodeForURL(context, currentParameter) + "=" + XSSUtil.encodeForURL(context, appendString);
}
String tableHeaderURL = "emxTableHeader.jsp?" + appendParams;

String tableportalHeaderURL = "emxTablePortalHeader.jsp?" + appendParams;

String tableBodyURL = "emxTableBody.jsp?" + appendParams;

String tableFootURL = "emxTableFooter.jsp?" + appendParams;
String tableportalFootURL = "emxTablePortalFooter.jsp?" + appendParams;
String filterIncludePage = emxGetParameter(request, "FilterFramePage");
boolean addFilterFrame = false;
String filterFrameSize = "0";
if (filterIncludePage != null)
{
    addFilterFrame = true;
    filterFrameSize = emxGetParameter(request, "FilterFrameSize");
    String filterAppendParams = "tableID=" + timeStamp;
    filterIncludePage = UINavigatorUtil.encodeURL(context, (String)filterIncludePage + "?" + filterAppendParams);
    
    if (filterFrameSize == null)
        filterFrameSize = "40";
}

// Check for transaction type passed in (needed to save ".finder" during a query)
//
HashMap requestMap=null;
String transactionType = emxGetParameter(request, "TransactionType");
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));
try {

    /* Added for User Defined Table */
    ContextUtil.startTransaction(context, updateTransaction);
    strCustomizationEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.UITable.Customization");

    /* End */

    // Process the request object to obtain the table information and set it in Table bean
    tableBean.setTableInfo(context, pageContext,request, timeStamp, userRoleList);
    hmpTableData = tableBean.getTableData(timeStamp);
    requestMap = tableBean.getRequestMap(hmpTableData);
    requestMap.put("uiType","Table");
    
 	// Not required for User tables since it is not specific to admin roles
 	boolean isUserTable = (Boolean) requestMap.get("userTable");
    if(!isUserTable){
    	String passedTable = (String)requestMap.get("table");
    	String accessUsers = MqlUtil.mqlCommand(context, "print table $1 system select $2 dump", passedTable, "property[AccessUsers].value");
    	if(UIUtil.isNotNullAndNotEmpty(accessUsers)) {
    		if(!PersonUtil.hasAnyAssignment(context, accessUsers)) {
    		    return;
    		}
    	}
    }


    HashMap tableControlMap = tableBean.getControlMap(hmpTableData);
    header = tableBean.getPageHeader(tableControlMap);
    StringList objectNTR = new StringList();
    if(objectId !=null &&objectId.compareToIgnoreCase("")!=0 && FrameworkUtil.isObjectId(context,objectId)){
    	strTitle=UIUtil.getWindowTitleName(context,null,objectId,null, true);
	    objectNTR = com.matrixone.apps.domain.util.StringUtil.split(strTitle, " ");
    }
	if(header !=  null && objectNTR.size() > 0 && header.indexOf((String)objectNTR.get(0))!= -1)
    {
		String tempHeader = header.replace((String)objectNTR.get(0),strTitle);
        strTitle = tempHeader.replace(":","|");
    }
    if(header == null || "".equals(header) || "null".equals(header)) {
        header = EnoviaResourceBundle.getProperty(context, "emxFramework.Common.defaultPageTitle");
    }
    ContextUtil.commitTransaction(context);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

}

boolean isNS = UINavigatorUtil.isNS(context,request);

/* Added for User Defined Table */
try
{
  if((strCustomize!=null && "true".equalsIgnoreCase(strCustomize)) || (strCustomize==null && "enable".equalsIgnoreCase(strCustomizationEnabled))||("".equalsIgnoreCase(strCustomize) && "enable".equalsIgnoreCase(strCustomizationEnabled)))
  {
      String strTableName = (String)requestMap.get("table");
      if(strTableName!=null && !strTableName.equals(""))
        tableBean.setCurrentTable(context,strTableName);
  }
}
catch(Exception ex)
{
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
/* End */

String suiteKey = (String)requestMap.get("suiteKey");
boolean showPortal = false;
if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
    showPortal = true;
}
boolean showHeader = true;
if((showTabHeader == null ||!"true".equalsIgnoreCase(showTabHeader)) && showPortal ){
    showHeader= false; 
}
if(listMode != null && "search".equalsIgnoreCase(listMode))
{
    showPortal = false;
}
if(UIUtil.isNullOrEmpty(header))
	pageTitle = strTitle;
else
	pageTitle = header;
String Style = emxGetParameter(request, "Style");
if(Style != null && "PrinterFriendly".equalsIgnoreCase(Style))
{
%>
    <jsp:include page = "emxTableReportView.jsp" flush="true">
        <jsp:param name="TransactionType" value="<%=transactionType%>"/>
        <jsp:param name="timeStamp" value="<%=timeStamp%>"/>
    </jsp:include>
<%
}
else
{
%>
    
<html>
    <head>
    <title><xss:encodeForHTML><%=strTitle%></xss:encodeForHTML></title>
    <%@include file = "emxUIConstantsInclude.inc"%>
  	<script language="JavaScript" type="text/javascript" src="scripts/emxUIToolbar.js"></script>
	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
    <%@include file = "emxNavigatorTimerBottom.inc"%>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    <%@include file = "../emxStyleDefaultInclude.inc"%>
        <script type="text/javascript">
			var footerurl = '<%=tableFootURL%>';
        	addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUIDOMLayout");
<%
			if(showPortal){
%>
				addStyleSheet("emxUIChannelDefault");
<%
			}
%>
	function setWindowTitle(){
	  if(getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp") >= 0){
		  var strTitle =  "<xss:encodeForJavaScript><%=strTitle%></xss:encodeForJavaScript>";
		  if(strTitle.indexOf("$<APPNAME>") != -1){
				getTopWindow().document.title = strTitle.replace("$<APPNAME>", getContentWindow().applicationProductInfo.appName);
			} else {
				getTopWindow().document.title = strTitle;
			}
	  }
	}
        </script>

   <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
    </head>
<%
boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
if(isIE){
%>
<body onload="setWindowTitle();adjustBody(<%=XSSUtil.encodeForJavaScript(context, filterFrameSize)%>);loadFooter();turnOffProgress();" onunload="cleanupSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>')">
<%
}else{
%>
	<body onload="setWindowTitle();adjustBody(<%=XSSUtil.encodeForHTML(context, filterFrameSize)%>);loadFooter();turnOffProgress();" onbeforeunload="cleanupSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>')">
<%}
	//Added to append the showRMB and uitype for table for RMB Feature
        
        // Get Table Data from session level Table bean
        
        HashMap tableData = tableBean.getTableData(timeStamp);
		//Add program filter if present
        tableBean.setProgramFilter(context, requestMap,tableData,timeStamp);
        HashMap tableControlMap = tableBean.getControlMap(tableData);
		// IR-052863V6R2011x adding parentOID as param value
        String parentOID = (String)requestMap.get("parentOID");
		if(UIUtil.isNullOrEmpty(parentOID)){
			parentOID = objectId;
		}
        String toolbar = (String)requestMap.get("toolbar");
        String relId = (String)requestMap.get( "relId");
        String sHelpMarker = (String)requestMap.get("HelpMarker");

        String selectedFilter = (String)requestMap.get("selectedFilter");
        String topActionbar = (String)requestMap.get("topActionbar");
        String bottomActionbar = (String)requestMap.get("bottomActionbar");
        String objectCompare=(String)requestMap.get("objectCompare");
        String selection=(String)requestMap.get("selection");
        String objectBased=(String)requestMap.get("objectBased");
        String tipPage = (String)requestMap.get("TipPage");
        String printerFriendly = (String)requestMap.get("PrinterFriendly");
        String showPageURLIcon = (String)requestMap.get("showPageURLIcon");
        String export = (String)requestMap.get("Export");
        String style = (String)requestMap.get("Style");
        String languageStr = Request.getLanguage(request);
        String editLink = (String)requestMap.get("editLink");
        String triggerValidation = (String)requestMap.get("triggerValidation");
        String subHeader = (String)requestMap.get("subHeader");

                StringBuffer title = new StringBuffer(50);
                title.append("header_");
                title.append((String)requestMap.get("table"));
                title.append("_");


        if ( (subHeader != null) && (subHeader.trim().length() > 0) ){
        	String subHeaderSeparator = UINavigatorUtil.getI18nString("emxFramework.CustomTable.Subheader.Separator", "emxFrameworkStringResource", languageStr);
        	StringList subHeaderList = FrameworkUtil.split(subHeader, subHeaderSeparator);
        	StringBuffer subHeaderBuffer = new StringBuffer();

        	for(int x = 0; x < subHeaderList.size(); x++){
        		if(x > 0) subHeaderBuffer.append(" ").append(subHeaderSeparator).append(" ");
        		subHeaderBuffer.append(UINavigatorUtil.parseHeader(context, pageContext, (String)subHeaderList.get(x), objectId, suiteKey, languageStr));
        	}
        	subHeader = subHeaderBuffer.toString();
        	//
        }

        boolean bExport = true;
        if ("false".equals(export))
            bExport = false;


        String registeredSuite = suiteKey;

        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        {
            registeredSuite = suiteKey.substring(13);
        }

        boolean hasNumericColumn = tableBean.hasNumericColumnForCalculations(context, tableData);
        boolean showChartIcon = hasNumericColumn;
        boolean showCalcIcon = hasNumericColumn;

        String calculations = (String)requestMap.get("calculations");
        if(calculations != null && "false".equalsIgnoreCase(calculations)) {
            showCalcIcon = false;
        }

        String chart = (String)requestMap.get("chart");
        if(chart != null && "false".equalsIgnoreCase(chart)) {
            showChartIcon = false;
        }
        String isFromIFWE = (String) session.getAttribute("isFromIFWE");
        if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE)){
        	showHeader = false;
        }
		
		
%>
	<div id="pageHeadDiv">
<form name="tableHeaderForm">
   
<%
	if(showHeader){
%>
<table id ="contentHeader">
     <tr>
    <td class="page-title">
      <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
<%
      if(subHeader != null && !"".equals(subHeader)) {
%>
        <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
<%
        }
%>
    </td>
<%
	String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
	if( showPortal == false || showHeader==true){
%>
      <td class="functions">
        <table>
              <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>  
<%
	}
   
%>
        </tr></table>
        </td>
        </tr>
        </table>
<%
	}
%>
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=toolbar%>"/>
    <jsp:param name="objectId" value="<%=objectId%>"/>
     <jsp:param name="portalMode" value="<%=portalMode%>"/>
    <jsp:param name="relId" value="<%=relId%>"/>
	<jsp:param name="parentOID" value="<%=parentOID%>"/>
    <jsp:param name="timeStamp" value="<%=timeStamp%>"/>
    <jsp:param name="editLink" value="<%=editLink%>"/>
    <jsp:param name="header" value="<%=header%>"/>
    <jsp:param name="PrinterFriendly" value="<%=printerFriendly%>"/>
    <jsp:param name="showPageURLIcon" value="<%=showPageURLIcon%>"/>
    <jsp:param name="export" value="<%=export%>"/>
	<jsp:param name="submitMethod" value="<%=request.getMethod()%>"/>  
    <jsp:param name="showChartOptions" value="<%=showChartIcon%>"/>
    <jsp:param name="showTableCalcOptions" value="<%=showCalcIcon%>"/>

    <jsp:param name="uiType" value="table"/>
    <jsp:param name="helpMarker" value="<%=sHelpMarker%>"/>
    <jsp:param name="tipPage" value="<%=tipPage%>"/>
    <jsp:param name="suiteKey" value="<%=registeredSuite%>"/>
    <jsp:param name="topActionbar" value="<%=topActionbar%>"/>
    <jsp:param name="bottomActionbar" value="<%=bottomActionbar%>"/>
    <jsp:param name="AutoFilter" value="<%=tableBean.hasAutoFilterColumn(timeStamp)%>"/>
    <jsp:param name="CurrencyConverter" value="<%=tableBean.hasCurrencyUOMColumn(timeStamp)%>"/>
    <jsp:param name="objectCompare" value="<%=objectCompare%>"/>
    <jsp:param name="objectBased" value="<%=objectBased%>"/>
    <jsp:param name="selection" value="<%=selection%>"/>
    <jsp:param name="selectedFilter" value="<%=selectedFilter%>"/>
    <jsp:param name="findMxLink" value="<%=findMxLink%>"/>
	<jsp:param name="customize" value="<%=strCustomize%>"/>
	<jsp:param name="triggerValidation" value="<%=triggerValidation%>"/>

</jsp:include>
<%
if (addFilterFrame) {
%>
            <div id="divListFilter">
            	<iframe name="listFilter" frameborder="0"></iframe>
            </div>
<%
	}
%>
</form>
</div><!-- /#pageHeadDiv -->
        <div id="divPageBody">
<%
if (addFilterFrame) {
%>
          		<iframe name="listDisplay" src="<%=tableBodyURL%>" width="100%" height="100%"  frameborder="0" border="0" onload="javascript:loadFilterPage('<xss:encodeForJavaScript><%=filterIncludePage%></xss:encodeForJavaScript>');"></iframe>
<%
} else {
%>        
          	<iframe name="listDisplay" src="<%=tableBodyURL%>" width="100%" height="100%"  frameborder="0" border="0"></iframe>
<%
}
%> 
            <iframe class="hidden-frame" name="listHidden" HEIGHT="0" WIDTH="0"></iframe>
            <iframe class="hidden-frame" name="postHidden" HEIGHT="0" WIDTH="0"></iframe>
</div>
        <div id="divPageFoot">
</div>
</body>
    </html>
<%
}


%>
