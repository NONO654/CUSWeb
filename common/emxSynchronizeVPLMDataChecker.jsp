<%--  emxSynchronizationEnvCheckerFS.jsp   -   FS page for Data Checker Results
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
      @quickreview E25 19:06:21 [Modifications for Change Object Checker].
      @quickreview E25 17:03:22 [Modifications for New UI ].
      @quickreview E25 17:06:01 [Modifications for different colors in case of success and failure ].
      @quickreview E25 17:06:08 [Modifications for change in color in case of failure ].
      @quickreview E25 17:07:05 [IR-533137-3DEXPERIENCER2018x Modifications messages from NLS files].
--%>
<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page
	import="com.matrixone.vplmintegration.util.VPLMxIntegrationUtilities"%>
<%@ page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil"%>
<%@ page import="matrix.db.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page
	import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page
	import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<%
    String languageStr           = request.getHeader("Accept-Language");
    String strBundle             = "emxVPLMSynchroStringResource";
	String objectID=request.getParameter("objectID");
	String checkerName=request.getParameter("ichecker");
	String expandStruct=request.getParameter("expandStructure");
	VPLMBusObject boToSync  = new VPLMBusObject(context,objectID);
	String objectName=boToSync.getSelectableValue("name");
	String objectType=boToSync.getSelectableValue("type");
	objectType = FrameworkUtil.findAndReplace(objectType, " ", "_");
	String objectRev=boToSync.getSelectableValue("revision");
    	String strDataCheck              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMSynchro.Synchronization.DataCheckResult");
        String strrefFail              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMJCollab.ModelerChecker.Fail");
        String displayType = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Type."+objectType); 
        String strDataCheckResult =strDataCheck +" "+displayType+" "+objectName+" "+objectRev;
%>
<html>

<head>
<TITLE>Collaboration Data Checker</TITLE>
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
function reset()
	{
		//alert("I am here in reset");
		 window.parent.location= "../common/emxSynchronizeVPLMDataCheckerDialogFS.jsp?titleKey=emxVPLMSynchro.Synchronization.Command.SyncDataChecker.Title";

		
	}

    </script>



</head>

<body class="slide-in-panel" onload="turnOffProgress();">
		<%
	HashMap<String,String> argsMap = new HashMap<String,String>();
	argsMap.put("ID",objectID);
	argsMap.put("expandStructure",expandStruct);
	argsMap.put("ichecker",checkerName);
	VPLMJCollaborationModelerChecker dataChecker= new VPLMJCollaborationModelerChecker();
	String webRootPath= application.getRealPath("/");
	dataChecker.setConfigFilelocation(webRootPath+"/WEB-INF/classes/VPLMCollaborationModelerCheckerConfig.xml");
	ArrayList<String> reportMessages=dataChecker.execute(context,argsMap); 
	boolean reportFailure=false;
	for(String report : reportMessages)
	{
		if(report.contains(strrefFail))
		{
			reportFailure=true;
			break;
		}
	}
	%>
	<table>
		<tr>
			<td class="heading1">
			<%if(reportFailure)
				{
				%>
				<p style="text-align: center; color: red; font-size: 10pt;" ><%=strDataCheckResult%></p>
				<%
				}else
				{%><p style="text-align: center; color: #006600; font-size: 10pt;" ><%=strDataCheckResult%></p>
				<%}%>
			</td>
		</tr>

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
