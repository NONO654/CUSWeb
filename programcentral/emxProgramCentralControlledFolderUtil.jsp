<%--  emxProgramCentralFolderReviseProcess.jsp   -

	The emxProgramCentralFolderReviseProcess.jsp JSP is linked to the Revise command(PMCProjectFolderRevise ). On clicking revise command the current folder will be revised to new revision and a configured trigger TypeControlledFolderRevisionAction” “Obsolete Last Revision” will perform following sequence of events.

	1.	Last revision folders state is stored into attribute Last State Before Obsolete
	2.	Last revision folder object is moved into Obsolete state
	3.	The parent object of the folder (Project Space/ Project Concept/ Project Template/Controlled Folder/ Workspace??) will be disconnected from old revision and will point to latest revision

   Copyright (c) Dassault Systemes, 1993 - 2018. All rights reserved.
   This program contains proprietary and trade secret information of Dassault Systems.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: Exp $
--%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<!-- Java script functions -->

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Page display code here -->

<%

    //
    // Java code with error handling
    //
    String sLanguage = request.getHeader("Accept-Language");
	String folderId 		 = emxGetParameter(request, "objectId");
    String strNewObjectId    = "";
	String strParentOID      = "";
	String strJSTreeID       = emxGetParameter(request, "jsTreeID");
	String strSuiteDirectory = emxGetParameter(request, "SuiteDirectory");
	String strParentType 	 = "";
	String strMode 	 		 = emxGetParameter(request, "mode");//Mode could be Relase or Revise

	//Added:4-Jun-10:rg6:R210:PRG Bug:IR-053998V6R2011x
	/*
        When the request is made from structure browser(RMB menu) for the folder the object id is not
        recieved(instead project id is recieved) in the parameter, in order to filter
        the object id below code is added.
   */
	String[] strFolders = emxGetParameterValues(request,"emxTableRowId");
	String isFromRMB=emxGetParameter(request,"isFromRMB");	// check if request is from RMB
	StringList slFolderTokens = new StringList();
	String strFolderId = null;
	String strFolderRelId = null;
	  if(isFromRMB!=null && strFolders!=null){
	      for (int i = 0; i < strFolders.length; i++)
	      {
	          slFolderTokens = FrameworkUtil.split(strFolders[i], "|");
	          strFolderId = (String) slFolderTokens .get(1);
	      }
	  }
	  if(ProgramCentralUtil.isNotNullString(strFolderId))
		  folderId=strFolderId;
	//End:4-Jun-10:rg6:R210:PRG Bug:IR-053998V6R2011x

	//FOR INDICATING ERROR FREE PROCESS EXECUTION
	boolean flag=false;

	//FOR RELATIONSHIPS
	  final String SELECT_PARENTID_VIA_DATA_VAULT = "to[" + com.matrixone.apps.domain.DomainConstants.RELATIONSHIP_WORKSPACE_VAULTS + "].from.id";
      final String SELECT_PARENTID_VIA_SUB_VAULT = "to[" + com.matrixone.apps.domain.DomainConstants.RELATIONSHIP_SUB_VAULTS + "].from.id";
      final String SELECT_PARENTID_VIA_LINKED_FOLDERS = "to[" + com.matrixone.apps.domain.DomainConstants.RELATIONSHIP_LINKED_FOLDERS + "].from.id";


    try {
        com.matrixone.apps.domain.util.ContextUtil.startTransaction(context,true);
        if("release".equals(strMode)){

            com.matrixone.apps.domain.DomainObject domFolder = com.matrixone.apps.domain.DomainObject.newInstance(context,folderId);
            domFolder.promote(context);
            %>
            <script type="text/javascript">
			 parent.document.location.href = parent.document.location.href;
			</script>
            <%
        }
        else if("revise".equals(strMode)){
        com.matrixone.apps.domain.DomainObject contFolder = com.matrixone.apps.domain.DomainObject.newInstance(context, folderId);
        com.matrixone.apps.domain.DomainObject newRevision = new com.matrixone.apps.domain.DomainObject(contFolder.reviseObject(context,false));

		//GETTING NEW REV ID HERE
		//com.matrixone.apps.domain.DomainObject domFolder = com.matrixone.apps.domain.DomainObject.newInstance(context,folderId);

        strNewObjectId=newRevision.getId();
        System.out.println("NEW REV :"+strNewObjectId);

        //SELECTABLES TO FIND PARENT ID FROM NEW REV ID
        //
        StringList slSelectables = new StringList(3);
        slSelectables.addElement(SELECT_PARENTID_VIA_SUB_VAULT);
        slSelectables.addElement(SELECT_PARENTID_VIA_DATA_VAULT);
        slSelectables.addElement(SELECT_PARENTID_VIA_LINKED_FOLDERS);
        //ENDS

        //NOEW SET THE NEW REV ID TO DOMAINOBJECT TO GET LATEST INFO
        //domFolder.setId(strNewObjectId);
		Map mpObjectInfo = contFolder.getInfo(context,slSelectables);
		System.out.println("MAP :"+mpObjectInfo);

		if(mpObjectInfo.get(SELECT_PARENTID_VIA_LINKED_FOLDERS)!=null){

		    strParentOID=(String)mpObjectInfo.get(SELECT_PARENTID_VIA_LINKED_FOLDERS);

		}
		else if(mpObjectInfo.get(SELECT_PARENTID_VIA_DATA_VAULT)!=null){

		    strParentOID=(String)mpObjectInfo.get(SELECT_PARENTID_VIA_DATA_VAULT);

		}
		else if(mpObjectInfo.get(SELECT_PARENTID_VIA_SUB_VAULT)!=null){

		    strParentOID=(String)mpObjectInfo.get(SELECT_PARENTID_VIA_SUB_VAULT);

		}
		else{

			String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral",
					  "emxProgramCentral.ControlledFolder.errMsg", sLanguage);
			throw new Exception(errMsg);
		}

		com.matrixone.apps.domain.DomainObject dmoParentType = com.matrixone.apps.domain.DomainObject.newInstance(context,strParentOID);
		strParentType = (String)dmoParentType.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_TYPE);

		//------------Inherit Access-------------
		String attrAccessTypeSelect = DomainObject.getAttributeSelect(PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_attribute_AccessType));
        String attrAccessType = newRevision.getInfo(context, attrAccessTypeSelect);
        
        if (!"Specific".equals(attrAccessType)){
	 	String toId = strParentOID;
		String toType = strParentType;
		String fromId = strNewObjectId;
		DomainAccess.createObjectOwnership(context, fromId,toId,  null, true);
        }
		//--------------
		//TRUE INDICATES EVERYTHING HAS GONE AS PER PLAN
		flag=true;
		//Added:16-July-10:rg6:R210:PRG Bug:IR-058150V6R2011x
		   %>
           <script type="text/javascript">
            parent.document.location.href = parent.document.location.href;
           </script>
           <%
         //End:16-July-10:rg6:R210:PRG Bug:IR-058150V6R2011x
    	}
        com.matrixone.apps.domain.util.ContextUtil.commitTransaction(context);
	    }catch (Exception ex) {
	        com.matrixone.apps.domain.util.ContextUtil.abortTransaction(context);
	         if (ex.toString() != null && ex.toString().length() > 0) {
	            emxNavErrorObject.addMessage(ex.toString());
	         }
	        ex.printStackTrace();
    } finally {
        if(flag){
        %>
       <script language="javascript" type="text/javaScript">

		// RELOADS SUBTREE FOR ANY NONE ROOT NODE IN STRUCTURE TREE
		function reloadSubtree (objNode) {
			if (objNode)
			{
				objNode.clear();
				objNode.loaded = false;
				objNode.collapse();
				//objNode.expand();
			}
		}// reloadSubtree()

		var tree = getTopWindow().objDetailsTree;
		var objTreeRootNode = tree.getOriginalRoot();
		var strTreeObjID = objTreeRootNode.objectID;

	    var structTree = getTopWindow().objStructureTree;
		var objStructTreeRootNode = structTree.getCurrentRoot()
		var strStructTreeObjID = objStructTreeRootNode.objectID;

		var objNode = tree.findNodeByObjectID("<%=folderId+""%>");
		var strNodeID = objNode.nodeID;
		var parentNode = tree.getNode(strNodeID).getParent().nodeID;


	    //IMPORTANT
		var strParentOID      = "<%=XSSUtil.encodeForJavaScript(context,strParentOID)%>";
		var strNewObjectId    = "<%=XSSUtil.encodeForJavaScript(context,strNewObjectId)%>";
		var strJSTreeID       = strStructTreeObjID;
		var strSuiteDirectory = "<%=XSSUtil.encodeForJavaScript(context,strSuiteDirectory)%>";
		var strParentType 	  = "<%=XSSUtil.encodeForJavaScript(context,strParentType)%>";
		//IMPORTANT



	    if(tree == null) {
	        getTopWindow().getWindowOpener().parent.document.location.href = getTopWindow().getWindowOpener().parent.document.location.href;//modified to make Refresh work in Netscape & IE
	    } else {

	        tree.deleteObject("<%=folderId+""%>", false);
	        structTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,folderId)%>",false);

	        // Check if the node for the parent object is already there in the structure tree?
			// If it is, then only we can add child node to it

			//FOR ADDING NEWLY REVISED STRUCTURE TREE
			var objOpener = getTopWindow().parent; // Parent getWindowOpener() window
            var objStructureTree = objOpener.getTopWindow().objStructureTree; // Reference to the structure tree

            if (objStructureTree.hasObject(strParentOID)) {
                var objParentNode = objStructureTree.findNodeByObjectID(strParentOID);
                var contentFrame = findFrame(objOpener.getTopWindow(), "content");
                if (contentFrame) {
                    if (contentFrame.addStructureTreeNode) {
                        contentFrame.addStructureTreeNode(strNewObjectId, strParentOID, strJSTreeID, strSuiteDirectory);
                    }
                }

            }
			//FOR ADDING NEWLY REVISED STRUCTURE TREE

	        //FOR ADDING NEWLY REVISED DETAILS TREE

			var frameContent = findFrame(getTopWindow(), "content");
			var newTree = getTopWindow().objDetailsTree;
			var nodeVar = newTree.root;
			var objNoded = "";

			frameContent.addStructureNode(strNewObjectId, strParentOID,parentNode,strSuiteDirectory);

			//FOR ADDING NEWLY REVISED DETAILS TREE ENDS

			var objStructureTree1 = objOpener.getTopWindow().objStructureTree; // Reference to the structure tree
			//LOGIC FOR REFRESHING THE NEWLY REVISED FOLDER TREE
			if(strParentType=="<%=com.matrixone.apps.domain.DomainConstants.TYPE_CONTROLLED_FOLDER%>"){
			objNoded = objStructureTree.findNodeByObjectID(strParentOID);
			}

			//this is for refreshing the tree structure after modifications
			reloadSubtree(objNoded);

	        var dispFrame = getTopWindow().findFrame(getTopWindow(),"emxUIStructureTree");
	        if(dispFrame != null){
	            structTree.refresh();
	        }
	    }
	    parent.document.location.href = parent.document.location.href;

       </script>
        <%
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
