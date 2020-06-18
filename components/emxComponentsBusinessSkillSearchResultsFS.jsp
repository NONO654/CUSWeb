<%-- emxRouteRolesSearchResultsFS.jsp -- Frameset for Role Search Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsBusinessSkillSearchResultsFS.jsp.rca 1.6 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%
  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  
  String objectId         = emxGetParameter(request,"objectId");
  String personId         = emxGetParameter(request,"personId");
  String mode 			  = emxGetParameter(request,"mode");
  String PageHeading      = "emxComponents.AddSkills.SearchBusinessSkills";
  String HelpMarker       = "emxhelpskillslevel";
  String[] selectedSkills = emxGetParameterValues(request, "businessSkills");

  session.setAttribute("selectedSkills", selectedSkills);
  

  fs.setDirectory(appDirectory);
  

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(640);
  contentURL.append("emxComponentsBusinessSkillSearchResults.jsp");//changed only the name of file

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&personId=");
  contentURL.append(personId);  
  contentURL.append("&mode=");
  contentURL.append(mode);  

  
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();

  fs.createHeaderLink("emxComponents.Button.NewSearch",
                      "newSearch()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      0);
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
  fs.writePage(out);
%>
