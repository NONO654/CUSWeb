/*!================================================================
 *  JavaScript Structure Tree
 *  emxUIStructureTree.js
 *  Version 1.0
 *  Requires: emxUIConstants.js, emxUIHistoryTree.js
 *  Last Updated: 21-Mar-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definitions for the structure tree
 *  navigator.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *
 *=================================================================
 */

/*=================================================================
 * emxUIStructureTree Class Definition
 *=================================================================
 */

//-----------------------------------------------------------------
//! Class emxUIStructureTree
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.0+
//      Netscape Navigator 4.x
//      Mozilla 1.0.1 + (Netscape 7.0+)
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 6-Jan-03
//
//  EDITOR(S)
//
// INHERITS FROM
//      emxUIHistoryTree
//
//  DESCRIPTION
//!     This class represents a structure navigation tree.
//
//  PARAMETERS
//      (none)
//-----------------------------------------------------------------
function emxUIStructureTree() {

        //---------------------------------------------------------------------------------
        // Inherit from emxUICoreTree
        //---------------------------------------------------------------------------------
        this.superclass = emxUIHistoryTree;
        this.superclass("emxUIStructureTree");
        delete this.superclass;
        //---------------------------------------------------------------------------------

        //---------------------------------------------------------------------------------
        // Private Properties
        //---------------------------------------------------------------------------------
        this.className = "emxUIStructureTree";          //override class name (NCZ, 6-Jan-03)
        this.stylesheet = getStyleSheet("emxUIStructureTree");    //stylesheet for the tree (NCZ, 6-Jan-03)
        //---------------------------------------------------------------------------------

        //---------------------------------------------------------------------------------
        // Protected Properties
        //---------------------------------------------------------------------------------
        this.menuName = "";                             //eMatrix menu name (NCZ, 6-Feb-03)
        this.selectedStructure = "";                    //eMatrix selected structure (NCZ, 6-Feb-03)
        this.structureMode = "";                        //eMatrix selected mode(details or structure) (JBB, 6-Feb-03)
        //---------------------------------------------------------------------------------

} //End: function emxUIStructureTree()

// inherit emxUIHistoryTree methods (NCZ, 21-Jan-03)
emxUIStructureTree.prototype = new emxUIHistoryTree("emxUIStructureTree");

//=================================================================
// emxUIStructureTreeNode Class Definition
//=================================================================

//-----------------------------------------------------------------
//! Class emxUIStructureTreeNode
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.0+
//      Netscape Navigator 4.x
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 6-Jan-03
//
//  EDITOR(S)
//
// INHERITS FROM
//      emxUIHistoryTreeNode
//
//  DESCRIPTION
//!     This class represents one node on the structure tree.
//
//  PARAMETERS
//      strObjectIcon (String) - the icon to display for the object. (NCZ, 6-Jan-03)
//      strObjectName (String) - text to display for the node. (NCZ, 6-Jan-03)
//      strObjectURL (String) - the URL for the object. (NCZ, 6-Jan-03)
//      strObjectTarget (String) - the target of the URL for the object. (NCZ, 6-Jan-03)
//      strExpandURL (String) - the URL that will load this node's children.
//              Use null if not needed (optional). (NCZ, 6-Jan-03)
//-----------------------------------------------------------------
function emxUIStructureTreeNode (strObjectIcon, strObjectName, strObjectURL, strObjectTarget, strObjectID, strExpandURL) {

        //---------------------------------------------------------------------------------
        // Inherit from emxUIHistoryTreeNode
        //---------------------------------------------------------------------------------
        this.superclass = emxUIHistoryTreeNode;
        this.superclass(strObjectIcon, strObjectName, strObjectURL, strExpandURL);
        delete this.superclass;
        //---------------------------------------------------------------------------------

        //---------------------------------------------------------------------------------
        // Private Properties
        //---------------------------------------------------------------------------------
        this.className = "emxUIStructureTreeNode";
        //---------------------------------------------------------------------------------

        //---------------------------------------------------------------------------------
        // Public Properties
        //---------------------------------------------------------------------------------
        this.objectID = strObjectID;                    //the object ID of the object (NCZ, 21-Jan-03)
        this.target = strObjectTarget;                  //the target for the object URL (NCZ, 6-Jan-03)
        //---------------------------------------------------------------------------------

} //End: function emxUIStructureTreeNode (strObjectIcon, strObjectName, strObjectURL, strObjectTarget, strExpandURL)

//  inherit emxUIHistoryTreeNode methods (NCZ, 6-Jan-03)
emxUIStructureTreeNode.prototype = new emxUIHistoryTreeNode;

