//=================================================================
// JavaScript ENORMTCusto.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
/* Contains non-rich text related code common to Form and Structure Display */
/*
 *                          MM:DD:YY
 * @quickreview T25  DJH 	10:25:13  : HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding tokens included.
 * @quickreview HAT1 DJH 	07:23:14  : Added Validation Column under Requirements and Test Cases.
 * @quickreview HAT1 ZUD 	08:13:14  : Added Validation Column under Requirement Specification and Chapter.
 * @quickreview JX5      	09:23:14  : Return all test cases for validation column in CATIA  
 * @quickReview ZUD      	10:10:14  : IR-333259-3DEXPERIENCER2015x Parameter value displayed in "Content" cell contains unexpected "null" values
 * @quickReview ZUD      	11:14:14  : HL ENOVIA GOV TRM Export to MS Word
 * @quickReview ZUD      	11:17:14  : HL ENOVIA GOV TRM Export to MS Word Code for Refresh of Table
 * @quickreview LX6      	12.18.14  : IR-341768-3DEXPERIENCER2016  No label is displayed on pop up dialogue box when user click on icons of the columns “Covered Requirements” and “Refining Requirements”
 * @quickreview JX5      	12:02:14  : IR-341738-3DEXPERIENCER2015x 
 * @quickreview ZUD	   		01:27:15  : Fix For IR-349181-3DEXPERIENCER2016x
 * @quickreview KIE1 ZUD 	02:13:15  : IR-333259-3DEXPERIENCER2016 Parameter value displayed in "Content" cell contains unexpected "null" values
 * @quickreview JX5  T94  	03:18:15  : Adapt to new level of jquery-ui and jquery-dialogextend for TMC project & IR-356589
 * @quickreview KIE1 ZUD 	04:13:15  : IR-362506-3DEXPERIENCER2016x: R417-033503: In "Parameter Edit View", invalid value for parameter display blank alert which is un-closable. ==> Replaced jAlert by alert.
 * @quickreview T94         04:13:15    : IR-365388-3DEXPERIENCER2015x : Loading content data KO for Requirement and comment object.
 * @quickreview KIE1 ZUD    04:22:15  : IR-364213-3DEXPERIENCER2016x : Issue on exporting the filtered objects of a specification to MS Word.
 * @quickreview KIE1 ZUD    04:27:15  : IR-364213-3DEXPERIENCER2016x : Worked on Performance
 * @quickreview KIE1 HAT1   05:28:15  : IR-362497-3DEXPERIENCER2016x : R417-033503: On structure view, Parameter Edit View UI need corrections.
 * @quickreview KIE1 ZUD    06:09:15  : IR-362506-3DEXPERIENCER2016x : R417-033503: In "Parameter Edit View", invalid value for parameter display blank alert which is un-closable.
 * @quickreview LX6         09:06:15  : IR-374998-3DEXPERIENCER2016x : When refining requirements, Change of relationship status of requirement in drop down menu is not getting saved properly.
 * @quickreview KIE1 ZUD    24:08:15  : IR-386290-3DEXPERIENCER2016x: PLM Parameter migration   
 * @quickreview HAT1 ZUD    15:10:12  : IR-398721-3DEXPERIENCER2017x: Any labels on the Test Case validation status  window are not translated.
 * @quickreview HAT1 ZUD    15:10:12  : IR-398727-3DEXPERIENCER2017x: R418-STP: Validation column does not display correct numbers for Testcases. 
 * @quickreview HAT1 ZUD    02:03:16  :  HL -  To enable Content column for Test Cases.  
 * @quickreview QYG         04:20:16  : IR-434537-3DEXPERIENCER2017x : Mislignment occurs after edit and save operation on content data
 * quickreview QYG          05:03:16    javascript refactoring, split from RichTextEditorCommon.js
 * @quickreview KIE1 ZUD    06:27:16  : IR-433967-3DEXPERIENCER2017x/ 14x: User must expand structure at least once for the Export to Word to include whole structure. Otherwise, it will just export what is on the screen.
 * @quickreview KIE1 ZUD     23:08:17  : IR-541421-3DEXPERIENCER2018x: Export to Word option Window is not translated.
 * @quickreview      ZUD     24:05:19  : IR-681470-3DEXPERIENCER2019x :3DEXPERIENCER2019x_Requirement Management: The whole structure is exported in spite of selecting option "Displayed Items".
 */
if(localStorage['debug.AMD']) {
	var _ENORMTCusto_js = _ENORMTCusto_js || 0;
	_ENORMTCusto_js++;
	console.info("AMD: ENORMTCusto/ENORMTCusto.js loading " + _ENORMTCusto_js + " times.");
}


