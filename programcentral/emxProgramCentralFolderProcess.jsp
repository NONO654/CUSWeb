<%-- emxProgramCentralFolderProcess.jsp

  Performs an action on a vault (add, edit, remove)

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

    static const char RCSID[] = "$Id: emxProgramCentralFolderProcess.jsp.rca 1.45.2.1 Wed Dec 24 10:59:13 2008 ds-ksuryawanshi Experimental $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
  ProjectSpace project = (ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
  com.matrixone.apps.common.WorkspaceVault parentWorkspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

  //Setting schema variables
  String workspaceVaultType   = PropertyUtil.getSchemaProperty(context,"type_ProjectVault");
  String workspaceVaultPolicy = workspaceVault.POLICY_WORKSPACE_VAULT;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Get parameters from URL
  String strLanguage = request.getHeader("Accept-Language");
  String action         = emxGetParameter(request, "action");
  String parentObjectId = null;
  String objectId = null;
  if ("getLatestRev".equals(action))
  {
    parentObjectId    = emxGetParameter(request,"parentOID");  //Id of the parent (can be of type workspaceVault, Project, and ProjectTemplate)
    objectId=(String) emxGetParameter(request, "objectId");
    DomainObject domParentObj = DomainObject.newInstance(context,parentObjectId);
    DomainObject domObjectId = DomainObject.newInstance(context,objectId);
    String isMinorrevisionable = (String)domObjectId.getInfo(context, "current.minorrevisionable");
    DomainObject dmoLatestRevision = new DomainObject();
    String sLatestRevId = "";
    if("true".equalsIgnoreCase(isMinorrevisionable)){
    BusinessObject boLatestRevision = domObjectId.getLastRevision(context);
    dmoLatestRevision = new DomainObject(boLatestRevision);
    sLatestRevId = dmoLatestRevision.getId(context);
    }else{
    	//Major Revisionable
    	String strLastId = domObjectId.getInfo(context,"majorid.lastmajorid.bestsofar.id");
    	dmoLatestRevision = DomainObject.newInstance(context, strLastId);
    sLatestRevId = dmoLatestRevision.getId(context);
    }

    RelationshipType rel = new RelationshipType(DomainConstants.RELATIONSHIP_VAULTED_OBJECTS_REV2);
    DomainRelationship rela = DomainRelationship.connect(context, domParentObj, rel, dmoLatestRevision);
    String strRelId = rela.getName();
        String xmlMessage = "<mxRoot>" + "<action><![CDATA[add]]></action>" +
        "<data status=\"committed\" fromRMB=\"" + "true" + "\"" + " >" +
        "<item oid=\"" + sLatestRevId + "\" relId=\"" + strRelId + "\" pid=\"" + parentObjectId +
        "\" direction=\"\" pasteBelowToRow=\"" + "" + "\" />" + "</data></mxRoot>";
    %>
        <script type="text/javascript" language="JavaScript">
        var topFrame = findFrame(getTopWindow(),"detailsDisplay");
		if (typeof topFrame.emxEditableTable == 'undefined'){
             	topFrame=this.parent;
        }
        topFrame.refreshStructureWithOutSort();
        topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
        topFrame.refreshStructureWithOutSort();
        </script>
    <%
    return;
  }
  if ("delete".equals(action))
  {
    parentObjectId    = emxGetParameter(request,"parentOID");  //Id of the parent (can be of type workspaceVault, Project, and ProjectTemplate)
    if(null == parentObjectId)
    {
    	parentObjectId=(String) emxGetParameter(request, "objectId");
    }
  }
  else
  {
   parentObjectId = emxGetParameter(request, "parentObjectId");  //Id of the parent (can be of type workspaceVault, Project, and ProjectTemplate)
  }
  String folderId       = emxGetParameter(request, "folderId");  //Id of folder that is being edited or cloned
  String[] folders = emxGetParameterValues(request,"emxTableRowId"); //Get folderIds from url that need to be deleted

  //Added PRG:RG6:R212:5-May-2011: root node can not be deleted check
  String sTableRowId = emxGetParameter(request, "emxTableRowId");
  Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTableRowId);
  String srowId = "";
  if(null != mParsedObject)
  {
     srowId = (String)mParsedObject.get("rowId");
     if("0".equalsIgnoreCase(srowId) && "delete".equalsIgnoreCase(action))  // root folder can not be deleted
     {
         String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral",
   			  "emxProgramCentral.Folders.Delete.RootFolder", strLanguage);
  %>
        <script language="JavaScript" type="text/javascript">
                                         alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                         getTopWindow().closeSlideInDialog();
        </script>
  <%      return;
     }
  }
