
PSTree = function (containerName,TABID) {
	this.config = {
		levelSeparation : 40,
		siblingsGap : 40,
		subtreesGap : 40,
		topXAdjustment : 80,
		topYAdjustment :30,		
		nodeWidth : 20,
		nodeHeight : 20,
		
		connectionColor : "#5b5d5e",
		nodeColor : "grey",
		revisionColor : 'grey',
		nodeBorderColor : "black",
		nodeSelColor : "#368ec4",
		
		expandedImage : './assets/icons/less.gif',
		collapsedImage : './assets/icons/plus.gif',
		branchModeImage : './assets/icons/infinity.png',
		singleModeImage : './assets/icons/transBig.gif',
		separaterImage : './assets/icons/separater1.jpg',
		transparentImage : './assets/icons/trans.gif',
		
		selectionMode : PSTree.SM_BOTH
	}
	
	this.containerName = containerName;
	this.self = this;
	this.canvasCtx = null;
	
	this.tab=TABID;
	
	this.canvasoffsetTop = 0;
	this.canvasoffsetLeft = 0;
	this.rootYOffset = 0;
	this.rootXOffset = 0;
	
	this.nDatabaseNodes = [];
	this.mapIDs = {};
	this.maxLevelHeight = [];
	this.maxLevelWidth = [];
	this.previousLevelNode = [];	
	
	this.root = new PSNode(-1);
	this.iSelectedNode = -1;
	
	this.isPositioningRequired = true;
	this.maxX = 0;
	this.maxY = 0;
	this.currentSelectedNode = null;
}

PSTree.SM_BRANCH = 0;
PSTree.SM_SINGLE = 1;
PSTree.SM_BOTH = 3;

PSTree.prototype.getElement = function (id) {
	id = id.toString().replace(/\./g, "\\.");//with escaped dot
	
		//var ttpElem = document.getElementById(this.containerName);
	var returnElem = document.getElementById(id);
	
	return returnElem;

//	return $('#' + this.containerName + ' #' + id)[0];
}

//algo
//it first calculates the positions of nodes based on top down tree (considers in between node's final orientation in calculation) and in the end converts coordinates based on the required tree orientation (which is left to right in our case)
//it is based on "A Node-Positioning Algorithm for General Trees" by John Q. Walker II in 1989
PSTree._initialTraversal = function (tree, currNode, level) {
		var siblingLeft = null;
		
        currNode.neighborLeft = null;
        currNode.neighborRight = null;
		currNode.xPos = 0;
        currNode.yPos = 0;
        currNode.baseXPos = 0;
        currNode.modifier = 0;
        
        tree._setHeightOfLevel(currNode, level);
        tree._setWidthOfLevel(currNode, level);
        tree._setNeighbors(currNode, level);
        if(currNode._getChildrenCount() == 0)
        {
            siblingLeft = currNode._getLeftSibling();
            if(siblingLeft != null)
                currNode.baseXPos = siblingLeft.baseXPos + tree.config.nodeHeight + tree.config.siblingsGap;
            else
                currNode.baseXPos = 0;
        }
        else
        {
            var noOfChildren = currNode._getChildrenCount();
            for(var i = 0; i < noOfChildren; i++)
            {
                var childNode = currNode._getChildAt(i);
                PSTree._initialTraversal(tree, childNode, level + 1);
            }

            var middle = currNode._getChildrenCenter(tree);
            middle -= tree.config.nodeHeight / 2;
            siblingLeft = currNode._getLeftSibling();
            if(siblingLeft != null)
            {
                currNode.baseXPos = siblingLeft.baseXPos + tree.config.nodeHeight + tree.config.siblingsGap;
                currNode.modifier = currNode.baseXPos - middle;
                PSTree._calculateApportion(tree, currNode, level);
            } 
            else
            {            	
                currNode.baseXPos = middle;
            }
        }	
}



