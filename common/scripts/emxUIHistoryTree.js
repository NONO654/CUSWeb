/*!================================================================
 *  JavaScript History Tree
 *  emxUIHistoryTree.js
 *  Version 1.0
 *  Requires: emxUIConstants.js, emxUICoreTree.js
 *  Last Updated: 15-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definitions for a tree that
 *  can change its root and keeps track of the changes made
 *  to the root.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIHistoryTree.js.rca 1.15 Tue Oct 28 22:59:39 2008 przemek Experimental przemek $
 *=================================================================
 */
//! Class emxUIHistoryTree
//!     This class represents a structure navigation tree that has
//!     "there" and "back" functionality.
function emxUIHistoryTree(strID) {
        this.superclass = emxUICoreTree;
        this.superclass(strID);
        delete this.superclass;
        this.className = "emxUIHistoryTree";
        this.currentRoot = null;
        this.history = new Array;
        this.objects = new Array;
        this.processing = false;
        this.selectedID = "root";
        this.stylesheet = DIR_STYLES + "emxUITree.css";
        this.doNavigate = true;
        this.showIcons = true;
}
emxUIHistoryTree.prototype = new emxUICoreTree;
//! Protected Method emxUIHistoryTree.back()
//!     This method causes the previous root to become the current
//!     root. This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTree.prototype.back = function _emxUIHistoryTree_back(blnDoNavigate) {
        var objRoot = this.history.pop();
        this.setCurrentRoot(objRoot, true, true, blnDoNavigate);
};
//! Protected Method emxUIHistoryTree.clear()
//!     This method clears the tree of all data.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTree.prototype.clear = function _emxUIHistoryTree_clear() {
        this.history = new Array;
        this.nodes = new Array;
        this.selectedID = "root";
        this.doNavigate = true;
        this.objects = new Array;
};
//! Protected Method emxUIHistoryTree.createRoot()
//!     This method sets a node as the root of the tree.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTree.prototype.emxUICoreTreeCreateRoot = emxUIHistoryTree.prototype.createRoot;
emxUIHistoryTree.prototype.createRoot = function _emxUIHistoryTree_createRoot(objNode) {
        this.emxUICoreTreeCreateRoot(objNode);
        this.currentRoot = this.root;
        this.objects = new Array;
        this.importObject(objNode);
        objNode.commandName = "rootnode";
};
//! Public Method emxUIHistoryTree.deleteObject()
//!     This method deletes an object and all of its nodes from the
//!     tree. This method is considered PUBLIC and may be used by
//!     developers.
emxUIHistoryTree.prototype.deleteObject = function _emxUIHistoryTree_deleteObject(strObjectID, blnRefresh) {
        var objObject = this.objects[strObjectID];
        if (objObject) {
                objObject.nodes.sort(compareNodesByIndent);
                for (var i=objObject.nodes.length -1; i >= 0; i--) {

                      if(objObject.nodes[i].parent != null){
                        objObject.nodes[i].parent.removeChildByID(objObject.nodes[i].nodeID, false);
                       }
                }
                this.objects.remove(objObject);
                this.objects[strObjectID] = null;
                if (blnRefresh == null || blnRefresh) {
                        this.doNavigate = true;
                        this.refresh(true);
                }
        }
        if(getTopWindow().bclist){
        	getTopWindow().bclist.remove(strObjectID);
        }
};
//! Private Method emxUIHistoryTree.draw()
//!     This method draws the tree onto the display frame. This method
//!     is considered PRIVATE and MAY NOT be used by developers.
emxUIHistoryTree.prototype.draw = function _emxUIHistoryTree_draw() {
        var d = new jsDocument;
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.id]) ? "getTopWindow()" : "parent";
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body oncontextmenu='return false;' class=\"structure-navigator\" onload=\"" + strLoc + ".trees['" + this.id + "'].setScrollPosition()\">");
        if(this.currentRoot){
            d.write(this.currentRoot.getHTML());
        }
        d.writeHTMLFooter();
        if(this.displayFrame) {
            with (this.displayFrame.document) {
                    open();
                    write(d);
                    close();
            }
        }
        this.setScrollPosition();
        if (this.doNavigate && this.getSelectedNode() != null && this.getSelectedNode().getURL() != null) {
				/*Modified for Dynamic Categories for Tree Feature*/
                this.link(this.getSelectedNode().getURL(), this.getSelectedNode().target);
                this.doNavigate = false;
        }
};
//! Public Method emxUIHistoryTree.getCurrentRoot()
//!     This method returns the current root node. This method
//!     is considered PUBLIC and may be used by developers.
emxUIHistoryTree.prototype.getCurrentRoot = function _emxUIHistoryTree_getCurrentRoot() {
        return this.currentRoot;
};
//! Public Method emxUIHistoryTree.findNodeByObjectID()
//!     This method finds the first node with a given object ID.
//!     This method is considered PUBLIC and MAY be used
//!     by developers.
emxUIHistoryTree.prototype.findNodeByObjectID = function _emxUIHistoryTree_findNodeByObjectID(strObjectID) {
	var objObject = this.objects[strObjectID];
	return (objObject ? objObject.nodes[0] : null);
};
//! Public Method emxUIHistoryTree.getObject()
//!     This method gets the object with the given object ID.
//!     This method is considered PUBLIC and MAY be used
//!     by developers.
emxUIHistoryTree.prototype.getObject = function _emxUIHistoryTree_getObject(strObjectID) {
	return this.objects[strObjectID];
};
//! Public Method emxUIHistoryTree.getOriginalRoot()
//!     This method returns the original root node. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUIHistoryTree.prototype.getOriginalRoot = function _emxUIHistoryTree_getOriginalRoot() {
        return this.root;
};
//! Public Method emxUIHistoryTree.getSelectedNode()
//!     This method returns the currently selected node. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUIHistoryTree.prototype.getSelectedNode = function _emxUIHistoryTree_getSelectedNode() {
        return this.selectedID != null ? this.nodes[this.selectedID] : null;
};
//! Private Method emxUIHistoryTree.getSelectedPathHTML()
//!     This method gets the HTML that outputs the path of the selected
//!     node. This is an addition for the automation of testing. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUIHistoryTree.prototype.getSelectedPathHTML = function _emxUIHistoryTree_getSelectedPathHTML() {
        var d = new jsDocument;
        d.write("<input type=\"hidden\" value=\"");
        d.write(this.getSelectedNode().path);
        d.write("\" />");
        return d.toString();
};
//! Public Method emxUIHistoryTree.hasObject()
//!     This method determines the object with the given object ID
//!     exists. This method is considered PUBLIC and MAY be used
//!     by developers.
emxUIHistoryTree.prototype.hasObject = function _emxUIHistoryTree_hasObject(strObjectID) {
	return !!this.objects[strObjectID];
};
//! Private Method emxUIHistoryTree.importObject()
//!     This method imports an object into the tree. It determines
//!     if the object already exists in the tree, and adds
//!     this node to the list of nodes representing this object.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIHistoryTree.prototype.importObject = function _emxUIHistoryTree_importObject(objNode) {
        var objObject = this.objects[objNode.objectID];
        if (!objObject) {
                objObject = new emxUIBusObject(objNode.icon, objNode.text, objNode.objectID);
                this.objects.push(objObject);
                this.objects[objNode.objectID] = objObject;
        }
        objObject.nodes.push(objNode);
};
//! Protected Method emxUIHistoryTree.setCurrentRoot()
//!     This method sets a node to be the current root.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTree.prototype.setCurrentRoot = function _enxUIHistoryTree_setCurrentRoot(objNode, blnRefresh, blnNoHistory, blnDoNavigate) {
        if (!this.processing) {
                if (typeof objNode == "string") {
                        objNode = this.nodes[objNode];
                }
                if (!blnNoHistory){
                        this.history.push(this.currentRoot);
                }
                this.currentRoot = objNode;
                this.setSelectedNode(objNode);
                this.currentRoot.expanded = true;
                if (blnRefresh) {
                        this.scrollX = 0;
                        this.scrollY = 0;
                        this.doNavigate = (blnDoNavigate == null ? true : blnDoNavigate);
                        if (!objNode.loaded) {
                                objNode.load();
                        } else {
                                this.refresh();
                        }
                }
        }
};
//! Public Method emxUIHistoryTree.setSelectedNode()
//!     This method sets a node to be selected. This method
//!     is considered PUBLIC and may be used by developers.
emxUIHistoryTree.prototype.setSelectedNode = function _emxUIHistoryTree_setSelectedNode(objNode, blnRefresh) {

        if (!this.processing) {
                this.selectedID = objNode.nodeID;
                if (blnRefresh) {
                        this.refresh(true);
                }
        }
        if(objNode.structureTreeClick != null){
        	objNode.url = encodeURI(objNode.url);
        	eval(objNode.structureTreeClick);//(encodeURI(objNode)).structureTreeClick);
        }
};
//! Class emxUIHistoryTreeNode
//!     This class represents one node on the details tree.
function emxUIHistoryTreeNode (strIcon, strText, strURL, strExpandURL) {
        this.superclass = emxUICoreTreeLoadNode;
        this.superclass(strIcon, strText, (strExpandURL == "null" || strExpandURL == ""? null : strExpandURL));
        delete this.superclass;
        this.className = "emxUIHistoryTreeNode";
        this.cssClass = "";
        this.scopeIDs = new Array;
        this.url = this.fixURL(strURL);
        this.commandName = null;
        this.objectID = null;
        this.relID = null;
}
emxUIHistoryTreeNode.prototype = new emxUICoreTreeLoadNode;
//! Protected Method emxUIHistoryTreeNode.addChild()
//!     This methods adds a child node to this node.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTreeNode.prototype.addChild = function _emxUIHistoryTreeNode_addChild(objNode) {
        var objDupNode = this.getDuplicate(objNode);
        if (!objDupNode) {
                this.tree.importNode(objNode);
                this.childNodes[this.childNodes.length] = objNode;
                objNode.parent = this;
                objNode.indent = this.indent + 1;
                objNode.path = this.path + TREE.PATH_SEPARATOR + "[" + objNode.text + "]";
                if (typeof objNode.scopeIDs != "undefined") {
                        for (var i=0; i < this.scopeIDs.length; i++) {
                                objNode.scopeIDs.push(this.scopeIDs[i]);
                        }
                }
                if (typeof objNode.objectID != "undefined" && objNode.objectID != null && objNode.objectID != "") {
                        this.tree.importObject(objNode);
                }
        }
        return objDupNode || objNode;
};
//! Protected Method emxUIHistoryTreeNode.addNodeScopeID()
//!     This method adds a node scopeID to the scopeIDs array. The
//!     scopeID is in the form "name=value".
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIHistoryTreeNode.prototype.addNodeScopeID = function _emxUIHistoryTreeNode_addNodeScopeID(strParam) {
        if (strParam.length == 0) {
            return;
        }
        var arrParam = strParam.split("=");
        var strName = arrParam[0];
        var strValue = arrParam[1];
        if (this.scopeIDs.join("&").indexOf(strName + "=") > -1) {
                for (var i=0; i < this.scopeIDs.length; i++) {
                        if (this.scopeIDs[i].indexOf(strName + "=") > -1) {
                                this.scopeIDs[i] = strParam;
                        }
                }
        } else {
                this.scopeIDs.push(strParam);
        }
};
//! Public Method emxUIHistoryTreeNode.changeObjectID()
//!     This method changes the object
//!     handled by the JavaScript business object itself, so it just
//!     passes the parameter along. This method is considered PUBLIC
//!     and may be used by developers.
emxUIHistoryTreeNode.prototype.changeObjectID = function _emxUIHistoryTreeNode_changeObjectID(strObjectID, blnRefresh) {
        this.tree.objects[this.objectID].changeID(strObjectID, blnRefresh);
        if(getTopWindow().bclist){
        	getTopWindow().bclist.changeID(this.objectID, strObjectID);
        }
} ;
//! Public Method emxUIHistoryTreeNode.changeObjectName()
//!     This method changes the object
//!     handled by the JavaScript business object itself, so it just
//!     passes the parameter along. This method is considered PUBLIC
//!     and may be used be developers.
emxUIHistoryTreeNode.prototype.changeObjectName = function _emxUIHistoryTreeNode_changeObjectName(strName, blnRefresh) {
        this.tree.objects[this.objectID].changeName(strName, blnRefresh);
        if(getTopWindow().bclist){
        	getTopWindow().bclist.changeLabel(this.objectID, strName);
        }
};
//! Public Method emxUIHistoryTreeNode.changeNodeStructureTreeClick()
//!     This method changes the tree Label in the StructureTreeLinkClick attribute of the node.
//!     NodeLabel defined in the StructureTreeLinkClick attribute of the StructureTree node is replaced by the
//!		nodeLabel passed as the argument to the method.
//!     This method is considered PUBLIC and may be used be developers.
emxUIHistoryTreeNode.prototype.changeNodeStructureTreeClick = function _emxUIHistoryTreeNode_changeNodeStructureTreeClick(nodeLabel) {
	 var nodeStrucTreeClick = this.structureTreeClick;
	 var nodeSplit = this.structureTreeClick.split(",");
	 nodeLabel = "'"+nodeLabel+"'";
	 this.structureTreeClick = this.structureTreeClick.replace(nodeSplit[2],nodeLabel);
};

