//=================================================================
// JavaScript explorer.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================

/* Contains code for the new dynaTree used in SB and SCE */
// @quickreview JX5 T94 IR-305271-3DEXPERIENCER2015x : Embedded SB in CATIA
// @quickreview JX5 T94 IR-315938-3DEXPERIENCER2015x : "<>" support: Name is truncated after �<� on structure tree
// @quickreview JX5 T94 IR-376555-3DEXPERIENCER2016x : Content column shrink if user expand rich text and then click on "Enable Edit". 
//													   Complementary fix suggested/requested by T94
// @quickreview QYG     IR-434537-3DEXPERIENCER2017x : Mislignment occurs after edit and save operation on content data
// @quickreview QYG     05:03:16    javascript refactoring, moved from jquery.dynatree-RMT.js
// @quickreview KIE1 ZUD : IR-448762-3DEXPERIENCER2017x: Tree preferences not applicable on Structure browser
// @quickreview KIE1 ZUD : 12/02/2016 :IR-486350-3DEXPERIENCER2018x: Issue view BOM certificat Manufacturing/Production / 3DEXPERIENCE R2016x FP.CFA.1646 / LINUX-Red Hat 5.5
// @quickreview HAT1 ZUD : 30/05/2017 :IR-523564-3DEXPERIENCER2018x: R419-STP: Side Tree panel does not load after user invoke covered or refined link dialogue box.
// @quickreview HAT1 ZUD : 09/06/2017 :IR-523359-3DEXPERIENCER2018x:  The last line of rich text is invisible in structure browser. 
// @quickreview ZUD      : 20/11/2018 : IR-634489-3DEXPERIENCER2017x: Scrolling lag issue in large Requirement Specifications


/*****************************************************************************/
/*****************************************************************************/
/**                   SIMPLE EXPLORER - STRUCTURE BROWSER                   **/
/*****************************************************************************/
/*****************************************************************************/

define('DS/ENORMTCustoSB/explorer', ['DS/RichEditorCusto/Util'], function(){
	// To expand back after a refresh view
	emxUICore.instrument(getTopWindow().sb, 'rebuildView', null, function() {
		// We have to expand
		if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == 'true') {
		    expandRichTextContentFromDynaTree(false);
		}
	});

	emxUICore.instrument(getTopWindow().sb, 'toggle2', null, aToggle2RMT);
	emxUICore.instrument(getTopWindow().sb, '_delay_expandAll', null, expandAllDynaTreeRMT);
	emxUICore.instrument(getTopWindow().sb, '_delay_expandNLevels', null, expandAllDynaTreeRMT);
	emxUICore.instrument(getTopWindow().sb, 'SCEExpandAll', null, expandAllDynaTreeRMT);
	emxUICore.instrument(getTopWindow().sb, 'SCECollapseAll', null, collapseAllDynatreeRMT);

	return {};
});

var COMMENT_TYPE = 'Comment';
var REQUIREMENT_TYPE = 'Requirement';
var CHAPTER_TYPE = 'Chapter';

/** 
 * 
 * CUSTOM PASTE BELOW 
 * 
 * **/
