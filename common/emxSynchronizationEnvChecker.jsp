<%--  emxSynchronizationEnvCheckerFS.jsp   -   Page to execute Data Checker and display results
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   @quickreview E25 17:03:22 [Modifications for New UI ].
   @quickreview E25 17:06:01 [Modifications for different colors in case of success and failure ].
   @quickreview E25 17:06:08 [Modifications for change in color in case of failure ].
--%>

<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMxIntegrationUtilities"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil"%>
<%@ page import="matrix.db.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker"%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<%
    String languageStr           = request.getHeader("Accept-Language");
    String strBundle             = "emxVPLMSynchroStringResource";
    String strEnvCheckResult              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMSynchro.Synchronization.EnvCheckResult");
%>
<html>

<head>
<TITLE>Collaboration Environment Checker </TITLE> 
<META http-equiv="imagetoolbar" content="no">
<META http-equiv="pragma" content="no-cache">

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="javaScript" src="../common/scripts/emxUITableUtil.js"></script>

<script language="javascript">
		    addStyleSheet("emxUIDefault","../common/styles/");
		    addStyleSheet("emxUIToolbar","../common/styles/");
		    addStyleSheet("emxUIList","../common/styles/");
		    addStyleSheet("emxUIProperties","../common/styles/");
    		addStyleSheet("emxUITemp","../");
		    addStyleSheet("emxUIForm","../common/styles/");
    </script>
</head>

<body class="slide-in-panel" onload="turnOffProgress();">
<%
String webRootPath = application.getRealPath("/");
VPLMJCollaborationModelerChecker envChecker= new VPLMJCollaborationModelerChecker();
envChecker.setConfigFilelocation(webRootPath+"WEB-INF/classes/VPLMCollaborationModelerCheckerConfig.xml");
HashMap<String,String> argsMap = new HashMap<String,String>();
	ArrayList<String> reportMessages=null;
	reportMessages=envChecker.execute(context,argsMap); 
	boolean reportFailure=false;
	for(String report : reportMessages)
	{
		if(report.contains("Fail"))
		{
			reportFailure=true;
			break;
		}
	}%>
	<table>
		<tr>
			<td class="heading1">
			<%if(reportFailure)
				{
				%>
				<p style="text-align: center; color: red; font-size: 10pt;" ><%=strEnvCheckResult%></p>
				<%
				}else
				{%><p style="text-align: center; color: #006600; font-size: 10pt;" ><%=strEnvCheckResult%></p>
				<%}%>
			</td>
		</tr>
<!-- Code to set rule configuration file for environment checker 
	Execution of environment checker and display of results in JSP.
-->
<%	
 
	for(String report : reportMessages)
	{
%>
		<tr>
			<td class="label">
				<%
	  out.println(report+"\n");
	
%>
			</td>
		</tr>
		<%
	}
  
%>
	</table>




</body>
</html>
