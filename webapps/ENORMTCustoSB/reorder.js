//=================================================================
// JavaScript reorder.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview JX5			04:29:15	IR-368345-3DEXPERIENCER2016x :  Drag and Drop functionality display root Requirement Specification name incorrect. 
//quickreview JX5			05:07:15	IR-368841-3DEXPERIENCER2016x : using drag and drop to reorganize requirements, this action needs to take a lot of time.
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
//quickreview HAT1 ZUD      08:09:16    IR-173726-3DEXPERIENCER2017x STP: Edit commands are not working on multiple selection at same level.

if(localStorage['debug.AMD']) {
	var _RMTReorder_js = _RMTReorder_js || 0;
	_RMTReorder_js++;
	console.info("AMD: ENORMTCustoSB/reorder.js loading " + _RMTReorder_js + " times.");
}

define('DS/ENORMTCustoSB/reorder', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/reorder.js dependency loaded.");
	}
	emxUICore.instrument(window, 'cut', beforeCut, null);
	emxUICore.instrument(window, 'copy', beforeCopy, null);
	emxUICore.instrument(window, 'pasteBelow', beforePasteBelow, afterPaste);
	emxUICore.instrument(window, 'pasteAbove', beforePasteAbove, afterPaste);
	emxUICore.instrument(window, 'pasteAsChild', beforePasteAsChild, afterPaste);
	emxUICore.instrument(window, 'applyEdits', beforeApplyEdits, null);

	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/reorder.js finish.");
	}	
	return {};
});


//JX5 to keep hand on bps postDataXML
var rmtModifiedRowIds = new Array();
//

function beforeCut() {
    var aRowIds = new Array();
    var rowsChecked = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[@checked='checked']");
    if (rowsChecked.length == 0)
        return;
    for (var i = 0; i < rowsChecked.length; i++) {
        var child = rowsChecked[i];

        var pid = child.getAttribute("p");
        var oid = child.getAttribute("o");
        var rid = child.getAttribute("r");
        if (!rid || !pid)
            continue;
        aRowIds.push(rid + "|" + oid + "|" + pid);
    }

    if (aRowIds.length == 0)
        return;
    return RMTValidationReorderOperation("Cut", aRowIds, false);
}

function beforeCopy() {
    var rowsChecked = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[@checked='checked']");
    if (rowsChecked.length == 0)
        return;

    if (preValidationsForEdit(rowsChecked)) {
        for (var i = 0; i < rowsChecked.length; i++) {
            rowsChecked[i].setAttribute("checked", "");
        }
        rebuildView();
        return false;
    }
    var aRowIds = new Array();
    for (var i = 0; i < rowsChecked.length; i++) {
        var child = rowsChecked[i];

        var pid = child.getAttribute("p");
        var oid = child.getAttribute("o");
        var rid = child.getAttribute("r");
        aRowIds.push(rid + "|" + oid + "|" + pid);
    }

    return RMTValidationReorderOperation("Copy", aRowIds, false);
}

function beforePasteBelow() {
    var aPastedReferenceRows = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[@checked='checked']");
    return RMTValidatePasteOperation("paste-below", aPastedReferenceRows,
        aCopiedRowsChecked, false);
}

function beforePasteAbove() {
    var aPastedReferenceRows = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[@checked='checked']");
    return RMTValidatePasteOperation("paste-above", aPastedReferenceRows,
        aCopiedRowsChecked, false);
}

function beforePasteAsChild() {
    var aPastedReferenceRows = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[@checked='checked']");
    return RMTValidatePasteOperation("paste-as-child", aPastedReferenceRows,
        aCopiedRowsChecked, false);
}

