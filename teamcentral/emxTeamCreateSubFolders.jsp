<%-- emxTeamCreateSubFolders.jsp -- This page will Create Workspace SubFolders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program.

  static const char RCSID[] = $Id: emxTeamCreateSubFolders.jsp.rca 1.36 Wed Oct 22 16:05:55 2008 przemek Experimental przemek $

--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "emxTeamStartUpdateTransaction.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String strSubcategoryName           = emxGetParameter(request, "Name").trim();
  String strSubcategoryDesc           = emxGetParameter(request, "Description").trim();
  String strCategoryId                = emxGetParameter(request, "objectId").trim();
  String callPage                     = emxGetParameter(request,"callPage");
  String workspaceId                  = emxGetParameter(request,"workspaceId");
  String accessType					  = emxGetParameter(request,"AccessType");
  String languageStr                  = request.getHeader("Accept-Language");
  String objID                        = "";
  String strProjectId                 = "";
  String i18NCategory                 = "";
  String i18NNotUnique                = "";
  String treeUrl                      = null;
  String errorMsg                     = "";
  String publishOnConnect =emxGetParameter(request,"PublishOnConnect");
  matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
  boolean isDSCInstalled = FrameworkUtil.isSuiteRegistered(ctx,"appVersionDesignerCentral",false,null,null);

  boolean bExists                     = false;

  BusinessObject boNewSubCategory     = null;
  SubscriptionManager subscriptionMgr = null;

  try {
    //To get the workspace object
    strProjectId                       = UserTask.getProjectId(ctx,strCategoryId);
    Workspace workspace                = (Workspace) DomainObject.newInstance(ctx,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
    workspace.setId(strProjectId);
    WorkspaceVault workspaceVault      = (WorkspaceVault) DomainObject.newInstance(ctx,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
    workspaceVault.setId(strCategoryId);

    workspace.open(ctx);
    workspaceVault.open(ctx);
    boolean subFolderExists = workspaceVault.isSubFolderExists(ctx, strSubcategoryName);
    if(subFolderExists){
    	String strErrorMsg = UINavigatorUtil.getI18nString("emxTeamCentral.CreateSubFolder.SubFolderExists","emxTeamCentralStringResource",languageStr);
    	throw new Exception(strErrorMsg);
    }
	//Commented for Duplicate folder Names R2010x
    //String strProjectRevision          = workspace.getRevision();
    //strProjectRevision                += "-" + workspaceVault.getName();

    //Modified for Duplicate Folder Names R2010x
    MQLCommand mqlCmd = new MQLCommand();
	mqlCmd.executeCommand(ctx, "print bus $1 select $2 dump $3",strCategoryId,"physicalid","|");
    String strProjectRevision = mqlCmd.getResult();
    strProjectRevision = strProjectRevision.substring(0,strProjectRevision.indexOf("\n"));
	//Addition ends for Duplicate Folder Names R2010x

    // Creating a Sub Category and connect this to Parent Category with Sub Vault Relationship
   	//<--!Added for the Bug No:339243 08/06/2007 10:00AM Start-->
	String folderName = workspaceVault.getInfo(ctx,DomainConstants.SELECT_NAME);
	//<--!Ended for the Bug No:339243 08/06/2007 10:00AM End-->
    boNewSubCategory = new BusinessObject(workspace.TYPE_WORKSPACE_VAULT, strSubcategoryName, strProjectRevision, workspace.getVault());

	//<--!Modifieded for the Bug No:339243 08/06/2007 10:00AM Start-->
	String i18NSubFolderName = EnoviaResourceBundle.getProperty(ctx, "emxTeamCentral.Common.CheckforSubFolderName");
	
	if(i18NSubFolderName.equalsIgnoreCase("true"))
	{
    if (strSubcategoryName.equals(folderName) || (workspaceVault.isSubFolderExists(ctx, strSubcategoryName))) {
        bExists = true;
        i18NCategory =  i18nNow.getI18nString("emxTeamCentral.AddCategories.SubCategory","emxTeamCentralStringResource",request.getHeader("Accept-Language"));
        i18NNotUnique = i18nNow.getI18nString("emxTeamCentral.AddCategories.NotUnique","emxTeamCentralStringResource",request.getHeader("Accept-Language"));
        session.putValue("error.message", i18NCategory +"  "+ boNewSubCategory.getName() +"  "+ i18NNotUnique);
        errorMsg = i18NCategory +"  "+ boNewSubCategory.getName() +"  "+ i18NNotUnique;
		} 
	}
	
	//<--!Modied for the Bug No:339243 08/06/2007 10:00AM End-->
	else {
      boNewSubCategory.create(ctx, workspace.POLICY_PROJECT_VAULT);
      boolean boolTree = false;
      String treeMenu = JSPUtil.getApplicationProperty(ctx,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )){
          boolTree = true;
      }
      if(boolTree == true){
        MailUtil.setTreeMenuName(ctx, treeMenu );
      }
      // Publish workspace  Event 'Folder Created'.
      subscriptionMgr = workspace.getSubscriptionManager();
      subscriptionMgr.publishEvent(ctx, workspace.EVENT_FOLDER_CREATED, boNewSubCategory.getObjectId());

      if(boolTree == true){
        MailUtil.setTreeMenuName(ctx, treeMenu );
      }
      // Publish workspace Vault  Event 'Folder Created'.
      subscriptionMgr = workspaceVault.getSubscriptionManager();
      subscriptionMgr.publishEvent(ctx, workspaceVault.EVENT_FOLDER_CREATED, boNewSubCategory.getObjectId());

      DomainObject subVault =  DomainObject.newInstance(ctx,boNewSubCategory);
     HashMap attrMap = new HashMap();
      if (UIUtil.isNotNullAndNotEmpty(publishOnConnect))
      {
      attrMap.put(DomainConstants.ATTRIBUTE_PUBLISH_ON_CONNECT,publishOnConnect);
      }
      if(WorkspaceVault.ATTRIBUTE_ACCESSTYPE_SPECIFIC.equals(accessType)){
      	    subVault.open(ctx);
      		attrMap.put(DomainConstants.ATTRIBUTE_ACCESS_TYPE,accessType);
            String objectId = subVault.getId(ctx);
        	DomainAccess.createObjectOwnership(ctx, objectId, PersonUtil.getPersonObjectID(ctx), DomainAccess.getOwnerAccessName(ctx,objectId), DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
            if(WorkspaceVault.isDefaultWSOaccessGrantEnabled(ctx)){
      		         String workspaceOwner = workspace.getInfo(ctx,DomainConstants.SELECT_OWNER);
          	if(UIUtil.isNotNullAndNotEmpty(workspaceOwner) && !(workspaceOwner.equals(ctx.getUser()))){
         			 DomainAccess.createObjectOwnership(ctx, objectId, PersonUtil.getPersonObjectID(ctx, workspaceOwner), DomainAccess.getOwnerAccessName(ctx,objectId), DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
         		 }      	
          }
          subVault.close(ctx);
        }
      subVault.setAttributeValues(ctx,attrMap);
      workspaceVault.connectTo(ctx, workspaceVault.RELATIONSHIP_SUBVAULTS, subVault);
      subVault.setDescription(ctx, strSubcategoryDesc);
      objID = subVault.getInfo(ctx, subVault.SELECT_ID);
      treeUrl = UINavigatorUtil.getCommonDirectory(ctx) + "/emxTree.jsp?objectId=" + objID +"&emxSuiteDirectory="+appDirectory+"&mode=insert&AppendParameters=true&folderId=" + strCategoryId + "&workspaceId=" + workspaceId;
    }

   workspaceVault.close(ctx);
   workspace.close(ctx);
%>
    <%@ include file = "emxTeamCommitTransaction.inc" %>
<%
  } catch (Exception ex){

    bExists = true;
    errorMsg = ex.getMessage().replace("\r","\\r").replace("\n","\\n");
%>
    <%@  include file="emxTeamAbortTransaction.inc" %>
<%
  }
%>

<html>
<body>
<script language="javascript">

<%
    if(!bExists) {

    if (callPage != null && ("workspacewizard".equals(callPage))) {
%>
	
        var tree1 = parent.window.getWindowOpener().parent.parent.tree;
        var tempnode = tree1.nodes[tree1.selectedID];
        var newNode = tempnode.addChild("<%=XSSUtil.encodeForJavaScript(ctx, strSubcategoryName)%>","images/iconSmallFolder_new.png",false,"<%=XSSUtil.encodeForJavaScript(ctx, objID)%>");
        tempnode.selectable = true;
        if(!tempnode.expanded) {
          tree1.toggleExpand(tree1.selectedID);//Open
        }
        else {
        	tree1.toggleExpand(tree1.selectedID);//Close
        	tree1.toggleExpand(tree1.selectedID);//Open
        }
        parent.window.getWindowOpener().location.href = parent.window.getWindowOpener().location.href;
        parent.window.closeWindow();
<%
    }else{
%>	 
        //XSSOK – isDSCInstalled - value not read from request
		var isDSCInstalled = "<%=isDSCInstalled%>";	
		if (isDSCInstalled == "true"){
			if(parent.window.getWindowOpener() != null){
				 parent.window.getWindowOpener().parent.getTopWindow().location.replace(parent.window.getWindowOpener().parent.getTopWindow().location);
				 parent.window.closeWindow();
				}
		} 
		
		var tree = null;
		if(parent.window.getWindowOpener() != null){
			tree = parent.window.getWindowOpener().getTopWindow().tempTree;//XSSOK		
			
		}
      if(tree != null && tree != 'undefined'){
		var conTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
		var isDSCInstalled = "<%=isDSCInstalled%>";//XSSOK		

		if (isDSCInstalled == "true" && conTree==null) {
          getTopWindow().window.getWindowOpener().parent.getTopWindow().location.replace(parent.window.getWindowOpener().parent.getTopWindow().location);			
		} else {
          getTopWindow().getWindowOpener().getTopWindow().addStructureNode("<%=XSSUtil.encodeForJavaScript(ctx,(String)boNewSubCategory.getObjectId())%>", "<%=XSSUtil.encodeForJavaScript(ctx, strCategoryId)%>",conTree.getSelectedNode().nodeID , "<%=XSSUtil.encodeForJavaScript(ctx, appDirectory)%>");
		}	
        parent.window.closeWindow();
       } else {
    	   try{
               loadTreeNode("<%=XSSUtil.encodeForJavaScript(ctx,(String)boNewSubCategory.getObjectId())%>", "<%=XSSUtil.encodeForJavaScript(ctx, strCategoryId)%>", null , "<%=XSSUtil.encodeForJavaScript(ctx, appDirectory)%>", true);
    	   }catch(exp){
    		   //to catch permission denied error
    	   }
         parent.window.closeWindow();
      }

<%
      }
      }else {
%>		
  alert("<%=XSSUtil.encodeForJavaScript(ctx, errorMsg)%>");
  parent.document.location.href=parent.document.location.href;
<%
    }
%>

</script>
</body>
</html>

