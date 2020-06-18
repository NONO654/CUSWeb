<%--
    This is an exact copy of emxTeamMoveCopyFoldersContentProcess.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    java code was added to update the SB with new node(s)
    updateStructureTree() call has been commented out because this
    	code does not work with the homepage.
    The call to close the popup has been moved to the call to 
    	sbExpandItems
    An error is printed to the screen if an exception occurs while 
    	trying to connect two items for an "addLinkFolder" command.
--%>

<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="smaStructureBrowser.js" type="text/javascript"></script>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
 
<script language="Javascript">
  //Structure tree object
  var strucTree     = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
  //Context tree object
  var contextTree       = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;

  function changeTreeName(sFolderId, sTreeLabel)
  {
    if(contextTree) {
      var conTreeNodeArray = contextTree.objects[sFolderId];
      if(conTreeNodeArray)
      conTreeNodeArray.nodes[0].changeObjectName(sTreeLabel,false);
    }

    var struTreeNodeArray = strucTree.objects[sFolderId];
    if(struTreeNodeArray) {
      struTreeNodeArray.nodes[0].changeObjectName(sTreeLabel,false);
      struTreeNodeArray.nodes[0].tree.doNavigate=false;
    }
  }
</script>

<%
	try
	{
		final String RELATIONSHIP_DATA_VAULTS = PropertyUtil.getSchemaProperty(context, "relationship_ProjectVaults");
		final String RELATIONSHIP_SUB_VAULTS = PropertyUtil.getSchemaProperty(context, "relationship_SubVaults");
		final String RELATIONSHIP_LINKED_FOLDERS = PropertyUtil.getSchemaProperty(context, "relationship_LinkedFolders");
		final String SELECT_PARENT_FOLDER_ID = "to[" + RELATIONSHIP_SUB_VAULTS + "].from.id";
		final String SELECT_PARENT_WORKSPACE_ID = "to[" + RELATIONSHIP_DATA_VAULTS + "].from.id";
		
		String strLanguage = request.getHeader("Accept-Header");
	    
	    String timeStamp = emxGetParameter(request, "timeStamp");
		Map reqMap = (Map)indentedTableBean.getRequestMap(timeStamp);
		Map reqValMap = (Map)reqMap.get("RequestValuesMap");

		String[] sourceObjects = (String[])reqValMap.get("emxTableRowId");
		String[] destinationObjects = (String[])emxGetParameterValues(request, "emxTableRowId");

		String[] contParentIds = (String[])reqValMap.get("objectId");
		String contParentId = contParentIds[0];

		String sourceWSId = emxGetParameter(request, "objectId");
		String menuAction = (String)reqMap.get("menuAction");

//		 For Move/Copy contents case
		String strFromFolderId = null;

		final String RELATIONSHIP_VAULTED_OBJECTS = PropertyUtil.getSchemaProperty(context, "relationship_VaultedDocuments");

		WorkspaceVault sourceFolder = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,
			 DomainConstants.TEAM);
		WorkspaceVault destinationFolder = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,
			 DomainConstants.TEAM);
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
		if( sourceObjects != null )
		{
			sourceIds = new String[sourceObjects.length];
			for(int i=0; i<sourceObjects.length; i++)
			{
				String sourceId = sourceObjects[i];
				stok = new StringTokenizer(sourceId,"|",false);
				
				//Do not skip if there is no rel id. (Happens on homepage)
				if( stok.hasMoreTokens() && stok.countTokens() > 2)
				{
					stok.nextToken(); // needs work
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
			    String strSourceFolderId = dmoContent.getInfo (context, "to[" + RELATIONSHIP_VAULTED_OBJECTS + "].from.id");
			    if (strSourceFolderId != null && !"".equals(strSourceFolderId) && !"null".equals(strSourceFolderId)) {
			        if (strSourceFolderId.equals(destObjId)) {
%>
						<script language="javascript">
	                		alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotCopyMoveContentToSameFolder")%>");
	              		</script>
<%			            
						return;
			        }
			        
			        DomainObject dmoDestination = DomainObject.newInstance (context, destObjId);
			        String strDestinationObjectType = dmoDestination.getInfo (context, DomainObject.SELECT_TYPE);
			        if (DomainObject.TYPE_WORKSPACE.equals(strDestinationObjectType)) {
 %>
 						<script language="javascript">
 	                		alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotCopyMoveContentToWorkspace")%>");
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
		    
		    for (int i=0; i<destinationIds.length; i++)
			{
		        domainObject = DomainObject.newInstance(context, destinationIds[i]);
		        strDestinationIdType = domainObject.getInfo(context, DomainObject.SELECT_TYPE);
		        
		        if ( (DomainObject.TYPE_WORKSPACE).equalsIgnoreCase(strDestinationIdType) ) {
%>
	                <script language="javascript">
	                	alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotAddLinkWorkspace")%>");
	              	</script>
<%
					return;
		        }
		        else if ( (sourceObjId != null && sourceObjId.equals (destinationIds[i])) || slParentIds.contains(destinationIds[i])) {
%>
	                <script language="javascript">
	                	alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotAddLinkSameOrParentFolder")%>");
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
	                	alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotCopyMoveLinkToInvalidFolder")%>");
	              	</script>
<%
				return;                
            }
		}
		
		
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
	                	alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.CannotCloneCopyMoveTheLinkedFolder")%>");
	              	</script>
