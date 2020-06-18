//=================================================================
// JavaScript parameter.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
/*
 *                          MM:DD:YY
 * @quickReview ZUD      	10:10:14  : IR-333259-3DEXPERIENCER2015x Parameter value displayed in "Content" cell contains unexpected "null" values
 * @quickreview KIE1 ZUD 	02:13:15  : IR-333259-3DEXPERIENCER2016 Parameter value displayed in "Content" cell contains unexpected "null" values
 * @quickreview KIE1 ZUD 	04:13:15  : IR-362506-3DEXPERIENCER2016x: R417-033503: In "Parameter Edit View", invalid value for parameter display blank alert which is un-closable. ==> Replaced jAlert by alert.
 * @quickreview KIE1 HAT1   05:28:15  : IR-362497-3DEXPERIENCER2016x : R417-033503: On structure view, Parameter Edit View UI need corrections.
 * @quickreview KIE1 ZUD    06:09:15  : IR-362506-3DEXPERIENCER2016x : R417-033503: In "Parameter Edit View", invalid value for parameter display blank alert which is un-closable.
 * @quickreview KIE1 ZUD    24:08:15  : IR-386290-3DEXPERIENCER2016x: PLM Parameter migration   
 * @quickreview QYG         05:03:16    javascript refactoring, split from RichTextEditorStructure.js
 * @quickreview KIE1 ZUD 	21:02:17  : IR-502482-3DEXPERIENCER2018x: Requirement: Parameter - After modifying the parameter value, original value in red color with strike-through is not displayed.
 * @quickreview KIE1 ZUD 	05:10:17  : IR-553055-3DEXPERIENCER2018x: Content column in Requirement specification page doesnt show the PLM Parameter value if PLM Parameter include value <
 * @quickreview KIE1 ZUD 	01:16:18  : IR-573969-3DEXPERIENCER2018x: R420-STP - Minimum value, parameter value and maximum value displayed incorrectly on parameter edit view pop up
*/
if(localStorage['debug.AMD']) {
	var _RMTParameter_js = _RMTParameter_js || 0;
	_RMTParameter_js++;
	console.info("AMD: ENORMTCustoSB/parameter.js loading " + _RMTParameter_js + " times.");
}

define('DS/ENORMTCustoSB/parameter', [], function(){
	return {};
});



// ++ ZUD support for Parameter under Requirement. Called from emxRMTCommonBase_mxJPO ++
function getParameterContent(currentImage, ParentID, objectID, timeStampObject, convertorVersion) {
    //Ajax call to RequirementUtil.jsp to retrieve Content column value for Parameter Node
    $.ajax({
        type: "GET",
        url: "../requirements/RequirementUtil.jsp?mode=getParameterValues&strObjID=" + objectID +
            "&tStamp=" + timeStampObject +
            "&convertorVersion=" + convertorVersion + "&" + csrfParams,
        dataType: "text",
        cache: true,
        success: function(txt) {
            var newpostDataXML = emxUICore.createXMLDOM();
            newpostDataXML.loadXML(txt);
            emxUICore.checkDOMError(newpostDataXML);
            refreshCellWithParameterContentRMT(newpostDataXML, objectID, currentImage);
        }
    });

}

// ++ ZUD Refreshes Structure Browser page. It is called every time OK button in the Parameter table is clicked.
function refreshCellWithParameterContentRMT(oXMLHTML, oClientData, oHTTP) {
	var valuePath = "/mxRoot/htmlContent/text()";
	var value = emxUICore.selectSingleNode(oXMLHTML, valuePath).nodeValue;

	if (oHTTP != null) {

		// We hide some span who are added by BPS
		$(oHTTP.parentElement).children('span').css('display', 'none');


		// Save some data about the current object, and the current row, one time
		if (dataObjectRTFDict[oClientData + '_id'] == undefined) {
			dataObjectRTFDict[oClientData + '_id'] = oHTTP.parentElement.parentElement.id;
			dataObjectRTFDict[oClientData + '_o'] = oClientData;
			dataObjectRTFDict[oClientData + '_r'] = findObjectRel(oHTTP);
			dataObjectRTFDict[oClientData + '_p'] = findObjectParent(oHTTP);
		}


		dataObjectRTFDict[oClientData + '_td'] = oHTTP;

		value = setDivDecoratorForParameter(value, oClientData);
		if (RTFEditedObjects[oClientData + '_b'] == true) {
			value = RTFEditedObjects[oClientData + '_d'];
			value = value.replace('iconActionEdit.png', 'iconActionEdit.gif');
			value = value.replace('iconActionEdit.png', 'iconActionEdit.gif');
		}
		dataObjectRTFDict[oClientData + '_td'].outerHTML = value;
	}
}
    // -- ZUD support for Parameter under Requirement --

