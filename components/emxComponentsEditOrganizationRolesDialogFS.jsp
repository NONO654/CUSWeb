<%--  emxComponentsEditOrganizationRolesDialogFS.jsp  - Frameset page for eciting a persons roles

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsEditOrganizationRolesDialogFS.jsp.rca 1.6 Wed Oct 22 16:17:49 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<jsp:useBean id="emxComponentsEditOrganizationRolesDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxComponentsEditOrganizationRolesDialogFS";

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String objectId = emxGetParameter(request,"objectId");
  String relId    = emxGetParameter(request,"relId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsEditOrganizationRolesDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + objectId + "&relId=" + relId;
  contentURL += "&beanName=" + tableBeanName;

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL += "&mx.page.filter=" + filterValue;
    fs.setFilterValue(filterValue);
  }

  fs.setBeanName(tableBeanName);

  // Page Heading  - Internationalized
  String PageHeading = "emxComponents.Common.EditOrganizationalRoles";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcompanypeopleroles";
  fs.setObjectId(objectId);

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  //String roleList = "role_DesignEngineer,role_ECRChairman,role_ECRCoordinator,role_ECREvaluator," +
  //                  "role_ManufacturingEngineer,role_OrganizationManager,role_PartFamilyCoordinator," +
  //                  "role_ProductObsolescenceManager,role_SeniorDesignEngineer,role_SeniorManufacturingEngineer,role_BuyerAdministrator,role_SupplierDevelopmentManager";
  String roleList = "role_GlobalUser";

  fs.createCommonLink("emxComponents.Command.Done",
                      "selectDone()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Command.Cancel",
                      "window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>
