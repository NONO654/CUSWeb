//=================================================================
// JavaScript inline-data-entry-RMT.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================

/* Contains code for the new feature available in SB : Inline Data Entry */
/* @quickreview ZUD DJH 14:06:26  HL Sequence Order to Tree Order Migration */
// Global variables to handle the inline data entry
// quickreview T25 DJH 13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding tokens added.
// quickreview T94                  IR-388383-3DEXPERIENCER2016   09:15:15 No derived requirement for inline data entry
// quickreview QYG     16:05:03     javascript refactoring, location moved
// quickreview ZUD	   07:03:2017 : IR-488815-3DEXPERIENCER2017x: R419-FUN058646: On WebTop, from Edit menu TRM objects are getting created without "Title."

define('DS/ENORMTCustoSB/InlineDataEntry', ['DS/RichEditorCusto/Util'], function(){
	// Handler to call some methods before or after a specific function
	emxUICore.instrument(window, 'createNewChildRow', beforeAddNewChildRowRMT,
	        afterAddNewChildRowRMT);
	emxUICore.instrument(window, 'createNewChildRowAbove',
	        beforeAddNewChildRowSameLevelRMT, afterAddNewChildRowSameLevelRMT);
	emxUICore.instrument(window, 'createNewChildRowBelow',
	        beforeAddNewChildRowSameLevelRMT, afterAddNewChildRowSameLevelRMT);

	emxUICore.instrument(window, 'addExistingChildRow',
	        eraseDefaultValuesRMTExisting, afterAddExistingChildRowRMT);
	emxUICore.instrument(window, 'addExistingChildRowAbove',
	        eraseDefaultValuesRMTExisting, afterAddExistingChildRowSameLevelRMT);
	emxUICore.instrument(window, 'addExistingChildRowBelow',
	        eraseDefaultValuesRMTExisting, afterAddExistingChildRowSameLevelRMT);

	emxUICore.instrument(window, 'applyEdits', beforeApplyEditRMT, null);
	emxUICore.instrument(window, 'lookupAction', beforeApplyEditRMT, null);
	emxUICore.instrument(window, 'RefreshView', null, afterRefreshingRMT);

	// ZUD Changes to Handle TreeOrder Attribute For inline Edition commands
	// TO call beforeNewInlineChild() before BPS call _newInlineChild()
	emxUICore.instrument(window, '_newInlineChild',
	        beforeNewInlineChild, null);
	// TO call aftermodifyPostDataXML() after BPS call modifyPostDataXML()
	emxUICore.instrument(window, 'modifyPostDataXML',
	        null, aftermodifyPostDataXML);
	return {};
});

var addNewRowInProgress = false;
var treatedRows = [];
var dictData = {};
var checkNotEditableFieldsDict = {};
var lastTypeChoosen = {};

var CLASSIFICATION_COLUMN = 'Classification';
var DIFFICULTY_COLUMN = 'Difficulty';
var PRIORITY_COLUMN = 'Priority';
var RS_COLUMN = 'Relationship Status';
var REVISION_COLUMN = 'Revision';
var STATUS_COLUMN = 'Status';
var ACTIVE_EC_COLUMN = 'Active EC';
var RESERVED_COLUMN = 'Reserved';
var CONTENT_COLUMN = 'RichTextContent';
var TITLE_COLUMN = 'Title';

var RELATIONSHIP_TYPE = 'Relationship Type';

var CHAPTER_DATA = {};
var COMMENT_DATA = {};
var REQUIREMENT_DATA = {};
var SUB_REQUIREMENT_DATA = {};
var DER_REQUIREMENT_DATA = {};
var REQUIREMENT_SPECIFICATION_DATA = {};
var SPEC_STRUCTURE_DATA = {};

CHAPTER_DATA['Type'] = 'Chapter';
COMMENT_DATA['Type'] = 'Comment';
REQUIREMENT_DATA['Type'] = 'Requirement';
SUB_REQUIREMENT_DATA['Type'] = 'Sub Requirement';
DER_REQUIREMENT_DATA['Type'] = 'Derived Requirement';
REQUIREMENT_SPECIFICATION_DATA['Type'] = 'Requirement Specification';
SPEC_STRUCTURE_DATA['Type'] = 'Specification Structure';

