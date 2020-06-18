 <%--  emxCommonPersonSearchResultsFS.jsp  - Frameset page for search result

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonPersonSearchResultsFS.jsp.rca 1.1.7.5 Wed Oct 22 16:18:06 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id="emxCommonRoutePersonSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxCommonRoutePersonSearchResultsFS";
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setBeanName(tableBeanName);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------

  String strFirstName   = emxGetParameter(request,"firstName");
  String strLastName    = emxGetParameter(request,"lastName");
  String strUserName    = emxGetParameter(request,"userName");
  String strCompanyName = emxGetParameter(request,"otherCompanyName");
  String parentForm     = emxGetParameter(request,"form");
  String parentField    = emxGetParameter(request,"fieldNameDisplay");
  String parentidField    = emxGetParameter(request,"fieldNameActual");
  
  //DSC Change Start
  String methodName    		= emxGetParameter(request,"methodName");
  String isWebFormRequest 	= emxGetParameter(request,"isWebFormRequest");
  //DSC Change End


  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect = emxGetParameter(request,"multiSelect");


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(640);
  contentURL.append("emxCommonPersonSearchResults.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&form=");
  contentURL.append(parentForm);
  contentURL.append("&fieldNameDisplay=");
  contentURL.append(parentField);
  contentURL.append("&fieldNameActual=");
  contentURL.append(parentidField);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&UserName=");
  contentURL.append(strUserName);
  contentURL.append("&FirstName=");
  contentURL.append(strFirstName);
  contentURL.append("&LastName=");
  contentURL.append(strLastName);
  contentURL.append("&otherCompanyName=");
  contentURL.append(strCompanyName);
  contentURL.append("&targetSearchPage=");
  contentURL.append(targetSearchPage);
  contentURL.append("&multiSelect=");
  contentURL.append(multiSelect);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  
  //DSC Change Start
  contentURL.append("&methodName=");
  contentURL.append(methodName);
  contentURL.append("&isWebFormRequest=");
  contentURL.append(isWebFormRequest);
  //DSC Change End
  
  contentURL.append("&showWarning=false");
  // Page Heading  - Internationalized
  String PageHeading = "emxComponents.SelectPeople.Step2Heading" ;

    // icon launches new window with help frameset inside

  String HelpMarker = "emxhelpmemlislistadd";


  fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), false, true,
                  true, false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();
  fs.createHeaderLink("emxComponents.Button.NewSearch",
                      "newSearch()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      0);

  fs.createCommonLink("emxComponents.Button.Submit",
                      "selectDone()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);


  fs.createCommonLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
