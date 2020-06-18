<%--  emxTeamFoldersView.jsp   -   Displays the Folder Objects List
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamFoldersView.jsp.rca 1.21 Wed Oct 22 16:05:55 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@ include file = "emxTeamStartReadTransaction.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String sObjectId    = emxGetParameter(request,"objectId");
  String templateId   = emxGetParameter(request, "templateId");
  String template     = emxGetParameter(request, "template");
  String strSelect    = emxGetParameter(request,"select");

 //Literal String Used in this Page

  String objectNameStr  = "";
  String objectIdStr    = "";
  String objectDescStr  = "";
  String objectStateStr = "";
  String objectOwnerStr = "";
  String colorStr = "odd";
  boolean colorFlag = false;

  Workspace ws          = (Workspace)DomainObject.newInstance(context,sObjectId,DomainConstants.TEAM);
  WorkspaceVault folder = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
  StringList buListSelectables1 = ws.getObjectSelectList(3);
  buListSelectables1.add(ws.SELECT_NAME);
  buListSelectables1.add(ws.SELECT_ID);
  //May be used for selecting folders already connected.
  buListSelectables1.add(folder.SELECT_CONTENT_ID);
  String workspace = i18nNow.getI18nString("emxFramework.Command.Workspace", "emxTeamCentralStringResource",request.getHeader("Accept-Language"));
  String folderLabelI18N   = i18nNow.getI18nString("emxFramework.Command.Folder ", "emxTeamCentralStringResource",request.getHeader("Accept-Language"));
  MapList buList   = ws.getWorkspaceFolders(context,buListSelectables1);
  
%>

<body onLoad="loadTree()">
</body>

<script language="javascript">
function loadTree(){

  var tree = parent.tree;
  tree.checkUrl = "emxTeamSubFoldersViewFS.jsp?objectId=";
  tree.displayFrame = self.name;
  //XSSOK
  tree.multiSelect = "ture" == "<%="multiple".equals(XSSUtil.encodeForJavaScript(context, strSelect))%>";

  //create the root
  tree.createRoot("<%=folderLabelI18N%>", "images/iconSmallFolder_new.png", "");
  //set the root to be selectable because by default it is NOT selectable
  tree.root.selectable = false;

  <framework:ifExpr expr="<%=buList.size() > 0%>">
      firsttime = true;
      var defaultnode = null;
  	  <framework:mapListItr mapList="<%= buList %>" mapName="foldermap">
<%
          String folderId = (String)foldermap.get(ws.SELECT_ID);
          String folderName = (String)foldermap.get(ws.SELECT_NAME);
          folder.setId(folderId);
          StringList subFoldersellist  = new StringList();
          subFoldersellist.add(folder.SELECT_NAME);
          subFoldersellist.add(folder.SELECT_ID);
          MapList subFolderList = folder.getSubVaults(context, subFoldersellist, 0);
%>

	      //add top-level nodes using tree.root.addChild(text, image, expandURL)
	   <!-- \\XSSOK -->
	      objCurNode = tree.root.addChild("<%=folderName%>", "images/iconSmallFolder_new.png", false, "<%=folderId%>");
    	  if (firsttime){
        	 defaultnode = objCurNode
	      }
	      firsttime = false;
	      //make this node unselectable (by default all children ARE selectable)
    	  objCurNode.selectable = true;
      	 
      	 <framework:ifExpr expr="<%=subFolderList.size() > 0%>">
		      <framework:mapListItr mapList="<%= subFolderList %>" mapName="pfMap">
        	      var presentNode = objCurNode;
<%
	               WorkspaceVault sv = new WorkspaceVault((String)pfMap.get(folder.SELECT_ID));
	               String parentId = sv.getParentVaultId(context);
	               boolean isPrentIdNull = parentId == null || "".equals(parentId) || "null".equals(parentId);
%>
                   <framework:ifExpr expr="<%=isPrentIdNull%>">
                   <!-- \\XSSOK -->
                   		tempNode = presentNode.addChild("<%=pfMap.get(folder.SELECT_NAME)%>", "images/iconSmallFolder_new.png", false, "<%= pfMap.get(folder.SELECT_ID)%>");
	                    tempNode.selectable = true;
                  </framework:ifExpr>
				  <framework:ifExpr expr="<%=!isPrentIdNull%>">
				  <!-- \\XSSOK -->
                  		tempNode = tree.nodes['<%=parentId%>'];
                  		<!-- \\XSSOK -->
                      	tempNode = tempNode.addChild("<%=pfMap.get(folder.SELECT_NAME)%>", "images/iconSmallFolder_new.png", false, "<%= pfMap.get(folder.SELECT_ID)%>");
                      	tempNode.selectable = true;
                  </framework:ifExpr>
      		</framework:mapListItr>
       </framework:ifExpr>
	</framework:mapListItr>
   //draw the tree
    tree.draw();    
    parent.linkClick(defaultnode.nodeID)
    //tree.setSelectedNode(defaultnode.nodeID);
    //parent.frames[1].document.location.href="emxTeamSubFoldersViewFS.jsp?objectId="+defaultnode.getObjectID();
   </framework:ifExpr>
 }
function load(param) {
  parent.frames[1].document.location.href="emxTeamSubFoldersViewFS.jsp?objectId="+param;
}

function goBack(){
  //parent.document.location.href="emxTeamCreateWorkspaceToplevelFoldersFS.jsp?objectId=<%=sObjectId%>";
  document.folderSummary.action =  "emxTeamCreateWorkspaceToplevelFoldersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, sObjectId)%>&template=<%=XSSUtil.encodeForURL(context, template)%>&templateId=<%=XSSUtil.encodeForURL(context, templateId)%>";
  document.folderSummary.submit();
}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="folderSummary" method="post">
</form>
<%@include file="emxTeamCommitTransaction.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>