CHAPTER_DATA['Icon'] = 'iconReqTypeChapter.png';
COMMENT_DATA['Icon'] = 'iconReqTypeComment.png';
REQUIREMENT_DATA['Icon'] = 'iconReqTypeRequirement.png';
SUB_REQUIREMENT_DATA['Icon'] = '../../common/images/iconReqTypeSubRequirement.png';
DER_REQUIREMENT_DATA['Icon'] = '../../common/images/iconReqTypeDerivedRequirement.png';
REQUIREMENT_SPECIFICATION_DATA['Icon'] = '';
SPEC_STRUCTURE_DATA['Icon'] = '';

CHAPTER_DATA['Translation'] = strChapterRMT;
COMMENT_DATA['Translation'] = strCommentRMT;
REQUIREMENT_DATA['Translation'] = strRequirementRMT;
SUB_REQUIREMENT_DATA['Translation'] = strSRRMT;
DER_REQUIREMENT_DATA['Translation'] = strDRRMT;
REQUIREMENT_SPECIFICATION_DATA['Translation'] = strRSRMT;
SPEC_STRUCTURE_DATA['Translation'] = strSSRMT;

CHAPTER_DATA['TypeChooser'] = false;
COMMENT_DATA['TypeChooser'] = false;
REQUIREMENT_DATA['TypeChooser'] = true;
SUB_REQUIREMENT_DATA['TypeChooser'] = true;
DER_REQUIREMENT_DATA['TypeChooser'] = true;
REQUIREMENT_SPECIFICATION_DATA['TypeChooser'] = false;
SPEC_STRUCTURE_DATA['TypeChooser'] = false;

CHAPTER_DATA['RS'] = SPEC_STRUCTURE_DATA['Type'];
COMMENT_DATA['RS'] = SPEC_STRUCTURE_DATA['Type'];
REQUIREMENT_DATA['RS'] = SPEC_STRUCTURE_DATA['Type'];
SUB_REQUIREMENT_DATA['RS'] = SUB_REQUIREMENT_DATA['Type'];
DER_REQUIREMENT_DATA['RS'] = DER_REQUIREMENT_DATA['Type'];
REQUIREMENT_SPECIFICATION_DATA['RS'] = '';
SPEC_STRUCTURE_DATA['RS'] = '';

var MAP_DATA_TYPE = {};
MAP_DATA_TYPE[CHAPTER_DATA['Type']] = CHAPTER_DATA;
MAP_DATA_TYPE[COMMENT_DATA['Type']] = COMMENT_DATA;
MAP_DATA_TYPE[REQUIREMENT_DATA['Type']] = REQUIREMENT_DATA;
MAP_DATA_TYPE[SUB_REQUIREMENT_DATA['Type']] = SUB_REQUIREMENT_DATA;
MAP_DATA_TYPE[DER_REQUIREMENT_DATA['Type']] = DER_REQUIREMENT_DATA;
MAP_DATA_TYPE[REQUIREMENT_SPECIFICATION_DATA['Type']] = REQUIREMENT_SPECIFICATION_DATA;
MAP_DATA_TYPE[SPEC_STRUCTURE_DATA['Type']] = SPEC_STRUCTURE_DATA;

/* Checks if the object is within the array */
function containsArray(a, obj) {
    for ( var i = 0; i < a.length; i++) {
        if (a[i] === obj) {
            return true;
        }
    }
    return false;
}

/* Get all the new rows */
function getTDElementForNewRows(rootNode, recMode) {

    var aNewRows = null;

    if (recMode && (rootNode == undefined || rootNode == null))
        return [];
    else if (recMode) {
        aNewRows = rootNode;
    } else {
        // Get the root, then the children
        aNewRows = emxUICore.selectNodes(oXML, "/mxRoot/rows/r")[0].childNodes;
    }

    var items = [];
    for ( var i = 0; i < aNewRows.length; i++) {

        items = items.concat(getTDElementForNewRows(aNewRows[i].childNodes,
                true));
        try {
            if (aNewRows[i].getAttribute('status') == 'new') {
                items.push(document.getElementById('icon_'
                        + aNewRows[i].getAttribute('id')));
            }
        } catch (ex) {
            // NOP
        }
    }
    return items;
}

