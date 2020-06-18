
//=================================================================
// JavaScript rcowidget.js
//=================================================================

//@quickreview HAT1 ZUD 16:11:07 IR-441347-3DEXPERIENCER2018x: The Center button of alignment on Rich text object property doesn't work properly.

function iniDropZoneRCO() {
    function addDataToSessionStorage(idRCO, dataRCO) {
        if (sessionStorage.getItem('rco_ckeditor_list') == null)
            sessionStorage.setItem('rco_ckeditor_list', 'rco_ckeditor_' + idRCO);
        else
            sessionStorage.setItem('rco_ckeditor_list', sessionStorage.getItem('rco_ckeditor_list') + ' ' + 'rco_ckeditor_' + idRCO);

        sessionStorage.setItem('rco_ckeditor_' + idRCO, JSON.stringify(dataRCO));
    }

    for (var entry in CKEDITOR.instances) break;
    var editor = CKEDITOR.instances[entry];

    var head = document.getElementsByTagName('head')[0];
    var csslink = document.createElement('link');
    csslink.id = 'dropZone';
    csslink.rel = 'stylesheet';
    csslink.type = 'text/css';
    csslink.href = '../webapps/RichEditorCusto/assets/ckeditor/dropZone/css/dropzone.css';
    csslink.media = 'all';
    head.appendChild(csslink);

    $.getScript("../webapps/RichEditorCusto/assets/ckeditor/dropZone/dropzone.js")
            .done(function(script, textStatus) {
        $('#loadingImageRCO').hide();

        var urlToUpload = serverURLWithRoot + '/resources/richeditor/res/upload?'; // + csrfParams;
        var dropzone = new Dropzone('#dropZoneRCO', {
            url: urlToUpload,
            maxFilesize: 150, // in MB
            uploadMultiple: false,
            maxFiles: 1
        });
        
        
        dropzone.on('success', function (file, serverResponse) {

            // Set the preview
            widget = editor.widgets.focused;

            var _DELIMITER = '\7';
            var data = serverResponse.path.split(_DELIMITER),
            filePath = data[0], preview = data[1];
            
            var imgPreview = $(file.previewElement).find('.dz-details').find('img');
            // If there is an issue with the preview, we put the default icon
            if (imgPreview.attr('src') == undefined) {
            	var imagePath = '';
            	
            	if (preview != undefined) {
            		imagePath = 'data:image/jpeg;base64,' + preview;
            	}            	
                imgPreview = $('<img width="200" height="200" alt="RCO image" class="preview-image-rco" src="' + imagePath + '" />');
            }
            if(preview != undefined) {
                widget.setPreview(imgPreview);
            }
            if(widget.data['rcoFileName'] == widget.getCaption()) { //if caption is same as file name, change it to new file name
                widget.setCaption(file.name);
                CKEDITOR.dialog.getCurrent().getContentElement('tab-info', 'rcoContent').setValue(file.name);
            }

            widget.setData({
                align: 'left',
                width: 100,
                height: 100
            });
            
            widget.setData('rcoFileName', file.name);
            widget.setData('rcoFileType', file.type);
            widget.setData('rcoFileLastModified', file.lastModifiedDate);
            widget.setData('rcoPathTempFile', filePath);

            widget.element.$.attributes['title'].textContent = editor.lang.rcowidget.titleFileName + ': ' + file.name + '\n' + 
                editor.lang.rcowidget.titleMIME + ': ' + file.type + '\n' + 
                editor.lang.rcowidget.titleModified + ': ' + file.lastModifiedDate;
            addDataToSessionStorage(widget.data['rcoSerialId'], widget.data);
            widget.setData('rcoPathTempFile', undefined);
        });
    }).fail(function(jqxhr, settings, exception) {
        console.log('DropZone failed to load.');
    });
}

