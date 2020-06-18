<%--  emxTeamUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamUnlinkSelectedFoldersProcess.jsp.rca 1.7.3.2 Wed Oct 22 16:05:59 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "emxTeamTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    //get document Id
	String[] linkedFolderIds = (String[])emxGetParameterValues(request, "emxTableRowId");
	String parentObjId = request.getParameter("objectId");
	StringList relIds = new StringList();

	String RELATIONSHIP_LINKED_FOLDERS = PropertyUtil.getSchemaProperty(context, "relationship_LinkedFolders");
	boolean needDisconnect = false;
	StringList selectedFolderIds = new StringList();
	for (int i=0; i<linkedFolderIds.length; i++)
	{
		String folderId = linkedFolderIds[i];
		StringTokenizer strTokenizer = new StringTokenizer(folderId , "|");
		String relId = strTokenizer.nextToken();
		selectedFolderIds.add(strTokenizer.nextToken());
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

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<script language="javascript">

<%	for (int i=0; i<selectedFolderIds.size(); i++)
	{%>
		getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, (String)selectedFolderIds.get(i))%>", false,true);
<%	}%>
getTopWindow().refreshTrees();
 var frameContent = openerFindFrame(getTopWindow(),"detailsDisplay");
frameContent.document.location.href = frameContent.document.location.href;

</script>

