/*!================================================================
 *  JavaScript Details Tree
 *  emxUIDetailsTree.js
 *  Version 2.0
 *  Requires: emxUIConstants.js, emxUIHistoryTree.js
 *  Last Updated: 25-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definitions for the details tree
 *  navigator.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIDetailsTree.js.rca 1.19 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
 *=================================================================
 */
var DETAILS_TREE = new Object;
DETAILS_TREE.IMG_REMOVE = DIR_IMAGES + "utilDetailsTreeRemove.gif";
DETAILS_TREE.IMG_UP = DIR_IMAGES + "utilDetailsTreeUp.gif";
DETAILS_TREE.IMG_BACK = DIR_IMAGES + "utilDetailsTreeBack.gif";
DETAILS_TREE.ICON_CATEGORY = "iconSmallCategory.gif";

//! Class emxUIDetailsTree
//!     This class represents a structure navigation tree.
function emxUIDetailsTree() {
        this.superclass = emxUIHistoryTree;
        this.superclass("emxUIDetailsTree");
        delete this.superclass;
        this.className = "emxUIDetailsTree";
        this.stylesheet = getStyleSheet("emxUIDetailsTree");
        this.target = "detailsDisplay";
}
emxUIDetailsTree.prototype = new emxUIHistoryTree;
//! Protected Method emxUIDetailsTree.clear()
//!     This method clears the tree of all data.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIDetailsTree.prototype.emxUIHistoryTreeClear = emxUIDetailsTree.prototype.clear;
emxUIDetailsTree.prototype.clear = function _emxUIDetailsTree_clear() {
        this.emxUIHistoryTreeClear();
        this.scopeID = null;
};
//! Private Method emxUIDetailsTree.draw()
//!     This method draws the tree onto the display frame. This
//!     method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIDetailsTree.prototype.draw = function _emxUIDetailsTree_draw() {
        var d = new jsDocument;
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.id]) ? "getTopWindow()" : "parent";
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body onload=\"" + strLoc + ".trees['" + this.id + "'].setScrollPosition()\">");
        d.write("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"105%\">");
        d.write(this.currentRoot.getHTML());
        d.write("</table>");
        d.write("<div name=\"");
        d.write(this.getSelectedNode().path);
        d.write("\" style=\"visibility: hidden; display: none\" />");
        d.writeHTMLFooter();
        with (this.displayFrame.document) {
                open();
                write(d);
                close();
        }
        this.setScrollPosition();
        if (this.doNavigate && this.getSelectedNode().getURL() != null) { //Modified for Dynamic Categories for Tree Feature
                this.link(this.getSelectedNode().getURL(), this.target);
                this.doNavigate = false;
        }
};
//! Private Method emxUIDetailsTree.importObject()
//!     This method imports an object into the tree. It determines
//!     if the object already exists in the tree, and adds
//!     this node to the list of nodes representing this object.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIDetailsTree.prototype.emxUIHistoryTreeImportObject = emxUIDetailsTree.prototype.importObject;
emxUIDetailsTree.prototype.importObject = function _emxUIDetailsTree_importObject(objNode) {
        if (objNode.className == "emxUIObjectNode") {
                this.emxUIHistoryTreeImportObject(objNode);
        }
};
//! Class emxUIDetailsTreeNode
//!     This class represents one node on the details tree.
function emxUIDetailsTreeNode (strIcon, strText, strURL, strObjectID, strRelID, strCommandName, strExpandURL) {
        this.superclass = emxUIHistoryTreeNode;
        this.superclass(strIcon, strText, strURL, strExpandURL);
        delete this.superclass;
        this.className = "emxUIDetailsTreeNode";
        this.commandName = strCommandName;
        this.loaded = !(strExpandURL && strExpandURL.length > 0);
        this.nodeType = 0;
        this.objectID = strObjectID;
        this.relID = strRelID;
}
emxUIDetailsTreeNode.prototype = new emxUIHistoryTreeNode;
//! Protected Method emxUIDetailsTreeNode.addToHistory()
//!     This method adds the node link into the page history.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIDetailsTreeNode.prototype.addToHistory = function _emxUIDetailsTree_addToHistory() {
        if (typeof this.objectID != "string" || this.objectID == "") {
                return;
        }
        var strCommandName = "";
        var strParentName="rootnode";
        if(typeof this.commandName == "string" && this.className != "emxUIObjectNode" ){
                strCommandName = this.commandName;
                if(this.parent){
                        strParentName = this.parent.text;
                } else {
                        strParentName = this.commandName;
                }
        }
        addToPageHistory(strParentName, this.getURL(), strCommandName, this.tree.target,this.text, "tree", this.objectID)
};
//! Protected Method emxUIDetailsTreeNode.expand()
//!     This method expands the node. If the node isn
//!     a loading node and proceeds to the loadURL.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUIDetailsTreeNode.prototype.expand = function _emxUIDetailsTreeNode_expand() {
        if (!this.expanded) {
                this.expanded = true;
                if (!this.loaded) {
                        var objLoadingNode = new emxUICoreTreeNode(IMG_LOADING, emxUIConstants.STR_LOADING);
                        objLoadingNode.getConnectorImage = this.getConnectorImage;
                        objLoadingNode.getConnectorImageHTML = this.getConnectorImageHTML;
                        objLoadingNode.getMiscImagesHTML = this.getMiscImagesHTML;
                        objLoadingNode.getFunctionalIndent = this.getFunctionalIndent;
                        objLoadingNode.getHTML = this.getHTML;
                        this.addChild(objLoadingNode);
                        this.tree.refresh();
                        var strURL = addURLParam(this.loadURL, "treeID=" + this.tree.id);
                        strURL = addURLParam(strURL, "jsTreeID=" + this.nodeID);
                        this.tree.displayFrame.document.location.href = strURL;
                } else {
                        this.tree.refresh(true);
                }
        }
};
//! Private Method emxUIDetailsTreeNode.getConnectorImage()
//!     This methods returns the appropriate image for the connector.
//!     This overrides the emxUICoreTreeNode.getConnectorImage().
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIDetailsTreeNode.prototype.getConnectorImage = function _emxUIDetailsTreeNode_getConnectorImage() {
        if (!this.hasChildNodes()) {
                return IMG_SPACER;
        } else {
                if (this.expanded) {
                        return TREE.IMG_MINUS;
                } else {
                        return TREE.IMG_PLUS;
                }
        }
};
//! Private Method emxUIDetailsTreeNode.getConnectorImageHTML()
//!     This methods creates the HTML that represents the connector image
//!     (plus/minus/none). This method is considered PRIVATE and MAY NOT
//!     be used by developers.
emxUIDetailsTreeNode.prototype.getConnectorImageHTML = function _emxUIDetailsTreeNode_getConnectorImageHTML() {
        var d = new jsDocument;
        var arrChildNodes = this.getPrintableChildNodes();
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.id]) ? "getTopWindow()" : "parent";
        d.write("<td>");
        if (this.hasChildNodes()) {
                d.write("<a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].nodes['");
                d.write(this.nodeID);
                d.write("'].handleClick('connector')\">");
        }
        d.write("<img src=\"");
        d.write(this.getConnectorImage());
        d.write("\" border=\"0\" width=\"16\" height=\"16\">");
        if (this.hasChildNodes()) {
                d.write("</a>");
        }
        d.write("</td>");
        return d.toString();
};
//! Private Method emxUIDetailsTreeNode.getDuplicate()
//!     This method tries to find a duplicate node and return it.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIDetailsTreeNode.prototype.getDuplicate = function _emxUIDetailsTreeNode_getDuplicate(objNode) {
        var objDupNode = null;
        if (objNode.className == "emxUIObjectNode") {
                for (var i=0; i < this.childNodes.length && !objDupNode; i++) {
                        if (this.childNodes[i].text == objNode.text && this.childNodes[i].relID == objNode.relID
                                && this.childNodes[i].objectID == objNode.objectID) {
                                objDupNode = this.childNodes[i];
                        }
                }
        } else {
                for (var i=0; i < this.childNodes.length && !objDupNode; i++) {
                        if (this.childNodes[i].text == objNode.text) {
                                objDupNode = this.childNodes[i];
                        }
                }
        }
        return objDupNode;
};
//! Private Method emxUIDetailsTreeNode.getHTML()
//!     This method creates the HTML that represents the node.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUIDetailsTreeNode.prototype.getHTML = function _emxUIDetailsTreeNode_getHTML() {
        var d = new jsDocument;
        var strCSSClass = (this.tree.getSelectedNode() == this) ? "selected" : "";
        d.write("<tr class=\"");
        d.write(strCSSClass);
        d.write("\"><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td></tr>");
        d.write("<tr class=\"");
        d.write(strCSSClass);
        d.write("\"><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"6\" /></td><td>");
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        if (this.getFunctionalIndent() > 0) {
                d.write(this.getMiscImagesHTML());
                d.write(this.getConnectorImageHTML());
        }
        d.write(this.getNodeHTML());
        d.write("</tr></table>");
        d.write("</td></tr>");
        d.write("<tr class=\"");
        d.write(strCSSClass);
        d.write("\"><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td></tr>");
        d.write("<tr class=\"darkBorder\"><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td></tr>");
        d.write("<tr class=\"lightBorder\"><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"5\" /></td><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" border=\"0\" height=\"1\" width=\"1\" /></td></tr>");
        d.write(this.getChildNodesHTML());
        return d.toString();
};
//! Private Method emxUIDetailsTreeNode.getMiscImagesHTML()
//!     This method creates the HTML that represents the "misc" images for
//!     the node. This method is considered PRIVATE and MAY NOT be
//!     used by developers.
emxUIDetailsTreeNode.prototype.getMiscImagesHTML = function _emxUIDetailsTreeNode_getMiscImagesHTML() {
        var strReturn="", strTemp="";
        var objCur = this, objParent = this.parent;
        var i=0;
        if (this.getFunctionalIndent() < 2) {
                return;
        }
         while (i < this.getFunctionalIndent() - 1) {
                strTemp = "<td class=\"node\"><img src=\"";
                strTemp += IMG_SPACER;
                strTemp += "\" width=\"19\" height=\"19\" border=\"0\"></td>";
                objCur = objParent;
                objParent = objParent.parent;
                i++;
                strReturn = strTemp + strReturn;
        }
        return strReturn;
};
//! Deprecated Public Method emxUIDetailsTreeNode.getName()
//!     This methods returns the text for the node.
//!     Deprecated. This method is considered DEPRECATED and
//!     should not be used. This is maintained for backwards compatibility
//!     only.
emxUIDetailsTreeNode.prototype.getName = function _emxUIDetailsTreeNode_getName() {
        return this.text;
};
//! Private Method emxUIDetailsTreeNode.handleClick()
//!     This methods handles the onclick event for this node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUIDetailsTreeNode.prototype.emxUIHistoryTreeNodeHandleClick = emxUIDetailsTreeNode.prototype.handleClick;
emxUIDetailsTreeNode.prototype.handleClick = function _emxUIDetailsTreeNode_handleClick(strTarget) {
        switch(strTarget) {
                case "node":
                        this.addToHistory();
                        this.tree.link(this.getURL(), this.tree.target);
                        this.tree.setSelectedNode(this, true);
                        break;
                case "connector":
                       // commented for bug IR-023972V6R2011x
                       // this.tree.setSelectedNode(this, false);
                       // this.tree.doNavigate = (typeof this.url == "string" && this.url != "");
                default:
                        this.emxUIHistoryTreeNodeHandleClick(strTarget);
                        break;
        }
};
//! Public Method emxUIDetailsTreeNode.removeChild()
//!     This method removes a child from the current node. This
//!     method is considered PUBLIC and MAY be used by developers.
emxUIDetailsTreeNode.prototype.removeChild = function _emxUIDetailsTreeNode_removeChild(strObjectID, blnRefresh) {
        var objNode = null;
        for (var i=0; i < this.childNodes.length && !objNode; i++) {
                if (this.childNodes[i].className == "emxUIObjectNode" && this.childNodes[i].objectID == strObjectID) {
                        objNode = this.childNodes[i];
                }
        }
        if (objNode) {
                this.removeChildByID(objNode.nodeID, blnRefresh);
        }
};
//! Public Method emxUIDetailsTreeNode.removeChildByID()
//!     This methods removes a child from the current node. This
//!     method is considered PUBLIC and MAY be used by developers.
emxUIDetailsTreeNode.prototype.removeChildByID = function _emxUIDetailsTreeNode_removeChildByID(strNodeID, blnRefresh) {
        var objNode = this.tree.nodes[strNodeID];
        if (objNode) {
                if (objNode == this.tree.getSelectedNode() || this.descendantSelected(objNode,this.tree.getSelectedNode())) {  //Modified for Dynamic Categories for Tree Feature
                        this.tree.setSelectedNode(objNode.parent, false);
                        this.tree.doNavigate = true;
                }
                this.childNodes.remove(objNode);
                this.tree.nodes.remove(objNode);
                this.tree.nodes[strNodeID] = null;
                if (objNode.className == "emxUIObjectNode") {
                        var objObject = this.tree.objects[objNode.objectID];
                        objObject.nodes.remove(objNode);
                        if (objObject.nodes.length == 0) {
                                this.tree.deleteObject(objNode.objectID);
                        }
                }
                if (blnRefresh) {
                        this.tree.refresh(true);
                }
        }
};
//! Deprecated Public Method emxUIDetailsTreeNode.setObjectId()
//!     This method changes the object ID of the object that this
//!     node represents and then refreshes the page. Deprecated.
//!     This method is considered DEPRECATED and  should not be used.
//!     This is maintained for backwards compatibility only.
emxUIDetailsTreeNode.prototype.setObjectID = emxUIDetailsTreeNode.prototype.setObjectId = function _emxUIDetailsTreeNode_setObjectID(strObjectID) {
        this.tree.objects[this.objectID].changeID(strObjectID, false);
};


