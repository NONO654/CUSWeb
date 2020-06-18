//=================================================================
// JavaScript RichTextEditorStructure.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview T25 	DJH 	10:31:13 	Correction of IR-236909V6R2014x.Added function checkBadChars().
//quickreview T25 	DJH 	11:19:13 	Correction of IR-269604V6R2014x.Added message variable. 
//quickreview KIE1 	ZUD 	02:24:15  	HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
//quickreview JX5 	T94 	03:18:15	Adapt to new level of jquery-ui and jquery-dialogextend for TMC project
//quickreview JX5   T94 	04:10:15 	Remove debugger statements and correct dialog events
//quickreview QYG           02:02:16    IR-422207-3DEXPERIENCER2015x : Issue with edit mode
//quickreview QYG           05:03:16    javascript refactoring, split out
//quickreview ZUD           08:03:17    Commenting Buggy code
//quickreview KIE1  ZUD     07:11:18    IR-552381-3DEXPERIENCER2019x R420-STP: After double click on Traceability report, non-working Save and Cancel option are visible
//
//

if(localStorage['debug.AMD']) {
	var _RMTSBCusto_js = _RMTSBCusto_js || 0;
	_RMTSBCusto_js++;
	console.info("AMD: ENORMTCustoSB/RichTextEditorStructure.js loading " + _RMTSBCusto_js + " times.");
}

define('DS/ENORMTCustoSB/RichTextEditorStructure', [
       'DS/RichEditorCusto/Util', 
       'DS/RichEditorCusto/RichEditorCusto', 
       'DS/ENORMTCustoSB/InlineDataEntry',
       'css!DS/ENORMTCustoSB/assets/css/Structure.css'
       ], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/RichTextEditorStructure.js dependency loaded");
	}
	
	emxUICore.instrument(window, 'applyEdits2', null, afterApplyEdits);
	emxUICore.instrument(window.editableTable, 'attachOrDetachEventHandlers', null,
	    attachRMTEventHandlers);
	emxUICore.instrument(window, 'getCell', ImgGetCell, null);
	emxUICore.instrument(window, 'getTDValueForSelectList', getTDValueForSelectListForRMT, null);

	emxUICore.instrument(window, 'viewMode', handleQuickChartPanel, null);
	emxUICore.instrument(window, 'editMode', handleQuickChartPanel, null);

	emxUICore.instrument(getTopWindow(), 'showSlideInDialog', closeQuickChartPanel, null);
	$(window).unload(function(){
		emxUICore.deinstrument(getTopWindow(), 'showSlideInDialog');	
	});

	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/RichTextEditorStructure.js finish");
	}
	return {};
});

function ChangeNameIfNeeded(){
	// Zud Commenting buggy code
	//var nameIndex = colMap['columns']['Name'].index-1;
    var revIndex = colMap['columns']['Revision'].index-1;
    var rootObject = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@id='0']")[0];
    var colMapSize = colMap.columns.length;
    var chilNodesSize  = rootObject.childNodes.length;
    var offset = chilNodesSize - colMapSize;
    
    //JX5 start IR-368345-3DEXPERIENCER2016x 
    //Use jquery to find the root node to avoid oXML index modification impacts
    var rootObjectNode = $(rootObject).find('c[FPRootCol=true]')[0];
    var rootObjectName = rootObjectNode.textContent;
    if(rootObjectName == null){
    	rootObjectName = rootObjectNode.text;
    }
    //JX5 end IR-368345-3DEXPERIENCER2016x 
    
    /*var rootObjectName = rootObject.childNodes[nameIndex+offset].textContent;
    if(rootObjectName==null){
    	rootObjectName = rootObject.childNodes[nameIndex+offset].text;
    }*/
    
    // For CATIA IR-367719-3DEXPERIENCER2016x
    var headerContent = $("#divExtendedHeaderContent", getTopWindow().document);
    if (headerContent.length == 0) {
    	return;
    }
    
    var headerName = headerContent.find(".extendedHeader.name")[0].innerText;
    if(rootObjectName!=headerName){
    	var rootObjectRev = rootObject.childNodes[revIndex+offset].textContent;
        if(rootObjectRev==null){
        	rootObjectRev = rootObject.childNodes[revIndex+offset].text;
        }
    	$("#catMenu",getTopWindow().document).find("li")[0].childNodes[0].textContent = rootObjectName+ " " + rootObjectRev;
    	$("#catMenu",getTopWindow().document).find("li")[0].childNodes[0].text = rootObjectName+ " " + rootObjectRev;
    	$("#divExtendedHeaderContent",getTopWindow().document).find(".extendedHeader.name")[0].innerText = rootObjectName;
    }
}