function doPasteBelow(aPastedRowsChecked, aCopiedRowsChecked) {
    if (!validatePasteOperation("paste-above", aPastedRowsChecked,
            aCopiedRowsChecked)) {
        rebuildView();
        return;
    }
    pasteRels = pasteRels.reverse();

    // To clone the copied row/node
    var iClone = 0;
    var nTempvariable = 0;
    var nCopiedRowsLength = aCopiedRowsChecked.length;
    var clonedRows = getCopiedRowXMLFromDB(aCopiedRowsChecked,
            aPastedRowsChecked, "pasteBelow");
    for ( var i = 0; i < aPastedRowsChecked.length; i++) {
        var nNewRow = new Array();
        var nTempNewRows = emxUICore.selectNodes(clonedRows, "/mxRoot/rows//r");
        for (; iClone < (nTempvariable + nCopiedRowsLength); iClone++) {
            nNewRow.push(nTempNewRows[iClone].cloneNode(true));
        }
        nTempvariable = nTempvariable + nCopiedRowsLength;
        nNewRow.reverse();
        var parentIDofPasteRow = aPastedRowsChecked[i].parentNode
                .getAttribute("o");
        var selectedPastedParentID = aPastedRowsChecked[i].getAttribute("p");

        for ( var k = 0; k < nNewRow.length; k++) {

            var pasteBelow = aPastedRowsChecked[i].nextSibling;
            var IdforNewlyAddedRow = nNewRow[k].getAttribute("id");
            var copiedParentID = nNewRow[k].getAttribute("p");
            nNewRow[k].setAttribute("relType", pasteRels.pop());

            var newNode = postDataXML.createElement("object");
            newNode.setAttribute("objectId", parentIDofPasteRow);
            
            // Checking weather the parent Nodes are matching
            if (selectedPastedParentID == copiedParentID) {
                if (pasteBelow != null) {
                    var nTempRow = nNewRow[k].cloneNode(true);
                    // nTempRow.setAttribute("id",IdforNewlyAddedRow);
                    nTempRow.setAttribute("p", parentIDofPasteRow);
                    nTempRow.setAttribute("checked", "");

                    if (cutFlag == 1 && resqFlag == 1) {
                        if (pasteBelow != null) {
                            pasteBelow.parentNode.insertBefore(nTempRow,
                                    pasteBelow).setAttribute("status",
                                    "resequence");
                        } else {
                            pasteBelow.parentNode.appendChild(nTempRow)
                                    .setAttribute("status", "resequence");
                        }
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                        hideCutRows(nNewRow[k]);
                        copyFlag = 1;
                        pasteFlag = 0;
                    } else if (cutFlag == 0 && resqFlag == 1 && copyFlag == 0) {
                        if (pasteBelow != null) {
                            pasteBelow.parentNode.insertBefore(nTempRow,
                                    pasteBelow).setAttribute("status",
                                    "resequence");
                        } else {
                            pasteBelow.parentNode.appendChild(nTempRow)
                                    .setAttribute("status", "resequence");
                        }
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                        hideCutRows(nNewRow[k]);
                        copyFlag = 2;
                        pasteFlag = 0;
                    } else if (cutFlag == 0 && resqFlag == 0) {
                        // To show the relation attributes as BLANK 
                        // for newly added row
                        nTempRow = showBlankRelAttribForAddedRow(nTempRow);
                        nTempRow.removeAttribute("displayRow");
                        pasteBelow.parentNode
                                .insertBefore(nTempRow, pasteBelow)
                                .setAttribute("status", "add");
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                    } else {
                        alert(emxUIConstants.STR_SBEDIT_NO_RESEQ_OPERATION);
                        rebuildView();
                        return;
                    }
                }
                // If it is the last node in the level i.e pasteBelow is NULL
                else {
                    var pasteBelow = aPastedRowsChecked[i];
                    var nTempRow = nNewRow[k].cloneNode(true);
                    nTempRow.setAttribute("p", parentIDofPasteRow);
                    nTempRow.setAttribute("checked", "");

                    if (cutFlag == 1 && resqFlag == 1) {
                        pasteBelow.parentNode.appendChild(nTempRow)
                                .setAttribute("status", "resequence");
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                        hideCutRows(nNewRow[k]);
                        copyFlag = 1;
                        pasteFlag = 0;
                    } else if (cutFlag == 0 && resqFlag == 1 && copyFlag == 0) {
                        pasteBelow.parentNode.appendChild(nTempRow)
                                .setAttribute("status", "resequence");
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                        hideCutRows(nNewRow[k]);
                        copyFlag = 2;
                        pasteFlag = 0;
                    } else if (cutFlag == 0 && resqFlag == 0) {
                        // To show the relation attributes as BLANK ..for newly
                        // added row
                        nTempRow = showBlankRelAttribForAddedRow(nTempRow);
                        nTempRow.removeAttribute("displayRow");
                        pasteBelow.parentNode.appendChild(nTempRow)
                                .setAttribute("status", "add");
                        updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                                aPastedRowsChecked[i], IdforNewlyAddedRow,
                                false);
                    } else {
                        alert(emxUIConstants.STR_SBEDIT_NO_RESEQ_OPERATION);
                        rebuildView();
                        return;
                    }
                }
            }
            // To paste the item on different Level as a simple paste
            else {
                var pasteBelow = aPastedRowsChecked[i];
                var levelofPasteRow = aPastedRowsChecked[i]
                        .getAttribute("level");
                var parentIDofPasteRow = aPastedRowsChecked[i]
                        .getAttribute("p");
                var nTempRow = nNewRow[k].cloneNode(true);
                // nTempRow.setAttribute("id",IdforNewlyAddedRow);
                nTempRow.setAttribute("level", levelofPasteRow);
                nTempRow.setAttribute("p", parentIDofPasteRow);
                nTempRow.setAttribute("checked", "");
                // To show the relation attributes as BLANK ..for newly added
                // row
                nTempRow = showBlankRelAttribForAddedRow(nTempRow);
                nTempRow.removeAttribute("displayRow");
                if (pasteBelow != null) {
                    pasteBelow.parentNode.insertBefore(nTempRow, pasteBelow)
                            .setAttribute("status", "add");
                    updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                            aPastedRowsChecked[i], IdforNewlyAddedRow, true);
                } else {
                    aPastedRowsChecked[i].parentNode.appendChild(nTempRow)
                            .setAttribute("status", "add");
                    updatePostDataXMLForEdit("pasteBelow", nNewRow[k],
                            aPastedRowsChecked[i], IdforNewlyAddedRow, true);
                }
                pasteFlag = 1;
            }
        }
        if (pasteFlag == 0)
            cutFlag = 0;
        rebuildView();
    }

    rebuildView();
}
// End-paste below

/** 
 * 
 * CUSTOM PASTE BELOW 
 * 
 * **/
