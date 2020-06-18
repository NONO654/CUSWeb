<%--  emxComponentsSpecifyShareTypesFS.jsp  -  FS page for emxComponentsSpecifyShareTypes.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSpecifyShareTypesFS.jsp.rca 1.7 Wed Oct 22 16:18:20 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxComponentsCommonUtilAppInclude.inc"%>

<%
  framesetObject fs     = new framesetObject();
  fs.setDirectory(appDirectory);
  
  String objectId     = emxGetParameter(request,"objectId");
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  
  // ids of the checkbox selected in the results page
  String selectedIds  = emxGetParameter(request, "selectedIds");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsSpecifyShareTypes.jsp";
  contentURL += "?objectId="+objectId+"&suiteKey=" + suiteKey + "&jsTreeID=" + jsTreeID+"&selectedIds="+selectedIds;
  
  String PageHeading = "emxComponents.Collaborate.SpecifyShareTypes";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpeditsharetypes";
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  // remove the warning 
  fs.removeDialogWarning();
  // setting the string resource file
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.createFooterLink("emxComponents.Button.Done",
                        "createCollaborationRequests()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        3);

  fs.createFooterLink("emxComponents.Button.Cancel",
                        "getTopWindow().closeWindow()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        3);
  fs.writePage(out);
%>