// ++ ZUD support for Parameter under Requirement ++

function setDivDecoratorForParameter(strHTML, objectID) {
	// Get information about the current object
	var strType = $('#objectType', strHTML).html();
	var lud = $('#lud', strHTML).html();
	var convertorVersion = $('#convertorVersion', strHTML).html();

	strType = strType != null ? strType : '';
	lud = lud != null ? lud : 0;
	convertorVersion = convertorVersion != null ? convertorVersion : '';

	// If the RichText has to be expanded
	var heightRTContainer = '55px';
	if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == 'true') {
		heightRTContainer = 'none';
	}
	var editorDivID = objectID.replace(/\./g, '');
	var functionDblClickToEdit = '\"javascript:openParameterEditorRMT(\'' + objectID + '\', \'' + strType +
		'\', \'' +
		lud + '\', \'' + convertorVersion + '\')\"';
	var decoratedHTML = "<div id='ParameterEditContainer_" + editorDivID + "' style='max-height:" +
		heightRTContainer + "; min-height: 20px; min-width: " +
		"50px; overflow: hidden; position: relative;' ondblclick=" + functionDblClickToEdit + ">";
	decoratedHTML += strHTML;


	return decoratedHTML;
}
// -- ZUD support for Parameter under Requirement --


// ++ ZUD PArameter Support under Requirement. This function is called on double click on Parameter Content cell ++
// It Opens floating Div dialog (Table) to edit parameter values
function openParameterEditorRMT(strObjIDToLoad, strType, lud, version) {
        $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
            $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
                function() {

                    jDialogForParameterEdition(strObjIDToLoad);
                });
        });
    }
    // -- ZUD Parameter Support under Requirement --

/** If we don't have any editor available, we just show a classic dialog with the HTML content inside **/
// ++ ZUD Parameter Support under Requirement ++
var ParametertableCellEdited = "0";

