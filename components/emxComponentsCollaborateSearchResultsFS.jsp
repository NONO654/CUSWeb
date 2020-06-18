<%-- emxComponentsCollaborateSearchResultsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCollaborateSearchResultsFS.jsp.rca 1.7 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="emxComponentsCollaborateSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxComponentsCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");

  if (initSource == null) {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String sUrl = emxGetParameter(request,"typename");
  String objectId   = emxGetParameter(request,"objectId");

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  String tableBeanName = "emxComponentsCollaborateSearchResultsFS";
  fs.setBeanName(tableBeanName);

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsCollaborateSearchResults.jsp";

  String sName = emxGetParameter(request,"txtName");
  String sPagination= emxGetParameter(request,"pagination");
  String sQueryLimit = emxGetParameter(request,"QueryLimit");

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&beanName=" + tableBeanName;
  contentURL += "&txtName="+XSSUtil.encodeForURL(context,sName)+"&typename="+sUrl+"&objectId="+objectId + "&pagination=" + sPagination + "&QueryLimit=" + sQueryLimit;

  String PageHeading = "emxComponents.Heading.Search";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpfullsearch";


  // (String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  //fs.removeDialogWarning();
  fs.setToolbar("APPCollaborationSearchResultsToolbar");

  // (String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxComponents.Button.Next",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
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
