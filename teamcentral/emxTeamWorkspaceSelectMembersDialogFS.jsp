<%--  emxTeamWorkspaceSelectMembersDialogFS.jsp   - Display Frameset for Add Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamWorkspaceSelectMembersDialogFS.jsp.rca 1.18 Wed Oct 22 16:06:07 2008 przemek Experimental przemek $
--%>


<%@include file ="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamWorkspaceSelectMembersDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%

  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String projectId    = emxGetParameter(request,"objectId");
  String organization = emxGetParameter(request,"Organization");
  String role         = emxGetParameter(request,"Role");
  String firstName    = emxGetParameter(request,"firstName");
  String lastName     = emxGetParameter(request,"lastName");
  String strReturn    = emxGetParameter(request,"return");
  String initSource   = emxGetParameter(request,"initSource");
  String getValue     = emxGetParameter(request,"getValue");
  String tableBeanName= "emxTeamWorkspaceSelectMembersDialogFS";
  String absentPerson = emxGetParameter(request,"absentPerson");
  //Below code waas added for Bug299781
  String userName     = emxGetParameter(request,"userName");
//R-024276V6R2011 Start
  String queryLimit   = emxGetParameter(request,"QueryLimit");
//R-024276V6R2011 End  
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.useCache(false);
  fs.setBeanName(tableBeanName);

  if (initSource == null){
      initSource = "";
    }

  if(projectId == null || "".equals(projectId)){
     projectId = "";
    }

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamWorkspaceSelectMembersDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+projectId;
  contentURL += "&organization=" + organization + "&role=" + role + "&firstName=" + firstName;
  contentURL += "&lastName=" + lastName + "&return=" + strReturn;
  contentURL += "&beanName=" + tableBeanName;
  contentURL += "&getValue=" + getValue;
  contentURL += "&absentPerson="+absentPerson + "&sortKey=LastFirstName&sortDir=ascending&sortType=string";
  //Below code waas added for Bug299781
  contentURL += "&userName=" + userName;
//R-024276V6R2011 Start 
  contentURL += "&QueryLimit="+ queryLimit;
//R-024276V6R2011 End
  contentURL = Framework.encodeURL( response, contentURL );

  // Page Heading - Internationalized
  String PageHeading = "emxTeamCentral.Common.SelectMembers";

  // Marker to pass into Help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectmembers";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

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
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);
%>
