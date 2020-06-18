
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../teamcentral/emxTeamUtil.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../teamcentral/emxTeamTreeUtilInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%
  
 String documentID          = emxGetParameter(request,"objectId"); 
 String folderId            = emxGetParameter(request,"parentId");
 //String targetLocation      = emxGetParameter(request,"targetLocation");
 
 DomainObject deleteDocument   = DomainObject.newInstance(context);
// StringTokenizer stToken    = new StringTokenizer(documentID, "~");
 BusinessObject busDocRev = null;
 String[] deleteArray=null;
 StringList deleteList = null;
 String treeLabel       = "";
 
 Workspace workspace                = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
 WorkspaceVault WorkspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
 
 String sWorkspaceId = UserTask.getProjectId(context,folderId);
 workspace.setId(sWorkspaceId);
 WorkspaceVault.setId(folderId);

 
	  SubscriptionManager subscriptionMgr = WorkspaceVault.getSubscriptionManager();

      subscriptionMgr.publishEvent(context, WorkspaceVault.EVENT_CONTENT_ADDED, "");
      String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");

    	if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
      		MailUtil.setTreeMenuName(context, treeMenu );
   		 }

      // Publish event 'Folder Content Modified' for workspace
      subscriptionMgr = workspace.getSubscriptionManager();
      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CONTENT_MODIFIED, folderId);     
              
%>
        <script language="Javascript">
       
<%      
        MapList folderMapList =  new  MapList();   
        folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,folderId);
     	if(folderMapList != null && folderMapList.size() > 0 ){
        Iterator folderMapListItr = folderMapList.iterator();
        while(folderMapListItr.hasNext()) {
          	Map folderMap = (Map)folderMapListItr.next();
          	String foldn  = (String)folderMap.get(WorkspaceVault.SELECT_NAME);
          	String foldId = (String)folderMap.get(WorkspaceVault.SELECT_ID);
          	treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,foldId,(String)null,appDirectory,sLanguage);
%>
getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForJavaScript(context, foldId)%>","<%=treeLabel%>");
<%
       }
     }   
%>	 
      //getTopWindow().objStructureTree.clear();
      getTopWindow().objStructureTree.refresh(true);
      var detailsDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
      var listDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"listDisplay");
      if(detailsDisplayFrame){
      detailsDisplayFrame.location.href = detailsDisplayFrame.location.href;
      }else if(listDisplayFrame){
       listDisplayFrame.location.href = listDisplayFrame.location.href;
      }
    </script>
 
	  