function RMTValidatePasteOperation(action, pCheckedRows, nCopiedRows, bCheckOnly) {
    // get all cut objects
    var allRows = emxUICore.selectNodes(postDataXML, "/mxRoot/object");
    if (!pCheckedRows || pCheckedRows.length == 0)
        return;
    if (!nCopiedRows || nCopiedRows.length == 0)
        return;
    var cutObject = new Array();
    // check if a cut object is pasted twice.
    for (var i = 0; i < nCopiedRows.length; i++) {
        if (nCopiedRows[i].getAttribute("status") == "cut") {
            cutObject.push(nCopiedRows[i].getAttribute("r"));
        }
    }
    // check if the cut object has been previously pasted
    for (var i = 0; i < allRows.length; i++) {
        var children = allRows[i];
        for (var j = 0; j < children.childNodes.length; j++) {
            childNode = children.childNodes[j];
            if (childNode.getAttribute("markup") == "add") {
                if (cutObject.indexOf(childNode.getAttribute("relId")) >= 0) {
                    alert(SBOnlyOnePasteAllowedText);
                    return false;
                }
            }
        }
    }
    
    // ++ HAT1 ZUD: IR-173726-3DEXPERIENCER2017x: fix 
    if (cutObject.length > 0 && pCheckedRows.length > 1) {
        alert(SBOnlyOnePasteAllowedText);
        var pasteAboveOrBelow = pCheckedRows[0];
        for(var i=1; i<pCheckedRows.length; i++)
        	pCheckedRows[i].setAttribute("checked", "unchecked");
        
        pCheckedRows = [];
        pCheckedRows.push(pasteAboveOrBelow);   

        //return false;
    }
    // -- HAT1 ZUD: IR-173726-3DEXPERIENCER2017x: fix
    
    var aRowIds = new Array();
    for (var i = 0; i < pCheckedRows.length; i++) {
        for (var j = 0; j < nCopiedRows.length; j++) {
            var parent = pCheckedRows[i];
            var child = nCopiedRows[j];

            if (action != "paste-as-child") {
                parent = pCheckedRows[i].parentNode;

            }
            var pid = child.getAttribute("p");
            var oid = child.getAttribute("o");
            var rid = child.getAttribute("r");
            var newpid = parent.getAttribute("o");
            var refrid = pCheckedRows[i].getAttribute("r");
            var refoid = pCheckedRows[i].getAttribute("o");
            if (!newpid)
                continue;

            aRowIds.push(rid + "|" + oid + "|" + pid + "|" + newpid + "|" + refrid + "|" + refoid);
        }
    }
    if (aRowIds.length == 0)
        return;

    return RMTValidationReorderOperation("Paste", aRowIds, bCheckOnly);
}

function RMTValidationReorderOperation(mode, aRowIds, bCheckOnly) {
    var rowIds = "rowIds=";
    for (var i = 0; i < aRowIds.length; i++) {
        rowIds += aRowIds[i];
        if (i != aRowIds.length - 1)
            rowIds += ",";
    }

    var bReorderOK = false;
    $.ajax({
        url: "../requirements/ReorderValidation.jsp?mode=" + mode,
        cache: true,
        processData: false,
        async: false,
        contentType: "text",
        type: "POST",
        data: rowIds,
        dataType: "text",
        success: function(txt) {

            var xmlResponse = emxUICore.createXMLDOM();
            xmlResponse.loadXML(txt);
            emxUICore.checkDOMError(xmlResponse);

            var root = xmlResponse.documentElement;
            var xPath = "message/text()";
            var msg = emxUICore.selectSingleNode(root, xPath).nodeValue;
            if (msg && msg != null && msg != "") {
                if (!bCheckOnly)
                    alert(msg);
                bReorderOK = false;
            } else
                bReorderOK = true;
        }
    });
    return bReorderOK;
}

function afterPaste() {

}

function refreshStructureTree() {
    // Legacy method, useless today for RMT
}


// END : LX6 IR-221725V6R2014 "STP: Rearranging of RMT object in Requirement
//START:IR211141 LX6 critSit Ford correction
function reorderObjectsByLevel(allModifiedRows, cutObjects) {
    var map = [];
    for (var i = 0; i < cutObjects.length; i++) {
        map[cutObjects[i].getAttribute("relId")] = cutObjects[i].getAttribute("rowId");
    }
    for (var i = 0; i < allModifiedRows.length; i++) {
        var children = allModifiedRows[i];
        reorderObjects(children, map);
    }
}

