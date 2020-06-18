<%-- emxTeamSubFoldersViewFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamSubFoldersViewFS.jsp.rca 1.15 Wed Oct 22 16:06:20 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamSubFoldersViewFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxTeamSubFoldersViewFS";
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
fs.useCache(false);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId   = emxGetParameter(request,"objectId");

  String contentURL = "emxTeamSubFoldersView.jsp";

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&objectId="+objectId;
  contentURL += "&beanName=" + tableBeanName;

  String PageHeading = "emxTeamCentral.Common.Subfolders";

  String HelpMarker = "emxhelpsubfolders";

  fs.setBeanName(tableBeanName);
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,false,true,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  fs.setObjectId(objectId);

  fs.createCommonLink("emxTeamCentral.Button.CreateNew",
                      "showEditDialogPopup()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_VPLMAdmin,role_VPLMViewer,role_VPLMProjectLeader,role_VPLMExperimenter,role_VPLMCreator",
                      false,
                      true,
                      "default",
                      true,
                      3);

  fs.createCommonLink("emxTeamCentral.Button.RemoveSelected",
                      "showDeleteDialogPopup()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_VPLMAdmin,role_VPLMViewer,role_VPLMProjectLeader,role_VPLMExperimenter,role_VPLMCreator",
                      false,
                      true,
                      "default",
                      true,
                      0);

  fs.writePage(out);
%>
