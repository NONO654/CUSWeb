<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating new documents
--%>

<%@page import = "java.util.HashMap, java.util.Map, matrix.util.StringList"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "matrix.db.*, matrix.util.*"%>
<%@page import="matrix.db.Context" %>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>
<%@page import = "java.util.Enumeration"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>


<%
//get the tableDataMap and the requestMap from the table bean
String timeStamp = emxGetParameter(request, "timeStamp");
HashMap tableDataMap = (HashMap) tableBean.getTableData(timeStamp);
MapList editObjectList = (MapList)tableDataMap.get("EditObjectList");
MapList objectList = (MapList)tableDataMap.get("ObjectList");
HashMap requestMap = (HashMap) 
tableBean.getRequestMap(tableDataMap);
String parentOID = (String)requestMap.get("parentOID");

HashMap paramMap = new HashMap();
Enumeration params = request.getParameterNames();
while (params.hasMoreElements())
{
    String name = (String) params.nextElement();
    String value = emxGetParameter(request, name);
    paramMap.put(name,value);
}

String objectId = (String)paramMap.get("objectId");
String url = SlmUIUtil.getCommandHref(context, "SMASteps_ExecutionOptions", objectId, parentOID, requestMap);
HashMap programMap = new HashMap();
programMap.put("stream",
    getServletConfig().getServletContext().
    getResourceAsStream("/simulationcentral/WorkflowExtensionDescriptors/ExecutionOption.xml"));
programMap.put("paramMap",paramMap);
programMap.put("requestMap",requestMap);
programMap.put("tableData",tableDataMap);

String[] args = JPO.packArgs(programMap);

Map results = (Map)JPO.invoke(context, 
    "jpo.simulation.ExecutionOption", null,
    "editStepsExeOpt", args, Map.class);
System.out.println("results= "+results);
%>
                <script language="JavaScript">
                    var topFrame = getTopWindow();
                    if ( getTopWindow().getWindowOpener() )
                    {
                        topFrame = getTopWindow().getWindowOpener().getTopWindow();
                    }
                    var frame1 = findFrame(topFrame, "SMASteps_ExecutionOptions");
                    if ( frame1 != null )
                    {
                    	frame1.location.href = "<%= url%>";
                    }
                </script>

