<%--  MCADTreeTableInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
//Include information related to browser and client platform
<%@ include file ="scripts/IEFUIConstants.js" %>

//Global Variables Start
var treeControlObject	= null;
var selectedNode		= null;
//Global Variables End

//Constants Start
//define classes used to style tree and table as elements of array
jsStyles = new Array;

//background color of tables
jsStyles[0] = "body { background-color: #ffffff; }";

//default font family,color,size
jsStyles[1] = "body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }";

jsStyles[2] = "a { color: #003366; text-decoration: none; }";

//bar heading across top of both frames
jsStyles[3] = "td.heading { background-color: #336699;font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;color:#ffffff}";

//text within cells not within links
jsStyles[4] = "td.tableValue { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;color:#003366}";

//selected row/table backcolor
jsStyles[5] = "tr.selected { background-color: #ffffcc}";
jsStyles[6] = "table.selected { background-color: #ffffcc}";
jsStyles[7] = "a:hover { }";
jsStyles[8] = "td.root { }";
jsStyles[9] = "td.root a { font-weight: bold; text-decoration: underline; }";
jsStyles[10] = "td.root a:hover { }";
jsStyles[11] = "td.line { background-color:#dedede }";

//Colors
var WHITE_COLOR			= "#FFFFFF";
var GRAYED_OUT_COLOR	= "#E8E8E8";

//directories
var DIR_IMAGES = "./images/";

//tree images defined here
var IMG_LOADING					= DIR_IMAGES + "utilLoading.gif";
var IMG_SPACER					= DIR_IMAGES + "utilTreeSpacer.gif";
var IMG_LINE_VERT				= DIR_IMAGES + "utilLineVert.gif";
var IMG_LINE_LAST				= DIR_IMAGES + "utilLineLast.gif";
var IMG_LINE_LAST_OPEN			= DIR_IMAGES + "utilLineLastOpen.gif";
var IMG_LINE_LAST_CLOSED		= DIR_IMAGES + "utilLineLastClosed.gif";
var IMG_LINE_NODE				= DIR_IMAGES + "utilLineNode.gif";
var IMG_LINE_NODE_OPEN			= DIR_IMAGES + "utilLineNodeOpen.gif";
var IMG_LINE_NODE_CLOSED		= DIR_IMAGES + "utilLineNodeClosed.gif";
var IMG_SPACE					= DIR_IMAGES + "utilSpace.gif";
var IMG_ICON_FILE				= DIR_IMAGES + "iconFile.gif";
var IMG_ICON_TREE_TO_ARROW		= DIR_IMAGES + "iconTreeToArrow.gif";
var IMG_ICON_TREE_FROM_ARROW	= DIR_IMAGES + "iconTreeFromArrow.gif";
var IMG_ICON_PREVIEW			= DIR_IMAGES + "iconPreview.gif";
var IMG_ICON_NEW_WINDOW			= DIR_IMAGES + "iconActionNewWindow.gif";
var IMG_ICON_DEPENDENT_DOC		= DIR_IMAGES + "iconDependentDocuments.gif";
var IMG_ICON_LOCKED				= DIR_IMAGES + "iconLocked.gif";
var IMG_ICON_UNLOCKED			= DIR_IMAGES + "iconUnLocked.gif";
var IMG_ICON_LOCKED_NOT_LATEST	= DIR_IMAGES + "iconLockedNotLatest.gif";

// indent in pixels
var NODE_INDENT = 19;

//table form object controls types
var COTROL_HIDDEN_TYPE      = "Hidden";
var COTROL_LABEL_TYPE       = "Label";
var COTROL_EDITBOX_TYPE     = "EditBox";
var COTROL_CHECKBOX_TYPE    = "CheckBox";
var COTROL_COMBOBOX_TYPE    = "ComboBox";
//Constants End

