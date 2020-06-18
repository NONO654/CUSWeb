//=================================================================
// JavaScript Tree Structure
// by Nicholas C. Zakas
//=================================================================
// Version 2.0 - May 23, 2001
// - Redesigned without attaching lines.  Streamlined functions.
// - Added nodes array to tree, removed getNode and findChildById.
// Version 1.0 - March 28, 2001
// - Works in Netscape 4.x, Netscape 6, and IE 4.0+.
//=================================================================

//=================================================================
// Part 1: Base Objects
//=================================================================
// These objects are used by the tab control for various functions.
// Nothing in this section should be modified or else major errors
// will occur.
//=================================================================

//-----------------------------------------------------------------
// Object jsDocument
// This object is used to eliminate overhead for string concatentation.
//-----------------------------------------------------------------
function jsDocument() {
	this.text = new Array();		//array to store the string
	this.write = function (str) { this.text[this.text.length] = str; }
	this.writeln = function (str) { this.text[this.text.length] = str + "\n"; }
	this.toString = function () { return this.text.join(""); }
	this.writeHTMLHeader = function (strStylesheet) {
			this.write("<html><head>");
			this.write("<link rel=\"stylesheet\" href=\"");
			this.write(strStylesheet);
			this.writeln("\">");
			this.write("</head>");
	}
	this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + ">"); }
	this.writeHTMLFooter = function () { this.writeln("</body></html>"); }
}

//=================================================================
// Part 2: Global Constants
//=================================================================
// This data in this section may be changed in order to customize
// the tab interface.
//=================================================================

//local copy of the tree
var localTree = null;

//directories
// var DIR_TREE = DIR_IMAGES + "tree/";
var DIR_TREE = DIR_IMAGES;

//images
var IMG_LOADING = DIR_TREE + "loading.gif";

//tree images (lines version)
var IMG_LINE_VERT = DIR_TREE + "LineVert.gif";
var IMG_LINE_LAST = DIR_TREE + "LineLast.gif";
var IMG_LINE_LAST_OPEN = DIR_TREE + "LineLastOpen.gif";
var IMG_LINE_LAST_CLOSED = DIR_TREE + "LineLastClosed.gif";
var IMG_LINE_NODE = DIR_TREE + "LineNode.gif";
var IMG_LINE_NODE_OPEN = DIR_TREE + "LineNodeOpen.gif";
var IMG_LINE_NODE_CLOSED = DIR_TREE + "LineNodeClosed.gif";

//tree images (no lines version)
var IMG_PLUS = DIR_TREE + "Plus.gif";
var IMG_MINUS = DIR_TREE + "Minus.gif";

//
var NODE_INDENT = 19;

//=================================================================
// Part 3: Tab Control Objects and Object Methods
//=================================================================
// This section defines the objects that control the tab control
// and should not be modified in any way.  Doing so could cause
// the tab control to malfunction.
//=================================================================

//-----------------------------------------------------------------
// Object jsTree
// This object represents the tree.
//
// Parameters:
//	strStylesheet (String) - a stylesheet to use.
//-----------------------------------------------------------------
function jsTree(strStylesheet,treeFrame) {

	//assign stylesheet
	this.stylesheet = DIR_STYLES + strStylesheet;
	
	//the root node of the tree
	this.root = null;
	
	//nodeID of selected item
	this.selectedID = "root";
	
	//shows lines?
	this.showLines = false;
	
	//scrolling information
	this.scrollX = 0;
	this.scrollY = 0;
	
	//map of all nodes in the tree
	this.nodes = new Array;
	
	//frame name
	this.displayFrame = treeFrame;
	
	//methods
	this.draw = _jsTree_draw;
	this.drawChild = _jsTree_drawChild;
	this.drawLoadingMessage = _jsTree_drawLoadingMessage;
	this.drawMiscImages = _jsTree_drawMiscImages;
	this.drawPlusMinusImage = _jsTree_drawPlusMinusImage;
	this.getScrollPosition = _jsTree_getScrollPosition;
	this.refresh = _jsTree_refresh;
	this.createRoot = _jsTree_createRoot;
	this.addChild = _jsTree_createRoot;
	this.setScrollPosition = _jsTree_setScrollPosition;
	this.toggleExpand = _jsTree_toggleExpand;	
	
	//save local copy of the tree
	localTree = this;
}

