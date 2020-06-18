/* ThreeStateCheckbox.js

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
     @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 2013:02:22  IR-215543V6R2014 Changes done in getNextPage method. LoadXMLRemote() is replaced with  RefreshViewScroll().
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview QYG      16:05:03   javascript refactoring, location moved
*/
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"


define('DS/ENORMTCustoSB/ThreeStateCheckbox', [],	function(){
	emxUICore.instrument(window, 'GetNextPage', null, GetNextPageTSC);
	emxUICore.instrument(window, 'rebuildView', null, rebuildViewTSC);
	emxUICore.instrument(window, 'RefreshAllSelections', null, RefreshAllSelectionsTSC);
	emxUICore.instrument(window, 'FreezePaneregister', null, FreezePaneregisterTSC);
	emxUICore.instrument(window, 'FreezePaneunregister', null, FreezePaneunregisterTSC);
	emxUICore.instrument(window, 'setCheckboxStatus', setCheckboxStatusTSCPre, setCheckboxStatusTSCPost);
	
	emxUICore.instrument(window, 'callSubmitURL', callSubmitURLTSC, null);
	emxUICore.instrument(window, 'expandObjsCallback', expandObjsCallbackTSC, null);
	emxUICore.instrument(window, 'toggle2', toggle2TSC, null);
	emxUICore.instrument(window, 'doFreezePaneCheckboxClick', doFreezePaneCheckboxClickTSC, null);
	console.log("ThreeStateCheckbox.js loaded.");
    return {};
});
	//[Bug 356131
	colMap.getColumnByIndex(0).setSetting("Target Location", "popup");
	//]
	


function RefreshAllSelectionsTSC(checked, tbl){ 
    renderPartialSelect();
}

function doFreezePaneCheckboxClickTSC(objCheckbox, event) {
    if (objCheckbox.checked){
        FreezePaneregister(objCheckbox.value);
        if(event && isShiftKeyDown(event)){
            shiftCheckedCheckbox = objCheckbox;
            doShiftCheckCheckboxes(normalCheckedCheckbox, shiftCheckedCheckbox);
            normalCheckedCheckbox = shiftCheckedCheckbox;
        }else{
            normalCheckedCheckbox = objCheckbox;
        }
    }else{
        FreezePaneunregister(objCheckbox.value);
        normalCheckedCheckbox = null;
    }
    //****************************
    //RefreshSelections();
    rebuildView();
    //******************************
    return false; /* don't call the original one */
}


function setCheckboxStatusTSCPre(objCheckbox){
	//logic to check all or clear all, clear mixed status;
	noSelectionCheck = true;
	clearMixed();
}

function setCheckboxStatusTSCPost(objCheckbox){
	noSelectionCheck = false;
}



/**********************************
function doShiftCheckCheckboxes(startingCheckbox, endingCheckbox)
function doFreezePaneChecks(objCheckbox, nRows, startIndex, endIndex)
function doCheckSelectAll()
function getCheckedCheckboxes()
function expandObjects(strURL, whereExp) 
function allLevelCheck(initialLoading) 
function RefreshView()
function removedeletedRows(response)

function applyEdits()
function removeMask()
***********************************/

function checkNodeDescendants(node, recursive, checked)
{
	if(!node){
		return;
	}
	
	var childNodes = node.childNodes;
    for(var i = 0; i < childNodes.length; i++){
    	if(childNodes[i].tagName == "r"){
    		childNodes[i].setAttribute("checked", checked ? "checked" : "");
    		childNodes[i].setAttribute("mixed", "");
    		removeFromMixed(childNodes[i]);
    	}
    	if(recursive){
    		checkNodeDescendants(childNodes[i], recursive, checked);
    	}
    }
	
}