PSTree._finalTraversal = function (tree, currNode, level, X, Y) {
	var xTmp = tree.rootXOffset + currNode.baseXPos + X;
	var yTmp = tree.rootYOffset + Y;
	var maxsizeTmp = 0;
	var nodesizeTmp = 0;
	var flag = false;
	
	//   left orientation            
	maxsizeTmp = tree.maxLevelWidth[level];
	flag = true;
	nodesizeTmp = tree.config.nodeWidth;
	//
	
	currNode.xPos = xTmp;
	currNode.yPos = yTmp;
	
	if(flag)
	{
		var swapTmp = currNode.xPos;
		currNode.xPos = currNode.yPos;
		currNode.yPos = swapTmp;
	}						
				
	if(tree.maxX < currNode.xPos)
		tree.maxX = currNode.xPos;
	if(tree.maxY < currNode.yPos)
		tree.maxY = currNode.yPos;
	if(currNode._getChildrenCount() != 0)
	   // PSTree._finalTraversal(tree, currNode._getChildAt(0), level + 1, X + currNode.modifier, Y + maxsizeTmp + tree.config.levelSeparation);
	{ 
		if(currNode._getChildrenCount() > 1)
			PSTree._finalTraversal(tree, currNode._getChildAt(0), level + 1, X + currNode.modifier, Y + maxsizeTmp + tree.config.levelSeparation + 15);
		else
			PSTree._finalTraversal(tree, currNode._getChildAt(0), level + 1, X + currNode.modifier, Y + maxsizeTmp + tree.config.levelSeparation);
	}
	var rightSibling = currNode._getRightSibling();
	if(rightSibling != null)
		PSTree._finalTraversal(tree, rightSibling, level, X, Y);
}

PSTree._calculateApportion = function (tree, currNode, level) {
        var childFirst = currNode._getChildAt(0);
        var firstChildLeftNeighbor = childFirst.neighborLeft;
		
        var j = 1;
        for(var k = level; j <= k && childFirst != null && firstChildLeftNeighbor != null; )
        {
            var rightModSum = 0;
            var leftModSum = 0;
			
            var ancestorRight = childFirst;
            var ancestorLeft = firstChildLeftNeighbor;
			
            for(var l = 0; l < j; l++)
            {
                ancestorRight = ancestorRight.nodeParent;
                ancestorLeft = ancestorLeft.nodeParent;
				
                rightModSum += ancestorRight.modifier;
                leftModSum += ancestorLeft.modifier;
            }

            var moveDistance = (firstChildLeftNeighbor.baseXPos + leftModSum + tree.config.nodeHeight + tree.config.subtreesGap) - (childFirst.baseXPos + rightModSum);
			
            if(moveDistance > 0)
            {
                var tempNode = currNode;
                var numSubtrees = 0;
                while( tempNode != null && tempNode != ancestorLeft )
                {
					numSubtrees++;
					tempNode = tempNode._getLeftSibling();
				}
                if(tempNode != null)
                {
                    var tempMoveNode = currNode;
                    var portion = moveDistance / numSubtrees;
                    while( tempMoveNode != ancestorLeft)
                    {
                        tempMoveNode.baseXPos += moveDistance;
                        tempMoveNode.modifier += moveDistance;
                        moveDistance -= portion;
						
						tempMoveNode = tempMoveNode._getLeftSibling();
                    }
                }
            }
            j++;
            if(childFirst._getChildrenCount() == 0)
            {
				childFirst = tree._getLeftmost(currNode, 0, j);
			}
            else
            {
				childFirst = childFirst._getChildAt(0);
			}
            if(childFirst != null)
            {
				firstChildLeftNeighbor = childFirst.neighborLeft;
			}
        }
}

PSTree.prototype._positionTree = function () {	
	this.maxLevelHeight = [];
	this.maxLevelWidth = [];			
	this.previousLevelNode = [];
	if(this.root._getChildrenCount() > 0)
	{
		var realRoot = this.root._getChildAt(0);
		PSTree._initialTraversal(this.self, realRoot, 0);
		
		//    left orientation 
		this.rootXOffset = this.config.topXAdjustment + realRoot.xPos;
		this.rootYOffset = this.config.topYAdjustment + realRoot.yPos;
		//
		
		PSTree._finalTraversal(this.self, realRoot, 0, 0, 0);
	}
}