function jDialogForParameterEdition(strObjIDToLoad) {
    var editorDivID = strObjIDToLoad.replace(/\./g, '');
    var tableValues = $('#Values_' + editorDivID).text();
    var unit = $('#Unit_' + editorDivID).text();
    var paraType = $('#paraType_' + editorDivID).text();
    
    if(tableValues == "")
    	return;
    tableValues = tableValues.replace(/ &lt; /g," < ");
    fillParameterTable(editorDivID, tableValues, unit);
    
    var buttonsjQueryNothingView = {};

    buttonsjQueryNothingView[cancelButtonCK] = function() {
        currentJDialogEditor.dialog("close");
    };

    // Dialog-extend options
    var dialogExtendOptions = {
        "closable": true,
        "maximizable": true,
        "minimizable": false,
        "dblclick": 'maximize'
    };

    var dialogOptions = {
        modal: true,
        resizable: true,
        height: 200,
        width: 640,
        buttons: [{
                text: textOk,
                click: function() {
                    if ("1" == ParametertableCellEdited) // values edited in teh div table
                    {
                        var Param_Val = "";
                        $('#Table_' + editorDivID).find("tbody tr td").each(function() {
                            Param_Val += $(this).text();
                            // entering # results in crashing the web page. Return in this case instead of crash.
                            if (Param_Val.indexOf('#') >= 0)
                                return;
                            Param_Val += "< ";
                        });
                        Param_Val = Param_Val.substr(0, Param_Val.lastIndexOf("<"));
                        Param_Val = Param_Val.replace("...", "");
                        Param_Val = Param_Val.replace("...", "");
                        Param_Val = Param_Val.replace("...", "");

                        // Checking If Param Values are Valid or not
                       
	                       var errorMessage = "";
	                       
                        		var displayUnit = $('#Select_'+editorDivID +' option:selected').text();
                        		
                        		var content_Val = "";
                        		var split_Val = Param_Val.split("<");
                        		
                        		if(paraType.contains("StringParameter"))
                        		{
                        			var newString = "";
                        			for(var i=0;i<split_Val.length;i++)
                        			{
                        				newString += split_Val[i];
                        				if(newString.length > 0 && i < split_Val.length - 2)
                        					newString +="<";
                        				
                        				split_Val[i] = "";
                        			}
                        			split_Val[1] = newString;
                        		}
                        		if(split_Val[0].trim().length > 0){
                      			   content_Val +=split_Val[0].toUpperCase()+" "+displayUnit+" < ";   
                             	}else{
                             		content_Val += "";
                             	}
                             	
                             	if(split_Val[1].trim().length > 0){
                      			   content_Val +="<b>"+split_Val[1].toUpperCase()+"</b> "+displayUnit;   
                             	}else{
                             		content_Val +="<b>...</b>";
                             	}
                             	
                             	if(split_Val[2].trim().length > 0){
                      			   content_Val +=" <"+split_Val[2].toUpperCase()+" "+displayUnit;   
                             	}else{
                             		content_Val += "";
                             	}
                             	
                             	// ++added code for previous value for showing strike-through
                             	var previous_val = "";
                             	var TableVal = tableValues.replace(/null/g,"");
                             	if(paraType.contains("StringParameter")|| paraType.contains("BooleanParameter"))
                             	{
                             		TableVal = tableValues.replace(/</g,"< ");
                             		previous_val = TableVal.toUpperCase();
                             	}else{
                             		if(TableVal.search("<") > -1 || displayUnit !== "")
                             		{
                             			var split_pre_Val = TableVal.split("<");
                             			if(split_pre_Val[0].trim().length > 0){
                             				previous_val +=split_pre_Val[0]+" "+displayUnit+" < ";   
                                      	}else{
                                      		previous_val += "";
                                      	}
                                      	
                                      	if(split_pre_Val[1].trim().length > 0){
                                      		previous_val +="<b>"+split_pre_Val[1]+"</b> "+displayUnit;   
                                      	}else{
                                      		previous_val +="<b>...</b>";
                                      	}
                                      	
                                      	if(split_pre_Val[2].trim().length > 0){
                                      		previous_val +=" <"+split_pre_Val[2]+" "+displayUnit;   
                                      	}else{
                                      		previous_val += "";
                                      	}
                             		}else{
                             			previous_val = TableVal;
                             		}
                             	}
                             	// --added code for previous value for showing strike-through
                             	
                             	 // IR-386290-3DEXPERIENCER2016x: Checking for parameter is valid or not if not then errorMessage will alert
                            	if(paraType.contains("StringParameter")|| paraType.contains("BooleanParameter"))
                        		{}
                        		else
                        		{
                        			var min = parseFloat(split_Val[0]);
                            		var mid = parseFloat(split_Val[1]);
                            		var max = parseFloat(split_Val[2]);	
                            		
                            		if(( isNaN(mid) && split_Val[1].trim().length !== 0 ) && (split_Val[0].trim().length > 0 || split_Val[2].trim().length > 0))
                            		{
                            			errorMessage = NominalStringValueError;
                            		}
                            		else if(isNaN(min) && split_Val[0].trim() !== "")
                        			{
                        				errorMessage = MinimalStringValueError;
                        			}
                        			else if(isNaN(max) && split_Val[2].trim() !== "")
                        			{
                        				errorMessage = MaximalStringValueError;
                        			}
                        			else
                        			{
	                            		if(!isNaN(mid))
	                            		{
	                            			if(!isNaN(min) && !isNaN(max))
	                            			{
	                            				if(min > mid || mid > max)
	                            				{
	                                    			errorMessage = NominalErrorAlert;
	                                    		}
	                            				else if(min > max)
	                            				{
	                                    			errorMessage = MinMaxErrorAlert;
	                                    		}
	                            			}else 
	                            			if(!isNaN(min))
	                            			{
	                            				if(min > mid)
	                            				{
	                                    			errorMessage = NominalErrorAlert;
	                                    		}
	                            			}else if(!isNaN(max)){
	                            				if(max < mid)
	                            				{
	                                    			errorMessage = NominalErrorAlert;
	                                    		}
	                            			}
	                            		}else{
	                            			if(!isNaN(min) && !isNaN(max))
	                            			{
	                            				if(min > max)
	                            				{
	                                    			errorMessage = MinMaxErrorAlert;
	                                    		}
	                            			}
	                            		}
                        			}
                        		}
                        		
                        		if(errorMessage.length > 0)
                        		{
                        			alert(errorMessage);
                        			errorMessage = "";
                        		}
                        		else
                        		{
                        			
                                	RTFEditedObjects[strObjIDToLoad + '_b'] =
                                        true;
                                    $('#contentCell_' + editorDivID).html(
                                    		content_Val);
                                   
                                    var previsousValue = document.getElementById('previousValue_' + editorDivID);
                                    previsousValue.innerHTML = previous_val;
                                  
                                    $('#Values_' + editorDivID).html(
                                    		Param_Val);
                                  
                                    var URLToSave = $('#ParameterEditContainer_' +
                                        editorDivID)[0].outerHTML;
                                    RTFEditedObjects[strObjIDToLoad + '_d'] =
                                        URLToSave;
                                    updateXMLWithParameterContent(strObjIDToLoad,
                                        Param_Val, hashmap[displayUnit]);

                                    //deleting the table as it was causing error otherwise
                                    deleteParameterTable(editorDivID);
                                    currentJDialogEditor.dialog("close");
                                    rebuildView();
                                    editMode();
                                    badParamVal = "0";
                                    ParametertableCellEdited = "0";
                                    stringCheck = "0";
                        		}
                        		
                    } else // nothing is edit in the table
                    {
                        deleteParameterTable(editorDivID);
                        currentJDialogEditor.dialog("close");
                        rebuildView();
                        editMode();
                        badParamVal = "0";
                        ParametertableCellEdited = "0";

                    }
                }
            },

            {
                text: textCancel,
                click: function() {
                    deleteParameterTable(editorDivID);
                    currentJDialogEditor.dialog("close");
                    // Refresh the view
                    rebuildView();
                    ParametertableCellEdited = "0";
                }
            }
        ],
        close: function() {
            try {
                deleteParameterTable(editorDivID);
                currentJDialogEditor.dialog("close");
                rebuildView();
                ParametertableCellEdited = "0";
            } catch (e) {
                // NOP
            }
        }
    };

    ParameterTableClick(editorDivID); // handles double click on Div's cell
    // Displays the Div (table) for parameter edit
    currentJDialogEditor = $('#ParameterEditor_' + editorDivID).dialog(dialogOptions).dialogExtend(
        dialogExtendOptions);
}
var stringCheck = 0;
var hashmap = {};
function fillParameterTable(editorDivID, tableValues, unit) {
	
	var TableVal = tableValues.replace(/null/g,"...");
	var prevUnit = "";
	var paraType = $('#paraType_' + editorDivID).text();
	if(unit.trim().length > 0 && unit !== null)
	{
		var Unit_ID = "Unit_" + editorDivID;
		var Select_ID = "Select_" + editorDivID;
		var Unit_Body = "<div id=\""+Unit_ID+"\" >";
		Unit_Body += "<lable> "+displayUnit+" : </lable>";
		Unit_Body += "<select id=\""+Select_ID+"\">";
		var unit_split = unit.split(",");
		
		prevUnit = unit_split[unit_split.length-1];
		for(var i = 0; i < unit_split.length-1; i++){
			var keyValue = unit_split[i].split(":");
			hashmap[keyValue[0].trim()]=keyValue[1].trim();
			if(keyValue[0].trim() === prevUnit ){
				Unit_Body += "<option selected='selected'>"+keyValue[0]+"</option>";	
			}else{
				Unit_Body += "<option>"+keyValue[0]+"</option>";
			}
		}
		
		Unit_Body += "</select>";
		Unit_Body += "</div>";
		
		 $('#ParameterEditor_' + editorDivID).append(Unit_Body);
	}
	
	var TableCell = TableVal.split("<");
	var Table_ID = "Table_" + editorDivID;
	var Table_Body = "";
	
	if(paraType.contains("StringParameter")|| paraType.contains("BooleanParameter")){
		
		Table_Body = "<div id=\"" + Table_ID +"\" >";
		Table_Body +="<table class=\"editableTable\" border='2' cellpadding='2' width='100%'> <thead> <tr class=\"ui-widget-header \"> <th></th><th>"+parameterValue+"</th><th></th> </tr></thead> ";
		Table_Body += "<td>...</td>";
		Table_Body += "<td>" + TableVal.replace(/</g , "< ") + "</td>";
		Table_Body += "<td>...</td>";
		Table_Body += "</tr> </tbody> </table> </div></div></div>";
		
		stringCheck = "1";
	}
	else{

	    Table_Body = "<div id=\"" + Table_ID +"\" >";
	    Table_Body +="<table class=\"editableTable\" border='2' cellpadding='2' width='100%'> <thead> <tr class=\"ui-widget-header \"> <th>"+minimalValue+"</th> <th>"+parameterValue+"</th> <th>"+maximalValue+"</th> </tr></thead> ";
	    Table_Body += "<tbody> <tr>";
	    Table_Body += "<td>" + TableCell[0] + "</td>";
	    Table_Body += "<td>" + TableCell[1] + "</td>";
	    Table_Body += "<td>" + TableCell[2] + "</td>";
	    Table_Body += "</tr> </tbody> </table> </div></div></div>";
	}
    $('#ParameterEditor_' + editorDivID).append(Table_Body);
    
    $('#Select_' + editorDivID).change(function(){
    	var currUnit = $(this).val();
    	ChangeDisplayUnit(editorDivID, hashmap[prevUnit], hashmap[currUnit], TableVal);
    });
}

