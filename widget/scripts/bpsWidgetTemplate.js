/*
 * Configurable templates for drawing BPS widgets
 * bpsWidgetTemplate.js
 * version 0.0.8
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * bpsWidgetTemplate Object
 * this file contains all the HTML templates for widgets
 *
 * Requires:
 * jQuery v1.6.2 or later
 *
 */
var bpsWidgetTemplate = {
    generic: function () {
        return jQuery('<div />');
    },
    list: function (obj) {
        return jQuery('<table />', {
            'id': obj.config.id,
            'class': 'simple-list',
            'width': '100%'
        }).append('<tbody />');
    },
    table: function (obj) {
        return jQuery('<table />', {
            'class': 'table',
            'width': '100%'
        }).append('<tbody />');
    },
    list_row_header: function () {
        return jQuery('<tr />', {
            'class': 'list-row'
        });
    },
    list_row: function (obj) {
        return jQuery("<tr />", {
            'data-type': obj.type,
            'data-objectId': obj.oid,
            'data-pid': obj.pid,
            'class': 'list-row',
            click: obj.editMode != true ?
                function(event) {
                    bpsWidgetEngine.processSelection.call(this, event, obj.widgetId);
                } : null
        });
    },
    list_cell_header: function (obj) {
        if (obj.size) {
            return jQuery('<th />', {
                'width': obj.size
            });
        }
        return jQuery('<th />');
    },
    list_cell: function (obj) {
        if (obj.size) {
            return jQuery('<td />', {
                'width': obj.size
            });
        }
        return jQuery('<td />');
    },
    view: function (obj) {
        return jQuery('<div />', {
            'class': 'ds-group ' + obj.layout.toLowerCase()
        });
    },
    experience: function (obj) {
        if  (obj.showLabel && obj.config.label) {
            var settings = bpsWidgetPreferences.buildPreferences(obj),
                refresh = this.refresh(obj);
            return jQuery('<div data-name="' + obj.config.name + '" class="experience"></div>').append(jQuery('<div class="widget-label">' + obj.config.label.text  + '</div>').append(jQuery(settings)).append(refresh));
        }
        return jQuery('<div />', {
            'data-name': obj.config.name,
            'class': 'experience'
        });
    },
    container: function (obj) {
        return jQuery('<div />', {
            'class': obj.type
        });
    },
    group: function (obj) {
        return jQuery('<div class="ds-' + obj.type + ' ' + obj.layout.toLowerCase() + '" draggable="true" ondragstart="drag(event)"></div>');
    },
    chartgroup: function (obj) {
        return jQuery('<div />', {
            'class': 'ds-group ' + obj.layout.toLowerCase() + ' ' + obj.type
        });
    },
    widget: function (obj) {
        return jQuery('<div class="ds-widget"><div class="widget-label">' + obj.type + '</div></div>');
    },
    channel: function (obj) {
        return jQuery('<div id="' + obj.config.id + '" class="' + obj.type + '"  ondrop="drop(event)" ondragover="allowDrop(event)"></div>');
    },
    text: function (txt, field) {
        return jQuery('<span />', {
            'field-name': field,
            html: txt                
        });
    },
    textbox_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "textbox");
        return editable;
    },
    textarea_editable: function (txt, field, obj) {
        var editable= jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "textarea");
        return editable;
    },
    combobox_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "combo");
        return editable;
    },
    radiobutton_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "radio");
        return editable;
    },
    checkbox_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "checkbox");
        return editable;
    },
    listbox_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "listbox");
        return editable;
    },
    date_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "date");
        return editable;
    },
    numeric_editable: function (txt, field, obj) {
        var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
        editable.css("cursor", "pointer");
        bpsWidgetEngine.addEditEvent(editable, field, obj, "numerictextbox");
        return editable;
    },
    message: function (txt) {
        return jQuery('<span />', {
            'class': 'message',
            text: txt
        });
    },
    error: function (txt) {
        if (typeof isIFWE !== "undefined" && isIFWE === true) {
            return this.container({type:"ds-widget"}).append(this.message(txt));
        } else {
            return this.container({type:"ds-widget"})
                .append(this.container({type:"experience"})
                    .append(this.container({type:"widget-label"})
                        .append(this.text(bpsWidgetConstants.str.WidgetLabel)))
                    .append(this.message(txt)));
        }
    },
    field: function (obj) {
        return jQuery('<div />', {
            'class': (obj.config.ui && obj.config.ui.type == 'TITLE') ? 'title' : 'field'
        });
    },
    image: function (obj) {
        if ((obj.size && obj.size != "ICON") && (obj.height && obj.height == "16px")) {
            return jQuery('<div class="image-container ' + obj.size.toLowerCase() + '" ><div class="icon-frame"><img src="' + obj.url + '" /></div></div>');
        } else {
            return jQuery('<div class="image-container ' + obj.size.toLowerCase() + '"><img src="' + obj.url + '" /></div>');
        }
    },
    badge: function (obj) {
        return jQuery('<div />', {
            'class': 'badge ' + obj.status,
            'title': obj.hovertext
        });
    },
    label: function (lbl) {
        return jQuery('<label />',{
            text: lbl
        });
    },
    progress: function (obj) {
        return jQuery('<span class="progress ' + obj.state + '"><span class="bar"><label>' + obj.percent + '%</label><span style="width:' + obj.percent + '%"></span></span></span>');
    },
    link: function (obj) {
        return jQuery("<a />", {
            'href': obj.url,
            'target': obj.target
        });      
    },
    refresh: function (obj) {
        return jQuery('<div />', {
            'class': 'settings-button refresh',
            'title': bpsWidgetConstants.str.Refresh,
            click: function () {
                bpsWidgetEngine.refresh(obj.config);
            }
        });
    },
    edit_actions_row: function (object, config, cells, treeMode, colspan) {
        var actionsRow = null;
        if ( cells.length > 0 && !treeMode && bpsWidgetAPIs.isObjectEditable(config, object) ) {
            actionsRow = jQuery('<tr class="list-row editable-actions" />');
            actionsRow.attr("data-objectId", object.objectId || "");
            var td = jQuery('<td colspan="' + colspan + '" />');
            var contDiv = jQuery('<div class="content" />');
            var msgDiv = jQuery('<div class="messages" />');
            var actionDiv = jQuery('<div class="actions">');
            var editButton = jQuery('<span class="edit-image-mode" />');
            var cancelButton = jQuery('<span class="edit-image-cancel" />');
            var isDisabled = " disabled";
            if ( bpsWidgetAPIs.isDirty(object) ) {
                isDisabled = "";
            }
            var doneButton = jQuery('<span class="edit-image-done' + isDisabled +  '" />');
            actionDiv.append(doneButton);
            actionDiv.append(cancelButton);
            actionDiv.append(editButton);
            contDiv.append(msgDiv);
            contDiv.append(actionDiv);
            td.append(contDiv);
            actionsRow.append(td);
            if ( object._editMode != true) {
                editButton.css("cursor", "pointer");
                doneButton.hide();
                cancelButton.hide();
            }
            else {
                editButton.hide();
                doneButton.css("cursor", "pointer");
                cancelButton.css("cursor", "pointer");
            }
            // Add event listeners for edit controls and editable fields.
            bpsWidgetAPIs.assignEditEventListeners(config, object, editButton, doneButton, cancelButton);
        }
        return actionsRow;
    },
    edit_popup_div: function (dataType, field, fieldName) {
        var ofield = field;
        var oFieldName = fieldName;
        // Check if this field has a label.
        var label = field.siblings('label');
        if ( label != null && label.text().length > 0 ) {
            oFieldName = label.text();
        }
        var tr = field.parents("tr:first");
        var oid = tr.attr("data-objectid");
        var popDiv = jQuery('<div class="popup form" data-type="' + dataType + '" data-objectid="' + oid + '" field-name="'+ fieldName + '"/>');
        var contsDiv = jQuery('<div class="contents" />');
        var headDiv = jQuery('<div class="head" />');
        var contDiv = jQuery('<div class="content" />');
        var titleSpan = jQuery('<span class="title">'+ oFieldName + '</span>');
        var actionsSpan = jQuery('<span class="actions" />');
        var doneButton = jQuery('<button class="done" />');
        var cancelButton = jQuery('<button class="cancel" />');
        var bodyDiv = jQuery('<div class="body" />');
        
        actionsSpan.append(doneButton);
        actionsSpan.append(cancelButton);
        contDiv.append(titleSpan);
        contDiv.append(actionsSpan);
        headDiv.append(contDiv);
        contsDiv.append(headDiv);
        contsDiv.append(bodyDiv);
        popDiv.append(contsDiv);
        
        cancelButton.click(function () {
            // Enable Done and Cancel buttons as we're done editing.
            bpsWidgetAPIs.__disableEditButtons(ofield, false);
            bpsWidgetEngine.__clearMsg(ofield);
            popDiv.remove();
        });
        
        return popDiv;
    }
};
