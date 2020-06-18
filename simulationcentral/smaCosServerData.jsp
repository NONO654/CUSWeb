






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
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
   Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
   String objectAction      = emxGetParameter(request, "objectAction");
   
	String serverName = emxGetParameter(request, "serverName");
	
    String[] jpoargs = new String[1];
    jpoargs[0] = serverName;
    serverName =
		(String)JPO.invoke( context, 
        "jpo.simulation.SimulationHost", null, 
        "getCosServerName", jpoargs, String.class);

   String header = "COS SERVER";
   StringBuffer  contentURL = new StringBuffer();

	// use the form supporting multiple COS servers
	String formName = "SMACOSServer_ViewEdit";
   	contentURL.append("../common/emxForm.jsp")
       .append("?form=").append(formName)
       .append("&mode=view")
       .append("&PrinterFriendly=false")
       .append("&Export=false&portalMode=true&showTabHeader=false")
       .append("&serverName="+serverName)
       .append("&toolbar=SMACOSServer_Toolbar")
       .append("&formHeader="+header);
%>
<script language="JavaScript">
       
	var frame = null;  
  	frame = findFrame(getTopWindow(),"SMACOSServer_PropsEdit"); 
  	if (frame) 
  	{
    	frame.location.href = "<%=contentURL.toString()%>";
  	}
</script>