function reorderObjects(children, map) {
    var flag = false;
    for (var j = 0; j < children.childNodes.length - 1; j++) {
        firstChildNode = children.childNodes[j];
        firstMarkup = firstChildNode.getAttribute("markup");

        secondChildNode = children.childNodes[j + 1];
        secondMarkup = secondChildNode.getAttribute("markup");
        if (firstMarkup == "add") {
            if (secondMarkup == "add") {
                var firstId = firstChildNode.getAttribute("relId");
                var firstRowId = map[firstId];
                var firstLevel = firstRowId.split(",").length;

                var secondId = secondChildNode.getAttribute("relId");
                var secondRowId = map[secondId];
                var secondLevel = secondRowId.split(",").length;
                if (secondLevel > firstLevel) {
                    flag = true;
                    //move objects!!!!!!!!!!
                    children.removeChild(secondChildNode);
                    children.insertBefore(secondChildNode, firstChildNode);
                }
            } else {
                //nothing to do
            }
        } else {
            if (secondMarkup == "add") {
                flag = true;
                //move objects!!!!!!!!!!
                children.removeChild(secondChildNode);
                children.insertBefore(secondChildNode, firstChildNode);
            } else {
                //nothing to do
            }
        }
    }
    if (flag == true) {
        reorderObjects(children, map);
    }
}


function beforeApplyEdits() {
	
	//JX5 clear array
	rmtModifiedRowIds = new Array();
	//
	
    var cutObject = new Array();
    var pasteObjects = new Array();
    var allRows = emxUICore.selectNodes(postDataXML, "/mxRoot/object");
    for (var i = 0; i < allRows.length; i++) {
        var children = allRows[i];
        
        //JX5 keep hand on modified parent objects
        if(children.getAttribute('markup') == 'changed'){
            rmtModifiedRowIds.push(children.getAttribute('rowId'));
        }
        //JX5 end
        
        for (var j = 0; j < children.childNodes.length; j++) {
            childNode = children.childNodes[j];
            
            //JX5 keep hand on cut/copy/paste/resequence objects
            var childRowId 	= null;
            var parentRowId = null;
            var temp		= null;
            if(childNode.getAttribute("markup") == 'cut'){
            	childRowId = childNode.getAttribute('rowId');
            	rmtModifiedRowIds.push(childRowId);
            }else if(childNode.getAttribute("markup") == 'add'){
            	childRowId 	= childNode.getAttribute('rowId');
            	var pasteAbove 		= childNode.getAttribute('paste-above');
            	var pasteBelow 		= childNode.getAttribute('paste-below');
            	var pasteAsChild 	= childNode.getAttribute('paste-as-child');
            	
            	if(pasteAbove){
            		temp = pasteAbove.split('|');    		
            	}else if(pasteBelow){
            		temp = pasteBelow.split('|'); 
            	}else if(pasteAsChild){
            		temp = pasteAsChild.split('|'); 
            	}
            	if(temp)
            		parentRowId = temp[temp.length-1];
            	else
            		parentRowId = '';
            	//need to refresh child and parent
            	if(!parentRowId) {
                	rmtModifiedRowIds.push(parentRowId);
            	}
            	rmtModifiedRowIds.push(childRowId);
            }else if(childNode.getAttribute("markup") == 'resequence'){
            	childRowId 			= childNode.getAttribute('rowId');
            	
            	var pasteAbove 		= childNode.getAttribute('paste-above');
            	var pasteBelow 		= childNode.getAttribute('paste-below');
            	var pasteAsChild 	= childNode.getAttribute('paste-as-child');
            	
            	if(pasteAbove){
            		temp = pasteAbove.split('|');    		
            	}else if(pasteBelow){
            		temp = pasteBelow.split('|'); 
            	}else if(pasteAsChild){
            		temp = pasteAsChild.split('|'); 
            	}
            	
            	if(temp)
            		parentRowId = temp[temp.length-1];
            	else
            		parentRowId = '';
            	rmtModifiedRowIds.push(parentRowId);
            	rmtModifiedRowIds.push(childRowId);
            }
            //JX5 End
            
            if (childNode.getAttribute("markup") == "cut") {
                cutObject.push(children.childNodes[j]);
            } else {
                pasteObjects.push(children.childNodes[j]);
            }
        }
    }
    for (var i = 0; i < cutObject.length; i++) {
        CutObjectId = cutObject[i].getAttribute("relId");
        for (var j = 0; j < pasteObjects.length; j++) {
            pasteObjectId = pasteObjects[j].getAttribute("relId");
            if (CutObjectId.toString() == pasteObjectId.toString()) {
                cutObject[i].setAttribute("recycle", "true");
                pasteObjects[j].setAttribute("recycle", "true");
            }
        }
    }

    if (doReconcile == true) {
        //START LX6 critSit Ford correction
        reorderObjectsByLevel(allRows, cutObject);
        //END LX6 critSit Ford correction
    }
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/reorder.js global finish.");
}