PSTree.prototype._setHeightOfLevel = function (node, level) {	
	if (this.maxLevelHeight[level] == null) 
		this.maxLevelHeight[level] = 0;
    if(this.maxLevelHeight[level] < this.config.nodeHeight)
        this.maxLevelHeight[level] = this.config.nodeHeight;	
}

PSTree.prototype._setWidthOfLevel = function (node, level) {
	if (this.maxLevelWidth[level] == null) 
		this.maxLevelWidth[level] = 0;
    if(this.maxLevelWidth[level] < this.config.nodeWidth)
        this.maxLevelWidth[level] = this.config.nodeWidth;		
}

PSTree.prototype._setNeighbors = function(node, level) {
    node.neighborLeft = this.previousLevelNode[level];
    if(node.neighborLeft != null)
        node.neighborLeft.neighborRight = node;
    this.previousLevelNode[level] = node;	
}

PSTree.prototype._getLeftmost = function (node, level, maxlevel) {
    if(level >= maxlevel) return node;
	
    if(node._getChildrenCount() == 0) return null;
    
    var childCount = node._getChildrenCount();
    for(var childIdx = 0; childIdx < childCount; childIdx++)
    {
        var childNode = node._getChildAt(childIdx);
        var leftmostDescendant = this._getLeftmost(childNode, level + 1, maxlevel);
        if(leftmostDescendant != null)
            return leftmostDescendant;
    }
    return null;	
}


PSTree.prototype._drawTree = function () {
	var s = [];		
	var node = null;
	for (var n = 0; n < this.nDatabaseNodes.length; n++)
	{ 
		node = this.nDatabaseNodes[n];
		var s1 = this.drawNodeHtml(node);
		s.push(s1);			
	}
	return s.join('');	
}

PSTree.prototype.ShowTooltip = function (node, attrArr, pos) {
	var top = pos.top + 30;
	var left = pos.left;
	var text = '';
	for(var i = 0; i < attrArr.length; i++)
	{
		text += attrArr[i] + '<br>';
	}	
	var ttpElem = document.getElementById('tooltip');
	ttpElem.style.top = top + 'px';
	ttpElem.style.left = left + 'px';
	ttpElem.innerHTML = text;	
	ttpElem.style.display = 'block';
	ttpElem.opacity = 1;
	
	//ttpElem.style.animation = 'fadeIn .5s ease-in 1 forwards';
	//ttpElem.style.animation-play-state = 'paused';	

	/*var $tooltipElem = $('#tooltip');
	 $tooltipElem.css("top", top);
	 $tooltipElem.css("left", left);
	 $tooltipElem.html(text);
	
	 $tooltipElem.stop(true, true).fadeIn();*/
}

PSTree.prototype.HideTooltip = function () {
var ttpElem = document.getElementById('tooltip');
ttpElem.style.display = 'none';
//ttpElem.style.animation-play-state = 'paused';
//	$('#tooltip').stop(true, true).hide();
}

PSTree.prototype.drawNodeHtml = function (node) {
	var s = [];
	if (!node._isAncestorCollapsed())
	{
		var truncatedDsc = node.dsc;
		var fixedSize = 10;
		if(node.dsc.length > fixedSize)
			truncatedDsc = truncatedDsc.substr(0, fixedSize	) + "..";
		
		s.push('<g id="PS_' + node.id + '" >');
		
		s.push('<rect id="rect_' + node.id + '" x="' + (node.xPos-30) + '" y="' + (node.yPos-23) + '" width="60"  height="46" rx="10" ry="10"  fill="#acd2e6" stroke="white" stroke-width="0" fill-opacity="0.0" />');
		
		s.push('<circle id="circleOuter_' + node.id + '" cx="' + node.xPos + '" cy="' + node.yPos + '" r="16" stroke="#5b5d5e" fill="white" />');
		
		s.push('<circle id="circleInner_' + node.id + '" cx="' + node.xPos + '" cy="' + node.yPos + '" r="7" stroke="grey"  fill="lightblue"  />');
				
		s.push('<image id="infinity_' + node.id + '" x="' + (node.xPos-5) + '" y="' + (node.yPos-5) + '" width="' + 10 + '" height="' + 10	 + '" xlink:href="'+this.config.branchModeImage+'"  display="none" />');
		
		if (node.canCollapse) {
			s.push('<image id="collapse_' + node.id + '" x="' + (node.xPos + 16) + '" y="' + (node.yPos - 4) + '" width="' + 10 + '" height="' + 10	 + '" xlink:href="'+this.config.expandedImage+'" />');
		}
		
		s.push('<text id="text_' + node.id + '" transform="rotate(-15, ' + (node.xPos - 12) + ', ' + (node.yPos - 16) + ')" font-family="calibri" font-size="15" x="' + (node.xPos - 12) + '" y="' + (node.yPos - 16) + '">' + node.meta + '</text>');
		
		s.push('</g>');
		
		if (!node.isCollapsed)	s.push(node._drawChildrenLinks(this.self));
	}
		
	return s.join('');	
}


