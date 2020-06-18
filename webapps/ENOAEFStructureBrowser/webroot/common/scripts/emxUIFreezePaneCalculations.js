//=================================================================
// JavaScript emxUIFreezePaneCalculations.js - Requires: emxUICore.js,emxUIFreezePane.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//  static const char RCSID[] = $Id: emxUIFreezePaneCalculations.js.rca 1.4 Mon Dec 15 03:08:26 2008 ds-ukumar Experimental $
//=================================================================

//Calculated Rows


//Global Variables
var calculatedRowsObject = new Object();
var CURRENT = 0;
var LEAF = 0;
var LOOP_ROWID = "";
var LOCAL_DEC_PREC = null

/**
 * fpShowTableCalcOptions
 * @param {}
 */
 function fpShowTableCalcOptions() {
   var totNumobj = parseInt(totalObjectCount(false));
   if(totNumobj > 0) {
        showModalDialog("emxFreezePaneCalculationOptions.jsp?timeStamp=" + timeStamp,"550","600",true);
   }
 }


function addToCalculatedRowsObject(strCalcLabel,colName,colValue){
	if(calculatedRowsObject[strCalcLabel] == null){
		calculatedRowsObject[strCalcLabel] = new Object();
		calculatedRowsObject[strCalcLabel][colName] = colValue;
	}else{
		calculatedRowsObject[strCalcLabel][colName] = colValue;
	}
}

function getCalculatedRowColumVal(strCalcLabel,colName){
	if(calculatedRowsObject[strCalcLabel][colName] != null){
		return calculatedRowsObject[strCalcLabel][colName];
	}else{
		return "";
	}
}

function addCalculationExpr(colName,selFunction,strName,strLabel){
	for(var id=0; id<colMap.columns.length; id++) {
 		var theColumn = colMap.columns[id];
 		if(colName == theColumn.name){
	 		var calcExpr = theColumn.getSetting("Calculation Expression");
	 		var hasArithExpr = calcExpr != null && calcExpr != "";
	 		if(hasArithExpr){
 			if(colName.indexOf(' ')!=-1){
 				colName = colName.replace(/\W/g,"__");
 			}
	 			var strSettingVal = calcExpr;
	 			var strNewCalcExpr = colName + "[" + strName + "|" + strLabel + "]=" + selFunction + "(" +colName+")";
	 			if(calcExpr.indexOf(strNewCalcExpr) == -1){
	 				theColumn.setSetting("Calculation Expression", calcExpr + ";" + strNewCalcExpr);
	 			}
	 		}else{
 			if(colName.indexOf(' ')!=-1){
 				colName = colName.replace(/\W/g,"__");
 			}
	 			var strSettingVal = colName +"["+strName+"|"+strLabel+"]="+selFunction + "(" + colName+")";
	 			theColumn.setSetting("Calculation Expression",strSettingVal);
	 		}
 		}
	}
}

function clearCalculatedCalc(colName){
	for(var calc in calculatedRowsObject){
		if(calculatedRowsObject[calc][colName] != null){
			calculatedRowsObject[calc][colName] = null;
			var noldCalcRow = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@calc = 'true' and @label = \""+calc+"\"]");
			objColumn = colMap.getColumnByName(colName);
			objColumn.setSetting("Calculation Expression","");
			var colIndex = objColumn.index;
			var columnInfo = emxUICore.selectSingleNode(noldCalcRow, "c[" + colIndex + "]");
			columnInfo.setAttribute("a","");
			emxUICore.setText(columnInfo,"");
		}
	}
}

function removeCalculationRow(strCalcLabel){
	for(var calc in calculatedRowsObject){
		if(calc == strCalcLabel){
			for(var colName in calculatedRowsObject[calc]){
				calculatedRowsObject[calc][colName] = null;
				var noldCalcRow = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@calc = 'true' and @label = \""+strCalcLabel+"\"]");
				if(noldCalcRow){
					noldCalcRow.parentNode.removeChild(noldCalcRow);
				}
				objColumn = colMap.getColumnByName(colName);
				var calcExpr = objColumn.getSetting("Calculation Expression");
				var hasCalcExpr = calcExpr != null && calcExpr != "";
				arrNewCalcExpr = new Array();
		 		if(hasCalcExpr){
		 			var arrCalcExpr = calcExpr.split(";");
		 			for(var i=0; i<arrCalcExpr.length; i++) {
		 				var strCalcExpr = arrCalcExpr[i];
		 				if(strCalcExpr.indexOf(strCalcLabel) == -1){
		 					arrNewCalcExpr.push(strCalcExpr);
		 				}
		 			}
		 			var strNewCalcExpr = arrNewCalcExpr.join(";");
		 			if(strNewCalcExpr == null){
		 				strNewCalcExpr = "";
		 			}
		 			objColumn.setSetting("Calculation Expression",strNewCalcExpr);
		 		}
			}
		}
	}
}

function removeBlankCalcRows(){
	var nCalcRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@calc]");
	for(var i=0; i<nCalcRows.length; i++) {
		var nCalcRow = nCalcRows[i];
		var isRowBlank = true;
		for(var j=1; j<nCalcRow.childNodes.length; j++) {
			if(emxUICore.getText(nCalcRow.childNodes[j]) != ""){
				isRowBlank = false;
				break;
			}
		}
		if(isRowBlank){
			nCalcRow.parentNode.removeChild(nCalcRow);
		}
	}
}

