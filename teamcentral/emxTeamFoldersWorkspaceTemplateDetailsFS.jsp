<%-- emxTeamFoldersWorkspaceTemplateDetailsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamFoldersWorkspaceTemplateDetailsFS.jsp.rca 1.6 Wed Oct 22 16:06:19 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>

<%
try{
    String objectId   = emxGetParameter(request,"objectId");

  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.useCache(false);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");


  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamFoldersWorkspaceDetails.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+objectId;
  String PageHeading = "emxTeamCentral.Common.Properties";
  String HelpMarker = "emxhelpfolderproperties";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  fs.setObjectId(objectId);
  fs.writePage(out);
}catch (MatrixException e){
  throw new MatrixException(i18nNow.getI18nString("emxTeamCentral.Common.PageAccessDenied", "emxTeamCentralStringResource",request.getHeader("Accept-Language")));
}

%>
