<%--  emxEngrLocationSearchResultsFS.jsp  -  Search summary frameset
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
   framesetObject fs = new framesetObject();
   String suiteKey   = emxGetParameter(request,"suiteKey");
   if(suiteKey==null || suiteKey.equals("null")){
      suiteKey="";
   }

   fs.setDirectory(appDirectory);
   fs.removeDialogWarning();

   // Specify URL to come in middle of frameset
   String contentURL = "emxEngrLocationSearchResults.jsp";
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
   String PageHeading = "emxEngineeringCentral.Common.Select";

   // Marker to pass into Help Pages
   // icon launches new window with help frameset inside
   String HelpMarker = "emxhelpselectcompany";
   String pagination = emxGetParameter(request, "pagination");
   boolean showPagination = true;
   if(pagination == null || "".equals(pagination) || "null".equals(pagination) ) {
      showPagination = true;
   }else if("true".equalsIgnoreCase(pagination)) {
       showPagination = true;
   }

   fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,showPagination,false);

   fs.setStringResourceFile("emxEngineeringCentralStringResource");

   String roleList ="role_GlobalUser";


   fs.createHeaderLink("emxFramework.Command.NewSearch",
                      "newSearch()",
                      roleList,
                      false,
                      true,
                      "default",
                      0);

   fs.createFooterLink("emxFramework.Command.Select",
                      "selectDone()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

   fs.createFooterLink("emxEngineeringCentral.Common.Cancel",
                      "close()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
   fs.writePage(out);

%>