//-----------------------------------------------------------------
// Function _jsTree_draw()
// This function draws the tree.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	node (jsnode) - the node to draw for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_draw() {

	//create string holder
	var d = new jsDocument;

	//write the header
	d.writeHTMLHeader(this.stylesheet);
	d.write("<body onload=\"parent.localTree.setScrollPosition()\">");

	
	//draw the root, which will recrusively draw the tree
	this.drawChild(d, this.root);

	//write the footer
	d.writeHTMLFooter();
	
	//draw to the frame
	with (frames[this.displayFrame].document) {
		open();
		write(d);
		close();
	}
}

//-----------------------------------------------------------------
// Method _jsTree_drawChild()
// This function draws an individual node onto a jsDocument.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	node (jsnode) - node to draw image for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_drawChild(d, node) {

	//begin table
	d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
	
	if (!this.showLines || (node.indent > 0)) {
		//determine what needs to be added
		this.drawMiscImages(d, node);
		
		//get whether this node has children and if it's expanded or not
		this.drawPlusMinusImage(d, node);
	}
	

	//begin link
	/*d.write("<td nowrap><a href=\"");
	d.write(node.url);
	d.write("\" target=\"");
	d.write(node.target)
	d.write("\">");*/
	d.write("<td nowrap=\"nowrap\"><a href=\"javascript:parent.linkClick('");
	d.write(node.nodeID);
	d.write("')\">");
	
	//draw the node image
	d.write("<img src=\"");
	d.write(node.icon); 
	d.write("\" border=\"0\" width=\"16\" height=\"16\">");
	
		
	//close link and the cell
	d.write("</a></td><td nowrap=\"nowrap\" "); 
	
	//determine class	
	if (node.parent == null) {
		if (this.selectedID == "root")
			d.write("class=\"rootSelected\" ");
		else
			d.write("class=\"root\" ");
	} else {
		if (this.selectedID == node.nodeID)
			d.write("class=\"selected\" ");
	}

	//determine class for the text link, this is rough
	/*d.write(">&nbsp;<a href=\"");
	d.write(node.url);
	d.write("\" target=\"");
	d.write(node.target)
	d.write("\">");*/
	d.write(">&nbsp;<a href=\"javascript:parent.linkClick('");
	d.write(node.nodeID);
	d.write("')\">");
	//cut up the string to appropriate length
	d.write(node.name);

	//close up link and table
	d.writeln("</a>&nbsp;</td></tr></table>");
	
	if (!this.showLines) {
		//spacer table
		d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
		d.write(IMG_SPACER);
		d.write("\" width=\"1\" height=\"3\" border=\"0\"></td></tr></table>");	
	}
	
	//fun part, draw your children!
	if (node.hasChildNodes && node.expanded) {
		if (node.loaded) {
			for (var i=0; i < node.childNodes.length; i++)
				this.drawChild(d, node.childNodes[i]);
		} else {
				this.drawLoadingMessage(d, node);
		}
	}
	//all done
}

//-----------------------------------------------------------------
// Function _jsTree_drawMiscImages()
// This function draws extra images for the specified node.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	objNode (jsNode) - the node to draw.
//	iIndent (int) - extra indents.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_drawMiscImages(d, objNode, iIndent) {

	//fix null iIndent
	if (!iIndent) iIndent = 0;
	
	if (this.showLines) {	
		var str="", tempstr="";
		var cur = objNode, par = objNode.parent;
		var i=0;
		
		//no indent needed if root or top level
		if (objNode.indent < 2 && iIndent == 0)
			return;
			
		//add spacers
		while (i < objNode.indent - 1) {
		
			//begin cell
			tempstr = "<td class=\"node\"><img src=\"";
			
			if ((cur.isLast && par.isLast) || (!cur.isLast && par.isLast))
				tempstr += IMG_SPACER;
			else
				tempstr += IMG_LINE_VERT;
			tempstr += "\" width=\"19\" height=\"16\" border=\"0\"></td>"
			
			cur = par;
			par = par.parent;
			i++;
			
			str = tempstr + str;
		}
		
		d.write(str);

		if (iIndent > 0) {
			d.write("<td class=\"node\"><img src=\"");
			d.write(IMG_SPACER)
			d.write("\" width=\"");
			d.write((NODE_INDENT * iIndent));
			d.write("\" height=\"16\" border=\"0\"></td>");		
		}
	} else {
		//no indent needed if root
		if (objNode.indent > 0) {
			d.write("<td class=\"node\"><img src=\"");
			d.write(IMG_SPACER)
			d.write("\" width=\"");
			d.write((NODE_INDENT * (objNode.indent + iIndent - 1)));
			d.write("\" height=\"16\" border=\"0\"></td>");		
		}	
	}
}

