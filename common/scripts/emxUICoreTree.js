/*!================================================================
 *  JavaScript Core Tree
 *  emxUICoreTree.js
 *  Version 1.0
 *  Requires: emxUIConstants.js
 *
 *  This file contains class definition for the core tree.
 *  This tree is not intended to be instantiated alone, but rather
 *  is a template for other trees in the apps.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUICoreTree.js.rca 1.16 Tue Oct 28 22:59:39 2008 przemek Experimental przemek $
 *=================================================================
 */
var trees = new Array;
var TREE = new Object;
TREE.IMG_LINE_VERT = DIR_TREE + "utilTreeLineVert.gif";
TREE.IMG_LINE_LAST = DIR_TREE + "utilTreeLineLast.gif";
TREE.IMG_LINE_LAST_OPEN = DIR_TREE + "utilTreeLineLastOpen.gif";
TREE.IMG_LINE_LAST_CLOSED = DIR_TREE + "utilTreeLineLastClosed.gif";
TREE.IMG_LINE_NODE = DIR_TREE + "utilTreeLineNode.gif";
TREE.IMG_LINE_NODE_OPEN = DIR_TREE + "utilTreeLineNodeOpen.gif";
TREE.IMG_LINE_NODE_CLOSED = DIR_TREE + "utilTreeLineNodeClosed.gif";
TREE.IMG_PLUS = DIR_TREE + "utilTreePlus.gif";
TREE.IMG_MINUS = DIR_TREE + "utilTreeMinus.gif";
TREE.IMG_CHECK_ON = DIR_TREE + "utilTreeCheckOn.gif";
TREE.IMG_CHECK_OFF = DIR_TREE + "utilTreeCheckOff.gif";
TREE.IMG_CHECK_OFF_DISABLED = DIR_TREE + "utilTreeCheckOffDisabled.gif";
TREE.IMG_RADIO_ON = DIR_TREE + "utilTreeRadioOn.gif";
TREE.IMG_RADIO_OFF = DIR_TREE + "utilTreeRadioOff.gif";
TREE.IMG_RADIO_OFF_DISABLED = DIR_TREE + "utilTreeRadioOffDisabled.gif";
TREE.STYLE_SHEET = getStyleSheet("emxUITree");
TREE.PATH_SEPARATOR = "\\";
//! Class emxUICoreTree
//!     This class represents a basic tree. This class is not intended
//!     to be instantiated on its own. Rather, this is a template
//!     for other trees.
function emxUICoreTree(strID) {
        this.className = "emxUICoreTree";
        this.id = strID;
        this.nodes = new Array;
        this.scrollX = 0;
        this.scrollY = 0;
        this.stylesheet = TREE.STYLE_SHEET;
        this.displayFrame = null;
        this.root = null;
        trees[trees.length] = this;
        trees[strID] = this;
}
//! Protected Method emxUICoreTree.createRoot()
//!     This method sets a node as the root of the tree. This method
//!     is considered PROTECTED and may only be used by the framework.
//!	Developers may NOT use this method.
emxUICoreTree.prototype.createRoot = function _emxUICoreTree_createRoot(objNode) {
        this.nodes = new Array;
        objNode.nodeID = "root";
        this.importNode(objNode);
        this.root = objNode;
        objNode.path = "[RootNode]";
        this.root.expanded = true;
};
//! Private Method emxUICoreTree.draw()
//!     This method draws the tree onto the display frame. This method
//!     is considered PRIVATE and may NOT be used by developers.
emxUICoreTree.prototype.draw = function _emxUICoreTree_draw() {
        var d = new jsDocument;
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.id]) ? "getTopWindow()" : "parent";
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body onload=\"" + strLoc + ".trees['" + this.id + "'].setScrollPosition()\">");
        d.write(this.root.getHTML());
        d.writeHTMLFooter();
        with (this.displayFrame.document) {
                open();
                write(d);
                close();
        }
        this.setScrollPosition();
};
//! Public Method emxUICoreTree.findNodeByName()
//!     This method finds the first node with a given name.
//!     This method is considered PUBLIC and MAY be used
//!     by developers.
emxUICoreTree.prototype.findNodeByName = function _emxUICoreTree_findNodeByName(strName) {
        var objNode = null;
        for (var i=0; i < this.nodes.length && !objNode; i++) {
                if (this.nodes[i].text == strName) {
                        objNode = this.nodes[i];
                }
        }
        return objNode;
};
//! Public Method emxUICoreTree.findContextObjectNodeByName()
//!     This method finds the first node with a given name starting from the given node id.
//!     This method is considered PUBLIC and MAY be used
//!     by developers.
emxUICoreTree.prototype.findContextObjectNodeByName = function _emxUICoreTree_findContextObjectNodeByName(nodeID, strName) {
        var objNode = null;
        var bNodeFound = false;
        for (var i=0; i < this.nodes.length && !objNode; i++) {
            if(this.nodes[i].nodeID == nodeID) {
                bNodeFound = true;
            }
            if (this.nodes[i].text == strName && bNodeFound) {
                 objNode = this.nodes[i];
            }
        }
        return objNode;
};

