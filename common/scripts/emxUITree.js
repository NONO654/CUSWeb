//=================================================================
// JavaScript File - emxUITree.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
// AUTHOR(S)
//      Nicholas C. Zakas (NCZ)
// static const char RCSID[] = $Id: emxUITree.js.rca 1.23 Wed Oct 22 15:48:00 2008 przemek Experimental przemek $
//=================================================================

var localTree = null;
var IMG_LINE_VERT = DIR_TREE + "utilTreeLineVert.gif";
var IMG_LINE_LAST = DIR_TREE + "utilTreeLineLast.gif";
var IMG_LINE_LAST_OPEN = DIR_TREE + "utilTreeLineLastOpen.gif";
var IMG_LINE_LAST_CLOSED = DIR_TREE + "utilTreeLineLastClosed.gif";
var IMG_LINE_NODE = DIR_TREE + "utilTreeLineNode.gif";
var IMG_LINE_NODE_OPEN = DIR_TREE + "utilTreeLineNodeOpen.gif";
var IMG_LINE_NODE_CLOSED = DIR_TREE + "utilTreeLineNodeClosed.gif";
var IMG_PLUS = DIR_TREE + "utilTreePlus.gif";
var IMG_MINUS = DIR_TREE + "utilTreeMinus.gif";
var NODE_INDENT = 19;
function jsTree(strStylesheet, strURLParams) {
    this.stylesheet = DIR_STYLES + strStylesheet;
        this.urlParams = new Array;
        if (strURLParams) {
                strURLParams = ( strURLParams.indexOf("?") == 0 ? strURLParams.substring(1, strURLParams.length) : strURLParams);
                this.urlParams = strURLParams.split("&");
    }
    this.root = null;
    this.dirty = false;
    this.firstLoad = true;
    this.selectedID = "root";
    this.showLines = true;
    this.scrollX = 0;
  this.scrollY = 0;
    this.nodes = new Array;
    this.nodemap = new Array;
    this.doNavigate = true;
    this.displayFrame = "treeDisplay";
  this.target = "detailsDisplay";
    this._targetFrame = null;
  this._displayFrame = null;
    this.processing = false;
    this.draw = _jsTree_draw;
  this.drawChild = _jsTree_drawChild;
  this.drawLoadingMessage = _jsTree_drawLoadingMessage;
  this.drawMiscImages = _jsTree_drawMiscImages;
  this.drawPlusMinusImage = _jsTree_drawPlusMinusImage;
  this.getScrollPosition = _jsTree_getScrollPosition;
  this.refresh = _jsTree_refresh;
  this.createRoot = _jsTree_createRoot;
  this.addChild = _jsTree_createRoot;
  this.removeNode = _jsTree_removeNode;
  this.deleteObject = _jsTree_deleteObject;
  this.setScrollPosition = _jsTree_setScrollPosition;
  this.setSelectedNode = _jsTree_setSelectedNode;
  this.toggleExpand = _jsTree_toggleExpand;
  this.clear = function () {
    this.nodes = new Array;
    this.nodemap = new Array;
    this.dirty = false;
    this.firstLoad = true;
    this.doNavigate = true;
    this.selectedID = "root";
  }
  this.navigate = function () {
    setTimeout("linkClick(localTree.selectedID)", 50);
  }
  this.getSelectedNode = function () {
    return this.nodes[this.selectedID];
  }
    localTree = this;
}
function _jsTree_draw() {
        var strTreeLoc = ( getTopWindow().localTree ? "getTopWindow()" : "parent");
    var d = new jsDocument;
    d.writeHTMLHeader(this.stylesheet);
  d.write("<body onload=\"" + strTreeLoc + ".localTree.setScrollPosition()\"");
          d.write(">");
    this.drawChild(d, this.root);
    d.writeHTMLFooter();
    this._displayFrame = findFrame(getTopWindow(), this.displayFrame);
    with (this._displayFrame.document) {
    open();
    write(d);
    close();
  }
      if (this.doNavigate || this.firstLoad) {
    this.navigate();
    this.doNavigate = false;
    this.firstLoad = false;
  }
    if (isNS4 || isNS6)
    this.setScrollPosition();
}
function _jsTree_drawChild(d, objNode) {
        var strTreeLoc = ( getTopWindow().localTree ? "getTopWindow()" : "parent");
    d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
  if (!this.showLines || (objNode.indent > 0)) {
        this.drawMiscImages(d, objNode);
        this.drawPlusMinusImage(d, objNode);
  }
        if(objNode.hyperLink)      d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strTreeLoc + ".linkClick('");
  else      d.write("<td nowrap=\"nowrap\"><a href=\"javascript:" + strTreeLoc + ".clickPlusMinus('");
  d.write(objNode.nodeID);
  d.write("')\">");
    d.write("<img src=\"");
  d.write(objNode.icon);
  d.write("\" border=\"0\" width=\"16\" height=\"16\">");
    d.write("</a></td><td nowrap=\"nowrap\" ");
    if (objNode.parent == null) {
    if (this.selectedID == "root")
      d.write("class=\"rootSelected\" ");
    else
      d.write("class=\"root\" ");
  } else {
    if (this.selectedID == objNode.nodeID)
      d.write("class=\"selected\" ");
  }
        if(objNode.hyperLink)         d.write(">&nbsp;<a href=\"javascript:" + strTreeLoc + ".linkClick('");    else      d.write(">&nbsp;<a href=\"javascript:" + strTreeLoc + ".clickPlusMinus('");
  d.write(objNode.nodeID);
  d.write("')\">");
    d.write(objNode.getName());
    d.writeln("</a>&nbsp;</td></tr></table>");
  if (!this.showLines) {
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
    d.write(IMG_SPACER);
    d.write("\" width=\"1\" height=\"3\" border=\"0\"></td></tr></table>");
  }
    if (objNode.hasChildNodes && objNode.expanded) {
    if (objNode.loaded) {
      for (var i=0; i < objNode.childNodes.length; i++)
        this.drawChild(d, objNode.childNodes[i]);
    } else {
        this.drawLoadingMessage(d, objNode);
    }
  }
  }