function addCalculatedRow(strCalcName,strCalcLabel,colName,colValue){
	addToCalculatedRowsObject(strCalcLabel,colName,colValue);
	var nCalcXML = emxUICore.createXMLDOM();
	nCalcXML.loadXML("mxRoot");
	var nCalcRow = nCalcXML.createElement("r");
	nCalcRow.setAttribute("calc","true");
	nCalcRow.setAttribute("name",strCalcName);
	nCalcRow.setAttribute("label",strCalcLabel);
	nCalcRow.setAttribute("id","cal"+strCalcName);
	var noXMLRows = emxUICore.selectSingleNode(oXML,"/mxRoot/rows");
	var noldCalcRow = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@calc = 'true' and @label = \""+strCalcLabel+"\"]");

	if(noldCalcRow != null){
		var objColumn = colMap.getColumnByName(colName);
		var colIndex = objColumn.index;
		var columnInfo = emxUICore.selectSingleNode(noldCalcRow, "c[" + colIndex + "]");
		var celVal = getCalculatedRowColumVal(strCalcLabel,colName);
		columnInfo.setAttribute("a",celVal);
		emxUICore.setText(columnInfo,celVal);
	}else{
		for(var id=0; id<colMap.columns.length; id++) {
			var nCalcCell = nCalcXML.createElement("c");
			if(id == 0){
				nCalcCell.setAttribute("a",strCalcName);
				emxUICore.setText(nCalcCell,strCalcLabel);
			}else{
				var celVal = getCalculatedRowColumVal(strCalcLabel,colMap.columns[id].name);
				nCalcCell.setAttribute("a",celVal);
				nCalcCell.setAttribute("editMask","false");
				emxUICore.setText(nCalcCell,celVal);
			}
			nCalcRow.appendChild(nCalcCell);
		}
		noXMLRows.appendChild(nCalcRow);
	}
}

