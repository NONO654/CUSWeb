//=================================================================
// JavaScript Discussion Tree
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// History
//-----------------------------------------------------------------
// August 1, 2001 (Version 1.0)
// - Works in IE 4.0+ and Netscape 4.x. Not fully tested in Netscape 6.0/Mozilla.
//=================================================================

//=================================================================
// Part 1: Global Constants
//=================================================================
// This data in this section may be changed in order to customize
// the tab interface.
//=================================================================

//local copy of the tree
var localDiscussionTree = null;
var DIR_IMAGES = "../common/images/";

var DIR_DISC = DIR_IMAGES;
var DIR_SMALL_ICONS = DIR_IMAGES;

//images
var IMG_PLUS = DIR_DISC + "utilDiscussionPlus.gif";
var IMG_MINUS = DIR_DISC + "utilDiscussionMinus.gif"
var IMG_DISC_ICON = DIR_SMALL_ICONS + "iconSmallDiscussion.gif";

//indent size in pixels
var NODE_INDENT = 19;

//=================================================================
// Part 2: Discussion Classes and Class Methods
//=================================================================
// This section defines the objects that control the discussion control
// and should not be modified in any way.  Doing so could cause
// the discussion control to malfunction.
//=================================================================

//-----------------------------------------------------------------
// Class jsDiscussion
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This class is the base of the discussion tree.
//
// PARAMETERS
//  strStylesheet (String) - the style sheet to use for the discussion.
//-----------------------------------------------------------------

function jsDiscussion(strStylesheet) {

   //assign stylesheet (NCZ, 8/1/02)
  this.stylesheet = strStylesheet;
  
  //the root node of the tree (NCZ, 8/1/02)
  this.root = null;
  
  //scrolling information (NCZ, 8/1/02)
  this.scrollX = 0;
  this.scrollY = 0;
  
  //map of all nodes in the tree (NCZ, 8/1/02)
  this.nodes = new Array;
  
  //frame name (NCZ, 8/1/02)
  this.displayFrame = "discussionDisplay";
  
  //user preferences (NCZ, 8/1/02)
  this.expandAll = false;
  this.messageWidth = 500;
  
  //methods (NCZ, 8/1/02)
  this.draw = _jsDiscussion_draw;
  this.drawReply = _jsDiscussion_drawReply;
  this.drawMiscImages = _jsDiscussion_drawMiscImages;
  this.drawPlusMinusImage = _jsDiscussion_drawPlusMinusImage;
  this.getScrollPosition = _jsDiscussion_getScrollPosition;
  this.refresh = _jsDiscussion_refresh;
  this.createRoot = _jsDiscussion_createRoot;
  this.setScrollPosition = _jsDiscussion_setScrollPosition;
  this.toggleExpand = _jsDiscussion_toggleExpand; 
  this.drawLoadingMessage = _jsDiscussion_drawLoadingMessage;
  this.showReply = showReply;
  
  //save local copy of the tree (NCZ, 8/1/02)
  localDiscussionTree = this;
}

//-----------------------------------------------------------------
// Method jsDiscussion.draw()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods draws the tree onto the screen.
//
// PARAMETERS
//  (none)
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_draw() {

  //create string holder (NCZ, 8/1/02)
  var d = new jsDocument;

  //write the header (NCZ, 8/1/02)
  d.writeHTMLHeader(this.stylesheet);
  d.write("<body onload=\"parent.localDiscussionTree.setScrollPosition()\">");

  //draw the root, which recursively draws the rest of the tree (NCZ, 8/1/02)
  this.drawReply(d, this.root);
  
  //write the footer (NCZ, 8/1/02)
  d.writeHTMLFooter();

  //draw to the frame (NCZ, 8/1/02)
  with (frames[this.displayFrame].document) {
    open();
    write(d);
    close();
  }
}

