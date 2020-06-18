<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "java.util.HashMap,java.util.Map"%>
<%@page import = "matrix.db.*, matrix.util.*"%>
<%@page import="matrix.db.Context" %>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.CacheUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
   Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
   String objectAction      = emxGetParameter(request, "objectAction");
   
   // get status that was passed in fro jsp that made WS call to cos
   String status      = emxGetParameter(request, "status");
   String user = context.getUser();
   user = user.replaceAll(" ", "_");
   
   // set status in cache so it can be retrieved in jpo form get field method
   CacheUtil.setCacheObject(context, SimulationConstants.COS_SERVER_STATUS+user, status);

	String serverName = emxGetParameter(request, "serverName");
	if (null == serverName) serverName = "";

	// use the portal supporting multiple COS servers
	String portalName = "SMACOSServer_Details";
   // set content to portal that opens COS Server properties channel
   // and channel having 3 tabs for stations, groups, and applications
   StringBuffer  contentURL = new StringBuffer();
   contentURL.append("../common/emxPortal.jsp")
       .append("?portal="+portalName)
       .append("&showPageHeader=false")
       .append("&HelpMarker=SMACOSServer_Details")
       .append("&mode=advanced")
       .append("&serverName=").append(serverName)
       .append("&suiteKey=SimulationCentral");
%>
<script language="JavaScript">
       
	var frame = null;  
  	frame = findFrame(getTopWindow(),"content"); 
  	if (frame) 
  	{
    	frame.location.href = "<%=contentURL.toString()%>";
  	}
</script>