/**
 * buildColumValues
 * @param {}
 */
 function buildNumericColumValues(isfromFilter) {
	var oXMLRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[not(@calc) or @rg]");
	if(typeof isfromFilter != 'undefined' && isfromFilter){
		oXMLRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[(not(@calc) or @rg) and @filter ='false']");
	}
 	for(var id=0; id<colMap.columns.length; id++) {
 		var theColumn = colMap.columns[id];
		var hasCalcExpr = theColumn.getSetting("Calculation Expression") != null;
 		var hasArithExpr = theColumn.getSetting("Arithmetic Expression") != null;
 		var isNumeric = theColumn.getSetting("Data Type") == "numeric";
 		var colIndex = theColumn.index;

 		var hasRowGroupingCal=hasRowGroupingCalculation(theColumn);
 		if(isNumeric){
 			var colName = theColumn.name;

 			if(colName.indexOf(' ')!=-1 ){
 				colName = colName.replace(/\W/g,"__");
 			}

			var rgCountColArray;
			var rgVar;
			var rgCount=0;

			if(hasRowGroupingCal){
				rgCountColArray = [];
				eval(colName+"_rgVar = new Array();");
				rgVar=eval(colName+"_rgVar");
				rgVar["rg"]=[];
			}
 			eval(colName+" = new Array();")
 			eval(colName+"_1 = new Object();")
 			eval(colName+"_2 = new Object();")
 			eval(colName+"_2['child'] = new Object();")
  			eval(colName+"_2['parent'] = new Object();")
 			for(var i=0; i<oXMLRows.length; i++) {
 				var nRow = oXMLRows[i];
 				var rowId = nRow.getAttribute("id");
 				var level = nRow.getAttribute("level");
				var rowGroup;

				if(hasRowGroupingCal){
					rowGroup = nRow.getAttribute("rg");
					if(rowGroup)
					{
						nRow.setAttribute("calc","true");
						rgVar[(rgCount)]=[];
						rgCount++;
						var rowGroupCount = nRow.getAttribute("count");
						rgCountColArray.push(rowGroupCount);
						var nRGCell = emxUICore.selectSingleNode(nRow, "c[" + colIndex + "]");
						rgVar["rg"].push(nRGCell);
					}
					else if(rgCount > 0)
					{
						var nCell = emxUICore.selectSingleNode(nRow, "c[" + colIndex + "]");
						for(var rci=0;rci<rgCountColArray.length;rci++)
						{
							var count=parseInt(rgCountColArray[rci]);
							if(count > 0){
								rgVar[rci].push(nCell);
								rgCountColArray[rci]=(count-1);
							}
						}
					}
				}

 				if(LEAF < parseInt(level)){
 					LEAF = parseInt(level);
 				}

 				if(!rowGroup && (hasCalcExpr || hasArithExpr)){
					var nCells = emxUICore.selectNodes(nRow,"c");
					var cell = nCells[id];
					if(cell != null){
						var cellValue = emxUICore.getText(cell);
						if(cellValue == null || cellValue == "" || isNaN(cellValue)){
							cellValue = "0";
						}
						var colNameLinear = eval(colName);
						colNameLinear.push(cell);

						var colName2D = eval(colName+"_1["+level+"]");
						if(colName2D == null){
							eval(colName+"_1["+level+"] = new Array();");
						}
						colName2D = eval(colName+"_1["+level+"]");
						colName2D.push(cell);
					}
					eval(""+colName+"_2['child']['"+rowId+"'] = new Object();"+colName+"_2['parent']['"+rowId+"'] = new Object();");
					var cLevel = 1;
					var pLevel = 1;

					for(var k=parseInt(level)+1; k<LEAF+1; k++) {
						var colName3DChild = eval(colName+"_2['child']['"+rowId+"']['"+cLevel+"']");
						if(colName3DChild == null){
							eval(colName+"_2['child']['"+rowId+"']['"+cLevel+"'] = new Array();");
						}
						colName3DChild = eval(colName+"_2['child']['"+rowId+"']['"+cLevel+"']");

						var jukcolName = colName;
						if(colName.indexOf("__")!=-1){
							jukcolName = colName.replace("__"," ");
						}
						var arrTemp = emxEditableTable.getChildrenColumnValues(rowId,jukcolName,k);
						for(var m=0; m<arrTemp.length; m++) {
							var cell = arrTemp[m];
							colName3DChild.push(cell);
						}
						cLevel++;
						if(arrTemp == null || arrTemp.length == 0)
							break;
					}
					for(var l=1; l<parseInt(level)+1; l++) {
						var colName3DParent = eval(colName+"_2['parent']['"+rowId+"']['"+pLevel+"']");
						if(colName3DParent == null){
							eval(colName+"_2['parent']['"+rowId+"']['"+pLevel+"'] = new Array();");
						}
						colName3DParent = eval(colName+"_2['parent']['"+rowId+"']['"+pLevel+"']");
						var jukcolName = colName;
						if(colName.indexOf("__")!=-1){
							jukcolName = colName.replace("__"," ");
						}
						colName3DParent.push(emxEditableTable.getParentColumnValue(rowId,jukcolName,l));
						pLevel++;
					}
				}
			}
		}
 	}
 	parseArithmethicExpr();
 }

 var isAdvancedRGEnabled = emxUIConstants.ADVANCED_ROW_GROUPING_ENABLED;
 function hasRowGroupingCalculation(columnObj){
	 var hasRowGroupingCal=false;
	 if(isAdvancedRGEnabled){
		 var rgCalculation = columnObj.getSetting("RowGroupCalculation");
		 if(rgCalculation){
			 hasRowGroupingCal=true;
		 }
	 }
	 return hasRowGroupingCal;
 }

 function rowGroupCalc(objColumn){

	 var colName = objColumn.name;
	 if(colName.indexOf(' ')!=-1){
		 colName = colName.replace(/\W/g,"__");
	 }
	 var rgCalculation = objColumn.getSetting("RowGroupCalculation");

	 var rgVar = eval(colName+"_rgVar");
	 var tCellArr = rgVar["rg"];

	 var isNFEnabled = objColumn.getSetting("isNF");
	 var isPFEnabled = objColumn.getSetting("isPF");
	 var symbol = "%";

	 for(var ctr2=0;ctr2<tCellArr.length;ctr2++){
		 var result=executeRowGroupCalc(colName+"_rgVar["+ctr2+"]",colMap,rgCalculation);
		 if(result!="NAN"){

			 result = result+"";
			 if(isNFEnabled == "true"){
				 result = getFormattedNumber(result);
			 }
			 if(isPFEnabled == "true"){
				 if(result != "") result += symbol;
			 }
		 }
		 console.log(rgCalculation+" :"+result);
		 var tCell=tCellArr[ctr2];

		 if(typeof result != "undefined"){
			 tCell.setAttribute("editMask","false");
			 emxUICore.setText(tCell,result);
			 tCell.setAttribute("a",result);
		 }

	 }
 }

 function executeRowGroupCalc(colName,colMap,rgCalculation){
	 if("|SUM|AVE|MAX|MIN|MEDIAN|STDDEV|CUSTOMCALC|COUNT|".indexOf("|"+rgCalculation+"|")!=-1){
		 var result=eval(rgCalculation+"("+colName+")");
		 return result;

	 }else{
		 var expWithoutOperands = rgCalculation.replace(/[\/+()%*-]/g, '!');
		 var operandArray = expWithoutOperands.split("!");
		 operandArray = sortByLength(operandArray);

		 for ( var i=0; i<operandArray.length; i++) {
			 var operand = operandArray[i].trim();
			 var isOperandMissing = true;
			 if(operand!="" && isNaN(operand)){
				 var theColumn;
				 var isRGCalculationRequired = false;
				 var operandRGCal = "";
				 for(var id=0; id<colMap.columns.length; id++){
					 theColumn = colMap.columns[id];
					 if(theColumn.name==operand){
						 operandRGCal = theColumn.getSetting("RowGroupCalculation");
						 formateSetting = theColumn.getSetting("format");
						 if(operandRGCal && formateSetting=="numeric"){
							 isRGCalculationRequired = true;
							 isOperandMissing = false;
						 }
						 break;
					 }
				 }
				 if(isOperandMissing){
					 return "NAN";
				 }
				 if(isRGCalculationRequired){
					 var index = colName.split("_rg")[1];
					 var operandValue = executeRowGroupCalc(operand+"_rg"+index,colMap,operandRGCal);
					 if(operandValue!="NAN")
						 rgCalculation = rgCalculation.replace(new RegExp(operand, 'g'), operandValue);
					 else
						 return "NAN";
				 }
			 }
		 }
		 return eval(rgCalculation);
	 }
 }

 function sortByLength(inArray){
	 for ( var i=0; i<inArray.length; i++) {
		 for ( var j=i+1; j<inArray.length; j++) {
			 if(inArray[j].trim().length>inArray[i].trim().length){
				 var temp = inArray[i];
				 inArray[i] = inArray[j];
				 inArray[j] = temp;
			 }
		 }
	 }
	 return inArray;
 }

 function parseArithmethicExpr() {
 	var oXMLRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[not(@calc) or @rg]");
 	for(var id=0; id<colMap.columns.length; id++) {
 		var theColumn = colMap.columns[id];
 		var hasArithExpr = theColumn.getSetting("Arithmetic Expression") != null;
 		var hasCalcExpr = theColumn.getSetting("Calculation Expression") != null;
 		var isNumeric = theColumn.getSetting("Data Type") == "numeric";
 		var isPFEnabled = theColumn.getSetting("isPF");
 		var colDecPrec = parseInt(theColumn.getSetting("Decimal Precision"));
 		if(!isNaN(colDecPrec)){
 			LOCAL_DEC_PREC = colDecPrec;
 		}else if(!isNaN(DEC_PREC)){
 			LOCAL_DEC_PREC = DEC_PREC;
 		}

		if(hasRowGroupingCalculation(theColumn)){
			rowGroupCalc(theColumn);
		}

 		if(hasArithExpr || hasCalcExpr){
 			var colName = theColumn.name;

 			if(colName.indexOf(' ')!=-1){
 				colName = colName.replace(/\W/g,"__");
 			}

 			var strArithExpr = theColumn.getSetting("Arithmetic Expression");
 			var strCalcExpr = theColumn.getSetting("Calculation Expression");
 			if((strArithExpr == null || strArithExpr == "") && (strCalcExpr == null || strCalcExpr == "")){
 				continue;
 			}
 			if(strCalcExpr != null && strCalcExpr != ""){
 				if(strArithExpr != "")
 					strArithExpr += ";" + strCalcExpr;
 				else
 					strArithExpr = strCalcExpr;
 			}
 			var arrArithExpr = strArithExpr.split(";");
 			for(var i=0; i<arrArithExpr.length; i++) {
 				var strExpr = arrArithExpr[i];
 				var strLHS = null;
 				var strRHS = null;
 				if(strExpr.indexOf("=") > -1){
 					var strTemp = strExpr.split("=");
 					strLHS = strTemp[0];
 					strRHS = strTemp[1];
 				}else{
 					strLHS = "";
 					strRHS = strExpr;
 				}
 				if(strLHS == "" || strLHS == colName){
 					strLHS = colName+"[CURRENT]";
 				}
 				var reLHS = new RegExp("(\\w*)(\\[)(\\S*.*)(\\])");
 				reLHS.test(strLHS);
        		var colNameLHS = RegExp["$1"];
        		var levelExprLHS = RegExp["$3"];
        		var isNewRowToAdd = false;
        		var strCalcName = "";
        		var strCalcLabel = "";
        		if(levelExprLHS != null && levelExprLHS.indexOf("|") > -1){
        			isNewRowToAdd = true;
        			strCalcName = levelExprLHS.split("|")[0];
        			strCalcLabel = levelExprLHS.split("|")[1];
        		}
        		var arrLevelIndex = levelExprLHS.split(",");
				var reRHS = new RegExp("(SUM)|(AVE)|(MAX)|(MIN)|(MEDIAN)|(STDDEV)|(CUSTOMCALC)|(\\[CURRENT)(\\S*)(\\d)(\\])");
				var startIndex,endIndex;
				var levelBased = false;
				var isChild = true;
				var isOperatorUsed = false;
				var replaceToItemAt = true;
				var oprRHS = new RegExp("(SUM)|(AVE)|(MAX)|(MIN)|(MEDIAN)|(STDDEV)|(CUSTOMCALC)");
				if(oprRHS.test(strRHS)){
					isOperatorUsed = true;
				}
				if(reRHS.test(strRHS)){
					if(strRHS.indexOf("[CURRENT+") > -1){
						startIndex = 0;
						endIndex = oXMLRows.length;
						arrLevelIndex.push("!LEAF");
						levelBased = true;
						isChild = true;
					}else if(strRHS.indexOf("[CURRENT-") > -1){
						startIndex = 0;
						endIndex = oXMLRows.length;
						arrLevelIndex.push("!0");
						levelBased = true;
						isChild = false;
					}else if(strRHS.indexOf("!") > -1){
						var reIDX = new RegExp("(\\()(\\w*.*)(\\[)(\S*.*)(\\])");

 						var RHSList = strRHS.split(",");
 						for(var k =0; k< RHSList.length; k++){
 							var strTempRHS = RHSList[k];
 							var m = reIDX.exec(strTempRHS);
 							var value = strTempRHS;
 							if (m != null) {
								do{
									var colNameRHS = m[2];
			 						var strIdx = m[4];
			 						var strNotIdx = strIdx.substring(strIdx.indexOf("!")+1,strIdx.length);
			 						var objColumn = colMap.getColumnByName(colNameRHS);
				    				if(objColumn != null){
				    					var colIndex = objColumn.index;
				    					var xPath = "";
				    					var colName2D = null;
				    					if(strIdx == "!LEAF"){
							 				eval(colNameRHS+"_1['!LEAF'] = new Array();");
							 				colName2D = eval(colNameRHS+"_1['!LEAF']");

					 						xPath = "/mxRoot/rows//r[not(@calc) and @level != "+LEAF+"]";
				    					}else{
							 				eval(colNameRHS+"_1['!"+strNotIdx+"'] = new Array();");
							 				colName2D = eval(colNameRHS+"_1['!"+strNotIdx+"']");

					 						xPath = "/mxRoot/rows//r[not(@calc) and @level != "+strNotIdx+"]";
				    					}
				 						var notXMLRows = emxUICore.selectNodes(oXML.documentElement,xPath);
				 						for(var j=0; j< notXMLRows.length; j++) {
						 					var nRow = notXMLRows[j];
						 					var nCells = emxUICore.selectNodes(nRow,"c");
							 				var cell = nCells[colIndex-1];
							 				if(cell != null){
								 				colName2D.push(cell);
							 				}
						 				}
						 				strRHS = strRHS.replace("["+strIdx+"]","['"+strIdx+"']");
				    				}
									value = value.substring(m.index + 1,value.length);
									m = reIDX.exec(value);
								}while(m != null)
							}
 						}
 						startIndex = 0;
						endIndex = startIndex + 1;
						hasNotIndex = true;
					}else if(strRHS.indexOf("LEAF") > -1){
						startIndex = LEAF;
						endIndex = startIndex + 1;
						levelBased = false;
					}else if(strRHS.indexOf("LEAF-1") > -1){
						startIndex = LEAF -1;
						endIndex = startIndex + 1;
						levelBased = false;
					}else if(strRHS.indexOf("CONCAT") > -1){
						startIndex = 0;
						endIndex = oXMLRows.length;
						levelBased = false;
					}else{
						var reIndexRHS = new RegExp("(\\[)(\\d)(\\])");
						if(reIndexRHS.test(strRHS)){
							startIndex = parseInt(RegExp["$2"]);
							endIndex = startIndex + 1;
						}else{
							startIndex = 0;
							endIndex = startIndex + 1;
						}
						levelBased = false;
					}
					if(levelBased){
						for(var ix=0; ix<colMap.columns.length; ix++) {
							var strReplaceString = "";
							var reIndexRHS = new RegExp("(\\[CURRENT)(\\S*)(\\d)(\\])");
							reIndexRHS.test(strRHS);
							var curIndex = RegExp["$3"];
							var strToReplace = "";
							if(isChild){
								strReplaceString = colMap.columns[ix].name + "[CURRENT+"+curIndex+"]";
								strToReplace = colMap.columns[ix].name + "_2['child'][LOOP_ROWID]"+ "["+curIndex+"]";
								strRHS = strRHS.replace(strReplaceString,strToReplace);
							}else{
								strReplaceString = colMap.columns[ix].name + "[CURRENT-"+curIndex+"]";
								strToReplace = colMap.columns[ix].name + "_2['parent'][LOOP_ROWID]"+ "["+curIndex+"].itemAt(0)";
								strRHS = strRHS.replace(/\[CURRENT]/g,".itemAt(CURRENT)");
								strRHS = strRHS.replace(strReplaceString,strToReplace);
							}
						}
						replaceToItemAt = false;
					}else if(isNewRowToAdd){
						for(var j=0; j<colMap.columns.length; j++) {
							var strReplaceString = colMap.columns[j].name;
							var strToReplace = colMap.columns[j].name + "_1";
							//IR-018597
							if(strRHS.indexOf(strReplaceString+"[") > -1){
								strRHS = strRHS.replace(strReplaceString,strToReplace);
							}
						}
						replaceToItemAt = false;
					}
				}else{
					startIndex = 0;
					endIndex = oXMLRows.length;
					//366490
					if(levelExprLHS.indexOf("!") == -1 && !arrLevelIndex.contains("CURRENT")){
	        			for(var k=0; k<LEAF+1; k++) {
	        				if(k == LEAF && arrLevelIndex.contains("LEAF")){
		        				continue;
		        			}
		        			if(!arrLevelIndex.contains(""+k)){
		        				arrLevelIndex.push("!"+k);
		        			}
		        		}
	        		}
				}
				if(isChild){
					for(var idx = endIndex-1;idx >= startIndex; idx--){
	    				CURRENT = idx;
	    				LOOP_ROWID = oXMLRows[idx].getAttribute("id");

	    				if(replaceToItemAt){
	    					strRHS = strRHS.replace(/\[CURRENT]/g,".itemAt(CURRENT)");
	    					strRHS = strRHS.replace(/\[LEAF]/g,".itemAt(LEAF)");
	    					/*strRHS = strRHS.replace(/\W/g,"__");*/
	    				}

	    				var result;
	    				var currLevel = oXMLRows[idx].getAttribute("level");
	    				if(arrLevelIndex.contains("!"+currLevel)){
	    					continue;
	    				}else if(parseInt(currLevel) == LEAF && arrLevelIndex.contains("!LEAF")){
	    					continue;
	    				}else if(arrLevelIndex.contains(""+currLevel)){
	    					result = eval(strRHS);
	    				}else{
	    					result = eval(strRHS);
	    				}
	    				if(LOCAL_DEC_PREC != null && !isOperatorUsed && !isNaN(result)){
				    		result = Math.round(result*Math.pow(10, LOCAL_DEC_PREC))/Math.pow(10, LOCAL_DEC_PREC);
				    	}

	    				if(colNameLHS.indexOf("__")!=-1){
	    					colNameLHS = colNameLHS.replace("__"," ");
	    				}
	    				var objColumn = colMap.getColumnByName(colNameLHS);
	    				var colIndex = objColumn.index;

	    				result = result+"";
	    			    var formattedPart ="";
	    			    var isNFEnabled = objColumn.getSetting("isNF");
	    			    var isPFEnabled = objColumn.getSetting("isPF");
	    			    var symbol = "%";
	    			    if(isNFEnabled == "true"){
	    			    	formattedPart = getFormattedNumber(result);
	    			    }
	    			    if(isPFEnabled == "true"){
							if(formattedPart != "") formattedPart += symbol;
							if(result != "") result += symbol;
						}

	    				if (isNewRowToAdd) {
	    					if(isNFEnabled == "true"){
								addCalculatedRow(strCalcName,strCalcLabel,objColumn.name,formattedPart);
	    					}else{
							addCalculatedRow(strCalcName,strCalcLabel,objColumn.name,result);
	    					}
						} else {
							var tRow = oXMLRows[idx];
		    				var tCell = emxUICore.selectSingleNode(tRow, "c[" + colIndex + "]");
		    				if(typeof result != "undefined"){
		    					tCell.setAttribute("editMask","false");
		    					if(isNFEnabled == "true"){
		    						emxUICore.setText(tCell,formattedPart);
		    					}else{
			    				emxUICore.setText(tCell,result);
		    					}
			    				tCell.setAttribute("a",result);
		    				}
						}
	    			}
				}else{
					for(var idx = startIndex;idx < endIndex; idx++){
	    				CURRENT = idx;
	    				LOOP_ROWID = oXMLRows[idx].getAttribute("id");

	    				if(replaceToItemAt){
	    					strRHS = strRHS.replace(/\[CURRENT]/g,".itemAt(CURRENT)");
	    					strRHS = strRHS.replace(/\[LEAF]/g,".itemAt(LEAF)");
	    				}

	    				var result;
	    				var currLevel = oXMLRows[idx].getAttribute("level");
	    				if(arrLevelIndex.contains("!"+currLevel)){
	    					continue;
	    				}else if(parseInt(currLevel) == LEAF && arrLevelIndex.contains("!LEAF")){
	    					continue;
	    				}else if(arrLevelIndex.contains(""+currLevel)){
	    					result = eval(strRHS);
	    				}else{
	    					result = eval(strRHS);
	    				}
	    				if(LOCAL_DEC_PREC != null && !isOperatorUsed && !isNaN(result)){
				    		result = Math.round(result*Math.pow(10, LOCAL_DEC_PREC))/Math.pow(10, LOCAL_DEC_PREC);
				    	}else if(!isNaN(result)){
				    		result = Math.round(result*Math.pow(10, 13))/Math.pow(10, 13);
				    	}
	    				var objColumn = colMap.getColumnByName(colNameLHS);
	    				var colIndex = objColumn.index;

	    				result = result+"";
	    			    var formattedPart ="";
	    			    var isNFEnabled = objColumn.getSetting("isNF");
	    			    if(isNFEnabled == "true"){
	    			    	formattedPart = getFormattedNumber(result);
	    			    }

	    			    if(isPFEnabled == "true"){
							if(formattedPart != "")formattedPart += symbol;
							if(result != "")result += symbol;
						}

	    				if (isNewRowToAdd) {
	    					if(isNFEnabled == "true"){
								addCalculatedRow(strCalcName,strCalcLabel,objColumn.name,formattedPart);
	    					}else{
							addCalculatedRow(strCalcName,strCalcLabel,objColumn.name,result);
	    					}
						} else {
							var tRow = oXMLRows[idx];
		    				var tCell = emxUICore.selectSingleNode(tRow, "c[" + colIndex + "]");
		    				if(typeof result != "undefined"){
		    					tCell.setAttribute("editMask","false");
		    					if(isNFEnabled == "true"){
		    						emxUICore.setText(tCell,formattedPart);
		    					}else{
			    				emxUICore.setText(tCell,result);
		    					}
			    				tCell.setAttribute("a",result);
		    				}
						}
	    			}
				}

 			}
 		}
 	}
 }

