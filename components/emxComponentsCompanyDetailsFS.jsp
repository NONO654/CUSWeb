<%--  emxComponentsCompanyDetailsFS.jsp -- This page displays the details of a company.

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCompanyDetailsFS.jsp.rca 1.14 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $;
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>


<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String objectId  = emxGetParameter(request,"objectId");
  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);

  // Specify URL to come in middle of frameset
  String contentURL     = "emxComponentsCompanyDetails.jsp";
  String previousAction = emxGetParameter(request,"previousAction");
  String sPage          = emxGetParameter(request,"page");
  int maxLinks = 4;
  
  // String sLanguage = request.getHeader("Accept-Language");
  // if we come back here after creating an rts we are
  // in a popup so make max links 3 instead of default 4
  if ("create".equalsIgnoreCase(previousAction)){
    maxLinks = 3;
  }

  // add these parameters to each content URL, and any others the App needs

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId="+ objectId + "&previousAction=" + previousAction;

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);

  String PageHeading = "emxComponents.Routes.PropertiesNoRev";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcompanyproperties";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false,maxLinks);
  fs.setToolbar("APPCompanyDetailsToolBar");
  
  fs.writePage(out);

%>
