<%--  emxSynchronizationEnvCheckerFS.jsp   -   FS page for Environment Checker dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
      @quickreview E25 17:03:22 [Modifications for New UI ].
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
<%@ page
	import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page
	import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker"%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<html>
<head>

</head>

<body bgcolor=white>
	<br />
	<%framesetObject fs = new framesetObject();

  final String appDirectory = UINavigatorUtil.getDirectoryProperty("eServiceSuiteEngineeringCentral.Directory");
 // Page Title - Internationalized
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPLMSynchro.Success.EnvironmentValidate";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPLMSynchroStringResource", request.getHeader("Accept-Language")) ;

  String languageStr = request.getHeader("Accept-Language");
  
  // Specify URL to come in middle of frameset
  String contentURL = "emxSynchronizationEnvChecker.jsp";

  String HelpMarker = "emxhelpbomsynchronize";
  
  if(titleKey.equals("emxVPLMSynchro.Catalog.Command.SyncWithCatalog.Title"))
	HelpMarker = "emxhelplcsynchronize";
  
  fs.setSuiteKey("VPMCentral");
  
  fs.initFrameset(titleKey, HelpMarker, contentURL,false,true,false,false);

  fs.setStringResourceFile("emxVPLMSynchroStringResource");

 

  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
	fs.setDirectory(appDirectory);



</body>
</html>