//-----------------------------------------------------------------
// Method jsDiscussion.drawReply()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods draws an individual discussion reply.
//
// PARAMETERS
//  d (jsDocument) - the document object to write to.
//  objReply (jsReply) - node to draw image for.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_drawReply(d, objReply) {
  
  //spacer table (NCZ, 8/1/02)
  d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
  d.write(IMG_SPACER);
  d.write("\" width=\"1\" height=\"1\" border=\"0\" /></td></tr></table>");

  //begin outer table (used for background) (NCZ, 8/1/02)
  d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"reply\" width=\"100%\"><tr>");

  //determine what indent needs to be added (NCZ, 8/1/02)
  this.drawMiscImages(d, objReply);
  d.write("<td>");
  //begin inner table (NCZ, 8/1/02)
  d.write("<table border=\"0\" width=\"");
  d.write(this.messageWidth);
  d.write("\"><tr>");
  
  //get whether this node has children and if it's expanded or not (NCZ, 8/1/02)
  this.drawPlusMinusImage(d, objReply); 
  
  //draw the icon (NCZ, 8/1/02)
  d.write("<td valign=\"top\" width=\"16\"><img src=\"");
  d.write(IMG_DISC_ICON);
  d.write("\" border=\"0\" /></td><td width=\"");
  d.write((this.messageWidth - 16));
  d.write("\"><span class=\"subject\">");
  d.write(objReply.subject);
  d.write("</span><br><span class=\"message\">");
  d.write(objReply.message);
  d.write("</span><br><span class=\"author\">");
  d.write(objReply.author);
  d.write("</span>, <span class=\"date\">");
  d.write(objReply.date);
  d.write("</span><br />[ <a href=\"javascript:parent.showReply('");
  d.write(objReply.nodeID + "','" + objReply.messageId);
  d.write("')\">");
  d.write(emxUIConstants.STR_REPLY);
  d.write("</a> ] ");
  
  d.write(" [<a href=\"javascript:parent.showAttachments('" + objReply.messageId +"')\">");
  d.write(emxUIConstants.STR_ATTACH);
  // var STR_DELETE is defined in emxTeamDiscussionTreeFrame, check to show the "delete" link
  if(objReply.showDelete == "true") {
    d.write("</a> ] [<a href=\"javascript:parent.deleteReply('" + objReply.messageId +"')\">");
    d.write(STR_DELETE);
    d.write("</a>]</td>");
  }
  else {
    d.write("</a>]</td>");
  }
  
  //end inner table (NCZ, 8/1/02)
  d.write("</tr></table>");

  //end outer table (NCZ, 8/1/02)
  d.write("</td></tr></table>");
  //alert(objReply.date);
  //alert(objReply.messageId);
  //fun part, draw your children! (NCZ, 8/1/02)
  if (objReply.hasChildNodes && objReply.expanded){
    if (objReply.loaded) {
      for (var i=0; i < objReply.replies.length; i++)
        this.drawReply(d, objReply.replies[i]);
    } else {
      this.drawLoadingMessage(d, objReply);
    } 
  }  
}

//-----------------------------------------------------------------
// Method jsDiscussion.drawMiscImages()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods draws extra images for the specified node.
//
// PARAMETERS
//  d (jsDocument) - the document object to write to.
//  objReply (jsReply) - node to draw for.
//  iExtra (int) - extra indent for a given level (optional).
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_drawMiscImages(d, objReply, iExtra) {

  //no indent needed if root (NCZ, 8/1/02)
  if (objReply.indent > 0) {
  
    //stop at one before indent (NCZ, 8/1/02)
    var iIndents = objReply.indent;
    
    //cycle through indents (NCZ, 8/1/02)
    d.write("<td valign=\"top\" width=\"");
    d.write((NODE_INDENT * iIndents));
    d.write("\"><img src=\"");
    d.write(IMG_SPACER)
    d.write("\" width=\"");
    d.write((NODE_INDENT * (iIndents + (iExtra ? iExtra : 0))));
    d.write("\" height=\"16\" border=\"0\" /></td>");   
  }
}

//-----------------------------------------------------------------
// Method jsDiscussion.drawPlusMinusImage()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods draws a plus/minus image, or no image, depending on
// the state of the node.
//
// PARAMETERS
//  d (jsDocument) - the document object to write to.
//  objReply (jsReply) - node to draw image for.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_drawPlusMinusImage(d, objReply) {
  
  //begin cell (NCZ, 8/1/02)
  d.write("<td valign=\"top\" width=\"19\">");
  
  //begin link (NCZ, 8/1/02)
  if (objReply.hasChildNodes) {
    d.write("<a href=\"javascript:parent.clickPlusMinus('");
    d.write(objReply.nodeID);
    d.write("')\">");
  }
  
  //nasty part, figure out which graphic to use (NCZ, 8/1/02)
  d.write("<img src=\"");
  if (objReply.hasChildNodes) {
    if (objReply.expanded){
      d.write(IMG_MINUS);
    }else{
      d.write(IMG_PLUS);
    }  
  } else{
    d.write(IMG_SPACER);
  }  
    
   d.write("\" border=\"0\" width=\"19\" height=\"16\" />");
  
  if (objReply.hasChildNodes){
    d.write("</a>");
  }  
  //close up cell
  d.write("</td>");
}

