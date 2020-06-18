<%--  emxComponentsTreeUtilInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<script language="Javascript">
    var contentFrame = openerFindFrame(getTopWindow(), "content");
    var detailsDisplay = null;
    if(getTopWindow().location.href.indexOf("emxNavigator.jsp")== -1) {
         detailsDisplay = openerFindFrame(getTopWindow(), "detailsDisplay");
    }else{ 
    var displayFrame = findFrame(getTopWindow(), "detailsDisplay");
    if(displayFrame) {
       detailsDisplay = displayFrame;
    }
    }
	var detailsTree  =null;
	if(contentFrame!=null){
		detailsTree  = contentFrame.getTopWindow().objDetailsTree;
	}
	var fromGlobalActionToolbar =false;
	if(getTopWindow().location.href.indexOf("emxNavigator.jsp")== -1) {
		fromGlobalActionToolbar = getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().name == "";
	}

   //For adding the node in structure and details tree and load the added object URL
		
 function loadTreeNode(nodeObjectId, parentNodeObjectId, treeNodeId,appDirectory, blnAddToDetailsTree, treeUrl)  {
		var structureNodeAdded = false;
		if(treeNodeId == null || treeNodeId == "null" || treeNodeId == "undefined")
			treeNodeId = "";
		if(detailsDisplay && detailsTree && !fromGlobalActionToolbar) {
			contentFrame.getTopWindow().addStructureTreeNode(nodeObjectId, parentNodeObjectId, treeNodeId,appDirectory, blnAddToDetailsTree);
			structureNodeAdded = true;		
	 	}
        if(treeUrl == null){
          treeUrl = getTreeURL(nodeObjectId,appDirectory);
          }
     if(structureNodeAdded){
           detailsDisplay.document.location.href = treeUrl;
          }
          else{
           contentFrame.document.location.href = treeUrl;
        }
     }
     
     // getting the object tree URL
    function getTreeURL(objectId, appDirectory, relId, mode, AppendParameters, treeNodeId){
     if(relId == null){
     relId = "null";
     }
     if(mode == null){
     mode = "insert";
     }
     if(AppendParameters == null){
     AppendParameters = "true";
     }
     return "../common/emxTree.jsp?AppendParameters="+AppendParameters+"&objectId=" + objectId + "&relId=" + relId +
     "&emxSuiteDirectory="+appDirectory + "&mode="+mode+"&jsTreeID="+treeNodeId;  
     }
     

     
</script>