//TMRF-Tree Menu Revision Filter
//! Class emxUIObjectNode[Overloaded]
//!      This class represents one object node on the details tree.
function emxUIObjectNode(strIcon, strText, strURL, strObjectID, strRelID,strExpandURL,blnRev,showRev,iconText) {
        this.superclass = emxUIDetailsTreeNode;
        this.superclass(strIcon, strText, strURL, strObjectID, strRelID, strExpandURL);
        delete this.superclass;
        this.className = "emxUIObjectNode";
        this.cssClass = "object";
        this.nodeType = 1;
        //TMRF- Tree Menu Revision Filter
        this.strObjectID = strObjectID;
        this.blnRev = blnRev;
        this.showRev = showRev;
        this.iconText= iconText;
}

emxUIObjectNode.prototype = new emxUIDetailsTreeNode;
//! Private Method emxUIObjectNode.getNodeHTML()
//!     This methods creates the HTML that represents the node part (icon
//!     and text only). This method is considered PRIVATE and MAY NOT
//!     be used by developers.
emxUIObjectNode.prototype.emxUIDetailsTreeNodeGetNodeHTML = emxUIObjectNode.prototype.getNodeHTML;
emxUIObjectNode.prototype.getNodeHTML = function _emxUIObjectNode_getNodeHTML() {
        var d = new jsDocument;
        d.write(this.emxUIDetailsTreeNodeGetNodeHTML());
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.tree.id]) ? "getTopWindow()" : "parent";
        //Modified For Bug : 348007
        //Tree Menu Revision Filter feature
            if(this.blnRev == 'true' && this.showRev == 'Enable')
            {
            	var forroot = this == this.tree.currentRoot;
        		d.write("<td nowrap=\"nowrap\"><a href=\"#\" onclick=\""+ strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].dropDownMenu(event,'"+this.strObjectID+"','"+forroot+"');")
                d.write("return false\" class=\"revFilter\" >");
                d.write("<div class=\"revFilter\">"+this.iconText+"</div>");
                d.write("</a></td>");
            }
        //End for Tree Menu Revision Filter
        if (this != this.tree.currentRoot) {
                d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].setCurrentRoot('");
                d.write(this.nodeID);
                d.write("', true);\"><img src=\"");
                d.write(DETAILS_TREE.IMG_UP);
                d.write("\" border=\"0\" /></a><a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].nodes['");
                d.write(this.parent.nodeID);
                d.write("'].removeChildByID('");
                d.write(this.nodeID);
                d.write("', true);\"><img src=\"");
                d.write(DETAILS_TREE.IMG_REMOVE);
                d.write("\" border=\"0\" /></a></td>");
        } else if (this.tree.history.length > 0){
                d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].back()\"><img src=\"");
                d.write(DETAILS_TREE.IMG_BACK);
                d.write("\" border=\"0\" /></a></td>");
        }
        return d.toString();
};