function checkNodeAncestors(node,recursive, state)
{
	if(!node){
		return;
	}
	
	var parent = node.parentNode;
	if(parent && parent.tagName != "rows"){
		var siblings = parent.childNodes;
		for(var i = 0; i < siblings.length; i++){
			if(siblings[i].tagName == "r"){
				if(state != checkNodeState(siblings[i])){
					state = "mixed";
					break;
				}
			}
		}
		
		if("mixed" == state){
			parent.setAttribute("checked", "checked");
			parent.setAttribute("mixed", "true");
			addToMixed(parent);
		}else if("checked" == state){
			parent.setAttribute("checked", "checked");
			parent.setAttribute("mixed", "");
			removeFromMixed(parent);
		}else{
			parent.setAttribute("checked", "");
			parent.setAttribute("mixed", "");
			removeFromMixed(parent);
		}
		checkNodeAncestors(parent,recursive, state)
	}

}


function removeFromMixed(node)
{
	for(var i = 0; i < mixedNodes.length; i++){
			if(mixedNodes[i].getAttribute("id") == node.getAttribute("id")){
				mixedNodes.splice(i, 1);
				return true;
			}
	}
}
function addToMixed(node)
{
	removeFromMixed(node);
	mixedNodes.push(node);
}
function clearMixed()
{
	for(var i = 0; i < mixedNodes.length; i++){
		mixedNodes[i].setAttribute("mixed", "");
	}
	mixedNodes = new Array();
}
function checkNodeState(node)
{
	if("checked" == node.getAttribute("checked")){
		if("true" == node.getAttribute("mixed")){
			return "mixed";
		}else{
			return "checked";
		}
	}else{
		return "unchecked";
	}

}

function getSelectedNodes()
{
    var selectedXML = emxUICore.createXMLDOM();
    var nRoot = selectedXML.createElement("mxRoot");
    selectedXML.appendChild(nRoot);

	var rows = selectedXML.createElement("rows");
	nRoot.appendChild(rows);
	
	var srcRows = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows");
	copySelectedNodes(srcRows, rows);

	return selectedXML.xml;
}

function copySelectedNodes(source, target)
{
    for (var i = 0;  i < source.childNodes.length; i++) {
    	var childNodes = source.childNodes;
    	if(childNodes[i].getAttribute("checked") == "checked" && childNodes[i].tagName == "r"){
    		var clone = childNodes[i].cloneNode(false);
    		if("true" == childNodes[i].getAttribute("mixed") || "false" == childNodes[i].getAttribute("filter")){
				target.appendChild(clone);
    			copySelectedNodes(childNodes[i], clone);
    		}
    	}
	}
}
function isAnySelected()
{
	var selected = false;
	var srcRows = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows");
	for (var i = 0;  i < srcRows.childNodes.length; i++) {
		var childNodes = srcRows.childNodes;
    	if(childNodes[i].getAttribute("checked") == "checked" && childNodes[i].tagName == "r"){
    		selected = true;
    		break;
		}		
	}
	return selected;
}
function printSelectedNodes()
{

	logMsgLine("Selected Nodes: " + getSelectedNodes());
}

function FreezePaneregisterTSC(strID) {

    var aId = strID.split("|");
    var id = aId[3];
    var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
    
    if(!noSelectionCheck ){
	    removeFromMixed(rowNode);
	    checkNodeDescendants(rowNode, true, true);
	    checkNodeAncestors(rowNode, true, "checked");
    }
    //what if the same chapter occurs multiple times in the structure?
}

function FreezePaneunregisterTSC(strID) {
    var aId = strID.split("|");
    var id = aId[3];
    var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
    
    if(!noSelectionCheck ){
	    removeFromMixed(rowNode);
	    checkNodeDescendants(rowNode, true, false);
	    checkNodeAncestors(rowNode, true, "unchecked");
    }
    //what if the same chapter occurs multiple times in the structure?
}

