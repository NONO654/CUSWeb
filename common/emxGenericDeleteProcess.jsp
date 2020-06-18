<%--  emxGenericDeleteProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxGenericDeleteProcess.jsp.rca 1.7.3.3 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.output.*"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="lifecycleBeanNew" class="com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber" scope="session"/>
<%
Boolean errorOccured = Boolean.valueOf(false);
String href = "";
String responseXML = "<mxRoot/>";

try
{
	href = "../common/emxTable.jsp?program=emxAEFUtil:getErrorObjectIds&table=AEFGenericDeleteErrorReport&sortColumnName=Type&HelpMarker=emxhelp_deleteerror&header=emxFramework.GenericDelete.ErrorReportHeader&customize=false&Export=true&PrinterFriendly=true&showClipboard=false&multiColumnSort=false&CancelButton=true&CancelLabel=emxFramework.Common.Close&pagination=0&autoFilter=false&TransactionType=update";
    
	boolean isErrorOccured 	= false;
	boolean stopProcess	   	= false;
	boolean rootObject	   	= false;
	String memberIds[] 		= emxGetParameterValues(request,"emxTableRowId");		
	String objectId    		= emxGetParameter(request,"objectId");
	String sbrootId    		= emxGetParameter(request,"rootId");	
	String language    		= emxGetParameter(request,"Accept-Language");
	String timeStamp   		= emxGetParameter(request,"timeStamp");
	String uiType      		= emxGetParameter(request,"uiType");	
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
 
	String[] methodargs = JPO.packArgs(requestMap);	
	Map resultMap = null;
	         
	try 
	{
	    resultMap = (Map) JPO.invoke(context, "emxAEFUtil", null, "deleteSelectedObjects",methodargs, Map.class);
	} catch (Exception exJPO) 
	{		                   
	    throw (new FrameworkException(exJPO.toString()));
	}  
	
	errorOccured     		= (Boolean) resultMap.get("errorOccured");	
	StringList erroredList  = (StringList) resultMap.get("erroredList");
	
	if(uiType != null && "StructureBrowser".equalsIgnoreCase(uiType))
	{		
	   responseXML	 = (String)resultMap.get("responseXML");
	}
	else if(uiType != null && "table".equalsIgnoreCase(uiType))
	{
	   MapList objectList  = (MapList)resultMap.get("ObjectList");	
	   HashMap tableData   = tableBean.getTableData(timeStamp);	
	   tableData.put("ObjectList",objectList);
	   tableBean.setTableData(timeStamp,tableData);
	   tableBean.setFilteredObjectList(timeStamp,objectList);
	   responseXML = "<mxRoot/>";
	}
	
	StringList taskList = lifecycleBeanNew.getClientTasks(context);	
	String xml 			= com.matrixone.apps.domain.util.FrameworkUtil.join(taskList,"");	
	HashMap tempMap 	= lifecycleBeanNew.getErrorMap(xml);	
	String errorxml		= null;
	if(errorOccured.booleanValue()) {
	    errorxml 		= lifecycleBeanNew.createAndSaveErrorXML(context,erroredList,tempMap);
	}
    href += "&errorxml="+errorxml;
    context.clearClientTasks();
	
} catch (Exception ex) {   
	if (ex.toString() != null && (ex.toString().trim()).length() > 0)
    	emxNavErrorObject.addMessage(ex.toString().trim());		
	
}

%>

<html>
<head> 
<script language="JavaScript" src="scripts/emxUICore.js"></script> 
<script type="text/javascript" language="javascript">


//XSSOK
var responseXML  = "<%=responseXML%>";

function registerEvent()
{
	var contentWindow = getTopWindow().modalDialog.contentWindow;
 	if(isIE && isMaxIE10 && contentWindow)	
		contentWindow.attachEvent("onunload" , refresh);
	else if(contentWindow)
		contentWindow.addEventListener("unload" , refresh,false);
}

function refresh() 
{

 if(parent.removedeletedRows){
  	  parent.removedeletedRows(responseXML);
	  return;
  }
  
 if(parent.refreshTableData){	 
	  parent.refreshTableData();
	  return;
 }	
 
  if(getTopWindow().refreshTablePage){	 
	  getTopWindow().refreshTablePage();
	  return;
 }	
}
</script>

<script type="text/javascript" language="javascript">
parent.turnOffProgress();
<%if(errorOccured.booleanValue()) { %> 	 
	    getTopWindow().showModalDialog("<%=href%>", 600, 500, "true");	 	  		
	 	setTimeout("registerEvent()",150);	 		
<%	} else { %>  
		refresh();
<%} %>		
	
</script>
</head>
<body>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