//-----------------------------------------------------------------
//! Public Method emxUIStructureTreeNode.addRelationshipTo()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.0+
//      Netscape Navigator 4.x
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 17-Jun-03
//
//  EDITOR(S)
//
//
//  DESCRIPTION
//!     This method adds the given node as a child under all
//!     nodes that match this node's object ID.
//!     This method is considered PUBLIC and MAY
//!     be used by developers.
//
//  PARAMETERS
//      objNode (emxUIStructureTreeNode) - the node to add.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUIStructureTreeNode.prototype.addRelationshipTo = function _emxUIStructureTreeNode_addRelationshipTo(objNode) {

        //get the object that represents this node (NCZ, 17-Jun-03)
        var objObject = this.tree.objects[this.objectID];

        //duplicate the node and add it to the object node (NCZ, 17-Jun-03)
        for (var i=0; i < objObject.nodes.length; i++) {
        	    var objNewNode = null;
        	    if(objNode.expandURL == undefined)
        	    	objNewNode = eval("new " + objNode.className + "(objNode.icon, objNode.text, objNode.url, objNode.target, objNode.objectID, objNode.loadURL)");
        	    else
        	    	objNewNode = eval("new " + objNode.className + "(objNode.icon, objNode.text, objNode.url, objNode.target, objNode.objectID, objNode.expandURL)");
        	    objNewNode.structureTreeClick = objNode.structureTreeClick;
                objObject.nodes[i].addChild(objNewNode);

        } //End: for

}; //End: emxUIStructureTreeNode.prototype.addRelationshipTo = function _emxUIStructureTreeNode_addRelationshipTo(objNode)

//-----------------------------------------------------------------
//! Private Method emxUIStructureTreeNode.getNodeHTML()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.0+
//      Netscape Navigator 4.x
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 6-Jan-03
//
//  EDITOR(S)
//
//  OVERRIDES
//      emxUICoreTreeNode.getNodeHTML()
//
//  DESCRIPTION
//!     This method creates the HTML that represents the node part (icon
//!     and text only). This method is considered PRIVATE and MAY NOT
//!     be used by developers.
//
//  PARAMETERS
//      (none)
//
//  RETURNS
//      An HTML string.
//-----------------------------------------------------------------
emxUIStructureTreeNode.prototype.emxUIHistoryTreeNodeGetNodeHTML = emxUIStructureTreeNode.prototype.getNodeHTML;
emxUIStructureTreeNode.prototype.getNodeHTML = function _emxUIStructureTreeNode_getNodeHTML() {

        //create string buffer (NCZ, 28-Aug-02)
        var d = new jsDocument;

        //determine CSS class (NCZ, 21-Jan-03)
        this.cssClass = (this.tree.getSelectedNode() == this) ? "selected" : "";

        //call original method (NCZ, 8-Jan-03)
        d.write(this.emxUIHistoryTreeNodeGetNodeHTML());

        //get the location of the tree object (NCZ, 6-Jan-03)
        var strLoc = (getTopWindow().trees && getTopWindow().trees[this.tree.id]) ? "getTopWindow()" : "parent";

        //add the Remove button and the Move to Top Button if this isn't the current root (NCZ, 8-Jan-03)
        if (this != this.tree.currentRoot) {
                d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].setCurrentRoot('");
                d.write(this.nodeID);
                d.write("', true);\"><img src=\"");
                d.write(DETAILS_TREE.IMG_UP);
                d.write("\" border=\"0\" alt=\"");
                d.write(emxUIConstants.STR_MOVE_TO_TOP);
                d.write("\"/></a></td>");
        } else if (this.tree.history.length > 0){
                d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strLoc + ".trees['");
                d.write(this.tree.id);
                d.write("'].back()\"><img src=\"");
                d.write(DETAILS_TREE.IMG_BACK);
                d.write("\" border=\"0\" alt=\"");
                d.write(emxUIConstants.STR_BACK);
                d.write("\" /></a></td>");
        } //End: if (this != this.tree.currentRoot)

        //return the string (NCZ, 6-Jan-03)
        return d.toString();

}; //End: emxUIStructureTreeNode.prototype.getNodeHTML = function ()

//-----------------------------------------------------------------
//! Public Method emxUIStructureTreeNode.removeRelationshipTo()
//-----------------------------------------------------------------
//  BROWSER(S)
//      Internet Explorer 5.0+
//      Netscape Navigator 4.x
//
//  AUTHOR(S)
//      Nicholas C. Zakas (NCZ), 17-Jun-03
//
//  EDITOR(S)
//
//
//  DESCRIPTION
//!     This method removes the nodes with the given objectID
//!     from all nodes with the current node's object ID.
//!     This method is considered PUBLIC and MAY
//!     be used by developers.
//
//  PARAMETERS
//      strObjectID (String) - the object ID of the node remove.
//
//  RETURNS
//      (nothing)
//-----------------------------------------------------------------
emxUIStructureTreeNode.prototype.removeRelationshipTo = function _emxUIStructureTreeNode_removeRelationshipTo(strObjectID) {

        //get the object that represents the node to be removed (NCZ, 17-Jun-03)
        var objObjectToRemove = this.tree.objects[strObjectID];

        // If objObjectToRemove is undefined, then it means nothing to be deleted from the tree.
        if(objObjectToRemove){
        //cycle through the nodes to find out which one has a parent with
        //the same object ID as this node (NCZ, 17-Jun-03)
        for (var i=objObjectToRemove.nodes.length-1; i > -1; i--) {
                if (objObjectToRemove.nodes[i].parent &&
                    objObjectToRemove.nodes[i].parent.objectID == this.objectID) {

                        objObjectToRemove.nodes[i].parent.removeChildByID(objObjectToRemove.nodes[i].nodeID, false);

                } //End: if (objObjectToRemove.nodes[i].parent && ...)

        } //End: for

        //refresh the tree (NCZ, 17-Jun-03)
        this.tree.refresh();
        }

}; //End: emxUIStructureTreeNode.prototype.removeRelationshipTo = function _emxUIStructureTreeNode_removeRelationshipTo()
