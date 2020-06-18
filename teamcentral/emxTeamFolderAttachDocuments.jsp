<%--  emxTeamFolderAttachDocuments.jsp  --  Comnnecting Contents to Discussion/Meeting

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamFolderAttachDocuments.jsp.rca 1.9 Wed Oct 22 16:06:30 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "emxTeamTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  String sObjectId                = emxGetParameter(request, "objectId");
  String ContentID[]              = emxGetParameterValues(request,"chkItem");
  String sProjectId               = emxGetParameter(request,"projectId");
  String sParentId                = emxGetParameter(request, "routeId");
  String sTemplateId              = emxGetParameter(request,"templateId");
  String sTemplateName            = emxGetParameter(request,"template");
  String sContent                 = emxGetParameter(request,"content");
  String sContentId               = emxGetParameter(request,"contentId");
  //DomainObject parentObj          = DomainObject.newInstance(context);
  DomainObject parentObj          = new DomainObject();
  String contentObjID = "";
  if(sContent == null){
    sContent = "";
  }  

  if(ContentID == null){
      ContentID = emxGetParameterValues(request,"emxTableRowId");
      ContentID = FrameworkUtil.getSplitTableRowIds(ContentID);
    }
  if(UINavigatorUtil.isMobile(context)){
	  ContentID = FrameworkUtil.getSplitTableRowIds(ContentID);
  }
  	try {
		String sRelationship = "";
		if (ContentID != null) {
			if (sParentId == null || "".equals(sParentId) ||sParentId.equals("") ) {
				parentObj.setId(sObjectId);
	     	} else {
				parentObj.setId(sParentId);
		 	}
			
			if(parentObj.getType(context).equals(parentObj.TYPE_WORKSPACE_VAULT)) {
				sRelationship = parentObj.RELATIONSHIP_VAULTED_DOCUMENTS;
				for(int i = 0; i<ContentID.length;i++) {
					contentObjID = ContentID[i];
	    	    	parentObj.connect(context,sRelationship,new DomainObject(ContentID[i]),false);
	    	    	//changes for IR-449078-3DEXPERIENCER2015x ***** begin
					WorkspaceVault folder = (WorkspaceVault) DomainObject.newInstance(context, sObjectId);
	    	    	
	    	    	StringList wsSelects = new StringList(1);
	    	    	wsSelects.addElement(DomainObject.SELECT_ID);
	    	    	Map folderMap = folder.getTopLevelVault(context, wsSelects);
	    	    	String topFolderId = (String)folderMap.get(DomainObject.SELECT_ID);
	    	    	WorkspaceVault topFolder = (WorkspaceVault)DomainObject.newInstance(context, topFolderId);
	    	    	
	                String parentVaultId = (String) topFolder.getInfo(context, "relationship[Data Vaults].from.id");
	                DomainObject vault = (DomainObject) DomainObject.newInstance(context, parentVaultId);
	                
	                String wsType = PropertyUtil.getSchemaProperty(context,"type_Project");
	                String vaultType = vault.getInfo(context, DomainObject.SELECT_TYPE); 
	                if (vaultType.equals(wsType)) {
						Workspace workspace = (Workspace) DomainObject.newInstance(context, parentVaultId);
						SubscriptionManager wsSubMgr = new SubscriptionManager(workspace);
						
						if (wsSubMgr != null) {
							wsSubMgr.publishEvent(context, workspace.EVENT_FOLDER_CONTENT_MODIFIED, ContentID[i]);
						}
	                }
	    	    	//changes for IR-449078-3DEXPERIENCER2015x ***** end
				}
			}
		}
	} catch(Exception ex ) {
		String emsg = ex.getMessage();
		String re ="(?:^|\\s)'([^']*?)'(?:$|\\s)"; 
		java.util.regex.Pattern pat = java.util.regex.Pattern.compile(re,java.util.regex.Pattern.MULTILINE);
		java.util.regex.Matcher mat = pat.matcher(emsg);
		String[] msgArgs = new String[1];
		if (mat.find()) {
			msgArgs[0] = mat.group();
			emsg = MessageUtil.getMessage(context, null, "emxTeamCentral.Error.NoChangeOwnerAccess", msgArgs, null, context.getLocale(), "emxTeamCentralStringResource");
		} else if(emsg.contains("A relationship of this type already exists")) {
		  emsg = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(), "emxTeamCentral.Error.ContentAlreadyConnected"); 
          emsg = MessageUtil.substituteValues(context,emsg,contentObjID,context.getSession().getLanguage());
		  }
		session.putValue("error.message",emsg);
	}%>
	
<script language="Javascript">
 <% 
  MapList folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,sObjectId); 
  if(folderMapList != null && folderMapList.size() > 0 ){
      Iterator folderMapListItr = folderMapList.iterator();
      	while(folderMapListItr.hasNext()) {
        	Map folderMap = (Map)folderMapListItr.next();
        	String foldn  = (String)folderMap.get(WorkspaceVault.SELECT_NAME);
        	String foldId = (String)folderMap.get(WorkspaceVault.SELECT_ID);
            String treeLabel  =  UITreeUtil.getUpdatedTreeLabel(application, session,request,context,foldId,(String)null,appDirectory,sLanguage);
 %>
      getTopWindow().getWindowOpener().getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForURL(context, foldId)%>", "<%=treeLabel%>");
<%
       }
     }  
%>
    getTopWindow().getWindowOpener().getTopWindow().refreshDetailsTree();
    getTopWindow().closeWindow();
</script>
</body>
</html>


