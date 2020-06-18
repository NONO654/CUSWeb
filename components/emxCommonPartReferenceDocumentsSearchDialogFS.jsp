 <%--  emxCommonPartReferenceDocumentsSearchDialogFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%

  String objectId = emxGetParameter(request,"objectId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");

  String searchHeading = "emxFramework.Suites.Display.Common";
  String searchMessage = "emxComponents.Common.Find";
  String searchRefDocs  = "emxComponents.Common.FindReferenceDocuments";

  // Specify URL to come in middle of frameset
  String contentURL = "emxCommonPartReferenceDocumentsSearchDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + objectId + "&suiteKey=" + suiteKey;


  searchFramesetObject fs = new searchFramesetObject();
  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpsearch");

  fs.initFrameset(searchMessage,contentURL,searchHeading,false);

  fs.setStringResourceFile("emxComponentsStringResource");

  // Setup query limit
  //
  String sQueryLimit = JSPUtil.getCentralProperty(application,
                                                  session,
                                                  "eServiceEngineeringCentral",
                                                  "QueryLimit");

  if (sQueryLimit == null || sQueryLimit.equals("null") || sQueryLimit.equals("")) {
    sQueryLimit = "";
  }
  else {
    Integer integerLimit = new Integer(sQueryLimit);
    int intLimit = integerLimit.intValue();
    fs.setQueryLimit(intLimit);
  }

  if (acc.has(Access.cRead)) {
 /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator,role_ComponentEngineer";*/
  String roleList ="role_GlobalUser";

  fs.createSearchLink(searchRefDocs, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);

  }

  fs.writePage(out);

%>





