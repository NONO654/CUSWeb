<%--
   C3DMeetingAttachmentsSelectionPage.jsp

   This file is copy of emxTable.jsp, its customized for AutoVue Integration Meeting Support HL.
   This JSP will show a table of attachment list to host of the meeting, he can selcect any one design and start the RTC in AutoVue.
   Copyright (c) 1992-2013 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.ds.enovia.c3d.controller.C3DResourceBundle"%>

<%
	String m_Lang = request.getHeader("Accept-Language");
	String I18NResourceBundle = "c3dIntegrationStringResource";
	C3DResourceBundle c3dResBundle = new C3DResourceBundle(context, m_Lang);		//[xlv:24Nov2014]
	String sSelectDocumentForRTC = c3dResBundle.getString("c3dIntegration.RTC.NoDocumentSelectedForRTC");	

	String meetingURL= emxGetParameter(request, "meetingURL");
	String strMeetingId = emxGetParameter(request, "meetingID");
	String attachmentID= "";
	
	meetingURL +="&action=StartRTC";	
	meetingURL +="&CSI_ClbAction=INIT";
	meetingURL +="&CSI_ClbSessionID=" + strMeetingId;

	System.out.println("[C3D:MeetingAttachmentSelection]: Meeting URL: " + meetingURL);
	System.out.println("[C3D:MeetingAttachmentSelection]: Meeting ID: " + strMeetingId);
%>

<script language="JavaScript">

//Function to launch AV applet in RTC mode for Attachment selected.
function LaunchAVAppletForSelectedDocument()
{
	var selectedIds = this.ids;
	
	if(typeof(selectedIds) == "undefined" || selectedIds == "undefined")
	{
		window.alert("<%=sSelectDocumentForRTC%>");
	}
	else
	{
		var finalURL = "";
		var params = selectedIds.split("|");
		
		if((typeof(params) != "undefined" || params != "undefined") && params.length >= 1)
			{
				for (var i = 0; i<params.length; i++)
				{
					var amppoint = params[i].indexOf("~");
			
					if (amppoint == (params[i].length-1))
					{
						params[i] = params[i].substring(0, amppoint);
						//alert("Attachement file id: " + params[i]);
						finalURL = '<%=meetingURL%>' + "&id=" + params[i];
						break;
					}
				}
				window.location.href = finalURL; 
			}
		}
}

//Function to close Attachment selection Page
function CloseDocSelectionPage()
{
	//[IR-251593V6R2014x]:START
	//IE allows window.close() for windows which are opened through window.open() calls.
	//otherwise it asks for window close confirmation.
	var browserName = navigator.appName;
	var index1 = browserName.indexOf('Explorer');

	if(index1>0)		//for IE.
	{
		var indexVersion = navigator.userAgent.indexOf('MSIE') + 5;
		var browserVersion = navigator.userAgent.substring(indexVersion, indexVersion + 1);
		if(browserVersion >=7)
		{
			window.open('', '_self', '');
			window.close();
		}
		else if (browserVersion == 6)
		{
			window.opener = null;
			window.close();
		}
		else
		{
			window.opener = '';
			window.close();
		}
	}
	else	//for other browsers.
	{
		window.close();
	}
	//[IR-251593V6R2014x]:END
}
</script>