//ck
//Requirement structure view save
/** Check is an error occurred during the applyEdit.
* Returns: true if everything is OK, false otherwise. **/
function checkErrorAfterApplyEdit() {

  // If an issue happened, the postDataXML.loadXML("<mxRoot/>"); is never called.
  // Thus, we can know if applyEdit succeed.
   var ua = window.navigator.userAgent;
   var edge = ua.indexOf('Edge/');
   var isEdge = false;
   if (edge > 0) {
		isEdge = true;
   }
   
	if (!isEdge && postDataXML.xml.indexOf('<mxRoot/>') >= 0)
		return true;
	else if(isEdge && postDataXML.xml.indexOf('<mxRoot />') >= 0)
		return true;
	else
		return false;
}


function afterApplyEdits() {
	var QuickChartSlideIn = $('#dashBoardSlideInFrame');
	if(QuickChartSlideIn.length>0){
		//the dashboard is displayed
		refreshQuickCharts();
	}
	
    if (!checkErrorAfterApplyEdit()) return;
    turnOnProgress(true);
    if (!validateNewRows()) {
        turnOffProgress();
        return;
    }
    
  //Check data to update (after cut/copy/paste)
    var dataToUpdate = null;
    if(!isIE)
    	dataToUpdate = emxUICore.selectNodes(oXML, '/mxRoot/rows//r[@relType = "undefined" or @titleValue != ""]');
    else
    	dataToUpdate = emxUICore.selectNodes(oXML, '/mxRoot/rows//r[@relType = "" or @titleValue != ""]');
    
	for(var i=0; i < dataToUpdate.length ; i++){
		var children = dataToUpdate[i];
		var curRowId = children.getAttribute('id');
		if(curRowId)
			rmtModifiedRowIds.push(curRowId);
		
		// ++KIE1 added for IR-638772-3DEXPERIENCER2019x: to modify the parent row
		var parent = dataToUpdate[i].parentNode;
		var parentRowId = parent.getAttribute('id');
		if(parentRowId)
			rmtModifiedRowIds.push(parentRowId);
		// --KIE1
	}
		
    // Rearranging of RMT object in structure view
    setTimeout(function() {
    	//Update modified rows
    	emxEditableTable.refreshRowByRowId(rmtModifiedRowIds,true);
    	//rebuild table view
    	rebuildView();
    	//reload structure explorer
    	reloadTreeAfterAdd();//FIXME update only modified rows
        turnOffProgress();
    }, TIMEOUT_VALUE * 2);

    // To leave the editMode for viewMode after saving
    setTimeout(function() {
        if (checkErrorAfterApplyEdit()) {
            // If we have a new RCU with the XHTML content
            syncRCOContent();

            viewMode();
        }
    }, TIMEOUT_VALUE * 4);
	// Name is not editable
    //ChangeNameIfNeeded();
}


var RMTEventHandlersAttached = false;
function attachRMTEventHandlers(attach) {
   if(!attach) {
	   return;
   }
    window.onkeydown = function(e) {
        e = e || window.event;
        checkKeyPressEvent(e);
    };

    if(!RMTEventHandlersAttached) {
        // Dbl click to edit
        jQuery("#mx_divBody").dblclick(function(e) {
        	e = e || window.event;
        	//	KIE1 ZUD IR-609281-3DEXPERIENCER2018x
        	var link = this.parentNode.action;
            if(link.contains("editLink=true"))
            {
            	ImgEditAndGetCell(e);	
            }                      
        });

        jQuery("#mx_divBody").ready(function(e) {
            e = e || window.event;
            if(this.URL.contains("traceabilityreport=true")){
    	        if($('#divPageFootButtons').length>0){
    	        	var obj = $( "#divPageFootButtons" ).find("tr");
    	        	//check if the 
    	        	if(obj[0].innerHTML.length == 0){
    	    	        var buttons= "<td id=\"nexticon\">";
    	    	        buttons+= "<a href='javascript:callSubmitURL(\"../requirements/TraceabilityReportCoverage.jsp?traceabilityreport=true&options=reportCount:1\");'><img src=\"images/buttonNextPage.gif\" border=\"0\" title=\""+SBNextButtonText+"\"></a>";
    	    	        buttons+= "</td>";
    	    	        buttons+="<td>";
    	    	        buttons+="<a class=\"button\" href='javascript:callSubmitURL(\"../requirements/TraceabilityReportCoverage.jsp?traceabilityreport=true&options=reportCount:1\");'>"+SBNextButtonText+"</a>";
    	    	        buttons+="</td>";
    	    	        obj.append(jQuery(buttons));
    	        	}
    	        }
            }
        });
        
        
        RMTEventHandlersAttached = true;
    }
    
    var divForDnD = null;
    if (bShowTreeExplorerAndDecorators) {
        // Dnd SB
        divForDnD = DnDForSBRMT();
    }
    if (bClickToSelect) {
        selectableForSBRMT(divForDnD);
    }

    loadStructureRichTextData();
    mouseoverForSBRMT(); //tooltip for rich text div
}