//-----------------------------------------------------------------
// Method jsDiscussion.refresh()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods refreshes the view of the tree.
//
// PARAMETERS
//  (none)
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_refresh() {

  //save the current scroll position (NCZ, 8/1/02)
  localDiscussionTree.getScrollPosition();
  
  //redraw the tree (NCZ, 8/1/02)
  this.draw();

}

//-----------------------------------------------------------------
// Method jsDiscussion.createRoot()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods creates the root node of the discussion tree.
//
// PARAMETERS
//  strSubject (String) - the subject of the message.
//  strMessage (String) - the message text.
//  strAuthor (String) - the author of the message.
//  strDate (String) - the date of the message.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_createRoot(strSubject, strMessage, strAuthor, strDate,strMessageID) {

  //set the root (NCZ, 8/1/02)
  this.root = new jsReply(strSubject, strMessage, strAuthor, strDate,strMessageID);
  this.root.title = strSubject;
  this.root.text = strMessage;
  
  //make sure it's expanded (NCZ, 8/1/02)
  this.root.expanded = true;
  
  //set the tree (NCZ, 8/1/02)
  this.root.tree = this;
  
  //set ID (NCZ, 8/1/02)
  this.root.nodeID = "root";
  this.nodes["root"] = this.root;

}

//-----------------------------------------------------------------
// Method jsDiscussion.toggleExpand()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods expands/collapses a node's children.
//
// PARAMETERS
//  strNodeID (String) - the nodeID of the node to act on.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_toggleExpand(strNodeID) {

  //get the node (NCZ, 8/1/02)
  var objReply = this.nodes[strNodeID];
  
  //change the expansion (NCZ, 8/1/02)
  objReply.expanded = !objReply.expanded;
  
  //refresh the tree (NCZ, 8/1/02)
  this.refresh();

}

//-----------------------------------------------------------------
// Method jsDiscussion.getScrollPosition()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods gets the scrolling position of the window and saves it
// into a local variable.
//
// PARAMETERS
//  (none)
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_getScrollPosition() {
    if (!isIE) {
        this.scrollX = frames[this.displayFrame].pageXOffset;
        this.scrollY = frames[this.displayFrame].pageYOffset;
    } else {
        this.scrollX = frames[this.displayFrame].document.body.scrollLeft;
        this.scrollY = frames[this.displayFrame].document.body.scrollTop;
    }
}

//-----------------------------------------------------------------
// Method jsDiscussion.setScrollPosition()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods sets the scrolling position of the window.
//
// PARAMETERS
//  (none)
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_setScrollPosition() {
  frames[this.displayFrame].scrollTo(this.scrollX, this.scrollY);
}


//-----------------------------------------------------------------
// Method jsDiscussion.drawLoadingMessage()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods draws a loading message for a node if the node's
// children have not yet been loaded.
//
// PARAMETERS
//  d (jsDocument) - the document object to write to.
//  objReply (jsReply) - node to draw image for.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function _jsDiscussion_drawLoadingMessage(d, objReply) {

  //spacer table (NCZ, 8/1/02)
  d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
  d.write(IMG_SPACER);
  d.write("\" width=\"1\" height=\"1\" border=\"0\" /></td></tr></table>");

  //begin outer table (used for background) (NCZ, 8/1/02)
  d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"reply\" width=\"100%\"><tr>");

  //determine what indent needs to be added (NCZ, 8/1/02)
  this.drawMiscImages(d, objReply, 2);
  d.write("<td>");
  //begin inner table (NCZ, 8/1/02)
  d.write("<table border=\"0\"><tr>");
  //begin message (NCZ, 8/1/02)
  d.write("<td nowrap><img src=\"");
  d.write(IMG_LOADING); 
  d.write("\" border=\"0\" width=\"16\" height=\"16\"></td><td nowrap class=\"loading\">");
  d.write(emxUIConstants.STR_LOADING);
  d.write("</td></tr></table>"); 

  //end outer table (NCZ, 8/1/02)
  d.write("</td></tr></table>");
}

//-----------------------------------------------------------------
// Class jsReply
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This class represents a node in the discussion tree.
//
// PARAMETERS
//  strSubject (String) - the subject of the message.
//  strMessage (String) - the message text.
//  strAuthor (String) - the author of the message.
//  strDate (String) - the date of the message.
//  strExpandURL (String) - the URL to load this node's chidren (optional).
//  strID (String) - a unique identifier to use for this node (optional).
//-----------------------------------------------------------------

