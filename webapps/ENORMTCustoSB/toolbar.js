//=================================================================
// JavaScript toolbar.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
//quickreview HAT1 ZUD      07:12:16    IR-484381-3DEXPERIENCER2018x: R419-STP: On Requirement specification list page Expand All command is not expanding objects.


if(localStorage['debug.AMD']) {
	var _RMTToolbar_js = _RMTToolbar_js || 0;
	_RMTToolbar_js++;
	console.info("AMD: ENORMTCustoSB/toolbar.js loading " + _RMTToolbar_js + " times.");
}

define('DS/ENORMTCustoSB/toolbar', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/toolbar.js dependency loaded.");
	}
	
	emxUICore.instrument(window, 'rebuildView', beforeRebuildView, fixMassUpdate);
	emxUICore.instrument(emxUICore, 'getData', beforeGetData, null);
	emxUICore.instrument(window, "getJsonForMenu", preGetJsonForMenu, null);

	emxUICore.instrument(window, 'isComponentPage', null, isComponentPageRMT);

	emxUICore.instrument(window, 'emxTableColumnLinkClick', beforeEmxTableColumnLinkClick, null);

	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/toolbar.js finish.");
	}
	
	return {};
});
/* Contains code for the SB */
{
    // rename "Edit" menu
    var obj;
    for (var i = 0; i < objMainToolbar.items.length; i++) {
        if (objMainToolbar.items[i].dynamicName == "AEFSBEditActions") {
            obj = objMainToolbar.items[i];
            break;
        }
    }
    if (obj) {
        obj.text = SBEditButtonText;
    }

    // rename "Enable Edit" command
    var obj;
    for (var i = 0; i < objMainToolbar.items.length; i++) {
        if (objMainToolbar.items[i].url && objMainToolbar.items[i].url.indexOf("javascript:editMode(") > -1) {
            obj = objMainToolbar.items[i];
            break;
        }
    }
    if (obj) {
        obj.text = SBEnableEditText;
        emxUIConstants.STR_ENABLE_EDIT = obj.text;
        emxUIConstants.STR_DISABLE_EDIT = SBEnableViewText;
    }

}


/* fix the RMB on effectivity column */
function beforeRebuildView() {
    $("#mx_divTableHead img[title='Allocation Status']").attr("title", strAllocationStatus);
    $("#mx_divTableHead img[title='Priority']").attr("title", strPriority);
    $("#mx_divTableHead img[title='Difficulty']").attr("title", strDifficulty);
    $("#mx_divTableHead img[title='LockStatus']").attr("title", strLockState);
    $("#mx_divTableHead img[title='Engineering Change']").attr("title", strActiveEC);
    $("#mx_divTableHead img[title='Status']").attr("title", strStatus);
    $("#mx_divTableHead img[title='Covered']").attr("title", strCovered);
    $("#mx_divTableHead img[title='Refining']").attr("title", strRefining);
    $("#mx_divTableHead img[title='Change Order']").attr("title", strActiveCO); // KIE1 added for Change Order

    var cffColumn = emxUICore.selectSingleNode(oXML,
        "/mxRoot/columns/column[@name = 'StructureEffectivityExpression']");
    if (!cffColumn) return;

    var rmbMenu = emxUICore.selectSingleNode(cffColumn, "settings/setting[@name = 'RMB Menu']/text()");
    if (rmbMenu) return;

    var menu = emxUICore.selectSingleNode(oXML,
        "/mxRoot/columns/column[@name = 'Name']/settings/setting[@name = 'RMB Menu']/text()");
    if (!menu) return;

    rmbMenu = oXML.createElement("setting");
    rmbMenu.setAttribute("name", "RMB Menu");
    emxUICore.setText(rmbMenu, menu.nodeValue);

    cffColumn.firstChild.appendChild(rmbMenu);
}

/* fix for IR-479777-3DEXPERIENCER2017x */
function fixMassUpdate() {
    $("#divMassUpdate option[value='AllocationStatus']").html(strAllocationStatus)
    $("#divMassUpdate option[value='Priority']").html(strPriority)
    $("#divMassUpdate option[value='Difficulty']").html(strDifficulty)
}

