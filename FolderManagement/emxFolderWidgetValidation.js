//=================================================================
// JavaScript emxFolderWidgetValidation.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// emxUIFormValidation.js
// This file is used to add any validation routines to be used by the UIForm component
//-----------------------------------------------------------------

/*What needs to be DONE if user clicks on the Fnacy tree nodes
 * Logic can needs to modified in the same METHOD and customize
 * */

var lastVisitedPage = "";
function fancyTreeNodeClick(objectId,relId,type,actionType,parentNodeID,parentNoderelID){

	if(actionType == undefined){
		unSelectOtherTreeNodes(objectId);//To Select the NODE if selected in other TREE
	}

	var urlToOpen;
	var urlTemp;
	if (window.calledFromSearch) {
		urlTemp = "../common/";
	} else {
		urlTemp = "../../common/";
	}

	var frameHandle = emxUICore.findFrame(getTopWindow(),'WorkspaceContent');
	if(actionType!= "undefined" && (actionType=="rename" || actionType=="delete" || actionType=="create" || actionType=="move")
			&& type!="Workspace" && type!="Personal Workspace"){
			var oXM = emxUICore.findFrame(getTopWindow(),'WorkspaceContent').sbPage.oXML;
			if(actionType == "rename"){
				frameHandle.emxEditableTable.refreshStructureWithOutSort();
			}else if(actionType == "create"){
				var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '"+parentNodeID+"' or @r ='"+parentNoderelID+"']");
				if(rowID){
					var selectSBrows = [];selectSBrows.push(rowID.getAttribute('id'));
					var strXml="<mxRoot><action>add</action><data status='committed'><item oid='"+objectId+"' relId='"+relId+"' pid='"+parentNodeID+"'/></data></mxRoot>";
					frameHandle.emxEditableTable.addToSelected(strXml,selectSBrows);
				}
			}else if(actionType == "move"){
				return;
			}
			else{
				var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '"+objectId+"' and @r ='"+relId+"']");
				if(rowID!= null && rowID != "undefined"){
					var completeID =[];
					completeID.push("|||"+rowID.getAttribute('id'));
					frameHandle.emxEditableTable.removeRowsSelected(completeID);
				}else{
					rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '"+objectId+"']");
					if(rowID!= null && rowID != "undefined" && rowID.getAttribute("id")=="0"){
						frameHandle.location.href = "../../common/emxBlank.jsp";
						lastVisitedPage = "blank";
					}
				}
			}
		return;
	}else if(type!="undefined" && (type=="Workspace" || type=="Personal Workspace") ){
		if(type=="Workspace"){
			urlToOpen =urlTemp+ "emxForm.jsp?workspaceId="+objectId+"&"+
			"objectId="+objectId+"&form=type_Workspace&mode=view&toolbar=FMAWorkspaceDetailsToolBar&showDropHeader=true";
			lastVisitedPage = "form";
		}else if(type=="Personal Workspace" ){
			urlToOpen =urlTemp+ "emxForm.jsp?objectId="+objectId + "&form=AEFDynamicAttributesForm&showDropHeader=true";
			lastVisitedPage = "form";
		}

		if(actionType == "delete" && frameHandle.location.href.indexOf("objectId="+objectId)){
			urlToOpen =urlTemp+ "emxBlank.jsp";
			lastVisitedPage = "blank";
		}
		if(actionType == "deleteAndShowBlank"){
			urlToOpen =urlTemp+ "emxBlank.jsp";
			lastVisitedPage = "blank";
		}
	}else{
		if(frameHandle.emxEditableTable && lastVisitedPage =="SB" && actionType != "deleteAndShowBlank"){
			frameHandle.turnOnProgress();
			setTimeout(function(){loadDataWithProgress(frameHandle,objectId);},10);

			lastVisitedPage = "SB";
			return;
		}else{
			urlToOpen =urlTemp+  "emxIndentedTable.jsp?expandProgramMenu=FMAFolderContentProgramMenu&portalMode=true&showChannelNavigation=true&showDropHeader=true&selectHandler=crossHL3dplay&afterExpandJS=setIconHideShow&table=FMAContentSummary&header=emxFolderManagement.Name.Content&"+
			"freezePane=Name&toolbar=FolderContentActions&selection=multiple&" +
			"HelpMarker=emxhelpfoldercontent&parentRelName=relationship_VaultedDocuments&" +
			"FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&emxSuiteDirectory=FolderManagement" +
			"&suiteKey=FolderManagement&StringResourceFileId=enoFolderManagementStringResource&massPromoteDemote=false&objectCompare=false&SuiteDirectory=FolderManagement&emxSuiteDirectory=FolderManagement&objectId="+objectId+"&relId="+relId;
			lastVisitedPage = "SB";
		}

		if(actionType == "deleteAndShowBlank"){
			urlToOpen =urlTemp+ "emxBlank.jsp";
			lastVisitedPage = "blank";
		}
	}
	frameHandle.location.href = urlToOpen;
}