define('DS/ENORMTCusto/ENORMTCusto', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCusto/ENORMTCusto.js dependency loaded.");
	}
	
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCusto/ENORMTCusto.js finish.");
	}	
	return {};
});

/**
 * Attach a JS script to a document, and run a function after the loading is completed
 * @param documentToAttach - the document to attach the script
 * @param scriptName - the path to the script
 * @param functionToRun - function for the callback
 */
function attachAndLoadScript(documentToAttach, scriptName, functionToRun) {
    var head = documentToAttach.getElementsByTagName('head')[0];
    var script = documentToAttach.createElement('script');

    script.type = 'text/javascript';
    script.src = scriptName;

    script.onload = functionToRun;
    head.appendChild(script);
}

function exportToWord() {
	 CheckPreferenceAndExport();
}

//Cehck Preference and Call Export
function CheckPreferenceAndExport()
{
	var value = "";
	 $.ajax({type: "GET",
	        url: "../requirements/RequirementUtil.jsp?mode=GetExportMode&timeStamp=" + rmt_timeStamp + "&" + csrfParams,
	        dataType: "text",
	        cache: false,
	        success: function(txt) {
	        	 var newpostDataXML = emxUICore.createXMLDOM();
	             newpostDataXML.loadXML(txt);
	             emxUICore.checkDOMError(newpostDataXML);
	             var valuePath = "/mxRoot/htmlContent/text()";
	         	value= emxUICore.selectSingleNode(newpostDataXML, valuePath).nodeValue;

	         	if(value == "RMC")
	         	{
	         		createWordDoc();
	         	}
	         	else if(value == "Tabular")
	         	{
	         		 // ONLY for IE
	         	    if (!isIE) {
	         	        alert(exportToWordForIE, 'Warning Export to Word');
	         	        return;
	         	    }
	         		exportRichTextData();
	         	}
	        }  
	      });
}
function ExportUserWord(word) 
{
	var rmm_rootObjIdSB = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0].getAttribute("o");
	
	// ++ KIE1 ZUD Fix for IR-364213-3DEXPERIENCER2016x.
	var objectsToExport = "";
	// If filteredObjetcs exist then only retrive object to export otherwise
	// export whole structure.
	
	if(word == "Display")
	{
		// ++ ZUD IR-681470-3DEXPERIENCER2019x ++
		var allFilterdObjectsList = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[ (not(@filter) or @filter != 'true') and ( count(ancestor::r[not(@display) or @display = 'none']) = '0')]");
			if (allFilterdObjectsList.length != 0) {
				for ( var j = 0; j < allFilterdObjectsList.length; j++) {
					objectsToExport += ":"+allFilterdObjectsList[j].getAttribute("id");
					}
				}
	}else{
		objectsToExport ="Whole";
		
	}
	
	  // -- KIE1 ZUD Fix for IR-364213-3DEXPERIENCER2016x.
    var rmm_rootObjIdExport = (typeof rmm_rootObjId == 'undefined') ? rmm_rootObjIdSB : rmm_rootObjId;
    //JX5 Widgetization HL
    var myWnd = showNonModalDialog("../requirements/RequirementUtil.jsp?mode=Aspose" + "&objectIdRoot="+ rmm_rootObjIdExport+"&objectsToExport=" + objectsToExport  + "&timeStamp=" + rmt_timeStamp + "&" + csrfParams,'','',false,true,'Small');
    //window.open("../requirements/RequirementUtil.jsp?mode=Aspose" + "&objectIdRoot="+ rmm_rootObjIdExport  + "&timeStamp=" + rmt_timeStamp + "&" + csrfParams);

}

//Export to Word RMC
function createWordDoc() 
{
	$.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
            function() {
                $('body', document).append("<div title='"+exportTOWordOption+"' id='ExportWordOption'></div>");
                var option = "";
                var flaotingOptions = {
                    resizable: [true, {
                        animate: true
                    }],
                    //height: 400,
                    width: 500,
                    "close": true,
                    "maximize": true,
                    "minimize": true,
                    "dblclick": 'maximize',
                    modal: true,
                    buttons: [{
                    	text : "Done",
                    	click: function() {
                    		
                    		if(document.getElementById('Displayed').checked)
                    		{
                    			option = "Display";
                    		}
                    		if(document.getElementById('Whole').checked)
                    		{
                    			option = "Whole";
                    		}
                    		
                    		ExportUserWord(option);
                    		currentJDialogEditor.dialog("close");
                    	}
                    	
                    }],
                    
                    close: function() {
                    	var tbl = document.getElementById('ExportWordOption');
                            if (tbl) tbl.parentNode.removeChild(tbl);
                            currentJDialogEditor.dialog("close");
                    }
                };

                var Table_Body = "<div><form action = ''> <input type='radio' name='option' id='Whole' checked> "+wholeStructure;
                Table_Body += "<input type='radio' name='option' id='Displayed'> "+diplayedItems+" </form> </div> ";
                
                $('#ExportWordOption').append(Table_Body);

                currentJDialogEditor = $('#ExportWordOption').dialog(flaotingOptions);
            });
    });
}


