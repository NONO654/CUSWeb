/*
 * Widget APIs
 * bpsWidgetAPIs.js
 * version 0.3
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
var bpsWidgetConversion = {
    _rawMode: false,
    hasOwn: Object.prototype.hasOwnProperty, //filter out prototype in "for in" loops
    getRawWidgetData: function (containerConfig) {
        _rawMode = true;
        return this.__drawWidget(containerConfig);
    },
    __drawWidget: function (containerConfig, widgetTypeHierachy, objectData, view) {  //jcontainerConfig: jason data from service;
        var containerType = containerConfig["widgetType"];
        if (widgetTypeHierachy == null) {
            widgetTypeHierachy = [];
        }
        if (view != null && bpsWidgetAPIs.isObjectContainer(containerType) && bpsWidgetAPIs.isObjectContainer(view.toLowerCase())) {
            containerType = view.toLowerCase();
            containerConfig["widgetType"] = containerType;
        }
        widgetTypeHierachy.push(containerType);
        if (containerConfig.availableViews != null) {
            var itemview = containerConfig.displayview;
            if (itemview == null) {
                itemview = view;
            }
            if (itemview == null || bpsWidgetAPIs.__findInArray(containerConfig.availableViews.view, itemview) == -1) {
                view = containerConfig.availableViews.view[0];
                } else {
                view = itemview;
            }
        }
        if (view != null) {
            containerConfig.displayview = view;
        }
        var containerItems = bpsWidgetAPIs.getContainerItems(containerConfig);  //get sub-widgets.
        var containerData = bpsWidgetAPIs.getContainerData(containerConfig, containerType, objectData, true);  //get data records.
        var dataloop = 1;
        if (containerData != null) {
            dataloop = containerData.length;
        }
        var containerHTMLItems = [];
        for (var i = 0; i < dataloop; i++) {  //data loop.
            objectData = containerData != null ? containerData[i] : objectData;
            var containerObjectItems = [];
            containerHTMLItems.push(containerObjectItems);
            for (var j = 0; j < containerItems.length; j++) {  //sub-widgets.
                var itemConfig = containerItems[j];
                var itemType = itemConfig["widgetType"];
                if (itemType == "field") {
                    if (_rawMode) {
                        containerObjectItems.push(this.__getRawField(itemConfig, widgetTypeHierachy, objectData));
                    } else {
                        containerObjectItems.push(bpsWidgetAPIs.drawFieldHTML(itemConfig, widgetTypeHierachy, objectData));
                    }
                } else if (itemType == "location") { //location
                    var path = itemConfig.url.path + ((itemConfig.url.path.indexOf('?') != -1) ? '&' : '?') + 'objectId=' + itemConfig.objectId;
                    containerObjectItems.push(jQuery('<object mimetype="text/html" data="' + path + '" style="width:100%">not supported</object>'));
                } else { //container.
                    containerObjectItems.push(this.__drawWidget(itemConfig, widgetTypeHierachy, objectData, view));
                }
            }
        }
        if (containerData != null && containerData.length == 0) {
            containerData = null;
        }
        var htmlContainer = null;
        if (_rawMode) {
            htmlContainer = this.__getRawContainer(containerConfig, widgetTypeHierachy, containerHTMLItems, containerData);
        } else {
            htmlContainer = bpsWidgetAPIs.drawContainerHTML(containerConfig, widgetTypeHierachy, containerHTMLItems, containerData);
        }
        widgetTypeHierachy.pop();
        return htmlContainer;
    },
    __getRawContainer: function (containerConfig, widgetTypeHierachy, containerHTMLItems, containerData) {
        var container = null;
        var items = null;
        if (containerData != null) {
            items = [];
            var levelIndexObject = null;
            for (var i = 0; i < containerHTMLItems.length; i++) {
                var item = {};                

                var containerItems = containerHTMLItems[i];
                for (var j = 0; j < containerItems.length; j++) {
                    var subitem = containerItems[j];
                    this.__mergeProperties(item, subitem);
                }
                var object = containerData[i];
                if (object.objectId != null) {
                    item["_objectId"] = object.objectId;
                }
                if (object.physicalId != null) {
                    item["_physicalId"] = object.physicalId;
                }
                var itemsPointer = null;
                if (object.level != null) {
                    var level = object.level;
                    item["_level"] = level;
                    if (levelIndexObject == null) {
                        levelIndexObject = {};
                        levelIndexObject[level-1] = items;
                    }
                    itemsPointer = levelIndexObject[level-1];
                    item.children = [];
                    levelIndexObject[level] = item.children;
                } else {
                    itemsPointer = items;
                }
                itemsPointer.push(item);
            }
        } else {
            items = {};
            var containerItems = containerHTMLItems[0];
            if (containerItems) {
                for (var i = 0; i < containerItems.length; i++) {
                    var item = containerItems[i];
                    this.__mergeProperties(items, item);
                }
            }
        }
        if (containerConfig.name == null) {
            container = items;
        } else {
            container = {};
            container[containerConfig.name] = items;
        }
        return container;
    },
    __mergeProperties: function (obj1, obj2) {
        for (var p in obj2) {
            if (obj2.hasOwnProperty(p)) {
                obj1[p] = obj2[p];
            }
        }
    },
    __getRawField: function (itemConfig, widgetTypeHierachy, objectData) {
        var values = bpsWidgetAPIs.getFieldData(itemConfig, objectData);
        var text = "";
        var actual = "";
        if (values != null) {
            for (var i = 0; i < values.length; i++) {
                if (values[i].value != null) {
                    if (i > 0) {
                        text += ",";
                    }
                    text += values[i].value;
                }
                if (values[i].actualValue != null) {
                    if (i > 0) {
                        actual += ",";
                    }
                    actual += values[i].actualValue;
                }
            }
        }
        var property = {};
        property[itemConfig.name] = text;
        if (actual != "") {
            property[itemConfig.name+"_actual"] = actual;
        }
        return property;
    }
};