//Global Classes Start
//Baseline document class Start
function jsDocument() 
{
	this.text = new Array();		//array to store the string
	this.write = function (str) { this.text[this.text.length] = str; }
	this.writeln = function (str) { this.text[this.text.length] = str + "\n"; }
	this.toString = function () { return this.text.join(""); }

	this.writeHTMLHeader = function () 
	{
		this.write("<html><head>");
		this.writeln("");
		this.writeln("<style type=text/css >");
		for (var i=0; i < jsStyles.length; i++) 
		{
		  this.writeln(jsStyles[i]);
		}
		this.writeln("</style>");
		this.writeln("");
		this.write("</head>");
	}
	this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + " >"); }
	this.writeHTMLFooter = function () { this.writeln("</body></html>"); }
}
//Baseline document class End

//TreeControl Class Start
function TreeControl(headerColumnsArray, noOfColumns, selectionRequired)
{
    //properties
    this.columnsArray				= headerColumnsArray;
	this.selectionRequired			= selectionRequired;
    this.treeControlNodes			= new Array;
    this.rootNode					= null;
	this.heading					= null;
	this.numOfCols					= noOfColumns;
    this.scrollX					= 0;
    this.scrollY					= 0;
    
    //methods
	this.draw						= TreeControl_draw;
	this.toggleExpand				= TreeControl_toggleExpand;
    this.getRootNode                = TreeControl_getRootNode;
    this.getTreeControlNodes        = TreeControl_getTreeControlNodes;
    this.replaceChildNode           = TreeControl_replaceChildNode;
    this.openAll                    = TreeControl_openAll;
    this.refresh                    = TreeControl_refresh;
	this.clean						= TreeControl_clean;
}

function TreeControl_getRootNode()
{
	var tableHeader = "<td align='left' height='18' width='<%=integSessionData.getPropertyValue("mcadIntegration.Server.ColumnName.Name")%>' class=heading nowrap >&nbsp;<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name")%>&nbsp;</td><td class=heading>&nbsp;</td>";

    this.heading = tableHeader + getTableHeader(this.columnsArray);
    
    this.rootNode = new TreeControlNode("root", null, null, "root", "root", "root", true, false, null);

	this.rootNode.expanded = true;
	this.rootNode.loaded = true;

    treeControlObject = this;
    
    return this.rootNode;
}

function TreeControl_getTreeControlNodes()
{
    return this.treeControlNodes;
}

function TreeControl_draw() 
{
	//check for error
	if (this.rootNode) 
	{
		//create string holder
		var d = new jsDocument;

		//write the header
		d.writeHTMLHeader();

  	    d.write("<body leftmargin=0 marginwidth=0 onResize=\"parent.reloadTable(this)\" >");
		d.write("<table cellpadding=0 cellspacing=0 border=0 >");
		d.write("<tr>" + this.heading + "</tr>");
		
		for(var i=0; i<this.rootNode.childNodes.length; i++)
		{
		    drawChild(d, this.rootNode.childNodes[i]);
		}

        d.write("</table>");

        d.write("<div id=\"tooltip\" style=\"position:absolute;visibility:hidden;border:1px solid black;width:250px;font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;color:#003366\" ></div>");

		//write the footer
		d.writeHTMLFooter();

		//draw to the frame
		with (frames['tableDisplay'].document) 
		{    
			open();
			write(d);

			if(!isIE)
			{
				close();
			}
		}
	} 
	else 
	{
		alert("<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Message.CriticalErrorRootNotSpecified")%>");
	}

	return;
}

function TreeControl_replaceChildNode(strID, nodeName, mcadID, isLocked, makeNodeGrayed, relationshipArrow, relationshipColumnValues)
{
    var oldTreeControlNode		= this.treeControlNodes[strID];
    var parentTreeControlNode	= oldTreeControlNode.parentNode;

	var childNode = parentTreeControlNode.replaceChild(strID, nodeName, mcadID, isLocked, makeNodeGrayed, relationshipArrow, relationshipColumnValues);
    
    this.treeControlNodes[strID] = childNode;
    
    return childNode;
}