//-----------------------------------------------------------------
// Function _jsTree_drawPlusMinusImage
// This function draws a plus/minus image, or no image, depending on
// the state of the node.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	node (jsnode) - node to draw image for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_drawPlusMinusImage(d, node) {
	if (node.indent < 1)
		return;
	
	var par = node.parent;			//pointer to parent
	
	//begin cell
	d.write("<td>");
	
	//begin link
	if (node.hasChildNodes) {
		d.write("<a href=\"javascript:parent.clickPlusMinus('");
		d.write(node.nodeID);
		d.write("')\">");
	}
	
	//nasty part, figure out which graphic to use
	d.write("<img src=\"");
	
	if (this.showLines) {
		//if this node is the last in the list
		if (node.isLast) {
			if (!node.hasChildNodes)
				d.write(IMG_LINE_LAST);
			else {
				if (node.expanded)
					d.write(IMG_LINE_LAST_OPEN);
				else
					d.write(IMG_LINE_LAST_CLOSED);	
			}
		} else {
			if (!node.hasChildNodes)
				d.write(IMG_LINE_NODE);
			else {
				if (node.expanded)
					d.write(IMG_LINE_NODE_OPEN);
				else
					d.write(IMG_LINE_NODE_CLOSED);
			}
		}	
	} else {
		if (node.hasChildNodes) {
			if (node.expanded)
				d.write(IMG_MINUS);
			else
				d.write(IMG_PLUS);
		} else
			d.write(IMG_SPACER);	
	}
	
	 d.write("\" border=\"0\" width=\"19\" height=\"16\" name=\"node");
	 d.write(node.nodeID);
	 d.write("\">");
	
	if (node.hasChildNodes)
		d.write("</a>");
		
	//close up cell
	d.write("</td>");
}

//-----------------------------------------------------------------
// Function _jsTree_drawLoadingMessage
// This function draws a loading message for a node if the node's
// children have not yet been loaded.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	objNode (jsNode) - node to draw image for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_drawLoadingMessage(d, objNode) {

	d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
	
	//determine what needs to be added
	this.drawMiscImages(d, objNode, 2);

	//begin link
	d.write("<td nowrap><img src=\"");
	d.write(IMG_LOADING); 
	d.write("\" border=\"0\" width=\"16\" height=\"16\"></td><td nowrap class=\"loading\">");
	d.write(STR_LOADING);
	d.write("</td></tr></table>"); 

	//spacer table
	d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
	d.write(IMG_SPACER);
	d.write("\" width=\"1\" height=\"3\" border=\"0\"></td></tr></table>");
}

//-----------------------------------------------------------------
// Function _jsTree_refresh()
// This refreshes the view of the tree.
//
// Parameters:
//	none.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_refresh() {

	tree.draw();

}

//-----------------------------------------------------------------
// Function _jsTree_createRoot()
// This function creates the root node of the tree.
//
// Parameters:
//	strName (String) - the text to display for the node.
//	strURL (String) - the url to link to.
//	strTarget (String) - the name of the window to put the URL into.
//	strIcon (String) - the image file to use (without the directory.
//	strID (String) - a unique identifier to use for this node.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_createRoot(strName, strURL, strTarget, strIcon, strID) {

	//set the root
	this.root = new jsNode(strName, strURL, strTarget, strIcon, strID);
	
	//make sure it's expanded
	this.root.expanded = true;
	
	//set the tree
	this.root.tree = this;
	
	//set ID
	this.root.nodeID = "root";
	this.nodes["root"] = this.root;

}

//-----------------------------------------------------------------
// Method _jsTree_toggleExpand()
// This function expand/collapse a node's children.
//
// Parameters:
//	strNodeID (String) - the nodeID of the node to act on.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_toggleExpand(strNodeID) {

	//get the node
	var node = this.nodes[strNodeID];
	
	//change the expansion
	node.expanded = !node.expanded;
	
	//refresh the tree
	this.refresh();

}

//-----------------------------------------------------------------
// Method _jsNode_getScrollPosition()
// This function gets the scrolling position of the window and saves it
// into a local variable.
//
// Parameters:
//	none.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_getScrollPosition() {
    if (document.layers) {
        this.scrollX = frames[this.displayFrame].pageXOffset;
        this.scrollY = frames[this.displayFrame].pageYOffset;
    } else if (document.all) {
        this.scrollX = frames[this.displayFrame].document.body.scrollLeft;
        this.scrollY = frames[this.displayFrame].document.body.scrollTop;
    }
}

