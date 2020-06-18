<%--  emxProgramCentralDashboardsCollectionListFS.jsp  -  

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,  Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  Reviewed for Level III compliance by JDH 5/6/2002

  static const char RCSID[] = $Id: emxProgramCentralDashboardsSummaryFS.jsp.rca 1.14 Wed Oct 22 15:49:19 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID      = emxGetParameter( request, "jsTreeID" );
  String suiteKey      = emxGetParameter( request, "suiteKey" );
  String initSource    = emxGetParameter( request, "initSource" );
  String objectId      = emxGetParameter( request, "objectId" );
  String Directory     = appDirectory;

  framesetObject fs = new framesetObject(  );
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if ( initSource == null ) {
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralDashboardsSummary.jsp?";
  // can't send busId=null,  so have to check for it
  if( objectId != null && !objectId.equals( "null" ) ) {
    contentURL += "busId=" + objectId + "&";
  }

  // add these parameters to each content URL,  and any others the App needs
  contentURL += "suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.ProgramTop.Dashboards";
  String HelpMarker = "emxhelpdashboardssummary";

  /* 2 ) vs: change this: for boolean values
  fs.initFrameset( 
    String 	pageHeading, 
    String 	helpMarker, 
    String 	middleFrameURL, 
    boolean 	UsePrinterFriendly, 
    boolean 	IsDialogPage, 
    boolean 	ShowPagination, 
    boolean 	ShowConversion
    int  	MaxTopLinks ( Optional )
  )
  */

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  /*
  3 ) vs: you might need contextual actions ( is HeaderLink is true ) and/or 
         actions using selected checkboxes ( isHeaderLink is false )
     To get the action links you need to use
  fs.createCommonLink( 
    String 	displayString, 
    String 	href, 
    String 	roleList, 
    boolean 	popup, 
    boolean 	isJavascript, 
    String 	iconImage, 
    boolean 	isHeaderLink
    int 		WindowSize
  )
  */

  String createNewDashboard = "emxProgramCentral.Common.CreateDashboard";
  String createNewDashboardURL = "emxProgramCentralDashboardsCreateDialogFS.jsp";
  String delete = "emxProgramCentral.Button.Delete";

  fs.createHeaderLink( createNewDashboard, 
                       createNewDashboardURL, 
                       "role_GlobalUser", 
                       true, 
                       false, 
                       "default", 
                       3);

  fs.createFooterLink(delete, "submitDelete()", "role_GlobalUser",
                      false, true, "default", 0);

  // 4 ) vs: Define any Filters to show up in drop down
  // fs.addFilterOption( Display String ( Internationalized ),  parameter Value )
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage( out );

%>
<html>
</html>