/* prepend custom menu items, remove expandAll command */
function beforeGetData(url) {

    if (url.indexOf("emxUIDynamicMenu.jsp?") < 0 || !oXML) return;

    if (url.indexOf("frmRMB=true") < 0) {
        if (emxEditableTable.isRichTextEditor && url.indexOf("emxUIDynamicMenu.jsp?") == 0) { //custom table view on SCE
            url = "../common/" + url;
            var data = beforeGetData._original.apply(this, [url]);
            return [data];
        } else {
            return;
        }
    }

    if (!emxEditableTable.isRichTextEditor && getRequestSetting('isIndentedView') != 'true') return;

    var start = url.indexOf("RMBMenu=");
    if (start < 0) return;
    var end = url.indexOf("&", start);
    if (end < 0) end = url.length;
    var originalMenu = url.substring(start + 8, end);
    if (originalMenu != "") {
        if (isSBEmbedded) {
            url = url.substring(0, start) + "RMBMenu=RMTSCETreeRMBDynamic" + url.substring(end) +
                "&appendRMBMenu=RMTBlank";
        }
        url = url.substring(0, start) + "RMBMenu=RMTSCETreeRMBDynamic" + url.substring(end) +
            "&appendRMBMenu=" + originalMenu;
    }

    var data = beforeGetData._original.apply(this, [url]);

    data += "try{" +
        "var lastItem = objMenu.items[objMenu.items.length - 1]; if(lastItem.dynamicName == 'AEFFreezePaneExpandLevelFilter') objMenu.items.pop();" +
        "lastItem = objMenu.items[objMenu.items.length - 1]; if(lastItem.emxClassName == 'emxUIToolbarMenuSeparator') objMenu.items.pop();" +
        "}catch(e){}";

    return [data];
}

beforeGetData._original = emxUICore.getData;