function _jsTree_drawMiscImages(d, objNode, iIndent) {
    if (!iIndent) iIndent = 0;
    if (this.showLines) {
    var str="", tempstr="";
    var cur = objNode, par = objNode.parent;
    var i=0;
        if (objNode.indent < 2 && iIndent == 0)
      return;
        while (i < objNode.indent - 1) {
            tempstr = "<td class=\"node\"><img src=\"";
            if ((isLastNode(cur) && isLastNode(par)) || (!isLastNode(cur) && isLastNode(par)))
        tempstr += IMG_SPACER;
      else
        tempstr += IMG_LINE_VERT;
      tempstr += "\" width=\"19\" height=\"19\" border=\"0\"></td>"
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
        if (objNode.indent > 1) {
      d.write("<td class=\"node\"><img src=\"");
      d.write(IMG_SPACER)
      d.write("\" width=\"");
      d.write((NODE_INDENT * (objNode.indent + iIndent - 1)));
      d.write("\" height=\"16\" border=\"0\"></td>");
    }
  }
}
function _jsTree_drawPlusMinusImage(d, objNode) {
  if (objNode.indent < 1)
    return;
        var strTreeLoc = ( getTopWindow().localTree ? "getTopWindow()" : "parent");
      var par = objNode.parent;
    d.write("<td>");
        if (objNode.hasChildNodes) {
    d.write("<a href=\"javascript:" + strTreeLoc + ".clickPlusMinus('");
    d.write(objNode.nodeID);
    d.write("')\">");
  }
    d.write("<img src=\"");
  if (this.showLines) {
            if (isLastNode(objNode)) {
      if (!objNode.hasChildNodes)
        d.write(IMG_LINE_LAST);
      else {
        if (objNode.expanded)
          d.write(IMG_LINE_LAST_OPEN);
        else
          d.write(IMG_LINE_LAST_CLOSED);
      }
    } else {
      if (!objNode.hasChildNodes)
        d.write(IMG_LINE_NODE);
      else {
        if (objNode.expanded)
          d.write(IMG_LINE_NODE_OPEN);
        else
          d.write(IMG_LINE_NODE_CLOSED);
      }
    }
  } else {
    if (objNode.hasChildNodes) {
      if (objNode.expanded)
        d.write(IMG_MINUS);
      else
        d.write(IMG_PLUS);
    } else
      d.write(IMG_SPACER);
  }
   d.write("\" border=\"0\" width=\"19\" height=\"19\" name=\"node");
   d.write(objNode.nodeID);
   d.write("\">");
  if (objNode.hasChildNodes)
    d.write("</a>");
    d.write("</td>");
}
function _jsTree_drawLoadingMessage(d, objNode) {
  d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");
    this.drawMiscImages(d, objNode, 2);
    d.write("<td nowrap><img src=\"");
  d.write(IMG_LOADING);
  d.write("\" border=\"0\" width=\"16\" height=\"16\"></td><td nowrap class=\"loading\">");
  d.write(emxUIConstants.STR_LOADING);
  d.write("</td></tr></table>");
    d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
  d.write(IMG_SPACER);
  d.write("\" width=\"1\" height=\"3\" border=\"0\"></td></tr></table>");
}
function _jsTree_removeNode(strNodeID) {
    var objNode = this.nodes[strNodeID];
    var objParent = objNode.parent;
    var arrTemp = new Array;
    for (var i=0; i < objParent.childNodes.length; i++)
    if (objParent.childNodes[i].id != strNodeID && objParent.childNodes[i].nodeID != strNodeID)
      arrTemp[arrTemp.length] = objParent.childNodes[i];
    objParent.childNodes = arrTemp;
    return objNode;
}
function _jsTree_refresh() {
  this.draw();
}
function _jsTree_createRoot(strName, strURL, strIcon, strID,strMenuName) {
    this.root = new jsNode(strName, strURL, strIcon, null, strID,strMenuName);
    this.root.expanded = true;
    this.root.tree = this;
    this.root.nodeID = "root";
    this.nodes["root"] = this.root;
}
function _jsTree_toggleExpand(strNodeID) {
    var node = this.nodes[strNodeID];
    node.expanded = !node.expanded;
    this.getScrollPosition();
    this.refresh();
}
function _jsTree_getScrollPosition() {
    var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
    if (isNS4 || isNS6) {
        this.scrollX = win.pageXOffset;
        this.scrollY = win.pageYOffset;
    } else if (isIE) {
        this.scrollX = win.document.body.scrollLeft;
        this.scrollY = win.document.body.scrollTop;
    }
}
function _jsTree_setScrollPosition() {
  var win = this._displayFrame || findFrame(getTopWindow(), this.displayFrame);
  win.scrollTo(this.scrollX, this.scrollY);
}
function _jsTree_setSelectedNode(strNodeID) {
    this.selectedID = strNodeID;
    var tempNode = this.nodes[strNodeID];
    while (tempNode.parent) {
    if (!tempNode.parent.expanded)
      tempNode.parent.expanded = true;
    tempNode = tempNode.parent;
  }
    this.getScrollPosition();
    this.refresh();
}
function _jsTree_deleteObject(strObjectID, bRefresh) {
        bRefresh = (bRefresh == null ? true : bRefresh);
        if (this.nodemap[strObjectID]) {
                for (var i=0; i < this.nodemap[strObjectID].length; i++) {
                        var objParent = this.nodemap[strObjectID][i].parent;
                        objParent.removeChild(strObjectID , bRefresh);
        }                 delete this.nodemap[strObjectID];
                        if (this.getSelectedNode().getObjectID() == strObjectID)
            this.setSelectedNode(this.getSelectedNode().parent.nodeID);
                this.doNavigate = true;
                this.getScrollPosition();
                if (bRefresh) {
            this.refresh();
        }     } }
function jsNode (strName, strURL, strIcon, strExpandURL, strObjectID, strRelID,strMenuName) {
    strName = strName.replace("<", "&lt;");
  strName = strName.replace(">", "&gt;");
      if (strName == parseInt(strName)) {
    this.isNumericName = true;
    this.name = " " + strName;
  } else {
    this.name = strName;
    this.isNumericName = false;
  }
  if((strIcon.substring(1,8)) == "servlet")
    this.icon = strIcon;
  else
    this.icon = DIR_SMALL_ICONS + strIcon;
  this.url = strURL;
  this.expandURL = strExpandURL;
  this.nodeID = "-1";
  this.id = strObjectID;
  this.relID = strRelID;
  this.commandName=strMenuName;
      if(strURL)
    this.hyperLink = true;
  else
    this.hyperLink = false;

    this.nodeScopeID = new Array;
      var bCanExpand = strExpandURL;
  if (bCanExpand) {
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
    this.addChild = _jsNode_addChild;
  this.getName = _jsNode_getName;
  this.getChild = _jsNode_getChild;
  this.hasDuplicateChild = _jsNode_hasDuplicateChild;
  this.getObjectID = _jsNode_getObjectID;
  this.setName = _jsNode_setName;
  this.setObjectID = _jsNode_setObjectID;
  this.changeObjectName = _jsNode_changeObjectName;
  this.changeObjectID = _jsNode_changeObjectID;
  this.removeChild = _jsNode_removeChild;
    this.addNodeScopeID = _jsTree_addNodeScopeID;
}
function _jsNode_addChild(strName, strURL, strIcon, strExpandURL, strObjectID, strRelID,strCommandName) {
        if (this.hasDuplicateChild(strName, strObjectID, strRelID)) return;
    var objNode = new jsNode(strName, strURL, strIcon, strExpandURL, strObjectID, strRelID,strCommandName);
    this.childNodes[this.childNodes.length] = objNode;
  this.childNodes[objNode.name] = objNode;
    if (strObjectID) this.childNodes[objNode.id] = objNode;
    this.hasChildNodes = true;
    objNode.parent = this;
    objNode.tree = this.tree;
    objNode.indent = this.indent + 1;
      objNode.nodeID = getUniqueNodeID();
    if (strObjectID) {
    this.tree.nodes[objNode.id] = objNode;
    if (this.tree.nodemap[objNode.id]) {
      this.tree.nodemap[objNode.id][this.tree.nodemap[objNode.id].length] = objNode;
    } else {
      this.tree.nodemap[objNode.id] = new Array(objNode);
    }
  }
  this.tree.nodes[objNode.nodeID] = objNode;
  this.tree.nodes[objNode.name] = objNode;
    return objNode;
}
function _jsNode_getName() {
        var strName = this.name;
        if (this.isNumericName) {
        strName = strName.substring(1, strName.length);
    }
        return strName;
}
function _jsNode_setName(strName) {
        if (strName == parseInt(strName)) {
        this.isNumericName = true;
        this.name = " " + strName;
    } else {
        this.name = strName;
        this.isNumericName = false;
    }
        return strName;
}
function _jsNode_getObjectID() {
        var strID = this.id;
        if (this.isNumericID) {
        strID = strID.substring(1, strID.length);
    }
        return strID;
}
function _jsNode_removeChild(strObjectID, bRefresh) {
        bRefresh = (bRefresh == null ? true : bRefresh);
        var objRemovedNode = null;
        var arrNewChildNodes = new Array;
        for (var i=0; i < this.childNodes.length; i++) {
                        if (this.childNodes[i].getObjectID() != strObjectID)
            arrNewChildNodes[arrNewChildNodes.length] = this.childNodes[i];
        else
            objRemovedNode = this.childNodes[i];
    }
        this.childNodes = arrNewChildNodes;
        if (this.childNodes.length == 0) {
        this.expanded = false;
        this.hasChildNodes = false;
    }
        this.tree.getScrollPosition();
        if (bRefresh) {
       this.tree.refresh();
    }         return objRemovedNode;
}
function _jsNode_setObjectID(strObjectID) {
        this.id = strObjectID;
        return strObjectID;
}
function _jsNode_changeObjectName(strName, bRefresh) {
        bRefresh = (bRefresh == null ? true : bRefresh);
        var strObjectID = this.id;
        var strObjectOldName = this.name;
        this.setName(strName);
        if (this.tree.nodemap[strObjectID])
    {
        for (var i=0; i < this.tree.nodemap[strObjectID].length; i++)
        {
                        if (this.tree.nodemap[strObjectID][i].name == strObjectOldName)
              this.tree.nodemap[strObjectID][i].setName(strName);
        }
    }
        this.tree.doNavigate = true;
        this.tree.getScrollPosition();
        if (bRefresh) {
        this.tree.refresh();
    } }
function _jsNode_changeObjectID(strNewObjectID, bRefresh) {
        bRefresh = (bRefresh == null ? true : bRefresh);
        var strObjectID = this.id;
        var reObjectID = new RegExp(strObjectID, "g");
       if (this.tree.nodemap[strObjectID]) {
                for (var i=0; i < this.tree.nodemap[strObjectID].length; i++) {
                        this.tree.nodemap[strObjectID][i].setObjectID(strNewObjectID);
                        this.tree.nodemap[strObjectID][i].url = this.tree.nodemap[strObjectID][i].url.replace(reObjectID, strNewObjectID);
                        for (var j=0; j < this.tree.nodemap[strObjectID][i].childNodes.length; j++) {
                                if (reObjectID.test(this.tree.nodemap[strObjectID][i].childNodes[j].url)) {
                                        this.tree.nodemap[strObjectID][i].childNodes[j].url = this.tree.nodemap[strObjectID][i].childNodes[j].url.replace(reObjectID, strNewObjectID);
                }             }         }                 this.tree.nodemap[strNewObjectID] = this.tree.nodemap[strObjectID];
                this.tree.nodemap[strObjectID] = null;
    }         this.tree.doNavigate = true;
        this.tree.getScrollPosition();
        if (bRefresh) {
        this.tree.refresh();
    } }
function _jsNode_hasDuplicateChild(strName, strObjectID, strRelID) {
        var bHasDuplicate = false;
        for (var i=0; i < this.childNodes.length && !bHasDuplicate; i++) {
                        if (this.childNodes[i].getName() == strName && this.childNodes[i].id == strObjectID && this.childNodes[i].relID == strRelID)
            bHasDuplicate = true;
    }
        return bHasDuplicate;
}
function _jsNode_getChild(strName, strObjectID, strRelID) {
        for (var i=0; i < this.childNodes.length; i++) {
                if (this.childNodes[i].getName() == strName && this.childNodes[i].id == strObjectID && this.childNodes[i].relID == strRelID)
            return this.childNodes[i];
    }
        return null;
}
function clickPlusMinus(strNodeID) {
              if (!localTree)
      localTree = (getTopWindow().localTree ? getTopWindow().localTree : parent.localTree);
        if (localTree.processing)
        return;
        localTree.processing = true;
        localTree.getScrollPosition();
        localTree.toggleExpand(strNodeID);
        localTree.refresh();
        if (localTree.nodes[strNodeID].hasChildNodes && localTree.nodes[strNodeID].expanded && !localTree.nodes[strNodeID].loaded) {
                var strURL = localTree.nodes[strNodeID].expandURL;
                strURL = addURLParam(strURL,"jsTreeID=" + strNodeID);
                var win = localTree._displayFrame || findFrame(getTopWindow(), localTree.displayFrame);
        win.document.location.href = strURL;
    }
        localTree.processing = false;
}
function linkClick(strNodeID) {
              if (!localTree)
      localTree = (getTopWindow().localTree ? getTopWindow().localTree : parent.localTree);
        if (localTree.processing)
        return;
        localTree.processing = true;
        var strURL = localTree.nodes[strNodeID].url;
        if (localTree.nodes[strNodeID].parent){
        var strParentName = localTree.nodes[strNodeID].parent.name;
        strURL = addURLParam(strURL,"objectName=" + escape(escape(strParentName)));
                    }
        if (localTree.nodes[strNodeID].hasChildNodes){
        var strParentName = localTree.nodes[strNodeID].name;
        strURL = addURLParam(strURL,"objectName=" + escape(escape(strParentName)));
                    }
        strURL = addURLParam(strURL,"jsTreeID=" + strNodeID);
        for (var j=0; j < localTree.urlParams.length; j++)
        strURL = addURLParam(strURL, localTree.urlParams[j]);
        localTree.selectedID = strNodeID;
        var win = localTree._targetFrame || findFrame(getTopWindow(), localTree.target);
        localTree.getScrollPosition();
        win.document.location.href = strURL;

    var strCommandName = "";
    var strParentName="rootnode";
    if(localTree.nodes[strNodeID].commandName != "undefined" && localTree.nodes[strNodeID].commandName != "" && localTree.nodes[strNodeID].commandName != "rootnode" ){
      strCommandName=localTree.nodes[strNodeID].commandName;
           if(localTree.nodes[strNodeID].parent)
     {
       if(localTree.nodes[strNodeID].commandName == "rootnode")
         strParentName=localTree.nodes[strNodeID].commandName;
       else
         strParentName=localTree.nodes[strNodeID].parent.name;
     }
    }

    if(localTree.nodes[strNodeID].id)
    addToPageHistory(strParentName,strURL,strCommandName,localTree.target,localTree.nodes[strNodeID].name,"tree",localTree.nodes[strNodeID].id)
        setTimeout("localTree.refresh()", 50);
        localTree.processing = false;
}
function listLinkClick(strParentNodeID, strName, strURL, strIcon, strExpandURL, strObjectID) {
              if (!localTree)
      localTree = (getTopWindow().localTree ? getTopWindow().localTree : parent.localTree);
    var frameTarget = localTree._targetFrame || findFrame(getTopWindow(), localTree.target);
  var frameDisplay = localTree._displayFrame || findFrame(getTopWindow(), localTree.displayFrame);
    var objParent = localTree.nodes[strParentNodeID];
  var objChild = objParent.childNodes[strObjectID];
    if (!objChild)
    objChild = objParent.childNodes[strName];
    if (!objChild)
    objChild = objParent.addChild(strName, strURL, strIcon, strExpandURL, strObjectID);
    localTree.selectedID = objChild.nodeID;
    objParent.expanded = true;
    for (var i=0; i < objParent.childNodes.length-1; i++) {
    if (objParent.childNodes[i].hasChildNodes)
      objParent.childNodes[i].expanded = false;
  }
    if (objChild.hasChildNodes)
    objChild.expanded = true;
    var strTargetURL = objChild.url;
    strTargetURL = addURLParam(strTargetURL,"jsTreeID=" + objChild.nodeID);
    frameTarget.document.location.href = strTargetURL;
    if (objChild.hasChildNodes && !objChild.loaded) {
        var strURL = objChild.expandURL;
        strURL = addURLParam(strURL, "jsTreeID=" + objChild.nodeID);
        frameDisplay.document.location.href = strURL;
  } else {
        localTree.getScrollPosition();
        localTree.refresh();
  }
}
function getUniqueNodeID() {
    var strNodeID = "node";
    strNodeID += ((new Date()).getTime() * Math.random());
    return strNodeID;
}
function isLastNode(objNode) {
    return objNode.parent.childNodes[objNode.parent.childNodes.length-1] == objNode;
}
function _jsTree_addNodeScopeID(strParam) {
        var objParent = this.parent;
    var nodeScopeIDs = new Array;
    var tempNodeScopeIDs = new Array();
    tempNodeScopeIDs[tempNodeScopeIDs.length] = strParam;
    if (!objParent)
    {
      if (strParam != null && strParam != 'undefined' && strParam.indexOf('=') != -1)
        this.nodeScopeID = tempNodeScopeIDs;
  } else {
      this.nodeScopeID = objParent.nodeScopeID;
      if (strParam != null && strParam != 'undefined' && strParam.indexOf('=') != -1)
      {
          nodeScopeIDs = this.nodeScopeID;
                  var arrayParam = strParam.split("=");
          var nodeScopeIDName = arrayParam[0];
                    for (var i=0; i < nodeScopeIDs.length; i++)
          {
            if ( (nodeScopeIDs[i].indexOf(nodeScopeIDName + "=") == -1))
                tempNodeScopeIDs[tempNodeScopeIDs.length] = nodeScopeIDs[i];
                          }
      this.nodeScopeID = tempNodeScopeIDs;
    }
  }
}
function addToPageHistory(strTitle,strURL,strCommand,strTarget,objCommandTitle,linkType,objectid) {
strTarget="content"
var strFinalURL = "emxPageHistoryProcess.jsp?pageURL="+escape(strURL)+"&objectid="+objectid+"&AppName="+strTitle+"&commandName="+strCommand+"&targetLocation="+strTarget+"&CommandTitle="+encodeURIComponent(objCommandTitle)+"&linkType="+linkType;
var objFrame;
if(getTopWindow().getWindowOpener())
 {
    objFrame=findFrame(parent.getWindowOpener().getTopWindow(), "hiddenFrame")
    if(objFrame)
     {
       objFrame.document.location.href = strFinalURL;
     }else{
        objFrame=findFrame(parent.getTopWindow(), "hiddenTreeFrame");
        if (objFrame){
            objFrame.document.location.href = strFinalURL;
        }else{
           objFrame=findFrame(parent.getTopWindow(), "hiddenTreeContentFrame");
           if (objFrame)
               objFrame.document.location.href = strFinalURL;
        }
     }
 }else{

    objFrame=findFrame(getTopWindow(), "hiddenFrame")
    if(objFrame){
       objFrame.document.location.href = strFinalURL;
    }else{
        objFrame=findFrame(getTopWindow(), "hiddenTreeFrame");
        if (objFrame){
            objFrame.document.location.href = strFinalURL;
        }else{
           objFrame=findFrame(getTopWindow(), "hiddenTreeContentFrame");
           if (objFrame)
               objFrame.document.location.href = strFinalURL;
        }

    }
 }
}
