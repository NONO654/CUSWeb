<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Disconnects Child objects from Parent
   Parameters : ObjectId-parent objectId
                ChildIds to be Disconnected

   Author     : Madhavhg
   Date       : 1/02/2003
   History    :

   static const char RCSID[] = "$Id: emxDocumentCentralObjectRemoveContentsProcess.jsp.rca 1.18 Tue Oct 28 23:00:37 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%

    Vector vecObjectIds     = new Vector();
    Hashtable hashNames     = new Hashtable();
    String parentId         = emxGetParameter(request, "objectId");
    String childIds[]       = (String[]) emxGetParameterValues(request, "emxTableRowId");
    childIds                = getTableRowIDsArray(childIds);
    StringBuffer sbErrorMsg = new StringBuffer();

    if(childIds != null) {
        for(int i=0;i<childIds.length;i++) {
            StringTokenizer st   = new StringTokenizer(childIds[i],"|");
            String sObjId        = "";
            while(st.hasMoreTokens()) {
               sObjId = st.nextToken();
            }
            childIds[i]          = sObjId;
            DomainObject doObj   = new DomainObject(sObjId);
            String strName       = doObj.getInfo(context,DomainObject.SELECT_NAME);
            if(strName != null) {
                hashNames.put(strName,sObjId);
            }
            vecObjectIds.addElement(sObjId);
        }
    }
    String languageStr          = request.getHeader("Accept-Language");
    String workSpaceVault       = Framework.getPropertyValue(session,"type_ProjectVault");
    String objectsNotRemoved    = "";

    //Getting the Type Info  of the Parent.
    DomainObject parentobj      = new DomainObject(parentId);
    String sParentType          = parentobj.getInfo(context,DomainObject.SELECT_TYPE);

    if(sParentType.equals(workSpaceVault))  {
        DCWorkspaceVault workSpaceVaultObj  = new DCWorkspaceVault(parentId);
        objectsNotRemoved   = workSpaceVaultObj.removeToObjects(context,childIds);
    }
    String strObjName       = "";
    String strObjectId      = "";
    StringTokenizer st      = new StringTokenizer(objectsNotRemoved," ");
    StringBuffer strObjNotRemovedName = new StringBuffer();

    while(st.hasMoreTokens()) {
        strObjName      = st.nextToken().trim();
        if(hashNames.containsKey(strObjName)){
            strObjectId = (String)hashNames.get(strObjName);
        }
        if(strObjectId != null && !strObjectId.trim().equals(""))
            vecObjectIds.removeElement(strObjectId);
    }

%>


<script language="javascript" type="text/javaScript">
    var vErrorMsg   = "<xss:encodeForJavaScript><%=sbErrorMsg.toString().trim()%></xss:encodeForJavaScript>";

    try{
        if (vErrorMsg != "") {
            alert(vErrorMsg);
        }
        //getting the Parent Node
        var parentNode = getTopWindow().objStructureTree.findNodeByObjectID('<xss:encodeForJavaScript><%= parentId %></xss:encodeForJavaScript>');
        if (parentNode) {
<%
            int iSize  = vecObjectIds.size();
            for (int i = 0; i < iSize; ++i) {
%>
                var childId = '<xss:encodeForJavaScript><%=(String)vecObjectIds.elementAt(i)%></xss:encodeForJavaScript>';
                if(getTopWindow().objStructureTree.findNodeByObjectID(childId)) {
                    //removing the child in selected parent node
                    parentNode.removeRelationshipTo(childId);
                }
<%
            }
%>
        }
        getTopWindow().refreshTablePage();
    }catch(exec){
        getTopWindow().refreshTablePage();
    }
</script>