/**
 * getNumericColumnValuesByLevel
 * @param {} colName,level
 */
 function getNumericColumnValuesByLevel(colName,level) {
 	if(level == "LEAF"){
 		var ctr = 0;
 		var tmpNumColVals = null;
 		while(numericColValues[colName][""+ctr] != null){
 			tmpNumColVals = numericColValues[colName][""+ctr];
 			ctr++;
 		}
 		return tmpNumColVals;
 	}else{
 		return numericColValues[colName][level];
 	}
 }


function SUM(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getSum(arrNumList);
	}else if(arguments.length > 1){
		return getSum(arguments);
	}else{
		return "";
	}
}

function AVE(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getAverage(arrNumList);
	}else if(arguments.length > 1){
		return getAverage(arguments);
	}else{
		return "";
	}
}

function MAX(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getMaximum(arrNumList);
	}else if(arguments.length > 1){
		return getMaximum(arguments);
	}else{
		return "";
	}
}

function MIN(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getMinimum(arrNumList);
	}else if(arguments.length > 1){
		return getMinimum(arguments);
	}else{
		return "";
	}
}

function MEDIAN(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getMedian(arrNumList);
	}else if(arguments.length > 1){
		return getMedian(arguments);
	}else{
		return "";
	}
}

function STDDEV(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return getStandardDeviation(arrNumList);
	}else if(arguments.length > 1){
		return getStandardDeviation(arguments);
	}else{
		return "";
	}
}