<%
  String tableType = emxGetParameter(request, "tableType");
  if (UIUtil.isNullOrEmpty(tableType)) {
    try {
     // tableType = FrameworkProperties.getProperty(context, "emxFramework.Table.Type"); \\Deprication2 
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
String subHeader = emxGetParameter(request,"subHeader");
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
 String appendParams = "timeStamp=" + timeStamp  + "&portalCmdName=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "portalCmdName")) + "&TransactionType=" +XSSUtil.encodeForURL(context, emxGetParameter(request, "TransactionType"))+"&sortColumnName=" + XSSUtil.encodeForURL(context, strSortColumnName)+"&findMxLink="+XSSUtil.encodeForURL(context, findMxLink)+"&uiType=table" +"&customize="+XSSUtil.encodeForURL(context, strCustomize)+"&multiColumnSort="+XSSUtil.encodeForURL(context, emxGetParameter(request, "multiColumnSort"))+"&showRMB=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "showRMB")) +"&showClipboard="+XSSUtil.encodeForURL(context, strshowClipboard)+"&massPromoteDemote=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "massPromoteDemote"))+"&disableSorting=" + XSSUtil.encodeForURL(context, disableSorting) + "&submitMethod=" + XSSUtil.encodeForURL(context, submitMethod) + "&categoryTreeName=" + XSSUtil.encodeForURL(context, categoryTreeName);
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
    appendParams +=  "&" + currentParameter + "=" + appendString;
}
String tableHeaderURL = "emxTableHeader.jsp?" + appendParams;

String tableportalHeaderURL = "emxTablePortalHeader.jsp?" + appendParams;

String tableBodyURL = "emxTableBody.jsp?" + appendParams;

String tableFootURL = "C3DMeetingAttachmentsTableFooter.jsp?" + appendParams;
String tableportalFootURL = "emxTablePortalFooter.jsp?" + appendParams;
String filterIncludePage = emxGetParameter(request, "FilterFramePage");
boolean addFilterFrame = false;
String filterFrameSize = "-1";
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
//    strCustomizationEnabled = FrameworkProperties.getProperty(context, "emxFramework.UITable.Customization"); //Deprication2
strCustomizationEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.UITable.Customization");

    /* End */

    // Process the request object to obtain the table information and set it in Table bean
    tableBean.setTableInfo(context, pageContext,request, timeStamp, userRoleList);
    hmpTableData = tableBean.getTableData(timeStamp);
    requestMap = tableBean.getRequestMap(hmpTableData);
    requestMap.put("uiType","Table");


    HashMap tableControlMap = tableBean.getControlMap(hmpTableData);
    header = tableBean.getPageHeader(tableControlMap);
    if(objectId !=null &&objectId.compareToIgnoreCase("")!=0 && FrameworkUtil.isObjectId(context,objectId)){
    strTitle=UIUtil.getWindowTitleName(context,null,objectId,null);
    }
    if(header !=  null && header.indexOf(strTitle)!= -1)
    {
        strTitle = header.replace(":","|");
    }
    if(header == null || "".equals(header) || "null".equals(header)) {
        //header = FrameworkProperties.getProperty(context, "emxFramework.Common.defaultPageTitle"); //Deprication2
		header = EnoviaResourceBundle.getProperty(context, "emxFramework.Common.defaultPageTitle");
    }
    ContextUtil.commitTransaction(context);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

}

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
	  if(top.document.location.href.indexOf("emxNavigatorDialog.jsp") >= 0){
	    top.document.title = "<%=strTitle%>";
	  }
	}
        </script>

   <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
    </head>

