/*=================================================================
 *  JavaScript Tree Utilities
 *  emxComponentsTreeUtil.js
 *  Version 1.0
 *  Requires: emxUIConstants.js
 *
 *  This file contains utility methods for interfacing with the
 *  structure and details trees.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *=================================================================
 */

//-----------------------------------------------------------------
// Function getObjectsToBeModified()
//-----------------------------------------------------------------
//
// DESCRIPTION
//      This function returns all the objectIds whose names should be updated in
//      both structure and details tree after adding/revising/removing etc...
//
// PARAMETERS
//      appDirectory (String)    - The appDirectory e.g.documentCentral
//      currentObjectId (String) - The OID of the object to be modified
//
// RETURNS
//      ObjectdIds (Array) - which are to be changed
//-----------------------------------------------------------------
function getObjectsToBeModified(openerObj, parentOIDs)
{
    var objectIds            = {};

    var vStructureTreeObject = openerObj.objStructureTree;
    var vStructureFancyTree  = openerObj.objStructureFancyTree;
    var vDetailsTreeObject   = openerObj.objDetailsTree;
    var vBreadCrumObject     = openerObj.bclist;
    
        var  vStructureTreeObjectIds = new Array();
	
        if (parentOIDs) {
            vStructureTreeObjectIds = parentOIDs.split(",");
        } else {
		if(vStructureTreeObject && vStructureTreeObject.getSelectedNode() && vStructureTreeObject.getSelectedNode().objectID){
            //get from vStructureTreeObject
            vStructureTreeObjectIds.push(vStructureTreeObject.getSelectedNode().objectID);
		}else if(vStructureFancyTree && vStructureFancyTree.getActiveNode() && vStructureFancyTree.getActiveNode().key){
			//get from vStructureFancyTree
			vStructureTreeObjectIds.push(vStructureFancyTree.getActiveNode().key);
		}else if(vBreadCrumObject && vBreadCrumObject.getCurrentBreadCrumbTrail() && vBreadCrumObject.getCurrentBreadCrumbTrail().getBreadCrumbArray()){
			// get from breadcrumb
			var breadCrumArray = vBreadCrumObject.getCurrentBreadCrumbTrail().getBreadCrumbArray();
			for(var i = 0; i < breadCrumArray.length ; i++ ) {
				if (breadCrumArray[i].categoryObj) {//should get only object Ids
					vStructureTreeObjectIds.push(breadCrumArray[i].id);
				}
			}
        }
	}
	
    
    if(vStructureTreeObject && vStructureTreeObject.objects && vStructureTreeObject.objects.length > 0) {
        for( var i = 0 ; i < vStructureTreeObjectIds.length; i++) {
            var node    = vStructureTreeObject.findNodeByObjectID(vStructureTreeObjectIds[i]);
            while(node) {
                objectIds[node.objectID]=node.objectID;
                node = node.getParent();
            }
        }
    }else if(vStructureFancyTree){
		for( var i = 0 ; i < vStructureTreeObjectIds.length; i++) {
            var node    = vStructureFancyTree.getNodeById(vStructureTreeObjectIds[i]);
            while(node && node.getParent()) {
                objectIds[node.key]=node.key;
                node = node.getParent();
            }
        }
	}else{
		for( var i = 0 ; i < vStructureTreeObjectIds.length; i++) {
            objectIds[vStructureTreeObjectIds[i]] = vStructureTreeObjectIds[i];
        }
   }
   
    return objectIds;
}


//-----------------------------------------------------------------
//Function getUpdatedLabel()
//-----------------------------------------------------------------
//
// DESCRIPTION
//      This function gets the updated Lable for a given objectId
//
// PARAMETERS
//      appDirectory (String)   - The appDirectory e.g.documentCentral
//      objectId (String)       - The OID of the object to be modified
//      openerObj (String)      - the opener object from where current operation is performed
//                                e.g top or getTopWindow().opener.getTopWindow()
//
// RETURNS
//      updated label (string)
//-----------------------------------------------------------------
function getUpdatedLabel(appDirectory,objectId,openerObj) {
    var url             = "../components/emxComponentsUpdatedTreeLabel.jsp?objectId=" + objectId + "&appDirectory=" +appDirectory;
    var xmlResult       = openerObj.emxUICore.getXMLData(url);
    var root            = xmlResult.documentElement;
    return (openerObj.emxUICore.getText(openerObj.emxUICore.selectSingleNode(root, "/updatedLabel")));
}


//-----------------------------------------------------------------
//Function updateCountAndRefreshTree()
//-----------------------------------------------------------------
//
// DESCRIPTION
//      This function updates All Parent object labels and refreshes the trees
//
// PARAMETERS
//      appDirectory (String)   - The appDirectory e.g.documentCentral
//      openerObj (String)      - the opener object from where current operation is performed
//      parentOIDs (String)     - The parent OID of the objects to be modified
// RETURNS
//      (nothing)
//-----------------------------------------------------------------
function updateCountAndRefreshTree(appDirectory,openerObj,parentOIDs)
{
    var objectIds   = getObjectsToBeModified(openerObj,parentOIDs);
    
    for(var objectId in objectIds) {
    
        var updatedLabel    = getUpdatedLabel(appDirectory,objectId,openerObj);
    
        openerObj.changeObjectLabelInTree(objectId, updatedLabel, true, false, false);
    }
}


//-----------------------------------------------------------------
//Function addMultipleStructureNodes()
//-----------------------------------------------------------------
//
// DESCRIPTION
//      This function adds multiple structure nodes to tree
//
// PARAMETERS
//      objectIds (String)      - The OID of the object to be added
//      parentOId (String)      - The parent ID of the object under which the object should be added
//      appDirectory (String)   - The appDirectory e.g.documentCentral
//      openerObj (String)      - the opener object from where current operation is performed
// RETURNS
//      (nothing)
//-----------------------------------------------------------------
/*
*@deprecated addMultipleStructureNodes() 
*This method is intended to be used to add multiple nodes but it is  taking only one objectId in the first parameter hence not serving  the purpose.
*use addStructureTreeNode() instead
*/

function addMultipleStructureNodes(objectIds, parentOId, appDirectory,openerObj)
{
	console.log("addMultipleStructureNodes() is deprecated .Use addStructureTreeNode() !!!");
    if(openerObj.objStructureTree) {
         openerObj.objDetailsTree.doNavigate  = true;
         getTopWindow().objStructureFancyTree.addChild(parentOId, objectIds);
    }
}
