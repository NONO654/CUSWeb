<%--  emxSynchronizeChangeWithVPLMDialogFS.jsp   -   FS page for Synchronization of change dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import="com.matrixone.vplmintegrationitf.util.*"%>
<%@ page import="com.matrixone.vplmintegration.util.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="matrix.db.*"%>
<%-- --%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%-- --%>
<%
	//
	// constants
	// Specify URL to come in middle of frameset
  String contentURL = "emxSynchronizeChangeWithVPLMDialog.jsp";
  //Providing HelpMarket to resolve this change.
  String HelpMarker = "emxhelpchangesynchronize";
  final String appDirectory = UINavigatorUtil.getDirectoryProperty("eServiceSuiteEngineeringCentral.Directory");
	// get request parameters 
  String objectId = emxGetParameter(request,"objectId");
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPLMSynchro.ChangeSynchronization.Command.SyncWithVPLM.Title";
	// for messages
  String languageStr			= request.getHeader("Accept-Language");
  String stringResource="emxVPLMSynchroStringResource";
	String msgTitle = UINavigatorUtil.getI18nString(titleKey, stringResource, languageStr) ;
  
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?";
  //Pass all the arguments in the URL        
  Map params = request.getParameterMap();
  java.util.Set keys= params.keySet();
  Iterator it = keys.iterator();
  int count = 0;
  while(it.hasNext())
  {
  	String key = (String) it.next();
    String value[] = (String[]) params.get(key);
    if(value!=null && value[0].toString().length()>0 && ++count==1)
    	contentURL += key+"="+value[0].toString();
    else
      contentURL += "&"+key+"="+value[0].toString();
  }

	// jsp definition
  framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);
  fs.setSuiteKey("VPMCentral");
  fs.initFrameset(titleKey,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);
  //Setting the String resource to emxVPLMSynchroStringResource  
  fs.setStringResourceFile(stringResource);
  fs.createFooterLink("emxVPLMSynchro.Button.Submit",
                      "checkInput()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);           
  fs.createFooterLink("emxVPLMSynchro.Button.Cancel",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>