<body onload="setWindowTitle();adjustBody(<%=XSSUtil.encodeForHTML(context,filterFrameSize)%>);loadFooter();turnOffProgress();" onunload="cleanupSession('<%=timeStamp%>')">
<%
	//Added to append the showRMB and uitype for table for RMB Feature        
        // Get Table Data from session level Table bean
        HashMap tableData = tableBean.getTableData(timeStamp);
        HashMap tableControlMap = tableBean.getControlMap(tableData);
		// IR-052863V6R2011x adding parentOID as param value
        String parentOID = (String)requestMap.get("parentOID");
        String toolbar = (String)requestMap.get("toolbar");
        String relId = (String)requestMap.get( "relId");
        String sHelpMarker = (String)requestMap.get("HelpMarker");
        String inquiryList = (String)requestMap.get("inquiry");
        String inquiryLabel = (String)requestMap.get("inquiryLabel");
        String programList = (String)requestMap.get("program");
        String programLabel = (String)requestMap.get("programLabel");
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

		StringBuffer title = new StringBuffer(50);
		title.append("header_");
		title.append((String)requestMap.get("table"));
		title.append("_");


        if ( (subHeader != null) && (subHeader.trim().length() > 0) ){
        //	String subHeaderSeparator = UINavigatorUtil.getI18nString("emxFramework.CustomTable.Subheader.Separator", //"emxFrameworkStringResource", languageStr);
		String subHeaderSeparator = EnoviaResourceBundle.getProperty(context,"emxFramework.CustomTable.Subheader.Separator", "emxFrameworkStringResource", languageStr);
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

      StringList filterStrList = new StringList();
      StringList filterLabelStrList = new StringList();

        // Get the list of enquiries and label
        if (inquiryList != null && inquiryList.trim().length() > 0 )
        {
            title.append(inquiryList);
            if (inquiryList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(inquiryList, ",");

            if (inquiryLabel != null && inquiryLabel.trim().length() > 0 )
            {
                if (inquiryLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(inquiryLabel, ",");
            }
        } else if (programList != null && programList.trim().length() > 0 )
        {
            title.append(programList);
            if (programList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(programList, ",");

            if (programLabel != null && programLabel.trim().length() > 0 )
            {
                if (programLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(programLabel, ",");
            }
        }

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

%>
	<div id="pageHeadDiv">
<form name="tableHeaderForm">
   
<%
	if(showHeader){
%>
<table>
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
	}
	String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
	if(!filterStrList.isEmpty() || showPortal == false || showHeader==true){
%>
      <td class="functions">
        <table>
              <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>  
<%
	}
    if (filterStrList != null && filterStrList.size() > 1)
    {
%>

                <td class="label"></td>
                <td class="input">
                    <select name="filterTable" onChange="onFilterOptionChange()">
<%
        if (selectedFilter == null || selectedFilter.length() == 0)
            selectedFilter = (String)filterStrList.get(0);

        for (int i=0; i < filterStrList.size(); i++ )
        {
            String optionSelect = "";
            String filterItem = (String)filterStrList.get(i);
            String filterLabel = (String)filterLabelStrList.get(i);

            if (filterLabel != null)
                filterLabel = UINavigatorUtil.parseHeader(context, filterLabel, objectId, suiteKey, Request.getLanguage(request));

            if (filterItem.equalsIgnoreCase(selectedFilter) )
                optionSelect = "selected";

%>
            <option value="<%=XSSUtil.encodeForHTMLAttribute(context, filterItem)%>" <%=optionSelect%> >
			<xss:encodeForHTML><%=filterLabel%></xss:encodeForHTML></option><%
        }
        %>
        </select></td>
<%
    }
%>

        </tr></table>
        </td>
        </tr>
        </table>

<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=toolbar%>"/>
    <jsp:param name="objectId" value="<%=objectId%>"/>
     <jsp:param name="portalMode" value="<%=portalMode%>"/>
    <jsp:param name="relId" value="<%=relId%>"/>
	<jsp:param name="parentOID" value="<%=parentOID%>"/>
	<jsp:param name="parentOID" value="<%=objectId%>"/>
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
            	<iframe name="listFilter" src="emxBlank.jsp" frameborder="0"></iframe>
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
    		<iframe name="listDisplay" src="<%=tableBodyURL%>" width="100%" height="80%"  frameborder="0" border="0" onload="javascript:loadFilterPage('<%=filterIncludePage%>');"></iframe>
<%
} else {
%>        
	       	<iframe name="listDisplay" src="<%=tableBodyURL%>" width="100%" height="80%"  frameborder="0" border="0"></iframe>

<%
}
%> 
            <iframe class="hidden-frame" name="listHidden" src="emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>
            <iframe class="hidden-frame" name="postHidden" src="emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>
</div>

<div id="divPageFoot">

</div>

</body>
    </html>
<%
}

//UIUtil.logConfigurations(context, request, requestMap);
%>
