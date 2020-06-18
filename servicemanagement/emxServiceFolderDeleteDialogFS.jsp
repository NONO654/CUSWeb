<%--  emxServiceFolderDeleteDialogFS.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxServiceFolderDeleteDialogFS.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<jsp:useBean id="emxServiceFolderDeleteDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxServiceManagementAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.useCache(false);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
  {
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String tableBeanName = "emxServiceFolderDeleteDialogFS";

  // ----------------- Do Not Edit Above ------------------------------
  
  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");
  String HelpMarker = emxGetParameter(request,"HelpMarker");
  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer();
  contentURL.append("emxServiceFolderDeleteDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=").append(suiteKey).append("&initSource=").append(initSource).append("&jsTreeID=").append(jsTreeID);
  contentURL.append("&objectId=").append(objectId).append("&beanName=").append(tableBeanName).append("&HelpMarker=").append(HelpMarker);
  
  String PageHeading = "emxWSManagement.Common.DeleteSelected";


  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,true,true,false);
  fs.setStringResourceFile("emxWSManagementStringResource");
  fs.setObjectId(objectId);
  fs.setBeanName(tableBeanName);
  fs.removeDialogWarning();

  fs.createCommonLink("emxWSManagement.Button.Done",
                      "deleteSelected()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonDone.gif",
                      false,
                      3);
  fs.createCommonLink("emxWSManagement.Button.Cancel",
                    "top.window.close()",
                    "role_GlobalUser",
                    false,
                    true,
                    "emxUIButtonCancel.gif",
                    false,
                    0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>





