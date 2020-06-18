
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "emxTeamTreeUtilInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  
 String documentID          = emxGetParameter(request,"contentId"); 
 String folderId            = emxGetParameter(request,"objectId");
 String confirm              = emxGetParameter(request,"confirm");
 String targetLocation      = emxGetParameter(request,"targetLocation");
 
 DomainObject deleteDocument   = DomainObject.newInstance(context);
// StringTokenizer stToken    = new StringTokenizer(documentID, "~");
 BusinessObject busDocRev = null;
 String[] deleteArray=null;
 StringList deleteList = null;
 
 Workspace workspace                = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
 WorkspaceVault WorkspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
 
 String sWorkspaceId = UserTask.getProjectId(context,folderId);
 workspace.setId(sWorkspaceId);
 WorkspaceVault.setId(folderId);

 if(confirm.equals("true")){
     
     StringList submittedObjectsList = FrameworkUtil.split(documentID,",");
     Iterator itr = submittedObjectsList.iterator();
     while (itr.hasNext()){
     deleteList = new StringList();
     deleteDocument.setId((String)itr.next());
     BusinessObjectItr busItr = new BusinessObjectItr(deleteDocument.getRevisions(context));
	  while(busItr.next())
	   {
	    busDocRev = busItr.obj();
	    deleteList.addElement(busDocRev.getObjectId());
	   }
	  deleteArray = (String[])deleteList.toArray(new String []{});
	  ContextUtil.pushContext(context);
	  CommonDocument.deleteDocuments(context, deleteArray);
	  ContextUtil.popContext(context);
     } 
  } 
	  SubscriptionManager subscriptionMgr = WorkspaceVault.getSubscriptionManager();

      subscriptionMgr.publishEvent(context, WorkspaceVault.EVENT_CONTENT_REMOVED, "");
      String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");

    	if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
      		MailUtil.setTreeMenuName(context, treeMenu );
   		 }

      // Publish event 'Folder Content Modified' for workspace
      subscriptionMgr = workspace.getSubscriptionManager();
      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CONTENT_MODIFIED, folderId);     
              
%>
        <script language="Javascript">
        getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, documentID)%>" , false);

	  var contentFrame = openerFindFrame(getTopWindow(), "content");


      var portalFrame =  findFrame(getTopWindow(), "portalDisplay");
      if(portalFrame){
		var frameToRefresh = findFrame(getTopWindow(), "WorkspaceContent");
		  getTopWindow().refreshTrees(frameToRefresh);

	  } else {
         getTopWindow().refreshTrees(frameToRefresh);
	  }
   getTopWindow().closeSlideInDialog();
   
      var detailsDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
      var listDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"listDisplay");
      if(detailsDisplayFrame){
      detailsDisplayFrame.location.href = detailsDisplayFrame.location.href;
      }else if(listDisplayFrame){
       listDisplayFrame.location.href = listDisplayFrame.location.href;
      }
    </script>
	  
