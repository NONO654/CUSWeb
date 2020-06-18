<%--  smaXMLMove.jsp   - "
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.framework.ui.PreProcessCallable"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%-- 
<%@include file=  "../components/emxSearchInclude.inc"%>
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%! 
boolean updateMaps(Map tableData, Map requestMap, Map programMap){
    final String SPLIT_CHAR = "\\";
    if (tableData == null || requestMap == null || programMap == null)
    {
        return false;
    }
    String xmlTableTag = (String) requestMap.get("xmlTableTag");
    String emxTableRowId = null;
    String[] ids = null;
    String rowID = null;
    if ("ExportRules".equalsIgnoreCase(xmlTableTag) || "DeleteRules".equalsIgnoreCase(xmlTableTag) || 
        "ImportRules".equalsIgnoreCase(xmlTableTag))
    {
        String parentOID = (String) requestMap.get("parentOID");
        
        if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        } else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        String stepId = ids[2];
        requestMap.put("setpID", stepId);
        String simId = ids[3];

        emxTableRowId = (String) requestMap.get("emxTableRowId");
        if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = emxTableRowId.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        } else if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = emxTableRowId.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        rowID = ids[0];
        requestMap.put("rowID", rowID);
        requestMap.put("parentOID", simId);
    } else if ("ParameterList".equalsIgnoreCase(xmlTableTag))
    {
        emxTableRowId = (String) requestMap.get("emxTableRowId");
        if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = emxTableRowId.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        } else if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = emxTableRowId.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        rowID = ids[0].replaceAll("\\|", "");
        requestMap.put("rowID", rowID);
    } else if ("Attributes".equalsIgnoreCase(xmlTableTag))
    {
        emxTableRowId = (String) requestMap.get("emxTableRowId");
        if (emxTableRowId.contains("|"))
        {
            ids = emxTableRowId.split("\\|");
        } 
        rowID = ids[1];
        requestMap.put("rowID", rowID);
        requestMap.put("parentOID", (String) requestMap.get("objectId"));
    } else if ("Steps".equalsIgnoreCase(xmlTableTag))
    {
        emxTableRowId = (String) requestMap.get("emxTableRowId");
        if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = emxTableRowId.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        } else if (emxTableRowId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = emxTableRowId.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        rowID = ids[2].replaceAll("\\|", "");
        requestMap.put("setpID", rowID);
    }else if ("Options".equalsIgnoreCase(xmlTableTag))
	{
    	requestMap.put("parentOID", (String) requestMap.get("objectId"));
		return true;
	}
    if (rowID != null)
        return true;
    else
        return false;
} 
%> 

<%
String timeStamp = emxGetParameter(request, "timeStamp");
Map tableData = (Map)tableBean.getTableData(timeStamp);
tableData = tableData == null ? indentedTableBean.getTableData(timeStamp) : tableData;
Map requestMap = (Map) UINavigatorUtil.getRequestParameterMap(pageContext);
String moveAction = emxGetParameter(request, "moveAction");

if ( (moveAction == null) || (moveAction.equals("")) )
{
    moveAction = "";
}

String tableRowId[] = request.getParameterValues("emxTableRowId");
String ruleID = "";
if ( (tableRowId == null) || (tableRowId.length == 0) )
{

}
else
    ruleID = tableRowId[0];

//requestMap.put("", "");
String errMsg = "";
String strPreJPOName = null;
String strPreMethodName = null;
String preProcessJpo = emxGetParameter(request, "preProcessJPO");

// look to see if there is a pre process jpo and if so invoke it
if (preProcessJpo != null)
{
    strPreJPOName = preProcessJpo.substring(0, preProcessJpo.indexOf(":"));
    strPreMethodName = preProcessJpo.substring(preProcessJpo.indexOf(":") + 1, preProcessJpo.length());
}
try 
{ 
  if ( (strPreJPOName != null) && (strPreJPOName.length() > 0) 
      && (strPreMethodName != null) && (strPreMethodName.length() > 0) )
  {
      // invoke the pre-process jpo if present
    Map inputMap = new HashMap();
    inputMap.put("rowID", ruleID);
    inputMap.put("moveAction", moveAction);
    inputMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
    inputMap.put("tableData", tableData);
    FrameworkUtil.validateMethodBeforeInvoke(context, strPreJPOName, strPreMethodName, "PREPROCESS");
    JPO.invoke(context, strPreJPOName, new String[0], strPreMethodName, JPO.packArgs(inputMap));
  }

} 
catch (Exception exJPO)
{
    errMsg =  MessageServices.massageMessage(exJPO.getMessage());
    emxNavErrorObject.addMessage(errMsg);
}

// continue processing only if there is no problem
// get the move jpo method
if (errMsg == null || errMsg.length() == 0)
{
	String strMoveJPO = emxGetParameter(request, "moveJPO");
	String strJPOName = null;
	String strMethodName = null;
	if (strMoveJPO != null)
	{
	  strJPOName = strMoveJPO.substring(0, strMoveJPO.indexOf(":"));
	  strMethodName = strMoveJPO.substring(strMoveJPO.indexOf(":") + 1, strMoveJPO.length());
	}
	
	try 
	{ 
	  if ( (strJPOName != null) && !(strJPOName.equals("")) 
	        && (strMethodName != null) && !(strMethodName.equals("")) )
	  {
	      // invoke the move jpo if present
	    Map inputMap = new HashMap();
	    inputMap.put("rowID", ruleID);
	    inputMap.put("moveAction", moveAction);
	    inputMap.put("requestMap", requestMap);
	    inputMap.put("tableData", tableData);
	    boolean isInvoke = updateMaps(tableData, requestMap, inputMap);
	    if (isInvoke)
	    JPO.invoke(context, strJPOName, new String[0], strMethodName, JPO.packArgs(inputMap));
	  }
	
	} 
	catch (Exception exJPO)
	{
	    errMsg =  MessageServices.massageMessage(exJPO.getMessage());
	    emxNavErrorObject.addMessage(errMsg);
	}
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


<%
if (errMsg == null || errMsg.length() == 0)
{
%>

<script language="Javascript">

    var myFrame = findFrame(getTopWindow(), "_self");
    if(myFrame)
    	myFrame.parent.location.href = myFrame.parent.location.href;

</script>

<%
}
%>