//! Public Method emxUIHistoryTreeNode.fixURL()
//!     This method strips the objectId and relId from a URL.
emxUIHistoryTreeNode.prototype.fixURL = function _emxUIHistoryTreeNode_fixURL(strURL) {
        if (strURL) {
                var arrURLParts = strURL.split("?");
                var strQueryString = arrURLParts[1];
                strQueryString = strQueryString.replace(new RegExp("(objectId=\[\\d\\.]*\\&?)"), "");
                strQueryString = strQueryString.replace(new RegExp("(relId=\[\\d\\.]*\\&?)"), "");
                if (strQueryString.lastIndexOf("&") == strQueryString.length-1) {
                        strQueryString = strQueryString.substring(0, strQueryString.length-1);
                }
                arrURLParts[1] = strQueryString;
                return arrURLParts.join("?");
        } else {
                return "";
        }
};
//! Private Method emxUIHistoryTreeNode.getFunctionalIndent()
//!     This methods gets the functional indent of the node, which is the
//!     node's stored indent minus the current root's indent. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUIHistoryTreeNode.prototype.getFunctionalIndent = function _emxUIHistoryTreeNode_getFunctionalIndent() {
        return this.indent - this.tree.currentRoot.indent;
};
//! Private Method emxUIHistoryTreeNode.getHTML()
//!     This method creates the HTML that represents the node.
//!     This method is considered PRIVATE and MAY NOT be used
//!     by developers.
emxUIHistoryTreeNode.prototype.getHTML = function _emxUIHistoryTreeNode_getHTML() {
        var d = new jsDocument;
        var strCSSClass = (this.tree.getSelectedNode() == this) ? "selected" : "";
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        if (this.getFunctionalIndent() > 0) {
                d.write(this.getMiscImagesHTML());
                d.write(this.getConnectorImageHTML());
        }
        d.write(this.getNodeHTML());
        d.write("</tr></table>");
        d.write(this.getChildNodesHTML());
        return d.toString();
};
//! Private Method emxUIHistoryTreeNode.getMiscImagesHTML()
//!     This methods creates the HTML that represents the "misc" images for
//!     the node. This method is considered PRIVATE and MAY NOT be used
//!     by developers.
emxUIHistoryTreeNode.prototype.getMiscImagesHTML = function _emxUIHistoryTreeNode_getMiscImagesHTML() {
        var strReturn="", strTemp="";
        var objCur = this, objParent = this.parent;
        var i=0;
        if (this.getFunctionalIndent() < 2) {
                return;
        }
        while (i < this.getFunctionalIndent() - 1) {
                strTemp = "<td class=\"node\"><img src=\"";
                if ((isLastNode(objCur) && isLastNode(objParent)) || (!isLastNode(objCur) && isLastNode(objParent))) {
                        strTemp += IMG_SPACER;
                } else {
                        strTemp += TREE.IMG_LINE_VERT;
                }
                strTemp += "\" width=\"19\" height=\"19\" border=\"0\"></td>";
                objCur = objParent;
                objParent = objParent.parent;
                i++;
                strReturn = strTemp + strReturn;
        }
        return strReturn;
};
//! Private Method emxUIHistoryTreeNode.getNodeHTML()
//!     This method creates the HTML that represents the node part (icon
//!     and text only). This method is considered PRIVATE and MAY NOT be
//!     used by developers.
emxUIHistoryTreeNode.prototype.getNodeHTML = function _emxUIHistoryTreeNode_getNodeHTML() {
        var d = new jsDocument;
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.tree.id]) ? "getTopWindow()" : "parent";
        if(this.tree.showIcons){
                d.write("<td nowrap=\"nowrap\">");
                d.write("<a onmousedown=\""+ strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].clickOnTree(event,'"+this.objectID+"')\">");
                d.write("<img src=\"");
                d.write(this.icon);
                d.write("\" border=\"0\" />");
                d.write("</a>");
                d.write("</td>");
        }
        d.write("<td nowrap=\"nowrap\" class=\"");
        d.write(this.cssClass);
        d.write("\">&nbsp;");
        d.write("<a onmousedown=\""+ strLoc + ".trees['");
        d.write(this.tree.id);
        d.write("'].clickOnTree(event,'"+this.objectID+"')\">");
        d.write(this.htmltext);
        d.writeln("</a>&nbsp;</td>");
        return d.toString();
};
//! Public Method emxUIHistoryTreeNode.getURL()
//!     This method returns the URL with node scope IDs attached.
//!     This method is considered PUBLIC and MAY be used by
//!     developers.
emxUIHistoryTreeNode.prototype.getURL = function _emxUIHistoryTreeNode_getURL() {
        var strURL = this.url;
        //Added for Dynamic Categories for Tree Feature
        if(strURL == null || strURL == "")
        	return null;
        for (var i=0; i < this.scopeIDs.length; i++) {
                strURL = addUniqueURLParam(strURL, this.scopeIDs[i]);
        }
        if (this.objectID && this.objectID != "") {
                strURL = addUniqueURLParam(strURL, "objectId=" + this.objectID);
        }
        if (this.relID && this.relID != "") {
                strURL = addUniqueURLParam(strURL, "relId=" + this.relID);
        }
        strURL = addUniqueURLParam(strURL, "jsTreeID=" + this.nodeID);
        return strURL;
};
//! Private Method emxUIHistoryTreeNode.handleClick()
//!     This method handles the onclick event for this node.
//!     This method is considered PRIVATE and MAY NOT be used
//!     by developers.
emxUIHistoryTreeNode.prototype.emxUICoreTreeNodeHandleClick = emxUIHistoryTreeNode.prototype.handleClick;
emxUIHistoryTreeNode.prototype.handleClick = function _emxUIHistoryTreeNode_handleClick(strTarget) {
        switch(strTarget) {
                case "node":
                        this.tree.link(this.getURL(), this.target);
                        this.tree.setSelectedNode(this, true);
                        var currBC = getTopWindow().bclist.getCurrentBC();
                        /*if(this.structureTreeClick == null && getTopWindow().bclist != null){
                        	getTopWindow().bclist.insertAfter(currBC.id,currBC.id,currBC.label,currBC.seperator,emxUIConstants.STR_BC_LABEL_HOME , currBC.structureURL, this.getURL());
                        }*/
                        break;
                default:
                        this.emxUICoreTreeNodeHandleClick(strTarget);
                        break;
    }
};
//! Public Method emxUIHistoryTreeNode.removeChildByID()
//!     This methods removes a child from the current node. This
//!     method is considered PUBLIC and MAY be used by developers.
emxUIHistoryTreeNode.prototype.removeChildByID = function _emxUIHistoryTreeNode_removeChildByID(strNodeID, blnRefresh) {
        var objNode = this.tree.nodes[strNodeID];
        if (objNode) {
                if (objNode == this.tree.getSelectedNode()) {
                        this.tree.setSelectedNode(objNode.parent);
                        this.tree.doNavigate = true;
                }
                this.childNodes.remove(objNode);
                this.tree.nodes.remove(objNode);
                this.tree.nodes[strNodeID] = null;
                if (blnRefresh) {
                        this.tree.refresh(true);
                }
        }
};
//! Class emxUIBusObject
//!     This class represents a business object. This class is
//!     not intended to be instantiated by a developer.
function emxUIBusObject(strIcon, strText, strObjectID) {
        this.nodes = new Array;
        this.icon = strIcon;
        this.objectID = strObjectID;
        this.text = strText;
}
//! Public Method emxUIBusObject.changeID()
//!     This method changes the ID of the object and updates all of
//!     nodes in the tree that represent the object. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUIBusObject.prototype.changeID = function _emxUIBusObject_changeID(strObjectID, blnRefresh) {
        this.nodes[0].tree.objects[this.objectID] = null;
        this.nodes[0].tree.objects[strObjectID] = this;
        this.objectID = strObjectID;
        for (var i=0; i < this.nodes.length; i++) {
                this.nodes[i].objectID = strObjectID;
        }
        this.nodes[0].tree.doNavigate = true;
        if (blnRefresh) {
                this.nodes[0].tree.refresh(true);
        }
};
//! Public Method emxUIBusObject.changeName()
//!     This method changes the name of the object and updates all of
//!     nodes in the tree that represent the object. This method is
//!     considered PUBLIC and MAY be used by developers.
emxUIBusObject.prototype.changeName = function _emxUIBusObject_changeName(strName, blnRefresh) {
        this.text = strName;
        for (var i=0; i < this.nodes.length; i++) {
                this.nodes[i].text = strName;
                if(strName){
                	this.nodes[i].htmltext = strName.htmlEncode();
                }
        }
        this.nodes[0].tree.doNavigate = true;
        if (blnRefresh) {
                this.nodes[0].tree.refresh(true);
        }
};
//! Public Method emxUIBusObject.getID()
//!     This method gets the ID of the object. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUIBusObject.prototype.getID = function _emxUIBusObject_getID() {
	return this.objectID;
};
//! Public Method emxUIBusObject.getName()
//!     This method returns the name of the object. This method is
//!     considered PUBLIC and MAY be used by developers.
emxUIBusObject.prototype.getName = function _emxUIBusObject_getName() {
	return this.text;
};

