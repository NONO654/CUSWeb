<%--  emxCommonSelectOrganizationDialog.jsp   -  This page lists all the RTS Templates related to the Company
   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonSelectWorkspaceFolderDialog.jsp.rca 1.9 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc" %>

<html>
<head>
<title>Select Tree</title>
</head>
<body onLoad="loadTree()">
  Loading Tree...
</body>
<script language="javascript">
  function loadTree() {
    //get reference to the tree object
<%
  Company company = (Company)DomainObject.newInstance(context, DomainConstants.TYPE_COMPANY, DomainConstants.SOURCING);
  Workspace ws = (Workspace)DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE, DomainConstants.SOURCING);
  WorkspaceVault folder = (WorkspaceVault)DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT, DomainConstants.SOURCING);

  String objectId = emxGetParameter(request,"objectId");
  String strSelect = emxGetParameter(request,"select");
%>
    var tree = parent.tree;

    //set the current frame to the display frame
    tree.displayFrame = self.name;
    tree.multiSelect = false;
    tree.propagate = false; // made false, to make no child selected automatically, when parent selected

    //we want radio/check buttons
<%
  if((strSelect !=null && !"null".equals(strSelect)) && "multiple".equals(strSelect))
  {
%>
    tree.multiSelect = true;
<%
  }
%>

<%
  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  StringList buListSelectables = person.getObjectSelectList(1);
  buListSelectables.add(person.SELECT_NAME);
  buListSelectables.add(person.SELECT_ID);


  StringList buListSelectables1 = ws.getObjectSelectList(3);
  buListSelectables1.add(ws.SELECT_NAME);
  buListSelectables1.add(ws.SELECT_ID);
  //May be used for selecting folders already connected.
  buListSelectables1.add(folder.SELECT_CONTENT_ID);

  String workspace = ComponentsUtil.i18nStringNow("emxSupplierSourcing.TreeNode.Workspaces", request.getHeader("Accept-Language"));

  //MapList buList = person.getUserProjects(context,buListSelectables,null,false);
  MapList buList =null;
  String strFolderAccessMember = emxGetParameter(request,"folderAccessMember");
  
  if(strFolderAccessMember !=null && !strFolderAccessMember.equals("") )
  {
      //PT :Workspace should be active to search the workspace folder 
      buList =   person.getUserProjects(context,buListSelectables,"current==Active",false);
  }
  else{
      buList = person.getUserProjects(context,buListSelectables,null,false); 
  }
%>
    //create the root
    tree.createRoot("<%=XSSUtil.encodeForJavaScript(context, workspace)%>", "../common/images/iconSmallWorkspace.gif", "");

    //set the root to be selectable because by default it is NOT selectable
    tree.root.selectable = false;

<%
    if(buList.size() > 0)
    {
%>//XSSOK
   <framework:mapListItr mapList="<%= buList %>" mapName="orgMap">
      //add top-level nodes using tree.root.addChild(text, image, expandURL)
      objCurNode = tree.root.addChild("<%=orgMap.get(person.SELECT_NAME)%>", "../common/images/iconSmallWorkspace.gif", false, "<%=orgMap.get(person.SELECT_ID)%>");

      //make this node unselectable (by default all children ARE selectable)
      objCurNode.selectable = false;
<%
      String folderId = "";
      String folderName = "";

      StringList folderContents = new StringList();
      ws.setId((String)orgMap.get(person.SELECT_ID));
      MapList pfList = ws.getWorkspaceFolders(context,buListSelectables1);
      if(pfList.size() > 0) {
%>
        <framework:mapListItr mapList="<%= pfList %>" mapName="pfMap">
          var presentNode = objCurNode;
<%
          folderId = (String)pfMap.get(ws.SELECT_ID);
          folderName = (String)pfMap.get(ws.SELECT_NAME);

////////////////////////////////////////////////////////////////////////////////////////
            HashMap hm = new HashMap();
            Vector processVector = new Vector();
            Vector resultVector  = getObjects(context, folderId, folderName, processVector);
            for ( int i=0; i < resultVector.size(); i++) {
              hm = (HashMap)resultVector.elementAt(i);
              WorkspaceVault sv = (WorkspaceVault)DomainObject.newInstance(context, (String)hm.get(ws.SELECT_ID), DomainConstants.SOURCING);

              String parentId = sv.getParentVaultId(context);
              if(parentId == null || "".equals(parentId) || "null".equals(parentId)) {
%>
				//XSSOK
                tempNode = presentNode.addChild("<%=hm.get(ws.SELECT_NAME)%>", "../common/images/iconSmallWorkspaceFolder.gif", false, "<%= hm.get(ws.SELECT_ID)%>");
                tempNode.selectable = true;
<%
              } else {
%>
                tempNode = tree.nodes["<%=XSSUtil.encodeForJavaScript(context, parentId)%>"];
				//XSSOK
                tempNode = tempNode.addChild("<%=hm.get(ws.SELECT_NAME)%>", "../common/images/iconWorkspaceFolder.gif", false, "<%= hm.get(ws.SELECT_ID)%>");
				//Bug No :303538 Dt:10-May-2005
                tempNode.selectable = true;
                //Bug No :303538 Dt:10-May-2005
<%
              }
            }
//////////////////////////////////////////////////////////////////////////////////////////
%>

        </framework:mapListItr>
<%
      }
%>

   </framework:mapListItr>

<%
    }
%>
    //draw the tree
    tree.draw();
  }
</script>
</html>

<%!
  public Vector getObjects(matrix.db.Context context, String folderId, String folderName, Vector vector) throws MatrixException
  {
    try {
      WorkspaceVault wsv = (WorkspaceVault)DomainObject.newInstance(context, folderId, DomainConstants.SOURCING);
      boolean hasReadAccess = false;
      boolean hasFromConnectAccess = false;
      boolean deniedAccess=false;

      deniedAccess=false;
      if(!"#DENIED!" .equals(folderId) ){
        StringList selectList = new StringList(3);
        selectList.add("current.access[fromconnect]");
        selectList.add("current.access[read]");
        Map map = wsv.getInfo(context,selectList);
        hasReadAccess = ((String) map.get("current.access[read]")).equalsIgnoreCase("true")?true:false;
        hasFromConnectAccess = ((String) map.get("current.access[fromconnect]")).equalsIgnoreCase("true")?true:false;
      }
      else{
        deniedAccess=true;
      }

      if( !((hasReadAccess && hasFromConnectAccess)&&(!deniedAccess)) ){
        return vector;
      }

      StringList busSelects = new SelectList(2);
      busSelects.add(wsv.SELECT_ID);
      busSelects.add(wsv.SELECT_NAME);

      MapList list = wsv.getSubVaults(context, busSelects, 1 );
      HashMap htt = new HashMap();
      String fldrId = "";
      String fldrName = "";
      htt.put(wsv.SELECT_ID, folderId);
      htt.put(wsv.SELECT_NAME, folderName);
      vector.add(htt);

      if( list.size() == 0){
        return vector;
      } else {
        for(int i = 0; i < list.size(); i++){
          try{
            fldrId = (String) ((Hashtable)list.get(i)).get(wsv.SELECT_ID);
            fldrName = (String) ((Hashtable)list.get(i)).get(wsv.SELECT_NAME);
          } catch(Exception e) {
            fldrId = (String) ((HashMap)list.get(i)).get(wsv.SELECT_ID);
            fldrName = (String) ((HashMap)list.get(i)).get(wsv.SELECT_NAME);
          }
          getObjects(context, fldrId, fldrName, vector);
        }
      }
    } catch(Exception ex) {
    }
    return vector;
  }
%>
