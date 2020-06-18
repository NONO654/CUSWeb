<%--  DSCEBOMSyncAppletFree.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@page import="com.matrixone.MCADIntegration.utils.MCADStringUtils"%>
<%@ include file = "MCADTopInclude.inc" %>
<%@ include file = "MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.apps.domain.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADLocalConfigObject" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADGlobalConfigObject" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADUtil,com.matrixone.MCADIntegration.server.MCADServerSettings,matrix.db.JPO,com.matrixone.MCADIntegration.server.beans.*" %>

<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js"></script>
<script language="JavaScript" src="../common/scripts/emxExtendedPageHeaderFreezePaneValidation.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<html>
<body>
  
  <%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String integrationName	=Request.getParameter(request,"integrationName");
	
	MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(),integSessionData.getResourceBundle(),integSessionData.getGlobalCache());

	MCADServerGeneralUtil serverGeneralUtil	= new MCADServerGeneralUtil(context, integSessionData, integrationName);
 	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
  
	Hashtable resultData	= null;
  //String operationUID	= (String)JPOArgsTable.get(MCADServerSettings.OPERATION_UID);	        	
	String jpoName	 	= globalConfigObject.getEBOMProxyJPOName();
	String jpoMethod	= "createEBOMSynchronization";	        	
	
	String objectId		= Request.getParameter(request,"objectId");
	
	Hashtable argsTable = new Hashtable(4);
	argsTable.put(MCADServerSettings.GCO_OBJECT, globalConfigObject);
	argsTable.put(MCADServerSettings.LANGUAGE_NAME, integSessionData.getLanguageName());
	argsTable.put(MCADServerSettings.OPERATION_UID, com.matrixone.MCADIntegration.utils.UUID.getNewUUIDString());	        	
	
	String [] initArgs = JPO.packArgs(argsTable);
	
	String [] args = new String[1];
	args[0] = objectId;
	
	resultData = (Hashtable)util.executeJPO(context, jpoName, initArgs, jpoMethod, args, Hashtable.class);

  String resultMessage = (String)resultData.get(MCADServerSettings.JPO_STATUS_MESSAGE);
  
  %>
  <script language="JavaScript">
  alert("<%=resultMessage.trim()%>");
	if(parent.parent.frames[0].document.getElementById('txtProgressDivChannel') !=null && parent.parent.frames[0].document.getElementById('imgProgressDivChannel') != null)
	{// If for activing progress bar is command is executed from Obejct summary page
		parent.parent.frames[0].document.getElementById('imgProgressDivChannel').style.visibility ='hidden';
	}
	else if(parent.parent.parent.document.getElementById('txtProgressDivChannel') !=null && parent.parent.parent.document.getElementById('imgProgressDivChannel') != null)
	{// else part for activating progess bar if command is executed from Navigate page.
		parent.parent.parent.document.getElementById('imgProgressDivChannel').style.visibility ='hidden';
	}
	else if(parent.parent.document.getElementById('imgLoadingProgressDiv')!=null)
	{// for navigate page from category tree
		parent.parent.document.getElementById('imgLoadingProgressDiv').style.visibility ='hidden';
	}
   window.top.document.getElementById('layerOverlay').style.display ='none';
   
  </script>
</body>
</html>

