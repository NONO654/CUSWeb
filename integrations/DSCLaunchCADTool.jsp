<%-- DSCLaunchCADTool.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	String integrationName	=Request.getParameter(request,"integrationName");
%>

<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript">
	var integFrame = getIntegrationFrame(this);		
	integFrame.launchCADTool("<%=integrationName%>");
</SCRIPT>
