/*
 * Widget APIs
 * bpsWidgetAPIs.js
 * version 2.1
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
var bpsWidgetAPIs = {
    //initial function to initiate processing of JSON data for UI presentation.
    drawWidget: function (containerConfig) {  //containerConfig: JSON data from service
        this.engine = containerConfig;
        return this.__drawWidget(containerConfig.data);
    },
    loadWidget: function (widgetName, callback) {  //loads widget from server asynchronously.
        var thisRequest = {
            callbackFunction: callback
        };
        bpsWidgetAPIs.ajaxRequest({
            url: bpsWidgetEngine.tempURI(widgetName),
            type: 'get',
            dataType: 'json',
            callback: function(data) {
                if (!data.success) {
                    var strError = data.error;
                    strError = bpsWidgetConstants.str[strError] || bpsWidgetConstants.str["NetworkError"];
                    throw(strError);
                } else {
                    thisRequest.callbackFunction.call(this, data.widgets[0]);
                }
            }
        });
    },
    getWidgetViews: function (widgetRoot) {
        var userViews = [];
        if (widgetRoot.availableViews != null) {
            var views = widgetRoot.availableViews.view;
            for (var i = 0; i < views.length; i++) {
                var viewpref = {
                    displayName: bpsWidgetConstants.str[views[i]],
                    value: views[i]
                };
                userViews.push(viewpref);
            }
        }
        return userViews;
    },
    setWidgetViewPreference: function (widgetRoot, view) {
        widgetRoot.displayview = view;
    },
    getWidgetViewPreference: function (widgetRoot) {
        return (widgetRoot.displayview);
    },
    getWidgetTitle: function (widgetRoot, objectId) {  //check if the widget data con
        var title = null;
        while (widgetRoot && (widgetRoot.widgetType === undefined ||
                              widgetRoot.widgetType == "view" ||
                              widgetRoot.widgetType == "experience")) {

            var dataWidgets = bpsWidgetAPIs.getContainerItems(widgetRoot, true); //include hidden.
            if (dataWidgets.length > 0) {
                widgetRoot = dataWidgets[0];
            } else {
                break;
            }
        }
        if (widgetRoot) {
            var rootObject = bpsWidgetAPIs.getObject(widgetRoot, objectId);
            title = bpsWidgetAPIs.getFieldValue(rootObject, "title");
            if (title) {
                title = title.displayValue;
            }
        }
        return title;
    },
    drawContainerHTML: function (containerConfig, widgetTypeHierachy, containerHTMLItems, containerData, objectData) {
        var containerType = containerConfig.widgetType || "ds-widget";
        var containerLayout = this.getContainerLayout(containerConfig, containerType) || "";
        var objData = {
                config: containerConfig,
                data: containerData,
                objectData: objectData,
                type: containerType,
                layout: containerLayout,
                children: containerHTMLItems
        };
        return this.engine.createView(objData);
    },
    drawFieldHTML: function (itemConfig, widgetTypeHierachy, objectData, widget, keepTableFieldLabel) {
        var fieldContext = this.getItemContext(itemConfig, widgetTypeHierachy);
        var labelSettings = null;
        if (keepTableFieldLabel != true && fieldContext == "table") {
            labelSettings = itemConfig.label;
            itemConfig.label = null;
        }
        var values = this.getFieldData(itemConfig, objectData);
        var objData = {
                config: itemConfig,
                data: objectData,
                objectData: objectData,
                context: fieldContext,
                type: "field",
                values: values,
                widget: widget
        };
        var HTMLField = this.engine.createFieldView(objData);
        if (labelSettings != null) {
            itemConfig.label = labelSettings;
        }
        return HTMLField;
    },
    isObjectContainer: function (testString) {
        return (this.__findInArray(this._dataContainers, testString) !== -1);
    },
    getItemContext: function (item, widgetTypeHierachy) {
        var itemContext = item._itemContext;
        if (itemContext == null) {
            var len = widgetTypeHierachy.length;
            for (var i = len-1; i >= 0; i--) {
                var found = false;
                itemContext = widgetTypeHierachy[i];
                switch(itemContext) {
                    case "table":
                    case "list":
                    case "form":
                    case "channel":
                        found = true;
                        break;
                }
                if (found) {
                    break;
                }
            }
            item._itemContext = itemContext;
        }
        return itemContext;
    },
    drawTableHeaderHTML: function (itemConfig, widgetTypeHierachy) {
        //for now, call standard field handling.
        return (this.drawFieldHTML(itemConfig, widgetTypeHierachy, null, itemConfig, true));
    },
    getTableHeaders: function (containerConfig, widgetTypeHierachy) {
        if (widgetTypeHierachy == null) {
            widgetTypeHierachy = ["table"];
        }
        var containerItems = this.getContainerItems(containerConfig);  //get sub-widgets.
        var containerHTMLItems = [];
        for (var j = 0; j < containerItems.length; j++) {  //sub-widgets.
            var itemConfig = containerItems[j];
            var itemType = itemConfig.widgetType;
            if (itemType == "field") {
                containerHTMLItems.push(this.drawTableHeaderHTML(itemConfig, widgetTypeHierachy));
            } else { //container.
                var subContainerHTMLItems = this.getTableHeaders(itemConfig, widgetTypeHierachy);
                var htmlStr = this.drawContainerHTML(containerConfig, [], subContainerHTMLItems);
                containerHTMLItems.push(htmlStr);
            }
        }
        return containerHTMLItems;
    },
    getContainerLayout: function (containerConfig, containerType) {
        var layout = null;
        var style = containerConfig.style;
        if (style != null) {
            layout = style.layout;
        }
        if (layout == null) {
            layout = "VERTICAL";
        }
        return layout;
    },
    getContainerItems: function (containerConfig, includeHidden) {
        var list = [],
            tempList = [],
            view = containerConfig.displayview;
        if (containerConfig.widget) {
            containerConfig.widget._parentExperience = containerConfig;
            tempList.push(containerConfig.widget);
        } else if (containerConfig.widgets) {
            tempList = containerConfig.widgets;
        }
        for (var i = 0; i < tempList.length; i++) {
            if (includeHidden == true || ((view == tempList[i].view || tempList[i].view==null) && tempList[i].hidden != true)) {
                list.push(tempList[i]);
            }
        }
        return list;
    },
    getWidgetData: function (containerConfig, options /* checkFiltered (true), allLevels (false) */) {
        options = options || {};
        var checkFiltered = options.checkFiltered || true,
        allLevels = options.allLevels || false;

        return this.getContainerData(containerConfig, null, null, checkFiltered, allLevels);
    },
    getContainerData: function (containerConfig, containerType, objectData, checkFiltered, allLevels) {
        var listData = null;
        if (containerConfig == null) {
            return listData;
        }
        var data = containerConfig.datarecords,
        fixedLevels = false;
        if (data != null) {
            listData = data.datagroups;
            fixedLevels = containerConfig.datarecords.fixedLevels;
            if (listData == null) {
                listData = [];
            }
        } else if (objectData != null && objectData.relateddata != null) {
            var relationship = containerConfig.name;
            var datarecords = objectData.relateddata[relationship];
            if (datarecords != null) {
                listData = datarecords.datagroups;
                fixedLevels = datarecords.fixedLevels;
            }
        }
        if (listData != null) {
            var expandedList = [];
            for (var i = 0; i < listData.length; i++) {
                var item = listData[i];
                if (checkFiltered == true && item.filtered == true) {
                    continue;
                }
                item._parentRecords = listData;
                expandedList.push(item);
                if (allLevels) {
                    var subObjects = bpsWidgetAPIs.getChildren(item, {checkFiltered: checkFiltered, allLevels: true, fixedLevels: fixedLevels} );
                    expandedList = expandedList.concat(subObjects);
                }
            }
            listData = expandedList;
        }
        if (data != null && containerConfig.countSummary == null) {
            //initially assume all data coming from server is not filtered.
            containerConfig.countSummary = {
                total : listData.length,
                shown : listData.length
            };
        }
        return listData;
    },
    getField: function (widgetRoot, fieldName) {  //get field by name.
        return this.__getField(widgetRoot, fieldName);
    },
    getFieldValue: function (objectData, fieldName) {  //get value by field name.
        var retValue,
            dataelement = objectData != null ? objectData.dataelements[fieldName] : null;
        if (dataelement != null) {
            values = dataelement.value;
            if (values.length > 0) {
                retValue = {displayValue: values[0].value, actualValue: values[0].actualValue};
            }
        }
        return retValue;
    },
    getFieldData: function (itemConfig, objectData) {
        var values = null;
        var dataelement = this.getDataElement(itemConfig, objectData);
        if (dataelement != null) {
            values = dataelement.value;
        }
        return values;
    },
    getDataElement: function (itemConfig, objectData) {
        if (objectData == null) {
            return null;
        }
        var fieldName = itemConfig.name;
        var dataelement = objectData.dataelements[fieldName];
        return dataelement;
    },
    getDataElementByIndex: function (objectData, index) {
        var dataelement = null;
        var dataelements = objectData.dataelements;
        if (index < dataelements.length) {
            dataelement = dataelements[index];
        } else {  // need to create element.
            for (var i = dataelements.length; i <= index; i++) { //append place holders.
                dataelement = {"value": []};
                dataelements.push(dataelement);
            }
        }
        return dataelement;
    },
    getAutoFilterFields: function (containerConfig) {
        return this.__getAutoFilterFields(containerConfig);
    },
    destroyTNProxies: function (widgetRoot) {
        var items;
        if (widgetRoot.widgetType == "experience") {
            items = this.getContainerItems(widgetRoot);
            widgetRoot = items[0];
        }
        if (widgetRoot.tnProxy) {
            widgetRoot.tnProxy.die();
            widgetRoot.tnProxy = null;
            jQuery(bpsWidgetTagNavInit.tnWin.document).unbind("." + widgetRoot.id);
        }
    },
    ajaxRequest: function (ajaxRequestObject /* {url: 'URL', type: 'post', dataType: 'json', data: 'postData', callback: 'loadTagDataDone'}*/) {
        var ajaxURL = ajaxRequestObject.url;
        ajaxURL += (ajaxURL.indexOf("?") == -1) ? "?" : "&";
        ajaxURL += enoviaServer.params;
        ajaxURL += "&bpsNoCache=" + Math.random(new Date().getTime());
        if (enoviaServer.space && "POST" == ajaxRequestObject.type) {
            ajaxURL += "&SecurityContext=" + enoviaServer.space;
        }
        if (typeof isIFWE !== "undefined" && isIFWE === true) {
            ajaxURL = encodeURI(enoviaServer.getUrl() + ajaxURL);
            UWA.Data.request(ajaxURL, {
                method: ajaxRequestObject.type,
                type: ajaxRequestObject.dataType,
                proxy: 'passport',
                timeout: 500000,
                cache: 3600,
                data: enoviaServer.getParamsAsJSON(),
                parameters: ajaxRequestObject.data,
                onComplete: ajaxRequestObject.callback
            });
        } else {
            ajaxURL = ((ajaxURL.indexOf("/") === 0) ? ".." : "") + ajaxURL;
            jQuery.ajax({
                url: ajaxURL,
                type: ajaxRequestObject.type,
                dataType: ajaxRequestObject.dataType,
                data: ajaxRequestObject.data,
                success: ajaxRequestObject.callback,
                cache: false
            });
        }
    },
    getCollaborativeStorages: function (callbackFunction) { //returns a list of cstorages with URL and displayName as properties.
        var thisRequest = {
            callbackFunction: callbackFunction
        };
        var getCStoragesDone = function (data) {
            var cstorage = data.cstorage;
            if (cstorage == null || cstorage.length === 0) {
                // if zero length use existing url.
                cstorage = [];
                cstorage.push({
                    displayName : "ENOVIA",
                    url : enoviaServer.getUrl()
                });
            }
            thisRequest.callbackFunction.call(this, cstorage);
        };
        var storageURL = "/resources/AppsMngt/cstorages";
        bpsWidgetAPIs.ajaxRequest({
            url: storageURL,
            type: 'GET',
            dataType: 'json',
            data: "",
            callback: getCStoragesDone
        });
    },
    getCollaborativeSpaces: function (callbackFunction) { //returns a list of cspaces.
        var thisRequest = {
            callbackFunction: callbackFunction
        };
        var getCSpacesDone = function (data) {
            var cspaces = data.cspaces;
            if (cspaces == null || cspaces.length == 0) {
            // if zero length use existing space
                cspaces = [];
                cspaces.push({
                    displayName : "Default",
                    name : "default"
                });
            }
            thisRequest.callbackFunction.call(this, cspaces);
        };
        var cspaceURL = "/resources/bps/cspaces";
        bpsWidgetAPIs.ajaxRequest({
            url: cspaceURL,
            type: 'GET',
            dataType: 'json',
            data: "",
            callback: getCSpacesDone
        });
    },
    sortWidget: function (widgetRoot, sortList /* {name: "field name", direction: "ascending/descending"}, */) {
        var widgetType = widgetRoot.widgetType;
        if (widgetType == "experience") {
            var containerItems = this.getContainerItems(widgetRoot);  //get main widget.
            widgetRoot = containerItems[0];
        }
        if (widgetRoot._parentExperience != null) { //save sort pref. in case of refresh.
            widgetRoot._parentExperience._sortList = sortList;
        }
        this.__sortWidget(widgetRoot, sortList);
    },
    getSortableFields: function (widgetRoot) { //returns a list of field objects that are defined as sortable.
        var widgetType = widgetRoot.widgetType;
        if (widgetType == "experience") {
            var containerItems = this.getContainerItems(widgetRoot);  //get main widget.
            widgetRoot = containerItems[0];
        }
        var sortfields = this.__getSortableFields(widgetRoot);
        var sorts = [];
        for (var i = 0; i < sortfields.length; i++) {
            var sortpref = {
                displayName: sortfields[i].label.text,
                value: sortfields[i].name
            };
            if (sortfields[i].sort.order == "1") {
                sortpref.defaultValue = sortfields[i].name;
                sortpref.sortdir = sortfields[i].sort.direction == null ? "ascending" : sortfields[i].sort.direction;
            }
            sorts.push(sortpref);
        }
        return sorts;
    },
    getId: function (rowObject) {
        return rowObject.physicalId || rowObject.objectId || rowObject.tempId;
    },
    getRelId: function (rowObject) {
        var relId = rowObject.relId || rowObject._relId;
        if (relId == null) {
            relId = "" + new Date().getTime();
            rowObject._relId = relId;
        }
        return relId;
    },
    getObject: function (widget, id /*id or object*/) {
        if (id == null) {
            return null;
        } else if (typeof id === "object") {
            return id;
        }
        var containerType, objectData, checkFiltered = true, allLevels = true,
        rows = this.getContainerData(widget, containerType, objectData, checkFiltered, allLevels);
        return this.__findObject(rows, id);
    },
    getRelatedObject: function (widget, relationship, node_parent /*id or object*/, id) {
        var containerType, checkFiltered = true, allLevels = true,
        parentObject = this.getObject(widget, node_parent),
        rows = this.getContainerData({name:relationship}, containerType, parentObject, checkFiltered, allLevels),
        relatedObject = this.__findObject(rows, id);
        if (relatedObject) {
            relatedObject._relationship = relationship;
            relatedObject._relationshipParentObject = parentObject;
        }
        return relatedObject;
    },
    getChildren: function (parentObj, args /* {checkFiltered: (true)/false, allLevels: true/(false), fixedLevels: true/(false)} */) { //get object children
        var checkFiltered = true,
        allLevels, fixedLevels,
        subItems = [],
        objects = parentObj.children;

        if (typeof args === "object") {
            checkFiltered = args.checkFiltered != undefined ? args.checkFiltered : checkFiltered;
            allLevels = args.allLevels;
            fixedLevels = args.fixedLevels;
        }
        if (objects != null && objects.length > 0) {
            for (var i=0; i < objects.length; i++) {
                var object = objects[i];
                if (checkFiltered === false || object.filtered != true) {
                    object._parentObject = parentObj;
                    subItems.push(object);
                    if (allLevels) {
                        var children = this.getChildren(object, args);
                        subItems = subItems.concat(children);
                    }
                }
            }
        } else if (fixedLevels) {
            parentObj.leaf = true;
        }
        return subItems;
    },
    expandObject: function (widget, id, callback, levels) {
        var object = this.getObject(widget, id);
        if (object.children.length > 0) { //already have the children; return it.
            callback.call(this, object.children);
        } else if (object.leaf || widget.datarecords.fixedLevels) { //leaf or already has been expanded to all levels.
            //leaf object; no children; send empty list.
            callback.call(this, []);
        } else { //retrieve the children from server.
            var thisRequest = {
                object: object,
                callbackFunction: callback
            },
            widgetName = widget._parentExperience != null ? widget._parentExperience.name : widget.name,
            url = bpsWidgetEngine.tempURI(widgetName);
            url += "?bpsAction=expand&expandId=" + object.objectId;
            bpsWidgetAPIs.ajaxRequest({
                url: url,
                type: 'get',
                dataType: 'json',
                callback: function(data) {
                    if (!data.success) {
                        var strError = data.error;
                        strError = bpsWidgetConstants.str[strError] || bpsWidgetConstants.str["NetworkError"];
                        throw(strError);
                    } else {
                        var children = data.widgets[0].widget.datarecords.datagroups;
                        thisRequest.object.children = children;
                        //needed to establish parent/child references.
                        bpsWidgetAPIs.getChildren(thisRequest.object, {checkFiltered: false, allLevels: true, fixedLevels: data.widgets[0].widget.datarecords.fixedLevels} );
                        thisRequest.object.leaf = true; //mark object that we have already checked.
                        if (thisRequest.callbackFunction) {
                            thisRequest.callbackFunction.call(this, thisRequest.object.children);
                        }
                    }
                }
            });
        }
    },
    getPreferenceValue: function (data, pref) {
        if (data.parentObj && data.parentObj.uwaWidget) {
            return data.parentObj.uwaWidget.getValue(pref);
        }
        return false;
    },
    getPreference: function (data, pref) {
        if (data.parentObj && data.parentObj.uwaWidget) {
            return data.parentObj.uwaWidget.getPreference(pref);
        }
        return false;
    },
    addPreference: function(data, prefObj) {
        if(data.parentObj && data.parentObj.uwaWidget) {
            prefObj.onchange = "onForceRefresh";
            data.parentObj.uwaWidget.addPreference(prefObj);
            data.parentObj.uwaWidget.setValue(prefObj.name, prefObj.defaultValue);
            data.parentObj.uwaWidget.setValue("bps_preference_"+ prefObj.name, JSON.stringify(prefObj));
            data.parentObj.uwaWidget.addPreference({name: "bps_preference_"+ prefObj.name, type: "hidden", value: JSON.stringify(prefObj)});

            data.parentObj.uwaWidget.MyWidget.onForceRefresh(true);
        }
    },
    appendFieldData: function (target, source) {  //combine field data.
        for (var key in source.dataelements) {
            if (source.dataelements.hasOwnProperty(key)) {
                target.dataelements[key] = source.dataelements[key];
            }
        }
    },
    //start of private variables & functions.
    _dataContainers: ["list","channel","table","form"],
    __processCustomDraw: function(itemConfig, widgetTypeHierachy, objectData) {
        var result, err_message;
        try {
            if(typeof itemConfig.custom.scriptSource === "string") {
                err_message = "eval failed";
                itemConfig.custom.scriptSource = eval('(' + itemConfig.custom.scriptSource + ')');
            }
            err_message = "draw failed";
            result = itemConfig.custom.scriptSource.draw(itemConfig, widgetTypeHierachy, objectData);
        } catch (err) {
            console.error(err.message + " in file " + itemConfig.custom.scriptPath);
            result = '<span class="message">Error: ' + err_message + '</span>';
            if (err_message === "eval failed") {
                itemConfig.custom.scriptSource = { draw: function() {return result;}};
            }
        }
        if (typeof result === "string") {
            result = jQuery(result);
        }
        return jQuery('<div></div>').append(result);
    },
    hasOwn: Object.prototype.hasOwnProperty, //filter out prototype in "for in" loops
    __drawWidget: function (containerConfig, widgetTypeHierachy, objectData, view, currentObjectContainer) {  //containerConfig: json data from service;
        var firstrun = 200;
        function postInsertRows (start) {
            var chunk = 10, i = start || 0, othis = this, containerHTMLItems = [], partialData = null;
            for (; i < Math.min((start + chunk), dataloop); i++) {  //data loop.
                objectData = containerData != null ? containerData[i] : objectData;
                var containerObjectItems = [];
                containerHTMLItems.push(containerObjectItems);
                for (var j = 0; j < containerItems.length; j++) {  //sub-widgets.
                    var itemConfig = containerItems[j];
                    var itemType = itemConfig.widgetType;
                    if (itemType == "field") {
                        if (itemConfig.custom) {
                            var returnObj = this.__processCustomDraw(itemConfig, widgetTypeHierachy, objectData);
                            containerObjectItems.push(returnObj);
                        } else {
                            containerObjectItems.push(this.drawFieldHTML(itemConfig, widgetTypeHierachy, objectData, currentObjectContainer));
                        }
                    } else if (itemType == "location") { //location
                        var path = bpsWidgetEngine.processUrl(itemConfig, itemConfig);
                        //var height = (itemConfig.style && itemConfig.style.height) ? enoviaServer.maximizedHeight || itemConfig.style.height : "";
                        var height = (itemConfig.style && itemConfig.style.height) ? itemConfig.style.height : "";
                        height="";
                        //TODO move this to templates
                        var frameContainer = jQuery('<div />').height(height);
                            frameContainer.bind('resize_me', function (event, data) {
                            //console.log(data.size + ": " + frameContainer);
                            var intRegex = /^\d+$/;
                            var size = parseInt(data.size, 10);
                            if (size && intRegex.test(size)) {
                                //frameContainer.height(Math.min(size, 600));
                                frameContainer.height(Math.min(size, parent.document.body.clientHeight -35));
                                //frameContainer.height(size);
                            }
                        });
                        var frame = jQuery('<iframe frameborder="0" mimetype="text/html" src="' + path + '" style="width:100%">not supported</iframe>');
                        frameContainer.append(frame);
                        containerObjectItems.push(frameContainer);
                        //containerObjectItems.push(jQuery('<object mimetype="text/html" data="' + path + '" style="width:100%"' + height + '>not //supported</object>'));
                    } else { //container.
                        if (itemType == "truecondition" || itemType == "falsecondition") {
                            if (!this.__checkTrueFalseCondition(currentObjectContainer, itemConfig, objectData, itemType == "truecondition")) {
                                continue;
                            }
                        }
                        containerObjectItems.push(this.__drawWidget(itemConfig, widgetTypeHierachy, objectData, view, currentObjectContainer));
                    }
                }
            }
            if (containerData != null && containerData.length > 0) {
                partialData = containerData.slice(start, i);
            }
            htmlContainer = this.drawContainerHTML(containerConfig, widgetTypeHierachy, containerHTMLItems, partialData, objectData);
            if (i < dataloop) {
                containerConfig._timeout = setTimeout(function(){postInsertRows.call(othis,i)},firstrun);
                firstrun = 1;
            }
        }

        var containerType = containerConfig.widgetType;
        if (widgetTypeHierachy == null) {
            widgetTypeHierachy = [];
        }
        if (view != null && this.isObjectContainer(containerType) && this.isObjectContainer(view.toLowerCase())) {
            containerType = view.toLowerCase();
            containerConfig.widgetType = containerType;
        }
        widgetTypeHierachy.push(containerType);
        if (containerConfig.availableViews != null) {
            var itemview = containerConfig.displayview;
            if (itemview == null) {
                itemview = view;
            }
            if (itemview == null || this.__findInArray(containerConfig.availableViews.view, itemview) == -1) {
                view = containerConfig.availableViews.view[0];
            } else {
                view = itemview;
            }
        }
        if (view != null) {
            containerConfig.displayview = view;
        } else {
            view = containerConfig.displayview;
        }
        var allLevels = containerType == "table" ||  containerType == "table_expand" ? false : true;
        var containerItems = this.getContainerItems(containerConfig);  //get sub-widgets.
        var containerData = this.getContainerData(containerConfig, containerType, objectData, true, allLevels);
        var dataloop = 1;
        if (containerData != null) {
            dataloop = containerData.length;
        }

        if (this.isObjectContainer(containerType)) {//register as a widget
            containerConfig.parentObj = this.engine;
            containerConfig.parentObj.registerTN(containerConfig);
            if (currentObjectContainer == null) {
                currentObjectContainer = containerConfig;
            }
        }

        var htmlContainer;
        if (containerConfig.custom) {
            htmlContainer = this.__processCustomDraw(containerConfig, widgetTypeHierachy, containerData);
        } else if (containerItems.length > 0) {
            clearTimeout(containerConfig._timeout);
            delete containerConfig._domElem;//remove pagination elem declared in bpsWidgetEngine
            postInsertRows.call(this, 0);
        } else {
            htmlContainer = bpsWidgetTemplate.generic();
        }

        if (containerData != null && containerConfig.charts.length > 0) {
            var charts = this.__drawCharts(containerConfig, containerData, containerConfig.charts, containerConfig.displayview);
            if (charts.length > 0) {
                var dom = bpsWidgetTemplate.chartgroup({type: "chartgroup", layout: "vertical"});
                for (var j=0; j < charts.length; j++) {
                    dom.append(charts[j]);
                }
                htmlContainer = dom.append(htmlContainer);
            }
        }

        if (this.isObjectContainer(containerType)) {//pointer to this widget's container
            if (containerConfig.parentObj.uwaWidget && containerConfig.custom == null && (this.__findInArray(["list", "table"], containerType)!= -1)) {
                 htmlContainer = bpsWidgetTemplate.container({type: "table-container"}).append(htmlContainer);
            }
            var origElem = htmlContainer, widgetSize;
            htmlContainer = bpsWidgetTemplate.generic().append(htmlContainer);
            if(containerConfig.parentObj.uwaWidget) {
                widgetSize = containerConfig.parentObj.uwaWidget.getValue("widgetsize");
                if (widgetSize && widgetSize.length > 0){
                    origElem.removeClass("small medium large");
                    origElem.addClass(widgetSize);
                }
            }
            if (containerConfig.custom == null) {
                if(containerConfig.parentObj.uwaWidget) {
                    var scrollParams = {};
                    if (containerType != "channel") {
                        if(containerConfig.style && containerConfig.style.height){
                            scrollParams = {height: parseInt(containerConfig.style.height)};
                        }
                    } else {
                        origElem.css('overflow','visible');
                    }
                    scrollParams.scrollDrag = true;
                    UWA.extendElement(origElem[0]);
                    new UWA.Controls.Scroller(origElem[0], scrollParams);
                } else {
                    if (containerType != "channel" && containerConfig.style && containerConfig.style.height) {
                        htmlContainer.addClass("table-scroll");
                        htmlContainer.css("height", containerConfig.style.height);
                    }
                    if (containerType != "channel" && parseInt(htmlContainer.css("height")) == 0) {
                        htmlContainer.css({position: "relative", height: "300px", overflow: "auto"});
                    }
                }
            }
            containerConfig.container = htmlContainer;
        }

        widgetTypeHierachy.pop();
        return htmlContainer;
    },
    __drawCharts: function (widget, widgetData, chartsConfig, view) {
        var containerHTMLCharts = [];
        for (var i = 0; i < chartsConfig.length; i++) {
            var itemConfig = chartsConfig[i];
            var itemType = itemConfig.widgetType;
            var itemView = itemConfig.view;
            if ((view == itemView || itemView==null) && itemConfig.hidden != true) {
                if (itemType == "chart") {
                    containerHTMLCharts.push(bpsWidgetChart.drawChart(widget, widgetData, itemConfig));
                } else { //chart container.
                    var containerList = this.__drawCharts(widget, widgetData, itemConfig.charts, view);
                    containerHTMLCharts.push(this.drawContainerHTML(itemConfig, [], containerList, null));
                }
            }
        }
        return containerHTMLCharts;
    },
    __checkTrueFalseCondition: function (widget, ifconfig, objectData, condition) {
        var iffield = ifconfig.field,
        ifvalue = ifconfig.value,
        ifcheck = false,
        fieldConfig = bpsWidgetAPIs.getField(widget, iffield);
        if (fieldConfig) {
            var values = bpsWidgetAPIs.getFieldData(fieldConfig, objectData);
            if (values.length == 0 && !condition) {
                ifcheck = true;
            }
            for (var k = 0; k < values.length; k++) {
                var fieldvalue = values[k].actualValue || values[k].value;
                if (ifvalue) {
                    if ((ifvalue != fieldvalue && !condition) || //for false condition, we may need to check all values.
                        (ifvalue == fieldvalue && condition)) {
                        ifcheck = true;
                        break;
                    }
                } else {
                    if (((fieldvalue == null || fieldvalue == "" || fieldvalue.toLowerCase() == "false") && !condition) ||
                        ((fieldvalue != null && fieldvalue != "" && fieldvalue.toLowerCase() != "false") && condition)) {
                        ifcheck = true;
                        break;
                    }
                }
            }
        }
        return ifcheck;
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
    __getAutoFilterFields: function (objJson, autoFilterFields) {
        if (objJson == null) {
            return [];
        }
        var topStack = false;
        if (autoFilterFields == null) {
            autoFilterFields = objJson._autoFilterFields;
            if (autoFilterFields != null) {
                return autoFilterFields;
            }
            topStack = true;
            autoFilterFields = [];
        }
        var items = this.getContainerItems(objJson, true);
        for (var i = 0; i < items.length; i++) {
            var itemConfig = items[i];
            var itemType = itemConfig["widgetType"];
            if (itemType == "field" || itemType == "tag") {
                if (itemConfig.selectable != null && itemConfig.selectable.filterable && itemConfig.selectable.sixw != null) {
                    autoFilterFields.push(itemConfig);
                }
            } else { //container.
                this.__getAutoFilterFields(itemConfig, autoFilterFields);
            }
        }
        if (topStack) {
            objJson._autoFilterFields = autoFilterFields; //cache fields
        }
        return autoFilterFields;
    },
    __appendTagData: function (object, tagObject) {  //combine tag data from service to widget data.
        this.appendFieldData(object, tagObject);
    },
    __appendTagConfig: function (containerConfig, TagConfig) {  //combine tag data from service to widget data.
        var widgetItems = this.getContainerItems(containerConfig, true);
        var tagItems = this.getContainerItems(TagConfig, true);
        widgetItems = widgetItems.concat(tagItems);
        delete containerConfig["widget"];
        containerConfig["widgets"] = widgetItems;
    },
    __setRowFilter: function (widgetRoot, row, bAutoFiltered, bSearchFiltered) {
        var isRowFiltered = row.filtered != null ? row.filtered : false;
        row.autoFiltered = bAutoFiltered != null ? bAutoFiltered : row.autoFiltered;
        row.bSearchFiltered = bSearchFiltered != null ? bSearchFiltered : row.bSearchFiltered;
        if (row.autoFiltered == true || row.bSearchFiltered == true) {
            if (!isRowFiltered) {
                row.filtered = true;
                widgetRoot.countSummary.shown--;
            }
        } else {
            if (isRowFiltered) {
                row.filtered = false;
                widgetRoot.countSummary.shown++;
            }
            this.__showParent(widgetRoot, row);
        }
    },
    __showParent: function (widgetRoot, childObject) {
        if (childObject._parentObject != null && childObject._parentObject.filtered == true) {
            childObject._parentObject.filtered = false;
            widgetRoot.countSummary.shown++;
            this.__showParent(widgetRoot, childObject._parentObject);
        }
    },
    __getSortableFields: function (widgetRoot, clearSortPreference) { //returns a list of sort fields.
        var sortFieldList = [];
        var fieldIndexCache = this.__getAllFields(widgetRoot);
        for (var key in fieldIndexCache) {
            if (fieldIndexCache.hasOwnProperty(key)) {
                var field = fieldIndexCache[key];
                if (field.sort != null && field.sort.sortable == true) {
                    if (field.sort.type != null) {
                        field.sort.type = field.sort.type.toLowerCase();
                    } else {
                        field.sort.type = "string";
                    }
                    if (clearSortPreference == true) {
                        delete field.sort.order;
                    }
                    if (field.label == null || field.label.text == null) {
                        field.label = {
                            text: field.name,
                            show: "none"
                        };
                    }
                    sortFieldList.push(field);
                }
            }
        }
        return sortFieldList;
    },
    __getAllFields: function (widgetRoot, fieldIndexCache) {  //returns an object indexed by field name and value is the field itself.
        if (widgetRoot == null) {
            return {};
        }
        if (fieldIndexCache == null) {
            fieldIndexCache = widgetRoot._fieldIndexCache;
            if (fieldIndexCache != null) {
                return fieldIndexCache;
            }
            fieldIndexCache = {};
            widgetRoot._fieldIndexCache = fieldIndexCache; //cache index.
        }
        var items = this.getContainerItems(widgetRoot, true);  //includeHidden.
        for (var i = 0; i < items.length; i++) {
            var itemConfig = items[i];
            var itemType = itemConfig["widgetType"];
            if (itemType == "field") {
                if (fieldIndexCache[itemConfig.name] == null) {  //cache first field instance.
                    fieldIndexCache[itemConfig.name] = itemConfig;  //index field name.
                }
            } else { //container.
                this.__getAllFields(itemConfig, fieldIndexCache);
            }
        }
        return fieldIndexCache;
    },
    __getField: function (widgetRoot, fieldName) {  //get field by name.
        var fieldIndexCache = this.__getAllFields(widgetRoot);
        return fieldIndexCache[fieldName];
    },
    __sortWidget: function (widgetRoot, sortList /* {name: "field name", direction: "ascending/descending"}, */) {
        if (widgetRoot == null || sortList == null) {
            return;
        }
        //clear previous sort preference.
        this.__getSortableFields(widgetRoot, true); //clear previous sort preference.
        var fieldList = [];
        for ( var i = 0; i < sortList.length; i++) {
            var field = this.__getField(widgetRoot, sortList[i].name);
            if (field != null && field.sort != null && field.sort.sortable == true) {
                var dir = sortList[i].direction != null && sortList[i].direction.toLowerCase() == "descending" ? -1 : 1; //1=ascending; -1=descending.
                fieldList.push(field);
                field.sort.direction = sortList.direction;
                field.sort.dir = dir;
                field.sort.order = fieldList.length;
            }
        }
        if (fieldList.length == 0) {
            return;
        }
        var rows = [];
        var data = widgetRoot["datarecords"];
        if (data != null) {
            rows = data["datagroups"];
        }
        this.__sortDatarecords(fieldList, rows);
    },
    __sortDatarecords: function (fieldList, rows) {
        if (rows == null || rows.length == 0) {
            return;
        }
        for (var i = 0; i < rows.length; i++) {
            var children = rows[i].children;
            this.__sortDatarecords(fieldList, children);
        }
        var thisSortPref = {
            "fieldList": fieldList
        };
        var sortObjects = function (dataObjectA, dataObjectB) {
            return bpsWidgetAPIs.__compareObjects(dataObjectA, dataObjectB, thisSortPref);
        };
        rows.sort(sortObjects);
    },
    __compareObjects: function (dataObjectA, dataObjectB, thisSortPref) {
        var fieldList = thisSortPref.fieldList;
        var direction = 0;
        var difference = 0;
        for (var i = 0; i < fieldList.length; i++) {
            var field = fieldList[i];
            var values1 = this.getFieldData(field, dataObjectA);
            var values2 = this.getFieldData(field, dataObjectB);

            var lenA = values1 != null ? values1.length : 0;
            var lenB = values2 != null ? values2.length : 0;

            if (lenA == 0 && lenB == 0) {
                continue;
            } else if (lenA == 0) {
                difference = -1;
            } else if (lenB == 0) {
                difference = 1;
            } else {  //check values.
                var loop = lenA > lenB ? lenA : lenB;
                for (var j = 0; j < loop; j++) {
                    var valueObj1 = values1[j];
                    var valueObj2 = values2[j];
                    var value1 = valueObj1.sortValue;
                    var value2 = valueObj2.sortValue;
                    if (value1 == null) {
                        value1 = field.sort.type != "date" ? valueObj1.value : valueObj1.actualValue;
                        value1 = (value1 != null) ? value1 = value1.toLowerCase() : "";
                    }
                    if (value2 == null) {
                        value2 = field.sort.type != "date" ? valueObj2.value : valueObj2.actualValue;
                        value2 = (value2 != null) ? value2 = value2.toLowerCase() : "";
                    }
                    if (field.sort.type == "string") {
                        if (value1 != value2) {
                            difference = value1 > value2 ? 1 : -1;
                        }
                    } else if (field.sort.type == "stringpad") {
                        difference = value1.length() - value2.length();
                        if (difference == 0) {
                            difference = value1 > value2 ? 1 : -1;
                        }
                    } else {
                        if (value1 != value2) {
                            difference = parseFloat(value1) > parseFloat(value2) ? 1 : -1;
                        }
                    }
                    if (difference != 0) {
                        break;
                    }
                }
            }
            if (difference != 0) {
                direction = field.sort.dir;
                break;
            }
        }
        return difference * direction;
    },
    __findObject: function (rows, id) {
        var retobject = null;
        if (rows != null) {
            for (var i = 0; i < rows.length; i++) {
                if (id == rows[i].objectId || id == rows[i].relId || id == rows[i]._relId || id == rows[i].physicalId || id == rows[i].tempId) {
                    retobject = rows[i];
                    break;
                }
            }
        }
        return retobject;
    }
};
