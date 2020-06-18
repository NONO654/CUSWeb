<%--  emxProgramCentralMemberEditAccessDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/8/2002

  static const char RCSID[] = $Id: emxProgramCentralMemberEditAccessDialogFS.jsp.rca 1.12 Wed Oct 22 15:50:31 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String personId   = emxGetParameter(request,"personId");
  String userType   = emxGetParameter(request,"userType");
  String Directory  = appDirectory;

  //Start:11-June-10:ak4:R210:PRG:Bug:047788
  if(userType.equals(com.matrixone.apps.common.MemberRelationship.TYPE_PERSON)){
  //End:11-June-10:ak4:R210:PRG:Bug:047788
  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralMemberEditAccessDialog.jsp?busId="+ objectId;
  // add these parameters to each content URL, and any others the App needs
  contentURL += "&suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&personId=" + personId + "&userType=" + userType;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.ModifyMemberAccessAndRole";
  String HelpMarker = "emxhelpmembereditaccessdialog";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

/*
  3) vs: you might need contextual actions
  fs.createHeaderLink(String displayString, String href, String roleList,
                      boolean popup, boolean isJavascript, String iconImage, int WindowSize)
*/

  String submitStr = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";

  fs.createFooterLink(submitStr, "submitFormEdit()", "role_GlobalUser",
                      false, true, "emxUIButtonDone.gif", 0);

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
  }
  //Start:11-June-10:ak4:R210:PRG:Bug:047788
  else{
	  %>
	   <script language="javascript" type="text/javaScript">  
           alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Access.GroupAndRole.CannotEdit</emxUtil:i18nScript>");
           window.closeWindow();
           </script>
	  <% 
  }
 //End:11-June-10:ak4:R210:PRG:Bug:047788
%>