function contains(arr, str){
	for(var j = 0; j < arr.length; j++){
		if(arr[j]  == str ){
			return true;
		}
	}
	return false;
}
//Validation of proper Drag TYPEs  wsDragTypes; fdDragTypes;
/* draggedTYpe- dragged object Type
 * droppedType -dropped object Type
 * hidealert - hiding the alert from validations
 * fromoutside - is it from OUTSIDE Fancy tree
 * Logic can needs to modified in the same METHOD and customize
 * */
function dndValidation(draggedType, droppedType, hidealert, fromOutSide){
	if(fromOutSide){
		var fddragArr = fdDragTypes.split(",");
		var wsdragArr = wsDragTypes.split(",");
		var droppedNodes = droppedType;
		if(draggedType == "Workspace Vault"){
			for(var j = 0; j < droppedNodes.objects.length; j++){
				if(!contains(fddragArr, droppedNodes.objects[j].type)){
					if(!hidealert) {
						getTopWindow().showTransientMessage(emxUIConstants.DND_TYPE_VALIDATION);
					}
	    			return false;
	    		}
			}
		}
		if(draggedType == "Workspace"){
			for(var j = 0; j < droppedNodes.objects.length; j++){
				if(!contains(wsdragArr, droppedNodes.objects[j].type)){
					if(!hidealert) {
						getTopWindow().showTransientMessage(emxUIConstants.DND_TYPE_VALIDATION);
					}
	    			return false;
	    		}
			}
		}
		return true;
	} else {
		if(draggedType=="Workspace Folder"){
			if(fdDragTypes.indexOf(droppedType)<=0){
				if(!hidealert) {
					getTopWindow().showTransientMessage(emxUIConstants.DND_TYPE_VALIDATION);
				}
				return false;
			}
		}
		if(draggedType=="Workspace"){
			if(wsDragTypes.indexOf(droppedType)<=0){
				if(!hidealert) {
					getTopWindow().showTransientMessage(emxUIConstants.DND_TYPE_VALIDATION);
				}
				return false;
			}
		}else{
			return true;
		}
	}
}


/*Validation method called on Create RMB menu
 * mode wil be rename or create
 * value the user key-in Value   TYpe - object Type   mode- mode of action rename/create/delete  nodeDteails- FT node*/
function createORRenameValidation(value,type,mode,nodeDetails){
	var arrayBadChar = "", badCharacters ="";
	if (emxUIConstants.FW_NAMEBADCHARS != ""){
		arrayBadChar = emxUIConstants.FW_NAMEBADCHARS.split(" ");
	}
	for (var i=0; i < arrayBadChar.length; i++) {
		if (value.indexOf(arrayBadChar[i]) > -1) {
			badCharacters += arrayBadChar[i] + " ";
		}
	}
	if(badCharacters.length != 0) {
		alert(emxUIConstants.FW_ALERT_FILENAMEBADCHARS + badCharacters);
		return false;
	}
	return true;
}

