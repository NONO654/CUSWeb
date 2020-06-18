<%--  emxRouteWizardSearchTemplateDialogFS.jsp  -   Create Frameset for Route Template Search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  // Instantiate searchFramesetObject object
  searchFramesetObject fs = new searchFramesetObject();

  String Directory = appDirectory;


  String scopeId   = emxGetParameter(request,"scopeId");
  String objectId   = emxGetParameter(request,"objectId");
  String workspaceId       = emxGetParameter(request,"workspaceId");
  //Bug 320802
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  String parentFieldObjId  = emxGetParameter(request,"fieldDispObjId");
  //till here 320802


  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  //Prepare the proper contentUrl with all the required parameters

//Bug 320802
  String contentURL = "emxRouteWizardSearchTemplateDialog.jsp";

  contentURL += "?form=" + parentForm + "&field=" + parentField+ "&fieldDisp=" +parentFieldDisp+"&fieldDispObjId="+parentFieldObjId;

  contentURL += "&supplierOrgId=" + supplierOrgId+"&scopeId="+scopeId+"&objectId=" + objectId;
  //till here 320802
  
  if (workspaceId != null && workspaceId.trim().length() > 0) {
	  contentURL += "&workspaceId=" + workspaceId;
  }

  String PageHeading = "emxComponents.SearchTemplate.FindTemplate";
  String HelpMarker = "emxhelpfindroutetemplate";

  //fs.initFrameset(String PageHeader,String contentURL, String searchHeading, boolean showPagination);
  fs.initFrameset(PageHeading,
                  contentURL,
                  "emxComponents.Common.SearchHeading",
                  false
                 );

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setDirectory(Directory);
  fs.setHelpMarker(HelpMarker);

  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding
  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String rolelist);
  fs.createSearchLink("emxComponents.SearchTemplate.FindTemplates",
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
                      "role_GlobalUser"
                     );

  fs.writePage(out);

%>
