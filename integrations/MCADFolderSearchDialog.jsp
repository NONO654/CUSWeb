<%--  MCADFolderSearchDialog.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@include file ="../iefdesigncenter/DSCAppletUtils.inc"%>

<%@ page import = "com.matrixone.apps.common.*, com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*, matrix.util.*, com.matrixone.MCADIntegration.server.beans.*"%>

<html>


<script language="javascript">//<![CDATA[
<!-- hide JavaScript from non-JavaScript browsers

var projectIcon = parent.PROJECT_SMALL_ICONS;
var folderIcon	= parent.FOLDER_SMALL_ICONS;
var workspaceIcon = parent.WORKSPACE_SMALL_ICONS;
var projectHeadingIcon = parent.PROJECT_HEADING_SMALL_ICON;
var imgSpacer = parent.IMG_SPACER;

function loadTree()
{
	var tree = parent.tree;
	//set the current frame to the display frame
	tree.displayFrame = self.name;
	//we want radio buttons
	tree.multiSelect = false;

<%! 
	private void addChildrenToPageForWorkspaces(Context context, String parentId, IEFSimpleObjectExpander simpleObjectExpander, JspWriter out, String callPage) throws Exception
	{
		MapList childVaultNameIdMap			= new MapList();

		HashMap childVaultRelIdBusIdMap = simpleObjectExpander.getRelidChildBusIdList(parentId);

		if(childVaultRelIdBusIdMap != null)
		{
			Iterator childRelidIterator = childVaultRelIdBusIdMap.keySet().iterator();
			
			while (childRelidIterator.hasNext())
			{
				HashMap vaultNameIdMap = new HashMap();
				String childRelId = (String) childRelidIterator.next();
				String childBusId = (String) childVaultRelIdBusIdMap.get(childRelId);
				
				BusinessObjectWithSelect businessObjectWithSelect = simpleObjectExpander.getBusinessObjectWithSelect(childBusId);

				String childName = businessObjectWithSelect.getSelectData(DomainObject.SELECT_NAME);

				vaultNameIdMap.put("id", childBusId);
				vaultNameIdMap.put("name", childName);
				childVaultNameIdMap.add(vaultNameIdMap);
			}
			childVaultNameIdMap.sort("name", "ascending", "String");

		}
		
		for(int i=0; i<childVaultNameIdMap.size(); i++)
		{
			HashMap vaultNameIdMap		= (HashMap) childVaultNameIdMap.get(i);
			String vaultName 			= (String)vaultNameIdMap.get("name");
			String vaultId	 			= (String)vaultNameIdMap.get("id");

		//	DomainObject domainObject = DomainObject.newInstance(context, vaultId);
		//	Access contextAccess	  = domainObject.getAccessMask(context);

			out.write("tree.nodes[\"" + parentId + "\"].addChild(\"" + vaultName + "\",folderIcon, false, \"" + vaultId + "\",\"radio\",\"" + vaultId + "\");\n");
			
			boolean toConnectAccess = true;

		/*	if (callPage != null && callPage.equals("Search"))
			   toConnectAccess = AccessUtil.hasReadAccess(contextAccess);
			else
			   toConnectAccess = AccessUtil.hasAddAccess(contextAccess);

			if (!toConnectAccess)
			{*/
				out.write("obj = tree.nodes[\"" + vaultId + "\"];\n");
				out.write("if(obj){obj.selectable = true;\n}");
			//}

			addChildrenToPageForWorkspaces(context, vaultId, simpleObjectExpander, out, callPage);
		}
	}

	private void addChildrenToPageForProject(Context context, String parentId, IEFSimpleObjectExpander simpleObjectExpander, JspWriter out) throws Exception
	{
		MapList childVaultNameIdMap		= new MapList();
		HashMap childVaultRelIdBusIdMap = simpleObjectExpander.getRelidChildBusIdList(parentId);

		if(childVaultRelIdBusIdMap != null)
		{
			Iterator childRelidIterator = childVaultRelIdBusIdMap.keySet().iterator();
			
			while (childRelidIterator.hasNext())
			{
				HashMap vaultNameIdMap = new HashMap(); 
				
				String childRelId = (String) childRelidIterator.next();
				String childBusId = (String) childVaultRelIdBusIdMap.get(childRelId);
				
				BusinessObjectWithSelect businessObjectWithSelect = simpleObjectExpander.getBusinessObjectWithSelect(childBusId);
				String childName = businessObjectWithSelect.getSelectData(DomainObject.SELECT_NAME);

				vaultNameIdMap.put("id", childBusId);
				vaultNameIdMap.put("name", childName);
				
				childVaultNameIdMap.add(vaultNameIdMap);

			}
			childVaultNameIdMap.sort("name", "ascending", "String");

		}
		
		
		for(int i=0; i<childVaultNameIdMap.size(); i++)
		{
			HashMap vaultNameIdMap 	= (HashMap) childVaultNameIdMap.get(i);
			String vaultName 		= (String)vaultNameIdMap.get("name");
			String vaultId			= (String)vaultNameIdMap.get("id");

		//	BusinessObjectWithSelect businessObjectWithSelect = simpleObjectExpander.getBusinessObjectWithSelect(vaultId);

		//	String access = (String) businessObjectWithSelect.getSelectData("current.access[fromconnect]");

			out.write("var treeNode = tree.nodes[\"" + parentId + "\"];\n");

			out.write("if (treeNode == null || treeNode == \"undefined\")\n");
			out.write("treeNode = tree.nodes[\"p_" + parentId + "\"];\n");

			out.write("treeNode.addChild(\"" + vaultName + "\",folderIcon, false, \"p_" + vaultId + "\",\"radio\",\"" + vaultName + "\");\n");

                     //  if (access.equalsIgnoreCase("False"))
		//	{
				out.write("obj = tree.nodes[\"p_" + vaultId + "\"];\n");
				out.write("if(obj){obj.selectable = true;}\n");
		//	}

			addChildrenToPageForProject(context, vaultId, simpleObjectExpander, out);
		}
	}
%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	boolean isTransactionStarted = false;

	String notAssignedToProject = integSessionData.getStringResource("mcadIntegration.Common.NotAssignedToProject");
	String myWorkspaces			= integSessionData.getStringResource("mcadIntegration.Server.MyWorkspaces");
	String myProjects			= integSessionData.getStringResource("mcadIntegration.Server.MyProjects");
	String myCollections		= integSessionData.getStringResource("mcadIntegration.Server.MyCollections");
	Context context				= integSessionData.getClonedContext(session);
	String strShowCollection	= emxGetParameter(request,"showCollection");
	String selectWorkspace		= emxGetParameter(request,"selectWorkspace");
	String callPage				= emxGetParameter(request,"callPage");
	String strShowProject       = emxGetParameter(request, "showProject");
    
	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(),integSessionData.getGlobalCache());
	String RELATIONSHIP_LINKED_FOLDERS = util.getActualNameForAEFData(context,"relationship_LinkedFolders");
    
	try
	{
		if(!(context.isTransactionActive()))
		{
			context.start(false);
			isTransactionStarted = true;
		}
	}
	catch (Exception transactionEx)
	{
              System.out.println("Error in Transaction :" + transactionEx.getMessage());	
	}

	boolean bShowCollection = true;
	// Search dialog does not want to show the Collection
	if (null != strShowCollection && strShowCollection.equalsIgnoreCase("false"))
		bShowCollection = false;
	// if user does not install Program Central, bShowProject should be set to false
	boolean bShowProject = true;

	// Checks whether PMC is installed
	HashMap paramMap	= new HashMap();
	String[] init		= new String[] {};
	MapList appList		= (MapList)JPO.invoke(context, "DSC_CommonUtil", init, "getInstalledApplications", JPO.packArgs(paramMap), MapList.class);
	for (int i = 0;  i < appList.size(); i++)
	{
	   HashMap map = (HashMap)appList.get(i);
	   String name =  (String)map.get("name");
	   if (null != name && name.equals("ProgramCentral"))
		   bShowProject = true;
	}



	 if (null != strShowProject && strShowProject.equalsIgnoreCase("false"))
		bShowProject = false;

	DomainObject personObject = PersonUtil.getPersonObject(context);

	StringList relSelects	= new StringList();
	StringList objSelects	= new StringList();
	objSelects.addElement(DomainObject.SELECT_ID);
	objSelects.addElement(DomainObject.SELECT_NAME);

	// get a list of workspace id's for the member
	MapList wsMapList = new MapList();
 
	try
	{		
		com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);

		// where for the query, show workspaces in the "Active" state only, and the users(roles) must have read access on the workspace.
		String queryTypeWhere   = "('" + DomainObject.SELECT_CURRENT + "' == 'Active')";
		
		//get the vaults of the Person's company
		String personVault = person.getVaultName(context);

		//query selects
		StringList objectSelects = new StringList();
		objectSelects.add(DomainObject.SELECT_ID);
		objectSelects.add(DomainObject.SELECT_NAME);

		/*Query query = new Query();
		query.setBusinessObjectType(DomainConstants.TYPE_PROJECT);
		query.setVaultPattern(personVault);
		query.setWhereExpression(queryTypeWhere);*/

		//QueryIterator resultItr = query.getIterator(context, objectSelects, (short)100);

		
		try
		{
			/*while(resultItr.hasNext())
			{
				HashMap wsList = new HashMap();
				BusinessObjectWithSelect busWithSelect 	= resultItr.next();
				String workspaceId = busWithSelect.getSelectData(DomainObject.SELECT_ID);
				String workspaceName = busWithSelect.getSelectData(DomainObject.SELECT_NAME);
				wsList.put("id", workspaceId);
				wsList.put("name", workspaceName);
				wsMapList.add(wsList);
			}
			  wsMapList.sort("name", "ascending", "String");*/
			MapList wsList		= (MapList)JPO.invoke(context, "emxWorkspace", init, "getActiveMyDeskWorkspace", JPO.packArgs(paramMap), MapList.class);
			wsMapList = wsList;
			//System.out.println("--wsMapList-->"+wsMapList);
			//wsMapList.sort("name", "ascending", "String");
			/*for (int i = 0;  i < wsList.size(); i++)
			{
			   Map mapWS = (Map)wsList.get(i);
			   String workspaceId =  (String)mapWS.get(DomainObject.SELECT_ID);
				//workspaceIdList.add(workspaceId);
				wsMapList.add(mapWS);
		     }	
*/			 
		}
		finally
		{
			//resultItr.close();
		}
	}
	catch (Exception ex) 
	{
	   throw (new MatrixException("emxMsoiTMCUtil:getCurrentUserWorkspaces : " + ex.toString()) );
	}

	if (wsMapList == null)
	{
%>
                <!--XSSOK-->
		tree.createRoot("<%=notAssignedToProject%>", imgSpacer, "");
<%
	}
	else
	{
%>
		tree.createRoot("",imgSpacer , "");
		//XSSOK
		tree.root.addChild("<%=myWorkspaces%>",workspaceIcon, false, "<%=myWorkspaces%>","r","<%=myWorkspaces%>");
		//XSSOK
		var workspaceNode = tree.nodes["<%=myWorkspaces%>"];
        if (workspaceNode) workspaceNode.selectable = false; 
<%
	}

	StringList relSelectsForWorkspaceVault = new StringList();

	StringList busSelectsForWorkspaceVault = new StringList(5);
	busSelectsForWorkspaceVault.add(DomainObject.SELECT_NAME);
	busSelectsForWorkspaceVault.add(DomainObject.SELECT_ID);
	
	Hashtable relsAndEnds = new Hashtable();
	relsAndEnds.put(DomainObject.RELATIONSHIP_WORKSPACE_VAULTS, "to");
	relsAndEnds.put(DomainObject.RELATIONSHIP_SUBVAULTS, "to");
        relsAndEnds.put(RELATIONSHIP_LINKED_FOLDERS,"to");

   	String [] wsIds = new String[wsMapList.size()];

	for ( int i=0; i<wsMapList.size(); i++)
	{
		Map idMap =(Map) wsMapList.get(i);
		wsIds[i] = (String)idMap.get("id");
	}
	
	IEFSimpleObjectExpander simpleObjectExpander = new IEFSimpleObjectExpander(wsIds, relsAndEnds, busSelectsForWorkspaceVault, relSelectsForWorkspaceVault, (short)0);
	simpleObjectExpander.expandInputObjects(context);

	for(int i=0; i < wsIds.length; i++)
	{
		String worksSpaceId = wsIds[i];
		BusinessObjectWithSelect busWithSelect = simpleObjectExpander.getBusinessObjectWithSelect(worksSpaceId);

		String projectId	= busWithSelect.getSelectData(DomainObject.SELECT_ID);
		String projectName  = busWithSelect.getSelectData(DomainObject.SELECT_NAME);
%>
                //XSSOK
		var workspaceNode = tree.nodes["<%=myWorkspaces%>"];
		//XSSOK
		workspaceNode.addChild("<%=projectName%>", workspaceIcon, false, "<%=projectId%>","r","<%=projectName%>_rw");
		if (workspaceNode) workspaceNode.selectable = false; 
		   //XSSOK
		var tempObj = tree.nodes['<%=projectId%>'];
		if (tempObj)
		{
			if("false" == "<%=XSSUtil.encodeForJavaScript(context,selectWorkspace)%>")
				tempObj.selectable = false;
			else
				tempObj.selectable = true;
		}
<%
		try
		{
			addChildrenToPageForWorkspaces(context, projectId, simpleObjectExpander, out, callPage);
		}
		catch(Exception e) 
		{
%>
                        //XSSOK
			tree.createRoot("<%=notAssignedToProject%>", "images/blank.gif", "none");
<%
		}
	}

	if (bShowProject)
	{ 
		String pjRelPattern		= PropertyUtil.getSchemaProperty(context, "relationship_Member");
		String pjTypePattern	= PropertyUtil.getSchemaProperty(context, "type_ProjectSpace");

		String [] inputids = new String[1];

		inputids[0] = personObject.getObjectId(context);

		Hashtable projectRelsAndEnd = new Hashtable();

		projectRelsAndEnd.put(pjRelPattern, "from");

		String SELECT_IS_PROJECT_SPACE = "type.kindof[" + pjTypePattern + "]";

		objSelects.add(SELECT_IS_PROJECT_SPACE);
		
		IEFSimpleObjectExpander personObjectExpander = new IEFSimpleObjectExpander(inputids, projectRelsAndEnd, objSelects, relSelects, (short)1);
		personObjectExpander.expandInputObjects(context);

		HashMap projectRelIdBusIdMap = personObjectExpander.getRelidChildBusIdList(inputids[0]);

		MapList projectspaceIdNameMap = new MapList();
		if(projectRelIdBusIdMap != null)
		{
			Iterator childRelidIterator = projectRelIdBusIdMap.keySet().iterator();
			
			while (childRelidIterator.hasNext())
			{
				HashMap idMap = new HashMap();
				String childRelId = (String) childRelidIterator.next();
				String childBusId = (String) projectRelIdBusIdMap.get(childRelId);

				BusinessObjectWithSelect businessObjectWithSelect = personObjectExpander.getBusinessObjectWithSelect(childBusId);

				String isProjectTypeSpace = businessObjectWithSelect.getSelectData(SELECT_IS_PROJECT_SPACE);
				String projectName		  = businessObjectWithSelect.getSelectData(DomainObject.SELECT_NAME);
				
				if(isProjectTypeSpace != null && isProjectTypeSpace.equalsIgnoreCase("true"))
				{
					idMap.put("id",childBusId);
					idMap.put("name",projectName);
					projectspaceIdNameMap.add(idMap);
				}
			}
			projectspaceIdNameMap.sort("name", "ascending", "String");
		}

		if (projectspaceIdNameMap == null)
		{
%>
                        //XSSOK
			tree.createRoot("<%=notAssignedToProject%>", projectIcon, "");
<%
		}
		else
		{
%>
                        //XSSOK
			tree.root.addChild("<%=myProjects%>", projectHeadingIcon, false, "<%=myProjects%>","r","<%=myProjects%>");
			//XSSOK
			var projectNode = tree.nodes["<%=myProjects%>"];
			projectNode.selectable = false;
<%
		}

		String [] projectIds = new String[projectspaceIdNameMap.size()];

		for ( int i=0; i<projectspaceIdNameMap.size(); i++)
		{
			Map idMap =(Map) projectspaceIdNameMap.get(i);
			projectIds[i] = (String)idMap.get("id");
		}

		StringList busSelects = new StringList(5);
		busSelects.add(DomainObject.SELECT_NAME);
		busSelects.add(DomainObject.SELECT_ID);
		busSelects.add(DomainObject.SELECT_TYPE);
	//	busSelects.add("current.access[fromconnect]");

		Hashtable subProjectRelsAndEnd = new Hashtable();
		subProjectRelsAndEnd.put(DomainObject.RELATIONSHIP_WORKSPACE_VAULTS, "to");
		subProjectRelsAndEnd.put(DomainObject.RELATIONSHIP_SUB_VAULTS, "to");

		IEFSimpleObjectExpander projectObjectExpander = new IEFSimpleObjectExpander(projectIds, subProjectRelsAndEnd, busSelects, relSelects, (short)0);
		projectObjectExpander.expandInputObjects(context);

		for( int i=0; i<projectspaceIdNameMap.size(); i++)
		{
			
			Map idMap 			=(Map) projectspaceIdNameMap.get(i);
			String projectId 	= (String)idMap.get("id");
			String projectName 	= (String)idMap.get("name");

			try
			{
		
%>
                                //XSSOK
				var tempNode = tree.nodes["<%=myProjects%>"];
				//XSSOK
				tempNode.addChild("<%=projectName%>",projectIcon, false, "<%=projectId%>","r","<%=projectName%>");
                //XSSOK
				var tempObj = tree.nodes['<%=projectId%>'];
				if (tempObj) tempObj.selectable = false;
<%
				addChildrenToPageForProject(context, projectId, projectObjectExpander, out);
				
			}
			catch (Exception e)
			{
%>
                                //XSSOK
				tree.createRoot("<%=notAssignedToProject%>", "images/blank.gif", "none");
<%
			}
		} // for projectMapList
      } // if bShowProject

        if (bShowCollection) 
		{
%>
                        //XSSOK
			tree.root.addChild("<%=myCollections%>", projectIcon, false, "<%=myCollections%>","r","<%=myCollections%>");
			//XSSOK
			var collectionNode = tree.nodes["<%=myCollections%>"];  
			if (collectionNode) collectionNode.selectable = false;     
<%
			try
			{
				MapList collectionMapList = null;
				collectionMapList = SetUtil.getCollections(context);
				for (int i = 0; i < collectionMapList.size(); i++)
				{
					Map collectionMap = (Map)collectionMapList.get(i);
					String collectionName  = (String)collectionMap.get("name");
				   
					String collectionCount = (String)collectionMap.get("count");
                
%>
                                        //XSSOK
					var collectionNode = tree.nodes["<%=myCollections%>"];
					//XSSOK
					collectionNode.addChild("<%=collectionName%>", projectIcon, false, "c_<%=collectionName%>","r","<%=collectionName%>");
               
<%               
				}
			}
			catch (Exception e)
			{
			}
		} // bShowCollection

		//If transaction has been started commit it.
    	if(isTransactionStarted)
    		context.commit();
 %>
	tree.draw();
}
// Stop hiding here -->//]]>

</script>

</head>

<body onLoad="loadTree()" />
  
</html>

