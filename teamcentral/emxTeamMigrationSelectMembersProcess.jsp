<%--  emxTeamMigrationSelectMembersProcess.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamMigrationSelectMembersProcess.jsp.rca 1.20 Wed Oct 22 16:05:58 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "emxTeamGrantAccess.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  String projectId      = emxGetParameter(request, "objectId");
  String strReturn      = emxGetParameter(request,"return");
  String timeStamp = emxGetParameter(request,"timeStamp");
  HashMap tableData = tableBean.getTableData(timeStamp);
  HashMap requestMap = tableBean.getRequestMap(tableData);
  String type      = (String)requestMap.get("type");
  String strTableRowIds[] = request.getParameterValues("emxTableRowId");
  
  if(type.equals("Person"))
  {
  String projectMemberStr       = Framework.getPropertyValue( session, "type_ProjectMember");
  String projectMemberPolicyStr = Framework.getPropertyValue( session, "policy_ProjectMember");
  String projectMembershipStr   = Framework.getPropertyValue( session, "relationship_ProjectMembership");
  String projectMembersStr      = Framework.getPropertyValue( session, "relationship_ProjectMembers");

  Workspace workspace = (Workspace)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,
         DomainConstants.TEAM);

  boolean hasAccess = false;
  try{
    // check if the user has access to add members
    hasAccess = AccessUtil.isOwnerWorkspaceLead(context, projectId);
  } catch(Exception ex) {
    throw(ex);
  }
  if(hasAccess) {
    //get the value passed from the hidden fields, not from the checkboxes

    BusinessObject newMember = null;
    BusinessObject newProjectMember = null;
    workspace.setId(projectId);
    SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
    workspace.open(context);
    String strProjectVault = workspace.getVault();
    for(int i=0;i<strTableRowIds.length; i++) {
      // get the member object
      boolean bopen = false;
      newMember = new BusinessObject(strTableRowIds[i]);
      newMember.open(context);
      // add ProjectMember only if not there already
        try {
          String strNewProjectMemberName = newMember.getName() + workspace.getRevision();
          // create ProjectMember object with TNRV
          newProjectMember =  new BusinessObject( projectMemberStr, strNewProjectMemberName, "-", strProjectVault);
          newProjectMember.create(context, projectMemberPolicyStr);
          newProjectMember.open(context);
          bopen = true;
          //JSPUtil.getProjectMember(context, session, projectId, newMember);
          // connect Member with ProjectMember
		try{
			  newMember.connect(context, new RelationshipType(projectMembershipStr), true, newProjectMember);
			  // connect Project with ProjectMember and set the Project Access attribute to Project Lead
			  workspace.connect(context, new RelationshipType(projectMembersStr), true, newProjectMember);
%>
			  <%@ include file = "emxTeamCommitTransaction.inc" %>
<%
		   }
		   catch(Exception exp)
		   {	 
%>
			  <%@  include file="emxTeamAbortTransaction.inc" %>
<%
		   }
                   String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Person");
          if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
            MailUtil.setTreeMenuName(context, treeMenu );
          }
          subscriptionMgr.publishEvent(context, workspace.EVENT_MEMBER_ADDED, newMember.getObjectId());
          newProjectMember.close(context);
          newMember.close(context);
        } catch( MatrixException me) {
          if(bopen) {
            newProjectMember.close(context);
            newMember.close(context);
          }
        }

    }
    workspace.close(context);
  }
  }
  else
  {
      StringList roleList = new StringList();
      String strRole = "";
      Iterator listItr ;
      Access access = new Access();
      AccessUtil accessUtil = new AccessUtil();


      if(strTableRowIds != null) {
		 for(int i=0;i<strTableRowIds.length; i++) {
          strRole = strTableRowIds[i];
          if(!"".equals(strRole)){
            accessUtil.setMemberRead(strRole);
          }
        }
      }
      try{
        if(accessUtil.getAccessList().size() > 0){
          emxGrantAccess GrantAccess = new emxGrantAccess(new DomainObject(projectId));
          GrantAccess.grantAccess(context, accessUtil);
        }
      }catch(Exception Ex){
        System.out.println("Exception :"+Ex.getMessage());
      }
  }
%>

<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
var detailsDisplay = openerFindFrame(getTopWindow(), 'detailsDisplay');
  if(detailsDisplay){
	  detailsDisplay.location.href = detailsDisplay.location.href;
    }else{
      getTopWindow().location.reload();
    }
    parent.window.closeWindow();
</script>
</body>
</html>