/* Generates a link with the type/image */
function generateLink(imageType, typeToPrint, realType, mode) {
    var generatedLink = "<img src='images/" + imageType
            + "' align='middle' title='" + typeToPrint + "'>&#160;";
    if (mode == "existing" || mode == "new") {
        generatedLink += "[" + typeToPrint + "]</a></span>";
    }
    return generatedLink;
}

// For the type chooser
var typeChooserRow = null;

// If you want to use cache, async is false
function getXMLDataCached(url) {
    var response = null;
    $.ajax({type: "GET",
        url: url,
        dataType: "text",
        async: false,
        cache: true,
        success: function(txt) {
            var  newpostDataXML = emxUICore.createXMLDOM();
            newpostDataXML.loadXML(txt);
            emxUICore.checkDOMError(newpostDataXML);
            response = newpostDataXML;
        }  
    });    
    return response;
}

/* When adding a row to the SB */
function defaultAddRowRMT(strIconToPrint, mode, bSameLevel) {
    addNewRowInProgress = true;

    var originalHTML = "<a href=\"javascript:;\"><img src=\"images/"
            + strIconToPrint + "\" border=\"0\" height=\"16\" /></a>&#160;";

    // We're looking for the new row
    var rows = getTDElementForNewRows();
    for ( var i = 0; i < rows.length; i++) {

        var tooltipIcons = "<img src=\"images/buttonHelp.gif\" border=\"0\" width=\"16\" height=\"16\" class=\"showTip ";
        tooltipIcons += rows[i].id;
        tooltipIcons += "_hover\"/>&#160;";

        // Get the parent ID to determine the right type
        var parentID = null;
        var rowChecked = emxUICore.selectSingleNode(oXML,
                "/mxRoot/rows//r[@checked='checked']");
        if (rowChecked != null) {
            parentID = rowChecked.getAttribute("o");

            // If the root is selected and the user tries to add below or above, we insert as child instead
            var rowRootID = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0]
            .getAttribute("o"); // The root
            if (rowRootID ==  parentID && bSameLevel == true) {
            	bSameLevel = false;
            }
            
            // If we use 'Insert above' or 'Insert below'
            if (bSameLevel) {
                parentID = rowChecked.getAttribute("p");
            }
        } else
            parentID = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0]
                    .getAttribute("o"); // The root
        
        var url = "../requirements/RequirementUtil.jsp?mode=checkTypeBeforeAdding&strParentID=";
        url += parentID + "&" + csrfParams;

        var root = getXMLDataCached(url);
        
        // Range Type
        var linkToShow = "<table>";
        var nodesToTreat = emxUICore.selectNodes(root, "/mxRoot//*");
        for ( var j = 0; j < nodesToTreat.length; j++) {
            var valueType = nodesToTreat[j].textContent;

            // For recent version of IE
            if (isIE && valueType == undefined) {
                valueType = nodesToTreat[j].text;
            }
            
            // IR-388383-3DEXPERIENCER2016
            if (valueType === DER_REQUIREMENT_DATA['Type']) {
            	continue;
            }
            
            // Default error msg
            if (MAP_DATA_TYPE[valueType] == null && valueType != 'NOP') {
                linkToShow += "<tr class=\"\"><td>" + valueType;
            }
            else if (MAP_DATA_TYPE[valueType] == null) {
                linkToShow += "<tr class=\"\"><td>" + strNoneRMT;
            } else {
                var linkToPrint = "<tr class=\"\"><td><span id='tooltip_inline_"
                        + valueType.replace(' ', '')
                        + "'><a style=\"text-decoration: none\" href=\"#\" onclick=\"javascript:defaultUpdateRowDataRMT('"
                        + mode + "', '" + rows[i].id + "',";

                typeChooserRow = [ valueType, rows[i] ];
                var typeChooser = "&#160; <input onclick=\"javascript:typeRequirementChooser('"
                        + valueType
                        + "', '" + rows[i].id + "')\" value=\"+\" "
                        + "name=\"btnTypeActual\" type=\"button\">";
                var endLink = MAP_DATA_TYPE[valueType]['TypeChooser'] == true ? typeChooser
                        : '';
                linkToShow += linkToPrint
                        + "'"
                        + MAP_DATA_TYPE[valueType]['Icon']
                        + "', '"
                        + valueType
                        + "', '"
                        + MAP_DATA_TYPE[valueType]['RS']
                        + "', false)\"> "
                        + generateLink(MAP_DATA_TYPE[valueType]['Icon'],
                                MAP_DATA_TYPE[valueType]['Translation'],
                                valueType, mode) + endLink;
            }

            linkToShow += "</td></tr>";
        }

        linkToShow += "</table>";

        // If the content hover already exists, we don't need to modify it
        if (dw_Tooltip.content_vars[rows[i].id + "_hover"] == undefined) {
            var currentHover = dw_Tooltip.content_vars[rows[i].id + "_hover"] = {};
            currentHover["sticky"] = true;
            currentHover["content"] = linkToShow;
        }

        if (containsArray(treatedRows, rows[i].id) == false) {
            treatedRows.push(rows[i].id);
            dictData[rows[i].id + "_original"] = originalHTML;
            dictData[rows[i].id + "_tooltip"] = tooltipIcons;
        } else {
            continue;
        }

        var searchResult = rows[i];
        searchResult.innerHTML = originalHTML + tooltipIcons;

        checkNotEditableFields(rows[i].id, 'Uneditable');
    }
}

