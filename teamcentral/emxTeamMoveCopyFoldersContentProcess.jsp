<%--  emxTeamMoveCopyFoldersContentProcess.jsp -- To Add the moved contents from the Source Folder to
      selected Destination Folder
  This page adds a location to an organization.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxTeamMoveCopyFoldersContentProcess.jsp.rca 1.21.3.2 Wed Oct 22 16:06:20 2008 przemek Experimental przemek $
--%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc" %>
<%@include file = "emxTeamTreeUtilInclude.inc" %>
<%@page import= "com.matrixone.apps.framework.ui.UITreeUtil" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>


<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
	try
	{
		final String RELATIONSHIP_DATA_VAULTS = PropertyUtil.getSchemaProperty(context, "relationship_ProjectVaults");
		final String RELATIONSHIP_SUB_VAULTS = PropertyUtil.getSchemaProperty(context, "relationship_SubVaults");
		final String RELATIONSHIP_LINKED_FOLDERS = PropertyUtil.getSchemaProperty(context, "relationship_LinkedFolders");
		final String SELECT_PARENT_FOLDER_ID = "to[" + RELATIONSHIP_SUB_VAULTS + "].from.id";
		final String SELECT_PARENT_WORKSPACE_ID = "to[" + RELATIONSHIP_DATA_VAULTS + "].from.id";
		
		String strLanguage = request.getHeader("Accept-Language");
	    
	    String timeStamp = emxGetParameter(request, "timeStamp");
		Map reqMap = (Map)indentedTableBean.getRequestMap(timeStamp);
		Map reqValMap = (Map)reqMap.get("RequestValuesMap");

		String[] sourceObjectsOld = (String[])reqValMap.get("emxTableRowId");
		String[] sourceObjects = FrameworkUtil.getSplitTableRowIds(sourceObjectsOld);
		String[] destinationObjects = (String[])emxGetParameterValues(request, "emxTableRowId");

		String[] contParentIds = (String[])reqValMap.get("objectId");
		String contParentId = contParentIds[0];

		String[] sourceObjectsNew = null;
		MapList newSourceFolderList = new MapList();


		String sourceWSId = emxGetParameter(request, "objectId");
		String menuAction = (String)reqMap.get("menuAction");

//		 For Move/Copy contents case
		String strFromFolderId = null;

		final String RELATIONSHIP_VAULTED_OBJECTS = PropertyUtil.getSchemaProperty(context, "relationship_VaultedDocuments");

		WorkspaceVault sourceFolder = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,
			 DomainConstants.TEAM);
		WorkspaceVault destinationFolder = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,
			 DomainConstants.TEAM);
		
		
		
            if (destinationObjects ==null) {
%>
                <script language="javascript">
                    alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.NoDestinationSelectedCopyMoveContent", "emxTeamCentralStringResource", strLanguage)%>");
					var frame = findFrame(getTopWindow(), "content");
         			if(frame && frame.setSubmitURLRequestCompleted) {
        				frame.setSubmitURLRequestCompleted();
        			}
                </script>