function doPasteAbove(aPastedRowsChecked, aCopiedRowsChecked) {
    if (!validatePasteOperation("paste-above", aPastedRowsChecked,
            aCopiedRowsChecked)) {
        rebuildView();
        return;
    }
    pasteRels = pasteRels.reverse();

    // To clone the copied row/node
    var iClone = 0;
    var nTempvariable = 0;
    var nCopiedRowsLength = aCopiedRowsChecked.length;
    var clonedRows = getCopiedRowXMLFromDB(aCopiedRowsChecked,
            aPastedRowsChecked, "pasteAbove");
    for ( var i = 0; i < aPastedRowsChecked.length; i++) {
        var nNewRow = new Array();
        var nTempNewRows = emxUICore.selectNodes(clonedRows, "/mxRoot/rows//r");
        for (; iClone < (nTempvariable + nCopiedRowsLength); iClone++) {
            nNewRow.push(nTempNewRows[iClone].cloneNode(true));
        }
        nTempvariable = nTempvariable + nCopiedRowsLength;
        for ( var k = 0; k < nNewRow.length; k++) {
            var parentIDofPasteRow = aPastedRowsChecked[i].parentNode
                    .getAttribute("o");
            var selectedPastedParentID = aPastedRowsChecked[i]
                    .getAttribute("p");

            // To update the postdata XML
            var newNode = postDataXML.createElement("object");
            newNode.setAttribute("objectId", parentIDofPasteRow);
            // End-update postdataXML

            var copiedParentID = nNewRow[k].getAttribute("p");
            nNewRow[k].setAttribute("relType", pasteRels.pop());

            // Checking weather the parent Nodes are matching
            if (selectedPastedParentID == copiedParentID) {
                var IdforNewlyAddedRow = nNewRow[k].getAttribute("id");
                var nTempRow = nNewRow[k].cloneNode(true);
                nTempRow.setAttribute("p", parentIDofPasteRow);
                nTempRow.setAttribute("checked", "");

                if (cutFlag == 1 && resqFlag == 1) {
                    aPastedRowsChecked[i].parentNode.insertBefore(nTempRow,
                            aPastedRowsChecked[i]).setAttribute("status",
                            "resequence");
                    updatePostDataXMLForEdit("pasteAbove", nNewRow[k],
                            aPastedRowsChecked[i], IdforNewlyAddedRow, false);
                    hideCutRows(nNewRow[k]);
                    copyFlag = 1;
                    pasteFlag = 0;
                } else if (cutFlag == 0 && resqFlag == 1 && copyFlag == 0) {
                    aPastedRowsChecked[i].parentNode.insertBefore(nTempRow,
                            aPastedRowsChecked[i]).setAttribute("status",
                            "resequence");
                    updatePostDataXMLForEdit("pasteAbove", nNewRow[k],
                            aPastedRowsChecked[i], IdforNewlyAddedRow, false);
                    hideCutRows(nNewRow[k]);
                    copyFlag = 2;
                    pasteFlag = 0;
                } else if (cutFlag == 0 && resqFlag == 0) {
                    // To show the relation attributes as BLANK 
                    // for newly added row
                    nTempRow = showBlankRelAttribForAddedRow(nTempRow);
                    nTempRow.removeAttribute("displayRow");
                    aPastedRowsChecked[i].parentNode.insertBefore(nTempRow,
                            aPastedRowsChecked[i])
                            .setAttribute("status", "add");
                    updatePostDataXMLForEdit("pasteAbove", nNewRow[k],
                            aPastedRowsChecked[i], IdforNewlyAddedRow, false);
                } else {
                    alert(emxUIConstants.STR_SBEDIT_NO_RESEQ_OPERATION);
                    rebuildView();
                    return;
                }
            }
            // To paste the item on different Level as a simple paste
            else {
                var levelofPasteRow = aPastedRowsChecked[i]
                        .getAttribute("level");
                var parentIDofPasteRow = aPastedRowsChecked[i]
                        .getAttribute("p");
                var IdforNewlyAddedRow = nNewRow[k].getAttribute("id");

                var nTempRow = nNewRow[k].cloneNode(true);
                nTempRow.setAttribute("p", parentIDofPasteRow);
                nTempRow.setAttribute("checked", "");
                nTempRow.setAttribute("level", new Number(levelofPasteRow));
                // To show the relation attributes as BLANK 
                // for newly added row
                nTempRow = showBlankRelAttribForAddedRow(nTempRow);
                nTempRow.removeAttribute("displayRow");
                aPastedRowsChecked[i].parentNode.insertBefore(nTempRow,
                        aPastedRowsChecked[i]).setAttribute("status", "add");

                updatePostDataXMLForEdit("pasteAbove", nNewRow[k],
                        aPastedRowsChecked[i], IdforNewlyAddedRow, true);
                pasteFlag = 1;
            }
        }
        if (pasteFlag == 0)
            cutFlag = 0;
        rebuildView();
    }
    rebuildView();
}
// End-paste Above

/** 
 * 
 * CUSTOM PASTE BELOW 
 * 
 * **/
function doCopy(copiedRowIds) {
    aCopiedRowsChecked = new Array();
    aCopiedRowsChecked = getSelectedRowObjects(copiedRowIds);

    for ( var i = 0; i < aCopiedRowsChecked.length; i++) {
        aCopiedRowsChecked[i].setAttribute("checked", "");
    }

    arrObjectId = new Array();
    var toolBarFrame = this;
    parent.ids = "";

    if (toolBarFrame && toolBarFrame.toolbars
            && toolBarFrame.toolbars.setListLinks) {
        toolBarFrame.toolbars.setListLinks(parent.ids.length > 1,
                'structureBrowser', editableTable.mode);
    }

    var amodfiedrowsChecked = new Array();
    amodfiedrowsChecked = emxUICore
            .selectNodes(
                    oXML,
                    "/mxRoot/rows//r[@checked='checked' and (@status = 'cut'or @status='add'or @status='resequence'or @status='changed')]");
    if (amodfiedrowsChecked.length > 0) {
        alert(emxUIConstants.STR_SBEDIT_NO_EDIT_OPERATION);
        aCopiedRowsChecked = new Array();
        rebuildView();
        return;
    }

    lastOperation = "copy";

    cutFlag = 0;
    resqFlag = 0;
    rebuildView();
}
//End-copy

var aCopiedRowDynaTree = null;
function cutForDynaTree(cutRowId) {
    aCopiedRowDynaTree = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + cutRowId + "']");
    doCut(aCopiedRowDynaTree);
    lastOperation = "cut";
    rebuildView();
}

function copyForDynaTree(copyRowId) {
    aCopiedRowDynaTree = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + copyRowId + "']");
    doCopy(aCopiedRowDynaTree);
    lastOperation = "copy";
    rebuildView();
}

function pasteAsChildDynaTree(pasteRowId) {
    doPasteAsChild(emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + pasteRowId + "']"), aCopiedRowDynaTree);
}

