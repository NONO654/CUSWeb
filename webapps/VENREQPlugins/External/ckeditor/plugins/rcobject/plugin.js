/**
 * @license Copyright (c) Dassault Systems - All rights reserved.
 * This plugin allows a user to create a rich content object inside his HTML content.
 * This new object is basically a Microsoft Office Document (Word, Excel, or others) and can be edited 
 * by opening its content directly in Word (Edit in Word).
 * 
 * After the save, the data is updated automatically.
 * 
 * Author: Claudien Barbier (T94)
 */
'use strict';

(function () {

    CKEDITOR.plugins .add(
            'rcobject', {
                lang: 'de,en,es,fr,it,ja,zh-cn,zh',
                requires: 'widget,dialog',
                icons: 'rcobject',
                
                onLoad: function (editor) {
                    // NOP
				},
                init: function (editor) {
                    
                	// Register the dialog to be able to create a new RCO
                    CKEDITOR.dialog.add('rcoDialog', this.path + 'dialogs/rcobject.js');
                    
                    // The only purpose of this button is to create a RCO, not to edit one
                    editor.ui.addButton('RCO', {
                        label: editor.lang.rcobject.dropFiles,
                        command: 'rcoCreation',
                        toolbar: 'widgets',
                        icon: this.path + 'icons/rcobject.png'
                    });
                    
                    // Attributes the command to the dialog
                    editor.addCommand('rcoCreation',
                        new CKEDITOR.dialogCommand('rcoDialog'));
                    
                    // Creates the RCO
                    var rco = rcoDefinition(editor);
                    
                    // Register the widget
                    editor.widgets.add('rcobject', rco);

                    /** 
                     * CONTEXTUAL MENU 
                    **/
                    editor.addMenuGroup('rcoContextualMenu', -1);

                    function isRCOSaved(editor) {
                        // The reference document is not created yet
                        if (editor.widgets.focused.data['isSaved'] == false) {
                            alert('You must save Structure Display content before using this command.');
                            return false;
                        }
                        return true;
                    }
                    
                    // Register the command to checkOut the RCO
                    editor.addCommand("rcoCheckOut", {
                        exec: function (editor) {
                        	if (isRCOSaved(editor)) {
                                if (editor.widgets.focused.data['rcoIsCheckedOut'] == false) {
                                    callCheckout(editor.widgets.focused.data["rcoReferenceDocFileId"], 'checkout', '', '', 'null',
                                        'null', 'structureBrowser', 'APPDocuemntSummary', '');
                                } else {
                                    showModalDialog('../components/emxCommonDocumentPreCheckin.jsp?showComments=required&' +
                                        'refreshTable=true&objectId=' +
                                        editor.widgets.focused.data["rcoReferenceDocFileId"] + '&showFormat=readonly&' +
                                        'append=true&objectAction=update&format=generic&oldFileName=' +
                                        editor.widgets.focused.data["rcoFileName"], 730, 450);
                                }
                            }
                        }
                    });

                 // Register the command to download the RCO
                    editor.addCommand("rcoDownload", {
                        exec: function (editor) {
                            if (isRCOSaved(editor))
                                callCheckout(editor.widgets.focused.data["rcoReferenceDocFileId"], 'download', '', '' ,'null', 
                                    'null', 'structureBrowser', 'APPDocuemntSummary', '');
                        }
                    });

                    // If the "menu" plugin is loaded, register the menu items.
                    if (editor.addMenuItems) {
                        editor.addMenuItems({
                            rcoContextualMenu :
                            {
                              label : editor.lang.rcobject.cmActions,
                              icon: this.path + '/images/action.png',
                              group : 'rcoContextualMenu',
                              order : 1,
                              getItems : function() {
                                return {
                                    rcoCheckOut : CKEDITOR.TRISTATE_OFF,
                                    rcoDownload : CKEDITOR.TRISTATE_OFF
                                };
                              }
                            },
                            
                            // Now add the child items to the group.
                            rcoCheckOut :
                            {
                              label : editor.lang.rcobject.cmCheckOut,
                              icon: this.path + '/images/checkOut.png',
                              group : 'rcoContextualMenu',
                              command : 'rcoCheckOut',
                              order : 11
                            },
                            rcoDownload :
                            {
                              label : editor.lang.rcobject.cmDl,
                              icon: this.path + '/images/download.gif',
                              group : 'rcoContextualMenu',
                              command : 'rcoDownload',
                              order : 12
                            },
                            rcoProperties: {
                                label: editor.lang.rcobject.cmProperties,
                                icon: this.path + '/images/properties.png',
                                command: 'rcoCreation',
                                group: 'rcoContextualMenu',
                                order: 2
                            }
                        });
                    }

                    // If the "contextmenu" plugin is loaded, register the listeners.
                    if (editor.contextMenu) {
                        editor.contextMenu.addListener(function (element,
                            selection) {
                            return getSelectedRCOWidget(editor, element);
                        });
                    }
                    
                    /**
                     * EVENTS
                     */
                    editor.on('destroy', function (evt) {
                        //alert('destroy plugins ');
                        // removeAllDataFromSessionStorage();
                    });
                    
                    editor.on('change', function (evt) {
                        
                    });
                }
            });

    function syncArrayRCOsWithEditor() {
        
        // Here is the array with all the current RCOs
        var aTmpRCOs = {};
        var aWidgets = $('.rcobject', $('.cke_wysiwyg_frame').contents());
        for (var i = 0; i < aWidgets.length; i++) {
            var rcoData = JSON.parse(aWidgets.get(i).attr('data-cke-widget-data'));
            var rcoSerialId = rcoData.rcoSerialId;
            aTmpRCOs[rcoSerialId] = rcoData;
        }
        
        // Init
        if (aRCOs == null) {
            aRCOs = aTmpRCOs;
        }
        
        // Length
        var lRCOs = 0, lTmpRCOs = 0;
        for (var entry in aRCOs) {
            if (aRCOs.hasOwnProperty(entry)) {
                lRCOs++;
            }
        }
        for (var entry in aTmpRCOs) {
            if (aTmpRCOs.hasOwnProperty(entry)) {
                lTmpRCOs++;
            }
        }
        
        // If a RCO has been deleted
        if (lRCOs > lTmpRCOs) {
            for (var entry in aRCOs) {
                if (aTmpRCOs[entry] == undefined) {
                    // Remove data from session storage
                    removeDataFromSessionStorage(entry);
                }
            }
        // A RCO has been added
        } else if (lRCOs < lTmpRCOs) {
            for (var entry in aTmpRCOs) {
                if (aRCOs[entry] == undefined) {
                    // Add data from session storage
                    addDataFromSessionStorage(entry, aRCOs[entry]);
                }
            }
        } else {
            // Nothing has changed about RCOs
        }
        

    }
    
    function rcoDefinition(editor) {
        var template = '<img alt="RCO image" src="" />',
            templateBlock = '<figure data-cke-saved-rco=\'\' title="' + editor.lang.rcobject.titleDefault + '" class="rcobject" style="display:inline-block">' +
                template +
                '<figcaption style="background: White;">' + editor.lang.rcobject.captionDefault + '</figcaption>' +
                '</figure>';

        // If we have already some data
        var oldDataRCO = null;
        return {
            inline: false,
            allowedContent: {
                figcaption: {
                    styles: 'background'
                },
                figure: {
                    classes: '!rcobject',
                    styles: 'float,display',
                    attributes: '!title, !data-cke-saved-rco'
                },
                img: {
                    attributes: '!src,alt,width,height',
                    styles: 'float'
                }
            },
            editables: {
                caption: {
                    selector: 'figcaption',
                    allowedContent: 'br em strong sub sup u s; a[!href]'
                }
            },
            parts: {
                image: 'img',
                caption: 'figcaption'
            },
            template: templateBlock,
            upcast: function (el) {
                if (el.hasClass('rcobject') == true) {
                    var attrs = el.attributes;
                    oldDataRCO = JSON.parse(attrs['data-cke-saved-rco'].replace(/'/g, '"'));
                    return el;
                }
                return false;
            },
            downcast: function (el) {
                if (el.hasClass('rcobject') == true) {
                    var attrs = el.attributes;
                    attrs['data-cke-saved-rco'] = JSON.stringify(this.data).replace(/"/g, '\'');
                    return el;
                }
                return false;
            },
            setPreview: function (content) {
                this.parts.image.setAttributes({
                    src: content.attr('src'),
                    alt: content.attr('alt')
                });
                setupResizer(this);
            },
            data: function () {
                var widget = this,
                    editor = widget.editor,
                    editable = editor.editable();
            },
            init: function () {
                
                // Old data are already loaded
                if (oldDataRCO != null) {
                    this.data = oldDataRCO;
                    return false;
                }
                
                // We can set the loading gif
                var image = this.parts.image;
                if (image != undefined)
                    image.src = pluginPath + 'images/loading.gif';

                for (var entry in CKEDITOR.instances) break;
                var editor = CKEDITOR.instances[entry];

                var editorSerialId = editor.name.substring("CKEDITOR_".length);

                var rcoSerialId = rcoTimeStamp + '_' + this.id;
                this.setData('rcoSerialId', rcoSerialId);
                this.setData('rcoEditorSerialId', editorSerialId);
                this.setData('rcoCurrentObjectId', $('#objectInfo_' + editorSerialId).children('#objectID').html());
                this.setData('rcoReferenceDocFileId', 'None');
                this.setData('rcoIsCheckedOut', false);
                
                this.setData({
                    align: 'left',
                    width: 0,
                    height: 0
                });
                
                this.setData('rcoFileName', '');
                this.setData('rcoFileType', '');
                this.setData('rcoFileLastModified', '');
                this.setData('rcoPathTempFile', '');
                this.setData('isSaved', false);

                this.element.setStyle('float', this.data['align']);
            },
            destroy: function () {
                //alert('destroy widget ' + this.data['rcoSerialId']);
                // removeDataFromSessionStorage(this.data['rcoSerialId']);
            }
        };
    }

    /** Add data to the session storage **/
    function addDataToSessionStorage(idRCO, dataRCO) {
        if (sessionStorage.getItem('rco_ckeditor_list') == null)
            sessionStorage.setItem('rco_ckeditor_list', 'rco_ckeditor_' + idRCO);
        else
            sessionStorage.setItem('rco_ckeditor_list', sessionStorage.getItem('rco_ckeditor_list') + ' ' + 'rco_ckeditor_' + idRCO);

        sessionStorage.setItem('rco_ckeditor_' + idRCO, JSON.stringify(dataRCO));
    }

    function removeDataFromSessionStorage(idRCO) {
        sessionStorage.setItem('rco_ckeditor_list', sessionStorage.getItem('rco_ckeditor_list').replace('rco_ckeditor_' + idRCO, ''));
        sessionStorage.removeItem('rco_ckeditor_' + idRCO);
    }

    function removeAllDataFromSessionStorage() {
        var aRcoList = sessionStorage.getItem('rco_ckeditor_list').split(' ');
        if (aRcoList.length == 1 && aRcoList[0] == '') {
            sessionStorage.removeItem('rco_ckeditor_list');
            return false;
        }
        
        for (var i = 0; i < aRcoList.length; i++) {
            //alert('Remove all : ' + aRcoList[i]);
            sessionStorage.removeItem(aRcoList[i]);
        }
        sessionStorage.removeItem('rco_ckeditor_list');
    }

    function getSelectedRCOWidget(editor, element) {
        if (!element) {
            var sel = editor.getSelection();
            element = sel.getSelectedElement();
        }

        if (element.find(".rcobject").$.length != 0) {
            return {
                rcoContextualMenu: CKEDITOR.TRISTATE_OFF,
                rcoProperties: CKEDITOR.TRISTATE_OFF
            };
        }
    }

    CKEDITOR.on('dialogDefinition', function(ev) {
        var dialogName = ev.data.name;
        var dialogDefinition = ev.data.definition;
        
        if (dialogName == 'rcoDialog') {

            var oldOnShow = dialogDefinition.onShow;
            dialogDefinition.onShow = function () {
                
                for (var entry in CKEDITOR.instances) break;
                var editor = CKEDITOR.instances[entry];
                
                for (var entry in editor.widgets.instances);
                var widget = editor.widgets.instances[entry];
                
                oldOnShow.apply(this, null);
                
                /*if (widget.data['rcoDoubleClick'] == true) {
                    widget.setData('rcoDoubleClick', false);
                    // This code will open the Upload tab.
                    this.selectPage('tap-upload');
                }*/
            };
            ev.data.definition.resizable = CKEDITOR.DIALOG_RESIZE_NONE;
        }
    });
    
    CKEDITOR.on('instanceReady', function () {
       
    });
    
    CKEDITOR.plugins.rcobject = {
            /** Checks whether current ratio of the image match the natural one by comparing dimensions. **/
            checkHasNaturalRatio: function( image ) {
                var $ = image.$,
                    natural = this.getNatural( image );

                // The reason for two alternative comparisons is that the rounding can come from
                // both dimensions, e.g. there are two cases:
                //  1. height is computed as a rounded relation of the real height and the value of width,
                //  2. width is computed as a rounded relation of the real width and the value of heigh.
                return Math.round( $.clientWidth / natural.width * natural.height ) == $.clientHeight ||
                    Math.round( $.clientHeight / natural.height * natural.width ) == $.clientWidth;
            },

            /** Returns natural dimensions of the image. For modern browsers 
             * it uses natural(Width|Height) for old ones (IE8), creates 
             * a new image and reads dimensions. **/
            getNatural: function( image ) {
                var dimensions;

                if ( image.$.naturalWidth ) {
                    dimensions = {
                        width: image.$.naturalWidth,
                        height: image.$.naturalHeight
                    };
                } else {
                    var img = new Image();
                    img.src = image.getAttribute( 'src' );

                    dimensions = {
                        width: img.width,
                        height: img.height
                    };
                }

                return dimensions;
            }
    };

    /** Defines all features related to drag-driven image resizing. **/
    function setupResizer(widget) {
        var editor = widget.editor,
            editable = editor.editable(),
            doc = editor.document,
            resizer = doc.createElement('span');

        resizer.addClass('cke_image_resizer');
        resizer.setAttribute('title', editor.lang.rcobject.resizer);
        resizer.append(new CKEDITOR.dom.text('\u200b', doc));

        // Inline widgets don't need a resizer wrapper as an image spans the entire widget.
        if (!widget.inline) {
            var oldResizeWrapper = widget.element.getFirst(),
                resizeWrapper = doc.createElement('span');

            resizeWrapper.addClass('cke_image_resizer_wrapper');
            resizeWrapper.append(widget.parts.image);
            resizeWrapper.append(resizer);
            widget.element.append(resizeWrapper, true);

            // Remove the old wrapper which could came from e.g. pasted HTML
            // and which could be corrupted (e.g. resizer span has been lost).
            if (oldResizeWrapper.is('span'))
                oldResizeWrapper.remove();
        } else
            widget.wrapper.append(resizer);

        // Calculate values of size variables and mouse offsets.
        resizer.on('mousedown', function (evt) {
            var image = widget.parts.image,

                // "factor" can be either 1 or -1. I.e.: For right-aligned images, we need to
                // subtract the difference to get proper width, etc. Without "factor",
                // resizer starts working the opposite way.
                factor = widget.data.align == 'right' ? -1 : 1,

                // The x-coordinate of the mouse relative to the screen
                // when button gets pressed.
                startX = evt.data.$.screenX,
                startY = evt.data.$.screenY,

                // The initial dimensions and aspect ratio of the image.
                startWidth = image.$.clientWidth,
                startHeight = image.$.clientHeight,
                ratio = startWidth / startHeight,

                listeners = [],

                // A class applied to editable during resizing.
                cursorClass = 'cke_image_s' + (!~factor ? 'w' : 'e'),

                nativeEvt, newWidth = 0, newHeight = 0, updateData = true,
                moveDiffX = 0, moveDiffY = 0, moveRatio;

            // Save the undo snapshot first: before resizing.
            editor.fire('saveSnapshot');

            // Mousemove listeners are removed on mouseup.
            attachToDocuments('mousemove', onMouseMove, listeners);

            // Clean up the mousemove listener. Update widget data if valid.
            attachToDocuments('mouseup', onMouseUp, listeners);

            // The entire editable will have the special cursor while resizing goes on.
            editable.addClass(cursorClass);

            // This is to always keep the resizer element visible while resizing.
            resizer.addClass('cke_image_resizing');

            // Attaches an event to a global document if inline editor.
            // Additionally, if framed, also attaches the same event to iframe's document.
            function attachToDocuments(name, callback, collection) {
                var globalDoc = CKEDITOR.document,
                    listeners = [];

                if (!doc.equals(globalDoc))
                    listeners.push(globalDoc.on(name, callback));

                listeners.push(doc.on(name, callback));

                if (collection) {
                    for (var i = listeners.length; i--;)
                        collection.push(listeners.pop());
                }
            }

            // Calculate with first, and then adjust height, preserving ratio.
            function adjustToX() {
                newWidth = startWidth + factor * moveDiffX;
                newHeight = Math.round(newWidth / ratio);
            }

            // Calculate height first, and then adjust width, preserving ratio.
            function adjustToY() {
                newHeight = startHeight - moveDiffY;
                newWidth = Math.round(newHeight * ratio);
            }

            // This is how variables refer to the geometry.
            // Note: x corresponds to moveOffset, this is the position of mouse
            // Note: o corresponds to [startX, startY].
            //
            //  +--------------+--------------+
            //  |              |              |
            //  |      I       |      II      |
            //  |              |              |
            //  +------------- o -------------+ _ _ _
            //  |              |              |      ^
            //  |      VI      |     III      |      | moveDiffY
            //  |              |         x _ _ _ _ _ v
            //  +--------------+---------|----+
            //                 |         |
            //                  <------->
            //                  moveDiffX
            function onMouseMove(evt) {
                nativeEvt = evt.data.$;

                // This is how far the mouse is from the point the button was pressed.
                moveDiffX = nativeEvt.screenX - startX;
                moveDiffY = startY - nativeEvt.screenY;

                // This is the aspect ratio of the move difference.
                moveRatio = Math.abs(moveDiffX / moveDiffY);

                // Left, center or none-aligned widget.
                if (factor == 1) {
                    if (moveDiffX <= 0) {
                        // Case: IV.
                        if (moveDiffY <= 0)
                            adjustToX();

                        // Case: I.
                        else {
                            if (moveRatio >= ratio)
                                adjustToX();
                            else
                                adjustToY();
                        }
                    } else {
                        // Case: III.
                        if (moveDiffY <= 0) {
                            if (moveRatio >= ratio)
                                adjustToY();
                            else
                                adjustToX();
                        }

                        // Case: II.
                        else
                            adjustToY();
                    }
                }

                // Right-aligned widget. It mirrors behaviours, so I becomes II,
                // IV becomes III and vice-versa.
                else {
                    if (moveDiffX <= 0) {
                        // Case: IV.
                        if (moveDiffY <= 0) {
                            if (moveRatio >= ratio)
                                adjustToY();
                            else
                                adjustToX();
                        }

                        // Case: I.
                        else
                            adjustToY();
                    } else {
                        // Case: III.
                        if (moveDiffY <= 0)
                            adjustToX();

                        // Case: II.
                        else {
                            if (moveRatio >= ratio)
                                adjustToX();
                            else
                                adjustToY();
                        }
                    }
                }

                // Don't update attributes if less than 10.
                // This is to prevent images to visually disappear.
                if (newWidth >= 15 && newHeight >= 15) {
                    image.setAttributes({
                        width: newWidth,
                        height: newHeight
                    });
                    updateData = true;
                } else
                    updateData = false;
            }

            function onMouseUp(evt) {
                var l;

                while ((l = listeners.pop()))
                    l.removeListener();

                // Restore default cursor by removing special class.
                editable.removeClass(cursorClass);

                // This is to bring back the regular behaviour of the resizer.
                resizer.removeClass('cke_image_resizing');

                if (updateData) {
                    widget.setData({
                        width: newWidth,
                        height: newHeight
                    });

                    // Save another undo snapshot: after resizing.
                    editor.fire('saveSnapshot');
                }

                // Don't update data twice or more.
                updateData = false;
            }
        });

        // Change the position of the widget resizer when data changes.
        widget.on('data', function () {
            resizer[widget.data.align == 'right' ? 'addClass' : 'removeClass']('cke_image_resizer_left');
        });
    }
})();
