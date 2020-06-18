<%--
   emxComponentsPotentialCustomersSearchResultsFS.jsp -
   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPotentialCustomersSearchResultsFS.jsp.rca 1.5 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>
<jsp:useBean id="emxComponentsPotentialCustomersSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  String tableBeanName = "emxComponentsPotentialCustomersSearchResultsFS";
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();
  fs.setBeanName(tableBeanName);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsPotentialCustomersSearchResults.jsp";

  String sUrl = emxGetParameter(request,"typename");
  String objectId   = emxGetParameter(request,"objectId");
  String sName = emxGetParameter(request,"txtName");
  String sPagination= emxGetParameter(request,"pagination");
  String sQueryLimit = emxGetParameter(request,"QueryLimit");

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&beanName=" + tableBeanName;
  contentURL += "&txtName="+sName+"&typename="+sUrl+"&objectId="+objectId + "&pagination=" + sPagination + "&QueryLimit=" + sQueryLimit;


  // Page Heading - Internationalized
  String PageHeading = "emxComponents.PotentialSuppliers.SearchResultsHeading";
  String HelpMarker = "emxhelpdesignatepotentialsuppliers";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.removeDialogWarning();
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  
  fs.setToolbar("SCSPotentialCustomersResultsToolbar");
  fs.createCommonLink("emxComponents.Button.Done",
                      "designate()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);
%>