function pasteAboveDynaTree(pasteRowId) {
    doPasteAbove(emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + pasteRowId + "']"), aCopiedRowDynaTree);
}

function pasteBelowDynaTree(pasteRowId) {
    doPasteBelow(emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + pasteRowId + "']"), aCopiedRowDynaTree);
}

/** 
 * 
 * CONTEXT MENU implement Cut/Copy/Paste
 * 
 * **/
var clipboardNode = null;
var pasteMode = null;

function copyPaste(action, node) {
    switch (action) {
    case "cut":
        clipboardNode = node;
        pasteMode = action;
        cutForDynaTree([node.data['objectRowId']]);
        break;
    case "copy":
        clipboardNode = node;
        pasteMode = action;
        copyForDynaTree([node.data['objectRowId']]);
        break;
    case "paste":
        if (!clipboardNode) {
            alert("Clipoard is empty.");
            break;
        }
        
        if (pasteMode == "cut") {
            // Cut mode: check for recursion and remove source
            var isRecursive = false;
            var cb = clipboardNode.toDict(true, function(dict) {
                // If one of the source nodes is the target, we must not move
                if (dict.key == node.data.key)
                    isRecursive = true;
            });
            if (isRecursive) {
                alert("Cannot move a node to a sub node.");
                return;
            }
            pasteAsChildDynaTree(node.data['objectRowId']);
            node.addChild(cb);
            applyEdits();
            clipboardNode.remove();
        } else {
            // Copy mode: prevent duplicate keys:
            var cb = clipboardNode.toDict(true, function(dict) {
                // dict.title = "Copy of " + dict.title;
                delete dict.key; // Remove key, so a new one will be created
            });
            pasteAsChildDynaTree(node.data['objectRowId']);
            node.addChild(cb);
            applyEdits();
        }
        clipboardNode = pasteMode = null;
        break;
    default:
        alert("Unhandled clipboard action '" + action + "'");
    }
};

/**
 * Context menu for Structure Explorer, who actually calls the context menu from SB
 * @param event
 */
function structureExplorerMenu(event) {
    var span = event.target;

	emxUICore.getEvent().preventDefault();
	emxUICore.getEvent().stopPropagation();

	var node = $.ui.dynatree.getNode(span);
	
	var rootObjectId = emxUICore.selectNodes(oXML, '/mxRoot/rows//r[@o]')[0].getAttribute('o'),
	targetObject = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='" + node.data["objectId"] + "']")[0];

	/* Root objectId - - - - - r attribute | o attribute | root obkjectId | id attribute */
	var rmbUrl = 'emxUIDynamicMenu.jsp?RMBMenu=RMTSCETreeRMBDynamic&frmRMB=true&objectId=' + 
	rootObjectId + '&uiType=structureBrowser&timeStamp=' + timeStamp + '&rmbTableRowId=' + 
	targetObject.getAttribute('r') + '|' + targetObject.getAttribute('o') + '|' + 
	rootObjectId + '|' + targetObject.getAttribute('id') + '&appendRMBMenu=' + jQuery('#treeBodyTable').find('.root-node').find('td')[1].getAttribute('rmb');
	
	var rmbdata = emxUICore.getData(rmbUrl);
	rmbdata = emxUICore.trim(rmbdata);

	var tableRowId = targetObject.getAttribute('o');
	eval(rmbdata);
	
	if(typeof objMenu != 'undefined' && objMenu != null) {
		objMenu.isRMBMenu = true;
		objMenu.init();
		objMenu.show(event.target, 'right', event.clientX,	event.clientY);
	}
	else {
		document.location.href="../emxLogout.jsp";
	}
}

function expandRichTextContentFromDynaTree(isExpanded) {
    var fixedMaxHeight = 55,
    paddingCss = 13;
    
    var divsToExpand = $("div[id^='contentCell_']");
    for ( var i = 0; i < divsToExpand.length; i++) {
        var jDivToExpand = $(divsToExpand[i]);
	// Don't Expand cell if its Parameter
       //++VMA10 ZUD: IR-705384-3DEXPERIENCER2019x --> includes() changed to indexOf() because includes not working in IE
        if((jDivToExpand[0].offsetParent.id).indexOf("Parameter") != -1)
	     continue;
        var parentRowRight = jDivToExpand.parent().parent().parent();
        var rowIdToSync = jDivToExpand.parent().parent().attr('rmbrow');
        var parentRowLeft = $(editableTable.tblTreeBody.rows
                .namedItem(rowIdToSync));
        
        if (isExpanded) {
            jDivToExpand.parent().css('max-height', fixedMaxHeight ); 

			//comment out for IR-434537
    		//if (parentRowRight.height() > 70) { // 70 = 55 (max height rich text) + 15 of CSS row padding
    		//    parentRowLeft.css('height', 70);
    		//    parentRowRight.css('height', 70);
    		//}
    		//else {
				parentRowRight.attr("height", ""); //IR-434537: clear erroneous row height so that it can collapse as needed.
				parentRowRight.css("height", "");
    		    parentRowLeft.css('height', parentRowRight.height());
    		//}
        }
        else{
    		var sizeToSync = jDivToExpand.height() + 5; // Borders
            
	        // We don't need to do anything, the RichText has a good size
	        if (sizeToSync < fixedMaxHeight)
	            continue;
	        
	        sizeToSync += paddingCss;
	            if(sizeToSync < parentRowRight.height()) {
	            	sizeToSync = parentRowRight.height();
	            }
	
	        parentRowLeft.animate({
	            'height' : '' + sizeToSync // Borders
	        }, {
	            duration : 300
	        });
	        sizeToSync -= paddingCss;
	        
	        jDivToExpand.parent().animate({
	            'max-height' : sizeToSync  

	        }, {
	            duration : 300
	        });
        }        
    }
}

