<%--  emxTeamUnlockDocument.jsp   -

   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamUnlinkSelectedFoldersProcess.jsp.rca 1.7.3.1 Wed Apr  2 16:19:20 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>

<%
    //get document Id
	String[] linkedFolderIds = (String[])emxGetParameterValues(request, "emxTableRowId");

	StringList relIds = new StringList();

	String RELATIONSHIP_LINKED_FOLDERS = PropertyUtil.getSchemaProperty(context, "relationship_LinkedFolders");
	boolean needDisconnect = false;
	
	String sXML = "";
	
	for (int i=0; i<linkedFolderIds.length; i++)
	{
		String folderId = linkedFolderIds[i];
		int index = folderId.indexOf("|");
		if ( index > 0 )
		{
			String relId = folderId.substring(0, index);
			DomainRelationship rel = new DomainRelationship(relId);
			rel.open(context);
			String relName = rel.getRelationshipType().getName();
			rel.close(context);
			if( RELATIONSHIP_LINKED_FOLDERS.equals(relName) )
			{
				needDisconnect = true;
				relIds.add(relId);
			}
		}
				
	}

	StringList relationshipSelects = new StringList("from.id");
	relationshipSelects.add("to.id");
	MapList mlRelInfos = new MapList();

	if( needDisconnect)
	{
		String[] arrayIds  = new String[relIds.size()];
		arrayIds = (String[])relIds.toArray(arrayIds);

		mlRelInfos = DomainRelationship.getInfo(context, arrayIds, relationshipSelects);

		DomainRelationship.disconnect(context, arrayIds);
	}
%>
            <jsp:forward page="../simulationcentral/smaTurnOffProgress.jsp">
                <jsp:param name="mxRootAction" value="remove"/>
            </jsp:forward>