function toggle2TSC(rowId){  
    //turnOnProgress();
	ElapsedTimer.enter('toggle2');
	setTimeout("removeMask()", 10);

    var dirRelType = "";
    var direction = ""; 
    //get to and from
    var toVal = (document.getElementById("to"))?document.getElementById("to").checked:0;
    var fVal = (document.getElementById("from"))?document.getElementById("from").checked:0;
    var nRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
    var display = nRow.getAttribute("display"); 
    if (toVal && fVal && expandLevel == "All" && display != "block"){
        alert(emxUIConstants.STR_ALLLEVEL_ERROR);        
        turnOffProgress();
		ElapsedTimer.exit('toggle2' + emxUIConstants.STR_ALLLEVEL_ERROR);
        return;
    }   
    if (document.getElementById("to")) {               
        if(toVal && fVal){
            resetParameter("direction","both");
            dirRelType += "&direction=both";
            direction = "both";
        }else if(toVal){
            resetParameter("direction","to");
            dirRelType += "&direction=to";
        }else if(fVal){
            resetParameter("direction","from");
            dirRelType += "&direction=from";
        }else{
            resetParameter("direction","both");
            dirRelType += "&direction=both";
            direction = "both";
        }
    }
    //get filters type
    var formItem = document.getElementById("select_type");
    var typeFilter = (formItem && formItem.options)?formItem[formItem.selectedIndex].value:0;

    if(typeFilter){
        resetParameter("selectedType",typeFilter);
        dirRelType += "&selectedType=" + typeFilter;
    }
    //relationship
    formItem = document.getElementById("select_relationship");
    var relFilter = (formItem && formItem.options)?formItem[formItem.selectedIndex].value:0;

    if(relFilter){
        resetParameter("selectedRelationship",relFilter);
        dirRelType += "&selectedRelationship=" + relFilter;
    }

    // Get the row being expanded or collapsed and toggle it's status
    display = (!display || display == "none") ? "block" : "none";
    nRow.setAttribute("display", display);

    // Check if row has already been expanded
    // if not then query server to get expanded nodes
    var expand = nRow.getAttribute("expand");
    var updateTableCache = "false";
    var toolbarData = "";

    if (editableTable.expandFilter || editableTable.customFilter){

        toolbarData = getToolbarData(editableTable.expandFilter);

        if (editableTable.expandFilter){
        expandLevel = document.getElementById("emxExpandFilter").value;

	        var expandedLevel = getExpandedLevel(nRow);

	        var strID = nRow.getAttribute("id");
			if (display == "block" &&
				expandLevel != expandedLevel &&
				expandLevel + ',' + expandedLevel != "All,All") 
			{
                expand = false;
                updateTableCache = "true";
            }
        }
        
        if ( (expand && toolbarData != globalStrData && display == "block")){
            expand = false;
            updateTableCache = "true";
        }

    if (!expand) {
            var childNodes = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id ='" + strID + "']/r");
            for (var itr = 0; itr < childNodes.length; itr++){
                childNodes[itr].parentNode.removeChild(childNodes[itr]);
            }
        }
    }
    
    if(toolbarData == "") {
    	toolbarData = "&toolbarData=";
    }

    globalStrData = toolbarData;


    if (!expand) {
      	var isExpandMultiLevelsJPO = emxUICore.selectSingleNode(oXML,"//requestMap/setting[@name='expandMultiLevelsJPO']");
        var strExpandMultiLevelsJPO = "false";
        if(isExpandMultiLevelsJPO != null && emxUICore.getText(isExpandMultiLevelsJPO))
            strExpandMultiLevelsJPO = emxUICore.getText(isExpandMultiLevelsJPO);
        var whereExp = "&levelId=" + rowId + dirRelType;
        bExpandOperation = true;
        var oLocalXML = null;
        //var requestMap = emxUICore.selectSingleNode(oXML,"//requestMap/setting[@name='expandFilter']/text()");
       
       if (editableTable.expandFilter && "false" == strExpandMultiLevelsJPO)
        {
            nRow.setAttribute("expandedLevels", expandLevel);
            globalStrData = toolbarData;
            // addMask();
            whereExp += toolbarData + "|updateTableCache=" + updateTableCache;
//          whereExp += getToolbarData()+ "|updateTableCache=" + updateTableCache;
            levelsExpanded = 0;
            oLocalXML = getXMLRows(timeStamp, whereExp, rowId);
        }
        else
        {	
		//addMask();
            oLocalXML = emxUICore.getXMLData("emxFreezePaneGetData.jsp?fpTimeStamp=" + timeStamp +
                                    "&levelId=" + rowId + dirRelType + toolbarData+"|updateTableCache=" + updateTableCache+"&IsStructureCompare="+isStructureCompare);

            ElapsedTimer.timeCheck("oLocalXML 1: " + emxUICore.selectNodes(oLocalXML, "/mxRoot/rows//r").length + " rows");

            if(editableTable.mode == "edit" && ((preProcessURL && preProcessURL !="") || (preProcessJPO && preProcessJPO !="")))
            {
                var action = processHookIn("pre", rowId);

                if (action.toLowerCase() == "stop") {
                    return;
                }

                    oLocalXML = emxUICore.getXMLDataPost("emxFreezePaneGetData.jsp?fpTimeStamp=" + timeStamp +
                                                 "&levelId=" + rowId + dirRelType + toolbarData+"&IsStructureCompare="+isStructureCompare);
                    ElapsedTimer.timeCheck("oLocalXML 2: " + emxUICore.selectNodes(oLocalXML, "/mxRoot/rows//r").length + " rows");
            }
            nRow.setAttribute("expandedLevels", expandLevel);
        	setTimeout("finishLongOperation()", 10);
        }
        if (oLocalXML ) {
            if("true" == strExpandMultiLevelsJPO){
	        	var aAllTempRows = emxUICore.selectNodes(oLocalXML, "/mxRoot/rows//r");
				ElapsedTimer.timeCheck("counted sAllTempRows: " + aAllTempRows.length);
                for(var p=0;p<aAllTempRows.length;p++){
                    if(aAllTempRows[p].getAttribute("display")==null)
                        aAllTempRows[p].setAttribute("display","block");
                }
            }
	        var aAllRows = emxUICore.selectNodes(oLocalXML, "/mxRoot/rows/r");
            for (var i = 0; i < aAllRows.length; i++) {
                nRow.appendChild(aAllRows[i].cloneNode(true));
            }
        }

        //**********************************************************
        //bug 377611
        if("mixed" == checkNodeState(nRow)){
	    	nRow.setAttribute("checked", "");
	    	nRow.setAttribute("mixed", "");
	    	removeFromMixed(nRow);
	    	checkNodeAncestors(nRow, true, "unchecked");
		   	var childNodes = nRow.getElementsByTagName("r");
		   	for(var i = 0; i < childNodes.length; i++){
		   		removeFromMixed(childNodes[i]);
		   	}
	    }else
	    if("checked" == checkNodeState(nRow)){
		   	//var childNodes = nRow.childNodes;
		   	var childNodes = nRow.getElementsByTagName("r");
		   	for(var i = 0; i < childNodes.length; i++){
		   		childNodes[i].setAttribute("checked", "checked");
		   	}
	   	}
	   	
		//**********************************************************
        
        nRow.setAttribute("expand", "true");
        /* Added for calc rows Feature */
        callToBuildColumValues("firstTime",true);
    }

    // As row has been expanded or collapsed, the display rows will change
    // so recalculate display rows again.
    aDisplayRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[(@level = '0' or count(ancestor::r[not(@display) or @display = 'none']) = '0')]");
    totalRows = aDisplayRows.length;
    var nTotalRows = emxUICore.selectSingleNode(oXML, "/mxRoot/setting[@name = 'total-rows']");
    emxUICore.setText(nTotalRows, totalRows);

    // redraw table and tree part
    rebuildView();

	if (!expand) {
		PreFetch(firstRow + pageSize - 1);
	}

    listHidden.document.location.assign("emxMQLNoticeWrapper.jsp");
    turnOffProgress();
	ElapsedTimer.exit('toggle2' + " normal");
	
	return false; /* don't call the original one */
}

