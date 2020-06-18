<%--  emxHistoryFS.jsp   -  FramesetPage
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, com.matrixone.apps.framework.ui.*, com.matrixone.apps.domain.util.*, java.util.*, java.io.*" errorPage="emxNavigatorErrorPage.jsp"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String HistoryMode = emxGetParameter(request,"HistoryMode");
  String Header      = emxGetParameter(request,"Header");
  String hiddenActions   = emxGetParameter(request,"hiddenActions");
  String actionFilter   = emxGetParameter(request,"actionfilter");
  //System.out.println("the value="+hiddenActions);
  fs.setDirectory("common");

  // ----------------- Do Not Edit Above ------------------------------
  String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(150);
  contentURL.append("showActionSelections.jsp");
  
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&HistoryMode=");
  contentURL.append("&hiddenActions=");
  contentURL.append(hiddenActions);
  contentURL.append("&actionFilter=");
  contentURL.append(actionFilter);

  // Page Heading - Internationalized
  String PageHeading ="emxFramework.History.SelectActionType";
 
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelphistory";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,UINavigatorUtil.encodeURL(contentURL.toString()),false,true,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  fs.setObjectId(objectId);

   String roleList = "role_GlobalUser";

    fs.createFooterLink("emxFramework.Common.Done",
                      "checkSelectedActions()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


  fs.createFooterLink("emxFramework.Button.Cancel",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>