// Function is invoked from SpecificationStructureUtil.jsp.If user select the
// object from SB RMB
function autoCheckRow(emxTableRowId) {
    if (emxEditableTable.isRichTextEditor) { // SCE
        for (var i = currentSelectedM1Nodes.length - 1; i >= 0; i--) {

            checkNode(currentSelectedM1Nodes[i], false);
        }
        var items = emxTableRowId.split('|');
        var oid = items[1];
        var rid = items[0];
        var m1Node = getM1Node(oid, rid);
        checkNode(m1Node, true);
    } else {
        var objForm = document.forms["emxTableForm"];
        for (var i = 0; i < objForm.elements.length; i++) {
            var objElement = objForm.elements[i];
            if (objElement.type == "checkbox" || objElement.type == "radio") {
                if (objElement.value == emxTableRowId) {
                    objElement.checked = true;
                } else {
                    objElement.checked = false;
                }
                doFreezePaneCheckboxClick(objElement, null);
            }
        }
    }

}

/**
 * Illegal characters and restricted bad characters /* function
 * chkNameBadChar(fieldname) { if(!fieldname) { fieldname=this; } var val =
 * fieldname; var charArray = new Array(20); charArray = "<%=EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars")%>";
 *
 * var charUsed = checkStringForChars(val,charArray,false); if(val.length>0 &&
 * charUsed.length >=1) { alert("<%=EnoviaResourceBundle.getProperty(context,
 * "emxRequirementsStringResource", context.getLocale(),
 * "emxRequirements.Alert.InvalidChars")%>" + "\n" + charArray ); return false; }
 * return true; }
 *  /* Method called from chkNameBadChar.
 */

function checkStringForChars(strText, arrBadChars, blnReturnAll) {
        var strBadChars = "";
        for (var i = 0; i < arrBadChars.length; i++) {
            if (strText.indexOf(arrBadChars[i]) > -1) {
                strBadChars += arrBadChars[i] + " ";
            }
        }
        if (strBadChars.length > 0) {
            if (blnReturnAll) {
                return arrBadChars.join(" ");
            } else {
                return strBadChars;
            }
        } else {
            return "";
        }

    }
/* not being used
// START LX6 : UI enhancement
function getValueForColumnRMT(colName, mxLink, originalresult) {
    var ReturnedValue;
    if (colName = "Name") {
        ReturnedValue = originalResult.split("|")[1];
    } else {
        ReturnedValue = originalResult;
    }
    return ReturnedValue;
}

// get value of the TD

function getTDValueRMT(objTD, value, originalResult) {
    var columnName = colMap.columns[objTD.cellIndex].getAttribute("name");
    var ReturnedValue;
    if (columnName == "Name") {
        ReturnedValue = originalResult.split("|")[1];
    } else {
        ReturnedValue = originalResult;
    }
    return ReturnedValue;
}
*/
function getTDValueForSelectListForRMT(objTD){
	var value =  $(":first-child", objTD).length ? $(":first-child", objTD).get(0).nodeValue:"";
	var array = [value];
	return array;
}

function ImgGetCell() {
	var event = arguments[0];
	try {
        if (editableTable.mode != "edit") {
            var column = event.target.parentElement.getAttribute("position");
            var arrowCell = false;
            if (column != null && colMap.columns[parseInt(column) - 1].name == "AllocationStatus") {
                arrowCell = true;
            }
            if (arrowCell == true) {
                var RootId = event.target.parentElement.getAttribute("rmbid");
                showModalDialog(
                    '../common/emxIndentedTable.jsp?expandProgram=emxTraceabilityReport:getTraceabilityFolderData&expandMultiLevelsJPO=true&table=RMTFullTraceabilityTable&header=emxRequirements.FullTraceability.Header&sortColumnName=none&HelpMarker=emxhelpfulltraceability&toolbar=RMTFullTraceabilityToolbar&expandLevelFilter=false&suiteKey=Requirements&StringResourceFileId=emxRequirementsStringResource&SuiteDirectory=requirements&emxSuiteDirectory=requirements&objectId=' +
                    RootId, '875', '550', 'false', 'popup');
            }
            return;
        }
    } catch (exp) {
        // NOP
    }
}

function findParentElementselected(object) {
    if (object != null) {
        if (object.id != "treeBodyTable" && object.id != "bodyTable") {
            id = findParentElementselected(object.parentElement);
        } else {
            id = object.id;
        }
    } else {
        id = null;
    }
    return id;
}