function expandObjsCallbackTSC(objDOM, curLevel){
	ElapsedTimer.enter();
	
	if (curLevel) {
		if (editableTable.mode == "edit" && ((preProcessURL && preProcessURL != "") || (preProcessJPO && preProcessJPO != ""))) {
                    var action = processHookIn("pre", curLevel);

                    if (action.toLowerCase() == "stop") {
				finishLongOperation();
				ElapsedTimer.exit("cb-1");
                        return;
                    }

                    objDOM = emxUICore.getXMLDataPost("emxFreezePaneGetData.jsp?fpTimeStamp=" + timeStamp +
			"&levelId=" +
			curLevel +
			globalStrData +
			"&IsStructureCompare=" +
			isStructureCompare);
                }
		var aAllRows = emxUICore.selectNodes(objDOM, "/mxRoot/rows/r");
                var xPath = "/mxRoot/rows//r[@id = '" + curLevel + "']";
		
		var tempRow = emxUICore.selectSingleNode(oXML, xPath);
		if (tempRow) {
                    for (var i = 0; i < aAllRows.length; i++) {
                        childArray.push(aAllRows[i].getAttribute("id"));
				tempRow.appendChild(aAllRows[i].cloneNode(true));
                        totalObjects++;
                    }
                    tempRow.setAttribute("display", "block");
                    tempRow.setAttribute("expand", "true");
			        //**********************************************************
			        if("mixed" == checkNodeState(tempRow)){
				    	tempRow.setAttribute("checked", "");
				    	tempRow.setAttribute("mixed", "");
				    	removeFromMixed(tempRow);
				    	checkNodeAncestors(tempRow, true, "unchecked");
				   		var childNodes = tempRow.getElementsByTagName("r");
					   	for(var i = 0; i < childNodes.length; i++){
					   		removeFromMixed(childNodes[i]);
					   	}
				    }else
				    if("checked" == checkNodeState(tempRow)){
					   	//var childNodes = tempRow.childNodes;
					   	var childNodes = tempRow.getElementsByTagName("r");
					   	for(var i = 0; i < childNodes.length; i++){
					   		childNodes[i].setAttribute("checked", "checked");
					   	}
				   	}
				   	
					//**********************************************************
                }

		if (spanRowCounter == null || levelCounter == null) {
                    spanRowCounter = document.getElementById("mx_spanRowCounter");
                    levelCounter = document.getElementById("mx_spanlevelCounter");
                }
		if (levelCounter != null) {
                if (isIE) {
                    levelCounter.innerText = " " + (levelsExpanded + 1) + " " + emxUIConstants.STR_OBJMSG2 + ": ";
                    spanRowCounter.innerText = totalObjects;
			} else {
                    levelCounter.textContent = " " + (levelsExpanded + 1) + " " + emxUIConstants.STR_OBJMSG2 + ": ";
                    spanRowCounter.textContent = totalObjects;
                }
		}
                if (levelids.length == 0){
                    levelsExpanded++;
                }
                expandObjects("emxFreezePaneGetData.jsp?fpTimeStamp=" + timeStamp+"&IsStructureCompare="+isStructureCompare, sExpandCriteria);
	} else {
		finishLongOperation();
            }
	objHTTP = null;
	
	ElapsedTimer.exit("cb-2");
	
	return false; /* don't call the original one */
}