function CONCAT(){
	if(arguments != null && arguments.length > 0){
		var returnStr = "";
		for (var count = 0; count < arguments.length; count ++) {
			returnStr += arguments[count];
		}
		return returnStr;
	}else{
		return "";
	}
}

function CUSTOMCALC(colName,arrNumList){
	var theColumn = colMap.getColumnByName(colName);
	if(theColumn != null){
    	var customCalProSetting = theColumn.getSetting("Calculate Custom Program");
    	var customCalPro = customCalProSetting.split(":")[0];
    	var customCalFun = customCalProSetting.split(":")[1];
    	if(customCalPro && customCalFun && customCalPro.length >0 && customCalFun.length>0){
    		var aAllColVals = null;
    		for(var k=0;k<arrNumList.length;k++){
    			if(aAllColVals == null){
    				aAllColVals = emxUICore.getText(arrNumList[k]);
    			}else{
    				aAllColVals += "|~|" + emxUICore.getText(arrNumList[k]);
    			}
    		}
    	 	var url = "../common/emxFreezePaneGetData.jsp?fpTimeStamp="+ timeStamp+"&customCalProgram="+customCalPro+"&customCalFunction="+customCalFun;
	   		var sRtnValue = emxUICore.getDataPost(url,"columnValues="+aAllColVals);
	   		return sRtnValue;
    	}
	}
}

