<%--  emxSynchronizeVPLMDataCheckerReportFS.jsp   -   FS page display of data checker results
	This FS page is to display results.
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@page
	import="com.matrixone.vplmintegration.util.VPLMxInstallationUtilities"%>
<%@ page import="java.util.List"%>
<%@ page import="matrix.db.*"%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<!-- code add input parameters from submitted form to content URL -->
<%
	framesetObject fs = new framesetObject();

	String objectId = emxGetParameter(request, "objectId");
	String languageStr = request.getHeader("Accept-Language");
	String contentURL = "emxSynchronizeVPLMDataChecker.jsp";
 	String strBundle             = "emxVPLMSynchroStringResource";

	contentURL += "?";

	Map params = request.getParameterMap();
	java.util.Set keys = params.keySet();
	Iterator it = keys.iterator();
	int count = 0;
	while (it.hasNext()) {
		String key = (String) it.next();
		String value[] = (String[]) params.get(key);
		if (value != null && value[0].toString().length() > 0 && ++count == 1)
			contentURL += key + "=" + value[0].toString();
		else
			contentURL += "&" + key + "=" + value[0].toString();
	}

  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPLMSynchro.Synchronization.Command.SyncDataChecker.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPMCentralStringResource", request.getHeader("Accept-Language")) ;

	String HelpMarker = "emxhelpbomsynchronize";
	if (titleKey
			.equals("emxVPMCentral.Synchronization.Command.SyncDataChecker.Title"))
		HelpMarker = "emxhelplcsynchronize";

	fs.setSuiteKey("VPMCentral");

	fs.initFrameset(msgTitle, HelpMarker, contentURL, false, true, false,
			false);

	fs.setStringResourceFile("emxVPLMSynchroStringResource");
	// code to add done button in frameset
	fs.createFooterLink("emxVPLMSynchro.Command.Done",
			"reset()", "role_GlobalUser", false, true,
			"common/images/buttonDialogDone.gif", 0);

	// ----------------- Do Not Edit Below ------------------------------

	fs.writePage(out);
%>







