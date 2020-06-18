/*!================================================================
 *  JavaScript Selectable Tree
 *  emxUISelectableTree.js
 *  Version 1.9
 *  Requires: emxUIConstants.js
 *  Last Updated: 20-Mar-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains class definition for the selectable tree.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUISelectableTree.js.rca 1.19 Wed Oct 22 15:47:54 2008 przemek Experimental przemek $
 *=================================================================
 */
var localSelectableTree = null;
var IMG_LINE_VERT = DIR_APPLEVEL_IMAGES + "utilTreeLineVert.gif";
var IMG_LINE_LAST = DIR_APPLEVEL_IMAGES + "utilTreeLineLast.gif";
var IMG_LINE_LAST_OPEN = DIR_APPLEVEL_IMAGES + "utilTreeLineLastOpen.gif";
var IMG_LINE_LAST_CLOSED = DIR_APPLEVEL_IMAGES + "utilTreeLineLastClosed.gif";
var IMG_LINE_NODE = DIR_APPLEVEL_IMAGES + "utilTreeLineNode.gif";
var IMG_LINE_NODE_OPEN = DIR_APPLEVEL_IMAGES + "utilTreeLineNodeOpen.gif";
var IMG_LINE_NODE_CLOSED = DIR_APPLEVEL_IMAGES + "utilTreeLineNodeClosed.gif";
var IMG_CHECK_ON = DIR_APPLEVEL_IMAGES + "utilTreeCheckOn.gif";
var IMG_CHECK_OFF = DIR_APPLEVEL_IMAGES + "utilTreeCheckOff.gif";
var IMG_CHECK_OFF_DISABLED = DIR_APPLEVEL_IMAGES + "utilTreeCheckOffDisabled.gif";
var IMG_RADIO_ON = DIR_APPLEVEL_IMAGES + "utilTreeRadioOn.gif";
var IMG_RADIO_OFF = DIR_APPLEVEL_IMAGES + "utilTreeRadioOff.gif";
var IMG_RADIO_OFF_DISABLED = DIR_APPLEVEL_IMAGES + "utilTreeRadioOffDisabled.gif";
//! Class jsSelectableTree
//!     This object represents a selectable tree.
function jsSelectableTree(strStylesheet, bPropagate) {
        this.alertMessage = null;
        this.root = null;
        this.checkUrl = null;
	this.formFieldID = null;
	this.formFieldValue = null;
        this.dirty = false;
        this.displayFrame = "treeDisplay";
        this._displayFrame = null;
        this.firstLoad = true;
        this.nodemap = new Array;
        this.nodes = new Array;
        this.scrollX = 0;
        this.scrollY = 0;
        this.selectedID = "root";
        this.stylesheet = DIR_APPLEVEL_STYLES + strStylesheet;
        this.propagate = (bPropagate == null ? true : bPropagate);
        this.multiSelect = true;
        this.draw = _jsSelectableTree_draw;
        this.drawChild = _jsSelectableTree_drawChild;
        this.drawLoadingMessage = _jsSelectableTree_drawLoadingMessage;
        this.drawMiscImages = _jsSelectableTree_drawMiscImages;
        this.drawPlusMinusImage = _jsSelectableTree_drawPlusMinusImage;
        this.drawSelectControl = _jsSelectableTree_drawSelectControl;
        this.getScrollPosition = _jsSelectableTree_getScrollPosition;
        this.refresh = _jsSelectableTree_refresh;
        this.createRoot = _jsSelectableTree_createRoot;
        this.addChild = _jsSelectableTree_createRoot;
        this.propagateChecks = _jsSelectableTree_propagateChecks;
        this.setScrollPosition = _jsSelectableTree_setScrollPosition;
        this.setSelectedNode = _jsSelectableTree_setSelectedNode;
        this.toggleExpand = _jsSelectableTree_toggleExpand;
        this.setSelectedNode = _jsTree_setSelectedNode;
        this.deleteObject = _jsTree_deleteObject;
        this.clear = function () {
                this.nodes = new Array;
                this.nodemap = new Array;
                this.dirty = false;
                this.firstLoad = true;
        };
        this.getSelectedNode = function () {
                return this.nodes[this.selectedID];
        };
        localSelectableTree = this;
}
//! Public Method jsSelectableTree.draw()
//!     This function draws the tree on the frame identified by displayFrame.
function _jsSelectableTree_draw() {
        var d = new jsDocument;
        d.writeHTMLHeader(this.stylesheet);
        d.write("<body onload=\"parent.localSelectableTree.setScrollPosition()\"");
        if (isIE){
                d.write(" onselectstart=\"return false\" oncontextmenu=\"return false\"");
        }
        d.write(">");
        d.write("<form method=\"post\">");
        if (this.firstLoad || this.multiSelect) {
                this.selectedID = "";
                this.firstLoad = false;
        }
        this.drawChild(d, this.root);
        d.write("</form>");
        d.writeHTMLFooter();
        this._displayFrame = findFrame(getTopWindow(), this.displayFrame);
        with (this._displayFrame.document) {
                open();
                write(d);
                close();
        }
        if (isNS4 || isMinMoz1) {
                this.setScrollPosition();
        }
}
//! Private Method jsSelectableTree.drawChild()
//!     This function draws an individual node onto a jsDocument.
function _jsSelectableTree_drawChild(d, objNode) {
        var strNodeURL = "javascript:parent.linkClick('" + objNode.nodeID + "')";
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        this.drawMiscImages(d, objNode);
        this.drawPlusMinusImage(d, objNode);
        this.drawSelectControl(d, objNode);
        d.write("<td nowrap=\"nowrap\">");
        if (objNode.selectable) {
                d.write("<a href=\"");
                d.write(strNodeURL);
                d.write("\">");
        }
        d.write("<img src=\"");
        d.write(objNode.icon);
        d.write("\" border=\"0\" width=\"16\" height=\"16\">");
        if (objNode.selectable){
                d.write("</a>");
        }
        d.write("</td><td nowrap=\"nowrap\" ");
        if (objNode.parent == null) {
                if (this.selectedID == "root"){
                        d.write("class=\"rootSelected\" ");
                }else{
                        d.write("class=\"root\" ");
                }
        } else {
                if (this.selectedID == objNode.nodeID){
                        d.write("class=\"selected\" ");
                }
        }
        d.write(">&nbsp;");
        if (objNode.selectable) {
                d.write("<a href=\"");
                d.write(strNodeURL);
                d.write("\">");
        }
        d.write(objNode.name);
        if (objNode.selectable){
                d.writeln("</a>");
        }
        d.write("&nbsp;</td></tr></table>");
        if (objNode.formName) {
                if (!this.multiSelect && (this.selectedID == objNode.nodeID) || this.multiSelect && objNode.checked) {
                        d.write("<input type=\"hidden\" name=\"");
                        d.write(objNode.formName);
                        d.write("\" value=\"");
                        d.write(objNode.formValue);
                        d.write("\" />");
                }
        }
        if (objNode.hasChildNodes && objNode.expanded) {
                if (objNode.loaded) {
                        for (var i=0; i < objNode.childNodes.length; i++){
                                this.drawChild(d, objNode.childNodes[i]);
                        }
                } else {
                        this.drawLoadingMessage(d, objNode);
                }
        }
}
//! Private Method jsSelectableTree.drawMiscImages()
//!     This function draws extra images for the specified node.
function _jsSelectableTree_drawMiscImages(d, objNode, iIndent) {
        if (objNode == this.root) {
                return;
        }
        if (!iIndent) {
                iIndent = 0;
        }
        var str="", tempstr="";
        var cur = objNode, par = objNode.parent;
        var i=0;
        if (objNode.indent < 2 && iIndent == 0){
                return;
        }
        while (i < objNode.indent - 1) {
                tempstr = "<td class=\"node\"><img src=\"";
                if ((cur.isLast && par.isLast) || (!cur.isLast && par.isLast)){
                        tempstr += IMG_SPACER;
                } else {
                        tempstr += IMG_LINE_VERT;
                }
                tempstr += "\" width=\"19\" height=\"19\" border=\"0\"></td>"
                cur = par;
                par = par.parent;
                i++;
                str = tempstr + str;
        }
        d.write(str);
}
//! Private Method jsSelectableTree.drawPlusMinusImage()
//!     This function draws a plus/minus image, or no image, depending on
//!     the state of the node.
function _jsSelectableTree_drawPlusMinusImage(d, objNode) {
        if (objNode.indent < 1){
                return;
        }
        var par = objNode.parent;
        d.write("<td>");
        if (objNode.hasChildNodes) {
                d.write("<a href=\"javascript:parent.clickPlusMinus('");
                d.write(objNode.nodeID);
                d.write("')\">");
        }
        d.write("<img src=\"");
        if (objNode.isLast) {
                if (!objNode.hasChildNodes){
                        d.write(IMG_LINE_LAST);
                } else {
                        if (objNode.expanded){
                                d.write(IMG_LINE_LAST_OPEN);
                        } else {
                                d.write(IMG_LINE_LAST_CLOSED);
                        }
                }
        } else {
                if (!objNode.hasChildNodes){
                        d.write(IMG_LINE_NODE);
                } else {
                        if (objNode.expanded){
                                d.write(IMG_LINE_NODE_OPEN);
                        } else {
                                d.write(IMG_LINE_NODE_CLOSED);
                        }
                }
        }
        d.write("\" border=\"0\" width=\"19\" height=\"19\" name=\"node");
        d.write(objNode.nodeID);
        d.write("\">");
        if (objNode.hasChildNodes){
                d.write("</a>");
        }
        d.write("</td>");
}
//! Private Method jsSelectableTree.drawSelectControl()
//!     This function draws a radio button or checkbox for a given node.
function _jsSelectableTree_drawSelectControl(d, objNode) {
        var strNodeURL = "javascript:parent.linkClick('" + objNode.nodeID + "')";
        d.write("<td>");
        if (this.multiSelect) {
                if (objNode.selectable){
                        d.write("<a href=\"");
                        d.write(strNodeURL);
                        d.write("\"><img src=\"");
                        d.write(objNode.checked ? IMG_CHECK_ON : IMG_CHECK_OFF);
                        d.write("\" border=\"0\" /></a>");
                } else {
                        d.write("<img src=\"");
                        d.write(IMG_CHECK_OFF_DISABLED);
                        d.write("\" />");
                }
        } else {
                if (objNode.selectable){
                        d.write("<a href=\"");
                        d.write(strNodeURL);
                        d.write("\"><img src=\"");
                        d.write((objNode.nodeID == this.selectedID) ? IMG_RADIO_ON : IMG_RADIO_OFF);
                        d.write("\" border=\"0\" /></a>");
                } else {
                        d.write("<img src=\"");
                        d.write(IMG_RADIO_OFF_DISABLED);
                        d.write("\" />");
                }
        }
        d.write("</td>");
}
//! Private Method jsSelectableTree.drawLoadingMessage()
//!     This function draws a loading message for a node if the node
//!     children have not yet been loaded.
function _jsSelectableTree_drawLoadingMessage(d, objNode) {
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
        this.drawMiscImages(d, objNode, 2);
        d.write("<td nowrap><img src=\"");
        d.write(IMG_LOADING);
        d.write("\" border=\"0\" width=\"16\" height=\"16\"></td><td nowrap class=\"loading\">");
        d.write(emxUIConstants.STR_LOADING);
        d.write("</td></tr></table>");
}
//! Private Method jsSelectableTree.refresh()
function _jsSelectableTree_refresh() {
        this.draw();
}
//! Public Method jsSelectableTree.createRoot()
//!     This function creates the root node of the tree.
function _jsSelectableTree_createRoot(strName, strIcon, strID, strFormName, strFormValue) {
        this.root = new jsNode(strName, strIcon, null, strID, strFormName, strFormValue);
        this.root.expanded = true;
        this.root.tree = this;
        this.root.nodeID = "root";
        this.root.selectable = false;
        this.nodes["root"] = this.root;
        return this.root;
}
//! Private Method jsSelectableTree.toggleExpand()
//!     This function expand/collapse a node
function _jsSelectableTree_toggleExpand(strNodeID) {
        var node = this.nodes[strNodeID];
        node.expanded = !node.expanded;
        this.getScrollPosition();
        this.refresh();
}
//! Private Method jsSelectableTree.getScrollPosition()
//!     This function gets the scrolling position of the window and saves it
//!     into a local variable.
function _jsSelectableTree_getScrollPosition() {
        var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
        if (isIE) {
        	var doc = win.document;
        	if(doc.documentElement){
        		this.scrollX = doc.documentElement.scrollLeft;
                this.scrollY = doc.documentElement.scrollTop;
        	}else if (doc.body){
        		this.scrollX = doc.body.scrollLeft;
                this.scrollY = doc.body.scrollTop;
        	}
        } else {
                this.scrollX = win.pageXOffset;
                this.scrollY = win.pageYOffset;
        }  
}
//! Private Method jsSelectableTree.setScrollPosition()
//!     This function sets the scrolling position of the window from the saved
//!     values.
function _jsSelectableTree_setScrollPosition() {
        var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
        win.scrollTo(this.scrollX, this.scrollY);
}
//! Private Method jsSelectableTree.setSelectedNode()
//!     This function sets a given node in the tree to be selected and
//!     expands all its ancestors so it can be viewed.
function _jsSelectableTree_setSelectedNode(strNodeID) {
        this.selectedID = strNodeID;
        var tempNode = this.nodes[strNodeID];
        while (tempNode.parent) {
                if (!tempNode.parent.expanded){
                        tempNode.parent.expanded = true;
                }
                tempNode = tempNode.parent;
        }
        this.getScrollPosition();
        this.refresh();
}
//! Private Method jsSelectableTree.propagateChecks()
//!     This method sets all the checkboxes for a node
//!     so that proper checkbox behavior occurs.
function _jsSelectableTree_propagateChecks(strNodeID) {
        var objNode = this.nodes[strNodeID];
        if (!objNode.checked) {
                var objPar = objNode.parent, objCur = objNode;
                while (objPar) {
                        objPar.checked = false;
                        objCur = objPar;
                        objPar = objPar.parent;
                }
        }
        objNode.updateChecks();
        this.getScrollPosition();
        this.refresh();
}
//! Class jsNode
//!     This class represents one node on the tree.
function jsNode (strName, strIcon, strExpandURL, strObjectID, strFormName, strFormValue) {
        this.name = strName;
        if((strIcon.substring(1,8)) == "servlet" || strIcon.indexOf("/") > -1){
                this.icon = strIcon;
        }else{
                this.icon = DIR_SMALL_ICONS + strIcon;
        }
        this.expandURL = strExpandURL;
        this.nodeID = "-1";
        this.isLast = false;
        this.id = strObjectID;
        var bCanExpand = strExpandURL;
        if (bCanExpand) {
                this.hasChildNodes = true;
                this.loaded = false
        } else {
                this.hasChildNodes = false;
                this.loaded = true;
        }
        this.selectable = true;
        this.formValue = strFormValue;
        this.formName = strFormName;
        this.childNodes = new Array;
        this.expanded = false;
        this.parent = null;
        this.indent = 0;
        this.tree = null;
        this.addChild = _jsNode_addChild;
        this.updateChecks = _jsNode_updateChecks;
        this.getCheckedValues = _jsNode_getCheckedValues;
        this.getObjectID = _jsNode_getObjectID;
        this.removeChild = _jsNode_removeChild;
}
//! Public Method jsNode.addChild()
//!     This method adds a child node to the current node.
function _jsNode_addChild(strName, strIcon, strExpandURL, strObjectID, strFormName, strFormValue) {
        //strName += " ";
        var objNode = new jsNode(strName, strIcon, strExpandURL, strObjectID, strFormName, strFormValue);
        
        //
        // We have to avoid the duplicate nodes in the tree. 
        // When the nodes being entered in the tree are actually corresponding business objects 
        // (i.e. node have object id), then two duplicate nodes can be identified with their same object id.
        // When the nodes being entered in the tree are not representing corresponding business objects
        // (i.e. node do not have object id), then two duplicate nodes can be identified with their same name.
        //
        var isNodeBusObj = false;
        if (strObjectID) {
            isNodeBusObj = true;
        }
        
        if (isNodeBusObj) {
            // Avoid duplicate node
            if (this.childNodes[strObjectID]) {
                return;
            }
            this.childNodes[strObjectID] = objNode;
        }
        else {
            // Avoid duplicate node
        if (this.childNodes[strName]) {
                return;
        }
        this.childNodes[strName] = objNode;
        }
        this.childNodes[this.childNodes.length] = objNode;

        this.hasChildNodes = true;
        objNode.parent = this;
        objNode.tree = this.tree;
        objNode.isLast = true;
        if (this.childNodes.length > 1) {
                this.childNodes[this.childNodes.length - 2].isLast = false;
        }
        
        objNode.indent = this.indent + 1;
        objNode.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.childNodes.length - 1);
        
        if (isNodeBusObj) {
                this.tree.nodes[strObjectID] = objNode;
                if (this.tree.nodemap[strObjectID]) {
                        this.tree.nodemap[strObjectID][this.tree.nodemap[strObjectID].length] = objNode;
                } else {
                        this.tree.nodemap[strObjectID] = new Array(objNode);
                }
        }
        else {
            this.tree.nodes[strName] = objNode;
        }
        this.tree.nodes[objNode.nodeID] = objNode;
        
        return objNode;
}
//! Private Method jsNode.updateChecks()
//!     This method updates the checkboxes of all of its children.
function _jsNode_updateChecks() {
        for (var i=0; i < this.childNodes.length; i++) {
                this.childNodes[i].checked = this.checked;
                this.childNodes[i].updateChecks();
        }
}
//! Public Method jsNode.getCheckedValues()
//!     This method prepares array of checked nodes id
//!     with a separator ";"
function _jsNode_getCheckedValues(result) {
        for (var i=0; i < this.childNodes.length; i++) {
                if(this.childNodes[i].checked){
                        result[0] += this.childNodes[i].id + ";";
                        result[1] += this.childNodes[i].name + ";";
                }
                result = this.childNodes[i].getCheckedValues(result);
        }
        return result;
}
//! Private Function clickPlusMinus()
//!     This function is the event handler for clicking the expand/collapse
//!     arrow in the tree.
function clickPlusMinus(strNodeID) {
        localSelectableTree.getScrollPosition();
        localSelectableTree.toggleExpand(strNodeID);
        if (localSelectableTree.nodes[strNodeID].hasChildNodes && localSelectableTree.nodes[strNodeID].expanded && !localSelectableTree.nodes[strNodeID].loaded) {
                var strURL = localSelectableTree.nodes[strNodeID].expandURL;
                strURL = addURLParam(strURL,"jsTreeID=" + strNodeID);
                var win = localSelectableTree._displayFrame || findFrame(getTopWindow(), localSelectableTree.displayFrame);
                win.document.location.href = strURL;
        }
}
//! Private Function linkClick()
//!     This function is the event handler for clicking on a link in the
//!     tree. It handles the navigation and the highlighting of the item.
function linkClick(strNodeID) {
        var objNode = localSelectableTree.nodes[strNodeID];
		if(localSelectableTree.selectedID != strNodeID)
		{			
			localSelectableTree.selectedID = strNodeID;
		}
		else
		{			
			localSelectableTree.selectedID = "";
		}
        localSelectableTree.getScrollPosition();
		
        if (localSelectableTree.multiSelect) {
                objNode.checked = !objNode.checked;
                if (localSelectableTree.propagate) {
                        localSelectableTree.propagateChecks(objNode.nodeID);
                }
        }
		
        if (localSelectableTree.checkUrl != null) {
                selectPage(localSelectableTree.checkUrl);
        }
        
	if (localSelectableTree.formFieldID != null) {
                setFormField(localSelectableTree.formFieldID, localSelectableTree.formFieldValue);
        }

        setTimeout("localSelectableTree.refresh()", 50);
}
//! Public Function doDone()
//!     This function assigns the seleted name and id of the object
//!     to the caller window.
function doDone(){
        var winObj = parent.window.getWindowOpener();
        var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
        eval("winObj.document.forms[0]." + fieldName + ".value='" + selnode.name + "'");
        eval("winObj.document.forms[0]." + fieldId + ".value='" + selnode.id + "'");
        parent.window.closeWindow();
}
//! Public Function isAnyNodeChecked()
//!     This method checks if any of the nodes under a node are
//!     selected or not
function isAnyNodeChecked(startNode) {
        for (var i=0; i < startNode.childNodes.length; i++) {
                if(startNode.childNodes[i].checked){
                        return true;
                }
                if(isAnyNodeChecked(startNode.childNodes[i]) == true){
                        return true;
                }
        }
        return false;
}
//! Public Function doSelect()
//!     This function submits the form to the page passed in as
//!     parameter 'target'.
function doSelect( target, strSeleOneItem ) {
        var checked = false;
        if (localSelectableTree.multiSelect) {
                checked = isAnyNodeChecked(localSelectableTree.root);
        } else {
                checked = (localSelectableTree.selectedID != "" ? true : false);
                if (checked) {
                        var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
                        if (target.indexOf("?") != -1) {
                                target += "&radio=" + selnode.id;
                        } else {
                                target += "?radio=" + selnode.id;
                        }
                }
        }
        if (checked) {
                if (frames['pagecontent'].document.forms[0] != null) {
                        frames['pagecontent'].document.forms[0].action= target;
                        frames['pagecontent'].document.forms[0].submit();
                        // Added for the Bug 302233
                        turnOnProgress();
                } else {
                        parent.window.closeWindow();
                }
        } else {
          if((strSeleOneItem == null) || (strSeleOneItem == ""))
            {
       if(parent.tree.alertMessage)
       {
         strSeleOneItem = parent.tree.alertMessage;
       }
       else
       {
         strSeleOneItem = emxUIConstants.SELECT_ONE_ITEM;
       }
          }
                alert(strSeleOneItem);
        }
}
//! Public Function selectPage()
//!     This function submits the form to the page passed in as
//!     parameter 'target'.
function selectPage(target){
        var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
		var lastIndex = frames[1].document.location.href.lastIndexOf('/');
		var targetURL = frames[1].document.location.href.substr(0, lastIndex) + '/' + target + selnode.id;
	 	frames[1].document.location.href = targetURL;

}