//function getPostDataXMLRTFData() {
//Moved to SBRichEdit.js

/* We have to use our own method to sync the rows.
 * Indeed, a user can put the RichText column in the treeRow side, and we have to consider this part.
 */
/*
 * doesn't seem to be used anywhere
function syncRowHeightsAfterEditRMT(rowId) {
    var nRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
    var curTreeRow = editableTable.tblTreeBody.rows.namedItem(rowId);
    var curTableRow = editableTable.tblListBody.rows.namedItem(rowId);

    if (curTreeRow == null || curTableRow == null)
        return;

    var newHeightToSet = Math.max(curTreeRow.offsetHeight, curTableRow.offsetHeight);
    curTreeRow.setAttribute("height", newHeightToSet);
    curTableRow.setAttribute("height", newHeightToSet); // Missing part in BPS code

    $(editableTable.tblTreeBody.rows.namedItem(rowId)).css('min-height', newHeightToSet);

    if (nRow) {
        nRow.setAttribute("height", newHeightToSet);
    }
}
*/

//function syncAllRowsSB()
//moved to dynatree.js


/* Returns the HTML content from a pure RTF content */
/* function getHTMLFromPureRTF(objectId, rtfContent) {
    $.ajax({
        url: "../requirements/RequirementUtil.jsp?mode=getHTMLFromRTF" + "&" + csrfParams,
        cache: false,
        processData: false,
        contentType: "text",
        type: "POST",
        data: RTF_FORMAT + '|' + objectId + '|' + rtfContent,
        dataType: HTML_FORMAT,
        success: function(html) {
            RTFEditedObjects[objectId + '_b'] = true;

            var editorDivID = objectId.replace(/\./g, '');
            $('#contentCell_' + editorDivID).html(html);
            RTFEditedObjects[objectId + '_d'] = $('#divRichTextContainer_' + editorDivID)[0].outerHTML;

            // Refresh the view
            rebuildView();
            turnOffProgress();
        }
    });
}
*/

//function checkMaxSize() {
//Moved to RichEditorCusto.js

function removeXMLWithRTFContent(strObjectId) {
    var nodesToTreat = postDataXML.firstChild.childNodes;
    var didYouRemoveSomething = false;

    for (var j = 0; j < nodesToTreat.length; j++) {
        var node = nodesToTreat[j];

        if (node.getAttribute("objectId") == dataObjectRTFDict[strObjectId + '_o']) {
            var nodesToTreatColumn = node.childNodes;
            for (var c = 0; c < nodesToTreatColumn.length; c++) {
                var columnToDelete = nodesToTreatColumn[c];

                if (columnToDelete.getAttribute("isRichTextColumnRMT") == 'true') {
                    node.removeChild(columnToDelete);
                    if (node.childNodes.length == 0) {
                        postDataXML.firstChild.removeChild(node);
                        didYouRemoveSomething = true;

                    }
                }
            }
        }
    }
    return didYouRemoveSomething;
}

//fcuntion checkErrorAfterApplyEdit() {
//Moved to RichTextEditorStructure.js

//function syncRCOContent()
//Moved to RichEditorCusto.js

//function getFloatingDiv()
//Moved to derivation.js



function findCurrentChannel(){
	  var returnedChannel = null;
	  var channel = window.parent;
	  if(channel.editableTable !=null&&channel.emxEditableTable!=null){
		  //The displayed channel is found
		  returnedChannel = channel;
	  }else{
		  //if not, we get the portal
		  var portal = findFrame(getTopWindow(),'portalDisplay');
		  if(portal!=null){
			  var nbFrames = portal.frames.length;
			  //And parse all channels
			  for(var i=0;i<nbFrames-1;i++){
				  fr = portal.frames[i];
				  if(fr.location.href!="about:blank"){
					  //we have founr the displayed one
					  returnedChannel=fr;
					  break;
				  }
			  }
		  }
	  }
	  return returnedChannel;
}


if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCusto/ENORMTCusto.js global finish.");
}
