<%-- emxTeamBuyerDeskSummaryFS.jsp -- FrameSet for Buyer Desk Summary page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamBuyerDeskSummaryFS.jsp.rca 1.13 Wed Oct 22 16:06:15 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamBuyerDeskSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  String tableBeanName = "emxTeamBuyerDeskSummaryFS";
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId  = emxGetParameter(request,"objectId");
  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);

  // add parameters Below
  String formName = emxGetParameter(request,"formName");
  String txtCtrl  = emxGetParameter(request,"txtCtrl");
  String txtId    = emxGetParameter(request,"txtId");


  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamBuyerDeskSummary.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId="+ objectId + "&formName=" + formName + "&txtCtrl=" + txtCtrl + "&txtId=" + txtId;
  contentURL += "&beanName=" + tableBeanName;

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxTeamCentral.BuyerDeskSummary.SelectBuyerDesk";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
//  String HelpMarker = "emxhelpselectbuyerdesk";
  String HelpMarker = "emxhelpsearchquery";
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitForm()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      0);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);

  fs.writePage(out);
%>