var userVal = "";
function ChangeDisplayUnit(editorDivID, prevUnit, currUnit, Param_Val)
{
		if(userVal === ""){
			userVal = Param_Val.replace("...", " ");
			userVal = userVal.replace("...", " ");
			userVal = userVal.replace("...", " ");
		}
		
		var user_split = userVal.split('<');
     	 if(user_split[0].trim() === "" && user_split[1].trim() === "" && user_split[2].trim() === "")
    	 {
     		userVal = "";
            $('#Table_' + editorDivID).find("tbody tr td").each(function() {
            	userVal += $(this).text();
                // entering # results in crashing the web page. Return in this case instead of crash.
                if (userVal.indexOf('#') >= 0)
                    return;
                
                userVal += "< ";
            });
            
            userVal = userVal.substr(0, userVal.lastIndexOf("<"));
    	 }
     	
	     	var dataXMLPreference = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=convert&paramValues="+userVal+"&prevUnit=" + prevUnit + "&currUnit=" +currUnit);
			var rows1 	   = $(dataXMLPreference).find("r");
			var displayValues   = rows1[0].getAttribute('returnVaues');
			var display_val = displayValues.split(',');
    	 
		if(displayValues === "")
		{
			userVal = "";
		}
		else
		{
			var i = 0;
			 $('#Table_' + editorDivID).find("tbody tr td").each(function() {
				 if($(this).text().trim() !== "..." && $(this).text().trim() !== "")
				 {
					 $(this).text(display_val[i]);
					 i++;
				 }
		     });
		}
		 
			 ParametertableCellEdited = "1";
	         Edited_state = "1";
		 
}

