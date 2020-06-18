//=================================================================
// JavaScript TestCase.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
/*
 *                          MM:DD:YY
 * @quickreview HAT1 DJH 	07:23:14  : Added Validation Column under Requirements and Test Cases.
 * @quickreview HAT1 ZUD 	08:13:14  : Added Validation Column under Requirement Specification and Chapter.
 * @quickreview JX5      	09:23:14  : Return all test cases for validation column in CATIA  
 * @quickreview HAT1 ZUD    15:10:12  : IR-398721-3DEXPERIENCER2017x: Any labels on the Test Case validation status  window are not translated.
 * @quickreview HAT1 ZUD    15:10:12  : IR-398727-3DEXPERIENCER2017x: R418-STP: Validation column does not display correct numbers for Testcases. 
 * @quickreview HAT1 ZUD    02:03:16  :  HL -  To enable Content column for Test Cases.  
 * @quickreview QYG         05:03:16    javascript refactoring, split from RichTextEditorStructure.js
 * @quickreview KIE1 ZUD    18:03:20  : IR-580732-3DEXPERIENCER2018x: validation column of the Test Case wrongly at failed
 */
if(localStorage['debug.AMD']) {
	var _RMTTestCase_js = _RMTTestCase_js || 0;
	_RMTTestCase_js++;
	console.info("AMD: ENORMTCustoSB/TestCase.js loading " + _RMTTestCase_js + " times.");
}

define('DS/ENORMTCustoSB/TestCase', [
       'DS/ENORMTCustoSB/expandall' //test case expand
    ], 
	function(){
		return {};
	}
);


function getRootTestCaseCounts(currentImage, objectID) 
{
	var eSBoXML;
	if(isSBEmbedded){
		eSBoXML = window.oXML;
	}
	else{
		if(findFrame(getTopWindow(), "detailsDisplay")) {
			eSBoXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
		}
		else{
			eSBoXML = findFrame(getTopWindow(), "content").oXML;
		}
	}

	var firstLevelChildren = emxUICore.selectNodes(eSBoXML, "/mxRoot/rows//r[@level='1']");
	
	var columnIndex = parseInt($(currentImage).closest("td[position]").attr("position"));
	
	var v = [0, 0, 0, 0];
	var template, template0;
	
	for(var i = 0; i < firstLevelChildren.length; i++){
		var validationCell = jQuery(firstLevelChildren[i]).children('c').eq(columnIndex - 1);
		var validations = jQuery(validationCell).find("b");
		
		//HAT1 ZUD: IR-632456-3DEXPERIENCER2017x fix
		if(validations.length > 4)
			validations = jQuery(validationCell).find("b b");

		if(validations.length == 0) {
			validations = jQuery(validationCell).find("a");
		}
		if(validations.length == v.length) {
			for(var j = 0; j < v.length; j++){
				v[j] += parseInt(validations[j].innerHTML || validations[j].text);
				template = validationCell.attr('a'); 
			}
		}
		else{
			if(!template0){
				template0 = validationCell.attr('a'); 
			}
		}
	}
	if(template){
		var reg = /(.+title = ")\d+(.+<b>)\d+(.+title = ")\d+(.+<b>)\d+(.+title = ")\d+(.+<b>)\d+(.+title = ")\d+(.+<b>)\d+(.+)/;
		var result = template.replace(reg, '$1' + v[0] + '$2' + v[0] + '$3' +  v[1] + '$4' + v[1] + '$5' + v[2] + '$6' + v[2] + '$7' + v[3] + '$8' + v[3] + '$9' );
		document.getElementById("ValidationColumn_"+objectID).innerHTML = result;
	}
	else if(template0){
		document.getElementById("ValidationColumn_"+objectID).innerHTML = template0;
	}
	else{
		document.getElementById("ValidationColumn_"+objectID).innerHTML = "";
	}
}

//++ HAT1 : DJH - HL (Validation Column). Floating Div for Test Case Count in Requirements. 

//HAT1 : ZUD - IR-398721-3DEXPERIENCER2017x: Any labels on the Test Case validation status  window are not translated.
function testCaseNotValidatedList(currentImage, testCaseobjectNames, timeStampObject, convertorVersion) {
    var testCaseNotValidatedID = "testCaseNotValidated";
    //var testCaseFloatingDivTitle = "Test Cases - Not Validated";
    var testCaseFloatingDivTitle = TestCaseNotValidated;
    TestCaseFloatDiv(testCaseFloatingDivTitle, testCaseNotValidatedID, testCaseobjectNames);
}

