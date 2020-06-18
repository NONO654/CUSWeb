/*
 * Widget Filter APIs
 * bpsWidgetFilter.js
 * version 0.7
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
var bpsWidgetFilter = {
    //start of public APIs.
    applyFacetColors: function (widgetRoot, columnIndex) {  //sets the column with color flag and applies color to the specific cell data.
        var bReset=false;
        this.__processSelections(widgetRoot, columnIndex, bReset);
    },
    //start of Tag specific functions.
    rebuildTagFacets: function (widgetRoot) {  //initializes facets per column and apply existing selections if any.
        bpsWidgetFilter.__getTagData(widgetRoot);
        var colorFieldIndex=-1, bReset=false;
        this.__processSelections(widgetRoot._tagData, colorFieldIndex, bReset);
    },
    resetTagFacets: function (widgetRoot) {  //undo all user selections.
        bpsWidgetFilter.__getTagData(widgetRoot);
        var found = this.__resetTags(widgetRoot);
        //var found = bpsWidgetFilter.__hasTagSelection(widgetRoot._tagData);
        if (found) {
            var colorFieldIndex=-1, bReset=true;
            this.__processSelections(widgetRoot._tagData, colorFieldIndex, bReset);
        }
        return found;
    },
    createTag: function (widgetRoot, tagEventObject) {
        var sixw = this.__getSixW(tagEventObject, "predicate");
        var columnIndex = this.__getExplicitTagFieldIndex(widgetRoot._tagData, sixw, true);
        var tagValue = tagEventObject.object;
        var objects = tagEventObject.subjects;
        this.__createTag(widgetRoot._tagData, columnIndex, tagValue, objects);
        this.rebuildTagFacets(widgetRoot);
    },
    removeTag: function (widgetRoot, tagEventObject) {
        var sixw = this.__getSixW(tagEventObject, "predicate");
        var columnIndex = this.__getExplicitTagFieldIndex(widgetRoot._tagData, sixw, false);
        var tagValue = tagEventObject.object;
        var objects = tagEventObject.subjects;
        this.__removeTag(widgetRoot._tagData, columnIndex, tagValue, objects);
    },
    processNewTagUserSelections: function (widgetRoot, allfilters) {  //applies the new tags after re-setting all previous ones.
        var found = false
        if (widgetRoot._tagData) {
            found = this.__resetTags(widgetRoot);
            for (var sixwlist in allfilters) {
                if (allfilters.hasOwnProperty(sixwlist)) {
                    var tags = allfilters[sixwlist];
                    for (var i=0; i < tags.length; i++) {
                        var tag = tags[i];
                        var fields = tag.field;
                        for (var j=0; j < fields.length; j++) {
                            var field = fields[j];
                            found = this.__updateTagSelection(widgetRoot._tagData, field, tag.object, true);
                        }
                    }
                }
            }
            //var tmpObj = lastTag.object.split(",");
            //found = this.__updateTagSelection(widgetRoot._tagData, tmpObj[0], tmpObj[1], lastTag.select);
            if (found) {
                var colorFieldIndex=-1, bReset=false;
                this.__processSelections(widgetRoot._tagData, colorFieldIndex, bReset);
            }
        }
        return found;
    },
    keywordSearch: function (widgetRoot, searchStr, callbackFunction) {
        //undo previous search.
        var updates = bpsWidgetFilter.__undoKeywordSearch(widgetRoot);

        if (searchStr != null && searchStr != "") {
            var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, false);  //get all data records regardless of filter.
            if (rows == null || rows.length == 0) {
                return;
            }
            var postData = bpsWidgetFilter.__getTagPostData(widgetRoot, rows) + "&searchStr=" + searchStr;

            var thisTagRequest = {
                callbackFunction: callbackFunction,
                widgetRoot: widgetRoot
            }
            var keywordSearchDone = function (data) {
                bpsWidgetFilter.__processSearchResults(thisTagRequest.widgetRoot, data);
                thisTagRequest.callbackFunction.call(this, thisTagRequest.widgetRoot);
            };
            var searchURL = "/resources/bps/widgettagdata/search";
            bpsWidgetAPIs.ajaxRequest({url: searchURL, type: 'post', dataType: 'json', data: postData, callback: keywordSearchDone});
        } else if (updates) {
            callbackFunction.call(this, widgetRoot);
        }
    },
    loadTagData: function (widgetRoot, callbackFunction) {
        if (bpsWidgetFilter._bUseWidgetDataAsTagData) {
            widgetRoot._tagData = widgetRoot;
            bpsWidgetFilter.rebuildTagFacets(widgetRoot);
            callbackFunction.call(this, widgetRoot);
        } else {
            var rows = bpsWidgetAPIs.getContainerData(widgetRoot);
            if (rows == null || rows.length == 0) {
                return;
            }
            var postData = bpsWidgetFilter.__getTagPostData(widgetRoot, rows);

            var thisTagRequest = {
                callbackFunction: callbackFunction,
                widgetRoot: widgetRoot,
                rows: rows
            }

            var loadTagDataDone = function (data) {
                bpsWidgetFilter.__processTagData(thisTagRequest.widgetRoot, data, thisTagRequest.rows);
                thisTagRequest.callbackFunction.call(this, thisTagRequest.widgetRoot);
            }
            var tagURL = "/resources/bps/widgettagdata";
            bpsWidgetAPIs.ajaxRequest({url: tagURL, type: 'post', dataType: 'json', data: postData, callback: loadTagDataDone});
        }
    },
    showObjects: function(widgetRoot, filteredSubjectList) {
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot._tagData, null, null, false);  //get all data records regardless of filter.
        if (rows == null) {
            return;
        }
        var field = this.__getObjectIdField(widgetRoot);

        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            var objectId = row.objectId;
            var filter = true;
            if (bpsWidgetAPIs.__findInArray(filteredSubjectList, objectId) != -1) {
                filter = false;
                if (field["_selectionsCount"] > 0) {
                    var facetObject = field["_uniqueValuesObject"][objectId];
                    if (facetObject != null && facetObject.selected == false) {  //should not be null.
                        filter = true;  //filtered out due to mis-match search criteria.
                    }
                }
            }
            this.__setRowFilter(row, filter);
        }
    },
    buildTagSummaryData: function (widgetRoot){
        bpsWidgetFilter.__getTagData(widgetRoot);

        var summaryData = [];
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot._tagData);
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            var field = fields[fieldIndex];
            if (field.name == "_objectId") {
                continue;
            }
            var facetList = field["_uniqueValuesObject"]._orderedList;
            for (var j = 0; j < facetList.length; j++) {
                var facetObject = facetList[j];
                if (facetObject.count > 0) {
                    var summary = {
                        "object": facetObject.label,
                        "dispValue": facetObject.label,
                        "sixw": field.sixw != null ? field.sixw : "DS6W_Who/DS6W_IsResponsibleOf",
                        "field": field.label,
                        "count": facetObject.count
                    };
                    summaryData.push(summary);
                }
            }
        }
        return summaryData;
    },
    buildTagObjectData: function (widgetRoot, tagRoot) {
        bpsWidgetFilter.__getTagData(widgetRoot, tagRoot);

        var tagData = {};
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot._tagData, null, null, true);  //get filtered records.
        if (rows == null) {
            //tagData.objectCount = 0;
            return tagData;
        }
        //tagData.objectCount = rows.length;

        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot._tagData);
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            tags = [];

            for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                var field = fields[fieldIndex];
                if (field.name == "_objectId") {
                    continue;
                }
                var dataelement = this.__getDataElement(field, row);
                var values = dataelement.value;
                if (values == null) {
                    continue;
                }
                for (var j = 0; j < values.length; j++) {
                    var value = values[j];
                    var label = this.__getValueLabel(value);
                    if (label == "") {
                        continue;
                    }
                    //workaround for prefix change
                    field.sixw = field.sixw.replace(/DS6W_/g, "ds6w:");
                    if(field.sixw.indexOf("ds6w:W") == 0){
                    	field.sixw = field.sixw.replace(/ds6w:W/, "ds6w:w");
                    }
                    if(field.sixw.indexOf("ds6w:H") == 0){
                    	field.sixw = field.sixw.replace(/ds6w:H/, "ds6w:h");
                    }
                    tag = {
                        "object": label,
                        "dispValue" : label,
                        "sixw": field.sixw,
                        "field": field.label
                    };
                    tags.push(tag);
                }
            }
            tagData[row.objectId] = tags;
        }
        return tagData;
    },
    //start of private variables & functions.
    color_base_css: "color-chip", // this is the common css for colorizing
    color_css: ["color-icon01Color-d55e00", "color-icon02Color-0072b2",
                "color-icon03Color-f0e442", "color-icon04Color-cc79a7",
                "color-icon05Color-009e73", "color-icon06Color-56b4e9",
                "color-icon07Color-ff0000", "color-icon08Color-00ff00",
                "color-icon09Color-9e45ff", "color-icon10Color-e69f00",
                "color-icon11Color-00573e", "color-icon12Color-c9c272",
                "color-icon13Color-b8002f", "color-icon14Color-00ffff",
                "color-icon15Color-7293a4", "color-icon16Color-662d91",
                "color-icon17Color-dedede", "color-icon19Color-0000eb",
                "color-icon19Color-6a2f00", "color-icon20Color-898989",
                "color-icon21Color-ff00ff", "color-icon22Color-9e9000",
                "color-icon23Color-a20059", "color-icon24Color-f86c04",
                "color-icon25Color-363636", "color-icon26Color-ffa1a1",
                "color-icon27Color-9e3100"],
    hasOwn: Object.prototype.hasOwnProperty, //filter out prototype in "for in" loops
    _bUseWidgetDataAsTagData: false,
    __getTagData: function (widgetRoot, tagData) {
        if (widgetRoot._tagData == null && tagData != null) {  //this is only necessary for PRG timeline.
            var rows = bpsWidgetAPIs.getContainerData(widgetRoot.widgets[0]);
            bpsWidgetFilter.__processTagData(widgetRoot.widgets[0], tagData, rows);
            widgetRoot._tagData = widgetRoot.widgets[0]._tagData;
        }
    },
    __resetTags: function (widgetRoot) { //remove all previous tag selections.
        var found = false
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot._tagData);
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            field = fields[fieldIndex];
            if (field.name == "_objectId") {
                continue;
            }
            if (field["_selectionsCount"] > 0) {
                found = true;
                var facetList = field["_uniqueValuesObject"]._orderedList;
                for (var j = 0; j < facetList.length; j++) {
                    var facetObject = facetList[j];
                    //reset selections per facet.
                    facetObject["prevcount"] = 0;
                    facetObject["count"] = 0;
                    facetObject["selected"] = false;
                }
            }
        }
        return found;
    },
    __undoKeywordSearch: function (widgetRoot) {
        //remove all previous found ids and refilter the widget.
        var field = this.__getObjectIdField(widgetRoot);
        if (field["_selectionsCount"] > 0) {
            var facetList = field["_uniqueValuesObject"]._orderedList;
            for (var j = 0; j < facetList.length; j++) {
                var facetObject = facetList[j];
                //reset selections per facet.
                facetObject["prevcount"] = 0;
                facetObject["count"] = 0;
                facetObject["selected"] = false;
            }
            bpsWidgetFilter.rebuildTagFacets(widgetRoot);
            return true;
        }
        return false;
    },
    __getObjectIdField: function (widgetRoot) {
        var field = null;
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot._tagData);
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            field = fields[fieldIndex];
            if (field.name == "_objectId") {
                break; //found object id field.
            }
        }
        return field;
    },
    __processSearchResults: function (widgetRoot, searchData) {
        //apply found ids as selections.
        var field = this.__getObjectIdField(widgetRoot);
        var searchWidget = searchData.widgets[0];
        var searchRows = bpsWidgetAPIs.getContainerData(searchWidget);
        for (var i = 0; i < searchRows.length; i++) {
            var row = searchRows[i];
            var objectId = row.objectId;
            var facetObject = field["_uniqueValuesObject"][objectId];
            if (facetObject != null) {
                facetObject.selected = true;
            }
        }
        bpsWidgetFilter.rebuildTagFacets(widgetRoot);
    },
    __processTagData: function (widgetRoot, tagData, rows) {
        //merge tag data into widget data.
        var tagRoot = tagData.widgets[0];
        widgetRoot._tagData = tagRoot;
        var tagrows = bpsWidgetAPIs.getContainerData(tagRoot);
        for (var i = 0; i < tagrows.length; i++) {
            var tagrow = tagrows[i];
            bpsWidgetAPIs.__appendTagInfo(rows[i], tagrow);
        }
        bpsWidgetAPIs.__appendTagInfo(widgetRoot, tagRoot);  //append tag fields to widget fields.
        tagRoot["datarecords"] = widgetRoot["datarecords"];
        tagRoot["widgets"] = widgetRoot["widgets"];

        if (widgetRoot.widgetType == "channel") {
            //for now, only channels can display pre-defined filtered fields.
            tagRoot.widgetType = "alltags";
        } else {
            tagRoot.widgetType = "6wtags";
        }
        bpsWidgetFilter.rebuildTagFacets(widgetRoot);
    },
    __getTagPostData: function (widgetRoot, objects) {
        var postData = "oid_list=";
        if (objects == null) {
            objects = bpsWidgetAPIs.getContainerData(widgetRoot.widgets[0]);
            if (objects == null) {
                return postData;
            }
        }
        var aObjectsIds = [];
        for (var i = 0; i < objects.length; i++) {
            var row = objects[i];
            aObjectsIds.push(row.objectId);
        }
        postData += aObjectsIds.join(",");
        return postData;
    },
    __processSelections: function (widgetRoot, colorFieldIndex, bReset) {
        colorFieldIndex = colorFieldIndex != null && colorFieldIndex != -1 ? colorFieldIndex : null;
        var colorIndex = null;
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot);
        var bSelectionsMade = false;
        //process field facets.
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            var field = fields[fieldIndex];
            //reset facet selections.
            field["_selections"] = {};
            field["_selectionsCount"] = 0;
            var facetList = field["_uniqueValuesObject"]._orderedList;
            for (var j = 0; j < facetList.length; j++) {
                var facetObject = facetList[j];
                if (bReset && field.name != "_objectId") {
                    //reset counts per facet.
                    facetObject["prevcount"] = 0;
                    facetObject["count"] = 0;
                    facetObject["selected"] = false;
                } else {
                    facetObject["prevcount"] = facetObject["count"];
                    facetObject["count"] = 0;
                    if (facetObject.selected == true) {
                        var label = facetObject["label"];
                        field["_selections"][label] = facetObject;
                        field["_selectionsCount"]++;
                        bSelectionsMade = true;
                    }
                }
            }
            //reset field filter status.
            if (field["_selectionsCount"] > 0) {
                field["_masterfield"]["_userfiltered"] = true;
            } else {
                field["_masterfield"]["_userfiltered"] = false;
            }
            //reset field color preference.
            if (colorFieldIndex != null) {
                if (colorFieldIndex == fieldIndex) {
                    var colorize = fields[colorFieldIndex]._colorize == true ? false : true;
                    fields[colorFieldIndex]["_masterfield"]._colorize = colorize;
                    if (colorize) {
                        colorIndex = colorFieldIndex;
                    }
                } else {
                    field["_masterfield"]._colorize = false;  //set color on master field definition
                }
            } else if (field["_masterfield"]._colorize) {
                colorIndex = fieldIndex;
            }
        }
        this.__processData(widgetRoot, fields, colorIndex, false, bSelectionsMade);
    },
    __processData: function (widgetRoot, fields, colorFieldIndex, bSecondPass, bSelectionsMade) {
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot);
        if (rows == null) {
            return;
        }
        var itemsFound = false;
        for (var i = 0; i < rows.length; i++) {
            var filtered = this.__processRow(rows[i], fields, colorFieldIndex, bSecondPass, bSelectionsMade);
            if (!filtered) {
                itemsFound = true;
            }
        }
        //check if any user selections were filtered out by other selection; if so remove and repeat process.
        if (bSelectionsMade && !itemsFound) {
            var redoFacets = false;
            for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                var field = fields[fieldIndex];
                var fieldSeclectionsCount = field["_selectionsCount"];
                if (fieldSeclectionsCount == 0) {
                    continue;
                }
                var fieldSelections = field["_selections"];
                for (var keyLabel in fieldSelections) {
                    var facetObject = fieldSelections[keyLabel];
                    if (facetObject.count == 0 && facetObject.prevcount == 0) {
                        delete fieldSelections[keyLabel];
                        fieldSeclectionsCount--;
                        field["_selectionsCount"] = fieldSeclectionsCount;
                        redoFacets = true;
                    }
                }
            }
            if (redoFacets) {  //reset all facetObject counts.
                for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                    var field = fields[fieldIndex];
                    var facetList = field["_uniqueValuesObject"]._orderedList;
                    for (var j = 0; j < facetList.length; j++) {
                        var facetObject = facetList[j];
                        facetObject["count"] = 0;
                    }
                }
                this.__applyAutoFilterSelections(widgetRoot, fields, colorFieldIndex, true, bSelectionsMade);
            }
        }
        // sort facets per field.
        var sortingType = null;   //date, integer or string(default).
        var sortingDirection = 1;  //1=ascending; -1=descending.
        var _sortFacets = function (facetObjectA, facetObjectB) {
            var value1 = facetObjectA.value.sortValue;
            var value2 = facetObjectB.value.sortValue;
            if (sortingType == "DATE") {
                return (parseInt(value1) > parseInt(value2)) ? sortingDirection : sortingDirection * -1;
            } else {
                if (sortingType == "INTEGER" || sortingType == "REAL") {
                    return (parseFloat(value1) > parseFloat(value2)) ? sortingDirection : sortingDirection * -1;
                } else {
                    return (value1 > value2) ? sortingDirection : sortingDirection * -1;
                }
            }
        };
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            sortingDirection = 1;
            sortingType = "STRING";
            var field = fields[fieldIndex];
            var masterField = field._masterfield;
            var sortObj = masterField.sort;
            if (sortObj != null) {
                if (sortObj.direction == "DESCENDING") {
                    sortingDirection = -1;
                } else {
                }
                sortingType = sortObj.type;
            }
            var facetList = field["_uniqueValuesObject"]._orderedList;
            facetList.sort(_sortFacets);
        }
    },
    __processRow: function (objectData, fields, colorFieldIndex, bSecondPass, bSelectionsMade) {
        // process row.
        var filter = false; // i.e. show by default.
        var coloredDataelement = null;
        var selfFilteredFieldIndex = -1;
        if (bSelectionsMade) {
            for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                var field = fields[fieldIndex];
                var fieldSeclectionsCount = field["_selectionsCount"];
                if (fieldSeclectionsCount == 0) {
                    continue;
                }
                var fieldSelections = field["_selections"];

                var dataelement = this.__getDataElement(field, objectData);
                var values = dataelement.value;
                var label = null;
                var matched = false;
                if (values != null) {
                    for (var i = 0; i < values.length; i++) {
                        var value = values[i];
                        label = this.__getValueLabel(value);
                        if (this.hasOwn.call(fieldSelections, label)) {
                            matched = true;
                            break;  //matched at least one item in list.
                        }
                    }
                }
                if (!matched) {
                    if (filter == false) { // hide row.
                        filter = true;
                        selfFilteredFieldIndex = fieldIndex;
                    } else {
                        selfFilteredFieldIndex = -1;
                        break;
                    }
                } else if (!bSecondPass && colorFieldIndex == fieldIndex && filter == false) {
                    var facetObject = fieldSelections[label];
                    var color = facetObject.color;
                    coloredDataelement = dataelement;
                    coloredDataelement["facetColoring"] = color; //turn on facet coloring for cell.
                }
            }
        }
        if (selfFilteredFieldIndex != -1 || filter == false) {
            for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                if (selfFilteredFieldIndex != -1 && selfFilteredFieldIndex != fieldIndex) {
                    continue;
                }
                var field = fields[fieldIndex];
                var dataelement = this.__getDataElement(field, objectData);
                var values = dataelement.value;
                if (values != null) {
                    for (var i = 0; i < values.length; i++) {
                        var value = values[i];
                        var facetObject = this.__getFacetObject(field["_uniqueValuesObject"], value, true);
                        if (coloredDataelement == null && !bSecondPass && colorFieldIndex == fieldIndex && filter == false) {
                            var color = facetObject.color;
                            coloredDataelement = dataelement;
                            coloredDataelement["facetColoring"] = color; //turn on facet coloring for cell.
                        }
                    }
                }
            }
        }
        if (!bSecondPass) {
            this.__setRowFilter(objectData, filter);
            if (colorFieldIndex != null && filter == true) {
                if (coloredDataelement == null) {
                    coloredDataelement = this.__getDataElement(fields[colorFieldIndex], objectData);
                }
                delete coloredDataelement["facetColoring"]; //turn on facet coloring for cell.
            }
        }
        return filter;
    },
    __getDataElement: function (field, objectData) {
        var dataelement = bpsWidgetAPIs.getDataElement(field, objectData);
        if (dataelement == null) {
            dataelement = {};
        }
        return dataelement;
    },
    __cloneValue: function (value, label) {
        var clonedValue = {};
        for (var key in value) {
            if (this.hasOwn.call(value, key)) {
                clonedValue[key] = value[key];
            }
        }
        if (clonedValue.sortValue == null) {
            if (clonedValue.actualValue != null) {
                clonedValue.sortValue = clonedValue.actualValue;
            } else {
                clonedValue.sortValue = label;
            }
        }
        return clonedValue;
    },
    __getValueLabel: function (value) {
        var label = "";
        if (value.imageValue != null) {
            label += value.imageValue + " ";  //need to format image.
        }
        if (value.printValue != null) {
            label += value.printValue;
        } else if (value.value != null) {
            label += value.value;
        }
        return label;
    },
    __getFacetObject: function (uniqueValuesObject, value, bIncrement) {
        var label = this.__getValueLabel(value);
        var facetObject = uniqueValuesObject[label];
        if (facetObject == null) {
            var counter = uniqueValuesObject._counter;
            var color = this.__generateFacetColor(counter);
            var clonedValue = this.__cloneValue(value, label);
            facetObject = {
                "value": clonedValue,
                "count": 0,
                "prevcount": 0,
                "color": color,
                "label": label,
                "selected": false
            };
            uniqueValuesObject[label] = facetObject;
            uniqueValuesObject._orderedList.push(facetObject);
            uniqueValuesObject._counter = counter + 1;
        }
        if (bIncrement) { // incr count.
            facetObject.count++;
        }
        return facetObject;
    },
    __setRowFilter: function (row, bFilter) {
        row.filtered = bFilter;
        if (!bFilter) { // hide row.
            this.__showParent(row);
        }
    },
    __showParent: function (childObject) {
        if (childObject._parentObject != null && childObject._parentObject.filtered == true) {
            childObject._parentObject.filtered = false;
            this.__showParent(childObject._parentObject);
        }
    },
    __generateFacetColor: function (index) {
        var classIndex = index % this.color_css.length;
        return this.color_base_css + " " + this.color_css[classIndex];
    },
    __updateTagSelection: function (widgetRoot, fieldName, tagValue, selected) {
        var found = false;
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot);
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            var field = fields[fieldIndex];
            if (field.label == fieldName) {
                var facetObject = field["_uniqueValuesObject"][tagValue];
                if (facetObject != null) {
                    facetObject.selected = selected;
                    found = true;
                }
                break;
            }
        }
        return found;
    },
    __hasTagSelection: function (widgetRoot) {
        var found = false;
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot);
        for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
            var field = fields[fieldIndex];
            if (field._selectionsCount > 0) {
                found = true;
                break;
            }
        }
        return found;
    },
    __getSixW: function (tagEventObject, predicatePropertyName) {
        var sixW;
        var predicate = tagEventObject[predicatePropertyName];
        if (predicate != null && predicate != "") {
            sixW = (tagEventObject.sixW ?  tagEventObject.sixW + "/" : "") + predicate;
        } else {
            sixW = tagEventObject.sixW;
        }
        return sixW;
    },
    __createTag: function (widgetRoot, fieldIndex, tagValue, objects) {
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, true);  //get non-filtered data records.
        if (rows == null) {
            return;
        }
        for (var i = 0; i < rows.length; i++) {
            var rowId = rows[i].objectId;
            if (bpsWidgetAPIs.__findInArray(objects, rowId) != -1) {
                var dataelement = bpsWidgetAPIs.getDataElementByIndex(rows[i], fieldIndex);
                var values = dataelement.value;
                var found = false;
                for (var j = 0; j < values.length; j++) {
                    var valueObj = values[j];
                    var text = valueObj.value;
                    if (text == tagValue) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    values.push({"value": tagValue});
                }
            }
        }
    },
    __removeTag: function (widgetRoot, fieldIndex, tagValue, objects) {
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, true);  //get non-filtered data records.
        if (rows == null) {
            return;
        }
        for (var i = 0; i < rows.length; i++) {
            var rowId = rows[i].objectId;
            if (bpsWidgetAPIs.__findInArray(objects, rowId) != -1) {
                var dataelement = bpsWidgetAPIs.getDataElementByIndex(rows[i], fieldIndex);
                var values = dataelement.value;
                var found = false;
                var updatedValues = [];
                for (var j = 0; j < values.length; j++) {
                    var valueObj = values[j];
                    var text = valueObj.value;
                    if (text != tagValue) {
                        updatedValues.push(valueObj);
                    }
                }
                dataelement.value = updatedValues;
            }
        }
    },
    __getExplicitTagFieldIndex: function (widgetRoot, sixw, bCreate) {
        //check if field already exist; return index of the field.
        var index = -1;
        var fieldName = sixw; //consistent w/widgettagdata service.
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot);
        for (var i = 0; i < fields.length; i++) {
            var name = fields[i].name;
            if (name == fieldName) {
                index = bpsWidgetAPIs.__getValueIndex(fields[i]);
                break;
            }
        }
        if (index == -1 && bCreate) {
            //create new field and add it to auto filter list.
            var masterfield = {"name": fieldName, "selectable" : {"sixw" : sixw}};
            bpsWidgetAPIs.__addNewAutoFilterField(widgetRoot, masterfield);
            index = bpsWidgetAPIs.__getValueIndex(masterfield);
        }
        return index;
    }
};
