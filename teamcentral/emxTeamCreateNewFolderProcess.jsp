<%--  emxTeamCreateNewFolderProcess   -  Creates new folder and connects to project
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateNewFolderProcess.jsp.rca 1.20 Wed Oct 22 16:05:53 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "emxTeamStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%

  String strProjectId              = emxGetParameter(request, "objectId");
  String templateId                = emxGetParameter(request, "templateId");
  String template                  = emxGetParameter(request, "template");
  boolean bExists                  = false;
  String strErrorMsg	           = "";

  try {
    BusinessObject boProject = new BusinessObject(strProjectId);
    boProject.open(context);

    //String strProjectRevision = boProject.getRevision();
    //strProjectRevision += "-" + boProject.getName();
    String strProjectVault = boProject.getVault();
    //Modified for Duplicate Folder Names R2010x
    MQLCommand mqlCmd = new MQLCommand();

	mqlCmd.executeCommand(context, "print bus $1 select $2 dump $3",strProjectId, "physicalid","|");
    String strProjectRevision = mqlCmd.getResult();
    strProjectRevision = strProjectRevision.substring(0,strProjectRevision.indexOf("\n"));
	//Addition ends for Duplicate Folder Names R2010x

    RelationshipType projectVaultsRelType     = new RelationshipType(DomainObject.RELATIONSHIP_PROJECT_VAULTS);

    // Check for the Category is selected or not
    Vector categoryVector     = new Vector();
    String strCategoryName = emxGetParameter(request,"folderName");
    String sDescription    = emxGetParameter(request,"folderDescription");
    String accessType = emxGetParameter(request,"AccessType");
	String publishOnConnect =emxGetParameter(request,"PublishOnConnect");
    
    

    // Creating a Category and connect this to the Current Project
    BusinessObject boNewCategory = new BusinessObject(DomainObject.TYPE_PROJECT_VAULT, strCategoryName, strProjectRevision, strProjectVault);
    if (boNewCategory.exists(context)) {
      bExists = true;
      String i18NCategory = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", new Locale(request.getHeader("Accept-Language")), "emxTeamCentral.AddCategories.Category");
      String i18NNotUnique = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", new Locale(request.getHeader("Accept-Language")), "emxTeamCentral.AddCategories.NotUnique");
      strErrorMsg = i18NCategory +"  "+ boNewCategory.getName() +"  "+ i18NNotUnique;
    	throw new Exception(strErrorMsg);
    }
    
    if(!bExists) {
      boNewCategory.create(context, DomainObject.POLICY_PROJECT_VAULT);
      Workspace workspace        = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
      workspace.setId(strProjectId);
      SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();

      String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
        MailUtil.setTreeMenuName(context, treeMenu );
      }
      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CREATED, boNewCategory.getObjectId());

      //updating the Description it exists
      if (sDescription != null && !sDescription.equals("")) {
        boNewCategory.setDescription(context, sDescription);
        boNewCategory.update(context);
      }
       DomainObject wsVault =  DomainObject.newInstance(context,boNewCategory);
       HashMap attrMap = new HashMap();
       if (UIUtil.isNotNullAndNotEmpty(publishOnConnect))
       {
       attrMap.put(DomainConstants.ATTRIBUTE_PUBLISH_ON_CONNECT,publishOnConnect);
       }
      if (UIUtil.isNotNullAndNotEmpty(accessType)) {
    	  wsVault.open(context);
    	  attrMap.put(DomainConstants.ATTRIBUTE_ACCESS_TYPE,accessType);
          String objectId = wsVault.getId(context);
        	DomainAccess.createObjectOwnership(context, objectId, PersonUtil.getPersonObjectID(context), DomainAccess.getOwnerAccessName(context,objectId), DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
            if(WorkspaceVault.isDefaultWSOaccessGrantEnabled(context)){
      		         String workspaceOwner = workspace.getInfo(context,DomainConstants.SELECT_OWNER);
          	if(UIUtil.isNotNullAndNotEmpty(workspaceOwner) && !(workspaceOwner.equals(context.getUser()))){
         			 DomainAccess.createObjectOwnership(context, objectId, PersonUtil.getPersonObjectID(context, workspaceOwner), DomainAccess.getOwnerAccessName(context,objectId), DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
         		 }      	
          }
            wsVault.close(context);
        }
      wsVault.setAttributeValues(context,attrMap);
      //connecting the new Category to the Project
      boNewCategory.connect( context, projectVaultsRelType, false, boProject);
    }
    boProject.close(context);
%>
    <%@ include file = "emxTeamCommitTransaction.inc" %>
<%
  } catch (Exception ex){
	  strErrorMsg = ex.getMessage().replace("\r","\\r").replace("\n","\\n");
%>
    <%@  include file="emxTeamAbortTransaction.inc" %>
<%
  }
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">

<%
    if(!bExists) {
%>

      var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "pagecontent"); 
      frameContent.parent.document.location.href="emxTeamCreateWorkspaceToplevelFoldersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strProjectId)%>&templateId=<%=XSSUtil.encodeForURL(context, templateId)%>&template=<%= XSSUtil.encodeForURL(context, template)%>";
      parent.window.closeWindow();
<%
    } else {
%>
      //XSSOK    
      alert("<%=strErrorMsg%>");
      document.location.href="emxTeamCreateNewFolderDialog.jsp?objectId=<%=XSSUtil.encodeForURL(context, strProjectId)%>&templateId=<%=XSSUtil.encodeForURL(context, templateId)%>&template=<%= XSSUtil.encodeForURL(context, template)%>";
<%
    }
%>
</script>