function jsReply (strSubject, strMessage, strAuthor, strDate, strMessageID, showDelete, strExpandURL, strID) {

  //properties (NCZ, 8/1/02)
  this.id = strID;
  this.subject = strSubject;
  this.message = strMessage;
  this.author = strAuthor;
  this.date = strDate;
  this.expandURL = strExpandURL;
  this.messageId = strMessageID;
  this.showDelete = showDelete;
  
  if (strExpandURL) {
    this.hasChildNodes = true;
    this.loaded = false
  } else {
    this.hasChildNodes = false;
    this.loaded = true;
  }
  
  //node ID assigned by JavaScript object itself (NCZ, 8/1/02)
  this.nodeID = "-1";
  
  //properties of replies (NCZ, 8/1/02)
  this.replies = new Array;
  this.expanded = false;
  this.parent = null;
  this.indent = 0;
  this.tree = null;
  
  //methods
  this.addChild = _jsReply_addChild;
}


//-----------------------------------------------------------------
// Method jsReply.addChild()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods adds a reply to the current reply in the discussion.
//
// PARAMETERS
//  strSubject (String) - the subject of the message.
//  strMessage (String) - the message text.
//  strAuthor (String) - the author of the message.
//  strDate (String) - the date of the message.
//  strExpandURL (String) - the URL to load the children for this reply (optional).
//  strID (String) - a unique identifier to use for this node. (optional)
//
// RETURNS
//  The jsReply object that was created.
//-----------------------------------------------------------------
   function _jsReply_addChild(strSubject, strMessage, strAuthor, strDate, strMessageID, showDelete, strExpandURL, strID) {

  //check for duplicates (NCZ, 8/1/02)
  //if (this.loaded && this != this.tree.root) return;
  
  //create the new node (NCZ, 8/1/02)
  var objReply = new jsReply(strSubject, strMessage, strAuthor, strDate,strMessageID, showDelete, strExpandURL, strID);
  
  //add the child to the array (NCZ, 8/1/02)
  this.replies[this.replies.length] = objReply;
  
  //set hasChildNodes flag (NCZ, 8/1/02)
  this.hasChildNodes = true;
    this.loaded = true;
  
  //set the parent (NCZ, 8/1/02)
  objReply.parent = this;
  
  //assign the tree (NCZ, 8/1/02)
  objReply.tree = this.tree;
  
  //assign expandAll (NCZ, 8/1/02)
  objReply.expanded = this.tree.expandAll;
  
  //set the indent (NCZ, 8/1/02)
  objReply.indent = this.indent + 1;

  //assign ID (NCZ, 8/1/02)
  objReply.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.replies.length - 1);

  //place into node map (NCZ, 8/1/02)
  //this.tree.nodes[strID] = objReply;
  this.tree.nodes[objReply.nodeID] = objReply;
  
  return objReply;
}


//-----------------------------------------------------------------
// Part 3: Event Handlers
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Function clickPlusMinus()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods  is the event handler for clicking the expand/collapse
// arrow in the discussion.
//
// PARAMETERS
//  strNodeID (String) - the ID of the node to act on.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function clickPlusMinus(strNodeID) {

  //expand the given node (NCZ, 8/1/02)
  localDiscussionTree.toggleExpand(strNodeID);

  //refresh the screen (NCZ, 8/1/02)
  localDiscussionTree.refresh();
  
  //check to see if data has to be loaded (NCZ, 8/1/02)
  if (localDiscussionTree.nodes[strNodeID].hasChildNodes && localDiscussionTree.nodes[strNodeID].expanded && !localDiscussionTree.nodes[strNodeID].loaded) {
    var strURL = localDiscussionTree.nodes[strNodeID].expandURL;
    strURL += (strURL.indexOf('?') > -1 ? '&amp;' : '?') + "jsTreeID=" + strNodeID;   
    frames[localDiscussionTree.displayFrame].document.location.href = strURL;
  
  }
}

//-----------------------------------------------------------------
// Function showReply()
//-----------------------------------------------------------------
// AUTHOR(S)
//  Nicholas C. Zakas (NCZ), 8/1/01
//
// EDITOR(S)
//
// DESCRIPTION
//  This methods shows the window to allow a user to reply.
//
// PARAMETERS
//  trNodeID (String) - the ID of the node to reply to.
//
// RETURNS
//  (nothing)
//-----------------------------------------------------------------
function showReply(strNodeID,messageId) {
//alert("here in js");
  //showModalDialog("emxTeamCreateDiscussionDialog.jsp?objectId=" + objectId,600,700);
//needs to be completed when the discussion is implemented.


}