<%                      
                return;
            }
            
		String[] destinationIds = new String[destinationObjects.length];
		StringTokenizer stok;
		for(int i=0; i<destinationObjects.length; i++)
		{
			String destId = destinationObjects[i];
			stok = new StringTokenizer(destId,"|",false);
			if( stok.hasMoreTokens())
			{
				destId = stok.nextToken();
			}
			destinationIds[i] = destId;
		}
		String destObjId = destinationIds[0];
		
		String sourceObjId = sourceWSId;
		String[] sourceIds = new String[]{sourceObjId};
		if( sourceObjects != null && sourceObjects.length > 0)
		{
			sourceIds = new String[sourceObjects.length];
			for(int i=0; i<sourceObjects.length; i++)
			{
				String sourceId = sourceObjects[i];
				stok = new StringTokenizer(sourceId,"|",false);
				if( stok.hasMoreTokens())
				{
					stok.nextToken();
				}
				if( stok.hasMoreTokens())
				{
					sourceId = stok.nextToken();
				}
				sourceIds[i] = sourceId;
			}
			sourceObjId = sourceIds[0];
		}
		
		//
		// Avoid Copy/Move/Link operation, to immediate parent folder/same folder/children subfolders.
		//
		if ( "moveContent".equals(menuAction) || "copyContent".equals(menuAction)) {
			// Find out the from folder id of the contents
			if (sourceObjects != null && sourceObjects.length > 0)
			{
			    DomainObject dmoContent = DomainObject.newInstance (context, sourceObjects[0]);
			    String[] strSourceFolderIds = (String[])reqValMap.get("objectId");
				String strSourceFolderId = strSourceFolderIds[0];
			    if (strSourceFolderId == null || "".equals(strSourceFolderId) || "null".equals(strSourceFolderId))
			    strSourceFolderId = dmoContent.getInfo (context, "to[" + RELATIONSHIP_VAULTED_OBJECTS + "].from.id");
			    if (strSourceFolderId != null && !"".equals(strSourceFolderId) && !"null".equals(strSourceFolderId)) {
			        if (strSourceFolderId.equals(destObjId)) {
%>
						<script language="javascript">
	                		alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMoveContentToSameFolder", "emxTeamCentralStringResource", strLanguage)%>");
							var frame = findFrame(getTopWindow(), "content");
	             			if(frame && frame.setSubmitURLRequestCompleted) {
	            				frame.setSubmitURLRequestCompleted();
	            			}
	              		</script>
<%			            
						return;
			        }
			        
			        DomainObject dmoDestination = DomainObject.newInstance (context, destObjId);
			        String strDestinationObjectType = dmoDestination.getInfo (context, DomainObject.SELECT_TYPE);
			        if (DomainObject.TYPE_WORKSPACE.equals(strDestinationObjectType)) {
 %>
 						<script language="javascript">
 	                		alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMoveContentToWorkspace", "emxTeamCentralStringResource", strLanguage)%>");
							var frame = findFrame(getTopWindow(), "content");
 	            			if(frame && frame.setSubmitURLRequestCompleted) {
								frame.setSubmitURLRequestCompleted();
							}
 	              		</script>
 <%			            
 						return;
			        }
			    }
			}

			destinationFolder.setId(destObjId);    
		}
		
		//
		// Avoid Add Link operation, from parent folders/same folder. while children subfolders are allowed.
		// Hint: If a folder has link of itself or of its parent folder then only a recursive structure is created in structure tree.
		//
		if ( "addLinkFolder".equals(menuAction)) {
		    DomainObject domainObject = null;
		    String strDestinationIdType = null;
		    
			// Find the parent folders for this source folders,
		    // make sure user has not selected any of the parent folders.
		    StringList busSelect = new StringList(DomainObject.SELECT_ID);
		    domainObject = DomainObject.newInstance(context, sourceObjId);
		    MapList mlParentFolders = domainObject.getRelatedObjects(context,
																							RELATIONSHIP_SUB_VAULTS,
																							DomainObject.TYPE_WORKSPACE_VAULT,
																							busSelect,
																							null,
																							true,
																							false,
																							(short)0,
																							"",
																							"");
		    Map mapParentInfo = null;
		    StringList slParentIds = new StringList();
		    for (Iterator itrParentFolders = mlParentFolders.iterator(); itrParentFolders.hasNext(); ) {
		        mapParentInfo = (Map)itrParentFolders.next();
		        slParentIds.add((String)mapParentInfo.get(DomainObject.SELECT_ID));
		    }
		    
			StringList busSelect2 = new StringList(SELECT_PARENT_FOLDER_ID);
	        busSelect2.add(SELECT_PARENT_WORKSPACE_ID);
            busSelect2.add(DomainObject.SELECT_TYPE);

		    for (int i=0; i<destinationIds.length; i++)
			{
		        domainObject = DomainObject.newInstance(context, destinationIds[i]);
		        
		        Map mapDestParentInfo = domainObject.getInfo (context, busSelect2);
		        String strParentFolderId = (String)mapDestParentInfo.get(SELECT_PARENT_FOLDER_ID);
		        String strParentWorkspaceId = (String)mapDestParentInfo.get(SELECT_PARENT_WORKSPACE_ID);
		        strDestinationIdType = (String)mapDestParentInfo.get(DomainObject.SELECT_TYPE);
		        StringList slInvalidFolders = new StringList();

		        if (UIUtil.isNotNullAndNotEmpty(strParentFolderId)) {
                    slInvalidFolders.add(strParentFolderId);   
                }
                if (UIUtil.isNotNullAndNotEmpty(strParentWorkspaceId)) {
                    slInvalidFolders.add(strParentWorkspaceId);   
                }
		        
		        
		        if ( (DomainObject.TYPE_WORKSPACE).equalsIgnoreCase(strDestinationIdType) ) {
%>
	                <script language="javascript">
	                	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotAddLinkWorkspace", "emxTeamCentralStringResource", strLanguage)%>");
						var frame = findFrame(getTopWindow(), "content");
	         			if(frame && frame.setSubmitURLRequestCompleted) {
	        				frame.setSubmitURLRequestCompleted();
	        			}
	              	</script>
<%
					return;
		        }
		        else if ( (sourceObjId != null && sourceObjId.equals (destinationIds[i])) || slParentIds.contains(destinationIds[i]) || slInvalidFolders.contains(sourceObjId)) {
%>
	                <script language="javascript">
	                	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotAddLinkSameOrParentFolder", "emxTeamCentralStringResource", strLanguage)%>");
						var frame = findFrame(getTopWindow(), "content");
	         			if(frame && frame.setSubmitURLRequestCompleted) {
	        				frame.setSubmitURLRequestCompleted();
	        			}
	              	</script>
<%
					return;			            
		        }
			}
		}

		
		
		//
		// Avoid Copy/Move/Link operation, to immediate parent folder/same folder/children subfolders.
		//
		if ( "moveFolder".equals(menuAction) || "copyFolder".equals(menuAction) || "linkFolder".equals(menuAction) ) {
		    
			// Validate if the folder is being moved to correct destination folder
            boolean isMovingToInvalidFolder = false;
            StringList slInvalidFolders = new StringList();

            StringList busSelect = new StringList(DomainObject.SELECT_ID);
            
            StringList busSelect2 = new StringList(SELECT_PARENT_FOLDER_ID);
            busSelect2.add(SELECT_PARENT_WORKSPACE_ID);
            
            MapList mlSubFoldersInfo = new MapList();
            Map mapSubFolderInfo = null;
            Map mapParentInfo = null;
            String strSubFolderId = null;
            DomainObject dmoSourceFolder = null;
			String strParentFolderId = null;
			String strParentWorkspaceId = null;
			
            for (int i = 0; i < sourceIds.length; i++) { 
                slInvalidFolders.add(sourceIds[i]);
                
                dmoSourceFolder = DomainObject.newInstance (context, sourceIds[i]);
                
                // This folder can be a top level folder, in that case the parent will be Workspace
                // If it is not top level folder then parent will be folder
                mapParentInfo = dmoSourceFolder.getInfo (context, busSelect2);
                strParentFolderId = (String)mapParentInfo.get(SELECT_PARENT_FOLDER_ID);
                strParentWorkspaceId = (String)mapParentInfo.get(SELECT_PARENT_WORKSPACE_ID);
                
                if (strParentFolderId != null && !"".equals(strParentFolderId) && !"null".equals(strParentFolderId)) {
                    slInvalidFolders.add(strParentFolderId);   
                }
                if (strParentWorkspaceId != null && !"".equals(strParentWorkspaceId) && !"null".equals(strParentWorkspaceId)) {
                    slInvalidFolders.add(strParentWorkspaceId);   
                }
                
				// Find all the subfolder ids of this folder
    			mlSubFoldersInfo = dmoSourceFolder.getRelatedObjects(context,
    			        										RELATIONSHIP_SUB_VAULTS,
    															DomainObject.TYPE_WORKSPACE_VAULT,
    															busSelect,
    															null,
    															false,
    															true,
    															(short)0,
    															"",
    															"");
    			if (mlSubFoldersInfo != null && mlSubFoldersInfo.size() != 0) {
	    			for (Iterator itrSubFolderInfo = mlSubFoldersInfo.iterator(); itrSubFolderInfo.hasNext();) {
	    			    mapSubFolderInfo = (Map)itrSubFolderInfo.next();
	    			    strSubFolderId = (String)mapSubFolderInfo.get(DomainObject.SELECT_ID);
	    			    slInvalidFolders.add(strSubFolderId);
	    			}
    			}
            }//for each selected folder

            isMovingToInvalidFolder = slInvalidFolders.contains(destObjId);
           
            if (isMovingToInvalidFolder) {
            	
                // Error message
%>
	                <script language="javascript">
	                	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMoveLinkToInvalidFolder", "emxTeamCentralStringResource", strLanguage)%>");
						var frame = findFrame(getTopWindow(), "content");
	         			if(frame && frame.setSubmitURLRequestCompleted) {
	        				frame.setSubmitURLRequestCompleted();
	        			}
	              	</script>
<%
                
				return;                
            }
		}
		
		//Added for Duplicate Folder Names R2010x
		//
		// Avoid Copy/Move/Link operation, to immediate parent folder/same folder/children subfolders.
		//
		if ( "moveFolder".equals(menuAction) || "copyFolder".equals(menuAction) || "cloneFolder".equals(menuAction) ) {
		    
			// Validate if the folder is being moved to correct destination folder
            boolean isMovingToInvalidFolder = false;
            StringList slInvalidFolders = new StringList();
	     StringList slInvalidFolderIds = new StringList();

            StringList busSelect = new StringList(DomainObject.SELECT_ID);
            busSelect.add(DomainObject.SELECT_NAME);
            StringList busSelect2 = new StringList(SELECT_PARENT_FOLDER_ID);
            busSelect2.add(SELECT_PARENT_WORKSPACE_ID);
            String strDestFolderType=null;
            MapList mlSubFoldersInfo = new MapList();
            Map mapSubFolderInfo = null;
            Map mapParentInfo = null;
            String strSubFolderId = null;
            String strSubFolderName = null;
            DomainObject dmoSourceFolder = null;
            DomainObject dmoDestFolder = null;
			String strParentFolderId = null;
			String strParentFolderName = null;
			String strParentWorkspaceId = null;
			String strParentWorkspaceName = null;
			String strDestFolderName = null;
			DomainObject doParentFolder = null;
			DomainObject doParentWS = null;
			String strSourceObjName = null;
			dmoSourceFolder = DomainObject.newInstance(context,sourceObjId);
			strSourceObjName = (String)dmoSourceFolder.getInfo(context,DomainObject.SELECT_NAME);
            for (int i = 0; i < destinationIds.length; i++) { 
                slInvalidFolders.add(sourceIds[i]);
                
                dmoDestFolder = DomainObject.newInstance (context, destinationIds[i]);
                strDestFolderName = (String)dmoDestFolder.getInfo(context,DomainObject.SELECT_NAME);
                strDestFolderType=(String)dmoDestFolder.getInfo(context,DomainObject.SELECT_TYPE);
                slInvalidFolders.add(strDestFolderName);
                // This folder can be a top level folder, in that case the parent will be Workspace
                // If it is not top level folder then parent will be folder
                mapParentInfo = dmoSourceFolder.getInfo (context, busSelect2);
                strParentFolderId = (String)mapParentInfo.get(SELECT_PARENT_FOLDER_ID);
                strParentWorkspaceId = (String)mapParentInfo.get(SELECT_PARENT_WORKSPACE_ID);
                //doParentFolder = DomainObject.newInstance(context,strParentFolderId);
                //doParentWS = DomainObject.newInstance(context,strParentWorkspaceId);
               // strParentFolderName = (String)doParentFolder.getInfo(context,DomainObject.SELECT_NAME);
               // strParentWorkspaceName = (String)doParentWS.getInfo(context,DomainObject.SELECT_NAME);
                
                if (strParentFolderId != null && !"".equals(strParentFolderId) && !"null".equals(strParentFolderId)) {
                    slInvalidFolders.add(strParentFolderId);   
                }
                if (strParentWorkspaceId != null && !"".equals(strParentWorkspaceId) && !"null".equals(strParentWorkspaceId)) {
                    slInvalidFolders.add(strParentWorkspaceId);   
                }
                
				// Find all the subfolder ids of this folder
    			mlSubFoldersInfo = dmoDestFolder.getRelatedObjects(context,
    					RELATIONSHIP_SUB_VAULTS+","+RELATIONSHIP_LINKED_FOLDERS,
    															DomainObject.TYPE_WORKSPACE_VAULT,
    															busSelect,
    															null,
    															false,
    															true,
    															(short)1,
    															"",
    															"");
    			if (mlSubFoldersInfo != null && mlSubFoldersInfo.size() != 0) {
	    			for (Iterator itrSubFolderInfo = mlSubFoldersInfo.iterator(); itrSubFolderInfo.hasNext();) {
	    			    mapSubFolderInfo = (Map)itrSubFolderInfo.next();
	    			    strSubFolderId = (String)mapSubFolderInfo.get(DomainObject.SELECT_ID);
	    			    strSubFolderName = (String)mapSubFolderInfo.get(DomainObject.SELECT_NAME);
	    			    String rel =  (String)mapSubFolderInfo.get("relationship");
	    			    if(RELATIONSHIP_LINKED_FOLDERS.equals(rel)){
	    			    	slInvalidFolderIds.add(strSubFolderId);
	    			    } else {
	    			    slInvalidFolders.add(strSubFolderName);
	    			}
	    			}
    			}
            }//for each selected folder

            isMovingToInvalidFolder = slInvalidFolders.contains(strSourceObjName);
            //IR-009758V6R2010x starts
            String i18NSubFolderName = EnoviaResourceBundle.getProperty(context, "emxTeamCentral.Common.CheckforSubFolderName");
            
            if(i18NSubFolderName.equalsIgnoreCase("true"))
            { 
            if (isMovingToInvalidFolder) {
                // Error message
%>
	                <script language="javascript">
	                	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMoveCloneDuplicateFolder", "emxTeamCentralStringResource", strLanguage)%>");
						var frame = findFrame(getTopWindow(), "content");
	         			if(frame && frame.setSubmitURLRequestCompleted) {
	        				frame.setSubmitURLRequestCompleted();
	        			}
	              	</script>
<%
            }	//     IR-009758V6R2010x  ends
             return;
			}else if(strDestFolderType.equals("Workspace") && "moveFolder".equals(menuAction)){
            	// Error message
            	%>
            	<script language="javascript">
             	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMovetoTopLevel", "emxTeamCentralStringResource", strLanguage)%>");
				var frame = findFrame(getTopWindow(), "content");
     			if(frame && frame.setSubmitURLRequestCompleted) {
    				frame.setSubmitURLRequestCompleted();
    			}
           	</script>
           	<%
           	     return;
           	}  else if(("moveFolder".equals(menuAction) || "copyFolder".equals(menuAction)) && slInvalidFolderIds.contains(sourceObjId)){
											// Error message
				%>
									<script language="javascript">
										alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCopyMoveWhereSameLinkedFolder", "emxTeamCentralStringResource", strLanguage)%>");
										var frame = findFrame(getTopWindow(), "content");
						     			if(frame && frame.setSubmitURLRequestCompleted) {
						    				frame.setSubmitURLRequestCompleted();
						    			}
									</script>
				<%
								//     IR-009758V6R2010x  ends
							 return;
           	}
		}
		
		//Addition ends for Duplicate Folder Names R2010x
		
		//
		// Avoid Clone/Copy/Move operations on linked folders.
		//
		if ( "moveFolder".equals(menuAction) || "copyFolder".equals(menuAction) || "cloneFolder".equals(menuAction) ) {
		   
		    // emxParentIds=42288.36793.59856.8843|42288.36793.19456.21412~42288.36793.41568.18368|42288.36793.41568.20651
		    String strEmxParentIds = emxGetParameter (request, "emxParentIds");
		    if (strEmxParentIds == null || "".equals(strEmxParentIds.trim()) || "null".equals(strEmxParentIds.trim())) {
		        strEmxParentIds = "";
		    }
		    
		    Map mapLinkingInformation = new HashMap();
		    
		    // Separate the relationship ids and partially fill the linking information
		    StringList slEmxParentIds = com.matrixone.apps.domain.util.FrameworkUtil.split (strEmxParentIds, "~");
		    String strEmxParentId = "";
		    StringList slRelIdObjId = null;
		    String strRelId = "";
		    String strObjectId = "";
		    String[] strRelIds = new String[slEmxParentIds.size()];
		    int i = 0;
		    
		    for (Iterator itrEmxParentIds = slEmxParentIds.iterator(); itrEmxParentIds.hasNext();) {
		        strEmxParentId = (String)itrEmxParentIds.next();
		        
		        slRelIdObjId = FrameworkUtil.split(strEmxParentId, "|");
		        
		        strRelId = (String)slRelIdObjId.get(0);
		        strObjectId = (String)slRelIdObjId.get(1);
		        
		        mapLinkingInformation.put (strRelId, strObjectId);
		        
		        strRelIds[i] = strRelId;
		        i++;
		    }
		    
		    // Find the relationship types
		    StringList slRelSelect = new StringList(com.matrixone.apps.domain.DomainRelationship.SELECT_TYPE);
		    slRelSelect.add(com.matrixone.apps.domain.DomainRelationship.SELECT_ID);
			MapList mlRelInfos = null;
			String strRelType = "";
		    if (strRelIds.length != 0) {
		        mlRelInfos = com.matrixone.apps.domain.DomainRelationship.getInfo (context, strRelIds, slRelSelect);
		        
		        // Update the linking information map
		        Map mapRelInfos = null;
		        for (Iterator itrRelInfos = mlRelInfos.iterator(); itrRelInfos.hasNext();) {
		            mapRelInfos = (Map)itrRelInfos.next();
		            
		            strRelId = (String)mapRelInfos.get(com.matrixone.apps.domain.DomainRelationship.SELECT_ID);
		            strRelType = (String)mapRelInfos.get(com.matrixone.apps.domain.DomainRelationship.SELECT_TYPE);
		            
		            strObjectId = (String)mapLinkingInformation.get(strRelId);
		            if (RELATIONSHIP_LINKED_FOLDERS.equals(strRelType)) {
                        mapLinkingInformation.put(strObjectId, "LinkedFolder");
		            }
		            else {
		                if (!"LinkedFolder".equals(mapLinkingInformation.get(strObjectId))) { // If already present, we should not lose the linked folder information
	                        mapLinkingInformation.put(strObjectId, "NotLinkedFolder");
	                    }
		            }
		            mapLinkingInformation.remove(strRelId);
		        }
		    }
		    
		    // Decide if the folders are linked ones
		    for (i=0; i<sourceIds.length; i++)
			{
				sourceFolder.setId (sourceIds[i]);
				if ("LinkedFolder".equals((String)mapLinkingInformation.get(sourceIds[i]))) {
                // Error message
%>
	                <script language="javascript">
	                	alert("<%=i18nNow.getI18nString("emxTeamCentral.Common.CannotCloneCopyMoveTheLinkedFolder", "emxTeamCentralStringResource", strLanguage)%>");
						var frame = findFrame(getTopWindow(), "content");
	         			if(frame && frame.setSubmitURLRequestCompleted) {
	        				frame.setSubmitURLRequestCompleted();
	        			}
	              	</script>
<%				    
				    return;
				}
			}
		    
		}
				
		String failedDocuments = null;
		
		if ( "moveFolder".equals(menuAction) )
		{
                WorkspaceVault.moveFolders(context, destObjId, sourceIds);
		}
		else if ( "copyFolder".equals(menuAction) )
		{
			destinationFolder.setId(destObjId);
			for (int i=0; i<sourceIds.length; i++)
			{
				sourceFolder.setId(sourceIds[i]);
				try{
				newSourceFolderList.add(sourceFolder.cloneStructureForId(context, destinationFolder, true));
				}catch(Exception ex){
					String sExceptionMsg = ex.getMessage();
					String sTNRNotUnique = "Business object 'type name revision' not unique";
					if(sExceptionMsg.contains(sTNRNotUnique))
					{
						 String sTranslatedMessage = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(),"emxTeamCentral.Common.CannotCopyDuplicateFolder");			  
					 	 session.putValue("error.message", sTranslatedMessage);
					}else{
						session.putValue("error.message",ex.toString());
					}
				}
			}
		}
		else if ( "cloneFolder".equals(menuAction) )
		{
			destinationFolder.setId(destObjId);
			for (int i=0; i<sourceIds.length; i++)
			{
				sourceFolder.setId(sourceIds[i]);
				newSourceFolderList.add(sourceFolder.cloneStructureForId(context, destinationFolder, false));
			}
		}
		else if ( "linkFolder".equals(menuAction) )
		{
			WorkspaceVault.linkFolders(context, destObjId, sourceIds);
		}
		else if ( "addLinkFolder".equals(menuAction) )
		{
		    for(int i=0; i <sourceIds.length ; i++ ){
		    WorkspaceVault.linkFolders(context, sourceIds[i], destinationIds);
		    }
		}
		else if ( "copyContent".equals(menuAction) )
		{
			// Find out the from folder id of the contents
			if (sourceObjects != null && sourceObjects.length > 0)
			{
			    DomainObject dmoContent = DomainObject.newInstance (context, sourceObjects[0]);
			    strFromFolderId = dmoContent.getInfo (context, "to[" + RELATIONSHIP_VAULTED_OBJECTS + "].from.id");
			}

			destinationFolder.setId(destObjId);
			failedDocuments = destinationFolder.moveCopyContent(context, sourceObjects, null, false);
		}
		else if ( "moveContent".equals(menuAction) )
		{
		    // Find out the from folder id of the contents
		    strFromFolderId = contParentId;

			destinationFolder.setId(destObjId);
			failedDocuments = destinationFolder.moveCopyContent(context, sourceObjects, contParentId, true);
		}



	//---------------------------Structure Tree Reload-------------------------------------
    //	Find the value for "Linked" suffix in structure tree node name
	i18nNow loc = new i18nNow();
	final String RESOURCE_BUNDLE = "emxTeamCentralStringResource";
	final String STRING_LINKED = (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxTeamCentral.Common.Linked");

	// We must reload (not just refresh) the object structure tree, user might have copied the folder into same workspace/workspace folder.
	// Structure tree object. We do not need to update the objDetailsTree because there will not be any change due to copy
	// operation.
	String strFolderId = "";
	String jsTreeID = emxGetParameter(request, "jsTreeID");
	String strSuiteDirectory = emxGetParameter(request, "SuiteDirectory");

	StringList busSelect = new StringList(DomainObject.SELECT_ID);
	busSelect.add(DomainObject.SELECT_NAME);

	StringList relSelect = new StringList(DomainRelationship.SELECT_ID);

	// Decide which is the destination folder for this operation
	String strParentId = destObjId;
	if ( "addLinkFolder".equals (menuAction))
	{
	    strParentId = sourceObjId;
	}

	// For Move/Copy contents case needs strFromFolderId and strToFolderId
	String strToFolderId = null;
	if ( "copyContent".equals (menuAction) || "moveContent".equals (menuAction))
	{
	    strToFolderId = destObjId;
	    // The strFromFolderId is already set above
	}
	
	if(failedDocuments != null){
        String moveCopyError = (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxTeamCentral.MoveCopyConent.AlreadyExistsError");
        moveCopyError = moveCopyError + failedDocuments ;
        session.putValue("error.message",moveCopyError);
    }
%>

       
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>
       
        
<script language="javascript">
    var strTreeId = "<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>"; 
    var strSuiteDirectory = "<%=XSSUtil.encodeForJavaScript(context, strSuiteDirectory)%>";
    var refreshTrees = true;
	var refreshDetailsFrame = false;
			// Find the content frame where emxTree.jsp is loaded. There are some JS APIs to add nodes in structure tree
			var contentFrame = openerFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
			if (!contentFrame)
			{
				throw "content frame could not be accessed";
			}

			// Find the structure tree object reference
			if (contentFrame.getTopWindow().objStructureTree)
			{
			var objStructureTree = contentFrame.getTopWindow().objStructureTree; // From emxNavigator.jsp
			}else{
				var objStructureTree = contentFrame.getTopWindow().getWindowOpener().parent.getTopWindow().objStructureTree;		// From emxNavigator.jsp		
			}
			// Do if we get valid structure tree pointer
			if (!objStructureTree)
			{
				throw "objStructureTree could not be accessed";
			}
<%
			if ("moveFolder".equals(menuAction))
			{
			    for (int i = 0; i < sourceIds.length; i++)
			    {
%>
					getTopWindow().getWindowOpener().parent.getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, sourceIds[i])%>", false);
<%
			    }
				%>	
			    
	
			    <%
			}
		if ( !("copyContent".equals (menuAction) || "moveContent".equals (menuAction)) ){
		    String[] sourceObjectIds = sourceIds;
		    String[] destinationObjectIds = destinationIds;
		    if ( "addLinkFolder".equals(menuAction)) {
		       sourceObjectIds = destinationIds;
			   destinationObjectIds = sourceIds;
		    }
		    for(int j=0; j < destinationObjectIds.length; j++){
			DomainObject destinationObject = DomainObject.newInstance (context, destinationObjectIds[j]);
			MapList linkedFolderInfo = destinationObject.getRelatedObjects(context,
			        										RELATIONSHIP_LINKED_FOLDERS,
															DomainObject.TYPE_WORKSPACE_VAULT,
															busSelect,
															relSelect,
															false,
															true,
															(short)1,
															"",
															"");
			HashMap linkedFoldersIds = new HashMap();
			for (Iterator itrFolders = linkedFolderInfo.iterator(); itrFolders.hasNext();)
			{
			    Map mapFolderInfo = (Map)itrFolders.next();
			    String linkFolderId = (String)mapFolderInfo.get(DomainObject.SELECT_ID);
			    String linkFolderRel = (String)mapFolderInfo.get("id[connection]");
			    linkedFoldersIds.put(linkFolderId,linkFolderRel);
			}

			sourceObjectsNew = new String[sourceObjects.length];
	        int ix = 0;
	        for (Iterator itr = newSourceFolderList.iterator(); itr.hasNext();)
			{
			    Map mapFolderInfo = (Map)itr.next();
			    String folderId = (String)mapFolderInfo.get(DomainObject.SELECT_ID);
			    sourceObjectsNew[ix++] = folderId ; 
				  	
			}
			
			if(destinationObject.getType(context).equals(DomainConstants.TYPE_WORKSPACE) &&  !"addLinkFolder".equals(menuAction)){
		  		sourceObjectIds = sourceObjectsNew;
			}		  		
			
		  	String nodeId = null;

			for(int i = 0 ;i < sourceObjectIds.length ; i++) {



				nodeId = XSSUtil.encodeForJavaScript(context, sourceObjectIds[i]);

%>
		//XSSOK
		contentFrame.getTopWindow().addStructureTreeNode("<%=nodeId%>", "<%=XSSUtil.encodeForJavaScript(context, destinationObjectIds[j])%>", strTreeId, strSuiteDirectory, true, "<%=linkedFoldersIds.get(XSSUtil.encodeForJavaScript(context, sourceObjectIds[0]))%>", null, false);
<%
			}
	    }


		}else{
			//Move and Copy content doesn't require refreshing the tree, On Moce only refresh details frame
			if("moveContent".equals(menuAction)){
				%>
				refreshDetailsFrame = true;
				<%
			}			
			%>
		    refreshTrees = false;
		    <%
		}
		//renaming the all the related node including the source and destination objects
				MapList sourceFolderMapList =  new  MapList();
				MapList destinationFolderMapList =  new  MapList(); 
				MapList folderMapList =  new  MapList();
				String[] sourceObjectIds = (String[])reqValMap.get("objectId");
				String sourceObjectId = sourceObjectIds[0];
				if(sourceObjectId != null){
					if(!((DomainObject.newInstance(context, sourceObjectId)).getType(context).equals(DomainConstants.TYPE_WORKSPACE)))
						sourceFolderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,sourceObjectId);
				}
				if(!((DomainObject.newInstance(context, destObjId)).getType(context).equals(DomainConstants.TYPE_WORKSPACE))){
					destinationFolderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,destObjId);
				}else{
					sourceFolderMapList = newSourceFolderList;
				}

				folderMapList.addAll(sourceFolderMapList);
				folderMapList.addAll(destinationFolderMapList);
		     	if(folderMapList != null && folderMapList.size() > 0 ){
		        Iterator folderMapListItr = folderMapList.iterator();
		        while(folderMapListItr.hasNext()) {
		          	Map folderMap = (Map)folderMapListItr.next();
		          	String foldn  = (String)folderMap.get(WorkspaceVault.SELECT_NAME);
		          	String foldId = (String)folderMap.get(WorkspaceVault.SELECT_ID);
		          	String treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,foldId,(String)null,appDirectory,sLanguage);
					if(!"addLinkFolder".equals(menuAction)){
				%>
					getTopWindow().opener.getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForURL(context, foldId)%>", "<%=treeLabel%>");
				<%}
		        }
		     	}