<%				    
				    return;
				}
			}
		    
		}
		
		
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
				sourceFolder.cloneStructure(context, destinationFolder, true);
			}
		}
		else if ( "cloneFolder".equals(menuAction) )
		{
			destinationFolder.setId(destObjId);
			for (int i=0; i<sourceIds.length; i++)
			{
				sourceFolder.setId(sourceIds[i]);
				sourceFolder.cloneStructure(context, destinationFolder, false);
			}
		}
		else if ( "linkFolder".equals(menuAction) )
		{
			WorkspaceVault.linkFolders(context, destObjId, sourceIds);
		}
		else if ( "addLinkFolder".equals(menuAction) )
		{
		    try
		    {
		    	WorkspaceVault.linkFolders(context, sourceObjId, destinationIds);
		    }
		    catch(Exception e)
		    {
		        
%>		        
		    <script language="javascript">
            	alert("<%=EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"smaHome.cmdChecks.CannotBeLinked")%>");
          	</script>
<%          	
		        //Swallow it and do nothing
		        System.out.println(e.getMessage());	
				return;
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
			destinationFolder.moveCopyContent(context, sourceObjects, null, false);
		}
		else if ( "moveContent".equals(menuAction) )
		{
		    // Find out the from folder id of the contents
		    strFromFolderId = contParentId;

			destinationFolder.setId(destObjId);
			destinationFolder.moveCopyContent(context, sourceObjects, contParentId, true);
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
	
	//Add the new node(s) to the SB
	String parentRowId = emxGetParameter(request, "emxTableRowId");
    String folderId = destObjId;
    
	//Create lineage string      
    Map argsMap = new HashMap();
    argsMap.put("objectId", sourceObjId);

    String lineage = (String) JPO.invoke(
        context,
        "jpo.simulation.Home",
        null,
        "getLineageOIDs",
        JPO.packArgs(argsMap),
        String.class);
      
    String lineageOids =  lineage + "," + folderId;
    
    String action = "ADD";
	String message = "";
    matrix.db.Relationship rel = null;
    
    String relId = "";
    
    String rowId = "";
    String sXML = "";
    
    //loop through all the selected objects and add them to the tree
    for(int ii = 0; ii < destinationIds.length; ii++)
    {
    	rowId = sourceObjects[0];
		if("addLinkFolder".equals(menuAction))
		{
	    	DomainObject folderDO = new DomainObject(destinationIds[ii]);
	    	MapList found = folderDO.getRelatedObjects(context, 
                RELATIONSHIP_LINKED_FOLDERS, // String Relationship pattern
                "*",          // String type pattern
                true,        // boolean getTo
                false,       // boolean getFrom
                (short)1,     // short recurseToLevel
                new StringList(DomainConstants.SELECT_RELATIONSHIP_ID),         // StringList objectSelects
                null,         // StringList relationshipSelects
                null,         // String objectWhere
                null,         // String relationshipWhere
                null,         // String postRelPattern
                null,         // String postTypePattern
                null );       // Map postPatterns
                
            for(int i = 0; i < found.size(); i++)
            {
                
            	Map link = (Map)found.get(i);
            	if(link.get(DomainConstants.SELECT_ID).equals(sourceIds[0]))
            	{
            	    relId = (String)link.get(DomainConstants.SELECT_RELATIONSHIP_ID);
            	}
            }
		}

    	// Convert parent ID and added content to an appropriate javascript
    	// code that either adds the entities or displays an error message.
    	StringList contentData = new StringList();
    	contentData.add(destinationIds[ii] + "|" + relId);
    	sXML += StructureBrowserUtil.convertToXMLString(
        	context, action, message, rowId, contentData, 
            	"smaHomeTOCContent", false );
    }
%>

<%=sXML %>

<script language="javascript">
<!--

<%
	// Define hasImmediateChild function depending upon the operation.
	// For linking functionality the on same level of the tree there can be two nodes with same object id. One linked and another actual folder.
	// To take care of this situation there are different implementation of this function.
	if ("linkFolder".equals(menuAction) || "addLinkFolder".equals(menuAction))
	{
%>
		function hasImmediateChild (objNode, strNodeObjectId) {
			if (objNode != null) {
				var duplicateChildNodes = new Array;
				var childNodes = objNode.childNodes;
				for (var i = 0; i < childNodes.length; i++) {
					var objChildNode = childNodes[i];
					if (objChildNode.objectID == strNodeObjectId) {
						duplicateChildNodes[duplicateChildNodes.length] = objChildNode;
					}
				}

				// From the duplicate childs nodes ignore the actual folders, and check with only linked folder
				var strSuffix = "(<%=STRING_LINKED%>)";
				for (var i = 0; i < duplicateChildNodes.length; i++) {
					var objChildNode = duplicateChildNodes[i];
					if (objChildNode.text.indexOf(strSuffix) != -1 ) {
						return true;
					}
				}
			}

			return false;
		}// hasImmediateChild()
<%
	}
	else
	{
%>
		// Finds fot the given node, if there is immediate child with given id
		function hasImmediateChild (objNode, strNodeObjectId) {
			if (objNode != null) {
				var childNodes = objNode.childNodes;
				for (var i = 0; i < childNodes.length; i++) {
					var objChildNode = childNodes[i];
					if (objChildNode.objectID == strNodeObjectId) {
						return true;
					}
				}
			}

			return false;
		}// hasImmediateChild()
<%
	}
%>

	// Reloads subtree for any none root node in structure tree
	function reloadSubtree (objNode) {
		if (objNode) {
			objNode.clear();
			objNode.loaded = false;
			objNode.collapse();
			//objNode.expand();
		}
	}// reloadSubtree()

	var updateFolderNodeNames = false;

  	function updateStructureTree ()
  	{
		try
		{
			// Find the content frame where emxTree.jsp is loaded. There are some JS APIs to add nodes in structure tree
			var contentFrame = findFrame (getTopWindow().getWindowOpener().getTopWindow(), "content");
			if (!contentFrame)
			{
				throw "content frame could not be accessed";
			}

			// Find the structure tree object reference
			var objStructureTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree; // From emxNavigator.jsp
			if (!objStructureTree)
			{
				objStructureTree = contentFrame.objStructureTree; // From emxTree.jsp
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
					objStructureTree.deleteObject ("<%=sourceIds[i]%>", false);
<%
			    }
%>
				objStructureTree.refresh();
<%
			}
%>
			var strChildId = "";
			var strParentId = "<%=strParentId%>";
			var strTreeId = "<%=jsTreeID%>";
			var strSuiteDirectory = "<%=strSuiteDirectory%>";
			var objParentNode = null;
			var objNodeToRemove = null;

			// Check if the destination object is from this structure tree
			var objParentNode = objStructureTree.findNodeByObjectID(strParentId);
<%
			//Is destination a workspace?
			DomainObject dmoObject = DomainObject.newInstance(context, strParentId);
			String strObjectType = dmoObject.getInfo(context, DomainObject.SELECT_TYPE);
			boolean isDestWorkspace = DomainObject.TYPE_WORKSPACE.equals(strObjectType);

			// Find the workspace id
			String strWorkspaceId = null;
			if (isDestWorkspace)
			{
			    strWorkspaceId = strParentId;
			}
			else
			{
			    WorkspaceVault workspaceVault = new WorkspaceVault (strParentId);

			    Map mapTopFolder = workspaceVault.getTopLevelVault (context, new StringList(DomainObject.SELECT_ID));
			    String strTopFolderId = (String)mapTopFolder.get(DomainObject.SELECT_ID);

			    workspaceVault.setId (strTopFolderId);
			    strWorkspaceId = workspaceVault.getInfo (context, "to[" + RELATIONSHIP_DATA_VAULTS + "].from.id");
			}

			// Find out the subfolders from this destination node now,
			// there might be some new onces here due to copy/move
			// Get all the first level folders of the workspace
			DomainObject dmoWorkspace = DomainObject.newInstance (context, strWorkspaceId);
			MapList mlFoldersInfo = dmoWorkspace.getRelatedObjects(context,
			        										RELATIONSHIP_DATA_VAULTS + "," + RELATIONSHIP_LINKED_FOLDERS,
															DomainObject.TYPE_WORKSPACE_VAULT,
															busSelect,
															relSelect,
															false,
															true,
															(short)1,
															"",
															"");

			// If the destination object is workspace then we have to add the new folders in tree
			if (isDestWorkspace)
			{
				// There will be some already attached folders and some those needs to be attached in structure tree now!
				String strRelationshipName = "";
				for (Iterator itrFolders = mlFoldersInfo.iterator(); itrFolders.hasNext();)
				{
				    Map mapFolderInfo = (Map)itrFolders.next();
				    strFolderId = (String)mapFolderInfo.get(DomainObject.SELECT_ID);
				    strRelationshipName = (String)mapFolderInfo.get("relationship");
				    String strFolderName = (String)mapFolderInfo.get(DomainObject.SELECT_NAME);
%>
					strChildId = "<%=strFolderId%>";
					// Check if this node is not already immediate child of objParentNode
					// if it is not then add it to the tree
					if (objParentNode != null && !hasImmediateChild (objParentNode, strChildId) )
					{
<%
						if (RELATIONSHIP_DATA_VAULTS.equals(strRelationshipName))
						{
%>
                            contentFrame.addStructureTreeNode (strChildId, strParentId, strTreeId, strSuiteDirectory, false);
                            updateFolderNodeNames = true;
<%
						}
						else if (RELATIONSHIP_LINKED_FOLDERS.equals(strRelationshipName))
						{
						    // For linked folders we need to have "(Linked) suffix"
						    // How to do that? Due to technical difficulty it is pending.
%>
                            contentFrame.addStructureTreeNode (strChildId, strParentId, strTreeId, strSuiteDirectory, false);
                            updateFolderNodeNames = true;
<%
						}
%>
					}
<%
				}// for folders
			}
			else
			{
			    if ( !("copyContent".equals (menuAction) || "moveContent".equals (menuAction)) )
			    {
				    // When parent of the folder is not workspace (root ofthe tree), it is easy to refresh the contents by just reloading this parent
				    // folder node. There are various cases how to refresh. If the node is expanded or not, if it has children or not etc things are considered.
%>					
					if (objParentNode != null)
					{
					if ( !objParentNode.expanded )
					{
						if (objParentNode.childNodes.length != 0)
						{
							reloadSubtree (objParentNode);
						}
						else
						{
							var objParentParentNode = objParentNode.getParent();
							if (objParentParentNode == objStructureTree.root)
							{
								reloadSubtree (objParentNode);
							}
							else
							{
								reloadSubtree (objParentParentNode);
							}
						}
					}
					else
					{
						if (objParentNode.childNodes.length != 0)
						{
							reloadSubtree (objParentNode);
						}
						else
						{
							var objParentParentNode = objParentNode.getParent();
							if (objParentParentNode == objStructureTree.root)
							{
								reloadSubtree (objParentNode);
							}
							else
							{
								reloadSubtree (objParentParentNode);
							}
						}
					}
					}//if (objParentNode != null)
<%
			    }
			}//else

			//
			// Once the contens are changed in any folder we have to update the entire hierarchy labels above.
			//
			if ( "copyContent".equals (menuAction) || "moveContent".equals (menuAction))
			{
%>
				updateFolderNodeNames = true;
				var objTempNode = null;
<%
				// If the contents are moved then only refresh the source folder
				if ("moveContent".equals (menuAction))
				{
%>
					objTempNode = objStructureTree.findNodeByObjectID ("<%=strFromFolderId%>");
				if (objTempNode)
				{
					var objTempParentNode = objTempNode.getParent();
					while (objTempParentNode && (objTempParentNode != objStructureTree.root))
					{
							reloadSubtree (objTempParentNode);
							objTempParentNode = objTempParentNode.getParent();
					}
				}
<%
				}
%>
				objTempNode = objStructureTree.findNodeByObjectID ("<%=strToFolderId%>");
				if (objTempNode)
				{
					var objTempParentNode = objTempNode.getParent();
					while (objTempParentNode && (objTempParentNode != objStructureTree.root))
					{
							reloadSubtree (objTempParentNode);
							objTempParentNode = objTempParentNode.getParent();
					}
				}
<%
			}
%>
			if (updateFolderNodeNames)
			{
				var objNodeToRename = null;
<%
				for (Iterator itrFolders = mlFoldersInfo.iterator(); itrFolders.hasNext();)
				{
				    Map mapFolderInfo = (Map)itrFolders.next();
				    strFolderId = (String)mapFolderInfo.get(DomainObject.SELECT_ID);
				    String strRelId = (String)mapFolderInfo.get(DomainRelationship.SELECT_ID);
				    String strNewLabel = UITreeUtil.getUpdatedTreeLabel (application,
																				session,request,
																				context,
																				strFolderId,
																				strRelId,
																				strSuiteDirectory,
																				strLanguage);
%>
					objNodeToRename = objStructureTree.findNodeByObjectID ("<%=strFolderId%>");
					if (objNodeToRename)
					{
						objNodeToRename.changeObjectName("<%=strNewLabel%>", false);
					}
<%
				}//for each folder
%>
			}
			
			objStructureTree.doNavigate = false;
			objStructureTree.refresh();
			
		}
		catch (exp)
		{
			alert("Could not update the structure tree. " + exp.description);
		}
		finally
		{
			getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
			getTopWindow().closeWindow();
		}
	}// updateStructureTree()
		
	//updateStructureTree();
	//getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	
	//getTopWindow().closeWindow();
	-->
</script>


 

<script language="javascript">	
	var frame = null;
        if ( getTopWindow().getWindowOpener() )
            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeTOCContent");
        else
            frame = findFrame(getTopWindow(),"smaHomeTOCContent");
    
        if ( frame != null )
        {
    		sbExpandItems('<%=lineageOids%>', frame , true, true, 0, null, function(){getTopWindow().open('smaClose.jsp', '_self');});        
        }       	
</script>

<%
	//---------------------------Structure Tree Reload-------------------------------------

	}
	catch(Exception ex)
	{
		ex.printStackTrace();
%>
        <%@include file = "../components/emxMQLNotice.inc" %>
<%
        session.putValue("error.message",ex.getMessage());
		System.out.println("ERROR.MESSAGE" + ex.getMessage());
%>
<html>
<body>
<script language="javascript">
	//getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	//getTopWindow().closeWindow();
</script>
</body>
</html>
<%
	}
%>
