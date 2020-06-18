<%--  emxProgramCentralTaksQuestionEditDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/8/2002

  static const char RCSID[] = $Id: emxProgramCentralMandatoryDiscussionDialogFS.jsp.rca 1.14 Wed Oct 22 15:49:34 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String fromPage  = (String) emxGetParameter(request, "fromPage");
  String Directory  = appDirectory;

  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralMandatoryDiscussionDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;
  contentURL += "&fromPage=" + fromPage;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentralCommon.MarkDeleteTask";
  String HelpMarker = "emxhelpmandatorydiscussiondialog";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

/*
  3) vs: you might need contextual actions
  fs.createHeaderLink(String displayString, String href, String roleList,
                      boolean popup, boolean isJavascript, String iconImage, int WindowSize)
*/

  String submitStr = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";

  fs.createFooterLink(submitStr, "submitForm()", "role_GlobalUser",
                      false, true, "emxUIButtonDone.gif", 0);

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>
