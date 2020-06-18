<%--  emxTeamGenericSelectFolderDialogFS.jsp   -   Create Frameset for New TopLevel Folder

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamGenericSelectFolderDialogFS.jsp.rca 1.11 Wed Oct 22 16:06:14 2008 przemek Experimental przemek $
--%>


<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<jsp:useBean id="emxTeamGenericSelectFolderDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs = new framesetObject();
  String Directory  = appDirectory;
  String tableBeanName = "emxTeamGenericSelectFolderDialogFS";
  fs.setDirectory(Directory);
  fs.useCache(false);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String objectId   = emxGetParameter(request,"objectId");
  String sProjectId = emxGetParameter(request,"projectId");
  String strRouteId = emxGetParameter(request,"routeId");
  String sCallPage  = emxGetParameter(request, "callPage");
  String sFormName  = emxGetParameter(request, "formName");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamGenericSelectFolderDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId + "&projectId=" + sProjectId+"&routeId="+strRouteId;
  contentURL +="&callPage="+sCallPage;
  contentURL +="&formName="+sFormName;
  contentURL += "&beanName=" + tableBeanName;

  String PageHeading  = "emxTeamCentral.UploadFolderDialogFS.Heading";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
//  String HelpMarker = "emxhelpselectfolders";
 // String HelpMarker = "emxhelpselectfolders";
  String HelpMarker = "emxhelpselectfolders";
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,true,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();
  fs.setBeanName(tableBeanName);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))

  fs.createCommonLink("emxTeamCentral.Button.Done",
                        "submitForm()",
                        "role_ExchangeUser,role_CompanyRepresentative",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        false,
                        3);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                        "closeWindow()",
                        "role_Buyer,role_Supplier,role_ExchangeUser",
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        false,
                        3);


  fs.writePage(out);

%>