function customizeToolBarForRMT() {
    var bViewMode = true;
    if (editableTable.mode == "edit")
        bViewMode = false;

    var toolbarItems = $(toolbars).first().attr('items');
    for (var i = 0; i < toolbarItems.length; i++) {
        var identifier = toolbarItems[i].id;
        if (identifier == undefined || identifier == '')
            identifier = toolbarItems[i].dynamicName;

        switch (identifier) {
            /*        case 'AEFLifecycleMassPromote':
                        if (toolbarItems[i].element != null) {
                            toolbarItems[i].element.innerHTML = '<img src="../common/images/iconActionPromote.gif">' +
                                labelPromoteToolBar;
                        }

                        break;
                    case 'AEFLifecycleMassDemote':
                        if (toolbarItems[i].element != null) {
                            toolbarItems[i].element.innerHTML = '<img src="../common/images/iconActionDemote.gif">' +
                                labelDemoteToolBar;
                        }

                        break;
                    case 'RMTSearchWithinContext':
                        if (toolbarItems[i].element != null) {

                            toolbarItems[i].element.innerHTML = '<img src="../common/images/iconActionSearch.gif">';
                        }

                        break;*/
            case 'AEFSBEditActions':
                $(toolbarItems[i].element).hide();
                break;
            case 'AEFSBCreateNewMenu':
                $(toolbarItems[i].buttonElement).hide();
                $(toolbarItems[i].menuElement).hide();
                break;
            case 'AEFSBRemoveRow':
                $(toolbarItems[i].element).hide();
                break;
            case "RMTCovering":
                if (isSBEmbedded)
                    $(toolbarItems[i].element).hide();
                break;
            case "RMTRefinedInto":
                if (isSBEmbedded)
                    $(toolbarItems[i].element).hide();
                break;
        }
    }

    // Show / Hide Structure Explorer
    /*var imgSrcPanel = '../common/images/iconActionOpenPanel.gif';
    var titlePanel = structureExplorerOpenSB;
    if (sessionStorage.getItem('show_dynaTree_RMT') == 'true') {
        imgSrcPanel = '../common/images/iconActionClosePanel.gif';
        titlePanel = structureExplorerCloseSB;
    }

    var buttonCloseOrHideSE = $('<td>', {
        itemid: 'structureExplorerButtonRMT',
        title: titlePanel,
        nowrap: '',
        class: 'icon-button'
    }).append('<img src="' + imgSrcPanel + '">');

    buttonCloseOrHideSE.mouseover(function() {
        emxUICore.addClass(this, "button-hover");
    }).mouseout(function() {
        emxUICore.removeClass(this, "button-hover");
    }).click(function() {
        emxUICore.removeClass(this, "button-hover");
        hideOrShowDynaTree();

        var imagePanel = $(this).children(":first");
        if (imagePanel.attr('src').indexOf('iconActionClosePanel') > 0) {
            $(this).attr('title', structureExplorerOpenSB);
            imagePanel.attr('src', '../common/images/iconActionOpenPanel.gif');
        } else {
            $(this).attr('title', structureExplorerCloseSB);
            imagePanel.attr('src', '../common/images/iconActionClosePanel.gif');
        }
    });

    $('#divToolbarContainer').find('.toolbar').first().find('td').first().before(buttonCloseOrHideSE);*/


    // Expand / collapse RichText
    var imgSrcExpand = '../requirements/images/iconReqCmdExpandRichText.png';

    var buttonExpandRichText = $('<td>', {
        itemid: 'expandRichTextButtonRMT',
        title: structureExplorerExpandSB,
        nowrap: '',
        class: 'icon-button-32x32'
    }).append('<img src="' + imgSrcExpand + '">');

    buttonExpandRichText.mouseover(function() {
        emxUICore.addClass(this, "button-hover");
    }).mouseout(function() {
        emxUICore.removeClass(this, "button-hover");
    }).click(function() {
        emxUICore.removeClass(this, "button-hover");

        if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == null)
            sessionStorage.setItem('structureBrowser_is_expanded_RT', 'false');


        // We have to expand
        if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == 'false') {
            expandRichTextContentFromDynaTree(false);
            sessionStorage.setItem('structureBrowser_is_expanded_RT', 'true');
        } else {
            expandRichTextContentFromDynaTree(true);
            sessionStorage.setItem('structureBrowser_is_expanded_RT', 'false');
        }
    });

    $('#divToolbarContainer').find('.toolbar').first().find('td').last().after(buttonExpandRichText);

    var buttonDashboard = $('<td>', {
        itemid: 'dashBoardRMT',
        title: strQuickCharts,
        nowrap: '',
        class: 'icon-button-32x32'
    }).append('<img src="../requirements/images/iconReqCmdQuickCharts.png">');

    buttonDashboard.mouseover(function() {
        emxUICore.addClass(this, "button-hover");
    }).mouseout(function() {
        emxUICore.removeClass(this, "button-hover");
    }).click(function() {
    	var reqTypes = childrenReqTypes.replace(/\[|\]/g,"").split(", ");
    	reqTypes.push('Requirement');
    	var reqObject = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+createOXmlReqTypes(reqTypes)+"]");
        if(reqObject!=null&&reqObject.length>0){
        	emxUICore.removeClass(this, "button-hover");
            createDashboardPanel('../requirements/emxRMTDashboard.jsp?objectId='+objectId);
        }else{
        	//display a popup error message
        	var href = '../requirements/emxRMTDashboard.jsp?requestType=errorMessage';
        	var result = null;
        	$.ajax({
        		  url: href,
        		  cache: false,
        		  async: false,
        		  dataType: 'text',
        		  success: function(data, status, hxr){
        		    result =  data;
        		    alert(result);
        		  },
        		  error: function(jqXHR, textStatus, errorThrown) {
        			console.log(textStatus);
        			result = null;
        		  }
        	}); 
        }
    	
    });
    if (!isSBEmbedded)
        $('#divToolbarContainer').find('.toolbar').first().find('td').last().after(buttonDashboard);
}


var contentButtonsToolBarRMT = {};
contentButtonsToolBarRMT['AEFSBEditActions'] = null;
contentButtonsToolBarRMT['AEFSBCreateNewMenu'] = null;
contentButtonsToolBarRMT['AEFSBRemoveRow'] = null;