function TreeControl_toggleExpand(strNodeID) 
{
	//Store frame coordinates in order to restore the frame position after refresh
	if (frames['tableDisplay'].document.layers) 
    {
        this.scrollX = frames['tableDisplay'].pageXOffset;
        this.scrollY = frames['tableDisplay'].pageYOffset;
    } 
    else if (frames['tableDisplay'].document.all) 
    {
        this.scrollX = frames['tableDisplay'].document.body.scrollLeft;
        this.scrollY = frames['tableDisplay'].document.body.scrollTop;
    }

	//get the node
	var node = this.treeControlNodes[strNodeID];
	//change the expansion
	node.expanded = !node.expanded;
	
	return;
}

function TreeControl_openAll(isOpen)
{
    for(var nodeId in this.treeControlNodes)
    {
        var tableNode   = this.treeControlNodes[nodeId].tableNode;
        
        tableNode.expanded  = isOpen;
    }
    
    //this.refresh();
}

function TreeControl_refresh()
{  
    this.draw();
	frames['tableDisplay'].scrollTo(this.scrollX, this.scrollY);
}

function TreeControl_clean()
{ 
    treeControlObject	= null;
	selectedNode		= null;
}
//TreeControl Class End

//TreeControlNode Class Start
function TreeControlNode(strID, strIcon, strRelImage, strName, mcadID, strRootId, boolHasChildren, makeNodeGrayed, relationshipColumnValues)
{
    //properties
    this.nodeID     = strID;
    this.parentNode = null;
    this.childNodes = new Array;

	this.name = strName;
	this.isLast = false;
	
	this.mcadID						= mcadID;
	this.picked						= false;
	this.makeNodeGrayed				= makeNodeGrayed;
	this.relationshipColumnValues	= relationshipColumnValues;

	//Tree cell images
	this.icon		= strIcon;
    this.relImage	= strRelImage;

    if (boolHasChildren) 
    {
		this.hasChildNodes = true;
		this.loaded = false
	} 
	else 
	{
		this.hasChildNodes = false;
		this.loaded = true;
	}

    this.rootId = strRootId;
    this.selected = false;

	this.expanded = false;
	this.indent = 0;
    
    //methods
    this.addChild       = TreeControlNode_addChild;
	this.replaceChild   = TreeControlNode_replaceChild;
	this.getForm        = TreeControlNode_getForm;
}

function TreeControlNode_addChild(strID, nodeName, mcadID, lockStatus, makeNodeGrayed, relationshipArrow, relationshipColumnValues)
{
	var lockStatusIcon = IMG_SPACE;
	if(lockStatus == "locked")
		lockStatusIcon = IMG_ICON_LOCKED;
	else if(lockStatus == "lockedNotLatest")
		lockStatusIcon = IMG_ICON_LOCKED_NOT_LATEST;
	else if(lockStatus == "unlockedNotLatest")
		lockStatusIcon = IMG_ICON_UNLOCKED_NOT_LATEST;
	else if(lockStatus =="unlocked")
		lockStatusIcon = IMG_ICON_UNLOCKED;

	if(relationshipArrow == "BottomUp")
		relationshipArrow = IMG_ICON_TREE_FROM_ARROW;
	else
		relationshipArrow = IMG_ICON_TREE_TO_ARROW;

    var childNode = new TreeControlNode(strID, lockStatusIcon, relationshipArrow, nodeName, mcadID, "root", false, makeNodeGrayed, relationshipColumnValues);
    
	this.hasChildNodes		= true;
	childNode.parentNode	= this;
	childNode.isLast		= true;
	childNode.indent		= this.indent + 1;

	this.childNodes[this.childNodes.length]		= childNode;
    treeControlObject.treeControlNodes[strID]	= childNode;

	if (this.childNodes.length > 1)
		this.childNodes[this.childNodes.length - 2].isLast = false;

    return childNode;
}

