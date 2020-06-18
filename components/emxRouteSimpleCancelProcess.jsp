<%--   emxRouteWizardCancelProcess.jsp -- This is the process page which edits the Route Template Object.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSimpleCancelProcess.jsp.rca 1.1.2.5 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

 <%

	 String keyValue=emxGetParameter(request,"keyValue");

 %>

<script language="Javascript">
  var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "hiddenFrame");
  var tree         = null;
  if(frameContent)
  {
	  
        tree=frameContent.getTopWindow ? frameContent.getTopWindow().tempTree : null;
   }
  var strucTree    = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;


<%
  DomainObject BaseObject = DomainObject.newInstance(context);

  Hashtable routeDetails = null;
  try  { 
	     routeDetails= (Hashtable)formBean.getElementValue("hashRouteWizFirst");
  } catch(Exception e) { }

  if (routeDetails != null) {
    MapList upLoadedFilesMapList      = null;
    String documentID                 = null;
    String newFolderId                = null;
    upLoadedFilesMapList              = (MapList)routeDetails.get("uploadedDocIDs");
    documentID                        = (String)routeDetails.get("documentID");
    newFolderId                       = (String)routeDetails.get("newFolderIds");

 //For Deleting any new Folder that was created.
    if(newFolderId != null && !"".equals(newFolderId)) {
      BaseObject.setId(newFolderId);
      BaseObject.deleteObject(context);
    }
// If there are any content objects added , Remove them.
    if (documentID != null) {
      if (upLoadedFilesMapList != null && upLoadedFilesMapList.size() > 0) {
        Iterator upLoadedFilesMapListItr = upLoadedFilesMapList.iterator();

        while(upLoadedFilesMapListItr.hasNext()) {
          Map upLoadedMap = (Map)upLoadedFilesMapListItr.next();

          if (upLoadedMap != null) {
            String docId = (String)upLoadedMap.get("docID");
            String foldId= (String)upLoadedMap.get("folderId");

            try {
              BaseObject.setId(docId);
              BaseObject.deleteObject(context);

              if (foldId != null && !"".equals(foldId)) {
                DomainObject domainObject = null;

                MapList  folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,foldId);

                if(folderMapList != null && folderMapList.size() > 0 ) {

                  Iterator folderMapListItr = folderMapList.iterator();
                  // Get the updated Tree Label
                  while(folderMapListItr.hasNext()) {
                    Map folderMap = (Map)folderMapListItr.next();
                    String folderId = (String)folderMap.get(domainObject.SELECT_ID);
                    String treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,folderId,(String)null,appDirectory,sLanguage);

%>
                    if (tree) {
                      var nodeArray = tree.objects["<%= XSSUtil.encodeForJavaScript(context,folderId)%>"];
                      if (nodeArray) {
                        nodeArray.nodes[0].changeObjectName("<%=XSSUtil.encodeForJavaScript(context, treeLabel)%>",false);
                      }
                      struTreeNodeArray    = strucTree.objects["<%=XSSUtil.encodeForJavaScript(context,folderId)%>"];
                      if(struTreeNodeArray) {
                        struTreeNodeArray.nodes[0].changeObjectName("<%=XSSUtil.encodeForJavaScript(context, treeLabel)%>",false);
                        struTreeNodeArray.nodes[0].tree.doNavigate=false;
                      }

                    }
<%
                  }
                }
              }

            } catch(Exception e) {

            }
          }
        }
%>
        if (tree) {
          tree.deleteObject("<%= XSSUtil.encodeForJavaScript(context,newFolderId)%>", true);
        } else{
          var tree = parent.window.getTopWindow().tempTree;
          tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,newFolderId)%>", true);

        }
        var objStructFrame = null;
          if(frameContent)
        {
                objStructFrame=findFrame(frameContent.getTopWindow(), "emxUIStructureTree");
        }

        if(strucTree) {
          if(objStructFrame) {
            strucTree.displayFrame = objStructFrame;
            strucTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,newFolderId)%>", false);
            strucTree.refresh();
          }
  }
<%
      }
    }
  }

        //Call the "clearFormBean()" method and clear the formBean content
            formBean.clear();
			formBean.removeFormInstance(session,request);
			session.removeAttribute(keyValue);


  //End of code for resetting session
%>
  window.closeWindow();
</script>


