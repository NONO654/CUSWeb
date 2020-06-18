<%--  emxTeamDeleteFolders.jsp   - To Delete a Folder
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamDeleteFolders.jsp.rca 1.33 Wed Oct 22 16:06:33 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  com.matrixone.apps.common.Person Person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
//added for the bug 339044
  String sProjectIds = emxGetParameter(request,"folderIds");
  if((sProjectIds==null)||(sProjectIds.length()==0)){
	  //below code is added for the bug 324431
	  String sProjectIdes[] = emxGetParameterValues(request,"emxTableRowId");
	  if(UINavigatorUtil.isMobile(context)){
		  sProjectIdes = FrameworkUtil.getSplitTableRowIds(sProjectIdes);
	  }
	  StringList folderIds = new StringList(sProjectIdes.length);
 	  for (int i=0; i<sProjectIdes.length; i++)
	  {
		String folderId = sProjectIdes[i];
		String[] index = folderId.split("\\|");
		
		folderIds.add(index[1]);
	  }
	  sProjectIds = FrameworkUtil.join(folderIds, ";");
	  //end of the code for the bug 324431
  }//end bug no 339044
  String objectId    = emxGetParameter(request,"objectId");
  String sLink       = emxGetParameter(request,"page");
  String sTargetpage = "";
  BusinessObject boProject  = null;
  StringTokenizer sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);
  Workspace workspace            = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
  WorkspaceVault workspaceVault  = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
  workspace.setId(objectId);
  
  String relSubVaultsStr         = Framework.getPropertyValue( session, "relationship_SubVaults");
  String relVaultedDocumentsStr  = Framework.getPropertyValue( session, "relationship_VaultedDocuments");
  String typeProjectVault     = Framework.getPropertyValue( session, "type_ProjectVault");

  HashMap deleteMap = workspaceVault.folderDeleteAlert(context, sProjectIds, objectId, request.getHeader("Accept-Language"));
  String sMsg = (String)deleteMap.get("errorMessage");
  boolean bCanDelete = ((Boolean)deleteMap.get("canDelete")).booleanValue();
  String sProjectId  = (String)deleteMap.get("sProjectId");
  boolean subfold  = ((Boolean)deleteMap.get("subfold")).booleanValue();
  String workspaceId  = (String)deleteMap.get("workspaceId");

 //below code is added for the bug 324431
if(sLink==null || "".equals(sLink))
  sLink="";
//end of the code for the bug 324431
  if(sLink.equals("Folder")) {
    sTargetpage = "emxTeamFoldersWorkspaceSummaryFS.jsp";
  } else if(sLink.equals("Subfolder")) {
    sTargetpage = "emxTeamSubFoldersWorkspaceSummaryFS.jsp";
  } else if(sLink.equals("WizFolder")) {
    sTargetpage = "emxTeamCreateWorkspaceToplevelFoldersFS.jsp";
  } else if(sLink.equals("WizSubfolder")) {
    sTargetpage = "emxTeamSubFoldersviewFS.jsp";
  }
%>

<%!


%>

<html>
<body>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<form name="newForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=workspaceId%></xss:encodeForHTMLAttribute>"/>
</form>

<%
  if (!bCanDelete) {
%>
    <script language="javascript">
    alert("<%=XSSUtil.encodeForJavaScript(context, sMsg)%>");
<%
    if(sLink.equals("WizFolder")) {
%>
	  //handle double-click issue
	   if(jsDblClick())
	   {
		//XSSOK
		document.newForm.action = "<%=sTargetpage%>";
      	document.newForm.submit();
	   }else {
		alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
	   }     
<%
    } else {
%>
      //parent.window.location.reload();
      
      // Using location.reload will submit the form again and again. So using correct way of reloading the table page.
      getTopWindow().refreshTablePage();
<%
    }

%>

</script>

<%
  } else {

    // Publish Event 'Folder Deleted'.
    //String url = UINavigatorUtil.notificationURL(application, request, strWSId, "Menu", false);
    SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();

    workspaceVault.setId(objectId);
     SubscriptionManager subscriptionWkVaultMgr = workspaceVault.getSubscriptionManager();

    sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);

    StringList SelectList = new StringList();
    SelectList.add(workspaceVault.SELECT_ID);

    while (sProjectIdsToken.hasMoreTokens()) {
      sProjectId = sProjectIdsToken.nextToken();
      boProject = new BusinessObject(sProjectId);
      boProject.open(context);

      Pattern relPattern  = null;
      Pattern typePattern = null;
      relPattern = new Pattern(relSubVaultsStr);
      typePattern = new Pattern(typeProjectVault);
      workspaceVault.setId(sProjectId);
      MapList mapList = workspaceVault.getRelatedObjects(context,
                                        relPattern.getPattern(),
                                        typePattern.getPattern(),
                                        SelectList, // objectSelects,
                                        new SelectList(), // relationshipSelects,
                                        false,             // getTo,
                                        true,             // getFrom,
                                        (short)0,         // recurseToLevel,
                                        null,             // objectWhere,
                                        "");        //relationshipWhere)


    for(int i=0;i<mapList.size();i++) {
      Map tempmap = (Map) mapList.get(i);
      String SubFolderId = (String) tempmap.get(workspaceVault.SELECT_ID);
      BusinessObject boFolder = new BusinessObject(SubFolderId);
      boFolder.open(context);
      try{
      boFolder.remove(context);
  	     }catch(Exception e){
 			 session.putValue("error.message", e.toString());		
 		 } finally{
      boFolder.close(context);
    }
    }
	try{
      boProject.remove(context);
	}catch(Exception e){
		 session.putValue("error.message", e.toString());		
	} finally{
      boProject.close(context);
	}
    }

   subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_DELETED, "");
   if(subfold == true) {
      workspaceVault.setId(objectId);
      subscriptionWkVaultMgr.publishEvent(context, workspaceVault.EVENT_FOLDER_DELETED, "");
  }

%>
  <script language="Javascript">
  //XSSOK
   var isWizFolderLink      =  <%=(XSSUtil.encodeForJavaScript(context,sLink).equals("WizFolder"))%>;
   //XSSOK
   var isWizSubfolderLink   =  <%=(XSSUtil.encodeForJavaScript(context,sLink).equals("WizSubfolder"))%>;

   
    if(isWizFolderLink) {
        
    	   //handle double-click issue
        if(jsDblClick()){
        		//XSSOK
             document.newForm.action = "<%=sTargetpage%>";
		     document.newForm.submit();
		   
	    }else{		  
             alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
        }
	   
    } else if(isWizSubfolderLink){

    var tree1 =  parent.parent.tree;

<%
    sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);
    while (sProjectIdsToken.hasMoreTokens()) {
    sProjectId = sProjectIdsToken.nextToken();
%>
     tree1.deleteObject("<%=XSSUtil.encodeForJavaScript(context, sProjectId)%>" , false);
<%
    }
%>
    tree1.refresh();
    parent.location = parent.location;

  } else {
<%
        sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);
        while (sProjectIdsToken.hasMoreTokens()) {
          sProjectId = sProjectIdsToken.nextToken();
%>
getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, sProjectId)%>", false);
<%
        }
    	String treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,workspaceId,(String)null,appDirectory,sLanguage);

%>
getTopWindow().changeObjectLabelInTree("<xss:encodeForJavaScript><%=workspaceId%></xss:encodeForJavaScript>","<%=treeLabel%>");
getTopWindow().refreshDetailsTree();
    }
</script>

</body>
</html>

<%
  }
%>
