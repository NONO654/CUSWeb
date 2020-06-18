<%--  emxSynchronizeVPLMDataCheckerDialogFS.jsp   -   FS page for Data Checker dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   @quickreview VKY 19:06:11 [Modifications to fix XSS Vulnerability ].
   @quickreview E25 17:03:22 [Modifications for New UI ].
--%>

<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="com.matrixone.vplmintegration.util.VPLMxInstallationUtilities"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@ page import="java.util.List"%>
<%@ page import="matrix.db.*"%>
<%@ include file="../emxUIFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  String languageStr			= request.getHeader("Accept-Language");
  String contentURL = "emxSynchronizeVPLMDataCheckerDialog.jsp";
  contentURL += "?";
        
	//Pass the selected objectId
	contentURL += "objectId="+ XSSUtil.encodeForURL(context, emxGetParameter(request, "objectId"));
  
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPLMSynchro.Synchronization.Command.SyncDataChecker.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPMCentralStringResource", request.getHeader("Accept-Language")) ;
  
  String HelpMarker = "emxhelpbomsynchronize";
  
  if(titleKey.equals("emxVPMCentral.Synchronization.Command.SyncDataChecker.Title"))
	HelpMarker = "emxhelplcsynchronize";
   
  fs.setSuiteKey("VPMCentral");
   
  fs.initFrameset(msgTitle,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxVPLMSynchroStringResource");
  // code to add submit in footer
  fs.createFooterLink("emxVPLMSynchro.Button.Submit","checkInput()","role_GlobalUser",false,true,"common/images/buttonDialogDone.gif",0);
                    
  //code to add cancel in footer
  fs.createFooterLink("emxVPLMSynchro.Button.Reset",
                      "reset()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






