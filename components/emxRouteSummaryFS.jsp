<%-- emxRouteSummaryFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSummaryFS.jsp.rca 1.12 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id  =  "emxCommonRouteSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs    = new framesetObject();
  String tableBeanName = "emxCommonRouteSummaryFS";
  String initSource    = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  fs.setDirectory(appDirectory);

  String objectId  = emxGetParameter(request,"objectId");

  StringBuffer contentURL = new StringBuffer(128);
  contentURL.append("emxRouteSummary.jsp");

  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxComponents.Routes.Heading1";
  String HelpMarker = "emxhelproutes";

  // PageHeading, HelpMarker, middleFrameURL, UsePrinterFriendly, IsDialogPage,
  // ShowPagination, ShowConversion
  fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), true, false,
                  true, false);

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);

  fs.createCommonLink("emxComponents.CreateRouteWizardDialog.CreateNewRoute",
                      "createRoute()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxComponents.Common.DeleteSelected",
                      "showRemoveDialogPopup()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Routes.StartSelected",
                      "showStartResume()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      3);

  fs.writePage(out);
%>