// PSTree API begins here...

PSTree.prototype.createTree = function () {	
	this._positionTree();
	var contentsHtml = this._drawTree();	
	var container = document.getElementById(this.containerName);
	container.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width=' + (this.maxX + 220) + ' height=' + (this.maxY + 100) + ' >' + contentsHtml + '</svg> <div id="tooltip">test</div>';
	
	var ttpElem = document.getElementById('tooltip');
	ttpElem.style.display = 'none';
	//$('#tooltip').hide();
	
	var node = null;
	for (var n = 0; n < this.nDatabaseNodes.length; n++)
	{ 
		node = this.nDatabaseNodes[n];
		var nodeId = node.id.toString().replace(/\./g, "\\.");//with escaped dot
		
		var treeData = {psTreeObj:this, treeNode:node};
		var psTreeObj = this;
		
		var psElem = this.getElement('PS_' + nodeId);
		
		//$('#' + this.containerName + ' #PS_' + nodeId).on('mouseenter mouseleave', treeData,  function( event ){
		
		psElem.onmouseover = function(event){
		
				var nodeId = this.id.replace("PS_","");
				psTreeObj.hoverIn(nodeId, {top: this.offsetTop, left: this.offsetLeft});
				//event.data.psTreeObj.hoverIn(event.data.treeNode.id, $(this).offset());
				};
				
		psElem.onmouseout = function(event){
			var nodeId = this.id.replace("PS_","");
			
				psTreeObj.hoverOut(nodeId);
		};
		var crcloutElem = this.getElement('circleOuter_' +nodeId);
		//$('#' + this.containerName).find('#rect_' +nodeId + ', #circleOuter_' +nodeId).on('click', treeData,  function( event ){
		
		crcloutElem.onclick = function(event)
		{
		var nodeId = this.id.replace("circleOuter_","");
		if(psTreeObj.config.selectionMode == PSTree.SM_SINGLE)
				psTreeObj.selectNodeSingle(nodeId,true);
			else
				psTreeObj.selectNodeWithBranch(nodeId);
		};
		
		
		var crclElem = this.getElement('circleInner_' +nodeId);
		var infElem = this.getElement('infinity_' +nodeId);
		
		//$('#' + this.containerName).find('#circleInner_' +nodeId + ', #infinity_' +nodeId).on('click', treeData,  function( event ){
		
		var onClick = function(event)
		{
			var nodeId = this.id;
			
			if(nodeId.indexOf('circleInner_') != -1)
			 nodeId = nodeId.replace("circleInner_","");
			else if(nodeId.indexOf('infinity_') != -1)
			 nodeId = nodeId.replace("infinity_","");
			
			if(psTreeObj.config.selectionMode == PSTree.SM_BRANCH)
				psTreeObj.selectNodeWithBranch(nodeId);
			else
				psTreeObj.selectNodeSingle(nodeId,true);
		};
		crclElem.onclick = onClick;
		infElem.onclick = onClick;
		
		var childElem = this.getElement('collapse_' +nodeId);
		
		//$('#' + this.containerName + ' #collapse_' +nodeId).on('click', treeData,  function( event ){
		
		if(childElem) 
		{	childElem.onclick = function ( event ){
			var nodeId = this.id.replace("collapse_","");
			if (node.canCollapse) {
				psTreeObj.collapseNode(nodeId, true);
			}
			
		};
		}
	}
	for (var i = this.nDatabaseNodes.length - 1; i >= 0; i--) {
        var node = this.nDatabaseNodes[i];
        if(node.isRevision)
        {
        	this.selectNodeSingle(nodeId, true);
        	break;
        }
    }
}

