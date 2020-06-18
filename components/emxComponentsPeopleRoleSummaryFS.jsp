<%--  emxComponentsPeopleRoleSummaryFS.jsp   -   Create Frameset for Person Roles
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleRoleSummaryFS.jsp.rca 1.20 Wed Oct 22 16:18:43 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  framesetObject fs = new framesetObject();

  String keyPerson = emxGetParameter(request,"keyPerson");

  formBean.processForm(session,request,"keyPerson");

  String initSource = (String)formBean.getElementValue("initSource");
  if (initSource == null || "null".equals(initSource)){
    initSource = "";
  }

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  String organizationId   = (String)formBean.getElementValue("objectId");
  String sCheckedRList[]  = formBean.getElementValues("chkItem1");

  String contentURL = "emxComponentsPeopleRoleSummary.jsp";
  String sChkRole ="";
  if(sCheckedRList!= null) {
    for (int i=0;i<sCheckedRList.length;i++) {
     sChkRole =   sChkRole+sCheckedRList[i]+"|";
    }
  }
  
  formBean.setElementValue("chkItem1",sChkRole);
  formBean.setElementValue("showWarning","false");

  formBean.setFormValues(session);
 
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?keyPerson=" + keyPerson +"&showWarning=false";

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(organizationId);

  String PageHeading = "emxComponents.Common.PeopleRoles";

  // Marker to pass into Help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateperson2";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.removeDialogWarning();

  fs.createCommonLink("emxComponents.Common.AddRole",
                        "addRoles()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        true,
                        3);

  fs.createCommonLink("emxComponents.AddMembersDialog.AddGroup",
                        "addGroups()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        true,
                        3);
                        
  fs.createCommonLink("emxComponents.Button.RemoveSelected",
                        "removeSelected()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        false,
                        3);                        

  fs.createCommonLink("emxComponents.Button.Previous",
                        "goBack()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogPrevious.gif",
                        false,
                        3);

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

 fs.writePage(out);

%>