//End Added PRG:RG6:R212:5-May-2011: root node can not be deleted check

  int numFolders = folders.length;

  for (int i=0; i<numFolders; i++)
  {
    //StringList slResourceTokens = FrameworkUtil.split(folders[i], "|");
    //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
    String[] ResourceTokensArr = folders[i].split("\\|");
    StringList slResourceTokens = new StringList();
    for(int j=0;j<ResourceTokensArr.length;slResourceTokens.add(ResourceTokensArr[j++]));
  //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
    int intSlResourceTokensSize = slResourceTokens.size();
    if(intSlResourceTokensSize==3)
    {
	    String strFolderId= (String)slResourceTokens.get(0);
	    DomainObject domFolderObj = DomainObject.newInstance(context,strFolderId);

	    String strParentId= (String)slResourceTokens.get(1);
        DomainObject domParentObj = DomainObject.newInstance(context,strParentId);

        MapList mlRelList = new MapList();

        String SELECT_IS_PROJECT_SPACE = "type.kindof["+DomainConstants.TYPE_PROJECT_SPACE+"]";
        String SELECT_IS_WORKSPACE_VAULT = "type.kindof["+DomainConstants.TYPE_WORKSPACE_VAULT+"]";
        StringList slSelects = new StringList();
        slSelects.add(DomainConstants.SELECT_ID);
        slSelects.add(SELECT_IS_PROJECT_SPACE);
        slSelects.add(SELECT_IS_WORKSPACE_VAULT);

        Map mapInfo = domParentObj.getInfo(context,slSelects);
        String sIsProjectSpaceType = (String) mapInfo.get(SELECT_IS_PROJECT_SPACE);
        String sIsWorkspaceVaultType = (String) mapInfo.get(SELECT_IS_WORKSPACE_VAULT);

        if(null != sIsProjectSpaceType && "TRUE".equalsIgnoreCase(sIsProjectSpaceType.trim()))
        {
        	StringList relList = new StringList();
            relList.add(DomainConstants.SELECT_RELATIONSHIP_ID);
            mlRelList  =domFolderObj.getRelatedObjects(context,
            		            "Data Vaults",
                                DomainConstants.TYPE_PROJECT_SPACE,
                                null,
                                relList,       // relationshipSelects
                                true,         // getTo
                                false,       // getFrom
                                (short) 0,  // recurseToLevel Max
                                null,      // objectWhere
                                null,
                                0);
        }
        else if(null != sIsWorkspaceVaultType && "TRUE".equalsIgnoreCase(sIsWorkspaceVaultType.trim()))
        {
		    StringList relList = new StringList();
	        relList.add(DomainConstants.SELECT_RELATIONSHIP_ID);
	        mlRelList  =domFolderObj.getRelatedObjects(context,
	                            DomainConstants.RELATIONSHIP_SUB_VAULTS,
	                            DomainConstants.TYPE_WORKSPACE_VAULT,
	                            null,
	                            relList,       // relationshipSelects
	                            true,         // getTo
	                            false,       // getFrom
	                            (short) 0,  // recurseToLevel Max
	                            null,      // objectWhere
	                            null,
	                            0);
        }
        if (mlRelList.size() > 0)
        {
            Iterator itr = mlRelList.iterator();
            while (itr.hasNext())
            {
                Map map = (Map)itr.next();
                String strBookmarkRelId = (String) map.get(DomainConstants.SELECT_RELATIONSHIP_ID);
                folders[i] = strBookmarkRelId + folders[i];
            }
        }
    }
  }

  String formKey        = emxGetParameter(request, "formKey");
  String jsTreeId       = emxGetParameter(request, "jsTreeId");
  boolean isFolderFrozen = false;
  boolean hasContent    = false;
  boolean hasSubVault   = false;
  String strFolderCannotDeleteList="";
  ArrayList folderDeleteList = new ArrayList();
  StringList slTreeNodeDeleteList = new StringList(); //PRG:RG6:R212:30-7-2011:IR-122871V6R2012x:Folder Structure Navigator Delete
  String jsTreeIdValue = null;
  if (jsTreeId!=null && !jsTreeId.equals("null")){
    jsTreeIdValue = jsTreeId;
  }
  if (jsTreeId == null) {
   jsTreeId = "";
  }

  //parentId should always be sent in
  project.setId(parentObjectId);
  String parentObjectType = project.getInfo(context, project.SELECT_TYPE);

  //start action processes
  try {
    // start a write transaction and lock business object
    workspaceVault.startTransaction(context, true);

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //Add, clone, and edit Process
    if (action.equals("add") || action.equals("edit") || action.equals("clone")) {

      //Gather all attribute values that need to be updated
      String folderName        = emxGetParameter(request, "FolderName");
      folderName               = folderName.trim();
      String folderDescription = emxGetParameter(request, "FolderDescription");
      String security          = emxGetParameter(request, "Security");
      String accessType        = emxGetParameter(request, "AccessType");

      //Add folder attributes to attributeMap
      HashMap attributeMap = new HashMap(4);
      attributeMap.put(workspaceVault.ATTRIBUTE_GLOBAL_READ, security);
      attributeMap.put(workspaceVault.ATTRIBUTE_ACCESS_TYPE, accessType);

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //Create new folder in database
      if ("add".equals(action)) {
        //If the object creating the new workspaceVault is not a workspaceVault
        if (! parentObjectType.equals(workspaceVaultType)) {
          workspaceVault.create(context,                //context
                                workspaceVaultType,     //Type
                                folderName,             //Folder name
                                workspaceVaultPolicy,   //Policy
                                project,                //Parent Object
                                (Map) attributeMap,     //attributes
                                folderDescription);     //description

          //get all members from the parent
          i18nNow i18nnow      = new i18nNow();
          HashMap accessMap    = new HashMap();
          String inheritedType = EnoviaResourceBundle.getProperty(context, "Framework",
    			  "emxFramework.Range.Access_Type.Inherited", strLanguage);
          String readAccess    = EnoviaResourceBundle.getProperty(context, "Framework",
    			  "emxFramework.Range.Project_Member_Access.Read", strLanguage);
          if(inheritedType.equalsIgnoreCase(accessType) && "True".equalsIgnoreCase(security)){
             ProjectSpace ps = (ProjectSpace)DomainObject.newInstance(context, parentObjectType, DomainConstants.PROGRAM);
             ps.setId(parentObjectId);
       StringList busSels = new StringList();
       busSels.add(ps.SELECT_NAME);
	   // Changed MapList ml = ps.getMembers(context,busSels,null,"","",); to MapList ml = ps.getMembers(context,busSels,null,"","",True); for Bug No 307539
      // MapList ml = ps.getMembers(context,busSels,null,"","",);
	   MapList ml = ps.getMembers(context,busSels,null,"","",true);
       if(ml != null){
         for(int i=0; i < ml.size(); i++){
            Map map = (Map)ml.get(i);
            String member = (String)map.get(ps.SELECT_NAME);
            if(!member.equals(context.getUser())){
               accessMap.put(member, readAccess);
            }
         }

         //set permissions on this new created WorkspaceVault object
               workspaceVault.setUserPermissions(context, accessMap);
             }
          }

        } else {
          //Object creating workspaceVault is a workspaceVault
          //therefore, new workspaceVault is a subFolder
          workspaceVault.setId(parentObjectId);
          //create subVault for parent vault
          workspaceVault = workspaceVault.createSubVault(
                                  context,               //conext
                                  folderName,            //Folder name
                                  workspaceVaultPolicy,  //Policy
                                  attributeMap,          //attributes
                                  folderDescription);    //description
        } //end if creating a subvault
      } //end add process

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //Clone Process
      if ("clone".equals(action)) {
        workspaceVault.setId(folderId);
        workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
        //If the object creating the new workspaceVault is not a workspaceVault
        if (! parentObjectType.equals(workspaceVaultType)) {
          workspaceVault = workspaceVault.clone(context,       //context
                                                folderName,    //Folder name
                                                project);      //Parent
        } else {
          //Object cloning workspaceVault is a workspaceVault
          //therefore, new workspaceVault is a subFolder
          parentWorkspaceVault.setId(parentObjectId);
          //create subVault for parent vault
          workspaceVault = workspaceVault.clone(context, folderName, parentWorkspaceVault);
        }
        //set all other attributes
        workspaceVault.setDescription(context, folderDescription);
        workspaceVault.setAttributeValues(context, attributeMap);
      } //end Clone process

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      //Edit process
      if (action.equals("edit")) {
        workspaceVault.setId(folderId);
        workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
        //set new name
        workspaceVault.setName(context, folderName);
        //set new description
        workspaceVault.setDescription(context, folderDescription);
        workspaceVault.setAttributeValues(context, attributeMap);
      } //end edit process
    } //end add, clone, edit process

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //Delete Process
    if ("delete".equals(action))
    {
      if ( folders != null )
      {
          //Finding all the sub Types of Controlled Folder
          String strMQL = "print type \"" + DomainConstants.TYPE_CONTROLLED_FOLDER +"\" select derivative dump |"; //PRG:RG6:R213:Mql Injection:Static Mql:14-Oct-2011
          String strResult = MqlUtil.mqlCommand(context, strMQL, true);
          StringList slControlledFolderTypeHierarchy = FrameworkUtil.split(strResult, "|");

          // Dont forget to add Controlled Folder type itself into this listing
          slControlledFolderTypeHierarchy.add(DomainConstants.TYPE_CONTROLLED_FOLDER);


        // get the number of folder to delete
        String strErrorMsg = "";
        final String SELECT_ATTRIBUTE_FOLDER_TITLE = "attribute[" + DomainConstants.ATTRIBUTE_TITLE + "]";
        StringList slFolderCannotDeleteList= new StringList();
        StringList slResourceTokens = new StringList();

        String rowId = "";
        String partialXML = "";
        for (int i=0; i<numFolders; i++)
        {
        	//Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
             slResourceTokens.clear();//Modified:RG6:PRG:R212:10-May-2011
        	//Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
        	String[] ResourceTokensArr = folders[i].split("\\|");
        	for(int j=0;j<ResourceTokensArr.length;slResourceTokens.add(ResourceTokensArr[j++]));
            //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start

          //workspaceVault.setId(folders[i]);
          String strFolderId= (String)slResourceTokens.get(1);
          String strparentObjId= (String)slResourceTokens.get(2);
          String strRelId= (String)slResourceTokens.get(0);
          DomainObject domainObject= DomainObject.newInstance(context,strFolderId);

          workspaceVault.setId((String)slResourceTokens.get(1));
		  //Added:22-Dec-08:nzf:R207:PRG Controlled Folder
          //Determine if folder has subFolders or content
          //Added:25-Nov-10:vf2:R211:IR-080889
          final String SELECT_LINK_URLS ="from[Link URL].to.id";
		  boolean isBookMark = false;
		  //End:25-Nov-10:vf2:R211:IR-080889
          StringList busSelects = new StringList();
          busSelects.add(workspaceVault.SELECT_CONTENT_ID2);
          busSelects.add(workspaceVault.SELECT_HAS_SUB_VAULTS);
          busSelects.add(SELECT_LINK_URLS);
          busSelects.add(workspaceVault.SELECT_TYPE);
          busSelects.add(workspaceVault.SELECT_CURRENT);
          busSelects.add(DomainConstants.SELECT_NAME);
          busSelects.add(SELECT_ATTRIBUTE_FOLDER_TITLE);

          Map folderMap = workspaceVault.getInfo(context, busSelects);
          //End:R207:PRG Controlled Folder
          //If the folder has subvaults or content, do not delete it
          boolean hasContent2  = false;
          boolean hasSubVault2 = false;
          if ("True".equalsIgnoreCase((String) folderMap.get(workspaceVault.SELECT_HAS_SUB_VAULTS)))
          {
              hasSubVault  = true;
              hasSubVault2 = true;
              if(slControlledFolderTypeHierarchy.contains((String) folderMap.get(workspaceVault.SELECT_TYPE)))
              {
                  if(!slFolderCannotDeleteList.contains((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE)))
                  {
                      slFolderCannotDeleteList.add((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE));
                  }
              }
              else
              {
				  if(!slFolderCannotDeleteList.contains((String) folderMap.get(DomainConstants.SELECT_NAME)))
				  {
				      slFolderCannotDeleteList.add((String) folderMap.get(DomainConstants.SELECT_NAME));
                  }

              }
          }
          if (null != folderMap.get(workspaceVault.SELECT_CONTENT_ID2))
          {
            hasContent  = true;
            hasContent2 = true;

            if(slControlledFolderTypeHierarchy.contains((String)folderMap.get(workspaceVault.SELECT_TYPE)))
            {
                if(!slFolderCannotDeleteList.contains((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE)))
                {
                    slFolderCannotDeleteList.add((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE));
                }
            }
            else
            {
				  if(!slFolderCannotDeleteList.contains((String) folderMap.get(DomainConstants.SELECT_NAME)))
				  {
				      slFolderCannotDeleteList.add((String) folderMap.get(DomainConstants.SELECT_NAME));
                }

            }

          }
          //Can delete folders which are in Create state
		  //Added:22-Dec-08:nzf:R207:PRG Controlled Folder

		  //Added:25-Nov-10:vf2:R211:IR-080889
          if (null != folderMap.get(SELECT_LINK_URLS))
          {
        	  hasContent = true;
        	  isBookMark = true;
            if(slControlledFolderTypeHierarchy.contains((String)folderMap.get(workspaceVault.SELECT_TYPE)))
            {
                if(!slFolderCannotDeleteList.contains((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE)))
                {
                    slFolderCannotDeleteList.add((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE));
                }
            }
            else
            {
                  if(!slFolderCannotDeleteList.contains((String) folderMap.get(DomainConstants.SELECT_NAME)))
                  {
                      slFolderCannotDeleteList.add((String) folderMap.get(DomainConstants.SELECT_NAME));
                }
            }
          }
          //End:22-Nov-10:vf2:R211:IR-080889
          if(slControlledFolderTypeHierarchy.contains((String)folderMap.get(workspaceVault.SELECT_TYPE)) && !DomainConstants.STATE_CONTROLLED_FOLDER_CREATE.equals((String) folderMap.get(workspaceVault.SELECT_CURRENT)))
          {
              isFolderFrozen = true;
              if(slControlledFolderTypeHierarchy.contains((String)folderMap.get(workspaceVault.SELECT_TYPE)))
              {
                  if(!slFolderCannotDeleteList.contains((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE)))
                  {
                      slFolderCannotDeleteList.add((String) folderMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE));
                  }
              }
              else
              {
				  if(!slFolderCannotDeleteList.contains((String) folderMap.get(DomainConstants.SELECT_NAME)))
				  {
				      slFolderCannotDeleteList.add((String) folderMap.get(DomainConstants.SELECT_NAME));
                  }

              }
          }
		  //End:R207:PRG Controlled Folder
          //Can also delete folder if it does not have subFolders and content
          //Added:25-Nov-10:vf2:R211:IR-080889
          if (!hasSubVault2 && !hasContent2 && !isFolderFrozen && !isBookMark)
          //End:25-Nov-10:vf2:R211:IR-080889
          {
        	  //Added By rg6 : 2011x.HF1
                  // below code is added to allow the project users(members) without project lead access
        	//in the project be able to disconnect and delete the root level folders in project

              parentWorkspaceVault.setId(strparentObjId);
             if(parentWorkspaceVault.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE)){
    					//Changes for delete folde access by : I9Q
    					boolean isTopushContext = false;
    					boolean hasDeleteAccess = parentWorkspaceVault.checkAccess(context, (short) AccessConstants.cDelete);
    					boolean hasModifyAccess = parentWorkspaceVault.checkAccess(context, (short) AccessConstants.cModify);

    					if(hasDeleteAccess && hasModifyAccess){
    						isTopushContext =  true;
    					}

    					if(isTopushContext){
    						try {
    							ContextUtil.pushContext(context);
    							workspaceVault.deleteObject(context);
    							folderDeleteList.add(folders[i]);
    						}
    						finally {
    							ContextUtil.popContext(context);
    						}
    					}
    					else {
    						// add check for hasNoRemoveAccess  & hasNoRemoveAccessForParent in above if
    						workspaceVault.deleteObject(context);
    						folderDeleteList.add(folders[i]);
    					}

    					//[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::End]
    					rowId =  (String)slResourceTokens.lastElement();
    					partialXML += "<item id=\"" + rowId + "\" />";
    					//[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::End]
    					slTreeNodeDeleteList.add(slResourceTokens.get(1));  //PRG:RG6:R212:30-7-2011:IR-122871V6R2012x:Folder Structure Navigator Delete
    				}
    				else{
    					try{
    						// add check for hasNoRemoveAccess  & hasNoRemoveAccessForParent in above if
    						//DomainRelationship.disconnect(context,strRelId);
		            workspaceVault.deleteObject(context);
		             //workspaceVault.deleteObject(context);
		            folderDeleteList.add(folders[i]);
		            //[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::Start]
		            rowId =  (String)slResourceTokens.lastElement();
		            partialXML += "<item id=\"" + rowId + "\" />"; //XSSOK
		            //[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::End]
		            slTreeNodeDeleteList.add(slResourceTokens.get(1)); //PRG:RG6:R212:30-7-2011:IR-122871V6R2012x:Folder Structure Navigator Delete
                 }catch(Exception e){
         			String msg = e.getMessage();
        			if(msg.contains("No delete access")){
        	    		%>
        	    		<script type="text/javascript" language="JavaScript">
        	    		var error="<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ProjectContent.NoDeleteAccessToBookmark</emxUtil:i18nScript>";
        	    		alert(error);
        	    		</script>
        	    		<%
        			}
                     e.printStackTrace();
                     throw e;
                 }
             }
          }
        }//For
        for (int i=0; i<slFolderCannotDeleteList.size(); i++)
        {
            strFolderCannotDeleteList = strFolderCannotDeleteList+slFolderCannotDeleteList.get(i)+",";
        }
        //[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::Start]
        String xmlMessage = "<mxRoot>";
        String message = "";
        xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
        xmlMessage += partialXML;
        xmlMessage += "<message><![CDATA[" + message  + "]]></message>";
        xmlMessage += "</mxRoot>";

        %>
        <script type="text/javascript" language="JavaScript">
        window.parent.removedeletedRows('<%= xmlMessage %>');   <%-- XSSOK--%>
        //window.parent.closeWindow();
        </script>
        <%
        //[Added::Jan 18, 2011:MS9:2011x.HF2:HF-054191::End]
//PRG:RG6:R212:30-7-2011:IR-122871V6R2012x:Folder Structure Navigator Delete
           for(int k=0;k<slTreeNodeDeleteList.size();k++)
           {
        	   String sDeletedObjId = (String)slTreeNodeDeleteList.get(k);
        %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script type="text/javascript" language="JavaScript">

		         var contentFrame = findFrame(getTopWindow(), "content");
		         var fancyTree = getTopWindow().objStructureFancyTree;
		         if(fancyTree)
		         {
		        	   contentFrame.deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context,sDeletedObjId)%>",false);
		        	   contentFrame.refreshStructureTree();
		         }
        </script>
        <%
      //PRG:RG6:R212:30-7-2011:IR-122871V6R2012x:Folder Structure Navigator Delete
           }
      }
    } //end delete

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // commit the data
    ContextUtil.commitTransaction(context);
  }
  catch (Exception e) {
    ContextUtil.abortTransaction(context);
  }
