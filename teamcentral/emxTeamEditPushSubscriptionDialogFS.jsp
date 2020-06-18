<%--  emxTeamEditPushSubscriptionDialogFS.jsp   -   Frameset page for editing push subscription.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamEditPushSubscriptionDialogFS.jsp.rca 1.11 Wed Oct 22 16:06:01 2008 przemek Experimental przemek $
--%>

<%@ include file ="../emxUIFramesetUtil.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id = "emxTeamEditPushSubscriptionDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs     = new framesetObject();
  String tableBeanName  = "emxTeamEditPushSubscriptionDialogFS";
  String initSource     = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String Directory          = appDirectory;
  String objectId           = emxGetParameter(request,"objectId");
  String chkSubscribeEvent  = emxGetParameter(request,"chkSubscribeEvent");
  String projectId          = emxGetParameter(request,"projectId");
  String PageHeading        = "emxTeamCentral.Common.PushSubscriptionRecipients";
  String HelpMarker         = "emxhelpeditpushsubscriptionrecipients";

  // Specify URL to come in middle of frameset
  String contentURL         = "emxTeamEditPushSubscriptionDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&projectId="+ projectId + "&flag=pushSubscription&chkSubscribeEvent="+chkSubscribeEvent+"&objectId="+objectId;
  contentURL += "&beanName=" + tableBeanName;
  contentURL                = Framework.encodeURL(response,contentURL);

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)

  StringList sVPLMRoleList = new StringList(4);
	  sVPLMRoleList.addElement("VPLMAdmin");
	  sVPLMRoleList.addElement("VPLMViewer");
	  sVPLMRoleList.addElement("VPLMProjectLeader");
	  sVPLMRoleList.addElement("VPLMCreator");
	
	 String roles = PersonUtil.getVPLMChildrenRoleList(context, sVPLMRoleList); 
	 roles = roles.concat(",role_ExchangeUser,role_CompanyRepresentative"); 
  
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.setDirectory(Directory);
  fs.useCache(false);
  fs.setBeanName(tableBeanName);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setObjectId(objectId);
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.AddRecipients",
                      "addSelected()",                      
                      roles,
                      false,
                      true,
                      "default",
                      true,
                      0);

  fs.createCommonLink("emxTeamCentral.Button.RemoveSelected",
                      "removeSelected()",
                      roles,
                      false,
                      true,
                      "default",
                      false,
                      0);

  fs.createCommonLink("emxTeamCentral.Button.Close",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);
  fs.writePage(out);
%>
