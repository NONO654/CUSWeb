<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%--  emxSynchronizeWithVPLMDialogFS.jsp   -   FS page for Synchronization dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="com.matrixone.vplmintegration.util.VPLMxInstallationUtilities"%>
<%@ page import="java.util.List"%>
<%@ page import="matrix.db.*"%>
<%@ include file="../emxUIFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  final String appDirectory = (String) EnoviaResourceBundle.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
  fs.setDirectory(appDirectory);

  String objectId = emxGetParameter(request,"objectId");
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
  String languageStr			= request.getHeader("Accept-Language");
  // Specify URL to come in middle of frameset

  //Retrieve Transfer Value; If True invoke emxSynchronizeWithVPLMDialog.jsp
  String contentURL = "emxSynchronizeWithVPLMDialog.jsp";
  
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
  
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPMCentral.Synchronization.Command.SyncWithVPLM.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPMCentralStringResource", request.getHeader("Accept-Language")) ;
  
   //SM7 - IR-86278 - Feb 25 , 2010 - Providing the titleKey to the initFrameset instead of msgTitle
  //UNG - IR-101231 - Providing HelpMarket to resolve this change.
  String HelpMarker = "emxhelpbomsynchronize";
  
  if(VPLMxInstallationUtilities.isENGSMBInstalled(context, true))
	HelpMarker = "emxhelpsynchronize";
  else if(VPLMxInstallationUtilities.isENGInstalled(context))
	HelpMarker = "emxhelpbomsynchronize";
  
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

   //SM7 - IR-86278 - Feb 25 , 2010 - Setting the String resource to emxVPLMSynchroStringResource as the entries for the Submit and  Cancel button is moved to emxVPLMSynchroStringResource files 
  fs.setStringResourceFile("emxVPLMSynchroStringResource");
  //fs.setStringResourceFile("emxFrameworkStringResource");

  //fs.createFooterLink("emxFramework.Button.Submit",
  fs.createFooterLink("emxVPLMSynchro.Button.Submit",
                      "checkInput()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);
                    
  //fs.createFooterLink("emxFramework.Button.Cancel",
  fs.createFooterLink("emxVPLMSynchro.Button.Cancel",
                      "cancelSlideIn()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>





