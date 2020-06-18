
<%--  emxGenericDeleteProcess.jsp
   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxGenericDeleteProcess.jsp.rca 1.7.3.3 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.common.util.ComponentsUtil"%>
<%@ page import="matrix.util.MatrixException"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices.ObjectUsedInReportException" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import="com.dassault_systemes.vplm.modeler.exception.PLMxModelerException" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.util.*" %>
<%@ page import="com.dassault_systemes.catrgn.services.util.nls.*" %>
<%@ page import="com.dassault_systemes.catrgn.constants.SystemReportGenerationConstants" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String errorMessage = null;
boolean isFromSearch = false;
try {
	Map requestMap = UINavigatorUtil.getRequestParameterMap(request);
	String toolbarName = (String)requestMap.get("toolbar");
	isFromSearch = toolbarName != null && toolbarName.contains("Search");
	String memberIds[] = emxGetParameterValues(request,"emxTableRowId");
	for (int i = 0; i < memberIds.length; i++) {
		if (memberIds[i].startsWith("|")) memberIds[i] = memberIds[i].substring(1, memberIds[i].indexOf("|", 1));
	}
	for (String reportId : memberIds) {
		// Init one reqInfo and connector config per launch
		CATRgnReportServices services = new CATRgnReportServices(context, request); // IR-542541
		services.generateReport(services.getReportWithInputs(reportId), true, true, "true".equalsIgnoreCase((String)requestMap.get("withChanges")));
	}
} catch (MatrixException e) {
	errorMessage = e.getMessage();
	if (SystemReportGenerationConstants.IS_DEBUG)
		e.printStackTrace();
}
%>

<html>
<head> 
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script> 

<script type="text/javascript" language="javascript">
	<% if( errorMessage != null) { %>
		alert("<%=XSSUtil.encodeForJavaScript(context, errorMessage)%>");
	<% }; %>
	if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isFromSearch))%>) {
		findFrame(getTopWindow(),"windowShadeFrame").document.getElementById("full_search_hidden").submit();
	} else {
		parent.location=parent.location;
	}
</script>

</head>
<body>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
