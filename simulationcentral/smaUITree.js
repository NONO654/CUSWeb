/*======================================================================
 * This file contains javascript functionality related to the tree used
 * in the LHS of the composer product.
 *
 * Copyright (c) Dassault_Systemes 2013
 *======================================================================
 */

/**
 * SMA Tree constructor. This assumes that the "top" contains the
 * objStructureTree.
 *
 * @param topFrame Top frame containing the object structure tree or
 *                 null in which case this method will get the tree
 *                 from "top".
 */
function smaUITree(topFrame)
{
   this.m_tree = (topFrame != undefined && topFrame != null)
                     ? topFrame.objStructureTree : getTopWindow().objStructureTree;
   this.m_HiddenFrame = findFrame(getTopWindow(), "hiddenFrame");
   this.m_qDebug = false;

   if ( this.m_qDebug )
   {
      console.debug("Tree Data");
      console.debug("  ID: " + this.m_tree.id);
      console.debug("  Menu Name: " + this.m_tree.menuName);
   }

   /**
    * Sets the display frame.
    *
    * @param frame Frame to be set as display frame.
    */
   this.setDisplayFrame = function(frame)
   {
      this.m_tree.displayFrame = frame;

   } // setDisplayFrame

   /**
    * Gets the display frame associated with the tree.
    */
   this.getDisplayFrame = function()
   {
      return this.m_tree.displayFrame;

   } // getDisplayFrame

   /**
    * Gets the tree node for the given object identifier.
    *
    * @param objId Object identifier.
    */
   this.getNode = function(objId)
   {
      return this.m_tree.findNodeByObjectID(objId);

   } // getNode

   /**
    * Sets the selected node.
    *
    * @param treeNode Tree node to be selected.
    * @param bReferesh true to refresh the tree immediately.
    */
   this.setSelected = function(treeNode, bRefresh)
   {
      this.m_tree.setSelectedNode(treeNode, bRefresh);

   } // setSelectedNode

   /**
    * Sets selected node and triggers click event on that node. This method
    * does it asynchronously.
    *
    * @param treeNode Tree node to be selected.
    * @param bReferesh true to refresh the tree immediately.
    */
   this.setSelectedWithClickAsync = function(treeNode, bRefresh, timeout)
   {
      if ( treeNode != null )
      {
         var tmout = (timeout == undefined) ? 0 : timeout;
         var ctx = this;
         setTimeout(function() {
               ctx.setSelected(treeNode, bRefresh);
               treeNode.handleClick('node');
         }, tmout);
      }
   }

} // smaUITree

/**
 * Expands the given node.
 *
 * @param treeNode Tree node to be expanded.
 */
smaUITree.prototype.expandNode = function _smaUITree_expandNode(treeNode)
{
   if ( treeNode != null )
   {
      this.printNode(treeNode);

      var treeFrame = this.getDisplayFrame();

      this.setDisplayFrame(this.m_HiddenFrame);
      treeNode.expand();
      this.setDisplayFrame(treeFrame);
   }

} // expandNode

/**
 * Prints information associated with the tree node to the console.
 *
 * @param treeNode Tree node whose information is to be printed.
 */
smaUITree.prototype.printNode = function _smaUITree_printNode(treeNode)
{
   if ( treeNode != null )
   {
      if ( this.m_qDebug )
      {
         console.debug("Path: " + treeNode.path);
         console.debug("  Class: " + treeNode.className);
         console.debug("  Indent: " + treeNode.indent);
         console.debug("  Expanded: " + treeNode.expanded);
         console.debug("  Html Text: " + treeNode.htmltext);
         console.debug("  Node ID: " + treeNode.nodeID);
         console.debug("  Text: " + treeNode.text);
         console.debug("  URL: " + treeNode.url);
         console.debug("  Command Name: " + treeNode.commandName);
         console.debug("  Load URL: " + treeNode.loadURL);
         console.debug("  Loaded: " + treeNode.loaded);
         console.debug("  Relation ID: " + treeNode.relID);
         console.debug("  Object ID: " + treeNode.objectID);
         console.debug("  Target: " + treeNode.target);
         console.debug("---------------------------------------");
      }
   }

} // printNode

/**
 * Expands all the given tree objects.
 *
 * @param objsStr Tree objects to be expanded. Comma separated string.
 * @param bSelFirst true to select the first node, false to select last.
 * <p>
 * Example: 1024.1234.4560,1025.1234.8780
 * </p>
 */
smaUITree.prototype.expandObjs = function _smaUITree_expandObjs(objsStr, bSelFirst)
{
   //
   // Split the comma separated object string into array.
   //
   var objs = objsStr.split(",");
   if ( objs.length > 0 )
   {
      //
      // Construct the treeExpand structure
      //
      var treeExpand = {
         objs: objs,
         ndx: 0,
         bSelFirst: bSelFirst,
         nTry: 5,
         cleanup: function() {
            var tobjs = this.objs;
            for(var i = 0; i < tobjs.length; ++i)
            {
               delete tobjs[i];
            }

            this.objs = null;
         }
      }

      this.expandObjects(treeExpand);
   }

} // expandObjs