function renderPartialSelect()
{
	for(var i = 0; i < mixedNodes.length; i++){
		partialSelect(mixedNodes[i].getAttribute("id"));
	}
}

function partialSelect(id)
{
    //var nodes = document.getElementsByName(id); //does not work with firefox
    var nodes = getTableRowById(id);
    
    //alert(nodes.length);
    
    nodes = getHighlightedTDs(nodes);
    for(var i = 0; i < nodes.length; i++){
    	nodes[i].style.backgroundColor = "#FFD7BD";
    	//alert(nodes[i].style.backgroundColor);
    }
}

function getTableRowById(id)
{
	var result = new Array();
	var nodes = document.getElementsByTagName("TR");
    for(var i = 0; i < nodes.length; i++){
    	if(nodes[i].getAttribute("id") == id){
    		result[result.length] = nodes[i];
    	}
    }
	return result;
}

function getHighlightedTDs(rows)
{
	var result = new Array();
    for(var i = 0; i < rows.length; i++){
    	var children = rows[i].childNodes;
    	for(var j = 0; j < children.length; j++){
    		if((children[j].tagName == "TD" || children[j].tagName == "TH")){
    			result[result.length] = children[j];
    		}
    	}
    }
    return result;
}


function rebuildViewTSC(){
    renderPartialSelect();
}

