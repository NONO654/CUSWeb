/*
 * Generic Filtering for SB xml data BPS Component
 * bpsSBFilter.js
 * version 1.1
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * bpsSBFilter Object
 * Controls filtering of structure browser data via facets and or tags
 *
 * Requires:
 * emxUICore.js and other standard BPS common js libraries
 *
 */

var bpsSBFilter  = {
    autoFilterSetting : "Auto Filter",
    multiValueSeparator : "0x08 ",
    hasOwn: Object.prototype.hasOwnProperty, //filter out prototype in "for in" loops
    color_base_css: "color-chip", // this is the common css for colorizing
    color_css: ["blue",
                "green",
                "yellow",
                "red",
                "orange",
                "violet",
                "vermilion",
                "light-green",
                "light-yellow",
                "pink",
                "light-orange",
                "light-violet",
                "dark-blue",
                "dark-green",
                "light-brown",
                "maroon",
                "brown",
                "dark-violet",
                "dark-gray",
                "gray",
                "light-gray",
                "light-cyan",
                "bright-green",
                "light-blue"],
    colorFilterSetting : "Color Filter",
	colorFilterExpression : "Color Cue Expression", 
	colorFilterExpressionType : "Color Cue Expression Type", 
	colorFilterExpressionLabel: "Color Cue Label", 
	
    //start of public APIs.
    rebuildFacets: function (objXml) {  //initializes facets per column and apply existing selections if any.
        var selectionUpdates=null, colorColumnIndex=-1, bReset=false, aSBRows=null;
        this.__applyExistingAutoFilterSelections(objXml, selectionUpdates, colorColumnIndex, bReset, aSBRows);
    },
    resetFacets: function (objXml, aSBRows) {  //undo all user selections.
        var selectionUpdates=null, colorColumnIndex=-1, bReset=true;
        this.__applyExistingAutoFilterSelections(objXml, selectionUpdates, colorColumnIndex, bReset, aSBRows);
        if(calRowsPresent == "true"){
			buildNumericColumValues();
		}
    },
    processNewTagUserSelections: function (objXml, lastTag, aSBRows) {  //resets the filters on the row data based on the new user selections.
        var tmpObj = lastTag.object.split(",");
        lastTag.columnIndex = tmpObj[0];
        lastTag.valueIndex = tmpObj[1];
        lastTag.selectionByName = true;

        var colorColumnIndex=-1, bReset=false;
        this.__applyExistingAutoFilterSelections(objXml, lastTag, colorColumnIndex, bReset, aSBRows);
    },
    processNewUserSelections: function (objXml, selectionUpdates) {  //resets the filters on the row data based on the new user selections.
        var colorColumnIndex=-1, bReset=false, aSBRows=null;
        this.__applyExistingAutoFilterSelections(objXml, selectionUpdates, colorColumnIndex, bReset, aSBRows);
        if(calRowsPresent == "true"){
			buildNumericColumValues(true);
		}
    },
    applyFacetColors: function (objXml, columnIndex) {  //sets the column with color flag and applies color to the specific cell data.
        var selectionUpdates=null, bReset=false, aSBRows=null;
        this.__applyExistingAutoFilterSelections(objXml, selectionUpdates, columnIndex, bReset, aSBRows);
    },
    createTag: function (objXml, tagEventObject) {
        var sixw = this.__getSixW(tagEventObject, "predicate");

        var columnIndex = this.__getColumnIndex(objXml, sixw, true);
        var tagValue = tagEventObject.object;
        var objects = tagEventObject.subjects;
        this.__createTag(objXml, columnIndex, tagValue, objects);
        this.rebuildFacets(objXml);
    },
    removeTag: function (objXml, tagEventObject) {
        var sixw = this.__getSixW(tagEventObject, "predicate");
        var columnIndex = this.__getColumnIndex(objXml, sixw, false);
        var tagValue = tagEventObject.object;
        var objects = tagEventObject.subjects;
        this.__removeTag(objXml, columnIndex, tagValue, objects);
    },
    updateTag: function (objXml, tagEventObject) {
        var rows = emxUICore.selectNodes(objXml, "/mxRoot/rows//r[not(@calc) and not(@rg) and not(@status)]");
        var sixw = this.__getSixW(tagEventObject, "prev-predicate");
        var columnIndex = this.__getColumnIndex(objXml, sixw, false);
        var tagValue = tagEventObject.prev-object;
        var objects = tagEventObject.subjects;
        this.__removeTag(objXml, columnIndex, tagValue, objects, rows);

        sixw = this.__getSixW(tagEventObject, "new-predicate");
        tagValue = tagEventObject["new-object"];
        columnIndex = this.__getColumnIndex(objXml, sixw, true);
        this.__createTag(objXml, columnIndex, tagValue, objects, rows);
        this.rebuildFacets(objXml);
    },
    isDataRefined: function (objXml) {  //checks if refinements have been made to the xml.
        var columnChilds = emxUICore.selectNodes(objXml, "/mxRoot/columns/column[@userfiltered='true' or @colorize='yes']");
        if (columnChilds.length > 0) {
            return true;
        } else {
            return false;
        }
    },

    //start of private functions.
    __getSixW: function (tagEventObject, predicatePropertyName) {
    	var sixW;
    	var predicate = tagEventObject[predicatePropertyName];
    	if(predicate != null && predicate != ""){
    		sixW = tagEventObject.sixW + "/" + predicate;
    	} else {
    		sixW = tagEventObject.sixW;
    	}
    	return sixW;
    },
    __applyExistingAutoFilterSelections: function (objXml, selectionUpdates, colorColumnIndex, bReset, aSBRows) {
    	var colorFilterExpressionDef = this.__getColorFilterExpressionDefinition(objXml);
        //selectionUpdates-> [ {'columnIndex': 0, 'valueIndex': 0, 'select': true/false}, ...]
        var selections = null;
        if (!bReset && selectionUpdates != null) {
            selections = {};
            if(selectionUpdates.selectionByName != null){
            	selections["selectionByName"] = selectionUpdates.selectionByName;
            selections[selectionUpdates.columnIndex + "," + selectionUpdates.valueIndex] = selectionUpdates.select;
            }else{
            	selections["selectionByName"] = false;
            	for (var ix = 0; ix < selectionUpdates.length; ix++) {
                	var selObj = selectionUpdates[ix];
                	selections[selObj.columnIndex + "," + selObj.valueIndex] = selObj.select;
                }
            }
        }
        colorColumnIndex = colorColumnIndex != null && colorColumnIndex != -1 ? colorColumnIndex : null;
        var colorIndex = null;
        var uniqueValueList = {}; // map with column index as key and unique value
        var selectionMap = {};
        var columnChilds = this.__buildColMap(objXml);
        var colLen = columnChilds.length;
        for (var i = 0; i < colLen; i++) {
            var column = columnChilds[i].columnNode;
            var columnName = columnChilds[i].columnName;
            var columnIndex = columnChilds[i].columnIndex;
            if (colorColumnIndex != null) {
                if (colorColumnIndex == columnIndex) { //colorize button toggle on the same column
                    var yesOrNo = column.getAttribute("colorize") == "yes" ? "no" : "yes";
                    column.setAttribute("colorize", yesOrNo);
                    if (yesOrNo == "yes") {
                        colorIndex = columnIndex;
                    }
                } else { //uncolorize all other columns
                    column.setAttribute("colorize", "no");
                }
            } else if (column.getAttribute("colorize") == "yes") { //colorize same column
                colorIndex = columnIndex;
            }
            //global colorize flag
            var colorizeSetting = emxUICore.selectSingleNode(objXml, "/mxRoot/setting[@name='colorize']");
            if(colorizeSetting == null){
            	colorizeSetting = objXml.createElement("setting");
            	colorizeSetting.setAttribute("name", "colorize");
            	objXml.documentElement.appendChild(colorizeSetting);
            }
            if(colorIndex != null){
                emxUICore.setText(colorizeSetting, "yes")
            }
            else{
            	emxUICore.setText(colorizeSetting, "no")
            }
            uniqueValueList[columnIndex] = {};
            uniqueValueList[columnIndex]["__counter"] = 0;
            selectionMap[columnIndex] = [];
            var uniqueValues = emxUICore.selectSingleNode(column, "uniquevalues");
            if (uniqueValues != null) {
                var values = emxUICore.selectNodes(uniqueValues, "c");
                for (var j = 0; j < values.length; j++) {
                    var selected = values[j].getAttribute("selected");
                    var cellValue = getCellValue(values[j]); 
                    var color = values[j].getAttribute("facetColoring");
                    var prevcount = values[j].getAttribute("count");
                    if (selections != null) {
                        if (selections["selectionByName"] == false && this.hasOwn.call(selections, columnIndex + "," + j)) {
                            selected = selections[columnIndex + "," + j] ? "yes" : "no";
                        } else if (selections["selectionByName"] == true && this.hasOwn.call(selections, columnName + "," + cellValue)) {
                            selected = selections[columnName + "," + cellValue] ? "yes" : "no";
                        } else if (selected == null){
                        	selected = "no";
                        }
                        values[j].setAttribute("selected", selected);
                    }
                    if (selected == "yes") {
                        if (bReset) {
                            values[j].setAttribute("selected", "no");
                        } else {
                            selectionMap[columnIndex].push(cellValue);
                        }
                    }
                    var facetValue = this.__createFacetValueObject(values[j], 0, prevcount, color, cellValue);
                    uniqueValueList[columnIndex][cellValue] = facetValue;
                    uniqueValueList[columnIndex]["__counter"]++;
                }
                if (selections == null && bReset == false /* && colorIndex == null */) { //oXML changed due to expansion etc., need to recount
                    column.removeChild(uniqueValues);
                }
            }
            //mark xml column as this is needed for isRefined function below.
            if (selectionMap[columnIndex].length > 0) {
                column.setAttribute("userfiltered", "true");
            } else {
                column.setAttribute("userfiltered", "false");
            }
        }
        if (selections == null && !bReset && !colorIndex == null) {
            selectionMap = null;  //by setting to null; filter attribute will not be updated for performance.
        }
        this.__applyAutoFilterSelections(objXml, columnChilds, selectionMap, uniqueValueList, colorIndex, aSBRows, colorFilterExpressionDef);
    },
    __applyAutoFilterSelections: function (objXml, columnChilds, selectionMap, uniqueValueList, colorColumnIndex, aSBRows, colorFilterExpressionDef) {
        var columnIndexList = []; // columns and corresponding index that are auto filtered.
        var colLen = columnChilds.length;
        for ( var i = 0; i < colLen; i++) {
            columnIndexList.push(columnChilds[i].columnIndex);
        }
        if (selectionMap != null) {
            for (var key in selectionMap) {
                if (this.hasOwn.call(selectionMap, key)) {
                    if (selectionMap[key].length == 0) {
                        delete selectionMap[key];
                    }
                }
            }
        }
        var itemsFound = false;
        var rows = emxUICore.selectNodes(objXml, "/mxRoot/rows//r[not(@calc) and not(@rg) and not(@status)]");
        for (var i = 0; i < rows.length; i++) {
            var sbRowNode = (aSBRows != null) ? aSBRows[i] : null;
            var filtered = this.__processRow(objXml, rows[i], columnIndexList, uniqueValueList, selectionMap, false, colorColumnIndex, sbRowNode, colorFilterExpressionDef);
            if (!filtered) {
                itemsFound = true;
            }
        }
        //check if any user selections were filtered out by other selections; if so remove and repeat process.
        if (selectionMap != null && !itemsFound) {
            var redoFacets = false;
            for (var key in selectionMap) {
                if (this.hasOwn.call(selectionMap, key)) {
                    var selectedValues = selectionMap[key];
                    var updatedList = [];
                    for (var i = 0; i < selectedValues.length; i++) {
                        var cellValue = selectedValues[i];
                        var facetValue = uniqueValueList[key][cellValue];
                        if (facetValue != null) {
                            if (facetValue.count == 0 && facetValue.prevcount == 0) {
                                redoFacets = true;
                            } else {
                                updatedList.push(cellValue);
                            }
                        }
                    }
                    selectionMap[key] = updatedList;
                }
            }
            if (redoFacets) {
                for (var column in uniqueValueList) { //reset counts and then rebuild counts.
                    if (this.hasOwn.call(uniqueValueList, column)) {
                        var facetValues = uniqueValueList[column];
                        for (var key in facetValues) {
                            if (this.hasOwn.call(facetValues, key)) {
                                if (key == "__counter") {
                                    continue;
                                }
                                facetValues[key].count = 0;
                            }
                        }
                    }
                }
                this.__applyAutoFilterSelections(objXml, columnChilds, selectionMap, uniqueValueList, colorColumnIndex, aSBRows, colorFilterExpressionDef);
            }
        }
        // sort routine for AF values.
        var sortingDirection = 1;  //1=ascending; -1=descending.
        var sortFilterValues = function (facetValueA, facetValueB) {
                //sortingDirection: 1 for ascending; -1 for descending.
                //sortingType: date, integer or string(default).
                if (sortingType == "date") {
                    var cellElementA = facetValueA.node;
                    var cellElementB = facetValueB.node;
                    return (parseInt(cellElementA.getAttribute("msValue")) > parseInt(cellElementB.getAttribute("msValue"))) ? sortingDirection : sortingDirection * -1;
                } else {
                    var cellValueA = facetValueA.cellValue;
                    var cellValueB = facetValueB.cellValue;
                    if (sortingType == "integer") {
                        return (parseFloat(cellValueA) > parseFloat(cellValueB)) ? sortingDirection : sortingDirection * -1;
                    } else {
                        return (cellValueA > cellValueB) ? sortingDirection : sortingDirection * -1;
                    }
                }
            };

        for (var j = 0; j < colLen; j++) {
            var colIndex = columnChilds[j].columnIndex;
            var column = columnChilds[j].columnNode;
            var uniqueValues = emxUICore.selectSingleNode(column, "uniquevalues");
            var appendFacets = false;
            if (uniqueValues == null) {
                appendFacets = true;
                // create xml element for holding unique values per column.
                uniqueValues = objXml.createElement("uniquevalues");
                uniqueValues.setAttribute('index', colIndex);
                column.appendChild(uniqueValues);
            }
            // apply counts.
            var filterValues = [];
            var filterFacets = uniqueValueList[colIndex];
            for (var key in filterFacets) {
                if (this.hasOwn.call(filterFacets, key)) {
                    if (key == "__counter") {
                        continue;
                    }
                    var valueCount = filterFacets[key].count;
                    filterFacets[key].node.setAttribute("count", valueCount);
                    if (appendFacets) {
                        filterValues.push(filterFacets[key]);
                    }
                }
            }
            if (appendFacets) { // sort AF range xml elements
                var sortingType = emxUICore.selectSingleNode(column, "settings/setting[@name = 'Sort Type']");
                if (sortingType != null) {
                    sortingType = emxUICore.getText(sortingType).toLowerCase();
                }
                if (sortingType == "real") {
                    sortingType = "integer";
                }
                filterValues.sort(sortFilterValues);
                for (var i = 0; i < filterValues.length; i++) {
                    var cellElement = filterValues[i].node;
                    uniqueValues.appendChild(cellElement);
                }
            }
        }
    },
    __processRow: function (objXml, row, columnIndexList, uniqueValueList, selectionMap, secondPass, colorColumnIndex, sbRow, colorFilterExpressionDef) {
        // process row.
        var cellNodes = emxUICore.selectNodes(row, "c");
        //Added for color filtering.
        var filter = false; // i.e. show by default.
        var selfFilteredColIndex = -1;
        if (selectionMap != null) {
            for (var colIndex in selectionMap) {
                if (this.hasOwn.call(selectionMap, colIndex)) {
                    var cellValues = null;
                    var cellNode = this.__getCellNode(cellNodes, colIndex);
                    if (cellNode != null) {
                    	var cellValueCalculated = colorFilterExpressionDef[colIndex].translate(cellNode); 
                        var cellValue = cellValueCalculated.cellValue;
                        if (cellValue != null) {
                            cellValues = cellValue.split(this.multiValueSeparator);
                        } else {
                        	//cellValues = [""];
                        	cellValues = [];
                        }
                    } else {
                        //cellValues = [""];
                        cellValues = [];
                    }
                    var selectedValues = selectionMap[colIndex];
                    var matched = false;
                    for (var i = 0; i < cellValues.length; i++) {
                        var cellValue = cellValues[i];
                        if (this.__findInArray(selectedValues, cellValue) != -1) {
                            matched = true;
                            break;  //matched at least one item in list.
                        }
                    }
                    if (!matched) {
                        if (filter == false) { // hide row.
                            filter = true;
                            selfFilteredColIndex = colIndex;
                        } else {
                            selfFilteredColIndex = -1;
                            break;
                        }
                    }
                }
            }
            if (!secondPass) {
                if (sbRow != null) {
                    this.__setRowFilter(sbRow, filter);
                }
                this.__setRowFilter(row, filter);
            }
        }
        if (selfFilteredColIndex != -1 || filter == false) {
            for (var j = 0; j < columnIndexList.length; j++) {
                var colIndex = columnIndexList[j];
                if (selfFilteredColIndex != -1 && colIndex != selfFilteredColIndex) {
                    continue;
                }
                var cellValues = null;
                var cellValuesActual = {};
                var isMultiVal = getTopWindow().sb.colMap.columns[colIndex].getSetting("isMultiVal")== "true" ? true:false;
                var cellNode = this.__getCellNode(cellNodes, colIndex);
                if (cellNode != null) {
                    var cellValueCalculated = colorFilterExpressionDef[colIndex].translate(cellNode); 
                    var cellValue = cellValueCalculated.cellValue;
                    if (cellValue != null) {
                        cellValues = cellValue.split(this.multiValueSeparator);
                        cellValuesActual[cellValue] = cellNode.getAttribute("a");
                    } else {
                    	cellValues = [];
                    }
                } else {
                    cellValues = [];
                }
                for (var i = 0; i < cellValues.length; i++) {
                    var cellValue = cellValues[i];
                    var facetNode = uniqueValueList[colIndex][cellValue];
                    if (facetNode == null) {
                    	//Modified color calculation logic for colorization filter capability
                        var color = "";//this.__generateFacetColor(uniqueValueList[colIndex]["__counter"]);
                        if(cellValueCalculated.color !== null){
                        	color = cellValueCalculated.color;
                        }else{
                        	color = this.__generateFacetColor(uniqueValueList[colIndex]["__counter"]);
                        }
                        
                        var clonedCell = null;
                        if (cellNode == null) {
                            clonedCell = objXml.createElement("c");
                            emxUICore.setText(clonedCell, "");
                        } else {
                            clonedCell = cellNode.cloneNode(true);

                            if(isMultiVal){
    	                    	clonedCell.setAttribute("a",cellValue);
    	                    }
                            emxUICore.setText(clonedCell, cellValue); 

                            if (cellValues.length > 1) {
                            	clonedCell.firstChild.nodeValue = cellValue;
                            }
                        }
                        facetNode = this.__createFacetValueObject(clonedCell, 1, 0, color, cellValue);
                        uniqueValueList[colIndex][cellValue] = facetNode;
                        uniqueValueList[colIndex]["__counter"]++;
                        clonedCell.setAttribute("facetColoring", color);
                    } else { // incr count.
                        facetNode.count++;
                    }
                    if (!secondPass && colorColumnIndex == colIndex && filter == false) {
                        var color = facetNode.color;
                        /* disable column colorization
                        if (cellNode != null) {
                            cellNode.setAttribute("facetColoring", color); //turn on facet coloring for cell.
                        }
                        */
                        var firstColCellNode = this.__getCellNode(cellNodes, 0); //always set facet coloring on first column
                        if (firstColCellNode != null) {
                        	firstColCellNode.setAttribute("facetColoring", color); 
                        }
                    }
                }
                if(cellValues.length == 0 && !secondPass &&  colorColumnIndex == colIndex && filter == false){
                    var cellNode = cellNode = this.__getCellNode(cellNodes, 0); //unset leftover facet coloring from other column
                    if (cellNode != null) {
                        cellNode.setAttribute("facetColoring", ""); 
                    }
                }
            }
        }
        if (!secondPass && colorColumnIndex != null && filter == true) {
        	/* disable column colorization
            var cellNode = this.__getCellNode(cellNodes, colorColumnIndex);
            if (cellNode != null) {
                cellNode.setAttribute("facetColoring", ""); //turn off facet coloring for filtered cell.
            }
            */
            var cellNode = cellNode = this.__getCellNode(cellNodes, 0); //unset facet coloring on first column
            if (cellNode != null) {
                cellNode.setAttribute("facetColoring", ""); 
            }
        }
        return filter;
    },
    
   
    __getColorFilterExpressionDefinition: function(objXml){
    	 var Interval = function (){
    			this.lowerBound = null;
    			this.upperBound =  null;
    			this.lowerBoundInclusive = false;
    			this.upperBoundInclusive = false;
    	};
    	Interval.prototype.match = function(value){
			return (this.lowerBoundInclusive ? value >= this.lowerBound : value > this.lowerBound) &&
						(this.upperBoundInclusive ? value <= this.upperBound : value < this.upperBound);
    	};
    	var NumericIntervalSet = function(expression, label){
    		var sub = expression.split('|');
			this.intervals = [];
			expression = sub[0];
			this.color = sub[1] ? bpsSBFilter.color_base_css + " " + sub[1] : null;
			if(label && label.trim().length > 0){
				this.label = label;
			}
			else{
				this.label = expression;
			}
			if(expression.toLowerCase() === "__other__"){
				this.isOther = true;
				return;
			}
			var fields = expression.split(":");
			for(var i = 0; i < fields.length; i++){
				var interval = new Interval();
				var field = fields[i].trim();
				if(field.indexOf(',') >= 0){
					var bounds = field.split(',');
					var LB = bounds[0].trim();
					var UB = bounds[1].trim();
					if(LB.length > 0){
						if(LB.indexOf('[') == 0){
							interval.lowerBoundInclusive = true;
							LB = LB.substr(1);
						}
						else if(LB.indexOf('(') == 0){
							LB = LB.substr(1);
						}
						if(LB.length > 0){
							interval.lowerBound = parseFloat(LB);
						}
						else{
							interval.lowerBound = Number.NEGATIVE_INFINITY;
						}
					}
					if(UB.indexOf(']') >= 0){
						interval.upperBoundInclusive = true;
						UB = UB.slice(0, -1);
					}
					else if(UB.indexOf(')') >= 0){
						UB = UB.slice(0, -1);
					}
					if(UB.length > 0){
						interval.upperBound = parseFloat(UB);
					}
					else{
						interval.upperBound = Number.POSITIVE_INFINITY;
					}
				}else{
					if(field.indexOf('!') >= 0){
						var v = parseFloat(field.substr(1));
						interval.lowerBound = Number.NEGATIVE_INFINITY;
						interval.upperBound = v;
						this.intervals.push(interval);
						interval = new Interval();
						interval.lowerBound = v;
						interval.upperBound = Number.POSITIVE_INFINITY;
					}
					else{
						interval.lowerBoundInclusive = interval.upperBoundInclusive = true;
						interval.lowerBound = interval.upperBound = parseFloat(field);
					}
				}
				this.intervals.push(interval);
			}
    	};
    	NumericIntervalSet.prototype.match = function(cellNode){
    		if(this.isOther){
    			return true;
    		}
	    	var cellValue = getCellValue(cellNode);
    		var found = false;
    		if(!isNaN(cellValue) && cellValue !== ""){
	    		for(var i = 0; i < this.intervals.length; i++){
	    			if(this.intervals[i].match(cellValue)){
	    				found = true;
	    				break;
	    			}
	    		}
    		}
    		return found;
    	};
    	NumericIntervalSet.prototype.translate = function(){
    		return {
    			"cellValue": this.label,
    			"color": this.color
    		};
    	};

    	var DateIntervalSet = function(expression, label){
    		var sub = expression.split('|');
			this.intervals = [];
			expression = sub[0];
			this.color = sub[1] ? bpsSBFilter.color_base_css + " " + sub[1] : null;
			if(label && label.trim().length > 0){
				this.label = label;
			}
			else{
				this.label = expression;
			}
			if(expression.toLowerCase() === "__other__"){
				this.isOther = true;
				return;
			}
			var fields = expression.split(":");
			for(var i = 0; i < fields.length; i++){
				var interval = new Interval();
				var field = fields[i].trim();
				if(field.indexOf(',') >= 0){
					var bounds = field.split(',');
					var LB = bounds[0].trim();
					var UB = bounds[1].trim();
					if(LB.length > 0){
						if(LB.indexOf('[') == 0){
							interval.lowerBoundInclusive = true;
						}
						if(LB.indexOf('[') == 0 || LB.indexOf('(') == 0){
							LB = LB.substr(1);
						}
						if(LB.length > 0){
							interval.lowerBound = new Date(Date.parse(LB));
						}
						else{
							interval.lowerBound = new Date(Date.UTC(0, 0, 0));
						}
						if(!interval.lowerBoundInclusive){
							interval.lowerBound.setDate(interval.lowerBound.getDate() + 1)
							interval.lowerBoundInclusive = true;
						}
					}
					if(UB.indexOf(']') >= 0){
						interval.upperBoundInclusive = true;
					}
					if(UB.indexOf(']') >= 0 || UB.indexOf(')') >= 0){
						UB = UB.slice(0, -1);
					}
					if(UB.length > 0){
						interval.upperBound = new Date(Date.parse(UB));
					}
					else{
						interval.upperBound = new Date(Date.UTC(10000, 0, 0));
					}
					if(interval.upperBoundInclusive){
						interval.upperBound.setDate(interval.upperBound.getDate() + 1)
						interval.upperBoundInclusive = false;
					}
				}else{
					if(field.indexOf('!') >= 0){
						var v = new Date(Date.parse(field.substr(1)));
						interval.lowerBound = new Date(Date.UTC(0, 0, 0));
						interval.upperBound = v;
						this.intervals.push(interval);
						interval = new Interval();
						interval.lowerBound = new Date(v);
						interval.lowerBound.setDate(interval.lowerBound.getDate() + 1) 
						interval.lowerBoundInclusive = true;
						interval.upperBound = new Date(Date.UTC(10000, 0, 0));
					}
					else{
						interval.lowerBoundInclusive = true;
						interval.lowerBound = new Date(Date.parse(field));
						interval.upperBoundInclusive = false;
						interval.upperBound = new Date(Date.parse(field));
						interval.upperBound.setDate(interval.lowerBound.getDate() + 1) 
					}
				}
				this.intervals.push(interval);
			}
    	};
    	DateIntervalSet.prototype.match = function(cellNode){
    		if(this.isOther){
    			return true;
    		}
	    	var cellValue = cellNode.getAttribute("msValue"); //getCellValue(cellNode);
    		var found = false;
    		if(cellValue != null && !isNaN(cellValue)){
    			cellValue = new Date(parseInt(cellValue));
	    		for(var i = 0; i < this.intervals.length; i++){
	    			if(this.intervals[i].match(cellValue)){
	    				found = true;
	    				break;
	    			}
	    		}
    		}
    		return found;
    	};
    	DateIntervalSet.prototype.translate = function(){
    		return {
    			"cellValue": this.label,
    			"color": this.color
    		};
    	};
    	
    	var StringValueSet = function(expression, label){
    		var sub = expression.split('|');
			this.set = [];
			expression = sub[0];
			this.color = sub[1] ? bpsSBFilter.color_base_css + " " + sub[1] : null;
			if(label && label.trim().length > 0){
				this.label = label;
			}
			else{
				this.label = expression;
			}
			if(expression.toLowerCase() === "__other__"){
				this.isOther = true;
				return;
			}
			var fields = expression.split(",");
			for(var i = 0; i < fields.length; i++){
				var field = fields[i].trim();
				this.set.push(field);
			}
    	};
    	StringValueSet.prototype.match = function(cellNode){
    		if(this.isOther){
    			return true;
    		}
	    	var cellValueActual = cellNode.getAttribute("a");
    		var found = false;
    		for(var i = 0; i < this.set.length; i++){
    			if(this.set[i] == cellValueActual){
    				found = true;
    				break;
    			}
    		}
    		return found;
    	};
    	StringValueSet.prototype.translate = function(cellNode){
	    	var cellValue = getCellValue(cellNode);
    		return {
    			"cellValue": this.set.length == 1 ? cellValue : this.label, 
    			"color": this.color
    		};
    	};
    	
    	var RegExSet = function(expression, label){
    		var sub = expression.split('#');
			this.regex = null;
			expression = sub[0];
			this.color = sub[1] ? bpsSBFilter.color_base_css + " " + sub[1] : null;
			
			if(expression.trim().toLowerCase() === "__other__"){
				this.isOther = true;
				if(label && label.trim().length > 0){
					this.label = label;
				}
				else{
					this.label = expression.trim();
				}
				return;
			}
			if(expression.trim()){
				expression = expression.trim().split('@');
				this.regex = new RegExp(expression[0], expression[1]);
			}
			if(label && label.trim().length > 0){
				this.label = label;
			}
			else{
				this.label = this.regex + "";
			}
       	};
    	RegExSet.prototype.match = function(cellNode){
    		if(this.isOther){
    			return true;
    		}
	    	var cellValueActual = cellNode.getAttribute("a");
    		return this.regex.test(cellValueActual);
    	};
    	RegExSet.prototype.translate = function(){
    		return {
    			"cellValue": this.label,
    			"color": this.color
    		};
    	};
    	
    	var ColumnColorExpressionDef = function(type, expressions, labels){
    		this.hasExpression = false;
			this.type = type;
			this.entries = [];
			switch(type.toLowerCase()){
			case "string": 
				for(var i = 0; i < expressions.length; i ++){
					this.entries.push(new StringValueSet(expressions[i], labels[i]));
				}
				this.hasExpression = this.entries.length > 0;
				this.entries.push({ //no expression match
					match: function(){
						return true;
					},
					translate: function(cellNode){
						return {
			    			"cellValue": getCellValue(cellNode), //no value translation
			    			"color": "" //no color
						};
					}
				});
				break;
			case "numeric":
				for(var i = 0; i < expressions.length; i ++){
					this.entries.push(new NumericIntervalSet(expressions[i], labels[i]));
				}
				this.hasExpression = this.entries.length > 0;
				this.entries.push({ //no expression match
					match: function(){
						return true;
					},
					translate: function(cellNode){
						return {
			    			"cellValue": null, //ignore this unique value
			    			"color": "" //no color
						};
					}
				});
				break;
			case "date":
				for(var i = 0; i < expressions.length; i ++){
					this.entries.push(new DateIntervalSet(expressions[i], labels[i]));
				}
				this.hasExpression = this.entries.length > 0;
				this.entries.push({ //no expression match
					match: function(){
						return true;
					},
					translate: function(cellNode){
						return {
			    			"cellValue": null, //ignore this unique value
			    			"color": "" //no color
						};
					}
				});
				break;
			case "regex":
				for(var i = 0; i < expressions.length; i ++){
					this.entries.push(new RegExSet(expressions[i], labels[i]));
				}
				this.hasExpression = this.entries.length > 0;
				this.entries.push({ //no expression match
					match: function(){
						return true;
					},
					translate: function(cellNode){
						return {
			    			"cellValue": null, //ignore this unique value
			    			"color": "" //no color
						};
					}
				});
				break;
			default: //no expressoin defined. 
				this.entries.push({
					match: function(){
						return true;
					},
					translate: function(cellNode){
						return {
			    			"cellValue": getCellValue(cellNode), //no value translation
			    			"color": null //return null for autogenerated color
						};
					}
				});
			}
    	};
    	
    	ColumnColorExpressionDef.prototype.translate = function(cellNode){
			for(var i = 0; i < this.entries.length; i++) {
				if(this.entries[i].match(cellNode)){
					return  this.entries[i].translate(cellNode);
				}
			}
		};
		
        var columnsTable = emxUICore.selectNodes(objXml,"/mxRoot/columns//column");
    	var columnColorExpressions = [];
    	for(p = 0; p < columnsTable.length; p++){
    		var expressions = emxUICore.selectSingleNode(columnsTable[p], "settings/setting[@name='"+this.colorFilterExpression+"']/text()");
    		var type = emxUICore.selectSingleNode(columnsTable[p], "settings/setting[@name='"+this.colorFilterExpressionType+"']/text()");
    		var labels = emxUICore.selectSingleNode(columnsTable[p], "settings/setting[@name='"+this.colorFilterExpressionLabel+"']/text()");
    		if(expressions !== null){
    			expressions = emxUICore.getText(expressions);
    		}
    		else{
    			expressions = "";
    		}
    		if(type !== null){
    			type = emxUICore.getText(type);
    		}
    		else{
    			type = "";
    		}
    		if(labels !== null){
    			labels = emxUICore.getText(labels);
    		}
    		else{
    			labels = "";
    		}
    		if(expressions !== null){
    			columnColorExpressions[p] = new ColumnColorExpressionDef(type, expressions.split(';'), labels.split(";"));
    		}
    	}
    	return columnColorExpressions;
    	
    },
    __getCellNode: function (cellNodes, colIndex) {
        var cellNode = null;
        if (colIndex < cellNodes.length) {
            cellNode = cellNodes[colIndex];
        }
        return cellNode;
    },
    __createFacetValueObject: function (node, count, prevcount, color, cellValue) {
        var facetValue = {
            "node": node,
            "count": count,
            "prevcount": prevcount,
            "color": color,
            "cellValue": cellValue
        };
        return facetValue;
    },
    __findInArray: function (arr, item) { //find an item in an array
        var len = arr.length;
        for (var i = 0; i < len; i++) {
            if (arr[i] === item) {
                return i;
            }
        }
        return -1;
    },
    __setRowFilter: function (row, bFilter) {
        if (bFilter) { // hide row.
            row.setAttribute('filter', 'true');
        } else { // show row.
            row.setAttribute('filter', 'false');
            this.__showParent(row);
        }
    },
    __showParent: function (row) {
        var parent = row.parentNode;
        var filter = parent.getAttribute('filter');
        if (filter != null && filter != "false") {
            parent.setAttribute('filter', 'false');
            this.__showParent(parent);
        }
    },
    __generateFacetColor: function (index) {
        var classIndex = index % this.color_css.length;
        return this.color_base_css + " " + this.color_css[classIndex];
    },
    __buildCol: function (index, cNode) {
        return {
            columnIndex:index,
            columnName:cNode.getAttribute('name'),
            columnNode:cNode
        };
    },
    __buildColMap: function (objXml) {
        var colObj = [];
        var columnChilds = emxUICore.selectNodes(objXml, "/mxRoot/columns/column");
        var colLen = columnChilds.length;
        for ( var i = 0; i < colLen; i++) {
            var setting = emxUICore.selectSingleNode(columnChilds[i],
                    "settings/setting[@name = '" + this.autoFilterSetting + "']/text()");
            if (setting != null && setting.nodeValue.toLowerCase() == "true") {
                colObj.push(this.__buildCol(i,columnChilds[i]));
            }
        }
        return colObj;
    },
    __getColumnIndex: function (objXml, sixw, bCreate) {
        //check if column already exist; return index of the column.
        var index = -1;
        var columnName = sixw + "/"; //slash for consistency w/sbtagdata service.
        var columnChilds = this.__buildColMap(objXml);
        for (var i = 0; i < columnChilds.length; i++) {
            var name = columnChilds[i].columnName;
            if (name == columnName) {
                index = i;
                break;
            }
        }
        if (index == -1 && bCreate) {
            //create new column.
            index = columnChilds.length;
            var templateColumnNode = columnChilds[0].columnNode;
            var clonedColumnNode = templateColumnNode.cloneNode(true);
            clonedColumnNode.setAttribute("name", columnName);
            var uniqueValues = emxUICore.selectSingleNode(clonedColumnNode, "uniquevalues");
            if (uniqueValues != null) {
                clonedColumnNode.removeChild(uniqueValues);
            }
            var setting = emxUICore.selectSingleNode(clonedColumnNode, "settings/setting[@name = 'sixw']/text()");
            if (setting != null) {
                setting.nodeValue = sixw;
            }
            //clonedColumnNode.setAttribute("label", predicateLabel);
            //todo: should set format setting to text.

            var columnsNode = emxUICore.selectSingleNode(objXml, "/mxRoot/columns");
            columnsNode.appendChild(clonedColumnNode);
        }
        return index;
    },
    __createTag: function (objXml, columnIndex, tagValue, objects, rows) {
        if (rows == null) {
            rows = emxUICore.selectNodes(objXml, "/mxRoot/rows//r[not(@calc) and not(@rg) and not(@status)]");
        }
        for (var i = 0; i < rows.length; i++) {
            var rowId = rows[i].getAttribute("o");
            if (this.__findInArray(objects, rowId) != -1) {
                var cellNodes = emxUICore.selectNodes(rows[i], "c");
                var cellNode = this.__getCellNode(cellNodes, columnIndex);
                if (cellNode != null) {
                    var cellValue = getCellValue(cellNode);
                    if(cellValue != null){
                        cellValues = cellValue.split(this.multiValueSeparator);
                        if (this.__findInArray(cellValues, tagValue) == -1) {
                            cellValue += this.multiValueSeparator + tagValue;
                            cellNode.firstChild.nodeValue = cellValue;
                        }
                    } else {
                    	emxUICore.setText(cellNode, tagValue);
                    }
                } else {
                    for (var j = cellNodes.length; j < columnIndex; j++) { //append place holders.
                        var blankCell = objXml.createElement("c");
                         emxUICore.setText(blankCell, "");
                        //var textNode = document.createTextNode(tagValue);
                        //blankCell.appendChild(textNode);
                        rows[i].appendChild(blankCell);
                    }
                    var newCell = objXml.createElement("c");
                    emxUICore.setText(newCell, tagValue);
                    //var textNode = document.createTextNode(tagValue);
                    //newCell.appendChild(textNode);
                    rows[i].appendChild(newCell);
                }
            }
        }
    },
    __removeTag: function (objXml, columnIndex, tagValue, objects, rows) {
        if (columnIndex == -1) {
            return;
        }
        if (rows == null) {
            rows = emxUICore.selectNodes(objXml, "/mxRoot/rows//r[not(@calc) and not(@rg) and not(@status)]");
        }
        for (var i = 0; i < rows.length; i++) {
            var rowId = rows[i].getAttribute("o");
            if (this.__findInArray(objects, rowId) != -1) {
                var cellNodes =  emxUICore.selectNodes(rows[i], "c");
                var cellNode = this.__getCellNode(cellNodes, columnIndex);
                if (cellNode != null) {
                    var cellValue = getCellValue(cellNode);
                    cellValues = cellValue.split(this.multiValueSeparator);
                    var newValues = [];
                    for (var j=0; j < cellValues.length; j++) {
                        var value = cellValues[j];
                        if (value != tagValue) {
                            newValues.push(value);
                        }
                    }
                    cellValue = newValues.join(this.multiValueSeparator);
                    cellNode.firstChild.nodeValue = cellValue;
                }
            }
        }
    }
};
