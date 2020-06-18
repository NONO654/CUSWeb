/*
 * Widget Engine
 * bpsWidgetEngine.js
 * version 0.2.0
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * bpsWidgetEngine Object
 * this file contains all the runtime logic for BPS widgets
 *
 * Requires:
 * jQuery v1.8.3 or later
 *
 */

var bpsWidgetEngine = {
    widgets: [],
    str: {
        TABLELAYOUT: "tablelayout",
        PROGRESSBAR: "PROGRESSBAR"
    },
    progBarStates: {
        WARNING: "overdue",
        INFO: "impending",
        OKAY: "",
        ERROR: "overdue"
    },
    callback: null,
    id: null,
    tnProxy: null,
    showLabel: true,
    jsonPath: "/resources/bps/widget/json/",
    widgetName: null,
    targetDiv: null,
    dom: null,
    params: "",
    cspaceKey: "SecurityContext=",
    cspace: "",
    data: null,
    viewpref: null,
    sortpref: null,
    sortdirpref: null,
    tempURI: function (widgetName) {
        widgetName = widgetName || this.widgetName;
        return this.jsonPath + widgetName;
    },
    getCspace: function() {
        return(this.cspace == null || this.cspace.length == 0 || this.cspace == "default") ? "" : this.cspaceKey + this.cspace;
    },
    processSelection: function(event, widgetId) {
        var targetElem = jQuery(event.target);
        if(targetElem[0].nodeName.toLowerCase() == 'a' || targetElem.parents('a').length) {
            //Unselect-all first since clicked on a link.
            jQuery(this).closest(".ds-widget").find(".selected").removeClass("selected");
        }
        var win = bpsTagNavConnector.getTNWindow();
        jQuery(this).toggleClass("selected");
        if(win) {
            jQuery(win.document).trigger("widget_selection_changed." + widgetId + ".bps_widget");
        }
    },
    init: function (widgetData) {
        var othis = this;
        if (widgetData) {
            this.processJSON(widgetData);
        } else {
            bpsWidgetAPIs.ajaxRequest({
                url: this.tempURI(),
                type: 'get',
                dataType: 'json',
                callback: function(data) {
                        othis.processJSON(data);
                    }
            });
        }

    },
    widget: function (initObj) {
        this.targetDiv   = initObj.div;
        this.widgetName  = initObj.name;
        this.uwaWidget   = initObj.uwaWidget;
        this.callback    = initObj.callback;
        this.cspace      = initObj.cspace;
        this.viewpref    = initObj.viewpref;
        this.sortpref    = initObj.sortpref;
        this.sortdirpref = initObj.sortdirpref;
        this.tenant      = initObj.tenant;
        //return copy of bpsWidgetEngine
        var obj = {};
        for (var key in this) {
            obj[key] = this[key];
        }
        return obj;
    },
    setLabel: function (bln) {
        this.showLabel = bln;
    },
    processJSON: function (data) {
        if (!data.success) {
            var strError = data.error;
            strError = bpsWidgetConstants.str[strError] || bpsWidgetConstants.str["NetworkError"];
            this.dom = bpsWidgetTemplate.error(strError);
        } else {
            this.data = data;
            bpsWidgetAPIs.setWidgetViewPreference(data.widgets[0], this.viewpref);
            if (this.sortpref != null) {
                bpsWidgetAPIs.sortWidget(data.widgets[0], [{name: this.sortpref, direction: this.sortdirpref}]);
            }
            this.dom = bpsWidgetAPIs.drawWidget(this);
        }
        this.drawUI();
    },
    createFieldView: function (obj) {
        var domElem = this.getTemplate(obj);
        this.processField(obj, domElem);
        return domElem;
    },
    registerTN: function (obj) {
        if (obj.id) {
            return;
        }
        obj.id = "wdg_" + Math.random();
        bpsWidgetTagNavInit.loadTagData(obj);
    },
    nodeExpandEvent: function (widget, table, node) {
        var childNodes = node.children;
        if (childNodes.length == 0) {
            var relId = node.id,
            thisRequest = {
                widget: widget,
                table: table,
                node: node
            },
            expandObjectCallback = function (children) {
                bpsWidgetEngine.processNewChildren(thisRequest.widget, thisRequest.table, thisRequest.node, children);
            };
            bpsWidgetAPIs.expandObject(widget, relId, expandObjectCallback);
        } else { //show leaf nodes with minus icon.
        jQuery.each(childNodes, function (i, childNode) {
                if (childNode.row.attr("data-leaf") == "true") {
                table.treetable("reveal", childNode.id);
            }
        });
        }
    },
    processNewChildren: function (widget, table, node, children) {
        if (children.length > 0) {
            var tempWidget = {
                datarecords: {datagroups: children},
                charts: [],
                widgets: widget.widgets,
                view: widget.view,
                _table: table,
                _node: node,
                id: widget.id,
                widgetType: "table_expand"  //special type for custom rendering.
            },
            childrenHTMItems = bpsWidgetAPIs.__drawWidget(tempWidget, null, null, null);
        }
    },
    refreshRow: function (widget, data_tr, actions_tr, obj) {
        var tempWidget = {
            datarecords: {editLink: widget.datarecords.editLink, datagroups: [obj]},
            charts: [],
            widgets: widget.widgets,
            view: widget.view,
            displayview: widget.displayview,
            _dataTr: data_tr,
            _actionsTr: actions_tr,
            _widget: widget,
            id: widget.id,
            widgetType: "row_refresh"
        };
        bpsWidgetAPIs.__drawWidget(tempWidget, null, null, null, widget);
    },
    createTableActionsRow: function (object, config, cells, treeMode, colspan) {
        return bpsWidgetTemplate.edit_actions_row(object, config, cells, treeMode, colspan);
    },
    createTableRow: function (object, config, cells, cellDefinitions, widgetId, treeMode) {
        var rowAttributes = {
            type: object.busType || "",
            oid: object.objectId || "",
            pid: object.physicalId || "",
            widgetId: widgetId,
            editMode: object._editMode
        },
        row = bpsWidgetTemplate.list_row(rowAttributes);
        if (treeMode) {
            row.attr("data-tt-id", bpsWidgetAPIs.getRelId(object));
            row.attr("data-tt-branch", true);
            if (object._parentObject) {
                row.attr("data-tt-parent-id", bpsWidgetAPIs.getRelId(object._parentObject));
            }
            if (object.leaf !== undefined) {
                row.attr("data-leaf", "true");
            }
        }
        var editDiv;
        for (var j=0; j < cells.length; j++) {
            settings = {};
            if (cellDefinitions[j].style != null && cellDefinitions[j].style.width != null) {
                settings.size = cellDefinitions[j].style.width;
            }
            td = bpsWidgetTemplate.list_cell(settings);
            td.append(cells[j]);
            row.append(td);
        }
        if (object.selected == true) {
            row.addClass("selected");
        }
        return row;
    },
    createView: function (obj) {
        var isContainer = bpsWidgetAPIs.isObjectContainer(obj.type),
        domElem = null,
        treeTable = false,
        widgetId = obj.config.id || "",
        containerItems = bpsWidgetAPIs.getContainerItems(obj.config);
        if (obj.type == "table_expand") {
            treeTable = true;
            jQuery.each(obj.children, function (i, child) {
                row = bpsWidgetEngine.createTableRow(obj.data[i], obj.config, child, containerItems, widgetId, treeTable);
                obj.config._table.treetable("loadBranch", obj.config._node, row[0]);
            });
            setTimeout(function(){bpsWidgetEngine.nodeExpandEvent(obj.config, obj.config._table, obj.config._node);}, 1); //expand leaf items.
        } else if (obj.type == "row_refresh") {
            var dataRow = bpsWidgetEngine.createTableRow(obj.data[0], obj.config._widget, obj.children[0], containerItems, widgetId, treeTable);
            obj.config._dataTr.replaceWith(dataRow);
            var colspan = dataRow.find("td").length;
            dataRow.addClass("editable");
            var actionRow = bpsWidgetEngine.createTableActionsRow(obj.data[0], obj.config._widget,  obj.children[0], treeTable, colspan);
            if ( actionRow != null) {
                obj.config._actionsTr.replaceWith(actionRow);
            }
        } else {
            //store a pointer to the domElem for pagination
            //this is destroyed in bpsWidgetAPIs __drawWidget
            if (obj.config._domElem) {
                domElem = obj.config._domElem;
            } else {
                domElem = this.getTemplate(obj);
                obj.config._domElem = domElem;
            }
            if (obj.type == "list" || obj.type == "table") {
                var tbodyElem = domElem.find('tbody'),
                row = null, td, settings, rootCounter = 0;
                
                if (obj.type == "table") {
                    if (obj.children.length != 0 && obj.data[0].level !== undefined) {
                        treeTable = true;
                    }
                    //draw table header in the same table.
                    var headers = bpsWidgetAPIs.getTableHeaders(obj.config);
                    row = bpsWidgetTemplate.list_row_header();
                    tbodyElem.append(row);
                    for (var j=0; j < headers.length; j++) {
                        settings = {};
                        if (containerItems[j].style != null && containerItems[j].style.width != null) {
                            settings.size = containerItems[j].style.width;
                        }
                        td = bpsWidgetTemplate.list_cell_header(settings);
                        td.append(headers[j]);
                        row.append(td);
                    }
                }
                jQuery.each(obj.children, function (i, child) {
                    row = bpsWidgetEngine.createTableRow(obj.data[i], obj.config, child, containerItems, widgetId, treeTable);
                    if (treeTable && obj.data[i]._parentObject == null) {
                        rootCounter++;
                    }
                    if (!treeTable && bpsWidgetAPIs.isObjectEditable(obj.config, child)) {
                        var colspan = row.find("td").length;
                        var actionRow = bpsWidgetEngine.createTableActionsRow(obj.data[i], obj.config, child, treeTable, colspan);
                        if ( actionRow != null) {
                            tbodyElem.append(actionRow);
                            row.addClass("editable");
                        }
                    }
                    var strVal = "";
                    try {
                        strVal = bpsWidgetAPIs.getFieldValue(obj.data[i],"name").displayValue || "";
                    } catch(e) {
                        //do nothing
                    }
                    row.attr("data-title", strVal);                    
                    tbodyElem.append(row);
                });
                if (treeTable) {
                    var tableDom = domElem,
                    tableWidget = obj.config,
                    processExpand = true;
                    domElem.treetable({ expandable: true,
                                        clickableNodeNames : false,
                                        onNodeExpand: function() {
                                            if (processExpand) {
                                                processExpand = false;
                                                bpsWidgetEngine.nodeExpandEvent(tableWidget, tableDom, this);
                                                processExpand = true;
                                            }
                                        }
                    });
                    if (rootCounter == 1) {
                        domElem.treetable("expandNode", bpsWidgetAPIs.getRelId(obj.data[0]));
                    }
                }
            } else {
                //domElem = this.getTemplate(obj);
                jQuery.each(obj.children, function (i, child) {
                    var parentDom = domElem;
                    if (obj.data) {
                        var domElemChild;
                        if (child.length > 1) {
                            domElemChild = bpsWidgetTemplate.group({type: 'group', layout: obj.layout});
                            domElem.append(domElemChild);
                            parentDom = domElemChild;
                        } else {
                            domElemChild = child[0];
                        }
                        if (obj.type == "channel") {
                            domElemChild.attr("data-objectId", obj.data[i].objectId || "");
                            domElemChild.attr("data-type", obj.data[i].busType || "");
                            domElemChild.attr("data-pid", obj.data[i].physicalId || "");
                            domElemChild.attr("data-title", "");
                            //add click to domElemChild here
                            domElemChild.click(function (event) {
                                bpsWidgetEngine.processSelection.call(this, event, obj.config.id);
                            });
                        }
                    }
                    for (var j=0; j < child.length; j++) {
                        if (containerItems[j] && containerItems[j].style) {
                            if (containerItems[j].style.width) {
                                child[j].css("width", containerItems[j].style.width);
                            }
                            if (obj.type != "experience" && containerItems[j].style.height) {
                                child[j].css("height", containerItems[j].style.height);
                            }
                        }
                        parentDom.append(child[j]);
                    }
                });
            }
            if (obj.children.length == 0 && domElem) {
                var noObjectsElem = obj.config.countSummary.total == 0 ? bpsWidgetTemplate.message(bpsWidgetConstants.str.NoObjectsFound) :
                                                                         bpsWidgetTemplate.message(bpsWidgetConstants.str.AllObjectsFiltered);
                domElem.append(noObjectsElem);
            }
            if (!isContainer) {
                if (obj.config.style && obj.config.style.height) {
                    domElem.css({height: obj.config.style.height, overflow:"hidden"});
                }
                // linked container.
                if (obj.type == "group") {
                    this.checkLink(obj, domElem);
                }
            }
        }
        return domElem;
    },
    getTemplate : function(obj) {
        var dom;
        obj.showLabel = this.showLabel;
        if (bpsWidgetTemplate[obj.type]) {
            dom = bpsWidgetTemplate[obj.type](obj);
        } else {
            dom = bpsWidgetTemplate.container(obj);
        }
        if (obj.config && obj.config.style && obj.config.style.cssClass) {
            dom.addClass(obj.config.style.cssClass);
        }
        return dom;
    },
    drawUI: function () {
        if (this.callback && typeof this.callback === "function") {
            this.callback(this.dom);
        } else {
            jQuery('#' + this.targetDiv).append(this.dom);
        }
    },
    emptyContainer: function ($elem) {
        $elem[0].innerHTML = "";
    },
    reDrawWidget: function (widget, view) {
        this.emptyContainer(widget.container);
        widget.container.append(bpsWidgetAPIs.__drawWidget(widget, null, null, view));
        widget.container.unwrap();
    },
    refresh: function (experienceObj) {
        var othis = this;
        //call service with widget name
        bpsWidgetAPIs.ajaxRequest({
            url: this.jsonPath + experienceObj.name,
            type: 'get',
            dataType: 'json',
            callback: function(data) {
                    if (!data.success) {
                        var strError = data.error;
                        strError = bpsWidgetConstants.str[strError] || bpsWidgetConstants.str["NetworkError"];
                        experienceObj.widget.container.html(bpsWidgetTemplate.message(strError));
                    } else {
                        experienceObj.widget.datarecords = data.widgets[0].widget.datarecords;//swapping out data records.
                        experienceObj.widget.widgets = data.widgets[0].widget.widgets;//swapping out widget definition.
                        if (experienceObj._sortList != null) {
                             bpsWidgetAPIs.sortWidget(experienceObj, experienceObj._sortList);
                        }

                        bpsWidgetTagNavInit.loadTagData(experienceObj.widget);

                        othis.emptyContainer(experienceObj.widget.container);
                        experienceObj.widget.container.append(bpsWidgetAPIs.__drawWidget(experienceObj.widget));
                        experienceObj.widget.container.unwrap();
                    }
                }
        });
    },
    processField: function (obj, fld) {
        //The nested if tests ORDER is important, please keep tests nested correctly
        var drawData = true;
        if (obj.config) {
            if (obj.config.style) {

                // field align attribute
                if (obj.config.style.align) {
                    fld.addClass(obj.config.style.align.toLowerCase());
                }

            }//end:if (obj.config.style)

            if (obj.config.ui) {
                // specific formats like progress, dates etc.
                if (obj.config.ui.type) {
                    switch (obj.config.ui.type) {
                    case this.str.PROGRESSBAR:
                        if(!isNaN(obj.values[0].value)){
                            var objProg = {
                                percent: obj.values[0].value,
                                state : this.progBarStates[obj.values[0].status] || ""
                            };
                            fld.append(bpsWidgetTemplate.progress(objProg));
                            //fld.css('width', '100%');
                            fld.addClass('progress-bar');
                            drawData = false;
                        }
                        break;

                    default:
                        break;
                    }
                }
            }//end:if (obj.cofig.ui)

            // Text Label for field
            if (obj.config.label) {
                var lbl = obj.config.label.text;
                if (lbl) {
                    var lblDom = bpsWidgetTemplate.label(lbl);
                    if (obj.config.label.show) {
                        lblDom.addClass(obj.config.label.show.toLowerCase());
                    }
                    fld.append(lblDom);
                }
            }

        }//end:if (obj.config)

        var defaultImage = (obj.config && obj.config.image) ? obj.config.image["default"] : null;
        var iSize;
        if ((obj.values && obj.values[0]) || defaultImage) {
            var iUrl;
            if (obj.values && obj.values[0] && obj.values[0].imageValue) {
                iUrl = obj.values[0].imageValue;
                iSize = obj.values[0].imageSize;
            } else {
                iUrl = defaultImage;
            }

             // Image field
            if (iUrl) {
                var iWidth, iHeight, iAttr, imgObj, iStatus, iStatusText, objStatus;
                if(iUrl.indexOf("../") == 0){// cleanup relative paths
                    iUrl = enoviaServer.getUrl() + iUrl.substring(2);
                } else if(iUrl.indexOf("/") == 0){// cleanup relative paths
                    iUrl = enoviaServer.getUrl() + iUrl;
                }
                if(!iSize) {
                    iAttr = (obj.config && obj.config.image) ? obj.config.image : {};
                    iWidth = iAttr.width;
                    iHeight = iAttr.height;
                    iSize = iAttr.size;
                    //set image and container heights
                    switch (iSize) {
                    case "THUMBNAIL":
                        iHeight = "60px";
                        break;
                    case "SMALL":
                        iHeight = "62px";
                        break;
                    case "MEDIUM":
                        iHeight = "108px";
                        break;
                    case "LARGE":
                        iHeight = "480px";
                        break;
                    default:
                        break;
                    }
                } else {
                    if(iSize == "ICON") {
                        iHeight = "16px";
                        iAttr = (obj.config && obj.config.image) ? obj.config.image : {};
                        iSize = iAttr.size;
                    }
                }
                imgObj = bpsWidgetTemplate.image({url: iUrl, width: iWidth, height: iHeight, size: iSize});
                if (obj.values && obj.values[0]) {
                    iStatus     = obj.values[0].badgeStatus || null;
                    iStatusText = obj.values[0].badgeTitle || "";
                    if (iStatus !== null) {
                        objStatus =  bpsWidgetTemplate.badge({status:iStatus.toLowerCase(), hovertext: iStatusText});
                        imgObj.append(objStatus);
                    }
                }
                fld.append(imgObj);
                drawData = false;
            }

            if (drawData) {
                // check if this field is editable
                var isFieldEditable = false;
                if (obj.config.selectable && obj.config.selectable.editable) {
                    //check if specific object is not editable for this field.
                    if (obj.data.dataelements[obj.config.name].editable !== false) { 
                        isFieldEditable = obj.config.selectable.editable;
                    }
                }
                var editMode = obj.data._editMode;
                if ( editMode == true) {
                    fld.append(this.__createField(obj, isFieldEditable));
                } else {
                    fld.append(this.__createField(obj, false));
                }
            }
        }

        // linked field
        this.checkLink(obj, fld);
    },
    checkLink: function (obj, domElem) {
        var inEditMode = false;
        if (obj.objectData && obj.objectData._editMode) {
            inEditMode = true;
        }
        if (!inEditMode && obj.config && obj.config.url) {
            var objUrl, tmpUrl;
            tmpUrl = this.processUrl(obj.config, obj.objectData, obj);
            objUrl = {
                url: tmpUrl,
                target: obj.config.url.target /*|| obj.config.widget.id*/
            };
            domElem.wrapInner(bpsWidgetTemplate.link(objUrl));
        }
    },
    processUrl: function (urlFieldConfig, object, fieldValue) {
        var param, tmpUrl, arrParam = [];
        if (fieldValue && fieldValue.values && fieldValue.values[0] && fieldValue.values[0].urlValue) {
            tmpUrl = fieldValue.values[0].urlValue;
        } else {
            tmpUrl = urlFieldConfig.url.path;
        }
        // cleanup relative paths
        if (tmpUrl.indexOf("?") == 0){
            tmpUrl = enoviaServer.getUrl() + tmpUrl;
        } else if (tmpUrl.indexOf("../") == 0){
            tmpUrl = enoviaServer.getUrl() + tmpUrl.substring(2);
        } else if (tmpUrl.indexOf("/") == 0){
            tmpUrl = enoviaServer.getUrl() + tmpUrl;
        } else if (tmpUrl.indexOf("javascript") == 0){
            return tmpUrl; 
        }
        //parameters
        if (object) {
            if (tmpUrl.indexOf("objectId=") == -1 && tmpUrl.indexOf("physicalId=") == -1)  {
                if (object.objectId)  {
                    arrParam.push("objectId=" + object.objectId);
                }
                if (object.physicalId) {
                    arrParam.push("physicalId=" + object.physicalId);
                }
            }
        }
        if (enoviaServer.tenant && enoviaServer.tenant.length > 0) {
            arrParam.push("tenant=" + enoviaServer.tenant);
        }
        //add the cspace parameter
        var csp = this.getCspace();
        if (csp.length > 0) {
            arrParam.push(csp);
        }
        if (arrParam.length > 0) {
            param = (tmpUrl.indexOf("?") != -1) ? "&" : "?";
            param += arrParam.join("&");
            //add params to url
            tmpUrl += param;
        }
        return tmpUrl;
    },
    addEditEvent: function (editable, field, obj, controlType) {
        editable.click(function() {
            bpsWidgetEngine.__editFieldClickHandler(editable, field, obj, controlType);
        });
    },
    __editFieldClickHandler: function (editable, field, obj, controlType) {
        var ofield = field, oobj = obj, oeditable = editable;
        // Don't allow editing if another field is being edited for this object.
        if (bpsWidgetEngine.__visiblePopups(editable) ) {
            return;
        }
        // Close any popups opened in other objects.
        bpsWidgetEngine.__closePopups(editable);
        // Create edit pop up.
        var popDiv = bpsWidgetTemplate.edit_popup_div(controlType, editable, field);
        var bodyDiv = popDiv.find('div.body');
        var ul = jQuery("<ul />");
        var li = jQuery("<li />");
        var origText = editable.text();
        var popupInput;
        switch (controlType) {
        case "textbox":
            popupInput = jQuery('<input is-editable="true" type="text" field-name="' + field + '" value="' + origText + '">');
            break;
        case "textarea":
            popupInput = jQuery('<textarea is-editable="true" field-name="' + field + '">' + origText + '</textarea>');
            break;
        case "combo":
            popupInput = jQuery('<input is-editable="true" type="text" field-name="' + field + '" value="' + origText + '">');
            var range = obj.config.range;
            popupInput = jQuery('<select is-editable="true" field-name="' + field + '">');
            var display, value, option;
            var selected = ( display == origText ? "selected" : "");
            if (range && range.item && range.item.length > 0) {
                jQuery.each(range.item, function(key, item) {
                    display = item.display;
                    value = item.value;
                    var selected = ( display == origText ? "selected" : "");
                    option = jQuery('<option value="' + value + '" ' + selected + '>'+ display + '</option>');
                    popupInput.append(option);
                });
            }
            break;
        case "radio":
            var range = obj.config.range;
            popupInput = jQuery('<span is-editable="true" field-name="' + field + '">');
            if (range && range.item && range.item.length > 0) {
                    var option, checked = "";
                jQuery.each(range.item, function(key, item) {
                    display = item.display;
                    value = item.value;
                    checked = ( display == origText ? "checked" : "");
                    option = jQuery('<label><input type="radio" ' + checked + ' is-editable="true" value="'+ value + '" name="'+ field +'"/>'+display+'</label><br/>');
                    popupInput.append(option);
                });
            }
            break;
        case "checkbox":
            var item_arr = [];
            var items = origText.split('|');
            for (var j = 0; j < items.length; j++) {
                item_arr.push(items[j]);
            }
            popupInput = jQuery('<span is-editable="true" field-name="' + field + '">');
            var range = obj.config.range;
            if (range && range.item && range.item.length > 0) {
                var size = range.item.length, option, checked = "";
                jQuery.each(range.item, function(key, item) {
                    display = item.display;
                    value = item.value;
                    checked = ( jQuery.inArray(display, item_arr) != -1 ? "checked" : "");
                    option = jQuery('<label><input type="checkbox" ' + checked + ' is-editable="true" value="'+ value + '" name="'+ field +'"/>'+ display +'</label><br/>');
                    popupInput.append(option);
                });
                // Heck to force single checkbox selection since multi-value edit is not yet supported in the engine.
                popupInput.find("input[type=checkbox]").on('click', function() {
                    popupInput.find("input[type=checkbox]").not(this).attr('checked', false);
                });
            }
            break;
        case "listbox":
            var item_arr = [];
            var items = origText.split('|');
            for (var j = 0; j < items.length; j++) {
                item_arr.push(items[j]);
            }
            var range = obj.config.range;
            if (range && range.item && range.item.length > 0) {
                //FIXME move these to where ever we have preferences/properties.
                var MIN_LISTBOX_ROWS = 1, MAX_LISTBOX_ROWS = 8;
                var numOptions = (range.item.length > MAX_LISTBOX_ROWS ? MAX_LISTBOX_ROWS : range.item.length);
                numOptions = (numOptions < MIN_LISTBOX_ROWS ? MIN_LISTBOX_ROWS : numOptions);
                var multiSelect = ""; // NOTE: we're only supporting single select for now.
                popupInput = jQuery('<select class="listbox" is-editable="true" field-name="' + field + '" ' + multiSelect + ' size="' + numOptions + '">');
                var option, selected = "";
                jQuery.each(range.item, function(key, item) {
                    display = item.display;
                    value = item.value;
                    selected = ( jQuery.inArray(display, item_arr) != -1 ? "selected" : "");
                    option = jQuery('<option ' + selected + ' is-editable="true" value="' + value + '" name="' + field + '">' + display + '</option>');
                    popupInput.append(option);
                });
            }
            break;
        case "date":
            popupInput= jQuery("<div />");
            popupInput.datepicker({
                clickInput:true,
                dateFormat:"M d, yy",
                onSelect: function(displayValue, inst) {
                    var actualValue = popupInput.datepicker('getDate').getTime();
                    editable.text(displayValue);
                    editable.addClass("modified");
                    bpsWidgetAPIs.modifyObject(obj.widget, obj.data.objectId, [{"name": field, "value": {"displayValue": displayValue, "actualValue": actualValue} }] );

                    // close popup
                    popDiv.remove();
                    bpsWidgetAPIs.__disableEditButtons(editable, false);
                },
                showOn:"focus",
                showButtonPanel:true,
                currentText: "Clear"
            });
            
            var clearButton = popupInput.find(".ui-datepicker-current");
            clearButton.click( function() {
                editable.text("");
                editable.addClass("modified");
                bpsWidgetAPIs.modifyObject(obj.widget, obj.data.objectId, [{"name": field, "value": {"displayValue": "", "actualValue": ""} }] );
                // close popup
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
            });
            
            var doneButton = popDiv.find("button.done");
            doneButton.hide();
            break;
        case "numerictextbox":
            popupInput = jQuery('<input is-editable="true" type="text" field-name="' + field + '" value="' + origText + '">');
            break;
        }
        li.append(popupInput);
        ul.append(li);
        bodyDiv.append(ul);
        // Add listener on the popup's done button
        var doneButton = popDiv.find("button.done");
        doneButton.click(function () {
            switch (controlType) {
            case "textbox":
            case "textarea":
                var newValue = popupInput.val();
                editable.attr("value", newValue);
                editable.text(newValue);
                editable.addClass("modified");
                bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": newValue, "actualValue": newValue} }] );
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "combo":
                var displayValue = popupInput.find(":selected").text();
                editable.text(displayValue);
                editable.addClass("modified");
                bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": displayValue, "actualValue": popupInput.val()} }] );
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "radio":
                var radioButton = popupInput.find(":checked");
                var displayValue = radioButton.parent("label").text();
                var newValue = radioButton.val();
                editable.text(displayValue);
                editable.attr("value", newValue);
                editable.addClass("modified");
                bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": displayValue, "actualValue": newValue} }] );
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "checkbox":
                var checkboxes = popupInput.find("input[type='checkbox']:checked");
                var displayValues = "";
                if ( checkboxes.length > 0 ) {
                    var value_arr = [], display_arr = [];
                    jQuery.each(checkboxes, function() {
                        var checkbox = jQuery(this);
                        value_arr.push(checkbox.val());
                        display_arr.push(checkbox.parent("label").text());
                    });
                    // Note: we're only supporting single select for now.
                    var newValue = value_arr.pop();
                    var displayValue = display_arr.pop();
                    editable.text(displayValue);
                    editable.addClass("modified");
                    bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": displayValue, "actualValue": newValue} }] );
                }
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "listbox":
                var selected = popupInput.find("option:selected");
                if ( selected.length > 0 ) {
                    var value_arr = [];
                    var display_arr = [];
                    jQuery.each(selected, function() {
                        value_arr.push(jQuery(this).val());
                        display_arr.push(jQuery(this).text());
                    });
                    if ( value_arr.length > 0 ) {
                        // NOTE: we're only supporting single select for now.
                        var newValue = value_arr.pop();
                        var displayValue = display_arr.pop();
                        editable.text(displayValue);
                        editable.addClass("modified");
                        bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": displayValue, "actualValue": newValue} }] );
                    }
                }
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "date":
                popDiv.remove();
                bpsWidgetAPIs.__disableEditButtons(editable, false);
                break;
            case "numerictextbox":
                var numValue = popupInput.val();
                if ( ! jQuery.isNumeric(numValue) ) {
                    // write error message to actions row
                    var fieldName = ofield;
                    var label = oeditable.siblings('label');
                    if ( label != null && label.text().length > 0 ) {
                        fieldName = label.text();
                    }
                    var msg = 'The value for field "' + fieldName + '" must be a numeric value!';
                    bpsWidgetEngine.__displayMsg(oeditable, msg, "error");
                }
                else {
                    bpsWidgetEngine.__clearMsg(oeditable);
                    editable.attr("value", popupInput.val());
                    editable.text(popupInput.val());
                    editable.addClass("modified");
                    bpsWidgetAPIs.modifyObject(oobj.widget, oobj.data.objectId, [{"name": ofield, "value": {"displayValue": popupInput.val(), "actualValue": popupInput.val()} }] );
                    popDiv.remove();
                    bpsWidgetAPIs.__disableEditButtons(oeditable, false);
                }
                break;
            }
        });  // end listener on the popup's done button
        // Position the edit pop up.
        bpsWidgetEngine.__positionPopup(editable, popDiv);
        bpsWidgetAPIs.__disableEditButtons(editable, true);
    },
    __createField: function(obj, isEditable) {
        var control,
        // default control type is a text box.
        controlType = "textbox",
        format = "",
        displayValue = obj.values[0].value,
        fieldName = obj.config.name;

        if ( !isEditable ) {
            // this is a read-only field
            return bpsWidgetTemplate.text(displayValue, fieldName);
        }

        if ( obj.config.ui && obj.config.ui.inputType ) {
            controlType = obj.config.ui.inputType.toLowerCase();
        }


        if ( obj.config.selectable && obj.config.selectable.format ) {
            format = obj.config.selectable.format.toLowerCase();
        }

        switch(controlType) {
        case "textbox":
            switch(format) {
            case "date":
                control = bpsWidgetTemplate.date_editable(displayValue, fieldName, obj);
                break;
            case "numeric":
                control = bpsWidgetTemplate.numeric_editable(displayValue, fieldName, obj);
                break;
            default:
                control = bpsWidgetTemplate.textbox_editable(displayValue, fieldName, obj);
                break;
            }
            break;
        case "textarea":
            control = bpsWidgetTemplate.textarea_editable(displayValue, fieldName, obj);
            break;
        case "combobox":
            control = bpsWidgetTemplate.combobox_editable(displayValue, fieldName, obj);
            break;
        case "radiobutton":
            control = bpsWidgetTemplate.radiobutton_editable(displayValue, fieldName, obj);
            break;
        case "checkbox":
            control = bpsWidgetTemplate.checkbox_editable(displayValue, fieldName, obj);
            break;
        case "listbox":
            control = bpsWidgetTemplate.listbox_editable(displayValue, fieldName, obj);
            break;
        default:
            // unknown control type, display as read-only text.
            control = bpsWidgetTemplate.text(displayValue, fieldName);
            break;
        }
        return control;
    },
    __positionPopup : function(field, popDiv) {
        // If space permits we're adding the popup div to the right of the field.
        var ARROW_PAD = 10;
        var table = field.parents("table:first");
        table.after(popDiv);
        var offset = field.offset();
        var popupWidth = popDiv.outerWidth();
        var popupHeight = popDiv.outerHeight(true);
        var fieldWidth = field.outerWidth();
        var fieldHeight = field.outerHeight();
        var popupRightMargin = offset.left + fieldWidth + popupWidth;
        var tableRightMargin = table.outerWidth();
        var popupLeft;
        var popupTop;

        if ( popupHeight/2 > offset.top - 30 ) {  // 30px to account for widget label header.
            // Popup will be off the top of the page so move below the field.
            popupLeft = offset.left + fieldWidth/2 - popupWidth/2;
            popDiv.addClass("top");  // for the arrow.
            popupTop = offset.top + fieldHeight + ARROW_PAD;
        }
        else if ( popupRightMargin <= tableRightMargin ) {
            // display popup to right of the field
            popupTop = offset.top  - (popupHeight/2 - fieldHeight/2 );
            popupLeft = offset.left + fieldWidth + ARROW_PAD;
        }
        else {
            // Popup will be outside of the right margin of the page so display popup to left of the field.
            popupLeft = offset.left - popupWidth - ARROW_PAD;
            if ( popupLeft < 0 ) {
                popupLeft = 0;
            }
            popupTop = offset.top  - (popupHeight/2 - fieldHeight/2 );
            popDiv.addClass("right");  // for the arrow.
        }
        popDiv.offset({top: popupTop, left: popupLeft});

    },
    __visiblePopups: function (editField) {
        var tr = editField.parents("tr:first");
        var oid = tr.attr("data-objectid");
        var table = editField.parents("table:first");
        var popups = table.siblings('div.popup[data-objectid="' + oid + '"]');
        if (popups.length > 0)
            return true;
        else
            return false;
    },
    __closePopups: function (editField) {
        var table = editField.parents("table:first");
        var popups = table.siblings('div.popup');
        jQuery.each(popups, function() {
            var popDiv = jQuery(this);
            var oid = popDiv.attr("data-objectid");
            var fieldName = popDiv.attr("field-name");
            var tr = table.find('tr[class="list-row"][data-objectid="' + oid + '"]');
            var span = tr.find('span.editable-field[field-name="'+ fieldName + '"]');
            bpsWidgetAPIs.__disableEditButtons(span, false);
            bpsWidgetEngine.__clearMsg(span);
            popDiv.remove();
        });
    },
    __displayMsg: function (field, text, condition) { // condition: "info", "warn", "error".
        var cond;
        if ( condition == null ) {
            cond = "info";
        } else {
            cond = condition.toLowerCase();
        }
        if ( cond != "info" && cond != "warn" && cond != "error" ) {
            cond = "info";
        }
        var tr = field.parents("tr:first");
        var oid = tr.attr("data-objectid");
        var table = field.parents("table:first");
        var action_tr = table.find('tr.editable-actions[data-objectid="' + oid + '"]');
        var divMsg = action_tr.find('div.messages');
        divMsg.addClass(cond);
        divMsg.text(text);
        field.addClass(cond); // for color highlighting the field
        return divMsg;
    },
    __clearMsg: function (field) {
        var tr = field.parents("tr:first");
        var oid = tr.attr("data-objectid");
        var table = field.parents("table:first");
        var action_tr = table.find('tr.editable-actions[data-objectid="' + oid + '"]');
        var divMsg = action_tr.find('div.messages');
        divMsg.removeClass('info warn error');
        this.emptyContainer(divMsg);
        field.removeClass('info warn error');
    }
};
