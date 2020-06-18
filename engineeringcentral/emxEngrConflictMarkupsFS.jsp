<%--  emxEngrConflictMarkupsFS.jsp  -  Resolve Markup Conflict Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<jsp:useBean id="emxEngrCommonPartSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxEngrConflictMarkupsFS";

  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  String emxSuiteDirectory = emxGetParameter(request,"emxSuiteDirectory");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String relId = emxGetParameter(request,"relId");
  String objectId = emxGetParameter(request,"objectId");
  String parentOID = emxGetParameter(request,"parentOID");
  String strKey = emxGetParameter(request,"key");
  String strLevel = emxGetParameter(request,"level");
  String strTimeStamp = emxGetParameter(request,"timeStamp");


  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrConflictMarkups.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&relId=" + relId + "&objectId=" + objectId +"&level=" + strLevel;
  contentURL += "&emxSuiteDirectory=" + emxSuiteDirectory + "&parentOID=" + parentOID +"&key="+strKey +"&timeStamp="+strTimeStamp;

  fs.setBeanName(tableBeanName);

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Markup.ResolveConflict";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpfindselect";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,true,false);

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  String roleList ="role_GlobalUser";


  fs.createCommonLink("emxFramework.Command.Done","submit()",roleList,false,true,"common/images/buttonDialogDone.gif",false,3);


  fs.createCommonLink("emxFramework.Command.Cancel","parent.closeWindow()",roleList,false,true,"common/images/buttonDialogCancel.gif",false,5);



  fs.writePage(out);

%>