/* Refresh part */
function afterRefreshStructureWithOutSort() {

    $("#requirementTreeExplorer").dynatree("destroy");
    $("#requirementTreeExplorer").empty();
    
    $('#requirementTreeExplorer').append('<div id="loadingDynaTreeGif" style="text-align: center; margin-top: 20px;">' +
    '<img src="../common/images/utilProgressGray.gif" /></div>');
    
    var listToRefresh =  getTopWindow().iframeMapToNotifyRMT;
    if (listToRefresh != undefined) {
        
        emxUICore.deinstrument(emxEditableTable, 'refreshStructureWithOutSort');
        
        // Refresh the main parent
        setTimeout(function() {
            if (listToRefresh[0].editableTable == null || listToRefresh[0].emxEditableTable == null)
                return false;
            
            listToRefresh[0].editableTable.loadData();
            listToRefresh[0].emxEditableTable.refreshStructureWithOutSort();
            emxUICore.instrument(emxEditableTable, 'refreshStructureWithOutSort', null, afterRefreshStructureWithOutSort);
            
            goDynaTree("#requirementTreeExplorer", null);
            $('#loadingDynaTreeGif').remove();
            
        }, TIMEOUT_VALUE * 10);
        
        /* FIXME refresh others jDialog
        for (var i = 1; i < listToRefresh.length; i++) {
            alert(i);
        }
        */
    } else {
        goDynaTree("#requirementTreeExplorer", null);
        $('#loadingDynaTreeGif').remove();
    }
    
}

function reloadTreeAfterAdd() {
    $("#requirementTreeExplorer").dynatree("destroy");
    $("#requirementTreeExplorer").empty();
    goDynaTree("#requirementTreeExplorer", null);
}

/** 
 * 
 * DYNATREE CONSTRUCTION
 * 
 * **/
var nodesAlreadyToggledDynaTree = {};
var nodesVisitedForReloading = {};
var currentNodeDynaTree = null;
function setCurrentNodeDynaTree(dtnode) {
    currentNodeDynaTree = dtnode;
}

function getCurrentNodeDynaTree() {
    return currentNodeDynaTree;
}

// A custom stack used to build the tree, to stock the nodes
function Stack() {
    this.stac = new Array();
    this.pop = function() {
        return this.stac.pop();
    };
    this.push = function(item) {
        this.stac.push(item);
    };
    this.getLast = function() {
        return this.stac[this.stac.length - 1];
    };
    this.getRoot = function() {
        if (this.stac.length >= 1)
            return this.stac[0];
        return null;
    };
    this.get = function(index) {
        return this.stac[index];
    };
}

// We need this part to know when an expand operation is running or note;
var toggleIsRunning = false;
var toggleFromDynaTree = false;



function expandAllDynaTreeRMT() {
    reloadTreeAfterAdd();
}

function collapseAllDynatreeRMT() {
	 // Should never happen
    if (arguments.length < 1)
        return;
    
    var toggledRowId = arguments[0].split('|')[3];
    
	aToggle2RMT(toggledRowId);
}

function aToggle2RMT() {
	refreshQuickCharts();
    toggleIsRunning = true;
    
    // Should never happen
    if (arguments.length < 1)
        return;
    
    var toggledRowID = arguments[0];
    var dtnode = getCurrentNodeDynaTree();

    // From SB
    if (dtnode == null) {
        $(divDynaTree).dynatree("getTree").visit(function(node) {
            if (node.data['objectRowId'] == toggledRowID) {
                dtnode = node;
                toggleFromDynaTree = false;
                return true;
            }
        });
    }
    
    if (nodesAlreadyToggledDynaTree[window.name + '_' + dtnode.data['objectRowId']] != true) {
        nodesAlreadyToggledDynaTree[window.name + '_' + dtnode.data['objectRowId']] = true;
        dtnode.expand(true);
        toggleDynaTree(dtnode);
        dtnode.setLazyNodeStatus(DTNodeStatus_Ok);
        setCurrentNodeDynaTree(null);
        toggleIsRunning = false;
        return;
    }
    
    // From DynaTree
    if (toggleFromDynaTree) {
        setCurrentNodeDynaTree(null);
        toggleIsRunning = false;
        toggleFromDynaTree = false;
        dtnode.setLazyNodeStatus(DTNodeStatus_Ok);
        return;
    }
    
    var mustExpand = true;
    if (dtnode.isExpanded())
        mustExpand = false;
    
    dtnode.expand(mustExpand);
    setCurrentNodeDynaTree(null);
    dtnode.setLazyNodeStatus(DTNodeStatus_Ok);
    toggleIsRunning = false;
}

var bFirstShowDynaTreeSlideContainer = false;

if (sessionStorage.getItem('dynaTree_is_persisted_RMT') == null)
    sessionStorage.setItem('dynaTree_is_persisted_RMT', 'false');


// DynaTree go! 
var divDynaTree = '';
function goDynaTree(divToSetDynaTree, optionsDynaTree) {
    // Initialize Dynatree - see dynaTree doc 
    divDynaTree = divToSetDynaTree;
    nodesAlreadyToggledDynaTree = {};
    
    // If we are in a details view, we don't want to persist the tree
    var isPersisted = true;
    if (window.name.indexOf('detailsDynaFrame_') > 0)
        isPersisted = false;
    
    $(divToSetDynaTree).dynatree(getOptionsForOrderTree(divToSetDynaTree, isPersisted));
    constructFirstTree(oXML);
}

