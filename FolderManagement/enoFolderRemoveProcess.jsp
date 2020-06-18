<%--  enoFolderRemoveProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import="com.dassault_systemes.enovia.foldermanagement.WorkspaceFolder"%>
<%@page import="com.dassault_systemes.enovia.e6w.foundation.FoundationException"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%

String relDataVaultsStr  = Framework.getPropertyValue( session, "relationship_ProjectVaults");
String typeProjectVault     = Framework.getPropertyValue( session, "type_ProjectVault");
String typeDocuments     = Framework.getPropertyValue( session, "type_DOCUMENTS");
String emxTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
String parentOID = emxGetParameter(request,"parentOID");
String rowIds = emxGetParameter(request,"rowIds");
String objectId = emxGetParameter(request,"objectId");
String relId = emxGetParameter(request,"relId");
String SuiteDirectory = emxGetParameter(request,"SuiteDirectory");
String StringResourceFileId = emxGetParameter(request,"StringResourceFileId");
String strRowIds[]   = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxTableRowId);
StringList slTableRowIdList = com.matrixone.apps.common.util.ComponentsUIUtil.getSelectedTableRowIds(emxTableRowId);

String strCannotDeleteFolder = EnoviaResourceBundle.getProperty(context, "enoFolderManagementStringResource", context.getLocale(), "enoFolderManagement.Common.CannotDeleteFolder");
String strCannotDeleteRootFolder = EnoviaResourceBundle.getProperty(context, "enoFolderManagementStringResource", context.getLocale(), "enoFolderManagement.Common.CannotDeleteRootFolder");
String strFoldersAndContents = EnoviaResourceBundle.getProperty(context, "enoFolderManagementStringResource", context.getLocale(), "enoFolderManagement.Common.CannotSelectFoldersAndContents");
String strCannotRemoveContent = EnoviaResourceBundle.getProperty(context, "enoFolderManagementStringResource", context.getLocale(), "enoFolderManagement.Common.CannotRemoveSubLevelContent");
StringList slWorkspaceVaultList = null;
StringList slDocumentList = null;

if(slTableRowIdList.contains("0")){
	%>
	<script language="Javascript">
	alert("<%=strCannotDeleteRootFolder%>");
	</script>
    	
	<%
}else{
	slWorkspaceVaultList = new StringList(strRowIds.length);
	slDocumentList = new StringList(strRowIds.length);
	for(int i=0;i<strRowIds.length;i++){
	    DomainObject selObject = new DomainObject(strRowIds[i]);
	    if(selObject.getType(context).equals(typeProjectVault)){
	    	slWorkspaceVaultList.add(strRowIds[i]);
	    }else if(selObject.isKindOf(context, typeDocuments)){
	    	slDocumentList.add(strRowIds[i]);
	    }   
	 }
	 if(slWorkspaceVaultList.size() > 0 && slDocumentList.size() > 0){
	    	%>
			<script language="Javascript">
	       		alert("<%=strFoldersAndContents%>");
	       	</script>	

	   	<%
	  }else if(slWorkspaceVaultList.size() > 0){
	    		String strProjectVaultID = "";
	    		try{
	    			String [] sRefFolders = (String [])slWorkspaceVaultList.toArray(new String[slWorkspaceVaultList.size()]);
	    			WorkspaceFolder.deleteFolders(context, sRefFolders);
	    			int iDeleteFoldersCount = sRefFolders.length;
	    			%>
	    			<script language="Javascript">
	    			var fancyTreeFrame = findFrame(top, "WorkspacePublicFolders");
	    			var colArray = [];
	    			<% for (int i=0; i<sRefFolders.length; i++) { %>
	    			colArray[<%= i %>] = "<%= XSSUtil.encodeForJavaScript(context,sRefFolders[i]) %>"; 
	    			<% } %>
	    			fancyTreeFrame.deleteNodesFromFancyTree(colArray, "delete");
	    			var portalFrame =  findFrame(getTopWindow(), "portalDisplay");
	    		      if(portalFrame){
	    				var frameToRefresh = findFrame(getTopWindow(), "WorkspaceContent");
	    				  getTopWindow().refreshTrees(frameToRefresh);

	    			  } else {
	    		         getTopWindow().refreshTrees(frameToRefresh);
	    			  }
	    			</script>
	    			<%
	    		}catch (FoundationException e)
                {
                    %>
                    <script language="Javascript">
	       				alert("<%=strCannotDeleteFolder%>");
	       			</script>
                    <% 
                }catch(Exception e){
                      e.printStackTrace();	
                }
	   }else{
	    				StringBuffer sbSlideInForm = new StringBuffer("../common/emxForm.jsp?form=TMCRemoveContentConfirmation&mode=edit&postProcessURL=../teamcentral/emxTeamDeleteContent.jsp&preProcessJPO=emxWorkspaceFolder:removeFolderContentPreProcess&formHeader=enoFolderManagement.DeleteContentFS.Heading&HelpMarker=emxhelpremovecontentconfirmation&submitAction=doNothing&fromFolderManagement=true");
	    				sbSlideInForm.append("&objectId="+objectId);
	    				sbSlideInForm.append("&parentOID="+parentOID);
	    				sbSlideInForm.append("&relId="+relId);
	    				sbSlideInForm.append("&SuiteDirectory="+SuiteDirectory);
	    				sbSlideInForm.append("&suiteKey=FolderManagement");
	    				StringBuffer sbTableRowIds = new StringBuffer();
	    				String sTabelRowIds = "";
	    				Iterator<?> contentObjectsIterator = slDocumentList.iterator();
	    				String docObjectId = "";
	    				String parentFolderId = "";
	    				DomainObject objWorkspaceVault = null;
	    				boolean isContentRemovable = true;
                		while(contentObjectsIterator.hasNext())
                 		{
                  			 docObjectId = docObjectId + (String)contentObjectsIterator.next() +",";
                 		}
                		docObjectId = docObjectId.substring(0,docObjectId.length()-1);
                		sbSlideInForm.append("&rowIds="+docObjectId);
                		for(int i=0;i<emxTableRowId.length;i++){
	    					sbTableRowIds.append(emxTableRowId[i]).append("~");
	    					StringList emxTableIDs = FrameworkUtil.split(emxTableRowId[i], "|");
	    					if(emxTableIDs.size()==4){
	    						parentFolderId = (String) emxTableIDs.get(2);
	    					}
	    					if(emxTableIDs.size()==3){
	    						parentFolderId = (String) emxTableIDs.get(1);
	    					}
	    					objWorkspaceVault = new DomainObject(parentFolderId);
	    					if(!objWorkspaceVault.getType(context).equals(typeProjectVault)){
	    						isContentRemovable = false;
								break;
	    					}
	    				}
	    				sTabelRowIds = sbTableRowIds.toString();
	    				sTabelRowIds = sTabelRowIds.substring(0,sTabelRowIds.length()-1);
	    				sbSlideInForm.append("&emxTableRowId="+sTabelRowIds);
	    				if(isContentRemovable){
	    	%>
	    		<script language="Javascript">
	    		getTopWindow().showSlideInDialog('<%= XSSUtil.encodeForJavaScript(context,sbSlideInForm.toString())%>', true);
		   		</script>
	    	<% }else{
	    		%>
	    		<script language="Javascript">
	    		alert("<%=strCannotRemoveContent%>");  		
		   		</script>
	    	<% 
	    		
	    	}
	    }
}

%>