function deleteParameterTable(editorDivID) {
    var tbl = document.getElementById('Table_' + editorDivID);
    if (tbl) tbl.parentNode.removeChild(tbl);

    var unit = document.getElementById('Unit_' + editorDivID);
    if(unit) unit.parentNode.removeChild(unit);
    
    hashmap = {};
    userVal = "";
    $('#ParameterEditor_' + editorDivID).css("display", "none");
}

//function to handle double click of cell in the table
function ParameterTableClick(editorDivID) {
    var Table = document.getElementById('Table_' + editorDivID);
    var Edited_state = "0";
    var OriginalContent = "";
    $('#Table_' + editorDivID).find("tbody tr td").dblclick(function() {
    	var val_check = $(this).siblings().text().trim();
    	if(stringCheck === "1" && $(this).text() === "...")
    	{
    		return;
    	}
    	else if(val_check.search("TRUE") > -1 || val_check.search("FALSE") > -1){
    		return;
    	}else{
	        if (Edited_state == "0") {
	            ParametertableCellEdited = "1";
	            Edited_state = "1";
	            OriginalContent = $(this).text();
	
	            $(this).addClass("cellEditing");
	            $(this).children().first().focus();
	            $(this).html("<input type='text' value='" + OriginalContent + "'>");
	            $(this).children().first().focus();
	
	            $(this).children().first().keypress(function(e) {
	                if (e.which == 13) {
	                    var newContent = $(this).val();
	                    $(this).parent().text(newContent);
	                    $(this).parent().removeClass("cellEditing");
	                }
	            });
	        }
    	}
        $(this).children().first().blur(function() {
            var newContent = $(this).val();
            if (newContent !== null && newContent !== undefined) {
                $(this).parent().html(newContent);
            } else {
                $(this).parent().html(OriginalContent);
            }
            Edited_state = "0";
            $(this).parent().removeClass("cellEditing");
        });
    });
    Table.width = '600px';
    Table.height = '600px';

}