/*isRefreshContentNeeded method
 * To check if the content page refresh is Needed OR not*/
function isRefreshContentNeeded(node){
	if(node.isActive()){
		return node;
	}else{
		if(node.parent.key.indexOf("root_") != 0){
			var res = isRefreshContentNeeded(node.parent);
			if(res!= false && res != undefined && res.data.type != "Workspace" && res.data.type != "Personal Workspace")
				return res;
			else
				return false;

		}
	}
}


/*To get parent node type for validation
 * node :current node*
 * returns parent node type*/
function classificationDnDValidation(node){
    if(node.parent.key.indexOf("root_") != 0){
          return classificationDnDValidation(node.parent);
    }else{
          return node.data.type;
    }
}

/*To remove NOde from /Add node to Fancy tree from OUTSIDE TREE
 * KEYID is object ID *
 * Action will be add/remove/renamed*/

function deleteNodesFromFancyTree(keyID,action){
	var tree;
	for(var k=0;k<2;k++){
		if(k == 0){
			tree = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree').fancytree("getTree");
		}
		if(tree!=null){
			for(var b=0; b<keyID.length; b++){
				var ftNode = tree.getNodeByKey(keyID[b]);
				if(ftNode){
					if(action=="delete"){
						ftNode.remove();
					}
					if(action=="create"){
						//DO we need to refresh the complete Fancy tree??
					}
				}
			}
		}
	}
}



/* Method to select the lasy selection if it is in DIFFERENT TREE
 *
 */
function unSelectOtherTreeNodes(key){
	var tree = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree').fancytree("getTree");
	var lastFocused = localStorage.getItem('ft-active');
	if(tree.getNodeByKey(lastFocused)){
		tree.getNodeByKey(lastFocused).setActive(false);
		tree.getNodeByKey(lastFocused).setFocus(false);
	}
}


/* Method to select Node in the Fancy tree when user selects that in SB
*
*/
function selectNodeInTree(key){
	var treeFrame = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree');
	var tree = treeFrame.fancytree("getTree");

	var nodeItem;
	if(tree.getNodeByKey(key)){
		tree.getNodeByKey(key).setActive(true);
		tree.getNodeByKey(key).setFocus(true);
		nodeItem = tree.getNodeByKey(key);
		//Scroll that Node into the View
		jQuery(emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders')).scrollTop(nodeItem.span.offsetTop);
	}

}


/* Method to retunr of the NODE if we pass teh KEY if it is in DIFFERENT TREE
*
*/
function returnName(key){
	var tree = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree').fancytree("getTree");

	if(tree.getNodeByKey(key)){
		return tree.getNodeByKey(key).title;
	}

}

/* TO show the Progress indicator and change the Header of SB while refreshing the content
 * frameHandle the SB frame Handle
 * ObjectID to make as ROOT Node
 * select Nodes select the same OBject on teh FOLDER layout
 * */
function loadDataWithProgress(frameHandle,objectID,selectNodes) {
	if(!frameHandle)
		frameHandle = emxUICore.findFrame(getTopWindow(),'WorkspaceContent');

	var oXM = frameHandle.sbPage.oXML;
	var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '"+objectID+"']");
	if(rowID && selectNodes && rowID.getAttribute("id")=='0'){
		return;
	}

	/*frameHandle.$('#emxTableFormSB').attr('style','display:none;');
	frameHandle.$('#FancyTree-loading').attr('style','display:block;');*/
	frameHandle.editableTable.loadData("",objectID);

	var cVal = $(frameHandle.$.find(".page-title h2")).text();
	var temp = cVal.split(":");
	$(frameHandle.$.find(".page-title h2")).text(cVal.replace(temp[0],returnName(objectID))) ;

	if(selectNodes){
		selectNodeInTree(objectID);
	}
}

