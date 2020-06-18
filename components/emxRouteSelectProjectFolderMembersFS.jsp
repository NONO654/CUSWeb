 <%--  emxRouteSelectProjectFolderMembersFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/2/2002

  static const char RCSID[] = $Id: emxRouteSelectProjectFolderMembersFS.jsp.rca 1.6 Wed Oct 22 16:18:04 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc" %>

<jsp:useBean id="emxRouteSelectProjectFolderMembersFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%

  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
  com.matrixone.apps.common.Route route = (com.matrixone.apps.common.Route) DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);

  String jsTreeID          = emxGetParameter(request,"jsTreeID");
  String suiteKey          = emxGetParameter(request,"suiteKey");
  String initSource        = emxGetParameter(request,"initSource");
  String objectId          = emxGetParameter(request,"objectId");
  String objectName        = emxGetParameter(request,"objectName");
  String topParentHolderId = emxGetParameter(request,"topVaultHolderId");
  String tableBeanName     = "emxRouteSelectProjectFolderMembersFS";
  String Directory         = appDirectory;

  String memberType = emxGetParameter(request,"memberType");
  String routeId = emxGetParameter(request,"routeId");

    String keyValue = emxGetParameter(request, "keyValue");

  framesetObject fs = new framesetObject();
  fs.setBeanName(tableBeanName);
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxComponentsStringResource");

 String PageHeading ="";
 if(memberType.equalsIgnoreCase("Role"))
 {
	PageHeading= "emxComponents.AddRoles.SelectRoles";
 }
  if(memberType.equalsIgnoreCase("Group"))
 {
	PageHeading= "emxComponents.AddGroups.SelectGroups";
 }
 if(memberType.equalsIgnoreCase("Person"))
 {
	PageHeading= "emxComponents.AddPeople.SelectPeople";
 }


  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectroles";


  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  StringList busSelects = new StringList(2);

  //If topParentHolderId was not passed in then caculate it
  if ( topParentHolderId == null || "null".equals(topParentHolderId) || "".equals(topParentHolderId)) {
    //Selectables needed for finding topParentHolderId
    busSelects.add(workspaceVault.SELECT_ID);
    busSelects.add(workspaceVault.SELECT_TYPE);

    //Obtain projectId or projectTemplateId
    workspaceVault.setId(objectId);
    workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
    Map topVaultMap   = workspaceVault.getTopLevelVault(context, busSelects);
    String topVaultId = (String) topVaultMap.get(workspaceVault.SELECT_ID);

    //reset workspaceVault for top level vault
    workspaceVault.clear();
    workspaceVault.setId(topVaultId);
    topParentHolderId = workspaceVault.getInfo(context, workspaceVault.SELECT_VAULT_HOLDER_ID);

    //If it is still null then the parent may be a route
    if (topParentHolderId == null || "null".equals(topParentHolderId) || "".equals(topParentHolderId)) {
        String SELECT_VAULT_HOLDER_ID = "from[" +
        route.RELATIONSHIP_OBJECT_ROUTE + "].to.id";
        topParentHolderId = workspaceVault.getInfo(context, SELECT_VAULT_HOLDER_ID);
    }
  }
  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteSelectProjectFolderMembers.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource
                + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId
                + "&topParentHolderId=" + topParentHolderId + "&beanName=" + tableBeanName+"&memberType="+memberType+"&routeId="+routeId+"&keyValue="+keyValue;

//(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  // ----------------- Do Not Edit Below ------------------------------
  fs.removeDialogWarning();
  fs.writePage(out);
%>