function TreeControlNode_replaceChild(strID, nodeName, mcadID, lockStatus, makeNodeGrayed, relationshipArrow, relationshipColumnValues) 
{
	var lockStatusIcon = IMG_ICON_UNLOCKED;
	if(lockStatus == "locked")
		lockStatusIcon = IMG_ICON_LOCKED;
	else if(lockStatus == "lockedNotLatest")
		lockStatusIcon = IMG_ICON_LOCKED_NOT_LATEST;

	if(relationshipArrow == "BottomUp")
		relationshipArrow = IMG_ICON_TREE_FROM_ARROW;
	else
		relationshipArrow = IMG_ICON_TREE_TO_ARROW;

	var node = new TreeControlNode(strID, lockStatusIcon, relationshipArrow, nodeName, mcadID, "root", false, makeNodeGrayed, relationshipColumnValues);
	
	//replace the child in the array
	var replacedNode = replaceNodeInChildNodes(this.childNodes, node);
	
	//set hasChildNodes flag
	this.hasChildNodes = true;
	
	//set the parent
	node.parentNode = this;
	
	//change the last info
	node.isLast = replacedNode.isLast;

	//set the indent
	node.indent = this.indent + 1;

	treeControlObject.treeControlNodes[strID] = node;

	return node;
}
//TreeControlNode class End
//Global Classes End

//Miscellaneous functions Start
function drawChild(d, node) 
{
	var backGroungColor = WHITE_COLOR;

	if(node.makeNodeGrayed)
		backGroungColor = GRAYED_OUT_COLOR;

	//begin table
	if (node.selected == true)
	{
	  d.write("<tr class=selected bgcolor=" + backGroungColor + ">");
	}
	else
	{
	  d.write("<tr bgcolor=" + backGroungColor + ">");
    }

	getTreeCell(d, node);

	//node.name has complete formatting including <td> tags
	var formData = node.getForm();
	d.write(formData);

	//close up link and table
	d.writeln("</tr>");

	//small lines under table rows
	d.writeln("<tr><td class=line colspan=" + (treeControlObject.numOfCols + 1) + " ><img src=images/utilSpace.gif width=1 height=1></td></tr>");


	//fun part, draw your children!
	if (node.hasChildNodes && node.expanded) 
	{
		if (node.loaded) 
		{
			for (var i=0; i < node.childNodes.length; i++)
				this.drawChild(d, node.childNodes[i]);
		} 
		else 
		{
				top.window.status = "LOADING...";
		}
	}

    return;
}

function getTreeCell(d, node)
{
	d.write("<td nowrap HEIGHT=24>&nbsp;");

	if (node.indent > 0) 
	{
		//determine what needs to be added
		drawMiscImages(d, node);

		//get whether this node has children and if it's expanded or not
		drawPlusMinusImage(d, node);
	}

	//draw relationship arrow with link
	var children_found = true;
	if ((node.relImage == null) && (node.indent > 0))
	{
		children_found = false;
    }

	if (children_found && node.indent > 0)
	{
		d.write("<img src=" + node.relImage + " border=0  align=absmiddle >");
    }

	d.write("<a href=\"javascript:parent.setActive('" + node.nodeID + "')\">");
	
	d.write("<img src=\"");
	d.write(node.icon);
	d.write("\" border=\"0\" width=\"16\" height=\"16\" align=absmiddle>&nbsp;");
	
	d.write("</a>");

	var nodeName = getNodeName(node);
	d.write(nodeName);

	d.writeln("</td>");

	d.writeln("<td><img src=\"" + IMG_LINE_VERT + "\" width=\"16\" height=\"24\" ></td>");
}

function drawMiscImages(d, node) 
{
	var str="", tempstr="";
	var cur = node, par = node.parentNode;
	var i=0;

	//no indent needed if root or top level
	if (node.indent < 2)
	{
		return;
	}

	//add spacers
	while (i < node.indent - 1) 
	{
		//begin cell
		tempstr = "<img src=\"";

		if ((cur.isLast && par.isLast) || (!cur.isLast && par.isLast))
			tempstr += IMG_SPACER;
		else
			tempstr += IMG_LINE_VERT;
			
		tempstr += "\" width=\"19\" height=\"16\" border=\"0\"  align=absmiddle >&nbsp;"

		cur = par;
		par = par.parentNode;
		i++;

		str = tempstr + str;
	}
	d.write(str);

	return;
}

