<%--  emxTeamWorkspaceSelectMembersProcess.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamWorkspaceSelectMembersProcess.jsp.rca 1.20 Wed Oct 22 16:05:58 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String projectId      = emxGetParameter(request, "objectId");
  String strReturn      = emxGetParameter(request,"return");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  //preload lookup strings
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
     workspace.setId(projectId);      
     
    //get the value passed from the hidden fields, not from the checkboxes
    String idArray       = emxGetParameter(request,"idArrayHidden");
    String fromPage    = emxGetParameter(request, "fromPage");
    if("WorkspaceWizard".equals(fromPage)) {
        String[] sPersonList          = request.getParameterValues("emxTableRowId");
        sPersonList        = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(sPersonList);
        idArray = com.matrixone.apps.common.util.ComponentsUIUtil.arrayToString(sPersonList, ",");
    }
    
    matrix.db.AccessList accessList = workspace.getAccessForGrantor(context, com.matrixone.apps.domain.util.AccessUtil.WORKSPACE_MEMBER_GRANTOR);
    matrix.util.StringList existingMembers = new matrix.util.StringList(accessList.size());
    for(int i = 0; i < accessList.size(); i++) {
        matrix.db.Access memberAccess = (matrix.db.Access) accessList.get(i);
        existingMembers.add(memberAccess.getUser());
    }    
    
    StringTokenizer idToken = new StringTokenizer(idArray, ",");
    BusinessObject newMember = null;
    BusinessObject newProjectMember = null;
    
    SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
    workspace.open(context);
    String strProjectVault = workspace.getVault();
    while (idToken.hasMoreTokens()) {
      // get the member object
      boolean bopen = false;
      newMember = new BusinessObject(idToken.nextToken());
      newMember.open(context);
      // add ProjectMember only if not there already
        try {
		  String newMemberName = newMember.getName();
		  if(existingMembers.contains(newMemberName)) {
		     continue; 
		  }
          String strNewProjectMemberName = newMemberName + workspace.getRevision();
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
  String wizardTreeURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, projectId) + "&emxSuiteDirectory="+appDirectory+"&suiteKey="+suiteKey;
%>

<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script> 
<script language="javascript">
  if('<%=XSSUtil.encodeForJavaScript(context, strReturn)%>' == 'access'){
	  getTopWindow().getWindowOpener().location.href = "<%=wizardTreeURL %>";
	  getTopWindow().closeWindow();
    }else{
      parent.window.getWindowOpener().getTopWindow().document.location.reload();
      parent.window.closeWindow();
    }
    
</script>
</body>
</html>
