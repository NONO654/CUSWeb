<%--   emxComponentsPersonSearchFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPersonSearchFS.jsp.rca 1.1.7.5 Wed Oct 22 16:18:33 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%
  framesetObject fs = new framesetObject();
  
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String objectId   = emxGetParameter(request,"objectId");
  String selection      = emxGetParameter(request,"selection");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");
  String formName   = emxGetParameter(request,"formName");
  String fieldNameDisplay  = emxGetParameter(request,"fieldNameDisplay");
  String fieldNameActual  = emxGetParameter(request,"fieldNameActual");
  String fromChooser  = emxGetParameter(request,"fromChooser");
  String submitURL  = emxGetParameter(request,"submitURL");


  if(suiteKey == null || "null".equalsIgnoreCase(suiteKey) || "".equalsIgnoreCase(suiteKey))
  {
        suiteKey="Components";
  }

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer();
  contentURL.append("emxComponentsPersonSearch.jsp");
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&selection=");
  contentURL.append(selection);
  contentURL.append("&showCompanyAsLabel=");
  contentURL.append(showCompanyAsLabel);
  contentURL.append("&defaultCompany=");
  contentURL.append(defaultCompany);
  contentURL.append("&formName=");
  contentURL.append(formName);
  contentURL.append("&fieldNameDisplay=");
  contentURL.append(fieldNameDisplay);
  contentURL.append("&fieldNameActual=");
  contentURL.append(fieldNameActual);
  contentURL.append("&fromChooser=");
  contentURL.append(fromChooser);
  contentURL.append("&submitURL=");
  contentURL.append(submitURL);
  
  String PageHeading = "emxComponents.Common.FindPerson";
  String HelpMarker = "emxhelpselectuser";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
 
  String rolesList = "role_GlobalUser";


  fs.createCommonLink("emxComponents.Button.Search",
                      "doSearch()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

 
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);
%>