//-----------------------------------------------------------------
// Method _jsNode_setScrollPosition()
// This function sets the scrolling position of the window
//
// Parameters:
//	none.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTree_setScrollPosition() {
	frames[this.displayFrame].scrollTo(this.scrollX, this.scrollY);
}

//-----------------------------------------------------------------
// Object jsNode
// This object represents one node on the tree.
//
// Parameters:
//	strName (String) - the text to display for the node.
//	strURL (String) - the url to link to.
//	strTarget (String) - the name of the window to put the URL into.
//	strIcon (String) - the image file to use (without the directory.
//	strID (String) - a unique identifier to use for this node.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function jsNode (strName, strURL, strTarget, strIcon, strExpandURL, strID) {
	
	//properties
	this.name = strName;
	this.icon = DIR_SMALL_ICONS + strIcon;
	this.url = strURL;
	this.expandURL = strExpandURL;
	this.target = strTarget;
	this.nodeID = "-1";
	this.isLast = false;
	this.id = strID;
	
	if (strExpandURL) {
		this.hasChildNodes = true;
		this.loaded = false
	} else {
		this.hasChildNodes = false;
		this.loaded = true;
	}


	this.childNodes = new Array;
	this.expanded = false;
	this.parent = null;
	this.indent = 0;
	this.tree = null;
	
	//methods
	this.addChild = _jsNode_addChild;
}


//-----------------------------------------------------------------
// Method _jsNode_addChild()
// This function is the event handler for clicking the expand/collapse
// arrow in the discussion.
//
// Parameters:
//	strName (String) - the text to display for the node.
//	strURL (String) - the url to link to.
//	strTarget (String) - the name of the window to put the URL into.
//	strIcon (String) - the image file to use (without the directory)
//	strID (String) - a unique identifier to use for this node.
// Returns:
//	The jsNode object that was created.
//-----------------------------------------------------------------
function _jsNode_addChild(strName, strURL, strTarget, strIcon, strExpandURL, strID) {

	//create the new node
	var node = new jsNode(strName, strURL, strTarget, strIcon, strExpandURL, strID);
	
	//add the child to the array
	this.childNodes[this.childNodes.length] = node;
	
	//set hasChildNodes flag
	this.hasChildNodes = true;
	
	//set the parent
	node.parent = this;
	
	//assign the tree
	node.tree = this.tree;
	
	//change the last info
	node.isLast = true;

	if (this.childNodes.length > 1)
		this.childNodes[this.childNodes.length - 2].isLast = false;
	
	//set the indent
	node.indent = this.indent + 1;

	//assign ID
	node.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.childNodes.length - 1);

	//place into node map
	if (strID)
		this.tree.nodes[strID] = node;
	this.tree.nodes[node.nodeID] = node;
	this.tree.nodes[strName] = node;
	
	return node;
}


//-----------------------------------------------------------------
// Part 3: Event Handlers
//-----------------------------------------------------------------


//-----------------------------------------------------------------
// Function clickPlusMinus()
// This function is the event handler for clicking the expand/collapse
// arrow in the discussion.
//
// Parameters:
//	nodeID (String) - the ID of the node to act on.
// Returns:
//	nothing.
// Used as:
//	clickPlusMinus[String]);
//-----------------------------------------------------------------
function clickPlusMinus(nodeID) {

	//save the current scroll position
	localTree.getScrollPosition();
	
	//expand the given node
	localTree.toggleExpand(nodeID);


	//refresh the screen
	localTree.refresh();
	
	//check to see if data has to be loaded
	if (localTree.nodes[nodeID].hasChildNodes && localTree.nodes[nodeID].expanded && !localTree.nodes[nodeID].loaded) {
		var strURL = localTree.nodes[nodeID].expandURL;
		
		strURL += (strURL.indexOf('?') > -1 ? '&' : '?') + "jsTreeID=" + nodeID;
		
		frames[localTree.displayFrame].document.location.href = strURL;
	
	}
}

function linkClick(strNodeID) {
	var strURL = localTree.nodes[strNodeID].url;
	var strTarget = localTree.nodes[strNodeID].target;
	strURL += (strURL.indexOf('?') > -1 ? '&' : '?') + "jsTreeID=" + strNodeID;
	localTree.selectedID = strNodeID;
	frames[strTarget].document.location.href = localTree.nodes[strNodeID].url 
	setTimeout("localTree.refresh()", 50);
}