//Start:T25 DJH 2013:02:22 IR-215543V6R2014: Replaced call of LoadXMLRemote() by RefreshViewScroll()
function GetNextPageTSC()
{    
    renderPartialSelect();
} 
//End:T25 DJH 2013:02:22

var mixedNodes = new Array();
var noSelectionCheck;

var logwin;
var loggingHolder;

function logMsgLine(message){
	logMsg(message + "\n\r");
}

function logMsg(message){
	if(rmm_debug){
		if(!logwin || logwin.closed){
			logwin = window.open("", "_blank");
			var logwinBody = logwin.document.getElementsByTagName('body')[0];
			logwin.document.write("<input type='button' value='clear' onclick='logHolder.innerHTML=\"\";'/><pre name='logHolder' id='logHolder'></pre>");
			 //KIE1 ZUD TSK447636 
			logwin.document.closeWindow();
			loggingHolder = logwin.document.getElementById("logHolder");
			
			window.focus();
		}
		if(logwin && !logwin.closed){
			var node = logwin.document.createTextNode(message);
			loggingHolder.appendChild(node);
			//node = logwin.document.createElement('br');
			//loggingHolder.appendChild(node);
		}
		
	}
	
}

function clearLogMessage(){
	if(logwin && !logwin.closed){
		loggingHolder.innerHTML = "";
	}
}


function logXmlMsgLine(message, node)
{
	logMsgLine(message + xml2String(node));
}

function xml2String(node)
{
	if( (isIE) ){
		return node.xml;
	}else{
		return new XMLSerializer().serializeToString(node);
	}

}

function getSimpleTimeFormat(d)
{
	var m = d.getMilliseconds();
	return d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds() + "." + (m < 10 ? "00" : (m < 100 ? "0" : "")) + m;
}
function logTimestamp(sMsg, d)
{
	if(!d){
		d = new Date();
	}
	logMsgLine(getSimpleTimeFormat(d) + ": " + sMsg);
}
function logTimestampLong(sMsg, lMillisec)
{
	if(lMillisec == undefined){
		lMillisec = new Date().getTime();
	}
	var d = new Date();
	d.setTime(lMillisec);
	logTimestamp(sMsg, d);
}


function callSubmitURLTSC(url, bSynch){
	if(!url.contains("traceabilityreport=true")){
		var callbackFunc = getRequestSetting('callbackFunction');
		if ((callbackFunc == null || callbackFunc == "") && 
			url != null && url != "" && !bSynch) 
		{
			//***************************************
			if(!isAnySelected()){
				alert(RMTConstants.noSelectionWarning);
				return false;
			}
			var xmlMsg = document.getElementById('xmlmsg');
			
			if(!xmlMsg){
				xmlMsg = document.createElement('input');
				xmlMsg.id = 'xmlmsg';
				xmlMsg.name = 'xmlmsg';
				xmlMsg.type = 'hidden';
				document.emxTableForm.appendChild(xmlMsg);
			}
			
			//xmlMsg.setAttribute('value', getSelectedNodes());
			document.emxTableForm.xmlmsg.value = btoa(getSelectedNodes());
			//*******************************************
		}
	}else{
		return true;
	}
}