//! Public Method emxUICoreTree.getNode()
//!     This method gets the node with the given node ID.
//!     This method is considered PUBLIC and MAY be used
//!     by developers.
emxUICoreTree.prototype.getNode = function _emxUICoreTree_getNode(strNodeID) {
	return this.nodes[strNodeID];
};
if (isIE) {
//! Private Method emxUICoreTree.getScrollPosition()
//!     This method gets the scroll position of the display frame.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUICoreTree.prototype.getScrollPosition = function _emxUICoreTree_getScrollPosition_IE() {
        if (this.displayFrame) {
        	this.scrollX = this.displayFrame.document.documentElement.scrollLeft?this.displayFrame.document.documentElement.scrollLeft:this.displayFrame.document.body.scrollLeft;
            this.scrollY = this.displayFrame.document.documentElement.scrollTop?this.displayFrame.document.documentElement.scrollTop:this.displayFrame.document.body.scrollTop;
        }
};
} else {
//! Private Method emxUICoreTree.getScrollPosition()
//!     This method gets the scroll position of the display frame.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUICoreTree.prototype.getScrollPosition = function _emxUICoreTree_getScrollPosition_NS() {
        if (this.displayFrame) {
            this.scrollX = this.displayFrame.pageXOffset;
            this.scrollY = this.displayFrame.pageYOffset;
        }
};
}
//! Public Method emxUICoreTree.hasNode()
//!     This method determines if the node with the given node ID
//!	exists. This method is considered PUBLIC and MAY be used
//!     by developers.
emxUICoreTree.prototype.hasNode = function _emxUICoreTree_getNode(strNodeID) {
	return !!this.nodes[strNodeID];
};
//! Private Method emxUICoreTree.importNode()
//!     This method imports a node into the tree. This method is
//!     considered PRIVATE and MAY NOT be used by developers.
emxUICoreTree.prototype.importNode = function _emxUICoreTree_importNode(objNode) {
        if (!this.nodes[objNode.nodeID]) {
                objNode.tree = this;
                this.nodes[this.nodes.length] = objNode;
                this.nodes[objNode.nodeID] = objNode;
                for (var i=0; i < objNode.childNodes.length; i++) {
                        this.importNode(objNode.childNodes[i]);
                }
    }
};
//! Private Method emxUICoreTree.link()
//!     This method simulates a link click. This method is considered
//!     PRIVATE and MAY NOT be used by developers.
emxUICoreTree.prototype.link = function _emxUICoreTree_link(strURL, strTarget) {
        if (strURL.indexOf("javascript:") == 0) {
                eval(strURL);
        } else {
                if (strTarget != null) {
                        var objFrame = findFrame(getTopWindow(), strTarget);
                        if (!objFrame) {
                                setTimeout(arguments.callee, 500, strURL, strTarget);
                        }
                        objFrame.location.href = strURL;
                } else {
                        document.location.href = strURL;
                }
        }
};
//! Public Method emxUICoreTree.refresh()
//!     This method refreshes the display of the tree. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUICoreTree.prototype.refresh = function _emxUICoreTree_refresh(blnGetScroll) {

		try{
			//This is code added for Bug 348007.TreeMenuRevision Filter(Permision Denied Error).
			emxUICore.removeEventHandler(window,"unload",registeredEvents.unregisterAllEvents);
		}catch(e){
		}

        if (blnGetScroll) {
                this.getScrollPosition();
        }
        this.draw();
};
//! Private Method emxUICoreTree.setScrollPosition()
//!     This method sets the scroll position of the display frame.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUICoreTree.prototype.setScrollPosition = function _emxUICoreTree_setScrollPosition() {
        if(this.displayFrame) {
            this.displayFrame.scrollTo(this.scrollX, this.scrollY);
        }
};
//! Class emxUICoreTreeNode
//!     This class represents a node on the tree. This class is not intended
//!     to be instantiated. Rather, this is intended to be a template upon
//!     which other classes can be built.
function emxUICoreTreeNode(strIcon, strText) {
        this.className = "emxUICoreTreeNode";
        this.indent = 0;
        this.path = "";
        this.tree = null;
        this.childNodes = new Array;
        this.expanded = false;
        if (strText) {
                this.htmltext = strText.htmlEncode();
        }
        if (strIcon) {
                this.icon = getIcon(strIcon);
        }
        this.nodeID = "node" + getUniqueID();
        this.parent = null;
        this.text = strText;
}