//! Public Function setFormField()
//!     This function submits the form to the page passed in as
//!     parameter 'target'.
function setFormField(targetID, targetValue){
	var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
	if(selnode)
	{
		targetID.value = selnode.id;
		var parentNode = selnode.parent;
			
		var fullPath = selnode.name;

		while(parentNode != null)
		{
			fullPath = parentNode.name + "/" + fullPath;
			parentNode = parentNode.parent;
		}
		targetValue.value = fullPath;
	}
	else
	{
		targetID.value		= "";
		targetValue.value	= "";
	}
}


//! Public Function doMultiDone()
//!     This function assigns multiple names and ids of the
//!     object to the caller window.
function doMultiDone(){
        var winObj = parent.window.getWindowOpener();
        var result = new Array();
        result[0] = "";
        result[1] = "";
        for(var i=0;i<localSelectableTree.root.childNodes.length;i++){
                var objNode = localSelectableTree.root.childNodes[i];
                if (objNode.hasChildNodes) {
                        result = objNode.getCheckedValues(result);
                }
        }
        eval("winObj.document.forms[0]." + fieldName + ".value='" + result[1] + "'");
        eval("winObj.document.forms[0]." + fieldId + ".value='" + result[0] + "'");
        parent.window.closeWindow();
}
//! Public Method jsNode.removeChild()
//!     This method removes a child node from the calling node.
function _jsNode_removeChild(strObjectID) {
        var objRemovedNode = null;
        var arrNewChildNodes = new Array;
        for (var i=0; i < this.childNodes.length; i++) {
                if (this.childNodes[i].getObjectID() != strObjectID){
                        arrNewChildNodes[arrNewChildNodes.length] = this.childNodes[i];
                } else {
                        objRemovedNode = this.childNodes[i];
                }
        }
        this.childNodes = arrNewChildNodes;
        if (this.childNodes.length == 0) {
                this.expanded = false;
                this.hasChildNodes = false;
        }
        this.tree.getScrollPosition();
        this.tree.refresh();
        return objRemovedNode;
}
//! Public Method jsTree.deleteObject()
//!     This method removes all nodes with a given object ID from the tree.
function _jsTree_deleteObject(strObjectID) {
        if (this.nodemap[strObjectID]) {
                for (var i=0; i < this.nodemap[strObjectID].length; i++) {
                        var objParent = this.nodemap[strObjectID][i].parent;
                        objParent.removeChild(strObjectID);
                }
                delete this.nodemap[strObjectID];
                if (this.getSelectedNode().getObjectID() == strObjectID){
                        this.setSelectedNode(this.getSelectedNode().parent.nodeID);
                }
                this.doNavigate = true;
                this.getScrollPosition();
                this.refresh();
        }
}
//! Public Method jsNode.getObjectID()
//!     This method retrieves a printable version of the node
function _jsNode_getObjectID() {
        var strID = this.id;
        if (this.isNumericID) {
                strID = strID.substring(1, strID.length);
        }
        return strID;
}
//! Public Method jsTree.setSelectedNode()
function _jsTree_setSelectedNode(strNodeID) {	
        this.selectedID = strNodeID;
        var tempNode = this.nodes[strNodeID];
		linkClick(tempNode.nodeID);
        while (tempNode.parent) {
                if (!tempNode.parent.expanded){
                        tempNode.parent.expanded = true;
                }
                tempNode = tempNode.parent;
        }	
        this.getScrollPosition();
        this.refresh();
}