function reloadDynaTreeFromPersistedData() {
    $(divDynaTree)
            .dynatree("getTree")
            .visit(
                    function(node) {
                        if (node.data['objectRowId'] != 0) // We don't want to toggle the root
                            if ($(divDynaTree).dynatree("getTree").persistence.expandedKeyList
                                    .indexOf(node.data['key']) != -1 && 
                                    nodesVisitedForReloading[window.name + '_' + node.data['objectRowId']] != true &&
                                    nodesAlreadyToggledDynaTree[window.name + '_' + node.data['objectRowId']] != true) {
                                nodesVisitedForReloading[window.name + '_' + node.data['objectRowId']] = true;
                                toggle(node.data['objectRowId']);
                            }
                    });
}

// Check on click
var lastCheckedSBXmlNodeForDynaTree = null;
function getOptionsForOrderTree(divToSetDynaTree, isPersisted) {
    return {
        persist: false,// FIXME isPersisted,
        minExpandLevel: 2,
        cookieId: 'cookie_' + divToSetDynaTree,
        onPostInit: function(isReloading, isError) {
            // WARNING - A persisted tree needs to be reload, we have to manage ALL the lazy expands.
            if (isReloading) {
                constructFirstTree(oXML);
                sessionStorage.setItem('dynaTree_is_persisted_RMT', 'true');
                reloadDynaTreeFromPersistedData();
            }
        },
        onActivate: function(node) {
            // Use status functions to find out about the calling context
            var isInitializing = node.tree.isInitializing(); // Tree loading phase
            var isReloading = node.tree.isReloading(); // Loading phase, and reading status from cookies
            var isUserEvent = node.tree.isUserEvent(); // Event was triggered by mouse or keyboard
            $("#echoActive").text(node.data.title);
        },
        imagePath: '../common/',
        debugLevel: 0,
        onLazyRead: function (dtnode) {
            if (!toggleIsRunning) {
                toggleFromDynaTree = true;
                setCurrentNodeDynaTree(dtnode);
                toggle(dtnode.data['objectRowId']);
            }
        },
        onExpand: function (flag, dtnode) {
            if (!toggleIsRunning) {
                toggleFromDynaTree = true;
                setCurrentNodeDynaTree(dtnode);
                toggle(dtnode.data['objectRowId']);
            }
        },
        // CUT / COPY / PASTE
        onClick: function(node, event) {
            // Close menu on click
            if( $(".contextMenu:visible").length > 0 ){
                $(".contextMenu").hide();
            }
            
            for (var row in rowsSelectedForDynaTree) {
                $('#' + row,
                '#mx_divBody').find(':checkbox').first().prop(
                'checked', false).triggerHandler('click');
            }
            
            scrollToSelected(node.data['objectRowId']);
            
            if (lastCheckedSBXmlNodeForDynaTree != null) {
                $('#' + lastCheckedSBXmlNodeForDynaTree.replace(/\,/g, '\\,'), '#mx_divBody').find(':checkbox').first().prop('checked', false).triggerHandler('click');
            }
            
            $('#' + node.data['objectRowId'].replace(/\,/g, '\\,'), '#mx_divTableBody').addClass('ui-selected');
        	rowsSelectedForDynaTree[node.data['objectRowId'].replace(/\,/g, '\\,')] = true;
        	$('#mx_divTableBody').find('tbody').first().selectable('refresh');
        	
            $('#' + node.data['objectRowId'].replace(/\,/g, '\\,'), '#mx_divBody').find(':checkbox').first().prop('checked', true).triggerHandler('click');
            lastCheckedSBXmlNodeForDynaTree = node.data['objectRowId'];
        },
        onDblClick: function(node, event) {
            if (editableTable.mode == "edit") {
                viewMode();
            } else 
                editMode();
            // link('1', node.data['objectId'], node.data['relId'], node.data['parentId'], node.data['objectName']);
        },
        onKeydown : function(node, event) {
            // Eat keyboard events, when a menu is open
            if ($(".contextMenu:visible").length > 0)
                return false;

            switch (event.which) {

            // Open context menu on [Space] key (simulate right
            // click)
            case 32: // [Space]
                $(node.span).trigger("mousedown", {
                    preventDefault : true,
                    button : 2
                }).trigger("mouseup", {
                    preventDefault : true,
                    pageX : node.span.offsetLeft,
                    pageY : node.span.offsetTop,
                    button : 2
                });
                return false;

                // Handle Ctrl-C, -X and -V
            case 67:
                if (event.ctrlKey) { // Ctrl-C
                    copyPaste("copy", node);
                    return false;
                }
                break;
            case 86:
                if (event.ctrlKey) { // Ctrl-V
                    copyPaste("paste", node);
                    return false;
                }
                break;
            case 88:
                if (event.ctrlKey) { // Ctrl-X
                    copyPaste("cut", node);
                    return false;
                }
                break;
            }
        },
        onCreate: function(node, span) {
        	//JX5 if embeddedSB
        if(!isSBEmbedded)
        	emxUICore.addEventHandler(span, "contextmenu", structureExplorerMenu);
        },
        dnd : {
            onDragStart : function(node) {
                logMsg("tree.onDragStart(%o)", node);
				if(node.data.objectType == "PlmParameter" || node.data.objectType == "Test Case"){
					return false;
				}
                return true;
            },
            onDragStop : function(node) {
                logMsg("tree.onDragStop(%o)", node);
            },
            autoExpandMS : 1000,
            preventVoidMoves : true,
            onDragEnter : function(node, sourceNode) {
                logMsg("tree.onDragEnter(%o, %o)", node,
                        sourceNode);
                return true;
            },
            onDragOver : function(node, sourceNode, hitMode) {
                // Prevent dropping a parent below it's own child
                if (node.isDescendantOf(sourceNode)) {
                    return false;
                }
                
                switch (hitMode) {
                    case 'over':
                        return cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-as-child', 
                                true);
                    case 'after':
                        return cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-below',
                                true);
                    case 'before':
                      return cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-above',
                              true);
                }
            },
            onDrop : function(node, sourceNode, hitMode, ui,
                    draggable) {
                
                if (node.isDescendantOf(sourceNode)) {
                    return false;
                }
                
                switch (hitMode) {
                    case 'over':
                        if (cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-as-child',
                                false)) {
                            sourceNode.move(node, hitMode);
                            return true;
                        }
                        return false;
                    case 'after':
                        if (cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-below',
                                false)) {
                            sourceNode.move(node, hitMode);
                            return true;
                        }
                        return false;
                    case 'before':
                        if (cutPasteOperationForDND(node.data['objectRowId'], sourceNode.data['objectRowId'], 'paste-above',
                                false)) {
                            sourceNode.move(node, hitMode);
                            return true;
                        }
                        return false;
                }
            },
            onDragLeave : function(node, sourceNode) {
                logMsg("tree.onDragLeave(%o, %o)", node,
                        sourceNode);
            }
        }
    };
}

