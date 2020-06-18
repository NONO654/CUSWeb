 <%--   emxRouteWorkflow.jsp  -  Display the Workflow view of all the Tasks in a Route
  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
--%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.common.RouteWorkflow"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<% 	
	Context context = Framework.getFrameContext(session);
    String timeZone = (String)session.getAttribute("timeZone");
	String sOID = com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");
	
	boolean isPrinterFriendly = false;
	String printerFriendly = com.matrixone.apps.domain.util.Request.getParameter(request, "PrinterFriendly");
	if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
		isPrinterFriendly = "true".equals(printerFriendly);
		}
	  
	RouteWorkflow rwObject = new RouteWorkflow(sOID);
	HashMap<String, StringBuffer> nodeMap = rwObject.getRouteTaskNodes(context, isPrinterFriendly, timeZone);
	
	StringBuffer sbTasks 		= nodeMap.get("sbTasks");
	StringBuffer sbConnections 	= nodeMap.get("sbConnections");	
%>

<!DOCTYPE html>
<html>
	<head>
		<script type="text/javascript" src="../common/scripts/jquery.min-xparam.js"></script>
		<script type="text/javascript" src="../common/scripts/jquery-ui.min-xparam.js"></script>
		<script type="text/javascript" src="../plugins/jsPlumb/1.4.1/jquery.jsPlumb-xparam.js"></script>
		<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
		<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
			
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"/>
        		
		<script type="text/javascript">
			jsPlumb.bind("ready", function() {			
				jsPlumb.importDefaults({
					Anchors  : ["RightMiddle", "LeftMiddle"],
					EndpointStyles : [{ fillStyle:'#55636b' }, { fillStyle:'#55636b' }],
					Endpoints : [ [ "Rectangle", {width:1, height:1} ], [ "Rectangle", { width:1, height:1 } ]],
					ConnectionOverlays	: [
						[ "Arrow", { location: -2 , width: 15, length: 15 } ]
					],
					Connector:[ "Flowchart", { stub: 10, gap:10 } ],								
					PaintStyle 	: {
						lineWidth:2,
						strokeStyle:"#55636b",
						joinstyle:"round"
					}
				});

			//XSSOK
			<%=sbConnections.toString()%>		
			});
		</script>
	</head>
	<body class="route-graphical">
	<div class="route-container">
				<%=sbTasks.toString()%>
				</div>
	</body>
</html>