/**
 * Refreshes the node with the given object identifier. Deletes all its
 * descendants and sets loaded flag to false, so that when the node
 * expands, it will fetch the data from the server.
 *
 * @param objId Object identifier associated with the tree node.
 */
smaUITree.prototype.refreshNode = function _smaUITree_refreshNode(objId)
{
   var treeNode = this.getNode(objId);
   var expanded = treeNode.expanded;

   //
   // Delete all the descendants of the tree node, which will set
   // the descendant nodes to be set as not loaded. This will
   // automatically trigger load call during expand. We expand
   // the tree node only if it was expanded. Otherwise, when user
   // clicks on the + it will automatically load the child nodes.
   //
   this.deleteDescendants(treeNode);

   treeNode.loaded = false;
   treeNode.expanded = false;

   //if ( expanded )
   //{
      this.expandNode(treeNode);
   //}

   //
   // Finally select the tree node with click event
   //
   this.setSelectedWithClickAsync(treeNode,false,0);

} // refreshNode

/**
 * Refreshes the node with the given object identifier. Deletes all its
 * descendants and sets loaded flag to false, so that when the node
 * expands, it will fetch the data from the server.
 *
 * @param objId Object identifier associated with the tree node.
 */
smaUITree.prototype.refreshNodeNoSelect = function _smaUITree_refreshNode(objId)
{
   var treeNode = this.getNode(objId);
   var expanded = treeNode.expanded;

   //
   // Delete all the descendants of the tree node, which will set
   // the descendant nodes to be set as not loaded. This will
   // automatically trigger load call during expand. We expand
   // the tree node only if it was expanded. Otherwise, when user
   // clicks on the + it will automatically load the child nodes.
   //
   this.deleteDescendants(treeNode);

   treeNode.loaded = false;
   treeNode.expanded = false;

   this.expandNode(treeNode);

} // refreshNode

/**
 * Expands the objects in the tree expand structure in a recursive fashion.
 *
 * @param treeExpand Tree expand structure.
 *
 * Private.
 */
smaUITree.prototype.expandObjects =
                    function _smaUITree_expandObjects(treeExpand)
{
   var objs = treeExpand.objs;
   var ndx = treeExpand.ndx;

   //
   // Check if we reached the end of the objects array, if so either
   // first or last node in the array
   //
   if ( objs.length == ndx )
   {
      if ( treeExpand.bSelFirst )
      {
         this.setSelectedWithClickAsync(this.getNode(objs[0]), true);
      }
      else
      {
         this.setSelectedWithClickAsync(
                            this.getNode(objs[objs.length-1]), true);
      }

      treeExpand.cleanup();

      return;
   }

   var treeNode = this.getNode(objs[ndx]);
   var ctx = this;

   if ( treeNode == null )
   {
      //
      // Tree node is null, try few times with some delay before
      // moving to the next node. The node that we are expanding
      // might not have been loaded yet. Expand is a lazy operation
      // that trigger server side call to load the node on the client
      // side javascript tree. If we dont succeed with expanding the
      // node after few tries move on to the next node.
      //
      if ( treeExpand.nTry > 0 )
      {
         treeExpand.nTry = treeExpand.nTry - 1;
         setTimeout(function() {
            ctx.expandObjects(treeExpand);
         }, 500);
      }
      else if ( treeExpand.nTry == 0 )
      {
         treeExpand.nTry = 5;
         treeExpand.ndx = ndx + 1;
         setTimeout(function() {
            ctx.expandObjects(treeExpand);
         }, 500);
      }
   }
   else
   {
      //
      // Good!. Found the tree node, now expand the node and move
      // to the next node.
      //
      treeNode.expand();

      treeExpand.nTry = 5;
      treeExpand.ndx = ndx + 1;
      setTimeout(function() {
         ctx.expandObjects(treeExpand);
      }, 500);
   }

} // expandObjects

/**
 * Deletes the descendant nodes of the given node. This function does not
 * delete the given node.
 *
 * @param treeNode Tree node to be whose descendants have to be deleted.
 *
 * Private.
 */
smaUITree.prototype.deleteDescendants =
                        function _smaUITree_deleteDescendants(treeNode)
{
   if ( treeNode == null )
   {
      return;
   }

   var children = treeNode.childNodes;
   if ( children != null )
   {
      for( var i = children.length-1; i > -1; --i)
      {
         var child = children[i];
         this.deleteDescendants(child);

         child.tree.deleteObject(child.objectID, false);
      }
   }

} // deleteDescendants

