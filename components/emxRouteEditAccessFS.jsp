<%-- emxRouteEditAccessFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc" %>

<jsp:useBean id="emxRouteEditAccessFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxRouteEditAccessFS";
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String objectName = emxGetParameter(request,"objectName");
  String objectId   = emxGetParameter(request,"objectId");
  String workspaceId = emxGetParameter(request,"workspaceId");
  String folderId = emxGetParameter(request,"folderId");

  // Specify URL to come in middle of frameset
  String contentURL = "";

  String typeDocument         = PropertyUtil.getSchemaProperty(context, "type_Document");
  String typeRoute         = PropertyUtil.getSchemaProperty(context, "type_Route");

  BusinessObject boGeneric = new BusinessObject(objectId);
  boGeneric.open(context);
  objectName = boGeneric.getName();
  
  //Assigned proper HelpMarker tag.
  String HelpMarker = "emxhelpaddworkspacemembersforfile";
  
  if (typeDocument.equals(boGeneric.getTypeName())) {
    String strTitleAttr = PropertyUtil.getSchemaProperty(context,"attribute_Title");
    objectName  = getAttribute(context,session,boGeneric,strTitleAttr);
  }else if(typeRoute.equals(boGeneric.getTypeName())){
    contentURL = "emxRouteEditAccess.jsp";
    HelpMarker = "emxhelprouteeditaccess";
  }


  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+objectId;
  contentURL += "&workspaceId="+workspaceId+ "&folderId="+folderId;
  boGeneric.close(context);

  String PageHeading = "emxComponents.Common.EditAccess";

  contentURL += "&beanName=" + tableBeanName;
  fs.setBeanName(tableBeanName);

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);

  fs.removeDialogWarning();


  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);
%>
