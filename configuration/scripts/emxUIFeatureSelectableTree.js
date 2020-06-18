/*!================================================================
 *  JavaScript Selectable Tree
 *  emxUIFeatureSelectableTree.js
 *  Version 1.9
 *  Requires: emxUIConstants.js
 *  Last Updated: Sept 15,2007 By Sandeep Kathe(klw)
 *
 *  This file contains class definition for the selectable tree.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
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
var IMG_BUTTO_CHANNEL_EXPAND = DIR_APPLEVEL_IMAGES + "utilChannelEllipsis.gif";
var IMG_LINE_DISABLED_NODE_OPEN = DIR_APPLEVEL_IMAGES + "utilTreeLineLastClosedDisabled.gif";
var IMG_BLANK = DIR_APPLEVEL_IMAGES + "utilSubmenuArrowWhite.gif";


//! Class jsSelectableTree
//!     This object represents a selectable tree.
function jsSelectableTree(strStylesheet, bPropagate) {
        this.alertMessage = null;
        this.root = null;
        this.checkUrl = null;
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
		this.drawPlusMinusImage1 = _jsSelectableTree_drawPlusMinusImage1;
		this.drawBlankImage = _jsSelectableTree_drawBlankImage;
        this.drawPlusMinusImage = _jsSelectableTree_drawPlusMinusImage;
		this.drawPlusMinusDisableImage = _jsSelectableTree_drawPlusMinusDisableImage;
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
  
         if (this.firstLoad || this.multiSelect) {
                this.selectedID = "";
                this.firstLoad = false;
        }
		
		if(this.root==null){
			//alert('if');
			//alert("before draw child : "+getTopWindow().getWindowOpener().this.root);
			//top.getWindowOpener().tree
			//alert("before draw child : "+getTopWindow().getWindowOpener().tree.root);
			this.drawChild(d, getTopWindow().getWindowOpener().tree.root);
		}
		else{
       		this.drawChild(d, this.root);
		}
 			var objDIV = document.getElementById("mx_divSourceList"); 
			if (objDIV) { 
			
				objDIV.innerHTML =d.toString();
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
		if(parseInt(objNode.subFeatureCount) > parseInt(objNode.strFeatureLimit)) {
			this.drawPlusMinusImage1(d, objNode);
			this.drawPlusMinusDisableImage(d, objNode);
			//this.drawPlusMinusImage(d, objNode);
			
        }
		else{
			this.drawBlankImage(d, objNode);
			this.drawPlusMinusImage(d, objNode);
		}
		this.drawSelectControl(d, objNode);
        d.write("<td nowrap=\"nowrap\">");
 
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
				tempstr = "<td>"
				tempstr += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				tempstr += "</td>"
                tempstr += "<td class=\"node\"><img src=\"";
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
function _jsSelectableTree_drawBlankImage(d, objNode) {
		d.write("<td>");
		d.write("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		d.write("</td>");

		
}
function _jsSelectableTree_drawPlusMinusImage1(d, objNode) {
	

        if (objNode.indent < 1){
                return;
        }
        var par = objNode.parent;
        d.write("<td>");
		//if (objNode.hasChildNodes) {
        if((parseInt(objNode.subFeatureCount) > parseInt(objNode.strFeatureLimit))) {
                d.write("<a href=\"javascript:parent.clickPlusMinusx('");
                d.write(objNode.nodeID);
                d.write("')\">");
        }
		d.write("<img src=\"");
        if (objNode.isLast) {
                //if (!objNode.hasChildNodes){
                 if(!(parseInt(objNode.subFeatureCount) > parseInt(objNode.strFeatureLimit))) {
                        d.write(IMG_LINE_LAST);
                } else {
                        if (objNode.expanded){
                                d.write(IMG_BUTTO_CHANNEL_EXPAND);
                        } else {
                                d.write(IMG_BUTTO_CHANNEL_EXPAND);
                        }
                }
        } else {
                //if (!objNode.hasChildNodes){
                 if(!(parseInt(objNode.subFeatureCount) > parseInt(objNode.strFeatureLimit))) {
                        d.write(IMG_LINE_NODE);
                } else {
                        if (objNode.expanded){
                                d.write(IMG_BUTTO_CHANNEL_EXPAND);
                        } else {
                                d.write(IMG_BUTTO_CHANNEL_EXPAND);
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
function _jsSelectableTree_drawPlusMinusDisableImage(d, objNode) {
	

        if (objNode.indent < 1){
                return;
        }
        var par = objNode.parent;
		d.write("<td style=\"width: 0.1em;\">");
		//d.write("&#160")
		d.write("</td>");
        d.write("<td>");
		//d.write("&nbsp;")
        d.write("<img width=100% src=\"");
        //d.write(IMG_LINE_NODE_CLOSED);
		d.write(IMG_LINE_DISABLED_NODE_OPEN);
        d.write("\" border=\"0\" width=\"19\" height=\"19\" name=\"node");
        d.write(objNode.nodeID);
        d.write("\">");
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
                        d.write("<img src= \"");
                        d.write(IMG_CHECK_OFF);
                        d.write("\"/>");
                }
        } else {
                if (objNode.selectable){
                        d.write("<a href=\"");
                        d.write(strNodeURL);
                        d.write("\"><img src=\"");
                        d.write((objNode.nodeID == this.selectedID) ? IMG_RADIO_ON : IMG_RADIO_OFF);
                        d.write("\" border=\"0\" /></a>");
                } else {
                        d.write("<img src= \"");
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
	var objDIV = document.getElementById("mx_divSourceList"); 
	
    //    var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
        if (isNS4 || isMinMoz1) {
                this.scrollX = objDIV.scrollLeft;
                this.scrollY = objDIV.scrollTop;
        } else if (isIE) {
                this.scrollX = objDIV.scrollLeft;
                this.scrollY = objDIV.scrollTop;
        }
}
//! Private Method jsSelectableTree.setScrollPosition()
//!     This function sets the scrolling position of the window from the saved
//!     values.
function _jsSelectableTree_setScrollPosition() {
	var objDIV = document.getElementById("mx_divSourceList"); 
//        var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
//        objDIV.scrollTo(this.scrollX, this.scrollY);
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
// Added one more parameter strFLID for Bug No 374370 
function jsNode (strName, strIcon, strExpandURL, strObjectID,strFLID, strFormName, strFormValue, strSubFeatureCound,strFeatureLimit) {
        this.name = strName;
        //added for getting feature list
       // this.FLID = strFLID; // Bug No 374370
        //Begin :IR-022953V6R2011:Splitting FeatureList Id and Object type   
        if(strFLID != null && strFLID != ""){
        	
        	var cIndex 	= 	strFLID.indexOf(":~:");
        	if(cIndex > -1){
        		this.FLID 	=  	strFLID.substring(0,cIndex);
        		this.type 	= 	strFLID.substring(cIndex+3,strFLID.length);
        	}
        }
       //End :IR-022953V6R2011:Splitting FeatureList Id and object type
        
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
                this.loaded = false;
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
        this.level = 0 ; 
		this.subFeatureCount = strSubFeatureCound;
		this.strFeatureLimit = strFeatureLimit;
}
//! Public Method jsNode.addChild()
//!     This method adds a child node to the current node.
//Added one more parameter strFLID for Bug No 374370 
function _jsNode_addChild(strName, strIcon, strExpandURL, strObjectID,strFLID, strFormName, strFormValue, strSubFeatureCount, strCalledFrom, strFeatureLimit) {
		var URL="../configuration/FeatureStructureTree.jsp?strmode=findSubTypeFromId&rootType="+strObjectID;
		var isSubFeature = emxUICore.getData(URL);
        isSubFeature = isSubFeature.replace(/\s/g, "");
        if(isSubFeature == 'true')
	    {
	    	strIcon = "../common/images/iconSmallConfigurableFeature.gif";
	    }
	    else{
	    	strIcon = "../common/images/iconSmallProduct.gif";
	    }
	    strName += " ";
        // Added one more param, strFLID for Bug No 374370 
        var objNode = new jsNode(strName, strIcon, strExpandURL, strObjectID,strFLID, strFormName, strFormValue,strSubFeatureCount,strFeatureLimit);
        //if (this.childNodes[strName]) {
         //       return;
        //}
        this.childNodes[this.childNodes.length] = objNode;
        this.childNodes[strName] = objNode;
        if (strObjectID) {
                this.childNodes[strObjectID] = objNode;
        }
        this.hasChildNodes = true;
        objNode.parent = this;
        objNode.tree = this.tree;
        objNode.isLast = true;
        if (this.childNodes.length > 1) {
                this.childNodes[this.childNodes.length - 2].isLast = false;
        }
        objNode.indent = this.indent + 1;
        objNode.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.childNodes.length - 1);
        if (strObjectID) {
                this.tree.nodes[strObjectID] = objNode;
                if (this.tree.nodemap[strObjectID]) {
                        this.tree.nodemap[strObjectID][this.tree.nodemap[strObjectID].length] = objNode;
                } else {
                        this.tree.nodemap[strObjectID] = new Array(objNode);
                }
        }
        this.tree.nodes[objNode.nodeID] = objNode;
        this.tree.nodes[strName] = objNode;
      //  setTimeout("localSelectableTree.refresh()", 50);
		if(strCalledFrom=='addleft' || strCalledFrom=='addright'){
		
		var optn = document.createElement("OPTION");
		optn.text = objNode.parent.name+'~'+strName;
		//optn.value = objNode.parent.id+'~'+strObjectID; // Commented for Bug No 374370 
		//added for getting FL id instead of feature id based expression for Bug No 374370 
		optn.value = strFLID;
		if(strCalledFrom=='addleft'){
			//to fill data in left box start
			if(document.BCform){
				if(document.BCform.C1) {
				var featureOptionDetails = document.BCform.C1.checked;
				if(featureOptionDetails){
					//alert('true');
				}
				else{
					//alert('false');
					optn.text = strName;
					optn.value = strObjectID;
				}
				}
				document.BCform.LeftExpression.options.add(optn);
			}
			
			//to fill data in left box end
		}
		else{
			//to fill data in right box start
			if(document.BCform){
				if(document.BCform.C2) {
				var featureOptionDetails = document.BCform.C2.checked;
				if(featureOptionDetails){
					//alert('true');
				}
				else{
					//alert('false');
					optn.text = strName;
					optn.value = strObjectID;
				}
				}
				document.BCform.txtRightExpression.options.add(optn);
			}
			else{
				var featureOptionDetails = document.QRform.C2.checked;
				if(featureOptionDetails){
					//alert('true');
				}
				else{
					//alert('false');
					optn.text = strName;
					optn.value = strObjectID;
				}
				document.QRform.txtRightExpression.options.add(optn);
			}
			//to fill data in right box end
		}
		}
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
var strNodeID1 = null;
function clickPlusMinus(strNodeID) {
	strNodeID1 = strNodeID;
	var plusMinusCheck = localSelectableTree.nodes[strNodeID].expanded;
	if(!plusMinusCheck)
	{
		eval("addMask()");
	}
	eval("setTimeout(\"clickPlusMinus1()\", 10);");
}
	
function clickPlusMinus1() {
        localSelectableTree.getScrollPosition();
        localSelectableTree.toggleExpand(strNodeID1);
        localSelectableTree.refresh();
        if (localSelectableTree.nodes[strNodeID1].hasChildNodes && localSelectableTree.nodes[strNodeID1].expanded && !localSelectableTree.nodes[strNodeID1].loaded) 
        {		
                var strURL = localSelectableTree.nodes[strNodeID1].expandURL;
				localSelectableTree.nodes[strNodeID1].loaded=true;
                var vtest=emxUICore.getData(strURL);
    			var vIndex=vtest.indexOf("f");
     			var vtest=vtest.substring(vIndex,vtest.length);
     			if(vIndex=='-1'){
     				localSelectableTree.nodes[strNodeID1].hasChildNodes=false;
     				localSelectableTree.nodes[strNodeID1].expanded=true;
     			}	
				eval(vtest);
				localSelectableTree.refresh();
				
        }
        strNodeID1 = null;
        removeMask();
}

function clickPlusMinusx(strNodeID) {
	
	strNodeID1 = strNodeID;
	var plusMinusCheck = localSelectableTree.nodes[strNodeID].expanded;
	
	if(!plusMinusCheck)
	{
		//eval("addMask()");
	}
	eval("setTimeout(\"clickPlusMinus1x()\", 10);");
}
	
function clickPlusMinus1x() {
	//localSelectableTree.getScrollPosition();
        //localSelectableTree.toggleExpand(strNodeID1);
        //localSelectableTree.refresh();
        /*localSelectableTree.getScrollPosition();
        localSelectableTree.toggleExpand(strNodeID1);
        //localSelectableTree.refresh();
        if (localSelectableTree.nodes[strNodeID1].hasChildNodes && localSelectableTree.nodes[strNodeID1].expanded && !localSelectableTree.nodes[strNodeID1].loaded) 
        {		
                /*var strURL = localSelectableTree.nodes[strNodeID1].expandURL;
				localSelectableTree.nodes[strNodeID1].loaded=true;
                var vtest=emxUICore.getData(strURL);
    			var vIndex=vtest.indexOf("f");
     			var vtest=vtest.substring(vIndex,vtest.length);
     			if(vIndex=='-1'){
     				localSelectableTree.nodes[strNodeID1].hasChildNodes=false;
     				localSelectableTree.nodes[strNodeID1].expanded=true;
     			}
				eval(vtest);
				showDialog('http://www.yahoo.com');
				//localSelectableTree.refresh();
				
        }
        strNodeID1 = null;
        //removeMask();*/
		var strURL = localSelectableTree.nodes[strNodeID1].expandURL;
		localSelectableTree.nodes[strNodeID1].loaded=true;
		localSelectableTree.nodes[strNodeID1].expanded=true;
		//showDialog(strURL);
		showModalDialog(strURL, 780, 550,true);
		localSelectableTree.refresh();
}
//! Private Function linkClick()
//!     This function is the event handler for clicking on a link in the
//!     tree. It handles the navigation and the highlighting of the item.
function linkClick(strNodeID) {
	
        var objNode = localSelectableTree.nodes[strNodeID];
        localSelectableTree.selectedID = strNodeID;
	
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
//		alert("here");
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
                if (frames[1].document.forms[0] != null) {
                        frames[1].document.forms[0].action= target;
                        frames[1].document.forms[0].submit();
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
         strSeleOneItem = "Please Select One Item";
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
        parent.frames[1].frames[1].document.location.href = target + selnode.id;
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
        while (tempNode.parent) {
                if (!tempNode.parent.expanded){
                        tempNode.parent.expanded = true;
                }
                tempNode = tempNode.parent;
        }
        this.getScrollPosition();
        this.refresh();
}