//! Protected Method emxUICoreTreeNode.setText()
emxUICoreTreeNode.prototype.setText = function _emxUICoreTreeNode_setText(strText) {
	 this.text = strText;
};
//! Protected Method emxUICoreTreeNode.setHtmlText()
emxUICoreTreeNode.prototype.setHtmlText = function _emxUICoreTreeNode_setHtmlText(strHtmltext) {
	 this.htmltext = strHtmltext;
};

//! Protected Method emxUICoreTreeNode.addChild()
//!     This methods adds a child node to this node.  This method
//!     is considered PROTECTED and may only be used by the framework.
//!     Developers may NOT use this method.
emxUICoreTreeNode.prototype.addChild = function _emxUICoreTreeNode_addChild(objNode) {
        this.tree.importNode(objNode);
        if (!this.isDuplicate(objNode)) {
                this.childNodes[this.childNodes.length] = objNode;
                objNode.parent = this;
                objNode.indent = this.indent + 1;
                objNode.path = this.path + TREE.PATH_SEPARATOR + "[" + objNode.text + "]";
        }
        return objNode;
};
//! Private Method emxUICoreTreeNode.addCloneChild()
//!     This methods adds a child node to this node. This method should
//!     not be called directly and is only called from within the
//!     cloneChildren() method. This method is considered PRIVATE and
//!     may NOT be used by developers.
emxUICoreTreeNode.prototype.addCloneChild = function _emxUICoreTreeNode_addCloneChild(objNode) {
        if (!this.isDuplicate(objNode)) {
                this.childNodes[this.childNodes.length] = objNode;
                objNode.parent = this;
        }
        return objNode;
};
//! Protected Method emxUICoreTreeNode.clear()
//!     This method clears all child nodes.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeNode.prototype.clear = function _emxUICoreTreeNode_clear() {
        this.childNodes = new Array;
};
//! Protected Method emxUICoreTreeNode.click()
//!     This methods fires a click on the node. This is a stub method.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeNode.prototype.click = function _emxUICoreTreeNode_click() {
};
//! Private Method emxUICoreTreeNode.clone()
//!     This methods creates a clone of this node. This method is
//!     considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.clone = function _emxUICoreTreeNode_clone() {
        var objNode = new emxUICoreTreeNode(this.icon, this.text);
        this.cloneChildren(objNode);
        return objNode;
};
//! Private Method emxUICoreTreeNode.cloneChildren()
//!     This methods creates a clone of this node
//!     is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.cloneChildren = function _emxUICoreTreeNode_cloneChildren(objNode) {
        for (var i=0; i < this.childNodes.length; i++) {
                objNode.addCloneChild(this.childNodes[i].clone());
        }
};
//! Protected Method emxUICoreTreeNode.collapse()
//!     This method collapses the node and refreshes the tree.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeNode.prototype.collapse = function _emxUICoreTreeNode_collapse() {
        if (this.expanded) {
                this.expanded = false;
                this.tree.refresh();
        }
};
//! Protected Method emxUICoreTreeNode.expand()
//!     This method expands the node and refreshes the tree.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeNode.prototype.expand = function _emxUICoreTreeNode_expand() {
        if (!this.expanded) {
                this.expanded = true;
                this.tree.refresh();
        }
};
//! Private Method emxUICoreTreeNode.getConnectorImage()
//!     This methods returns the appropriate image for the connector.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUICoreTreeNode.prototype.getConnectorImage = function _emxUICoreTree_getConnectorImage() {
        if (isLastNode(this)) {
                if (!this.hasChildNodes()) {
                        return TREE.IMG_LINE_LAST;
                } else {
                        if (this.expanded) {
                                return TREE.IMG_LINE_LAST_OPEN;
                        } else {
                                return TREE.IMG_LINE_LAST_CLOSED;
                        }
                }
        } else {
                if (!this.hasChildNodes()) {
                        return TREE.IMG_LINE_NODE;
                } else {
                        if (this.expanded) {
                                return TREE.IMG_LINE_NODE_OPEN;
                        } else {
                                return TREE.IMG_LINE_NODE_CLOSED;
                        }
                }
    }
};
//! Private Method emxUICoreTreeNode.getChildNodesHTML()
//!     This methods gets the HTML for all child nodes. This method
//!     is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.getChildNodesHTML = function _emxUICoreTreeNode_getChildNodesHTML() {
        var d = new jsDocument;
        var arrChildNodes = this.getPrintableChildNodes();
        if (arrChildNodes.length > 0 && this.expanded) {
                for (var i=0; i < arrChildNodes.length; i++) {
                        d.write(arrChildNodes[i].getHTML());
                }
        }
        return d.toString();
};
//! Private Method emxUICoreTreeNode.getConnectorImageHTML()
//!     This methods creates the HTML that represents the connector image
//!     (plus/minus/none). This method is considered PRIVATE and MAY NOT
//!     be used by developers.
emxUICoreTreeNode.prototype.getConnectorImageHTML = function _emxUICoreTreeNode_getConnectorImageHTML() {
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
        d.write("\" border=\"0\" width=\"19\" height=\"19\">");
        if (this.hasChildNodes()) {
                d.write("</a>");
        }
        d.write("</td>");
        return d.toString();
};
//! Private Method emxUICoreTreeNode.getHTML()
//!     This methods creates the HTML that represents the node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.getHTML = function _emxUICoreTreeNode_getHTML() {
        var d = new jsDocument;
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        if (this.indent > 0) {
                d.write(this.getMiscImagesHTML());
                d.write(this.getConnectorImageHTML());
        }
        d.write(this.getNodeHTML());
        d.write("</tr></table>");
        d.write(this.getChildNodesHTML());
        return d.toString();
};
//! Private Method emxUICoreTreeNode.getMiscImagesHTML()
//!     This methods creates the HTML that represents the "misc" images for
//!     the node. This method is considered PRIVATE and MAY NOT be used
//!      by developers.
emxUICoreTreeNode.prototype.getMiscImagesHTML = function _emxUICoreTreeNode_getMiscImagesHTML() {
        var strReturn="", strTemp="";
        var objCur = this, objParent = this.parent;
        var i=0;
        if (this.indent < 2) {
                return;
        }
        while (i < this.indent - 1) {
                strTemp = "<td class=\"node\"><img src=\"";
                if ((isLastNode(objCur) && isLastNode(objParent)) || (!isLastNode(objCur) && isLastNode(objParent)))
                        strTemp += IMG_SPACER;
                else {
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
//! Private Method emxUICoreTreeNode.getNodeHTML()
//!     This methods creates the HTML that represents the node part (icon
//!     and text only). This method is considered PRIVATE and MAY NOT
//!     be used by developers.
emxUICoreTreeNode.prototype.getNodeHTML = function _emxUICoreTree_getNodeHTML() {
        var d = new jsDocument;
        d.write("<td><img src=\"");
        d.write(this.icon);
        d.write("\" border=\"0\" width=\"16\" height=\"16\" />");
        d.write("</td><td nowrap>&nbsp;");
        d.write(this.htmltext);
        d.writeln("</td>");
        return d.toString();
};
//! Public Method emxUICoreTreeNode.getParent()
//!     This method returns a pointer to the parent ndoe of this node.
//!     This method is intended to be overridden in cases
//!     where the nodes must be filtered. This method is considered
//!     PUBLIC and MAY be used by developers.
emxUICoreTreeNode.prototype.getParent = function _emxUICoreTreeNode_getParent() {
        return this.parent;
};

//Added for Dynamic Categories for Tree Feature
//! Private Method emxUICoreTreeNode.descendantSelected()
//!     This method returns boolean.
//!     This method returns true when passed in selectedNode is descendant of the contextNode
emxUICoreTreeNode.prototype.descendantSelected = function _emxUICoreTreeNode_descendantSelected(contextNode,selectedNode) {
        //return this.parent;
        var parentNode = null;
        var nodeFound = false;
        while( (parentNode = selectedNode.getParent()) != null)
        {
        	if(contextNode == parentNode)
        	{
        		nodeFound = true;
        		break;
        	}

        	selectedNode = parentNode;
        }

        return nodeFound;
};

//! Private Method emxUICoreTreeNode.getPrintableChildNodes()
//!     This methods returns all of the child nodes that should be
//!     printed. For the core, this just returns the whole childNodes
//!     array. This method is intended to be overridden in cases
//!     where the nodes must be filtered. This method is considered
//!     PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.getPrintableChildNodes = function _emxUICoreTreeNode_getPrintableChildNodes() {
        this.sortChildren();
        return this.childNodes;
};
//! Private Method emxUICoreTreeNode.handleClick()
//!     This methods handles the onclick event for this node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.handleClick = function _emxUICoreTreeNode_handleClick(strTarget) {
        switch(strTarget) {
                case "connector":
                        if (this.hasChildNodes()) {
                        if (this.expanded) {
                                this.collapse();
                        } else {
                                this.expand();
                        }
                        }
                break;
        }
};
//! Private Method emxUICoreTreeNode.hasChildNodes()
//!     This method returns true if there are any childNodes. This method
//!     is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.hasChildNodes = function _emxUICoreTreeNode_hasChildNodes() {
    var arrChildNodes = this.getPrintableChildNodes();
    return arrChildNodes.length > 0;
};
//! Private Method emxUICoreTreeNode.getDuplicate()
//!     This method determines if a duplicate node already exists in the
//!     childNodes array and returns the duplicate node. This method is
//!     considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.getDuplicate = function _emxUICoreTreeNode_getDuplicate(objNode) {
        var objDupNode = null;
        for (var i=0; i < this.childNodes.length && !objDupNode; i++){
                if (this.childNodes[i] == objNode){
                        objDupNode = this.childNodes[i];
                }
        }
        return objDupNode;
};
//! Private Method emxUICoreTreeNode.isDuplicate()
//!     This method determines if a duplicate node already exists in the
//!     childNodes array. This method is considered PRIVATE and MAY NOT
//!     be used by developers.
emxUICoreTreeNode.prototype.isDuplicate = function _emxUICoreTreeNode_isDuplicate(objNode) {
        var blnFound = false;
        for (var i=0; i < this.childNodes.length && !blnFound; i++){
                blnFound = this.childNodes[i] == objNode;
        }
        return blnFound;
};
//! Private Method emxUICoreTreeNode.sortChildren()
//!     This method sorts all of the children of this node. This is a stub
//!     that can be overridden if necessary. This method is considered
//!     PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.sortChildren = function _emxUICoreTreeNode_sortChildren() {
};
//! Private Method emxUICoreTreeNode.updateIndents()
//!     This method updates the indents of this node and all child nodes.
//!     This method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeNode.prototype.updateIndents = function _emxUICoreTreeNode_updateIndents() {
        this.indent = this.parent.indent + 1;
        for (var i=0; i < this.childNodes.length; i++) {
                this.childNodes[i].updateIndents();
        }
};
//! Class emxUICoreTreeLoadNode
//!     This class represents a node on the tree whose children will be loaded
//!     only upon expansion of the node.
function emxUICoreTreeLoadNode(strIcon, strText, strLoadURL) {
        this.superclass = emxUICoreTreeNode;
        this.superclass(strIcon, strText);
        delete this.superclass;
        this.className = "emxUICoreTreeLoadNode";
        this.loadURL = strLoadURL;
        this.loaded = strLoadURL == null;
}
emxUICoreTreeLoadNode.prototype = new emxUICoreTreeNode;
//! Private Method emxUICoreTreeLoadNode.clone()
//!     This methods creates a clone of this node. This method is
//!     considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeLoadNode.prototype.clone = function _emxUICoreTreeLoadNode_clone() {
        var objNode = new emxUICoreTreeNode(this.icon, this.text, this.loadURL);
        this.cloneChildren(objNode);
        return objNode;
};
//! Protected Method emxUICoreTreeLoadNode.expand()
//!     This method expands the node. If the node isn
//!     a loading node and proceeds to the loadURL.
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeLoadNode.prototype.expand = function _emxUICoreTreeLoadNode_expand() {
        if (!this.expanded) {
                this.expanded = true;
                if (!this.loaded) {
                        this.load();
                } else {
                        this.tree.refresh(true);
                }
        }
};
//! Private Method emxUICoreTreeLoadNode.hasChildNodes()
//!     This method returns true if there are any childNodes. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreTreeLoadNode.prototype.hasChildNodes = function _emxUICoreTreeLoadNode_hasChildNodes() {
        var arrChildNodes = this.getPrintableChildNodes();
        return arrChildNodes.length > 0 || (!this.loaded && this.loadURL);
};
//! Protected Method emxUICoreTreeLoadNode.load()
//!     This method loads the node
//!     This method is considered PROTECTED and may only be used by the
//!     framework. Developers may NOT use this method.
emxUICoreTreeLoadNode.prototype.load = function _emxUICoreTreeLoadNode_load() {
        if (!this.loaded) {
                this.addChild(new emxUICoreTreeNode(IMG_LOADING, emxUIConstants.STR_LOADING));
                this.tree.refresh(true);
                var strURL = addURLParam(this.loadURL, "treeID=" + this.tree.id);
                strURL = addURLParam(strURL, "nodeID=" + this.nodeID);
                this.tree.displayFrame.document.location.href = strURL;
        }
};
//! Class emxUICoreCheckboxTree
//!     This class represents a tree.
function emxUICoreCheckboxTree(strID) {
        this.superclass = emxUICoreTree;
        this.superclass(strID);
        delete this.superclass;
        this.className = "emxUICoreCheckboxTree";
}
emxUICoreCheckboxTree.prototype = new emxUICoreTree;
//! Public Method emxUICoreCheckboxTree.getValue()
//!     This method gets the value of the tree. This method
//!     is considered PUBLIC and MAY be used by developers.
emxUICoreCheckboxTree.prototype.getValue = function _emxUICoreCheckboxTree_getValue() {
        return this.root.getValue();
};
//! Class emxUICoreCheckboxTreeNode
//!     This class represents a node on the tree that has a checkbox.
function emxUICoreCheckboxTreeNode(strIcon, strText, strLoadURL) {
        this.superclass = emxUICoreTreeLoadNode;
        this.superclass(strIcon, strText, strLoadURL);
        delete this.superclass;
        this.checked = false;
        this.className = "emxUICoreCheckboxTreeNode";
        this.disabled = false;
}
emxUICoreCheckboxTreeNode.prototype = new emxUICoreTreeLoadNode;
emxUICoreCheckboxTreeNode.prototype.emxUICoreTreeNodeHandleClick = emxUICoreCheckboxTreeNode.prototype.handleClick;
//! Private Method emxUICoreCheckboxTreeNode.clone()
//!     This methods creates a clone of this node. This method is
//!     considered PRIVATE and MAY NOT be used by developers.
emxUICoreCheckboxTreeNode.prototype.clone = function _emxUICoreCheckboxTreeNode_clone() {
        var objNode = new emxUICoreCheckboxTreeNode(this.icon, this.text, this.loadURL);
        this.cloneChildren(objNode);
        return objNode;
};
//! Private Method emxUICoreCheckboxTreeNode.getCheckboxHTML()
//!     This methods creates the HTML that represents the checkbox.
//!     This method is considered PRIVATE and MAY NOT be used by
//!     developers.
emxUICoreCheckboxTreeNode.prototype.getCheckboxHTML = function _emxUICoreCheckboxTreeNode_getCheckboxHTML() {
        var d = new jsDocument;
        d.write("<td>");
        if (!this.disabled) {
                d.write("<a href=\"javascript:parent.trees['");
                d.write(this.tree.id);
                d.write("'].nodes['");
                d.write(this.nodeID);
                d.write("'].handleClick('checkbox')\"><img src=\"");
                d.write(this.checked ? TREE.IMG_CHECK_ON : TREE.IMG_CHECK_OFF);
                d.write("\" height=\"13\" width=\"13\" align=\"absmiddle\" border=\"0\" /></a>");
        } else {
                d.write("<img src=\"");
                d.write(TREE.IMG_CHECK_OFF_DISABLED);
                d.write("\" border=\"0\" align=\"absmiddle\" />");
        }
        d.write("<td>");
        return d.toString();
};
//! Private Method emxUICoreCheckboxTreeNode.getHTML()
//!     This method creates the HTML that represents the node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreCheckboxTreeNode.prototype.getHTML = function _emxUICoreCheckboxTreeNode_getHTML() {
        var d = new jsDocument;
        d.write("<table border=0 cellspacing=0 cellpadding=0><tr>");
        if (this.indent > 0) {
                d.write(this.getMiscImagesHTML());
                d.write(this.getConnectorImageHTML());
        }
        d.write(this.getCheckboxHTML());
        d.write(this.getNodeHTML());
        d.writeln("</tr></table>");
        d.write(this.getChildNodesHTML());
        return d.toString();
};
//! Public Method emxUICoreCheckboxTreeNode.getValue()
//!     This methods gets the value of the node. This method is
//!     considered PUBLIC and MAY be used by developers.
emxUICoreCheckboxTreeNode.prototype.getValue = function _emxUICoreCheckboxTreeNode_getValue() {
        var d = new jsDocument;
        if (this.checked && !this.disabled) {
                d.write(this.text);
                d.write(",");
        } else {
                var arrChildNodes = this.getPrintableChildNodes();
                for (var i=0; i < arrChildNodes.length; i++) {
                        d.write(arrChildNodes[i].getValue());
                }
        }
        return d.toString();
};
//! Private Method emxUICoreCheckboxTreeNode.handleClick()
//!     This methods handles the onclick event for this node. This
//!     method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreCheckboxTreeNode.prototype.handleClick = function (strTarget) {
        switch(strTarget) {
                case "checkbox":
                        this.toggleCheck();
                        this.tree.refresh();
                        break;
                default:
                        this.emxUICoreTreeNodeHandleClick(strTarget);
                        break;
        }
};
//! Public Method emxUICoreCheckboxTreeNode.toggleCheck()
//!     This methods toggles the checked state. This method is
//!     considered PUBLIC and MAY be used by developers.
emxUICoreCheckboxTreeNode.prototype.toggleCheck = function _emxUICoreCheckboxTreeNode_toggleCheck(blnOverride) {
    if (!this.disabled) {
        this.checked = (blnOverride == null ? !this.checked : blnOverride);
    }
};
//! Class emxUICoreRadioTree
//!     This class represents a radio button tree.
function emxUICoreRadioTree(strID) {
        this.superclass = emxUICoreTree;
        this.superclass(strID);
        delete this.superclass;
        this.className = "emxUICoreRadioTree";
        this.selectedID = -1;
}
emxUICoreRadioTree.prototype = new emxUICoreTree;
//! Public Method emxUICoreRadioTree.getValue()
//!     This method gets the value of the tree. This method is
//!     considered PUBLIC and may be used by developers.
emxUICoreRadioTree.prototype.getValue = function _emxUICoreRadioTree_getValue() {
        if (this.selectedID == -1) {
                return "";
        } else {
                return this.nodes[this.selectedID].text;
        }
};
//! Class emxUICoreRadioTreeNode
//!     This class represents a node on the tree that has a radio button.
function emxUICoreRadioTreeNode(strIcon, strText, strLoadURL) {
    this.superclass = emxUICoreTreeLoadNode;
    this.superclass(strIcon, strText, strLoadURL);
    delete this.superclass;
    this.className = "emxUICoreRadioTreeNode";
    this.disabled = false;
}
emxUICoreRadioTreeNode.prototype = new emxUICoreTreeLoadNode;
emxUICoreRadioTreeNode.prototype.emxUICoreTreeNodeHandleClick = emxUICoreRadioTreeNode.prototype.handleClick;
//! Private Method emxUICoreRadioTreeNode.clone()
//!     This methods creates a clone of this node. This method
//!     is considered PRIVATE and MAY NOT be used by developers.
emxUICoreRadioTreeNode.prototype.clone = function _emxUICoreRadioTreeNode_clone() {
        var objNode = new emxUICoreRadioTreeNode(this.icon, this.text, this.loadURL);
        this.cloneChildren(objNode);
        return objNode;
};
//! Private Method emxUICoreRadioTreeNode.getHTML()
//!     This method creates the HTML that represents the node.
//!     This method is considered PRIVATE and MAY NOT be used
//!     by developers.
emxUICoreRadioTreeNode.prototype.getHTML = function _emxUICoreRadioTreeNode_getHTML() {
        var d = new jsDocument;
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        if (this.indent > 0) {
                d.write(this.getMiscImagesHTML());
                d.write(this.getConnectorImageHTML());
        }
        d.write(this.getRadioHTML());
        d.write(this.getNodeHTML());
        d.writeln("</tr></table>");
        d.write(this.getChildNodesHTML());
        return d.toString();
};
//! Private Method emxUICoreRadioTreeNode.getRadioHTML()
//!     This method creates the HTML that represents the radio button.
//!     This method is considered PRIVATE and MAY NOT be used by developers.
emxUICoreRadioTreeNode.prototype.getRadioHTML = function _emxUICoreRadioTreeNode_getRadioHTML() {
        var d = new jsDocument;
        d.write("<td>");
        if (!this.disabled) {
                d.write("<a href=\"javascript:parent.trees['");
                d.write(this.tree.id);
                d.write("'].nodes['");
                d.write(this.nodeID);
                d.write("'].handleClick('radiobutton')\"><img src=\"");
                d.write(this.tree.selectedID == this.nodeID ? TREE.IMG_RADIO_ON : TREE.IMG_RADIO_OFF);
                d.write("\" border=\"0\" /></a>");
        } else {
                d.write("<img src=\"");
                d.write(TREE.IMG_RADIO_OFF_DISABLED);
                d.write("\" border=\"0\" />");
        }
        d.write("<td>");
        return d.toString();
};
//! Private Method emxUICoreRadioTreeNode.handleClick()
//!     This methods handles the onclick event for this node.
//!     This method is considered PRIVATE and MAY NOT be used
//!     by developers.
emxUICoreRadioTreeNode.prototype.handleClick = function _emxUICoreRadioTreeNode_handleClick(strTarget) {
        switch(strTarget) {
                case "radiobutton":
                        this.tree.selectedID = this.nodeID;
                        this.tree.refresh(true);
                        break;
                default:
                        this.emxUICoreTreeNodeHandleClick(strTarget);
                        break;
        }
};
//! Private Function compareNodesByIndent()
//!     This function compares two nodes by their indent.
//!     This function is considered PRIVATE and MAY NOT be used
//!     be developers.
function compareNodesByIndent(objNodeA, objNodeB) {
        if (objNodeA.indent > objNodeB.indent) {
                return 1;
        } else if (objNodeA.indent < objNodeB.indent) {
                return -1;
        } else {
                return 0;
        }
}
//! Private Function compareNodesByText()
//!     This function compares two nodes by their display text.
//!     This function is considered PRIVATE and MAY NOT be used
//!     by developers.
function compareNodesByText(objNodeA, objNodeB) {
        if (objNodeA.text.toLowerCase() > objNodeB.text.toLowerCase()) {
                return 1;
        } else if (objNodeA.text.toLowerCase() < objNodeB.text.toLowerCase()) {
                return -1;
        } else {
                return 0;
        }
}
//! Private Function getIcon()
//!     This function gets the full path of the icon.
//!     This function is considered PRIVATE and MAY NOT be used
//!     by developers.
function getIcon(strIcon) {
        if (strIcon == null) {
                return null;
        } else if (strIcon.substring(1,8) == "servlet" || strIcon.indexOf(DIR_SMALL_ICONS) > -1) {
                return strIcon;
        } else {
                return DIR_SMALL_ICONS + strIcon;
        }
}
//! Private Function getUniqueID()
//!     This function creates a unique ID. This function is
//!     considered PRIVATE and MAY NOT be used by developers.
function getUniqueID() {
        var strNodeID = "emx";
        strNodeID += ((new Date()).getTime() * Math.random());
        return strNodeID;
}
//! Private Function isLastNode()
//!     This function determines if the given node is the last of its siblings.
//!     This function is considered PRIVATE and MAY NOT be used by developers.
function isLastNode(objNode) {
        var arrChildNodes = objNode.parent.getPrintableChildNodes();
        return arrChildNodes[arrChildNodes.length-1] == objNode;
}