function testCaseNotFulValidatedList(currentImage, testCaseobjectNames, timeStampObject, convertorVersion) {
    var testCaseNotFulValidatedID = "testCaseNotFulValidated";
    //var testCaseFloatingDivTitle = "Test Cases - Not Fully Validated";
    var testCaseFloatingDivTitle = TestCaseNotFullyValidated;
    TestCaseFloatDiv(testCaseFloatingDivTitle, testCaseNotFulValidatedID, testCaseobjectNames);
}

function testCaseValidationFailedList(currentImage, testCaseobjectNames, timeStampObject, convertorVersion) {
    var testCaseValidationFailedID = "testCaseValidationFailed";
    //var testCaseFloatingDivTitle = "Test Cases - Validation Failed";
    var testCaseFloatingDivTitle = TestCaseValidationFailed;
    TestCaseFloatDiv(testCaseFloatingDivTitle, testCaseValidationFailedID, testCaseobjectNames);
}


function testCaseValidationPassedList(currentImage, testCaseobjectNames, timeStampObject, convertorVersion) {
    var testCaseValidationPassedID = "testCaseValidationPassed";
    //var testCaseFloatingDivTitle = "Test Cases - Validation Passed";
    var testCaseFloatingDivTitle = TestCaseValidationPassed;

    TestCaseFloatDiv(testCaseFloatingDivTitle, testCaseValidationPassedID, testCaseobjectNames);
}

//Floating Div popup function for each hyper link in Validation column under Requirement.
function TestCaseFloatDiv(testCaseFloatingDivTitle, testCaseValidationID, testCaseobjectNames) {
        $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
            $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
                function() {
                    $('body', document).append("<div title='" + testCaseFloatingDivTitle +
                        "' id='TestCaseContainer_" + testCaseValidationID + "'></div>");

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
                                text: TestCaseTableButtonOK,
                                click: function() {
                                    var tbl = document.getElementById('TestCaseContainer_' +
                                        testCaseValidationID);
                                    if (tbl) tbl.parentNode.removeChild(tbl);
                                    currentJDialogEditor.dialog("close");
                                }

                            },

                            {
                                text: TestCaseTableButtonCancel,
                                click: function() {
                                    var tbl = document.getElementById(
                                        'TestCaseContainer_' +
                                        testCaseValidationID);
                                    if (tbl) tbl.parentNode.removeChild(tbl);
                                    currentJDialogEditor.dialog("close");
                                }
                            }
                        ],
                        close: function() {
                            var tbl = document.getElementById('TestCaseContainer_' +
                                testCaseValidationID);
                            if (tbl) tbl.parentNode.removeChild(tbl);
                            currentJDialogEditor.dialog("close");
                        }
                    };


                    var testCaseobjectList = testCaseobjectNames.slice(1, -1);
                    var TableCell = testCaseobjectList.split(",");
                    var Table_Body = "<table class=\"editableTable\" border='2' cellpadding='2' width='100%'> <thead> <tr class=\"ui-widget-header \"> <th>" + TestCaseTableHeader +"</th> </tr></thead> ";
                    Table_Body += "<tbody>";

                    for (var i = 0; i < TableCell.length; i++) {

                        Table_Body += "<tr>";
                        Table_Body += "<td>" + TableCell[i] + "</td>";
                        Table_Body += "</tr>";
                    }

                    Table_Body += " </tbody> </table> </div></div>";
                    $('#TestCaseContainer_' + testCaseValidationID).append(Table_Body);

                    currentJDialogEditor = $('#TestCaseContainer_' + testCaseValidationID).dialog(flaotingOptions);
                });
        });
    }
    //-- HAT1 : DJH - HL (Validation Column). Floating Div for Test Case Count in Requirements. 


//++ HAT1 : DJH  - HL (Validation Column). Popup of Last or Next Scheduled Test Execution under Test Case. 
function testExecutionPopUp(objectId, relId, parentOID) {
        var url = "../common/emxTree.jsp?emxSuiteDirectory=productline&relId=" + relId + "&parentOID=" +
            parentOID + "&suiteKey=ProductLine&objectId=" + objectId + "&jsTreeID=";
        window.showModalDialog(url);
    }
    //-- HAT1 : DJH  - HL (Validation Column). Popup of Last or Next Scheduled Test Execution under Test Case. 

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/TestCase.js loading global finish.");
}