%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%><script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" type="text/javaScript">//<![CDATA[

<%-- XSSOK--%>  var subDocs = "<%= hasContent %>";
<%-- XSSOK--%>  var subFolder = "<%= hasSubVault %>";
<%-- XSSOK--%>  var frozenFolder = "<%= isFolderFrozen %>";
<%-- XSSOK--%> var action = "<%= action %>";
  var err = "";
  var errBegin="<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.FoldersCannotBeDeleted</emxUtil:i18nScript>"+"\n";
  var canDelete = "true";

  if (subDocs == "true") {
  err=err+"<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.DocumentExists</emxUtil:i18nScript>"+"\n";
  canDelete = "false";
  }

  if (subFolder == "true") {
  err=err+"<emxUtil:i18nScript localize='i18nId'>emxProgramCentral.Common.SubFolderExists</emxUtil:i18nScript>"+"\n";
  canDelete = "false";
  }

  if (frozenFolder == "true") {
  err=err+"<emxUtil:i18nScript localize='i18nId'>emxProgramCentral.ControlledFolder.CannotDeleteFolder</emxUtil:i18nScript>"+"\n";
  canDelete = "false";
  }

  if(canDelete == "false"){
  alert(errBegin+"<%=XSSUtil.encodeForJavaScript(context,strFolderCannotDeleteList)%>"+"\n"+err);
  }

  if (action == "add" || action == "edit" || action == "clone") {
      //Might need to refresh name in tree for edit process
      var tree = parent.window.getWindowOpener().getTopWindow().objDetailsTree;
      var conTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
      if (action == "edit") {

          tree.getSelectedNode().changeObjectName("<%=XSSUtil.encodeForJavaScript(context,(String) emxGetParameter(request, "FolderName"))%>",false);
          var structNode = conTree.objects["<%=XSSUtil.encodeForJavaScript(context,(String)workspaceVault.getObjectId())%>"];
          if(structNode) {
              // Code modified for bug 319716
              structNode.nodes[0].changeObjectName("<%=XSSUtil.encodeForJavaScript(context,(String) emxGetParameter(request, "FolderName"))%>" , false);
          }
          //Update the name on the Structure Tree
          //var dispFrame = getTopWindow().findFrame(getTopWindow(),"emxUIStructureTree");
          var objStructFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "emxUIStructureTree");
          if(objStructFrame){
              var strucTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
              if(strucTree){
                  structNode = strucTree.objects["<%=XSSUtil.encodeForJavaScript(context,(String)workspaceVault.getObjectId())%>"];
                  if(structNode) {
                      structNode.nodes[0].changeObjectName("<%=XSSUtil.encodeForJavaScript(context,(String) emxGetParameter(request, "FolderName"))%>" , false);
                      //strucTree.doNavigate=false;
                  }
                  strucTree.displayFrame = objStructFrame;
                  strucTree.refresh();
              }
			  //Bug - 330541
			  var tree = parent.window.getWindowOpener().getTopWindow().objDetailsTree;
			  if(tree) {
				var contextNode = tree.objects["<%=XSSUtil.encodeForJavaScript(context,(String)workspaceVault.getObjectId())%>"];
				contextNode.nodes[0].changeObjectName("<%=XSSUtil.encodeForJavaScript(context,(String) emxGetParameter(request, "FolderName"))%>" , false);
				tree.refresh();
			  }
			  //Bug - 330541
          } //till here for bug 319716
      } else {
<%
         // to refresh Structure Tree
         String parentType = null;
         String newVaultId = workspaceVault.getObjectId();
         if (parentObjectType.equals(DomainConstants.TYPE_WORKSPACE_VAULT)) {
           workspaceVault.setId(parentObjectId);

           // determine the project type.  Folders under projects need the access tree node
           // but folders under project template do not.
           StringList objectSelects = new StringList(1);
           objectSelects.add(workspaceVault.SELECT_VAULT_HOLDER_ID);

           // get the top folder.  We need to know what type of project it's attached to
           Map topVaultMap   = workspaceVault.getTopLevelVault(context, objectSelects);
           String topVaultId = (String) topVaultMap.get(workspaceVault.SELECT_VAULT_HOLDER_ID);
           project.setId(topVaultId);

           // Get the type of object the folder is attached to
           parentType = project.getInfo(context, project.SELECT_TYPE);
         } else {
           parentType = parentObjectType;
         }
         if (parentType.equals(DomainConstants.TYPE_PROJECT_TEMPLATE)) {
%>
           tree.refresh();
<%
         } else {
%>

           var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
           if(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener()){
             contentFrame = contentFrame.getTopWindow();
           }
           contentFrame.addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context,newVaultId)%>", "<%=XSSUtil.encodeForJavaScript(context,parentObjectId)%>", conTree.getSelectedNode().nodeID, "<%=XSSUtil.encodeForJavaScript(context,appDirectory)%>","","", false);
<%
         }
%>
         getTopWindow().getWindowOpener().parent.document.location.href = getTopWindow().getWindowOpener().parent.document.location.href;//modified to make Refresh work in Netscape & IE
     }
       parent.window.closeWindow();
  }
  // Stop hiding here -->//]]>

</script>