PSTree.prototype.add = function (id, pid, dsc, isRevision, meta,state,revision) {	
	var metadata = (typeof meta != "undefined")	? meta : "";
	//Search for parent node in database
	var pnode = null; 
	if (pid == -1) 
	{
		pnode = this.root;
	}
	else
	{
		for(var i = 0; i < this.nDatabaseNodes.length; i++)
		{
			var dbNode = this.nDatabaseNodes[i];
			if (dbNode.id == pid)
			{
				pnode = dbNode;
				break;
			}
		}	
	}	
	var node = new PSNode(id, pid, dsc, isRevision, metadata,state,revision);	
	node.nodeParent = pnode; 
	pnode.canCollapse = true; 
	var i = this.nDatabaseNodes.length;	
	node.dbIndex = this.mapIDs[id] = i;	 
	this.nDatabaseNodes[i] = node;	
	var h = pnode.nodeChildren.length; 
	node.siblingIndex = h;
	pnode.nodeChildren[h] = node;
	
	//make revision first child for parent
	if(isRevision)
	{
		//swap with first child
		var oldFisrtNode = pnode.nodeChildren[0];
		pnode.nodeChildren[0] = node;
		pnode.nodeChildren[h] = oldFisrtNode;
	}
}

PSTree.prototype.hoverIn = function (nodeid, pos) {
	var dbindex = this.mapIDs[nodeid];
	var node = this.nDatabaseNodes[dbindex];
	
	var rect_element = this.getElement('rect_' + nodeid);
	rect_element.setAttribute('fill-opacity', "0.9");
	
	var ttpPos = {top: node.yPos, left: node.xPos};
	this.ShowTooltip(node, [UWA.i18n("Name") + ": " + node.dsc, UWA.i18n("Rev") + ": " + node.rev, UWA.i18n("State") + ": " + node.state], ttpPos);
	
	if( ! node.isSelected )
	{
		this.highlightNode(nodeid);
	}
}

PSTree.prototype.hoverOut = function (nodeid) {
	var dbindex = this.mapIDs[nodeid];
	var node = this.nDatabaseNodes[dbindex];
	
	var rect_element = this.getElement('rect_' + nodeid);
	rect_element.setAttribute('fill-opacity', "0");
	
	this.HideTooltip();
	
	if( ! node.isSelected )
	{
		this.dehighlightNode(nodeid);
	}
}

PSTree.prototype.collapseNode = function (nodeid, upd) {
	var dbindex = this.mapIDs[nodeid];
	var node = this.nDatabaseNodes[dbindex];
	//toggle
	node.isCollapsed = !node.isCollapsed;
	
	var collapse_element = this.getElement('collapse_' + nodeid);
	collapse_element.setAttribute('xlink:href', ((node.isCollapsed) ? this.config.collapsedImage : this.config.expandedImage));

	if(node.isCollapsed )
		this.toggleChildNodesVisibility(node, false);
	else
		this.toggleChildNodesVisibility(node, true);

}

PSTree.prototype.toggleChildNodesVisibility = function (node, show) {
	if(!(node.isCollapsed && show))
	{
		var n = node.nodeChildren.length;
		for(var i = 0; i < n; i++)
		{
			var childNode = node.nodeChildren[i];
			
			var rect_element = this.getElement('rect_' + childNode.id);
			var circleOuter_element = this.getElement('circleOuter_' + childNode.id);
			var circleInner_element = this.getElement('circleInner_' + childNode.id);
			var infinity_element = this.getElement('infinity_' + childNode.id);
			var collapse_element = this.getElement('collapse_' + childNode.id);
			var text_element = this.getElement('text_' + childNode.id);
			var connection_element = this.getElement('connection_' + childNode.id);
			if(show)
			{
				rect_element.setAttribute("display", "");
				circleOuter_element.setAttribute("display", "");
				circleInner_element.setAttribute("display", "");
				if(childNode.isInfinity)
					infinity_element.setAttribute("display", "");
				if(collapse_element != null)
					collapse_element.setAttribute("display", "");
				text_element.setAttribute("display", "");	
				connection_element.setAttribute("display", "");	
			}	
			else
			{
				rect_element.setAttribute("display", "none");
				circleOuter_element.setAttribute("display", "none");
				circleInner_element.setAttribute("display", "none");
				infinity_element.setAttribute("display", "none");
				if(collapse_element != null)
					collapse_element.setAttribute("display", "none");
				text_element.setAttribute("display", "none");
				connection_element.setAttribute("display", "none");	
			}
				
			this.toggleChildNodesVisibility(childNode, show);
		}
	}
}

