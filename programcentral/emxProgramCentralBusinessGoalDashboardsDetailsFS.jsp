 <%--  emxProgramCentralBusinessGoalDashboardsDetailsFS.jsp  -

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,  Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  Reviewed for Level III compliance by JDH 5/6/2002

  static const char RCSID[] = $Id: emxProgramCentralBusinessGoalDashboardsDetailsFS.jsp.rca 1.7 Wed Oct 22 15:49:19 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<jsp:useBean id="emxProgramCentralBusinessGoalDashboardsDetailsFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%
  //extract parameters
  String jsTreeID = emxGetParameter( request, "jsTreeID" );
  String suiteKey = emxGetParameter( request, "suiteKey" );
  String initSource = emxGetParameter( request, "initSource" );
  String objectId = emxGetParameter( request, "objectId" );
  String hideGoal = emxGetParameter(request, "hideGoal");
  String Directory = appDirectory;
  String tableBeanName = "emxProgramCentralBusinessGoalDashboardsDetailsFS";

  //initialization
  if(hideGoal == null || hideGoal.equals("null") || hideGoal.equals("")){
    hideGoal = "true";
  }

  framesetObject fs = new framesetObject();
  fs.setBeanName(tableBeanName);
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if ( initSource == null ) {
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralBusinessGoalDashboardsDetails.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&beanName=" + tableBeanName;
  contentURL += "&hideGoal=" + hideGoal + "&topId=" + objectId;


  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.ProgramTop.BusinessGoalDashboard";
  String HelpMarker = "emxhelpbusinessgoaldashboardsdetails";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage( out );

%>
<html>
</html>
