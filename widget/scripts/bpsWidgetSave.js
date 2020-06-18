/*
 * Widget Save APIs
 * bpsWidgetSave.js
 * version 1.3
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
var bpsWidgetSave = {
    addObject: function (widget, parent /*id or object*/, fields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/, index) {
        var relationship;
        var tempId = bpsWidgetSave.addRelatedObject(widget, relationship, parent, fields, index);
        return tempId;
    },
    addRelatedObject: function (widget, relationship, parent /*id or object*/, fields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/, index) {
        var newObject = bpsWidgetSave.__newObject(fields),
            parentObject = bpsWidgetAPIs.getObject(widget, parent);
        var tempId = bpsWidgetSave.__addObject(widget, relationship, parentObject, newObject, index);
        return tempId;
    },
    modifyObject: function (widget, id /*id or object*/, updatedFields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/) {
        var object = bpsWidgetAPIs.getObject(widget, id);
        for (var i=0; i < updatedFields.length; i++) {
            var field = updatedFields[i];
            var currentvalues = bpsWidgetAPIs.getFieldData(field, object);
            if (currentvalues == null || currentvalues.length == 0) {
                //add an empty value object to hold the multiple values.
                currentvalues = [{}];
                object.dataelements[field.name] = {value: currentvalues};
            }
            if (field.value.displayValue !== undefined) { //need to handle multi-value scenarios.
                if (currentvalues[0].prevDisplay === undefined) {
                    currentvalues[0].prevDisplay = currentvalues[0].value || "";
                }
                currentvalues[0].value = field.value.displayValue;
            }
            if (field.value.actualValue !== undefined) {
                if (currentvalues[0].prevActual === undefined) {
                    currentvalues[0].prevActual = currentvalues[0].actualValue || "";
                }
                currentvalues[0].actualValue = field.value.actualValue;
            }
        }
        if (object.updateAction === undefined) {
            object.updateAction = "MODIFY";
            bpsWidgetSave.__addToModifiedList(widget, null, object);
        }
    },
    modifyRelatedObject: function (widget, relationship, parent /*id or object*/, id, updatedFields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/) {
        var object = bpsWidgetAPIs.getRelatedObject(widget, relationship, parent, id);
        bpsWidgetSave.modifyObject(widget, object, updatedFields);
    },
    cancelObject: function (widget, id /*id or object*/) {
        var fieldvalues,
        object = bpsWidgetAPIs.getObject(widget, id);

        if (object.updateAction == "MODIFY") {
            bpsWidgetSave.__deletePrevValues(object, true);
            delete object.updateAction;
            delete object._updateAction;
        }
    },
    deleteObject: function (widget, id /*id or object*/) {
        var object = bpsWidgetAPIs.getObject(widget, id);
        object.updateAction = "DELETE";
        bpsWidgetSave.__addToModifiedList(widget, null, object);
    },
    deleteRelatedObject: function (widget, relationship, parent /*id or object*/, id) {
        var object = bpsWidgetAPIs.getRelatedObject(widget, relationship, parent, id);
        bpsWidgetSave.deleteObject(widget, object);
    },
    applyUpdates: function (widget, callback, showError, saveId) {
        //send updated objects to server.
        var modifiedInfo = bpsWidgetSave.__generateUpdateWidget(widget, saveId);
        if (modifiedInfo == null) {
            return; //nothing to save.
        }
        var updateWidget = modifiedInfo.updateWidget;
        var widget_post_data = "updateWidget=" + encodeURIComponent(JSON.stringify(updateWidget));

        var thisRequest = {
            showError: showError,
            callbackFunction: callback
        };

        var applyUpdatesDone = function (data) {
            if (!data.success) {
                var strError = data.error,
                strErrorMsg = bpsWidgetConstants.str[strError] || bpsWidgetConstants.str.NetworkError;
                if (showError != false) {
                    alert(strErrorMsg);
                    //return;
                } else if ("WidgetUpdateError" != strError) {
                    alert(strErrorMsg);
                }
            }
            if (data.success || "WidgetUpdateError" == strError) {
                //copy ids of newly created objects.
                bpsWidgetAPIs.__copyIds(data.widgets[0].datarecords, updateWidget.datarecords, modifiedInfo.clonedObjects, data.success);
                widget.datarecords.csrf = data.widgets[0].datarecords.csrf;
            }
            if (thisRequest.callbackFunction) {
                thisRequest.callbackFunction.call(this, data.success);
            }
        };

        bpsWidgetAPIs.ajaxRequest({
            url: "/resources/bps/widget",
            type: 'POST',
            dataType: 'json',
            data: widget_post_data,
            callback: applyUpdatesDone
        });
    },
    isObjectEditable: function (widget, id /*id or object*/) {
        if (widget.datarecords && widget.datarecords.editLink == true) {
            var object = bpsWidgetAPIs.getObject(widget, id);
            if (object.editable == false) {
                return false;
            } else {
                return true;
            }
        }
        return false;
    },
    isDirty: function (rowObject) {
        var dirty = false;
        if ( rowObject && rowObject.updateAction == "MODIFY") {
            dirty = true;
        }
        return dirty;
    },
    assignEditEventListeners: function (config, obj, editButton, doneButton, cancelButton) {
        bpsWidgetSave.__addEditEventListener(config, obj, editButton);
        bpsWidgetSave.__addDoneCancelEventListener(config, obj, doneButton, true);
        bpsWidgetSave.__addDoneCancelEventListener(config, obj, cancelButton, false);
    },
    __addObject: function (widget, relationship, parentObject, newObject, index) {
        var rows;
        if (parentObject == null) {
            rows = widget.datarecords.datagroups;
        } else if (relationship != null) {
            if (parentObject.relateddata === undefined) {
                parentObject.relateddata = {};
            }
            if (parentObject.relateddata[relationship] === undefined) {
                parentObject.relateddata[relationship] = {
                    name: relationship,
                    datagroups: []
                };
            }
            rows = parentObject.relateddata[relationship].datagroups;
        } else {
            if (parentObject.children === undefined) {
                parentObject.children = [];
            }
            rows = parentObject.children;
        }
        if (index == null) {
            rows.push(newObject);
        } else {
            //insert object in list.
            rows.splice(index, 0, newObject);
        }
        newObject.updateAction = "CREATE";
        newObject.tempId = "temp_" + new Date().getTime() + Math.random();
        newObject.widgetType = "datagroup";

        bpsWidgetSave.__addToModifiedList(widget, parentObject, newObject, relationship);
        return newObject.tempId;
    },
    __addToModifiedList: function (widget, parentObject, childObject, relationship) {
        var modifiedList = widget._modifiedObjectList;
        if (modifiedList == null) {
            modifiedList = [];
            widget._modifiedObjectList = modifiedList;
        }
        if (parentObject == null) {
            relationship = childObject._relationship;
            parentObject = childObject._relationshipParentObject;
        }
        modifiedList.push({
            parent: parentObject,
            child: childObject,
            relationship: relationship
        });
    },
    __copyIds: function (modifedUpdateWidget, updateWidget, masterReference, success) {  //copy new object ids of newly created objects into master data (target).
        var id, master;
        for (var key in modifedUpdateWidget) {
            if (key == "datagroups" || key == "children" || key == "relateddata") {
                var sourceItems = modifedUpdateWidget[key];
                var targetItems = updateWidget[key];
                if (targetItems == null) {
                    if (success) {
                        //new structure sent by server during update.  add new structure to master data.
                        id = bpsWidgetAPIs.getId(updateWidget);
                        master = masterReference[id].source;
                        master[key] = sourceItems;
                    }
                    continue;
                }
                if (key == "relateddata") {
                    for (var rel in sourceItems) {
                        bpsWidgetSave.__copyIds(sourceItems[rel], targetItems[rel], masterReference, success);
                    }
                } else {
                    for (var i=0; i < sourceItems.length; i++) {
                        bpsWidgetSave.__copyIds(sourceItems[i], targetItems[i], masterReference, success);
                    }
                }
            } else if (key == "updateAction") {
                id = bpsWidgetAPIs.getId(updateWidget);
                master = masterReference[id].source;
                master.updateMessage = modifedUpdateWidget.updateMessage;
                master.updateSuccessful = modifedUpdateWidget.updateSuccessful;
                if (success) {
                    delete master._updateAction;  //delete pending status.
                    delete master.updateAction;  //delete update action.
                    if (modifedUpdateWidget[key] == "CREATE") {
                        master.objectId = modifedUpdateWidget.objectId;
                        master.physicalId = modifedUpdateWidget.physicalId;
                        master.relId = modifedUpdateWidget.relId;
                        bpsWidgetAPIs.appendFieldData(master, modifedUpdateWidget);
                    } else if (modifedUpdateWidget[key] == "MODIFY") {
                        bpsWidgetSave.__deletePrevValues(master, false);
                    } else if (modifedUpdateWidget[key] == "DELETE") {
                        try {
                            //remove object from array.
                            var index;
                            if (master._relationshipParentObject) {
                                index = master._relationshipParentObject.relateddata[master._relationship].datagroups.indexOf(master);
                                master._relationshipParentObject.relateddata[master._relationship].datagroups.splice(index, 1); //remove 1 item at index.
                            } else if (master._parentObject) {
                                index = master._parentObject.children.indexOf(master);
                                master._parentObject.children.splice(index, 1); //remove 1 item at index.
                            } else if (master._parentRecords) {
                                index = master._parentRecords.indexOf(master);
                                master._parentRecords.splice(index, 1); //remove 1 item at index.
                            }
                        } catch (err) {
                            console.error(err.message);
                        }
                    }
                }
            }
        }
    },
    __copyModifiedObject: function (source, target) {
        var propertyList = ["objectId", "physicalId", "relId", "tempId", "updateAction", "dataelements"];
        for (var i=0; i < propertyList.length; i++) {
            target[propertyList[i]] = source[propertyList[i]];
        }
        if (source.updateAction !== undefined) {
            source._updateAction = "PENDING";
        }
        delete source.updateMessage;
        delete source.updateSuccessful;

    },
    __deletePrevValues: function (object, restorePrevValue) {
        for (var key in object.dataelements) {
            if (object.dataelements.hasOwnProperty(key)) {
                fieldvalues = object.dataelements[key].value;
                if (fieldvalues && fieldvalues.length > 0) {
                    if (fieldvalues[0].prevDisplay != undefined) {
                        if (restorePrevValue) {
                            fieldvalues[0].value = fieldvalues[0].prevDisplay;
                        }
                        delete fieldvalues[0].prevDisplay;
                    }
                    if (fieldvalues[0].prevActual != undefined) {
                        if (restorePrevValue) {
                            fieldvalues[0].actualValue = fieldvalues[0].prevActual;
                        }
                        delete fieldvalues[0].prevActual;
                    }
                }
            }
        }
    },
    __newObject: function (fields) {
        var newObject = {
                children : [],
                dataelements : {}
            };
        for (var i=0; i < fields.length; i++) {
            var field = fields[i];
            newObject.dataelements[field.name] = {
                "name": field.name,
                "value": [{"value": field.value.displayValue, "actualValue": field.value.actualValue }]
            };
        }
        return newObject;
    },
    __generateUpdateWidget: function (widget, saveId) {
        if (widget._modifiedObjectList == null) {
            return null;
        }
        var updateWidget = {datarecords: {datagroups: []}},
        clonedObjects = {},
        modifiedList = widget._modifiedObjectList,
        parent, clonedParent, found, valueIndex,
        child, clonedChild, relationship, id;

        updateWidget.datarecords.name = widget.datarecords.name;
        updateWidget.datarecords.csrf = widget.datarecords.csrf;
        updateWidget.name = widget._parentExperience != null ? widget._parentExperience.name : widget.name;

        for (var i=0; i < modifiedList.length; i++) {
            parent = modifiedList[i].parent;
            child = modifiedList[i].child;
            relationship = modifiedList[i].relationship;

            if (child.updateAction === undefined || child._updateAction == "PENDING") {
                continue;
            }

            id = bpsWidgetAPIs.getId(child);
            if (saveId !== undefined && id != saveId) {
                continue;
            }

            clonedChild = {};
            clonedObjects[id] = {   //add to temp cache;
                item: clonedChild,
                source: child
            };
            this.__copyModifiedObject(child, clonedChild);  //clone some object properties.

            this.__addModifiedObject(updateWidget, clonedObjects, parent, relationship, clonedChild);
        }
        return {
            "updateWidget": updateWidget,
            "clonedObjects": clonedObjects
            };
    },
    __addModifiedObject: function(updateWidget, clonedObjects, parent, relationship, clonedChild) {
        var clonedParent = null;
        if (parent) {
            var id = bpsWidgetAPIs.getId(parent),
            found = clonedObjects[id];

            if (found == null) {
                clonedParent = {};
                clonedObjects[id] = {   //add to temp cache;
                    item: clonedParent,
                    source: parent
                };
                bpsWidgetSave.__copyModifiedObject(parent, clonedParent);  //clone some object properties.
                if (parent._relationship != null) {
                    //recursively add all parent objects to the update widget for proper context of modified object.
                    this.__addModifiedObject(updateWidget, clonedObjects, parent._relationshipParentObject, parent._relationship, clonedParent);
                } else {
                    updateWidget.datarecords.datagroups.push(clonedParent);
                }
            } else {
                clonedParent = found.item;
            }
        }

        if (relationship) {
            if (clonedParent.relateddata === undefined) {
                clonedParent.relateddata = {};
            }
            if (clonedParent.relateddata[relationship] === undefined) {
                clonedParent.relateddata[relationship] = {
                        name: relationship,
                        datagroups: []
                    };
            }
            clonedParent.relateddata[relationship].datagroups.push(clonedChild);
        } else if (clonedParent) {
            if (clonedParent.children === undefined) {
                clonedParent.children = [];
            }
            clonedParent.children.push(clonedChild);
        } else {
            updateWidget.datarecords.datagroups.push(clonedChild);
        }
    },
    __addEditEventListener: function (config, obj, editButton) {
        var oconfig = config,
        oobj = obj;
        editButton.click(function () {
            if ( oobj._editMode != true ) {
                // going into "edit" mode.
                oobj._editMode = true;
                // repaint object row in edit-mode.
                var actions_tr = jQuery(this).parents("tr:first");
                var data_tr = actions_tr.siblings('tr[data-objectid="' + oobj.objectId + '"]');
                bpsWidgetEngine.refreshRow(oconfig, data_tr, actions_tr, oobj);
            }
        });
    },
    __addDoneCancelEventListener: function (config, obj, button, apply) {
        var oconfig = config,
        oobj = obj;
        button.click(function () {
            if ( ! jQuery(this).hasClass("disabled") ) {
                var displayMsg;

                var actions_tr = jQuery(this).parents("tr:first");
                var data_tr = actions_tr.siblings('tr[data-objectid="' + oobj.objectId + '"]');



                if ( apply ) {
                    // Send updates to the server.
                    var afield = jQuery(this);
                    var afield = data_tr.find(".modified:first");
                    data_tr.css("cursor", "wait");
                    actions_tr.css("cursor", "wait");
                    jQuery(this).css("cursor", "wait");
                    bpsWidgetAPIs.__disableEditButtons(afield, true);
                    displayMsg = "Saving changes to the database...";
                    var divMsg = bpsWidgetEngine.__displayMsg(afield, displayMsg, "info");

                    // applyUpdates Callback.
                    var updateCallback = function () {
                        var updateSuccessful  = oobj.updateSuccessful;
                        var updateMsg = oobj.updateMessage;
                        if ( updateSuccessful == false ) {
                            // applyUpdates had an error condition.
                            divMsg = bpsWidgetEngine.__displayMsg(afield, updateMsg, "error");
                            bpsWidgetAPIs.__disableEditButtons(afield, false);
                            data_tr.css("cursor", "default");
                            actions_tr.css("cursor", "default");
                            jQuery(this).css("cursor", "default");
                        }
                        else {
                            // applyUpdates was success.
                            if ( updateMsg && updateMsg.length > 0 ) {
                                divMsg = bpsWidgetEngine.__displayMsg(afield, updateMsg, "error");
                            }
                            divMsg.fadeOut(1500, function() {
                                delete oobj._editMode;  // we're no longer in edit mode, clear indicator
                                bpsWidgetEngine.refreshRow(oconfig, data_tr, actions_tr, oobj);
                            });
                        }
                    };
                    bpsWidgetAPIs.applyUpdates(oconfig, updateCallback, false, oobj.physicalId);
                } else {
                    // Cancel button clicked...
                    if ( bpsWidgetAPIs.isDirty(oobj) ) {
                        // Warn user if they're cancelling edit before saving modifications.
                        var choice = confirm("This object has unsaved changes.  These changes will be lost if you cancel.  Do you still want to cancel?");
                        if (choice) {
                            bpsWidgetSave.cancelObject(oconfig, oobj);
                        } else {
                            return;
                        }
                    } else {
                        bpsWidgetSave.cancelObject(oconfig, oobj);
                    }
                    delete oobj._editMode;  // we're no longer in edit mode, clear indicator
                    bpsWidgetEngine.refreshRow(oconfig, data_tr, actions_tr, oobj);
                }
            }
        });
    },
    __disableEditButtons: function (field, disable) {
        var tr = field.parents("tr:first");
        var oid = tr.attr("data-objectid");
        var table = field.parents("table:first");
        var action_tr = table.find('tr.editable-actions[data-objectid="' + oid + '"]');
        var doneButton = action_tr.find('span.edit-image-done');
        var cancelButton = action_tr.find('span.edit-image-cancel');
        var ediableFields = tr.find('.editable-field');
        if ( disable == true ) {
            doneButton.addClass("disabled");
            cancelButton.addClass("disabled");
            doneButton.css("cursor", "default");
            cancelButton.css("cursor", "default");
            ediableFields.css("cursor", "default");
        }
        else {
            // If we have any modified fields then enable the done button.
            if ( tr.find('.modified').length > 0 ) {
                doneButton.removeClass("disabled");
            }
            cancelButton.removeClass("disabled");
            doneButton.css("cursor", "pointer");
            cancelButton.css("cursor", "pointer");
            ediableFields.css("cursor", "pointer");
        }
    }
};

jQuery.extend(bpsWidgetAPIs, bpsWidgetSave);