function updateXMLWithParameterContent(strObjectId, Param_Val, displayUnit) {

    removeXMLWithRTFContent(strObjectId);
    //var editorDivID = strObjectId.replace(/\./g, '');
    var RTFRowObject = getElement("object");
    RTFRowObject.setAttribute("rowId", dataObjectRTFDict[strObjectId + '_id']);
    RTFRowObject
        .setAttribute("objectId", dataObjectRTFDict[strObjectId + '_o']);
    //RTFRowObject.setAttribute("relId", dataObjectRTFDict[strObjectId + '_r']);
    RTFRowObject.setAttribute("parentId", dataObjectRTFDict[strObjectId + '_p']);
    RTFRowObject.setAttribute("markup", "changed");
    RTFRowObject.setAttribute("level", "1");
    RTFRowObject.setAttribute("Param_Val", Param_Val);

    var RTFColumn = getElement("column");
    RTFColumn.setAttribute("name", "RichTextContent");
    RTFColumn.setAttribute("isRichTextColumnRMT", "true");
    RTFColumn.setAttribute("edited", "true");


    // Format | EncodedRichText | ContentText
    var contentText = oXML.createTextNode(Param_Val+":"+displayUnit);
    RTFColumn.appendChild(contentText);

    RTFRowObject.appendChild(RTFColumn);
    postDataXML.firstChild.appendChild(RTFRowObject);

    var rowToUpdate = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id='" + dataObjectRTFDict[
        strObjectId + '_id'] + "']");
    rowToUpdate.setAttribute('status', 'changed');

    // var rowChildList = rowToUpdate.childNodes;
    var nbColumns = 0;

    for (nbColumns = 0; nbColumns < colMap['columns'].length; nbColumns++) {
        if (colMap['columns'][nbColumns].settings['isRichTextColumnRMT'] == 'true') {
            break;
        }
    }
    //rowChildList[nbColumns].childNodes.reset();
    //rowChildList[nbColumns].childNodes.reset(); //ONLY FOR IE

    //rowChildList[nbColumns].appendChild(oXML.createTextNode(''));
    //rowChildList[nbColumns].setAttribute('edited', 'true');
    // rowChildList[nbColumns].setAttribute('d', '');
    //rowChildList[nbColumns].setAttribute('newA', '');
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/parameter.js global finish.");
}
