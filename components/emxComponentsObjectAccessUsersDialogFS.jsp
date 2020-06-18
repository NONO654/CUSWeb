<%--  emxObjectAccessUsersDialogFS.jsp   -  Display Frameset for Add AccessUsers dialog page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsObjectAccessUsersDialogFS.jsp.rca 1.4.7.5 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $
--%>
    <%@include file = "../emxUIFramesetUtil.inc"%>
    <%@include file="emxComponentsFramesetUtil.inc"%>

    <jsp:useBean id="emxObjectAccessUsersDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
    <jsp:useBean id="accessFormBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String keyValue = emxGetParameter(request,"keyValue");
    if(keyValue == null)
    {
        keyValue = accessFormBean.newFormKey(session);
    }

    accessFormBean.processForm(session, request, "keyValue");
    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);
    fs.useCache(false);

	String accessChoice = (String) accessFormBean.getElementValue("accessChoice");
	String addUserType = (String) accessFormBean.getElementValue("addUserType");
	String pushGrantor = (String) accessFormBean.getElementValue("pushGrantor");
	String objectId = (String) accessFormBean.getElementValue("objectId");
	String showAllProgram = (String) accessFormBean.getElementValue("showAllProgram");
	String showAllFunction = (String) accessFormBean.getElementValue("showAllFunction");
 	String lbcAccess = (String) accessFormBean.getElementValue("lbcAccess");

    if(addUserType == null || "".equals(addUserType) || "null".equals(addUserType))
    {
        addUserType    =  (String) accessFormBean.getElementValue("addUserType");
    }

    if(addUserType == null || "".equals(addUserType) || "null".equals(addUserType))
    {
        addUserType = "";
    }

    StringList strListUserTypes = FrameworkUtil.split(addUserType, ",");

    String tableBeanName = "emxObjectAccessUsersDialogFS";

    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer();
    contentURL.append("emxComponentsObjectAccessUsersDialog.jsp");

	contentURL.append("?keyValue=");
	contentURL.append(keyValue);
	contentURL.append("&objectId=");
	contentURL.append(objectId);
	contentURL.append("&accessChoice=");
	contentURL.append(accessChoice);
	contentURL.append("&addUserType=");
	contentURL.append(addUserType);
	contentURL.append("&pushGrantor=");
	contentURL.append(pushGrantor);
	contentURL.append("&showAllProgram=");
	contentURL.append(showAllProgram);
	contentURL.append("&showAllFunction=");
	contentURL.append(showAllFunction);
 	if (Boolean.parseBoolean(lbcAccess)) {
		contentURL.append("&lbcAccess=");
		contentURL.append(lbcAccess);
	}

    fs.setStringResourceFile("emxComponentsStringResource");

    // Page Heading - Internationalized
    String PageHeading = "emxComponents.ObjectAccess.AddUsersHeading";

    // Marker to pass into Help Pages
    String HelpMarker= "emxhelpaccessadd";

    fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
    fs.setBeanName(tableBeanName);

    if (strListUserTypes.contains("person"))
    {
        fs.createCommonLink("emxComponents.AddMembersDialog.AddPeople",
                            "addPeople()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            true,
                            3);
    }

    if (strListUserTypes.size() > 0)
    {
        fs.createCommonLink("emxComponents.ActionLink.Remove",
                            "removeMembers()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            false,
                            0);
    }

    if (strListUserTypes.contains("role"))
    {
        fs.createCommonLink("emxComponents.AddMembersDialog.AddRole",
                            "addRole()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            true,
                            3);
    }

    if (strListUserTypes.contains("group"))
    {
        fs.createCommonLink("emxComponents.AddMembersDialog.AddGroup",
                            "addGroup()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            true,
                            3);
    }

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

    fs.removeDialogWarning();
    fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
    fs.writePage(out);
%>

