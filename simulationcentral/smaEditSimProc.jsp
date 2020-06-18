<%-- (c) Dassault Systemes, 2014 --%>
<%--
  Post process for Simulation
--%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import = "java.util.HashMap,java.util.Map"%>
<%@page import="matrix.db.JPO"%>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%

Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String objectId = (String) requestMap.get("objectId");
String simUsageNew = (String) requestMap.get("Simulation Kind");
String simUsageOld = (String) requestMap.get("Simulation KindfieldValue");

if(!simUsageOld.equals(simUsageNew))
{

    HashMap paramMap = new HashMap();
    paramMap.put("objectId",objectId);
    paramMap.put("New Value",simUsageNew);

    String msg =  (String) JPO.invoke(context,
        "jpo.simulation.SIMULATIONS", null,
        "updateSimulationUsageAttribute", JPO.packArgs(paramMap),String.class);
    %>
    <script>
    var msg = '<%=msg%>';
    alert (msg);
    </script>
   <%
}
%>
