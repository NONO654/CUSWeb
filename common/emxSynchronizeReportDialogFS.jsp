<%-- @quickreview X32 19:06:20 : Old Reporter removal Modification--%>
<%-- @quickreview E25 19:01:07 :  Modifications for short/detailed report option modifications from web side reporter on/off case--%>
<%-- @quickreview ANT4 18:03:30 : IR-563472-3DEXPERIENCER2017x Report XSS from 18X --%>
<%-- @quickreview ANT4 18:03:29 : IR-563472-3DEXPERIENCER2017x Fix issue with '&' in organization name --%>
<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%--  emxSynchronizeWithVPLMDialogFS.jsp   -   FS page for Create Specification dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSynchronizeWithVPLMDialogFS.jsp.rca 1.14.1.2 Mon Aug  6 19:59:33 2007 przemek Experimental $
--%>

<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMxInstallationUtilities"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationEnvVariable"%>
<%@page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationReporter"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil" %>
<%@ page import="matrix.db.*"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ include file="../emxUIFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  final String appDirectory = (String) EnoviaResourceBundle.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
  fs.setDirectory(appDirectory);

  String objectId = emxGetParameter(request,"objectId");
  String targetLocation = emxGetParameter(request,"targetLocation");
  //SBM1: 02/14/2017 IR-495077: retrieve objectId from emxTableRowId in case of RMB click
  String strRMBTableID = emxGetParameter(request, "emxTableRowId");
  if (strRMBTableID != null && !"null".equals(strRMBTableID) && !"".equals(strRMBTableID)) {
		StringList sList = FrameworkUtil.split(strRMBTableID, "|");    
		if (sList.size() == 3) {
			objectId = (String) sList.get(0);		    
		} else if (sList.size() == 4) {
			objectId = (String) sList.get(1);		    
		} else if (sList.size() == 2) {
			objectId = (String) sList.get(1);
		} else {
			objectId = strRMBTableID;
		}
	}
  VPLMBusObject bo=new VPLMBusObject(context,objectId);
  String objectType=bo.getBasicTypeName();
  String vplmContext = emxGetParameter(request,"vplmContext");
  String SYNC_AND_TRANSFER = emxGetParameter(request,VPLMIntegrationConstants.SYNC_AND_TRANSFER);
  String SYNC_DEPTH = emxGetParameter(request,VPLMIntegrationConstants.SYNC_DEPTH);
  String SYNC_DEPTH_CUSTOM= emxGetParameter(request,"SYNC_DEPTH_CUSTOM");
  //CRK: 6/30/08 Added for support of the GetCatalog scenario.
  String SYNC_FORWARD = emxGetParameter(request,"SYNC_FORWARD");
  String DETAILED_REPORT= emxGetParameter(request,VPLMIntegrationReporter.DETAILED_REPORT);

   if(SYNC_DEPTH!=null && !SYNC_DEPTH.isEmpty()) {
  	String prefName="preference_DepthSync_"+objectType;
  	VPLMIntegTraceUtil.trace(context,"emxSynchronizeReportDialogFS:setAdminProperty "+prefName+"="+SYNC_DEPTH);
	PropertyUtil.setAdminProperty(context, "person", context.getUser(), prefName, SYNC_DEPTH);
  } 
  if(SYNC_DEPTH_CUSTOM!=null && !SYNC_DEPTH_CUSTOM.isEmpty()) {
  	String prefName="preference_DepthSyncCustom_"+objectType;
  	VPLMIntegTraceUtil.trace(context,"emxSynchronizeReportDialogFS:setAdminProperty "+prefName+"="+SYNC_DEPTH_CUSTOM);
	PropertyUtil.setAdminProperty(context, "person", context.getUser(), prefName, SYNC_DEPTH_CUSTOM);
  } 
  		
  //LUS - Begin 8/12/2008 for Bug: A0635363
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPMCentral.Synchronization.Command.SyncWithVPLM.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPMCentralStringResource", request.getHeader("Accept-Language")) ;
  //LUS - End 8/12/2008 for Bug: A0635363

  String languageStr = request.getHeader("Accept-Language");
  // Specify URL to come in middle of frameset
  
  //S45 mistake h String contentURL = "emxSyncronizeWithVPLM.jsp";
  String contentURL = "emxSyncronizeWithVPLM.jsp";

  //LUS - Begin 6/23/2008 for Bug: A0627779 
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + XSSUtil.encodeForURL(context, objectId) + "&vplmContext=" + XSSUtil.encodeForURL(context, vplmContext) + "&"+VPLMIntegrationConstants.SYNC_AND_TRANSFER+"=" + XSSUtil.encodeForURL(context, SYNC_AND_TRANSFER) + "&"+VPLMIntegrationConstants.SYNC_DEPTH+"=" + XSSUtil.encodeForURL(context, SYNC_DEPTH) + "&"+VPLMIntegrationReporter.DETAILED_REPORT+"=" + XSSUtil.encodeForURL(context, DETAILED_REPORT) +  "&SYNC_FORWARD=" + XSSUtil.encodeForURL(context, SYNC_FORWARD) + "&targetLocation="+XSSUtil.encodeForURL(context, targetLocation);
  VPLMIntegTraceUtil.trace(context,"emxSynchronizeReportDialogFS:contentURL="+contentURL);
  //LUS - End 6/23/2008 for Bug: A0627779 
  //SM7 - IR-86278 - Feb 25 , 2010 - Providing the titleKey to the initFrameset instead of msgTitle
  String HelpMarker = "emxhelpbomsynchronize";
  
  if(VPLMxInstallationUtilities.isENGSMBInstalled(context, true)) {
	 HelpMarker = "emxhelpsynchronize";
  }
  else if(VPLMxInstallationUtilities.isENGInstalled(context)) {
	 HelpMarker = "emxhelpbomsynchronize";
  }
  
  if(titleKey.equals("emxVPLMSynchro.Catalog.Command.SyncWithCatalog.Title"))
	HelpMarker = "emxhelplcsynchronize";
  
  fs.setSuiteKey("VPMCentral");
  
  fs.initFrameset(titleKey,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxVPLMSynchroStringResource");

  fs.createFooterLink("emxVPLMSynchro.Command.Done",
                      "doneAction()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>