PSTree.prototype.selectNodeSingle = function (nodeid,fromUI) {		
	    var dbindex = this.mapIDs[nodeid];
	    var node = this.nDatabaseNodes[dbindex];
	    var previousSelectedNode = this.currentSelectedNode
	    if( previousSelectedNode != null)
	    {
	        if (node.id != previousSelectedNode.id || (node.id == previousSelectedNode.id && !fromUI))
		    {
			    previousSelectedNode.isSelected = false;
			    this.dehighlightNode(previousSelectedNode.id);
		    }
	    }
	    this.currentSelectedNode = node;
	 
	
	
	    if( ! node.isSelected )
	    {
		    node.isSelected = !node.isSelected;
	    }
	    node.isInfinity = false;
	    this.showSelectedNode(node, node.isInfinity);

	require(['DS/ConfiguratorWebView/PanelController'],
    function (PanelController) {
	    if(node.isSelected)
	        PanelController.addEventOnProdStateSelection(node.id, node.dsc, node.rev, fromUI);
	    else if(fromUI)
	        PanelController.addEventOnProdStateUnselection();
     });
};

PSTree.prototype.showSelectedNode = function (node, showInfinity) {
	if( ! node._isAncestorCollapsed() )
	{
		if(showInfinity)
			this.showInfinity(node.id);
		else
			this.hideInfinity(node.id);
	}	
		if(node.isSelected)
			this.highlightNode(node.id);
		else
			this.dehighlightNode(node.id);
	
}

PSTree.prototype.showInfinity = function (nodeid) {		
	var infinity_element = this.getElement('infinity_' + nodeid);
	
	infinity_element.setAttribute('display', "");
}

PSTree.prototype.hideInfinity = function (nodeid) {		
	var infinity_element = this.getElement('infinity_' + nodeid);
	
	infinity_element.setAttribute('display', "none");
}

PSTree.prototype.highlightNode = function (nodeid) {		
	var circleOuter_element = this.getElement('circleOuter_' + nodeid);
	var circleInner_element = this.getElement('circleInner_' + nodeid);
	
	circleOuter_element.setAttribute('fill', "#368ec4");	
	circleOuter_element.setAttribute('stroke', "lightgrey");	
	circleOuter_element.setAttribute('stroke-width', "4");	
	circleOuter_element.setAttribute('r', "17");	
	
	circleInner_element.setAttribute('fill', "lightyellow");	
}

PSTree.prototype.dehighlightNode = function (nodeid) {		
	var circleOuter_element = this.getElement('circleOuter_' + nodeid);
	var circleInner_element = this.getElement('circleInner_' + nodeid);
	
	circleOuter_element.setAttribute('fill', "white");	
	circleOuter_element.setAttribute('stroke', "#5b5d5e");	
	circleOuter_element.setAttribute('stroke-width', "1");	
	circleOuter_element.setAttribute('r', "16");
	
	circleInner_element.setAttribute('fill', "lightblue");	
}

PSTree.prototype.selectNodeWithBranch = function (nodeid) {		
	var dbindex = this.mapIDs[nodeid];
	var node = this.nDatabaseNodes[dbindex];
	var considerSubsequent = true;
	if(node.isSelected && !node.isInfinity)
		considerSubsequent = false;
	
	node.isSelected = !node.isSelected;
	node.isInfinity = node.isSelected;
	this.showSelectedNode(node, node.isInfinity);
	
	if(considerSubsequent)
		this.selectSubsequentNodes(node, node.isSelected);
}