function COUNT(arrNumList){
	if(arrNumList != null && typeof arrNumList == "object" && arrNumList.length > 0){
		return arrNumList.length;
	}else{
		return "0";
	}
}

function getSum(arrNumList,decPresc){
	var count, len = arrNumList.length, val,sum = 0;
	var visibleRowIds = getDisplayRowIdsList();	
    for (count = 0; count < len; count ++) {
		if(manualExpand && arrNumList[count].parentNode && visibleRowIds.indexOf(arrNumList[count].parentNode.getAttribute('id')) == -1){
			continue;
		}		
    	if(typeof arrNumList[count] == "object"){
    		val = getNumericCellValue(arrNumList[count]);
    	}else{
    		val = arrNumList[count];
    	}
    	if(val == null || val == ""){
    		val = "0";
    	}
    	if(isNaN(parseFloat(val))){
    		return null;
    	}else{
    		sum += parseFloat(val);
    	}
    }
    if(decPresc == null){
    	if(LOCAL_DEC_PREC != null){
    		return Math.round(sum*Math.pow(10, LOCAL_DEC_PREC))/Math.pow(10, LOCAL_DEC_PREC);
    	}else{
    return sum;
}
    }else{
    	return Math.round(sum*Math.pow(10, decPresc))/Math.pow(10, decPresc);
    }
}
function getAverage(arrNumList,decPresc){
	var count, len = arrNumList.length, val,sum = getSum(arrNumList),avg = 0.0;
    if(sum == null){
    	return null;
    }else{
    	avg = sum/len;
    }
    if(decPresc == null){
    	if(LOCAL_DEC_PREC != null){
    		return Math.round(avg*Math.pow(10, LOCAL_DEC_PREC))/Math.pow(10, LOCAL_DEC_PREC);
    	}else{
    		return avg;
    	}
    }else{
    	return Math.round(avg*Math.pow(10, decPresc))/Math.pow(10, decPresc);
    }
}
function getMaximum(arrNumList){
	var count, len = arrNumList.length, val,max = null;
	if(typeof arrNumList[0] == "object"){
		max = getNumericCellValue(arrNumList[0]);
	}else{
		max = arrNumList[0];
	}
	var visibleRowIds = getDisplayRowIdsList();	
	 if(isNaN(max))
    	max = 0;
    for (count = 0; count < len; count ++) {
		if(manualExpand && arrNumList[count].parentNode && visibleRowIds.indexOf(arrNumList[count].parentNode.getAttribute('id')) == -1){
			continue;
		}		
    	if(typeof arrNumList[count] == "object"){
			val = getNumericCellValue(arrNumList[count]);
		}else{
			val = arrNumList[count];
		}
    	if( val && val == null && val == ""){
    		val = 0;
    	}
    	if(isNaN(parseFloat(val))){
    		continue;
    	}else if(parseFloat(val) > max){
    		max = parseFloat(val);
    	}
    }
    if(max == ""){
    	max = 0;
    }
    return max;
}
function getMinimum(arrNumList){
	var count, len = arrNumList.length, val,min = null;
	var visibleRowIds = getDisplayRowIdsList();	
	if(typeof arrNumList[0] == "object"){
		min = getNumericCellValue(arrNumList[0]);
	}else{
		min = arrNumList[0];
	}
    if(isNaN(min))
    	min = 0;
    for (count = 0; count < len; count ++) {
		if(manualExpand && arrNumList[count].parentNode && visibleRowIds.indexOf(arrNumList[count].parentNode.getAttribute('id')) == -1){
			continue;
		}		
    	if(typeof arrNumList[count] == "object"){
			val = getNumericCellValue(arrNumList[count]);
		}else{
			val = arrNumList[count];
		}
    	if( val && val == null || val == ""){
    		val = 0;
    	}
    	if(isNaN(parseFloat(val))){
    		continue;
    	}else if(parseFloat(val) < min){
    		min = parseFloat(val);
    	}
    }
    if(min == ""){
    	min = 0;
    }
    return min;
}
function getMedian(arrNumList){
	var count, len = arrNumList.length, val,median = 0.0,halfLen = (len+1)/2;
	if(arrNumList.length <= 2){
		return getAverage(arrNumList);
	}
	arrNumList = arrNumList.sort(sortNumber);
	var visibleRowIds = getDisplayRowIdsList();	
    for (count = 0; count < len; count ++) {
		if(manualExpand && arrNumList[count].parentNode && visibleRowIds.indexOf(arrNumList[count].parentNode.getAttribute('id')) == -1){
			continue;
		}		
    	if(typeof arrNumList[count] == "object"){
			val = getNumericCellValue(arrNumList[count]);
		}else{
			val = arrNumList[count];
		}
    	if(val && val == null || val == ""){
    		val = "0";
    	}
    	if(isNaN(parseFloat(val))){
    		return null;
    	}
    }
    var idx = parseInt(halfLen);
    if(idx != halfLen){
    	median = getAverage([arrNumList[idx-1],arrNumList[idx]]);
    }else{
    	var currIdxVal = null;
    	if(typeof arrNumList[idx - 1] == "object"){
			currIdxVal = getNumericCellValue(arrNumList[idx - 1]);
		}else{
			currIdxVal = arrNumList[idx - 1];
		}
    	median = parseFloat(currIdxVal);
    }
    if(isNaN(median)){
    	return "0";
    }else{
    return median;
}
}

