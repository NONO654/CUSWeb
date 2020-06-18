<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.db.Context"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.common.util.DebugUtil"%>

<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>

<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
</head>
<body>
	<%
		String simTemplateOID = "";
	
		try {
			
			DebugUtil.dumpObject("Simulation Template Search", "Submit Called");
			
			String timeStamp = emxGetParameter(request, "timeStamp");
	    	HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
	    	
	    	String caseId = (String)requestMap.get("objectId");

	    	String[] emxRowIds = request.getParameterValues("emxTableRowId");
	    
	        if (emxRowIds.length > 0){
	        	simTemplateOID = emxRowIds[0];
	        	
	        	DebugUtil.dumpObject("Selected Simulation Template", simTemplateOID);
	        }
			
		}
		catch(Exception ex){
			DebugUtil.dumpObject(ex);
			throw (ex);
		}
		finally{
			DebugUtil.dumpObject("Simulation Template Search", "Complete");
		}
		
	%>
	<script>
    	var opener = getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].contentWindow || getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].window;
    	if (opener){
    		if(opener.proxy){
    			opener.proxy.fireNamedCallback('setSelectedSimTemplate', '<%=simTemplateOID%>');
    		}
    		else{
    			throw 'proxy not found';
    		}
    		getTopWindow().closeWindow();
    	}
    </script>
</body>
</html>