var strBaseType = null;
var strIdTooltip = null;
// Allow us to use the type chooser for custom type
function typeRequirementChooser(strType, idTooltip) {

    strBaseType = strType;
    strIdTooltip = idTooltip;
    
    var objForm = emxUICore.getNamedForm(window, 0);
    if (objForm.elements['TypeActual'] == undefined) {
        var typeActualForm = document.createElement('input');
        typeActualForm.type = 'hidden';
        typeActualForm.name = 'TypeActual';
        typeActualForm.value = REQUIREMENT_DATA['Type'];
        objForm.appendChild(typeActualForm);

        var typeActualDisplayForm = document.createElement('input');
        typeActualDisplayForm.type = 'hidden';
        typeActualDisplayForm.name = 'TypeActualDisplay';
        typeActualDisplayForm.value = REQUIREMENT_DATA['Type'];
        objForm.appendChild(typeActualDisplayForm);
    }

    showChooser(
            '../common/emxTypeChooser.jsp?SelectType=single'
                    + '&ReloadOpener=false&SelectAbstractTypes=false&InclusionList=type_Requirement&ExclusionList=type_RequirementProxy'
                    + '&ReloadOpener=false&fieldNameActual=TypeActual&fieldNameDisplay=TypeActualDisplay'
                    + '&fieldNameOID=TypeActualOID&suiteKey=Requirements&callbackFunction=refreshRequirementType',
            '600', '600', 'true', '');
}

function refreshRequirementType() {
    if (strIdTooltip == null || strBaseType == null)
        return false;

    var divToUpdate = $('#tooltip_inline_' + strBaseType.replace(' ', ''))[0];
    var objForm = emxUICore.getNamedForm(window, 0);
    var displayedTextToReplace = divToUpdate.textContent.match(/\[.*?\]/)[0];
    
    var currentHover = dw_Tooltip.content_vars[strIdTooltip + "_hover"];
    currentHover["content"] = currentHover["content"].replace("'" + strBaseType + "'", "'" + objForm.elements['TypeActual'].value + "'");
    currentHover["content"] = currentHover["content"].replace("title='" + strBaseType + "'", "title='" + objForm.elements['TypeActual'].value + "'");
    currentHover["content"]  = currentHover["content"].replace(displayedTextToReplace, '['
            + objForm.elements['TypeActualDisplay'].value + ']');
    
    divToUpdate.parentNode.parentNode.parentNode.parentNode.outerHTML = currentHover["content"];
}

/* Add existing */
function afterAddExistingChildRowRMT() {
    defaultAddRowRMT("iconActionAdd.gif", "existing", false);
}

function afterAddExistingChildRowSameLevelRMT() {
    defaultAddRowRMT("iconActionAdd.gif", "existing", true);
}

/* Add new */
function afterAddNewChildRowRMT() {
    defaultAddRowRMT("iconActionCreate.gif", "new", false);
}

function afterAddNewChildRowSameLevelRMT() {
    defaultAddRowRMT("iconActionCreate.gif", "new", true);
}

/*
 * Changes the icon of the current row, updates the revision, updates the name,
 * and updates the postDataXML
 */