function drawPlusMinusImage(d, node) 
{
	var par = node.parentNode;		//pointer to parent

	//begin link
	if (node.hasChildNodes) 
	{
		d.write("<a href=\"javascript:parent.syncFrames('");
		d.write(node.nodeID);
		d.write("')\" >");
	}

	//nasty part, figure out which graphic to use
	d.write("<img src=\"");

	//if this node is the last in the list
	if (node.isLast) 
	{
		if (!node.hasChildNodes)
			d.write(IMG_LINE_LAST);
		else 
		{
			if (node.expanded)
				d.write(IMG_LINE_LAST_OPEN);
			else
				d.write(IMG_LINE_LAST_CLOSED);
		}
	} else 
	{
		if (!node.hasChildNodes)
			d.write(IMG_LINE_NODE);
		else 
		{
			if (node.expanded)
				d.write(IMG_LINE_NODE_OPEN);
			else
				d.write(IMG_LINE_NODE_CLOSED);
		}
	}

	d.write("\" border=\"0\" width=\"19\" height=\"16\" name=\"node");
	d.write(node.nodeID);
	d.write("\"  align=absmiddle alt=\"Click +/- to Expand/Collapse\">&nbsp;");

	if (node.hasChildNodes)
		d.write("</a>");

	return;
}

function getSelectControlOptions(selectedValue, optionsArray)
{
    var optionsString = "";
    for(var i=0; i<optionsArray.length; i++)
    {
        var option = optionsArray[i];
        if(option == selectedValue)
        {
            optionsString = optionsString + "<option value=\"" + option + "\" selected>" + option + "</option>";
        }
        else
        {
            optionsString = optionsString + "<option value=\"" + option + "\">" + option + "</option>";
        }
    }
    
    return optionsString;
}

function replaceNodeInChildNodes(childNodes, node)
{
	var childNode = null;

    for(var i=0; i< childNodes.length; i++)
    {
        childNode = childNodes[i];
        if(childNode.nodeID == node.nodeID)
        {
            childNodes[i] = node;
            break;
        }
    }

	return childNode;
}
//Miscellaneous functions End

//Window event handlers start
window.onresize=resizeWindow;
function resizeWindow()
{
	if(treeControlObject)
		treeControlObject.refresh();
}

function syncFrames(nodeID) 
{
	//mark as selected
	treeControlObject.treeControlNodes[nodeID].selected = true;

    if (selectedNode)
    {
		if (selectedNode != nodeID)
		{
			//toggle selectedNode to false
			treeControlObject.treeControlNodes[selectedNode].selected = false;
		}
	}

	//set selectedNode
	selectedNode = nodeID;

	//expand the given node
	treeControlObject.toggleExpand(nodeID);
	
	treeControlObject.refresh();

	return;
}

function setActive(strNodeId)
{
    var isInitialSelected = treeControlObject.treeControlNodes[strNodeId].selected;
    
    if(isInitialSelected == false)
    {
	    treeControlObject.treeControlNodes[strNodeId].selected = true;
	}
	else
	{
	    treeControlObject.treeControlNodes[strNodeId].selected = false;
	}

    //check if selectedNode exists
	if (selectedNode)
	{
		if (selectedNode != strNodeId)
		{
			treeControlObject.treeControlNodes[selectedNode].selected = false;
		}
	}
    
    if(isInitialSelected == false)
    {
        selectedNode = strNodeId;
	}
	else
	{
	    selectedNode = null;
	}

	treeControlObject.refresh();

	return;
}

function reloadTable(documentObject)
{
	treeControlObject.refresh();
}
//Window event handlers End