CKEDITOR.dialog.add( 'rcowidgetDialog', function( editor ) {

    // RegExp: 123, 123px, empty string ""
    var regexGetSizeOrEmpty = /(^\s*(\d+)(px)?\s*$)|^$/i,

        lockButtonId = CKEDITOR.tools.getNextId(),
        resetButtonId = CKEDITOR.tools.getNextId(),

        lang = editor.lang.rcowidget,
        commonLang = editor.lang.common,

        lockResetStyle = 'margin-top:18px;width:40px;height:20px;',
        lockResetHtml = new CKEDITOR.template(
            '<div>' +
                '<a href="javascript:void(0)" tabindex="-1" title="' + lang.lockRatio + '" class="cke_btn_locked" id="{lockButtonId}" role="checkbox">' +
                    '<span class="cke_icon"></span>' +
                    '<span class="cke_label">' + lang.lockRatio + '</span>' +
                '</a>' +

                '<a href="javascript:void(0)" tabindex="-1" title="' + lang.resetSize + '" class="cke_btn_reset" id="{resetButtonId}" role="button">' +
                    '<span class="cke_label">' + lang.resetSize + '</span>' +
                '</a>' +
            '</div>' ).output( {
                lockButtonId: lockButtonId,
                resetButtonId: resetButtonId
            } ),

        helpers = CKEDITOR.plugins.rcowidget,

        // Functions inherited from rcowidget plugin.
        checkHasNaturalRatio = helpers.checkHasNaturalRatio,
        getNatural = helpers.getNatural,

        // Global variables referring to the dialog's context.
        doc = null, widget = null, image,

        // Global variable referring to this dialog's image pre-loader.
        preLoader,

        // Global variables holding the original size of the image.
        domWidth = 0, domHeight = 0,

        // Global variables related to image pre-loading.
        preLoadedWidth = 0, preLoadedHeight = 0, srcChanged = false,

        // Global variables related to size locking.
        lockRatio = false, userDefinedLock = false,

        // Global variables referring to dialog fields and elements.
        lockButton = null, resetButton = null, widthField = null, heightField = null,

        natural;

    // Validates dimension. Allowed values are:
    // "123px", "123", "" (empty string)
    function validateDimension() {
        var match = this.getValue().match( regexGetSizeOrEmpty ),
            isValid = !!( match && parseInt( match[ 1 ], 10 ) !== 0 );

        if ( !isValid )
            alert( commonLang[ 'invalid' + CKEDITOR.tools.capitalize( this.id ) ] );

        return isValid;
    }

    // Creates a function that pre-loads images. The callback function passes
    // [image, width, height] or null if loading failed.
    //
    // @returns {Function}
    function createPreLoader() {
        var image = doc.createElement( 'img' ),
            listeners = [];

        function addListener( event, callback ) {
            listeners.push( image.once( event, function( evt ) {
                removeListeners();
                callback( evt );
            } ) );
        }

        function removeListeners() {
            var l;

            while ( ( l = listeners.pop() ) )
                l.removeListener();
        }

        // @param {String} src.
        // @param {Function} callback.
        return function( src, callback, scope ) {
            addListener( 'load', function() {
                // Don't use image.$.(width|height) since it's buggy in IE9-10 (#11159)
                var dimensions = getNatural( image );

                callback.call( scope, image, dimensions.width, dimensions.height );
            } );

            addListener( 'error', function() {
                callback( null );
            } );

            addListener( 'abort', function() {
                callback( null );
            } );

            image.setAttribute( 'src', src + '?' + Math.random().toString( 16 ).substring( 2 ) );
        };
    }

    // This function updates width and height fields once the
    // "src" field is altered. Along with dimensions, also the
    // dimensions lock is adjusted.
    function onChangeSrc() {
        var value = this.getValue();

        toggleDimensions( false );

        // Remember that src is different than default.
        if ( value !== widget.data.src ) {
            // Update dimensions of the image once it's preloaded.
            preLoader( value, function( image, width, height ) {
                // Re-enable width and height fields.
                toggleDimensions( true );

                // There was problem loading the image. Unlock ratio.
                if ( !image )
                    return toggleLockRatio( false );

                // Fill width field with the width of the new image.
                widthField.setValue( width );

                // Fill height field with the height of the new image.
                heightField.setValue( height );

                // Cache the new width.
                preLoadedWidth = width;

                // Cache the new height.
                preLoadedHeight = height;

                // Check for new lock value if image exist.
                 toggleLockRatio( helpers.checkHasNaturalRatio( image ) );
            } );

            srcChanged = true;
        }

        // Value is the same as in widget data but is was
        // modified back in time. Roll back dimensions when restoring
        // default src.
        else if ( srcChanged ) {
            // Re-enable width and height fields.
            toggleDimensions( true );

            // Restore width field with cached width.
            widthField.setValue( domWidth );

            // Restore height field with cached height.
            heightField.setValue( domHeight );

            // Src equals default one back again.
            srcChanged = false;
        }

        // Value is the same as in widget data and it hadn't
        // been modified.
        else {
            // Re-enable width and height fields.
            toggleDimensions( true );
        }
    }

    function onChangeDimension() {
        // If ratio is un-locked, then we don't care what's next.
        if ( !lockRatio )
            return;

        var value = this.getValue();

        // No reason to auto-scale or unlock if the field is empty.
        if ( !value )
            return;

        // If the value of the field is invalid (e.g. with %), unlock ratio.
        if ( !value.match( regexGetSizeOrEmpty ) )
            toggleLockRatio( false );

        // No automatic re-scale when dimension is '0'.
        if ( value === '0' )
            return;

        var isWidth = this.id == 'width',
            // If dialog opened for the new image, domWidth and domHeight
            // will be empty. Use dimensions from pre-loader in such case instead.
            width = domWidth || preLoadedWidth,
            height = domHeight || preLoadedHeight;

        // If changing width, then auto-scale height.
        if ( isWidth )
            value = Math.round( height * ( value / width ) );

        // If changing height, then auto-scale width.
        else
            value = Math.round( width * ( value / height ) );

        // If the value is a number, apply it to the other field.
        if ( !isNaN( value ) )
            ( isWidth ? heightField : widthField ).setValue( value );
    }

    // Set-up function for lock and reset buttons:
    //  * Adds lock and reset buttons to focusables. Check if button exist first
    //    because it may be disabled e.g. due to ACF restrictions.
    //  * Register mouseover and mouseout event listeners for UI manipulations.
    //  * Register click event listeners for buttons.
    function onLoadLockReset() {
        var dialog = this.getDialog();

        function setupMouseClasses( el ) {
            el.on( 'mouseover', function() {
                this.addClass( 'cke_btn_over' );
            }, el );

            el.on( 'mouseout', function() {
                this.removeClass( 'cke_btn_over' );
            }, el );
        }

        // Create references to lock and reset buttons for this dialog instance.
        lockButton = doc.getById( lockButtonId );
        resetButton = doc.getById( resetButtonId );

        // Activate (Un)LockRatio button
        if ( lockButton ) {
            // Consider that there's an additional focusable field
            // in the dialog when the "browse" button is visible.
            dialog.addFocusable( lockButton, 4 + hasFileBrowser );

            lockButton.on( 'click', function( evt ) {
                toggleLockRatio();
                evt.data && evt.data.preventDefault();
            }, this.getDialog() );

            setupMouseClasses( lockButton );
        }

        // Activate the reset size button.
        if ( resetButton ) {
            // Consider that there's an additional focusable field
            // in the dialog when the "browse" button is visible.
            dialog.addFocusable( resetButton, 5 + hasFileBrowser );

            // Fills width and height fields with the original dimensions of the
            // image (stored in widget#data since widget#init).
            resetButton.on( 'click', function( evt ) {
                // If there's a new image loaded, reset button should revert
                // cached dimensions of pre-loaded DOM element.
                if ( srcChanged ) {
                    widthField.setValue( preLoadedWidth );
                    heightField.setValue( preLoadedHeight );
                }

                // If the old image remains, reset button should revert
                // dimensions as loaded when the dialog was first shown.
                else {
                    widthField.setValue( domWidth );
                    heightField.setValue( domHeight );
                }

                evt.data && evt.data.preventDefault();
            }, this );

            setupMouseClasses( resetButton );
        }
    }

    function toggleLockRatio( enable ) {
        // No locking if there's no radio (i.e. due to ACF).
        if ( !lockButton )
            return;

        if ( typeof enable == 'boolean' ) {
            // If user explicitly wants to decide whether
            // to lock or not, don't do anything.
            if ( userDefinedLock )
                return;

            lockRatio = enable;
        }

        // Undefined. User changed lock value.
        else {
            var width = widthField.getValue(),
                height;

            userDefinedLock = true;
            lockRatio = !lockRatio;

            // Automatically adjust height to width to match
            // the original ratio (based on dom- dimensions).
            if ( lockRatio && width ) {
                height = domHeight / domWidth * width;

                if ( !isNaN( height ) )
                    heightField.setValue( Math.round( height ) );
            }
        }

        lockButton[ lockRatio ? 'removeClass' : 'addClass' ]( 'cke_btn_unlocked' );
        lockButton.setAttribute( 'aria-checked', lockRatio );

        // Ratio button hc presentation - WHITE SQUARE / BLACK SQUARE
        if ( CKEDITOR.env.hc ) {
            var icon = lockButton.getChild( 0 );
            icon.setHtml( lockRatio ? CKEDITOR.env.ie ? '\u25A0' : '\u25A3' : CKEDITOR.env.ie ? '\u25A1' : '\u25A2' );
        }
    }

    function toggleDimensions( enable ) {
        var method = enable ? 'enable' : 'disable';

        widthField[ method ]();
        heightField[ method ]();
    }

    var hasFileBrowser = !!( editor.config.filebrowserImageBrowseUrl || editor.config.filebrowserBrowseUrl ),
        srcBoxChildren = [
            {
                id: 'src',
                type: 'text',
                label: commonLang.url,
                onKeyup: onChangeSrc,
                onChange: onChangeSrc,
                setup: function( widget ) {
                    this.setValue( widget.data.src );
                },
                commit: function( widget ) {
                    widget.setData( 'src', this.getValue() );
                },
                validate: CKEDITOR.dialog.validate.notEmpty( 'FIXME' )
            }
        ];

    // Render the "Browse" button on demand to avoid an "empty" (hidden child)
    // space in dialog layout that distorts the UI.
    if ( hasFileBrowser ) {
        srcBoxChildren.push( {
            type: 'button',
            id: 'browse',
            // v-align with the 'txtUrl' field.
            // TODO: We need something better than a fixed size here.
            style: 'display:inline-block;margin-top:16px;',
            align: 'center',
            label: editor.lang.common.browseServer,
            hidden: true,
            filebrowser: 'info:src'
        } );
    }
    
    return {
        title: lang.dialogTitle,
        minWidth: 295,
        minHeight: 100,
        onLoad: function() {
            // Create a "global" reference to the document for this dialog instance.
            doc = this._.element.getDocument();

            // Create a pre-loader used for determining dimensions of new images.
            preLoader = createPreLoader();
            
    // Create a "global" reference to edited widget.
            widget = this._.editor.widgets.focused;
        },
        onShow: function() {
        	widget = this._.editor.widgets.focused;

            // Create a "global" reference to widget's image.
            image = widget.parts.image;

            // Reset global variables.
            srcChanged = userDefinedLock = lockRatio = false;

            // Natural dimensions of the image.
            natural = getNatural( image );

            // Get the natural width of the image.
            preLoadedWidth = domWidth = natural.width;

            // Get the natural height of the image.
            preLoadedHeight = domHeight = natural.height;
            widget.data.height = image["$"].height;
			widget.data.width = image["$"].width;
            // Setup the content for ALL UI elements
            this.setupContent(widget);
        },
        onOk: function() {
            this.commitContent(widget);
        },
        contents: [
            {
                id: 'tab-info',
                label: lang.dialogTabInfo,
                elements: [
                    /*{
                        type: 'vbox',
                        padding: 0,
                        children: [
                            {
                                type: 'hbox',
                                widths: [ '100%' ],
                                children: srcBoxChildren
                            }
                        ]
                    },*/
                    {
                        id: 'rcoContent',
                        type: 'textarea',
                        label: lang.dialogCaption,
                        setup: function( widget ) {
                        	this.setValue( widget.getCaption() );
                        },
                        commit: function( widget ) {
                        	widget.setCaption(this.getValue());
                        }
                    },
                    {
                        type: 'hbox',
                        widths: [ '25%', '25%', '50%' ],
                        requiredContent: 'img[width,height]',
                        children: [
                            {
                                type: 'text',
                                width: '45px',
                                id: 'width',
                                label: commonLang.width,
                                validate: validateDimension,
                                onKeyUp: onChangeDimension,
                                onLoad: function() {
                                    widthField = this;
                                },
                                setup: function( widget ) {
                                    this.setValue( widget.data.width );
                                },
                                commit: function( widget ) {
                                    var newWidth = this.getValue();
                                    widget.setData('width', newWidth);
                                    $(widget.parts.image.$).width(newWidth);
                                }
                            },
                            {
                                type: 'text',
                                id: 'height',
                                width: '45px',
                                label: commonLang.height,
                                validate: validateDimension,
                                onKeyUp: onChangeDimension,
                                onLoad: function() {
                                    heightField = this;
                                },
                                setup: function( widget ) {
                                    this.setValue(widget.data.height);
                                },
                                commit: function( widget ) {
                                    var newHeight = this.getValue();
                                    widget.setData('height', newHeight);
                                    $(widget.parts.image.$).height(newHeight);
                                }
                            },
                            {
                                id: 'lock',
                                type: 'html',
                                style: lockResetStyle,
                                onLoad: onLoadLockReset,
                                setup: function( widget ) {
                                    toggleLockRatio( widget.data.lock );
                                },
                                commit: function( widget ) {
                                    widget.setData( 'lock', lockRatio );
                                },
                                html: lockResetHtml
                            }
                        ]
                    },
                    {
                        type: 'hbox',
                        id: 'alignment',
                        children: [
                            {
                                id: 'align',
                                type: 'radio',
                                items: [
                                    [ lang.none, 'none' ],
                                    [ lang.left, 'left' ],
                                    // ++ HAT1 ZUD: IR-441347-3DEXPERIENCER2018x fix
                                    //[ 'Center', 'center' ],
                                    [ lang.right, 'right' ] ],
                                label: commonLang.align,
                                setup: function( widget ) {
                                    this.setValue(widget.data.align);
                                },
                                commit: function( widget ) {
                                    var newAlign = this.getValue();
                                    widget.setData('align', newAlign);
                                    widget.element.setStyle('float', newAlign);
                                }
                            }
                        ]
                    }
                ]
            },
            {
                id: 'tab-adv',
                label: lang.dialogTabAdv,
                elements: [
                    {
                        type: 'html',
                        id: 'rcoFileName',
                        html: '',
                        setup: function( widget ) {
                            this.getElement().setHtml('<span style="font-weight:bold;">' + lang.titleFileName + '</span><br/>' + 
                            		'<span style="margin-left:10px">' + widget.data.rcoFileName + '</span>');
                        }
                    },
                    {
                        type: 'html',
                        id: 'rcoFileType',
                        html: '', 
                        setup: function( widget ) {
                            this.getElement().setHtml('<span style="font-weight:bold;">' + lang.titleMIME + '</span><br/>' + 
                            		'<span style="margin-left:10px">' + widget.data.rcoFileType + '</span>');
                        }
                    },
                    {
                        type: 'html',
                        id: 'rcoFileLastModified',
                        html: '',
                        setup: function( widget ) {
                            this.getElement().setHtml('<span style="font-weight:bold;">' + lang.titleModified + '</span><br/>' + 
                            		'<div style="margin-left:10px; max-width: 250px; overflow:hidden; text-overflow:ellipsis;">' + widget.data.rcoFileLastModified + '</div>');
                        }
                    }
                ]
            },
            {
                id: 'tap-upload',
                label: lang.dialogTabUpload,
                elements: [
                    {
                        type: 'html',
                        html: '',
                        setup: function( widget ) {
                            this.getElement().setHtml('<div id="dropZoneRCO" class="dropzone square"><img id="loadingImageRCO" style="margin-left: 50%; margin-right: 50%;" ' +
                                  'src="../webapps/RichEditorCusto/assets/ckeditor/plugins/rcowidget/images/loading.gif" onload="iniDropZoneRCO();"></div>');
                        }
                    }
                ]
            }
        ]
    };
} ); 