//TMRF- Tree Menu Revision Filter
emxUIHistoryTree.prototype.dropDownMenu = function _emxUIHistoryTree_dropDownMenu(e,strObjectID,forroot) {
   //Modified For Bug : 348007
   var treedisplay = emxUICore.findFrame(window,"treeDisplay");
   var oEvent = {
			clientX:emxUICore.getEvent(treedisplay).clientX,
			clientY:emxUICore.getEvent(treedisplay).clientY,
			target:emxUICore.getEvent(treedisplay).target
   };
   eval(emxUICore.getData("emxDynamicRevisionMenu.jsp?&objectId="+strObjectID+"&isforRoot="+forroot));
   objMenu.init(treedisplay,"revisionFilter");
   objMenu.show(oEvent.target, 'revisionFilterDropDown');
};
//TMRF- Tree Menu Revision Filter
emxUIHistoryTree.prototype.clickOnTree = function clickOnTree(e,oid) {
	
	var which  = emxUICore.getMouseButton(e);
	if('RIGHT' === which)
	{
	    // right click -- > do the magic
		var target = (e.srcElement)?e.srcElement:e.originalTarget;
		
		// prevent browser context-menu/RMB !
		jQuery(document).bind("contextmenu", function (e) {
			return false;
		});
		
		// fetch data from type_ Menu for the object from creating RMB menu.
		 jQuery.ajax(
						{
							url  : "../common/emxNavigatorMenu.jsp?objectId="+oid,
							type : "POST",
							data : {id : oid },
							dataType : "text",
							success : function (returndata,status,xhr)
							{
								//use the return data to render
								renderRMB(returndata,e,target);
							}
						}
					 );
	}
    else
	{
		// left click, load details display frame
    	// use handleClick function that was used before these changes.
    	nodeObj = this.findNodeByObjectID(oid);
    	nodeObj.handleClick('node');

	}
}
function renderRMB(rmbdata,e,target)
{
	rmbdata = emxUICore.trim(rmbdata);
	eval(rmbdata);
	treeRMBMenu.init();
	treeRMBMenu.isNavigatorRMB = true;
	var intx = e.clientX;
	var inty = e.clientY;
	if(target!=undefined)
		treeRMBMenu.show(target ,'right',intx,inty);
	else
		treeRMBMenu.show(e.target ,'right',intx,inty);
    e.preventDefault();
    e.stopPropagation();
}