function customizeMassUpdateToolBarForRMT() {
    var bViewMode = true;
    if (editableTable.mode == "edit")
        bViewMode = false;
    
    if(bViewMode) {
    	return;
    }
    
    var toolbarItems = $(toolbars).first().attr('items');
    for (var i = 0; i < toolbarItems.length; i++) {

        var identifier = toolbarItems[i].id;
        if (identifier == undefined || identifier == '')
            identifier = toolbarItems[i].dynamicName;

        var toolbarToCustomize = $('#divMassUpdate').find('.toolbar').first();
        var tdsToolbar = toolbarToCustomize.find('td');
        $(toolbarToCustomize).parent().css("height", "36px");
        switch (identifier) {
            case 'AEFSBEditActions':
                if (!bViewMode) {
                	if(isIE){
                        if (contentButtonsToolBarRMT['AEFSBEditActions'] == null)
                            contentButtonsToolBarRMT['AEFSBEditActions'] = toolbarItems[i].element.innerHTML;
                        else {
                            toolbarItems[i].element.innerHTML = contentButtonsToolBarRMT['AEFSBEditActions'];
                        }
                	}

                    tdsToolbar.first().before(toolbarItems[i].element);
                    $(toolbarItems[i].element).css("display", "table-cell")
                    $(toolbarItems[i].element).show();
                }
                break;
            case 'AEFSBCreateNewMenu':
                if (!bViewMode) {
                	if(isIE){
                        if (contentButtonsToolBarRMT['AEFSBCreateNewMenu'] == null) {
                            contentButtonsToolBarRMT['AEFSBCreateNewMenu'] = 'true';
                            contentButtonsToolBarRMT['AEFSBCreateNewMenub'] = toolbarItems[i].buttonElement.innerHTML;
                            contentButtonsToolBarRMT['AEFSBCreateNewMenum'] = toolbarItems[i].menuElement.innerHTML;
                        } else {
                            toolbarItems[i].buttonElement.innerHTML = contentButtonsToolBarRMT[
                                'AEFSBCreateNewMenub'];
                            toolbarItems[i].menuElement.innerHTML = contentButtonsToolBarRMT[
                                'AEFSBCreateNewMenum'];
                        }
                	}

                    tdsToolbar.first().after(toolbarItems[i].menuElement);
                    tdsToolbar.first().after(toolbarItems[i].buttonElement);
                    $(toolbarItems[i].buttonElement).css("position", "relative").css("min-height", "0px");
                    $(toolbarItems[i].menuElement).css("position", "relative").css("min-height", "0px");
                    $(toolbarItems[i].buttonElement).show();
                    $(toolbarItems[i].menuElement).show();
                }
                break;
            case 'AEFSBRemoveRow':
                if (!bViewMode) {
                	if(isIE){
                        if (contentButtonsToolBarRMT['AEFSBRemoveRow'] == null)
                            contentButtonsToolBarRMT['AEFSBRemoveRow'] = toolbarItems[i].element.innerHTML;
                        else {
                            toolbarItems[i].element.innerHTML = contentButtonsToolBarRMT['AEFSBRemoveRow'];
                        }
                	}

                    toolbarToCustomize.find('td:nth-child(3)').after(toolbarItems[i].element);
                    $(toolbarItems[i].element).css("position", "relative").css("min-height", "0px");
                    $(toolbarItems[i].element).show();
                }
                break;
        }
    }
}

var customizedToolbarLoaded = 0;

function doCustomizeToolBarForRMT() {
	if(this.name == 'main') {
		customizeToolBarForRMT();
	}
}


function preGetJsonForMenu(menu, menuJson) {
    var isCustomTableMenu = false;
    var isFirstFilterCommand = true;
    for (var i = 0; i < menu.items.length; i++) {
        var url = menu.items[i].url;
        if (!url)
            continue;
        var checkmark = false;
        if (emxEditableTable.isRichTextEditor) {
            checkmark = url.indexOf("javascript:showSimpleView()") >= 0 && simpleView || url.indexOf(
                    "javascript:indentTo('" + param_indent + "')") >= 0 || url.indexOf(selectedProgram.value) >=
                0;
        } else {
            if (url.indexOf("../common/emxCustomizeTablePopup.jsp") >= 0) {
                isCustomTableMenu = true;
            }

            if (isCustomTableMenu) {
                var singleRoot = emxUICore.selectSingleNode(oXML,
                    "/mxRoot/rows//r[@id ='0']");
                if (singleRoot) {
                    checkmark = url.indexOf(getParameter("selectedProgram")) >= 0 && url.indexOf(
                        "javascript:filterPage(") >= 0;
                } else {
                    if (isFirstFilterCommand && url.indexOf("javascript:filterPage(") >= 0) {
                        checkmark = true;
                        isFirstFilterCommand = false;
                    }
                }
            }
        }
        if (checkmark) {
            menu.items[i].icon = "../common/images/iconActionChecked.gif";
        }
    }
}

