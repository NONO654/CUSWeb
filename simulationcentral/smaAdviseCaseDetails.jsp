<%--
@quickreview SD4 6/5/2014 remove unused css link to smaResIntImport.css 
--%>
<%--  smaAdviseImportDataSet.jsp - main file for importing a dataset and creating an Analytics case connected to that dataset
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import = "matrix.db.JPO"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
		
		<link rel="stylesheet" type="text/css" href="./styles/smaAdviseResetAll.css">
		
		<link rel="stylesheet" type="text/css" href="./styles/smaAdviseHelp.css">
		<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script	src="./smaAdviseLaunchHelper.js" type="text/javascript"></script>
		<script	src="./smaAdviseHelp.js" type="text/javascript"></script>
		<script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
		<script type="text/javascript" src="../simulationcentral/smaAdviseOpenWidget.js"></script>
</head>
<body>
<%
boolean showEdit = true;
boolean showRun = true;
String strObjId = request.getParameter("objectId");
%>
<script type="text/javascript">
	openResultAnalytics("<%=strObjId%>");
</script>
</html>