%>
   
	if(refreshTrees){
		if(getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().bclist && getTopWindow().getWindowOpener().getTopWindow().bclist.getCurrentBC().fancyTreeData){
   		   var objStructureFancyTree = getTopWindow().getWindowOpener().getTopWindow().objStructureFancyTree;
   		   var currBC = getTopWindow().getWindowOpener().getTopWindow().bclist.getCurrentBC();
   		   if(objStructureFancyTree){
   		    	objStructureFancyTree.reInit(currBC.fancyTreeData, true);
   				var nodeExists=objStructureFancyTree.getNodeById(currBC.id);
				if(nodeExists){
					nodeExists.setFocus();
				}
   		   }
   		    contentFrame.getTopWindow().refreshDetailsTree();
   	   	}else{
			contentFrame.getTopWindow().refreshTrees();
   		}
	}
   if(refreshDetailsFrame){
		contentFrame.getTopWindow().refreshDetailsTree();
   }
   getTopWindow().closeWindow();
</script>
<%
	//---------------------------Structure Tree Reload-------------------------------------

	}
	catch(Exception ex)
	{
		ex.printStackTrace();
		String errorMessage = ex.toString();
		if(errorMessage.contains("emxTeamCentral.WorkspaceVault.MoveOperationError")){
			errorMessage = EnoviaResourceBundle.getProperty(context,
                    "emxTeamCentralStringResource",
                    context.getLocale(),
                    "emxTeamCentral.WorkspaceVault.MoveOperationError");
		}
		if(UIUtil.isNotNullAndNotEmpty(errorMessage)){
			errorMessage = errorMessage.replace("java.lang.Exception:","");
		}
        session.putValue("error.message",errorMessage);
		
%>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>
<html>
<body>
<script language="javascript">
	var detailsDisplay = openerFindFrame(getTopWindow(), 'detailsDisplay');
  if(detailsDisplay){
	  detailsDisplay.location.href = detailsDisplay.location.href;
	  }
	getTopWindow().closeWindow();
</script>
</body>
</html>
<%
	}
%>
