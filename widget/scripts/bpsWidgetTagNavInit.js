/**
 * Implementation of the Tag Navigator component for BPS widgets
 * bpsWidgetTagNavInit.js
 * version 0.0.8
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * bpsWidgetTagNavInit Object
 * Controls filtering of widget data via 6W tagger
 *
 * Requires:
 * bpsTagNavConnector.js
 * jQuery v1.8.3 or later
 */
var bpsWidgetTagNavInit = {
    tnWin: null,
    loadTagData: function (widgetRoot) {
        if (!this.tnWin) {
            return;
        }
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, false, true);
        var postData = this.getTagPostData(widgetRoot, rows);
        if (postData == "") {
            return;
        }

        var thisTagRequest = {
            widgetRoot: widgetRoot,
            rows: rows
        }

        var loadTagDataDone = function (data) {
            var tagData = data != null ? data.widgets : null;
            if (tagData == null || tagData.length === 0) {
                return;
            }
            bpsWidgetTagNavInit.processTagData(thisTagRequest.widgetRoot, tagData[0], thisTagRequest.rows);
            if (postData.indexOf("isPhysicalIds=false") != -1) {
                //if data does not contain physicalids, then refresh view to enable rows selections based on physical ids.
                bpsWidgetEngine.reDrawWidget(widgetRoot);
            }
            bpsWidgetTagNavInit.drawTags(thisTagRequest.widgetRoot);
        }

        var tagURL = "/resources/bps/widgettagdata";
        bpsWidgetAPIs.ajaxRequest({url: tagURL, type: 'post', dataType: 'json', data: postData, callback: loadTagDataDone});
        bpsWidgetTagNavInit.register(thisTagRequest.widgetRoot);
    },
    keywordSearch: function (widgetRoot, searchStr, callbackFunction) {
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, false, true);  //get all data records regardless of filter.
        //undo previous search.
        bpsWidgetTagNavInit.__undoFilters(widgetRoot, rows);
        if (searchStr != null && searchStr != "") {
            var postData = bpsWidgetTagNavInit.getTagPostData(widgetRoot, rows);
            if (postData == "") {
                widgetRoot.nonObjectBased = true;
                return;
            }
            postData += "&searchStr=" + searchStr;
            var thisTagRequest = {
                callbackFunction: callbackFunction,
                widgetRoot: widgetRoot
            }

            var keywordSearchDone = function (data) {
                bpsWidgetTagNavInit.processSearchResults(thisTagRequest.widgetRoot, data, rows);
                bpsWidgetTagNavInit.drawTags(thisTagRequest.widgetRoot, true);
            };

            var searchURL = "/resources/bps/widgettagdata/search";
            bpsWidgetAPIs.ajaxRequest({url: searchURL, type: 'post', dataType: 'json', data: postData, callback: keywordSearchDone});
        } else if (widgetRoot.nonObjectBased != true) {
            bpsWidgetTagNavInit.drawTags(widgetRoot, true);
        }
    },
    processSearchResults: function (widgetRoot, searchData, rows) {    
        //Mark returned ids from search results.
        var bAutoFiltered = null,
            foundIds = [];
        var searchWidget = searchData.widgets[0];
        var searchRows = bpsWidgetAPIs.getContainerData(searchWidget);
        for (var i = 0; i < searchRows.length; i++) {
            var id = bpsWidgetAPIs.getId(searchRows[i]);
            foundIds.push(id);
        }
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            var id = bpsWidgetAPIs.getId(row);
            var bSearchFiltered = true;
            if (bpsWidgetAPIs.__findInArray(foundIds, id) != -1) {
                bSearchFiltered = false;
            }
            bpsWidgetAPIs.__setRowFilter(widgetRoot, row, bAutoFiltered, bSearchFiltered);
        }
    },
    __undoFilters: function (widgetRoot, objects) {
        //remove search filter the objects - loop through each row and reset search filter.
        var bAutoFiltered = false,
        bSearchFiltered = false;
        for (var i=0; i < objects.length; i++) {
            bpsWidgetAPIs.__setRowFilter(widgetRoot, objects[i], bAutoFiltered, bSearchFiltered);
        }
    },
    processTagData: function (widgetRoot, tagRoot, rows) {
        //merge tag data into widget data.
        var tagrows = bpsWidgetAPIs.getContainerData(tagRoot);
        for (var i = 0; i < tagrows.length; i++) {
            var tagrow = tagrows[i];
            bpsWidgetAPIs.__appendTagData(rows[i], tagrow);
            rows[i].physicalId = tagrow.physicalId;
        }
        bpsWidgetAPIs.__appendTagConfig(widgetRoot, tagRoot);  //append tag fields to widget fields.
    },
    buildTagObjectData: function (widgetRoot) {
        var tagData = {};
        var fields = bpsWidgetAPIs.getAutoFilterFields(widgetRoot);
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, true, true);  //get filtered records.
        for (var i = 0; i < rows.length; i++) {
            var object = rows[i];
            tags = [];

            for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                var field = fields[fieldIndex];
                var dataelement = bpsWidgetAPIs.getDataElement(field, object);
                var values = dataelement != null ? dataelement.value : null;
                if (values == null) {
                    continue;
                }
                for (var j = 0; j < values.length; j++) {
                    var value = values[j];
                    var label = this.getTagLabel(value);
                    if (label == "") {
                        continue;
                    }
                    tag = {
                        "object": label,
                        "dispValue" : label,
                        "sixw": field.selectable.sixw,
                        "field": field.name
                    };
                    tags.push(tag);
                }
            }
            var objectId = "pid://" + bpsWidgetAPIs.getId(object);
            tagData[objectId] = tags;
        }
        return tagData;
    },
    getTagLabel: function (value) {
        var label = "";
        if (value.printValue != null) {
            label += value.printValue;
        } else if (value.value != null) {
            label += value.value;
        }
        return label;
    },
    getTagPostData: function (widgetRoot, objects) {
        var postData = "";
        if (objects != null) {
            var isPhysicalIds = true;
            var aObjectsIds = [];
            for (var i = 0; i < objects.length; i++) {
                var row = objects[i];
                if (row.physicalId != null) {
                    aObjectsIds.push(row.physicalId);
                } else if (row.objectId != null) {
                    aObjectsIds.push(row.objectId);
                    isPhysicalIds = false;
                } else {
                    aObjectsIds = []; //some objects with no ids; for now, this is not valid.
                    bpsWidgetAPIs.destroyTNProxies(widgetRoot);
                    break;
                }
            }
            if (aObjectsIds.length > 0) {
                postData = "oid_list=" + aObjectsIds.join(",");
                postData += "&isPhysicalIds=" + isPhysicalIds;
            }
        }
        return postData;
    },
    drawTags: function(widget, reDrawWidget) {
        if (widget.tnProxy) {
            var tnDataObj = this.buildTagObjectData(widget);
            widget.tnProxy.setSubjectsTags(tnDataObj);
        }
        if (reDrawWidget == true && !this.hasFilters(widget)) {  //if there are tags, the tagger will call showObjects which in turn will reDraw.
            //bpsWidgetEngine.reDrawWidget(widget);
            //let tagger refresh the widget first since hasFilters is not functional now.
            setTimeout(function(){bpsWidgetEngine.reDrawWidget(widget);}, 10);  
        }
    },
    showObjects: function(widgetRoot, filteredSubjectList) {
        var bSearchFiltered = null;
        var rows = bpsWidgetAPIs.getContainerData(widgetRoot, null, null, false, true);  //get all data records regardless of filter.
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            var objectId = "pid://" + bpsWidgetAPIs.getId(row);
            var filter = true;
            if (bpsWidgetAPIs.__findInArray(filteredSubjectList, objectId) != -1) {
                filter = false;
            }
            bpsWidgetAPIs.__setRowFilter(widgetRoot, row, filter, bSearchFiltered);
        }
    },
    handleFilter: function(objSelection) {//"this" is scoped to the widget that invoked this method
        bpsWidgetTagNavInit.showObjects(this, objSelection.filteredSubjectList);
        this.parentObj.reDrawWidget(this);
    },
    handleTagCollect: function () {
        var aWidgetOids = [];
        this.container.find(".selected").each(function() {
                                    aWidgetOids.push("pid://" + jQuery(this).attr("data-pid"));
                                });
        try {
            if(aWidgetOids.length > 0){
                this.tnProxy.focusOnSubjects(aWidgetOids);
            } else {
                this.tnProxy.unfocus();
            }
        } catch (e) {
            //do nothing
            console.log(e.message);
        }
    },
    hasFilters: function (widget) {
        return false;//todo
        var hasFilters = false;
        if (widget.tagger) {
            var allfilters = widget.tagger.getFilters().allfilters;
            for (var key in allfilters) {
                if (allfilters.hasOwnProperty(key)) {
                    hasFilters = true;
                    break;
                }
            }
        }
        return hasFilters;
    },
    register: function(widget) {
        if(widget.tagger) {
            return;
        }
        var tagger, oThis = this,
            win = this.tnWin,
            tabID, tagServiceURL = enoviaServer.getUrl();

        if(isIFWE) {
            tabID = enoviaServer.taggerContextId || "";
            if (tabID.length == 0) {
                return;
            }
        } else {
            tabID = "context1"; //we should get this from a common function
        }

        //tagger = win.bpsTagNavConnector.TagNavigator.get6WTagger(tabID);
        widget.tagger = true;
        //setup listeners
        var params = enoviaServer.tenant ? {
            tenant: enoviaServer.tenant
        } : {};


        require(['TagNavigatorProxy/TagNavigatorProxy'], function(TagNavigatorProxy) {
            var options = {
                contextId: tabID,
                id: widget.id,
                proxyDisplayName: 'ENOVIA UI Components',
                tagsServerUrl: tagServiceURL,
                tagsServerUrlParams: params,
                filteringMode: 'WithFilteringServices',
                disableAutoComplete: true
            };

            widget.tnProxy = TagNavigatorProxy.createProxy(options);
            //when a tag is clicked in TN
            widget.tnProxy.addFilterSubjectsListener(oThis.handleFilter, widget);
        });

        //non TN event bindings
        //widget.id is to fire events on this widget only
        //.bps_widget is to unregister all events with one namespace
        jQuery(win.document).bind("widget_selection_changed." + widget.id + ".bps_widget", function(e, data) {
            oThis.handleTagCollect.call(widget, data);
        });

        jQuery(window).unload(function() {
            jQuery(win.document).unbind(".bps_widget");
			win.bpsTagNavConnector.TagNavigator.get6WTagger(tabID).clearFilters(true);
            widget.tnProxy.die();
        });
    },
    init: function() {
        var oThis = this;
        this.tnWin = bpsTagNavConnector.getTNWindow();
        if(this.tnWin){
            this.tnWin.hasWidget = true; //to enable TN button on toolbar
            jQuery(window).unload(function() {
                oThis.tnWin.hasWidget = false;
            });
        }
    }
};

jQuery(function() {// onload initialization
    bpsWidgetTagNavInit.init();
});

if(typeof console === "undefined") {//prevent IE from throwing errors. This is just a debug utility
    console = {
        log: function() {},
        warn: function() {},
        dir: function() {}
    }
}
