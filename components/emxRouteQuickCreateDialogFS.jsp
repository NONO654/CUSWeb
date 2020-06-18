<%--  emxRouteQuickCreateDialogFS.jsp   -   Create Frameset for Quick Route Create
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxRouteQuickCreateDialogFS.jsp.rca 1.9 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String portalMode   = emxGetParameter(request,"portalMode");

  fs.setDirectory(appDirectory);

  // ----------------- Do Not Edit Above ------------------------------
//Customization for supplier review feature in spec
  String supplierOrgId = "";
  String tableRowId = emxGetParameter(request,"emxTableRowId");
  if(tableRowId != null && !"null".equals(tableRowId) && tableRowId.trim().length() > 0)
  {
    supplierOrgId = tableRowId;
  }
  else
  {
    supplierOrgId = emxGetParameter(request,"supplierOrgId");
  }

  if(supplierOrgId != null && !"null".equals(supplierOrgId) && supplierOrgId.trim().length() > 0 && supplierOrgId.indexOf("|") > -1)
  {
    StringList idList = FrameworkUtil.split(supplierOrgId,"|");
    supplierOrgId = (String)idList.elementAt(1);
  }

  String relatedObjectId = emxGetParameter(request,"objectId");
  String routeId    = emxGetParameter(request, "routeId");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(175);
  contentURL.append("emxRouteQuickCreateDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(relatedObjectId);
  contentURL.append("&routeId=");
  contentURL.append(routeId);
  contentURL.append("&supplierOrgId=");
  contentURL.append(supplierOrgId);
  contentURL.append("&portalMode=");
  contentURL.append(portalMode);


  fs.setStringResourceFile("emxComponentsStringResource");

 // Page Heading - Internationalized
 String PageHeading = "emxComponents.Common.CreateRoute";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
 String HelpMarker = "emxhelpcreatenewroute";
    

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.createFooterLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