var treatedRowsMultiSelection = {};
function defaultUpdateRowDataRMT(mode, strRowIdToChange, strIconToPrint,
        strType, strRS, bRec) {
    
    // To check if we did one loop or not
    var didOneLoop = false;

    // If the user wants to apply the current operation to several rows
    // ONLY the rows with status = new will be treated
    var rowsChecked = emxUICore.selectNodes(oXML,
            "/mxRoot/rows//r[@checked='checked']");
    for ( var nbRowToAssist = 0; nbRowToAssist < rowsChecked.length; nbRowToAssist++) {
        if (rowsChecked[nbRowToAssist].getAttribute('status') == 'new') {
            if (treatedRowsMultiSelection['icon_'
                    + rowsChecked[nbRowToAssist].getAttribute('id')] != true) {
                didOneLoop = true;
                treatedRowsMultiSelection['icon_'
                        + rowsChecked[nbRowToAssist].getAttribute('id')] = true;
                defaultUpdateRowDataRMT(mode, 'icon_'
                        + rowsChecked[nbRowToAssist].getAttribute('id'),
                        strIconToPrint, strType, strRS, true);
            }
        }
    }
    
    if (didOneLoop != false && (bRec == false && rowsChecked.length != 0))
        return;

    var rows = getTDElementForNewRows();
    for ( var i = 0; i < rows.length; i++) {
        if (rows[i].id == strRowIdToChange) {

            var idCurrentRow = rows[i].id.replace('icon_', '');
            currentRow = getRow(idCurrentRow);

            /* A Sub/Derived requirement is still a requirement */
            if (strType == SUB_REQUIREMENT_DATA['Type']
                    || strType == DER_REQUIREMENT_DATA['Type'])
                strType = REQUIREMENT_DATA['Type'];

            
            // Here the icon is changed, and the post data XML is modified to
            // have the right type
            var tooltipIcons = "<img src=\"images/"
                    + strIconToPrint
                    + "\" border=\"0\" width=\"16\" height=\"16\" class=\"showTip ";
            tooltipIcons += strRowIdToChange;
            tooltipIcons += "_hover\"/>&#160;";

            var newHTML = dictData[strRowIdToChange + "_original"]
                    + tooltipIcons;
            dictData[strRowIdToChange + "_tooltip"] = tooltipIcons;
            modifyPostDataXMLRMT(strRowIdToChange, strType, strRS);
            rows[i].innerHTML = newHTML;

            // In existing mode, we don't need to fill the other fields
            if (mode == "existing")
                return;

            if (strType == COMMENT_DATA['Type']
                    || strType == CHAPTER_DATA['Type'])
                checkNotEditableFields(rows[i].id, 'Uneditable');
            else
                checkNotEditableFields(rows[i].id, 'Editable');

            // Here the revision is updated, depending of the current type
            for ( var nbColumns = 0; nbColumns < colMap['columns'].length; nbColumns++) {
                if (colMap['columns'][nbColumns].name == REVISION_COLUMN) {
                    currentColumnPosition = nbColumns + 1;
                    break;
                }
            }

            // ZUD Insert Auto Name in Title Column Too.
            var curentcolumnPosition_Rev = currentColumnPosition;
            var currentColumnPosition_Title = colMap['columns'][TITLE_COLUMN];
            var column_Title = TITLE_COLUMN;
            // Title Column is present
            if(currentColumnPosition_Title)
            {
            	currentColumnPosition_Title = colMap['columns']["Title"].index;
            }
           
            var autoName = getAutoNameRMT(strType);
            
            var TitleCount =  autoName.substring(autoName.indexOf(autonameSeparator) + 1); //Name.split("-")[1];
    	 	var title = TitleCount.substring(TitleCount.indexOf(autonameSeparator) + 1); 
    	 	title = strType +" " + title;
    	    // ZUD Insert Auto Name in Title Column Too.
    	 	
            // Here we are updating the revision
            var tdsTreeBodyTable = document.getElementById("treeBodyTable")
                    .getElementsByTagName('td');
            for ( var nbTdsTreeBodyTable = 0; nbTdsTreeBodyTable < tdsTreeBodyTable.length; nbTdsTreeBodyTable++) {
                if (tdsTreeBodyTable[nbTdsTreeBodyTable].getAttribute('rmbrow') != null
                        && tdsTreeBodyTable[nbTdsTreeBodyTable]
                                .getAttribute('rmbrow').length > 10) {
                    var checkIdToTreat = strRowIdToChange.replace('icon_', '');
                    if (tdsTreeBodyTable[nbTdsTreeBodyTable]
                            .getAttribute('position') == curentcolumnPosition_Rev
                            && tdsTreeBodyTable[nbTdsTreeBodyTable]
                                    .getAttribute('rmbrow') == checkIdToTreat) {
                        if (strType == CHAPTER_DATA['Type']
                                || strType == COMMENT_DATA['Type']) {
                            updateTextRMT(idCurrentRow,
                                    tdsTreeBodyTable[nbTdsTreeBodyTable],
                                    REVISION_COLUMN, '1');
                        } else {
                            updateTextRMT(idCurrentRow,
                                    tdsTreeBodyTable[nbTdsTreeBodyTable],
                                    REVISION_COLUMN, 'A');
                        }
                    }
                    
                    // Autonaming for For Title
                    if (tdsTreeBodyTable[nbTdsTreeBodyTable]
                    .getAttribute('position') == currentColumnPosition_Title
                    && tdsTreeBodyTable[nbTdsTreeBodyTable]
                            .getAttribute('rmbrow') == checkIdToTreat) {
                    	updateTextRMT(idCurrentRow,
                    	tdsTreeBodyTable[nbTdsTreeBodyTable],
                    	column_Title, title);
                    	}
                }
            }
            
            
            currentColumnPosition = colMap['columns']['Name'];
            if(currentColumnPosition)
            {
            currentColumnPosition = colMap['columns']['Name'].index;
            updateTextRMT(
                    idCurrentRow,
                    rows[i].parentNode.parentNode.parentNode.parentNode.parentNode,
                    'Name', autoName);
            	
            	 
            }  
            
        }
    }
}