// Used for the first construction
var dataXML = null;
function constructFirstTree(oXMLToUse) {
//var start = new Date().getTime();
    var treeDyna = jQuery(divDynaTree).dynatree("getTree");
    treeDyna.enableUpdate(false);
    
    var rootMasterNodeDyna = jQuery(divDynaTree).dynatree("getRoot");
    
    // Get the root directly inside the SB
    var rootSB = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id='0']");
/*
    // Transform a regular OXML to a Dynatree format
    function _adaptXML(father, node) {
    	var newNode = addChildForDynaTree(node, father, true);

        //var children = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id='" + father.getAttribute("id") + "']/child::r");
    	var children = father.childNodes;
        for (var j = 0; j < children.length; j++) {
        	if(children[j].tagName == 'r') {
        	    _adaptXML(children[j], newNode);
            }
        }
    }
    
    // Build the tree
    _adaptXML(rootSB, rootMasterNodeDyna);
*/    
    
    // ++ KIE1 ZUD for Tree Preferences in Struture Browser
	dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=getTreeDisplaySettings");
	
    
	var indent = -1;
	var path = new Array();
	var rows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
	
	path.push(rootMasterNodeDyna);
	for (var ii = 0; ii < rows.length; ii++) {
		var r = rows[ii];

		var level = parseInt(r.getAttribute("level"));
		if(level > indent){
			indent = level;
		}else if(level == indent){
			path.pop();
		}else{
			do{
				path.pop();
				indent--;
			}while(level < indent);
			path.pop();
		}
		var newNode = addChildForDynaTree(path[path.length - 1] , r, true);;
		path.push(newNode);
	}
    
    // Draw the tree
    //treeDyna.redraw();

    treeDyna.enableUpdate(true);
//console.log("total time to render dynatree: " + (new Date().getTime() - start));
}

function addChildForDynaTree(nodeToAttach, rowContent, isLazy) {

    var objectId = rowContent.getAttribute('o');
    var objectRowId = rowContent.getAttribute('id');
    var relId = rowContent.getAttribute('r');
    var parentId = rowContent.getAttribute('p');
    var level = rowContent.getAttribute('level');
    var objectType = rowContent.getAttribute('type');
    
    var isExpanded = (rowContent.getAttribute('expand') == 'true') ? true : false;
    var rows = emxUICore.selectNodes(dataXML, "/mxRoot/rows//r");
    var objectName = "";
    var objectImage = "";
    var toolTipName = "";
    var title		= "";
    var revision		= "";
    var isFolder = false;
    var nameIndex = -1;
    //++ KIE1 ZUD added for Structure Browser and Dyna Tree
    var displayedColumn = rows[0].getAttribute("displayedColumn");
    
    var name_title = displayedColumn.split('_');
    
    if(name_title.length > 1)
    {
    	nameIndex = colMap['columns']['Name'].index - 1;
    	var jRowContent = jQuery(rowContent).children('c').eq(nameIndex);
  	    //    objectImage = jRowContent.attr('i'); //very expensive in IE
  	    objectImage = jRowContent[0].getAttribute('i');
  	    toolTipName = jRowContent.text();
  	    
  	    var titleIndex = colMap['columns']['Title'].index - 1;
  	    var jRowContent_title = jQuery(rowContent).children('c').eq(titleIndex);
	    title = jRowContent_title.text();
	    
	    var revisionIndex = colMap['columns']['Revision'].index - 1;
	    var jRowContent_revision = jQuery(rowContent).children('c').eq(revisionIndex);
  	    revision = jRowContent_revision.text();
    }
    else
    {
	    if(name_title[0] == "Name")
	    {
	    	nameIndex = colMap['columns']['Name'].index - 1;
	    }
	    if(name_title[0] == "Title")
	    {
	    	nameIndex = colMap['columns']['DUP_Title'].index - 1;
	    }
		var jRowContent = jQuery(rowContent).children('c').eq(nameIndex);
	    objectImage = jRowContent[0].getAttribute('i');
	    title = jRowContent.text();
	    toolTipName = jRowContent.text();
	    
	    var revisionIndex = colMap['columns']['Revision'].index - 1;
	    var jRowContent_revision = jQuery(rowContent).children('c').eq(revisionIndex);
  	    revision = jRowContent_revision.text();
    }
  //--KIE1 ZUD added for Structure Browser and Dyna Tree
	for(var i=0; i < rows.length;i++)
	{
		objectType = objectType.trim();
		var objType = objectType.replace(" ","");
		var treeDisplaySetting = rows[i].getAttribute(objType);
		if(treeDisplaySetting == null)
		{
			treeDisplaySetting = rows[i].getAttribute("treeDisplaySettings_Default");
		}
		// HAT ZUD: IR-523564-3DEXPERIENCER2018x FIX
		objectName = getTreeDisplayTabularView(treeDisplaySetting,toolTipName,title,revision);
	}
	 // -- KIE1 ZUD for Tree Preferences in Struture Browser
    // Special handler for a comment
    if (objectType == COMMENT_TYPE) {
        isLazy = false;
    }
    
    if (isExpanded == true) {
    	nodesAlreadyToggledDynaTree[window.name + '_' + objectRowId] = true;
        isLazy = false;
    }
    
	if(objectType != "PlmParameter" && objectType != "Test Case"){
		toolTipName = toolTipName + ' | ' + structureExplorerTooltipSB;
	}
	
    return nodeToAttach.addChild({
        key: objectId,
        isFolder: isFolder,
        objectRowId: objectRowId,
        title: objectName,
        tooltip: toolTipName,
        isLazy: isLazy,
        icon: objectImage,
        expand: isExpanded,
        objectId : objectId,
        relId: relId,
        objectName: objectName,
        objectType: objectType,
        parentId: parentId,
        level: level
      });
}