// KIE1 ZUD modified for Issue with ExpandAll command
function SCEExpandAll(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];

        var m1Node = getM1Node(objectId, relId);
        expandTreeNodeFor(m1Node);
    } else {
        var rowId = items[3];
        
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
        "']//r[@display = 'none']");
    for (var i = 0; i < nRows.length; i++) {
        nRows[i].setAttribute("display", "block");
    }

    var nRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
    nRow.setAttribute("display", "block");
    rebuildView();
        emxEditableTable.expand([rowId], "All");
    }
}

function SCECollapseAll(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];

        var m1Node = getM1Node(objectId, relId);
        collapseTreeNodeFor(m1Node);
    } else {
        var rowId = items[3];
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
            "']//r[@display = 'block']");
        for (var i = 0; i < nRows.length; i++) {
            nRows[i].setAttribute("display", "none");
        }

        var nRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
        nRow.setAttribute("display", "none");
        rebuildView();
    }
}

function SCESelectAllChildren(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];

        var m1Node = getM1Node(objectId, relId);
        checkM1NodeChildren(m1Node, true);
    } else {
        var rowId = items[3];
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
            "']/r[not(@rg) and (not(@disableSelection) or @disableSelection != 'true')]");
        var objCheckbox = {
            checked: true
        };
        doFreezePaneChecks(objCheckbox, nRows, 0, nRows.length);
        rebuildView();
    }
}

function SCEUnselectAllChildren(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];

        var m1Node = getM1Node(objectId, relId);
        checkM1NodeChildren(m1Node, false);
    } else {
        var rowId = items[3];
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
            "']/r[not(@rg) and (not(@disableSelection) or @disableSelection != 'true')]");
        var objCheckbox = {
            checked: false
        };
        doFreezePaneChecks(objCheckbox, nRows, 0, nRows.length);
        rebuildView();
    }
}

function SCESelectAllDescendants(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];
        var m1Node = getM1Node(objectId, relId);
        checkM1NodeDescendants(m1Node, true);
    } else {
        var rowId = items[3];
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
            "']//r[not(@rg) and (not(@disableSelection) or @disableSelection != 'true')]");
        var objCheckbox = {
            checked: true
        };
        doFreezePaneChecks(objCheckbox, nRows, 0, nRows.length);
        rebuildView();
    }
}

function SCEUnselectAllDescendants(tableRowId) {
    var items = tableRowId.split('|');
    if (emxEditableTable.isRichTextEditor) {
        var objectId = items[1];
        var relId = items[0];
        var m1Node = getM1Node(objectId, relId);
        checkM1NodeDescendants(m1Node, false);
    } else {
        var rowId = items[3];
        var nRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@id = '" + rowId +
            "']//r[not(@rg) and (not(@disableSelection) or @disableSelection != 'true')]");
        var objCheckbox = {
            checked: false
        };
        doFreezePaneChecks(objCheckbox, nRows, 0, nRows.length);
        rebuildView();
    }
}

    /*
     * IR-216193V6R2014: treat PopupLauncher.jsp as a component page for popups
     */

function isComponentPageRMT(strURL, originalResult) {
    return originalResult || strURL.indexOf("PopupLauncher.jsp") > -1 || strURL.indexOf(
        "StructureDisplay.jsp") > -1;
}

//on dashboard, force table link to target content frame
function beforeEmxTableColumnLinkClick(href, width, height, modal, target, onselaction, colValue, indentedTableBln,strPopupSize)
{
	if(getTopWindow().isfromIFWE){
		if(target == 'popup'){
			target = 'content';
		}
		emxTableColumnLinkClick._original.apply(this, [href, width, height, modal, target, onselaction, colValue, indentedTableBln,strPopupSize]);
		return false;
	}
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/toolbar.js global finish.");
}
