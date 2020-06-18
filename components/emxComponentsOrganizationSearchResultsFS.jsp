<%--  emxComponentsOrganizationSearchResultsFS.jsp  -  Search summary frameset

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsOrganizationSearchResultsFS.jsp.rca 1.1.7.5 Wed Oct 22 16:17:53 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<% 
  framesetObject fs = new framesetObject();
  String suiteKey   = emxGetParameter(request,"suiteKey");
  if(suiteKey==null || suiteKey.equals("null")){
    suiteKey="";
  }

  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();
  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsOrganizationSearchResults.jsp";
  contentURL += "?suiteKey=" + suiteKey;

  // Loop through parameters and pass on to summary page
  for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
      String name  = (String) names.nextElement();
      String value = emxGetParameter(request, name);

      String param = "&" + name + "=" + value;
      contentURL += param;
  }

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Common.Select";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearch";


  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");

  String roleList ="role_GlobalUser";

  fs.createHeaderLink("emxComponents.Command.NewSearch",
                      "newSearch()",
                      roleList,
                      false,
                      true,
                      "default",
                      0);


  fs.createFooterLink("emxComponents.Common.Select",
                      "selectDone()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  fs.createFooterLink("emxComponents.Common.Cancel",
                      "parent.window.close()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
  fs.writePage(out);

%>

