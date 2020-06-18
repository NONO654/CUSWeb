<%--
  $Archive: emxLifecycleApprovalDialogFS.jsp $
  $Revision: 1.12 $
  $Author: przemek $
  
  Name of the File : emxLifecycleApprovalDialogFS.jsp
  
  Description : FS page for Approval dialog
  
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
  if(appDirectory == null || "".equals(appDirectory) || "null".equals(appDirectory))
  {
    appDirectory = "common";  
  }
  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
        initSource = "";
    }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String signName = emxGetParameter(request, "signatureName");
  String fromState = emxGetParameter(request, "fromState");
  String toState = emxGetParameter(request, "toState");
  String isInCurrentState = emxGetParameter(request, "isInCurrentState");
  String sHasApprove = emxGetParameter(request, "sHasApprove");
  String sHasReject = emxGetParameter(request, "sHasReject");
  String sHasIgnore = emxGetParameter(request, "sHasIgnore");
%>

<script language="javascript" src="scripts/emxUIModal.js"></script>

<%
  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(150);
  contentURL.append("emxLifecycleApprovalDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  
  contentURL.append("&signatureName=");
  contentURL.append(signName);
  contentURL.append("&fromState=");
  contentURL.append(fromState);
  contentURL.append("&toState=");
  contentURL.append(toState);
  contentURL.append("&isInCurrentState=");
  contentURL.append(isInCurrentState);
  contentURL.append("&sHasApprove=");
  contentURL.append(sHasApprove);
  contentURL.append("&sHasReject=");
  contentURL.append(sHasReject);
  contentURL.append("&sHasIgnore=");
  contentURL.append(sHasIgnore);             

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Lifecycle.Approval";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelplifecycleapprovals";
  
  String roleList = "role_GlobalUser";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

  
  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createFooterLink("emxFramework.Lifecycle.Done",
                      "checkInput()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

                      
  fs.createFooterLink("emxFramework.Lifecycle.Cancel",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