function findRowIndex(targetNode) {
    var RowIndex;
    if (targetNode.rowIndex == undefined) {
        RowIndex = findRowIndex(targetNode.parentNode);
    } else {
        RowIndex = targetNode.rowIndex;
    }
    return RowIndex;
}

function findCellIndex(targetNode) {
    var cellIndex;
    if (targetNode.cellIndex == undefined) {
        cellIndex = findCellIndex(targetNode.parentNode);
    } else {
        cellIndex = targetNode.cellIndex;
    }
    return cellIndex;
}

function ImgEditAndGetCell(event) {
    if (editableTable.mode != "edit") {
        event = emxUICore.getEvent();
        var targetNode = event.target;
        var RowIndex = findRowIndex(targetNode);
        var ColIndex = findCellIndex(targetNode);

        // Set the current column position
        currentColumnPosition = ColIndex;
        currentCell.tableName = findParentElementselected(targetNode);
        editMode();
        getCell(RowIndex, ColIndex);
    }
}

function checkKeyPressEvent(event) {
    if (editableTable.mode == "edit" && event.which == 27) {
        viewMode();
        if (editableTable.mode == "view") {
            emxEditableTable.refreshStructureWithOutSort();
        }
    }
}


function handleQuickChartPanel(){
	closePanel();
	loadRichTextData();
}



function isCtrlKeyDown(event) {
    return (event.ctrlKey == 1) ? true : false;
}

//Start T25 : DJH 13:10:31 : IR-236909V6R2014x
//Start T25 : DJH 13:11:19 : IR-269604V6R2014x 
//Checking for Bad characters in the Text Area field
function checkBadChars(fieldName) {

    if (!fieldName)
        fieldName = this;

    var badChars = "";
    var message = msg;
    for (var i = 0; i < arrBadChars.length; i += 2) {

        if (fieldName.indexOf(arrBadChars[i]) > -1) {
            badChars += arrBadChars[i] + " ";
        }
    }

    if ((badChars).length != 0) {
        message += badChars;
        alert(message);
        return false;
    }

    return true;
}

//End T25 : DJH

// PROTO to navigate with tabs
function createTabsDiv() {
    var topWindowDocument = getTopWindow().document;

    //Append the CSS for the jQuery-UI
    var cssId = 'jquery-ui-smoothness.css';
    if (!document.getElementById(cssId)) {
        var head = topWindowDocument.getElementsByTagName('head')[0];
        var csslink = topWindowDocument.createElement('link');
        csslink.id = cssId;
        csslink.rel = 'stylesheet';
        csslink.type = 'text/css';
        csslink.href = '../requirements/styles/jquery-ui-smoothness.css';
        csslink.media = 'all';
        head.appendChild(csslink);
    }

    $(topWindowDocument.body).append('<div id="testUI" style="width: 600px; height: 50px;' +
        'top: 92%; position: absolute; left: 32%;">' +
        '<div id="tabs">' +
        '<ul>' +
        '<li><a href="#tabs-1">R-0000026</a></li>' +
        '<li><a href="#tabs-2">CHAP-000001</a></li>' +
        '<li><a href="#tabs-3">R-0000028</a></li>' +
        '</ul>' +
        '<div id="tabs-1">' +
        '<p>Click here to see R-0000026.</p>' +
        '</div>' +
        '<div id="tabs-2">' +
        '<p>Morbi tincidunt,urus.</p>' +
        '</div>' +
        '<div id="tabs-3">' +
        '<p>Mauris es a, lacus.</p>' +
        '<p>Duis cursus. Maechendrerit.</p>' +
        '</div>' +
        '</div>' +
        '</div>');

    var tabsDiv = $("#tabs", topWindowDocument.body);
    tabsDiv.tabs({
        select: function(event, ui) {
            if (sessionStorage.getItem('bodyHtmlTabs_TEST') == null) {
                sessionStorage.setItem('bodyHtmlTabs_TEST', $('html').html());
            }

            $('html').html(sessionStorage.getItem('bodyHtmlTabs_TEST'));



        }
    });
    tabsDiv.hide();
    $("#testUI", topWindowDocument.body).hover(function() {
        tabsDiv.show();
    }, function() {
        tabsDiv.hide();
    });
}


jQuery.browser = {};
(function() {
    jQuery.browser.msie = false;
    jQuery.browser.version = 0;
    if (navigator.userAgent.match(/MSIE ([0-9]+)\./)) {
        jQuery.browser.msie = true;
        jQuery.browser.version = RegExp.$1;
    }
})();

function closeQuickChartPanel(){
	closePanel();
	return true;
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/RichTextEditorStructure.js global finish.");
}

