<%--emxTeamFindLikeQueryFS.jsp - Frameset page of the Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamFindLikeQueryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");

  if (initSource == null) {
    initSource = "";
  }

  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String suiteKey         = emxGetParameter(request,"suiteKey");
  String ComboTypeSymbolic= emxGetParameter(request,"ComboTypeSymbolic");
  String sLink            = emxGetParameter(request,"page");
  String sSearchType      = emxGetParameter(request,"searchType");
  // Page Heading - Based on type
  String PageHeading = "";
  if (ComboTypeSymbolic.equalsIgnoreCase("type_Document")){
    PageHeading = "emxTeamCentral.FindLike.Document.Results";
  }else if (ComboTypeSymbolic.equalsIgnoreCase("type_Package")){
    PageHeading = "emxTeamCentral.FindLike.Package.Results";
  }else if (ComboTypeSymbolic.equalsIgnoreCase("type_RequestToSupplier")){
    PageHeading = "emxTeamCentral.FindLike.RTS.Results";
  }else if (ComboTypeSymbolic.equalsIgnoreCase("type_RTSQuotation")){
    PageHeading = "emxTeamCentral.FindLike.RTSQuotation.Results";
  }else{
    PageHeading = "emxTeamCentral.FindLike.Common.Results";
  }

  String tableBeanName    = "emxTeamFindLikeQueryFS";
  String HelpMarker       = "emxhelpfindlike";
  String strParams        = "";



   Enumeration paramNames  = request.getParameterNames();
   Map paramMap = new HashMap();
   while(paramNames.hasMoreElements()) {
       String paramName = (String)paramNames.nextElement();
       String paramValue = emxGetParameter(request,paramName);
       paramMap.put(paramName, paramValue);
  }
  session.setAttribute("strParams", paramMap);

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamFindLikeQuery.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&beanName=" + tableBeanName+ "&page="+sLink;
  contentURL += "&searchType="+sSearchType;
 
  String sQueryLimit = emxGetParameter(request,"QueryLimit");
  contentURL += "&sQueryLimit="+sQueryLimit;

 
  contentURL = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(contentURL);
  contentURL = Framework.encodeURL(response, contentURL);

  fs.setDirectory(appDirectory);
  fs.useCache(false);
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,true,false);
  fs.setBeanName(tableBeanName);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();
  fs.createCommonLink("emxTeamCentral.Button.NewSearch",
                      "newSearch()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "default",
                      true,
                      3);
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);

%>
