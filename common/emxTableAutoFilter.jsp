<%--  emxTableAutoFilter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableAutoFilter.jsp.rca 1.8 Wed Oct 22 15:48:17 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String suiteKey     = emxGetParameter(request,"suiteKey");

  fs.setDirectory(appDirectory);

  String timeStamp = emxGetParameter(request, "timeStamp");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTableAutoFilterDisplay.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&timeStamp="+timeStamp;

  fs.setStringResourceFile("emxFrameworkStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.TableComponent.AutoFilterHeader";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpfiltercolumns";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createHeaderLink("emxFramework.IconMail.Button.Reset",
                        "resetFilters()",
                        "role_GlobalUser",
                        false,
                        true,
                        "",
                      3);

  fs.createFooterLink("emxFramework.Common.Done",
                      "filterTable()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxFramework.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