/* Erases the default values for add existing */
function eraseDefaultValuesRMTExisting() {
    var columnsToErase = [ RS_COLUMN, CLASSIFICATION_COLUMN, DIFFICULTY_COLUMN,
            PRIORITY_COLUMN ];
    for ( var nbColumns = 0; nbColumns < columnsToErase.length; nbColumns++) {
        if (colMap['columns'][columnsToErase[nbColumns]] != undefined) {
            colMap['columns'][columnsToErase[nbColumns]].rangeValues = new Object();
            colMap['columns'][columnsToErase[nbColumns]].setAttribute(
                    'defExnDisplayValue', '');
            colMap['columns'][columnsToErase[nbColumns]].setAttribute(
                    'defExnValue', '');
            colMap['columns'][columnsToErase[nbColumns]].setAttribute(
                    'defNewDisplayValue', '');
            colMap['columns'][columnsToErase[nbColumns]].setAttribute(
                    'defNewValue', '');
        }
    }
}

function beforeAddNewChildRowRMT() {
    return beforeAddNewChildRowDefaultRMT(false);
}
    
function beforeAddNewChildRowSameLevelRMT() {
    return beforeAddNewChildRowDefaultRMT(true);
}
    
function beforeAddNewChildRowDefaultRMT(bSameLevel) {

    /* Erases the default values for add new */
    if (colMap['columns'][RS_COLUMN] != undefined) {
        colMap['columns'][RS_COLUMN].rangeValues = new Object();
        colMap['columns'][RS_COLUMN].setAttribute('defExnDisplayValue', '');
        colMap['columns'][RS_COLUMN].setAttribute('defExnValue', '');
        colMap['columns'][RS_COLUMN].setAttribute('defNewDisplayValue', '');
        colMap['columns'][RS_COLUMN].setAttribute('defNewValue', '');
    }

    // Get the parent ID to determine the right type
    var parentID = null;
    var rowChecked = emxUICore.selectSingleNode(oXML,
            "/mxRoot/rows//r[@checked='checked']");

    if (rowChecked != null) {
        parentID = rowChecked.getAttribute("o");

        // If we use 'Insert above' or 'Insert below'
        if (bSameLevel) {
            parentID = rowChecked.getAttribute("p");
        }
        
        // If the root is selected and the user tries to add below or above, we insert as child instead
        var rowRootID = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0]
        .getAttribute("o"); // The root
        if ((parentID == undefined || parentID == "") && bSameLevel == true) {
        	parentID = rowRootID;
        }
    } else {
        rowChecked = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0];
        parentID = rowChecked.getAttribute("o"); // The root
    }

    if (parentID == undefined || parentID == "") {
        var strXMLError = "<mxRoot><object rowId=\""
                + rowChecked.getAttribute('id') + "\"><error>"
                + strCannotCreateObjectInlineRMT + "</error></object></mxRoot>";
        emxEditableTable.displayValidationMessages(strXMLError);
        return false;
    }

    return true;
}

