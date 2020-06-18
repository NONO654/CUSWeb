<%--  emxTeamSearchWorkSpaceMembersDialogFS.jsp   -   Create Frameset for Route Template Search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%
  String Directory = appDirectory;
  searchFramesetObject fs = new searchFramesetObject();

  String sProjectId        = emxGetParameter(request, "projectId");
  String sRouteId          = emxGetParameter(request, "routeId");
  String flag              = emxGetParameter(request,"flag");
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent");
  String objectId          = emxGetParameter(request,"objectId");
  String sfromPage         = emxGetParameter(request,"fromPage");

  //Prepare the proper contentUrl with all the required parameters
  String contentURL = "emxTeamSearchWorkspaceMembersDialog.jsp?objectId="+objectId+"&projectId="+sProjectId+"&routeId="+sRouteId+"&flag=";
        contentURL  +=flag+"&chkSubscribeEvent="+chkSubscribeEvent+"&fromPage="+sfromPage;
  contentURL = Framework.encodeURL(response,contentURL);

  String searchRoleContentURL = "emxTeamSearchWorkspaceMemberRolesDialog.jsp?objectId="+objectId+"&projectId="+sProjectId+"&routeId="+sRouteId+"&flag=";
        searchRoleContentURL  +=flag+"&chkSubscribeEvent="+chkSubscribeEvent+"&fromPage="+sfromPage;
  searchRoleContentURL = Framework.encodeURL(response,searchRoleContentURL);

  String PageHeading = "emxTeamCentral.RouteWizardAddMembersDialog.AddWorkspaceMembers";
  String HelpMarker = "emxhelpfindroles";

  //fs.initFrameset(String PageHeader,String contentURL, String searchHeading, boolean showPagination);
  fs.initFrameset(PageHeading,
                  contentURL,
                  "emxTeamCentral.SearchCommon.SearchHeading",
                  false
                 );

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setDirectory(Directory);
  fs.setHelpMarker(HelpMarker);

  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding
  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String rolelist);
  fs.createSearchLink("emxTeamCentral.RouteWizardAddMembersDialog.FindPeople",
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
                      "role_CompanyRepresentative,role_ExchangeUser");

  if(flag==null || (flag!=null && !"pushSubscription".equals(flag))){
    fs.createSearchLink("emxTeamCentral.RouteWizardAddMembersDialog.FindRole",
                         com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchRoleContentURL),
                         "role_CompanyRepresentative,role_ExchangeUser");
  }                       

  fs.writePage(out);

%>
