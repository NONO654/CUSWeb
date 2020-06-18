<%--
  emxProgramGlobals.inc

  Define globally available objects for the Program Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramGlobals2.inc.rca 1.12 Wed Oct 22 15:49:51 2008 przemek Experimental przemek $"
--%>
<%
  final long emxProgramTimerJavaStartTime = System.currentTimeMillis();
%>
<%@ page import = "java.text.*" errorPage="../common/eServiceError.jsp"%>
<%@ page import = "com.matrixone.apps.program.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>
<%@ page import =  "com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.VCDocument,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault,
                    com.matrixone.apps.common.AssignedTasksRelationship,
                    com.matrixone.apps.common.DependencyRelationship,
                    com.matrixone.apps.common.MemberRelationship,
                    com.matrixone.apps.common.ProjectManagement,
                    com.matrixone.apps.common.SubtaskRelationship" %>
<%@ include file="emxProgramContext.inc" %>
<%@ include file="emxProgramTags.inc" %>
<%@ include file="emxProgramVariables.inc" %>
<%@ include file="emxProgramMethods.inc" %>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>

<%

  // used to clean up session attributes create by wbs summmary and modify pages
  String IsActive = (String) emxGetParameter(request,"isActive");
  String TimeStamp = (String) emxGetParameter(request,"timeStamp");
  String HideWBS = (String) emxGetParameter(request,"hideWBS");
  String SessionTimeStamp = (String) emxGetParameter(request,"sessionTimeStamp");

  if(IsActive == null || !IsActive.equals("true") || (HideWBS != null && HideWBS.equals("true"))) {
    if(TimeStamp != null && !TimeStamp.equals("null")) {
      session.removeAttribute("taskList" + TimeStamp);
    } else if(SessionTimeStamp != null && !SessionTimeStamp.equals("null")) {
      session.removeAttribute("taskList" + SessionTimeStamp);
    }
  }

  //Get and store user's company name/id in the PersonUtil
  //then get them later as needed. This will avoid going
  //through the same call/routine to get the user's company name/id everytime.
  //Use this key pair to get/set user's company name.
  //     key:    personName_CompanyName
  //     value:  user's company name
  //     key:    personName_CompanyId
  //     value:  user's company id

  // Create the context object.
	final matrix.db.Context ctx = Framework.getFrameContext(session);
  String login_User_Name       = ctx.getUser();
  String login_User_Id_Key     = login_User_Name + "_Id";
  String user_Company_Name_Key = login_User_Name + "_CompanyName";
  String user_Company_Id_Key   = login_User_Name + "_CompanyId";

  //get user's id
  String login_User_Id         = (String)PersonUtil.getPersonProperty(ctx, login_User_Name, login_User_Id_Key);
  String user_Company_Name = "";
  String user_Company_Id = "";

try {

  if(login_User_Id == null || "".equals(login_User_Id) || "null".equals(login_User_Id))
  {
     login_User_Id = PersonUtil.getPersonObjectID(ctx);
     PersonUtil.setPersonProperty(ctx, login_User_Name, login_User_Id_Key, (Object) login_User_Id);
  }

  //get user's company name and Id
  user_Company_Name = (String)PersonUtil.getPersonProperty(ctx, login_User_Name, user_Company_Name_Key);
  user_Company_Id = (String)PersonUtil.getPersonProperty(ctx, login_User_Name, user_Company_Id_Key);

  if((user_Company_Name == null || "".equals(user_Company_Name) || "null".equals(user_Company_Name)) ||
     (user_Company_Id == null || "".equals(user_Company_Id) || "null".equals(user_Company_Id)))
  {
     user_Company_Id = PersonUtil.getUserCompanyId(ctx);
     //Company companyObject = (Company) DomainObject.newInstance(ctx, user_Company_Id);
     DomainObject companyObject =  DomainObject.newInstance(ctx, user_Company_Id);
     user_Company_Name = companyObject.getInfo(ctx, DomainObject.SELECT_NAME);


     //set user's company name/id into PersonUtil
     PersonUtil.setPersonProperty(ctx, login_User_Name, user_Company_Name_Key, (Object) user_Company_Name);
     PersonUtil.setPersonProperty(ctx, login_User_Name, user_Company_Id_Key, (Object) user_Company_Id);
  }
} finally {        
        ctx.shutdown();
}
%>