// HAT ZUD: IR-523564-3DEXPERIENCER2018x FIX
function getTreeDisplayTabularView(treeDisplaySettings, objectName, objectTitle, objectRevision)
{ 
	var itrTreeDisplaySettings = treeDisplaySettings.split("|");
	var isName      = (itrTreeDisplaySettings[0].split("="))[1];
	var isTitle     = (itrTreeDisplaySettings[1].split("="))[1];
	var isRevision  = (itrTreeDisplaySettings[2].split("="))[1];
	var isSeperator = (itrTreeDisplaySettings[3].split("="))[1];
	var titleMaxWidth = (itrTreeDisplaySettings[4].split("="))[1];
	titleMaxWidth = Math.floor(titleMaxWidth);
	
	if(objectTitle.length > titleMaxWidth)
	{
		objectTitle = objectTitle.substring(0, titleMaxWidth);
	}
	
	var seperator = "  ";
	if((isSeperator != "false" || isSeperator != "") && objectTitle.length != 0 && (isName != "false" ||isName != "") && (isTitle != "false" || isTitle != ""))
	{
		seperator = " | ";
	}
	
	if((isName != "false" ||isName != "") && (isTitle != "false" || isTitle != "") && objectTitle.length != 0)
	{
		objectName = objectName + seperator + objectTitle;
	}
	
	if((isName == "false" || isName == "") && (isTitle != "false"||isTitle != "") && objectTitle.length != 0)
	{
		objectName = objectTitle;
	}
	
	if(isRevision != "false" || isRevision != "")
	{
		objectName = objectName + "  " + objectRevision;
	}
	
	if((isName == "false"||isName == "") && (isTitle == "false"||isTitle == "") && (isRevision == "false" || isRevision == "false"))
	{
		objectName = objectTitle + " "+objectRevision;
	}
	return objectName;
}
// -- KIE1 ZUD for Tree Preferences in Struture Browser

// Used to expand a dynaTree node
function toggleDynaTree(dtnode) {
    var rowsToAdd = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id= '" + dtnode.data['objectRowId'] + "']//r[@o]");
    
    for (var i = 0; i < rowsToAdd.length; i++) {
        addChildForDynaTree(dtnode, rowsToAdd[i], true, false);
    }
}

function viewDetailsForDynaTree(dtnode) {
    
    var idDivDyna = dtnode.data['objectId'].replace(/\./g, '');
    var menuToDisplay = 'RMTChapterStructureDisplay';
    if (dtnode.data['objectType'] == REQUIREMENT_TYPE)
        menuToDisplay = 'RMTRequirementStructureDisplay';
    var srcFramDyna = '../requirements/StructureDisplay.jsp?menu=' + menuToDisplay +
    '&objectId=' + dtnode.data['objectId'] + '&relId=' + dtnode.data['relId'] + '&suiteKey=Requirements' + 
    '&StringResourceFileId=emxRequirementsStringResource&SuiteDirectory=requirements&emxSuiteDirectory=requirements';
    
    jQuery('#sideBarSBForRMT').append('<div style="width: 100%; height: 100%;" title="' + dtnode.data['title'] + 
            '" id="viewDetails_' + idDivDyna + '">' +
            '<iframe id="detailsDynaFrame_' + idDivDyna + '" src="' + srcFramDyna + '"></iframe>' +
            '</div>');

    var dialogExtendOptions = {
            "close": true,
            "maximize": true,
            "minimize": true
        };
        
        var dialogOptions = {
            modal: false,
            resizable: false,
            height: 400,
            width: 880
        };
        
        var topWindow = getTopWindow();
        if (topWindow.iframeMapToNotifyRMT == undefined) {
            topWindow.iframeMapToNotifyRMT = [];
            topWindow.iframeMapToNotifyRMT.push(topWindow.sb); // Parent SB
        }
        
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(function(script, textStatus) {
            var dialogDiv = jQuery('#viewDetails_' + idDivDyna);
            dialogDiv.dialog(dialogOptions).dialogExtend(dialogExtendOptions);
            getTopWindow().iframeMapToNotifyRMT.push($('#detailsDynaFrame_' + idDivDyna, dialogDiv));
        });
}

/*****************************************************************************/
/*****************************************************************************/
/**                END SIMPLE EXPLORER - STRUCTURE BROWSER                  **/
/*****************************************************************************/
/*****************************************************************************/
