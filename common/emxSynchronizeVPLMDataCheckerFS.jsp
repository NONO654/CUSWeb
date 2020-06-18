<%--  emxSynchronizeVPLMDataCheckerReportFS.jsp   -   FS page display of data checker results
	This FS page is to display results.
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
      @quickreview E25 17:03:22 [Modifications for New UI ].
--%>
<%@ page import="java.util.*" %>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMxIntegrationUtilities"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil" %>
<%@ page import="matrix.db.*"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page import="com.matrixone.jdom.Content" %>
<%@ page import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker" %>


<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="lifecycleBeanNew" class="com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber" scope="session"/>
<%@ include file="../emxUIFramesetUtil.inc"%>
<html>
  <head>
    <title>Collaboration Data Checker</title>
  </head>

  <body bgcolor=white>
 <%
Boolean errorOccured = Boolean.valueOf(false);
String href = "";
String responseXML = "<mxRoot/>";
	String sRelId="";
	String sEBOMPartId ="";
String objectId="";
try
{
	href = "../common/emxTable.jsp?program=emxAEFUtil:getErrorObjectIds&table=AEFGenericDeleteErrorReport&sortColumnName=Type&HelpMarker=emxhelp_deleteerror&header=emxFramework.GenericDelete.ErrorReportHeader&customize=false&Export=true&PrinterFriendly=true&showClipboard=false&multiColumnSort=false&CancelButton=true&CancelLabel=emxFramework.Common.Close&pagination=0&autoFilter=false&TransactionType=update";
    
	boolean isErrorOccured 	= false;
	boolean stopProcess	   	= false;
	boolean rootObject	   	= false;
	String selPartIds[] 		= emxGetParameterValues(request,"emxTableRowId");
		

	objectId    		= emxGetParameter(request,"objectId");
	String sbrootId    		= emxGetParameter(request,"rootId");	
	String language    		= emxGetParameter(request,"Accept-Language");
	String timeStamp   		= emxGetParameter(request,"timeStamp");
	String uiType      		= emxGetParameter(request,"uiType");


	for (int i=0; i < selPartIds.length ;i++){
			StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
			if (strTokens.hasMoreTokens()){
			        objectId= strTokens.nextToken();

				}
		}
	if(uiType == null)
	    uiType = "Table";
		
	HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
	HashMap reqValuesMap    = UINavigatorUtil.getRequestParameterValuesMap(request);
	
	requestMap.put("RequestValuesMap", reqValuesMap); 
	requestMap.put("language",language);
	
	if(uiType != null && "StructureBrowser".equalsIgnoreCase(uiType) && timeStamp != null)
	{		
        HashMap tableData 	= indentedTableBean.getTableData(timeStamp);	    
	    TreeMap indexedList = (TreeMap)tableData.get("IndexedObjectList");	    
	    requestMap.put("IndexedObjectList",indexedList);	   
	    requestMap.put("uiType",uiType);
	
	}
	else if(uiType != null && "table".equalsIgnoreCase(uiType) && timeStamp != null)
	{
	    HashMap tableData   = tableBean.getTableData(timeStamp);	    
	    MapList objectList  = new MapList();	   
	    objectList   = (MapList)tableData.get("ObjectList");	 
	    requestMap.put("ObjectList",objectList);	 
	    requestMap.put("uiType",uiType);


	 

	}




} catch (Exception ex) {   
	if (ex.toString() != null && (ex.toString().trim()).length() > 0)
    	System.out.println(	ex.toString());	
	
}
%>
  
 <%framesetObject fs = new framesetObject();

  final String appDirectory = UINavigatorUtil.getDirectoryProperty("eServiceSuiteEngineeringCentral.Directory");
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPLMSynchro.Success.DataValidate";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPLMSynchroStringResource", request.getHeader("Accept-Language")) ;

  String languageStr = request.getHeader("Accept-Language");
  String contentURL = "emxSynchronizeVPLMDataChecker.jsp?"+"&objectId="+objectId;

  VPLMIntegTraceUtil.trace(context,"emxSynchronizeReportDialogFS:contentURL="+contentURL);

  String HelpMarker = "emxhelpbomsynchronize";
  
  if(titleKey.equals("emxVPLMSynchro.Catalog.Command.SyncWithCatalog.Title"))
	HelpMarker = "emxhelplcsynchronize";
  
  fs.setSuiteKey("VPMCentral");
  
  fs.initFrameset(titleKey, HelpMarker, contentURL,false,true,false,false);

  fs.setStringResourceFile("emxVPLMSynchroStringResource");

  fs.createFooterLink("emxVPLMSynchro.Command.Done",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
  fs.setDirectory(appDirectory);
  


  </body>
</html> 