PSTree.prototype.selectSubsequentNodes = function (node, selectionRequired) {		
	
	var n = node.nodeChildren.length;
	for(var i = 0; i < n; i++)
	{
		var childNode = node.nodeChildren[i];
		childNode.isSelected = selectionRequired;
		childNode.isInfinity = selectionRequired;
		this.showSelectedNode(childNode, childNode.isInfinity);
		
		this.selectSubsequentNodes(childNode, selectionRequired);
	}
}


PSNode = function (id, pid, dsc, isRevision, meta,state,revision) {
	this.id = id;
	this.pid = pid;
	this.dsc = dsc;
	this.meta = meta;
	this.state = state;
	this.rev = revision;
	
	this.siblingIndex = 0;
	this.dbIndex = 0;
	
	this.xPos = 0;
	this.yPos = 0;
	this.baseXPos = 0;
	this.modifier = 0;
	this.neighborLeft = null;
	this.neighborRight = null;
	this.nodeParent = null;	
	this.nodeChildren = [];
	
	this.isCollapsed = false;
	this.canCollapse = false;
	
	this.isSelected = false;	
	this.isRevision = isRevision;
	this.isInfinity = false;
}


PSNode.prototype._isAncestorCollapsed = function () {
	if (this.nodeParent.isCollapsed) { return true; }
	else 
	{
		if (this.nodeParent.id == -1) { return false; }
		else	{ return this.nodeParent._isAncestorCollapsed(); }
	}
}


PSNode.prototype._getChildrenCount = function () {
	if (this.isCollapsed) return 0;
    if(this.nodeChildren == null)
        return 0;
    else
        return this.nodeChildren.length;
}

PSNode.prototype._getLeftSibling = function () {
    if(this.neighborLeft != null && this.neighborLeft.nodeParent == this.nodeParent)
        return this.neighborLeft;
    else
        return null;	
}

PSNode.prototype._getRightSibling = function () {
    if(this.neighborRight != null && this.neighborRight.nodeParent == this.nodeParent)
        return this.neighborRight;
    else
        return null;	
}

PSNode.prototype._getChildAt = function (i) {
	return this.nodeChildren[i];
}

PSNode.prototype._getChildrenCenter = function (tree) {
	var n = this._getChildrenCount();
	for(var i = 0; i < n; i++)
    {
        var childNode = this._getChildAt(i);
        //if(childNode.isRevision)
			return childNode.baseXPos + tree.config.nodeHeight / 2;	;
    }
	
    node = this._getChildAt(0);
    node1 = this._getLastChild();
    return node.baseXPos + ((node1.baseXPos - node.baseXPos) + tree.config.nodeHeight) / 2;	
}


PSNode.prototype._getLastChild = function () {
	return this._getChildAt(this._getChildrenCount() - 1);
}

PSNode.prototype._drawChildrenLinks = function (tree) {
	var s = [];
	var xa = 0, ya = 0, xb = 0, yb = 0, xc = 0, yc = 0, xd = 0, yd = 0;
	var node1 = null;
	
	//	left orientation
	xa = this.xPos + tree.config.nodeWidth + 10;
	ya = this.yPos + (tree.config.nodeHeight / 2);		
	//		
	for (var k = 0; k < this.nodeChildren.length; k++)
	{
		node1 = this.nodeChildren[k];
				
		//left orientation
		xd = node1.xPos;
		yd = yc = node1.yPos + (tree.config.nodeHeight / 2);		
		yb = ya;
		//		
		xb = xc = xd - tree.config.levelSeparation / 2;
		
		s.push('<line id="connection_' + node1.id + '" x1="' + (xa-5) + '"  y1="' + (ya-10) + '" x2="' + (xd-10) + '"   y2="' + (yd-10) + '" style="stroke:' + tree.config.connectionColor + ';"');
		s.push(' stroke-width="2" ');
		if( ! node1.isRevision )
		{
			s.push(' stroke-dasharray="10,5" ');
		}
		s.push('/>');
	}		
	return s.join('');
}