//added for bug 344195
emxUIObjectNode.prototype.setRevisionFilter = function _emxUIObjectNode_setRevisionFilter(blnRev) {
	this.blnRev = blnRev;
	this.tree.refresh(true);
}

//! Class emxUICategoryNode
//!     This class represents one object node on the details tree.
function emxUICategoryNode(strText, strURL, strObjectID, strRelID, strCommandName, strExpandURL) {
        this.superclass = emxUIDetailsTreeNode;
        this.superclass(DETAILS_TREE.ICON_CATEGORY, strText, strURL, strObjectID, strRelID, strCommandName, strExpandURL);
        delete this.superclass;
        this.className = "emxUICategoryNode";
        this.cssClass = "category";
        this.nodeType = 2;
}
emxUICategoryNode.prototype = new emxUIDetailsTreeNode;
//! Private Method emxUICategoryNode.handleClick()
//!     This method handles the onclick event for this node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICategoryNode.prototype.emxUIDetailsTreeNodeHandleClick = emxUICategoryNode.prototype.handleClick;
emxUICategoryNode.prototype.handleClick = function (strTarget) {
        switch(strTarget) {
                case "node":
                        if (typeof this.url != "string" || this.url == "") {
                                this.emxUIDetailsTreeNodeHandleClick("connector");
        	        } else {
                                this.emxUIDetailsTreeNodeHandleClick(strTarget);
        	        }
                        break;
                default:
                        this.emxUIDetailsTreeNodeHandleClick(strTarget);
                        break;
        }
};
//! Private Function listLinkClick()
//!     This method is the event handler for clicking on a link in a
//!     list. It handles adding a new node to the tree, gettings its children,
//!     the navigation and the highlighting of the new item. This function is
//!     considered PRIVATE and MAY NOT be used by developers.
function listLinkClick( strIcon, strName, strURL, strObjectID, strRelID, strExpandURL) {
        var objDetailsTree = getTopWindow().objDetailsTree;
        var objParent = objDetailsTree.getSelectedNode();
        for (var i=0; i < objParent.childNodes.length; i++) {
                objParent.childNodes[i].expanded = false;
        }
        var wTop = getTopWindow();
        var objChild = objParent.addChild(new wTop.emxUIObjectNode(strIcon, strName, strURL, strObjectID, strRelID, strExpandURL));
        objParent.expanded = true;
        objChild.expanded = true;
        objDetailsTree.doNavigate = true;
        objDetailsTree.selectedID = objChild.nodeID;
        strURL = getTopWindow().addURLParam(strExpandURL, "jsTreeID=" + objChild.nodeID);
        objDetailsTree.displayFrame.document.location.href = strURL;
}
//! Private Function addToPageHistory()
//!     This function submits to a hidden frame which add item to session.
//!     This function is considered PRIVATE and MAY NOT be used by developers.
function addToPageHistory(strTitle,strURL,strCommand,strTarget,strCommandTitle,strLinkType,strObjectID) {
        var strTarget="content";
        // This piece of code is commented to fix the bug 355748
        /*if(!isIE){
           strTitle=escape(strTitle);
         }*/
        strCommandTitle=encodeURIComponent(strCommandTitle);
        strTitle=encodeURIComponent(strTitle);
        var strFinalURL = "emxPageHistoryProcess.jsp?xmlRpc=true&pageURL="+escape(strURL)+"&AppName="+strTitle+"&commandName="+escape(strCommand)+"&targetLocation="+escape(strTarget)+"&CommandTitle="+strCommandTitle+"&linkType="+escape(strLinkType);
       	var oXMLHTTP = emxUICore.createHttpRequest();
		oXMLHTTP.open("get", strFinalURL, false);
	    oXMLHTTP.send(null);
		var func = eval( "(" + oXMLHTTP.responseText + ")");
	    func.run();
}
