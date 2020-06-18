<%--  emxTeamSelectWorkspaceMembersDialogFS.jsp   - Display Frameset for Add Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSelectWorkspaceMembersDialogFS.jsp.rca 1.18 Wed Oct 22 16:06:29 2008 przemek Experimental przemek $
--%>


<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id  = "emxTeamSelectWorkspaceMembersDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  framesetObject fs = new framesetObject();
  String tableBeanName = "emxTeamSelectWorkspaceMembersDialogFS";
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String Directory = appDirectory;

  fs.setDirectory(Directory);
fs.useCache(false);
  // Specify URL to come in middle of frameset

  String projectId         = emxGetParameter(request,"projectId");
  String sRouteId          = emxGetParameter(request, "routeId");
  String firstPersonName   = emxGetParameter(request, "firstName");
  String lastPersonName    = emxGetParameter(request, "lastName");
  String role              = emxGetParameter(request, "role");
  String flag              = emxGetParameter(request,"flag");
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent");
  String objectId          = emxGetParameter(request,"objectId");
  String strnoSearch       = emxGetParameter(request,"noSearch");
  String strCompany        = emxGetParameter(request,"company");
  String sfromPage         = emxGetParameter(request,"fromPage");
  String userName          = emxGetParameter(request,"userName");
  String searchFlag        = emxGetParameter(request,"searchFlag");
  //searchFlag

  String contentURL = "emxTeamSelectWorkspaceMembersDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&projectId="+projectId+"&routeId="+sRouteId;
  contentURL += "&firstName="+firstPersonName+"&lastName="+lastPersonName+"&role="+role+"&flag="+flag+"&chkSubscribeEvent="+chkSubscribeEvent+"&objectId="+objectId;
  contentURL += "&beanName=" + tableBeanName + "&noSearch=" + strnoSearch + "&company=" + strCompany+"&fromPage="+sfromPage;
  contentURL += "&userName=" + userName + "&searchFlag=" + searchFlag;

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxTeamCentral.WorkSpaceAddMembersDialog.AddMembers";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpaddworkspacemembersforroute";

  contentURL = Framework.encodeURL(response,contentURL);
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))

  if(sfromPage != null && !"routeWizard".equals(sfromPage.trim()))
  {
    fs.createCommonLink("emxTeamCentral.Button.NewSearch",
                        "newSearch()",
                        "role_CompanyRepresentative,role_ExchangeUser",
                        false,
                        true,
                        "default",
                        true,
                        3);
  }
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitForm()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.removeDialogWarning();
  fs.writePage(out);
%>
