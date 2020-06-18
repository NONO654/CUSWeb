<%-- emxRouteWizardSearchTemplateResultsFS.jsp  --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardSearchTemplateResultsFS.jsp.rca 1.6 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String Directory = appDirectory;

  fs.setDirectory(Directory);



 String srcPage      = emxGetParameter(request,"srcPage");
 String scopeId      = emxGetParameter(request,"scopeId");



  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteWizardSearchTemplateResults.jsp";

  String objectId   = emxGetParameter(request,"objectId");
  String sName      = emxGetParameter(request,"txtName");
  String sScope     = emxGetParameter(request,"selScope");


  String supplierOrgId     = emxGetParameter(request,"supplierOrgId");

    //Prepare the proper contentUrl with all the required parameters

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId="+objectId+"&txtName="+sName+"&selScope="+sScope;
  contentURL += "&supplierOrgId="+supplierOrgId+"&scopeId="+scopeId;

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.SearchTemplate.SelectTemplate";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelproutetemplatefind";
  fs.setStringResourceFile("emxComponentsStringResource");

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
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
  fs.removeDialogWarning();
  fs.writePage(out);
%>
