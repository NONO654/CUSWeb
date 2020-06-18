<%--  emxLifecycleApproveRejectDialogFS.jsp   -   FS page for Approval dialog

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleApproveRejectDialogFS.jsp.rca 1.6.3.2 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  
  fs.setDirectory(appDirectory);


  // Specify URL to come in middle of frameset
    String jsTreeID 		= emxGetParameter(request,"jsTreeID");
    String suiteKey 		= emxGetParameter(request,"suiteKey");
    String objectId 		= emxGetParameter(request,"objectId");
    String strSignatureName = emxGetParameter(request, "signatureName");
    String strTaskId 		= emxGetParameter(request, "taskId");
    String strState 		= emxGetParameter(request, "stateName");
    String strRouteTaskUser = emxGetParameter(request, "routeTaskUser");

    // Specify URL to come in middle of frameset
    StringBuffer strContentURL = new StringBuffer(150);
    strContentURL.append("emxLifecycleApproveRejectDialog.jsp");

    // add these parameters to each content URL, and any others the App needs
    strContentURL.append("?suiteKey=");
    strContentURL.append(suiteKey);
    strContentURL.append("&initSource=");
    strContentURL.append(initSource);
    strContentURL.append("&jsTreeID=");
    strContentURL.append(jsTreeID);

    strContentURL.append("&objectId=");
    strContentURL.append(objectId);

    strContentURL.append("&signatureName=");
    strContentURL.append(strSignatureName);

    strContentURL.append("&state=");
    strContentURL.append(strState);

    strContentURL.append("&taskId=");
    strContentURL.append(strTaskId);
    
    if(UIUtil.isNotNullAndNotEmpty(strRouteTaskUser) && strRouteTaskUser.startsWith("role_"))
    {
    	strContentURL.append("&routeTaskUser=");
   		strContentURL.append(strRouteTaskUser);
    }
    
  String contentURL = strContentURL.toString();

  fs.setStringResourceFile("emxFrameworkStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Lifecycle.Approval";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelplifecycleapprovals";
  

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createFooterLink("emxFramework.Lifecycle.Done",
			          "checkInput()",
			          "role_GlobalUser",
			          false,
			          true,
			          "common/images/buttonDialogDone.gif",
			          3);
  
  fs.createFooterLink("emxFramework.Lifecycle.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