function sortNumber(a,b)
{
	if(typeof a == "object"){
		a = emxUICore.getText(a);
	}
	if(typeof b == "object"){
		b = emxUICore.getText(b);
	}
	return a - b;
}

function getStandardDeviation(arrNumList,decPresc){
	var count, len = arrNumList.length, val,dev = 0.0,variance = 0.0,stdDev = 0.0,avg = getAverage(arrNumList);
		var visibleRowIds = getDisplayRowIdsList();
    for (count = 0; count < len; count ++) {
		if(manualExpand && arrNumList[count].parentNode && visibleRowIds.indexOf(arrNumList[count].parentNode.getAttribute('id')) == -1){
			continue;
		}		
    	if(typeof arrNumList[count] == "object"){
			val = getNumericCellValue(arrNumList[count]);
		}else{
			val = arrNumList[count];
		}
    	if(val == null || val == ""){
    		val = "0";
    	}
    	if(isNaN(parseFloat(val)) || avg == null){
    		return null;
    	}else{
    		dev += Math.pow((parseFloat(val) - avg), 2);
    	}
    }
    variance = dev / (len-1);
    stdDev = Math.sqrt(variance);
    if(isNaN(stdDev)){
    	return "0";
    }
    if(decPresc == null){
    	if(LOCAL_DEC_PREC != null){
    		return Math.round(stdDev*Math.pow(10, LOCAL_DEC_PREC))/Math.pow(10, LOCAL_DEC_PREC);
    	}else{
    		return stdDev;
    	}
    }else{
    	return Math.round(stdDev*Math.pow(10, decPresc))/Math.pow(10, decPresc);
    }
}

function getDisplayRowIdsList(){

	var visibleRowIds = new Array() ;
    var aDisplayRows = getDisplayRows();
    for(var i=0;i<aDisplayRows.length;i++){
        visibleRowIds.push(aDisplayRows[i].getAttribute("id"));
	}
	return visibleRowIds;
}


if (!Array.prototype.contains || !Array.prototype.itemAt) {

	Array.prototype.contains = function _array_contains(item){
		var count, len = this.length, val;
        for (count = 0; count < len; count ++) {
        	val = this[count];
        	if(val == item){
        		return true;
        	}
        }
        return false;
	}
	Array.prototype.itemAt = function _array_itemAt(index){
		if(this[index] != null){
			var val = emxUICore.getText(this[index]);
			if(isNaN(parseFloat(val))){
				return 0;
			}else{
				return parseFloat(val);
			}
		}else{
			return null;
		}
	}
}