/* Updates a text inside a particular cell */
function updateTextRMT(idCurrentRow, currentTDRMT, colName, newText) {

    var floatingDiv = document.createElement("div");
    floatingDiv.name = "floatingDiv";
    floatingDiv.className = "formLayer";
    document.forms[0].appendChild(floatingDiv);

    currentCell = getTotalCellInfo(currentRow, colName);
    currentCell.target = currentTDRMT;

    var textfield = textField(currentCell.target, colMap['columns'][0],
            newText, idCurrentRow);
    textfield.value = newText;
    if (isIE) {
        floatingDiv.style.visibility = "hidden";
    } else {
        floatingDiv.style.visibility = "invisible";
    }
    floatingDiv.appendChild(textfield);

    updateText(currentCell.target, textfield, currentTDRMT.parentNode
            .getAttribute("id"));
}

/* Get an Auto-Name for a requirement, a comment, ... */
function getAutoNameRMT(type) {
    var url = "../requirements/RequirementUtil.jsp?mode=getAutoNameFor&strType=";
    url += type + "&" + csrfParams;
    var root = emxUICore.getXMLData(url).documentElement;

    var valuePath = "/mxRoot/autoNameRMT/text()";
    var value = emxUICore.selectSingleNode(root, valuePath).nodeValue;
    return value;
}

/* For a chapter or a comment, some fiedls can't be editable */
function checkNotEditableFields(rowId, mode) {
    // FIXME Allocation Status, Content... non-editable - SEE HF RELATED - IR-228435V6R2014x
    rowId = rowId.replace('icon_', '');
    var columnsToErase = [CLASSIFICATION_COLUMN, DIFFICULTY_COLUMN,
            PRIORITY_COLUMN, STATUS_COLUMN, ACTIVE_EC_COLUMN, RESERVED_COLUMN, CONTENT_COLUMN];

    for ( var nbColumnsToErase = 0; nbColumnsToErase < columnsToErase.length; nbColumnsToErase++) {
        var tdsTreeBodyTable = document.getElementById("mx_divTableBody")
                .getElementsByTagName('tr');
        for ( var nbTdsTreeBodyTable = 0; nbTdsTreeBodyTable < tdsTreeBodyTable.length; nbTdsTreeBodyTable++) {
            if (tdsTreeBodyTable[nbTdsTreeBodyTable].id == rowId) {

                if (colMap['columns'][columnsToErase[nbColumnsToErase]] != undefined)
                    currentColumnPosition = colMap['columns'][columnsToErase[nbColumnsToErase]].index;

                // We need to browse the different TD
                var childNodesTD = tdsTreeBodyTable[nbTdsTreeBodyTable].childNodes;
                for ( var iTD = 0; iTD < childNodesTD.length; iTD++) {
                    if (childNodesTD[iTD].tagName == 'TD'
                            && childNodesTD[iTD].getAttribute('position') == currentColumnPosition) {
                        var currentTDRMT = childNodesTD[iTD];

                        if (mode == 'Uneditable') {
                            if (checkNotEditableFieldsDict[rowId] == undefined)
                                checkNotEditableFieldsDict[rowId] = {};

                            if (currentTDRMT.innerHTML == "")
                                continue;

                            checkNotEditableFieldsDict[rowId]['className_'
                                    + currentColumnPosition] = currentTDRMT.className;
                            checkNotEditableFieldsDict[rowId]['innerHTML_'
                                    + currentColumnPosition] = currentTDRMT.innerHTML;

                            currentTDRMT.innerHTML = "";
                            currentTDRMT.className = "";
                        } else {
                            if (checkNotEditableFieldsDict[rowId] == undefined)
                                continue;
                            
                            if (checkNotEditableFieldsDict[rowId]['innerHTML_'
                                    + currentColumnPosition] == undefined)
                                checkNotEditableFieldsDict[rowId]['innerHTML_'
                                                                  + currentColumnPosition] = '';
                            
                            currentTDRMT.innerHTML = checkNotEditableFieldsDict[rowId]['innerHTML_'
                                    + currentColumnPosition];
                            currentTDRMT.className = checkNotEditableFieldsDict[rowId]['className_'
                                    + currentColumnPosition];
                        }
                    }
                }
            }
        }
    }
}

/* When refreshing the SB content */
function afterRefreshingRMT() {
    if (!addNewRowInProgress)
        return;

    var rows = getTDElementForNewRows();
    var newHTML = "";
    for ( var i = 0; i < rows.length; i++) {

        var tooltipIcons = "<img src=\"images/buttonHelp.gif\" border=\"0\" width=\"16\" height=\"16\" class=\"showTip ";
        tooltipIcons += rows[i].id;
        tooltipIcons += "_hover\"/>&#160;";

        if (containsArray(treatedRows, rows[i].id) == false) {
            // NOP
        } else {
            if (rows[i].innerHTML.indexOf("iconStatusError") > 0
                    && rows[i].innerHTML.indexOf("showTip") < 0) {
                var oldHTML = rows[i].innerHTML
                        .replace("align=\"middle\"", " ");
                newHTML = oldHTML + dictData[rows[i].id + "_tooltip"];
            } else
                newHTML = dictData[rows[i].id + "_original"]
                        + dictData[rows[i].id + "_tooltip"];
        }
        var searchResult = rows[i];
        searchResult.innerHTML = newHTML;

        if (newHTML == "")
            continue;

        if (newHTML.indexOf(CHAPTER_DATA['Type']) > 1
                || newHTML.indexOf(COMMENT_DATA['Type']) > 1
                || newHTML.indexOf('Help') > 1) {
            checkNotEditableFields(rows[i].id, 'Uneditable');
        } else
            checkNotEditableFields(rows[i].id, 'Editable');
    }
}

/* Before saving, we need to ensure that a type has been specified */
function beforeApplyEditRMT() {
    var rows = getTDElementForNewRows();
    var checkOK = true;
    for ( var i = 0; i < rows.length; i++) {
        if (rows[i].innerHTML.indexOf("buttonHelp") > 0) {
            var strXMLError = "<mxRoot><object rowId=\""
                    + rows[i].id.replace("icon_", "") + "\"><error>"
                    + strErrorApplyRMT + "</error></object></mxRoot>";
            emxEditableTable.displayValidationMessages(strXMLError);
            checkOK = false;
        }
    }
    return checkOK;
}

/* Modifies the XML data to specify the type and the relationship */
function modifyPostDataXMLRMT(rawRowID, strType, strRS) {
    var rowID = rawRowID.replace("icon_", "");
    var columnType = getElement("column");
    columnType.setAttribute("name", "Type");
    var textType = oXML.createTextNode(strType);
    columnType.appendChild(textType);

    var columnRS = getElement("column");
    columnRS.setAttribute("name", RELATIONSHIP_TYPE);
    var textRS = oXML.createTextNode(strRS);
    columnRS.appendChild(textRS);

    var childList = postDataXML.childNodes.item(0).childNodes;
    for ( var i = 0; i < childList.length; i++) {
        var rowChildList = childList[i].childNodes;
        for ( var j = 0; j < rowChildList.length; j++) {
            if (rowID == rowChildList[j].getAttribute("rowId")) {
                rowChildList[j].appendChild(columnType);
                rowChildList[j].appendChild(columnRS);
            }
        }
    }
}

function checkAddedRowRMT(row) {
    return true;
}

// ZUD Changes to Handle TreeOrder Attribute For inline Edition commands
var inlineEditingAction;
function beforeNewInlineChild(markup,insertAction)
{
	inlineEditingAction = insertAction;
}

function aftermodifyPostDataXML(crow,prow,markup)
{
	 	 
	 var poid    = getAttribute(prow,"o");
	    var prid    = getAttribute(prow,"id");
	    var pobject = getNode(postDataXML,"/mxRoot/object[@rowId='" + prid + "'][@objectId='" + poid + "']");
	    pobject.setAttribute("inlineEditingAction",inlineEditingAction);
}

