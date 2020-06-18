/**
 * @license Copyright (c) Dassault Systems - All rights reserved.
 * 
 * Author: TRM Team
 */

function updateHTMLAfterRCOCreation(editor, response, options ) {

	editor.focus();

	var file = options.files[0];

	var widget = editor.widgets.focused; 
	if(widget) { //do not replace currently selected widget
		var range = editor.createRange();
		var nextElement = widget.element.getParent().getNext();
		range.setStartAt(nextElement, 0);
		range.setEndAt(nextElement, 1);
		editor.getSelection().selectRanges( [ range ] );
	}

	editor.execCommand('rcowidget');
	// Set the preview
	widget = editor.widgets.focused;

	// generate the preview if possible
	var imgPreview = undefined;
	var imagePath = '';
	var thumbnail = undefined;
	if (response) {
		try {
			var json = JSON.parse(response);
			if (json.thumbnail && json.thumbnail !== "") {
				thumbnail = json.thumbnail;
			}
		} catch (err) { }
	}

	if (thumbnail !== null && thumbnail !== undefined) {

		imagePath = 'data:image/jpeg;base64,' + thumbnail;

	} else {
		imagePath = CKEDITOR.plugins.rcowidget.getDefaultIcon();
	}

	imgPreview = jQuery('<img style="width:200px;height:200px" alt="RCO image" class="preview-image-rco" src="' + imagePath + '" />');

	widget.setPreview(imgPreview);
	widget.setCaption(file.name);

	widget.setData({
		align: 'left',
		width: 100,
		height: 100
	});

	widget.setData('rcoFileName', file.name);
	widget.setData('rcoFileType', file.type);
	widget.setData('rcoFileLastModified', file.lastModifiedDate);
	widget.setData('isSaved', true);

	// update html info
	jQuery(widget.element.$).data('data-rcowidget-saved', JSON.stringify(widget.data).replace(/"/g, '|'));
	delete widget.data['rcoCurrentObjectId'];
}

function loadAndInitDropZone(editor, serverURL, clientURL) {


	jQuery.getScript(clientURL + "/webapps/RichEditorCusto/assets/ckeditor/dropZone/dropzone.js")
	.done(function(script, textStatus) {

		jQuery('#loadingImageRCO').hide();

		var urlToUpload = serverURL + '/resources/richeditor/res/upload?'; // + csrfParams;

		var dropZoneId = 'dropZoneRCO_' + editor.name

		var dropzone = new Dropzone('#'+dropZoneId, {
			url: urlToUpload,
			maxFilesize: 150, // in MB
			uploadMultiple: false,
			maxFiles: 1,
			withCredentials: true
		});

		dropzone.on('success', function (file, serverResponse) {

			// Set the preview
			cke_widget = editor.widgets.focused;

			var _DELIMITER = '\7';
			var data = serverResponse.path.split(_DELIMITER),
			filePath = data[0], preview = data[1];

			var imgPreview = jQuery(file.previewElement).find('.dz-details').find('img');
			// If there is an issue with the preview, we put the default icon
			if (imgPreview.attr('src') == undefined) {

				var imagePath = '';
				if (preview != undefined) {
					imagePath = 'data:image/jpeg;base64,' + preview;
				}            	
				imgPreview = jQuery('<img width="200" height="200" alt="RCO image" class="preview-image-rco" src="' + imagePath + '" />');
			}

			if(preview != undefined) {
				cke_widget.setPreview(imgPreview);
			}

			cke_widget.setData({
				align: 'left',
				width: 100,
				height: 100
			});

			cke_widget.setData('rcoFileName', file.name);
			cke_widget.setData('rcoFileType', file.type);
			cke_widget.setData('rcoFileLastModified', file.lastModifiedDate);
			cke_widget.setData('rcoPathTempFile', filePath);
			cke_widget.setCaption(file.name);

			cke_widget.element.$.attributes['title'].textContent = editor.lang.rcowidget.titleFileName + ': ' + file.name + '\n' + 
			editor.lang.rcowidget.titleMIME + ': ' + file.type + '\n' + 
			editor.lang.rcowidget.titleModified + ': ' + file.lastModifiedDate;
			addDataToSessionStorage(cke_widget.data['rcoSerialId'], cke_widget.data);

			// In widgets we need to actually checkin the file
			if(UWA && UWA.is(window.widget)) {

				require(['DS/WAFData/WAFData', 'DS/PADUtils/PADContext'], function(WAFData, PADContext) {

					var fetchOpts = {};

					var physicalId = undefined;
					var selected_element = cke_widget.element.$.closest('.rich-object');
					if(selected_element) {

						physicalId = selected_element.dataset.physicalid;
					}

					var argsURL = '?objectId=' + physicalId + '&filePath=' + encodeURIComponent(cke_widget.data['rcoPathTempFile']) +
					'&refDocName=' + encodeURIComponent(cke_widget.data['rcoFileName']) /*+ '&' + csrfParams*/;

					/* CSRF Token management in POST request */
					var context = PADContext.get();
					if(UWA.is(context) && UWA.is(context.getCSRF)) {

						var csrf = context.getCSRF();
						var keys = Object.keys(csrf);
						keys.forEach(function(key) {

							argsURL += '&' + key + '=' + csrf[key];
						});
					}

					var url = serverURL + '/resources/richeditor/res/checkinRCOFromTempFile' + argsURL;

					fetchOpts.method = 'GET';
					fetchOpts.responseType = 'text';
					fetchOpts.onComplete = function(result) {

						cke_widget.data['isSaved'] = true;
						cke_widget.setCaption(cke_widget.data['rcoFileName']);

						sessionStorage.removeItem(cke_widget.data['rcoSerialId']);
						sessionStorage.removeItem('rco_ckeditor_list');
					};


					WAFData.authenticatedRequest(url, fetchOpts);

				});

			}

		});

	}).fail(function(jqxhr, settings, exception) {
		console.log('DropZone failed to load.');
	});

}

function iniDropZoneRCO() {

	var cke_path = CKEDITOR.basePath;
	var webapps_idx = cke_path.indexOf('/webapps');
	var clientURL = cke_path.substr(0, webapps_idx);

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
	csslink.href = clientURL + '/webapps/RichEditorCusto/assets/ckeditor/dropZone/css/dropzone.css';
	csslink.media = 'all';

	head.appendChild(csslink);

	var serverURL = '';
	if(UWA && UWA.is(window.widget)) {

		require(['DS/TraceableRequirementsUtils/Utils'], function(REQUtils) {

			serverURL = REQUtils.get3DSpaceUrl();
			editor = CKEDITOR.dialog.getCurrent()._.editor;
			loadAndInitDropZone(editor, serverURL, clientURL);

		});

	} else {

		loadAndInitDropZone(editor, serverURLWithRoot, clientURL);

	}




}

/** Add data to the session storage **/
function addDataToSessionStorage(idRCO, dataRCO) {
	if (sessionStorage.getItem('rco_ckeditor_list') == null)
		sessionStorage.setItem('rco_ckeditor_list', 'rco_ckeditor_' + idRCO);
	else
		sessionStorage.setItem('rco_ckeditor_list', sessionStorage.getItem('rco_ckeditor_list') + ' ' + 'rco_ckeditor_' + idRCO);

	sessionStorage.setItem('rco_ckeditor_' + idRCO, JSON.stringify(dataRCO));
}

CKEDITOR.dialog
.add(
		'rcowidgetDialog',
		function(editor) {

			// RegExp: 123, 123px, empty string ""
			var regexGetSizeOrEmpty = /(^\s*(\d+)(px)?\s*$)|^$/i,

			lockButtonId = CKEDITOR.tools.getNextId(), resetButtonId = CKEDITOR.tools
			.getNextId(),

			lang = editor.lang.rcowidget, commonLang = editor.lang.common,

			lockResetStyle = 'margin-top:18px;width:40px;height:20px;', lockResetHtml = new CKEDITOR.template(
					'<div>'
					+ '<a href="javascript:void(0)" tabindex="-1" title="'
					+ lang.lockRatio
					+ '" class="cke_btn_locked" id="{lockButtonId}" role="checkbox">'
					+ '<span class="cke_icon"></span>'
					+ '<span class="cke_label">'
					+ lang.lockRatio
					+ '</span>'
					+ '</a>'
					+

					'<a href="javascript:void(0)" tabindex="-1" title="'
					+ lang.resetSize
					+ '" class="cke_btn_reset" id="{resetButtonId}" role="button">'
					+ '<span class="cke_label">'
					+ lang.resetSize + '</span>' + '</a>'
					+ '</div>').output({
						lockButtonId : lockButtonId,
						resetButtonId : resetButtonId
					}),

					helpers = CKEDITOR.plugins.rcowidget,

					// Functions inherited from rcowidget plugin.
					checkHasNaturalRatio = helpers.checkHasNaturalRatio, getNatural = helpers.getNatural,

					// Global variables referring to the dialog's context.
					doc = null, cke_widget = null, image,

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
				var match = this.getValue().match(regexGetSizeOrEmpty), isValid = !!(match && parseInt(
						match[1], 10) !== 0);

				if (!isValid)
					alert(commonLang['invalid'
					                 + CKEDITOR.tools.capitalize(this.id)]);

				return isValid;
			}

			// Creates a function that pre-loads images. The callback function passes
			// [image, width, height] or null if loading failed.
			//
			// @returns {Function}
			function createPreLoader() {
				var image = doc.createElement('img'), listeners = [];

				function addListener(event, callback) {
					listeners.push(image.once(event, function(evt) {
						removeListeners();
						callback(evt);
					}));
				}

				function removeListeners() {
					var l;

					while ((l = listeners.pop()))
						l.removeListener();
				}

				// @param {String} src.
				// @param {Function} callback.
				return function(src, callback, scope) {
					addListener('load', function() {
						// Don't use image.$.(width|height) since it's buggy in IE9-10 (#11159)
						var dimensions = getNatural(image);

						callback.call(scope, image, dimensions.width,
								dimensions.height);
					});

					addListener('error', function() {
						callback(null);
					});

					addListener('abort', function() {
						callback(null);
					});

					image.setAttribute('src', src + '?'
							+ Math.random().toString(16).substring(2));
				};
			}

			// This function updates width and height fields once the
			// "src" field is altered. Along with dimensions, also the
			// dimensions lock is adjusted.
			function onChangeSrc() {
				var value = this.getValue();

				toggleDimensions(false);

				// Remember that src is different than default.
				if (value !== cke_widget.data.src) {
					// Update dimensions of the image once it's preloaded.
					preLoader(value, function(image, width, height) {
						// Re-enable width and height fields.
						toggleDimensions(true);

						// There was problem loading the image. Unlock ratio.
						if (!image)
							return toggleLockRatio(false);

						// Fill width field with the width of the new image.
						widthField.setValue(width);

						// Fill height field with the height of the new image.
						heightField.setValue(height);

						// Cache the new width.
						preLoadedWidth = width;

						// Cache the new height.
						preLoadedHeight = height;

						// Check for new lock value if image exist.
						toggleLockRatio(helpers
								.checkHasNaturalRatio(image));
					});

					srcChanged = true;
				}

				// Value is the same as in widget data but is was
				// modified back in time. Roll back dimensions when restoring
				// default src.
				else if (srcChanged) {
					// Re-enable width and height fields.
					toggleDimensions(true);

					// Restore width field with cached width.
					widthField.setValue(domWidth);

					// Restore height field with cached height.
					heightField.setValue(domHeight);

					// Src equals default one back again.
					srcChanged = false;
				}

				// Value is the same as in widget data and it hadn't
				// been modified.
				else {
					// Re-enable width and height fields.
					toggleDimensions(true);
				}
			}

			function onChangeDimension() {
				// If ratio is un-locked, then we don't care what's next.
				if (!lockRatio)
					return;

				var value = this.getValue();

				// No reason to auto-scale or unlock if the field is empty.
				if (!value)
					return;

				// If the value of the field is invalid (e.g. with %), unlock ratio.
				if (!value.match(regexGetSizeOrEmpty))
					toggleLockRatio(false);

				// No automatic re-scale when dimension is '0'.
				if (value === '0')
					return;

				var isWidth = this.id == 'width',
				// If dialog opened for the new image, domWidth and domHeight
				// will be empty. Use dimensions from pre-loader in such case instead.
				width = domWidth || preLoadedWidth, height = domHeight
				|| preLoadedHeight;

				// If changing width, then auto-scale height.
				if (isWidth)
					value = Math.round(height * (value / width));

				// If changing height, then auto-scale width.
				else
					value = Math.round(width * (value / height));

				// If the value is a number, apply it to the other field.
				if (!isNaN(value))
					(isWidth ? heightField : widthField)
					.setValue(value);
			}

			// Set-up function for lock and reset buttons:
			//  * Adds lock and reset buttons to focusables. Check if button exist first
			//    because it may be disabled e.g. due to ACF restrictions.
			//  * Register mouseover and mouseout event listeners for UI manipulations.
			//  * Register click event listeners for buttons.
			function onLoadLockReset() {
				var dialog = this.getDialog();

				function setupMouseClasses(el) {
					el.on('mouseover', function() {
						this.addClass('cke_btn_over');
					}, el);

					el.on('mouseout', function() {
						this.removeClass('cke_btn_over');
					}, el);
				}

				// Create references to lock and reset buttons for this dialog instance.
				lockButton = doc.getById(lockButtonId);
				resetButton = doc.getById(resetButtonId);

				// Activate (Un)LockRatio button
				if (lockButton) {
					// Consider that there's an additional focusable field
					// in the dialog when the "browse" button is visible.
					dialog.addFocusable(lockButton, 4 + hasFileBrowser);

					lockButton.on('click', function(evt) {
						toggleLockRatio();
						evt.data && evt.data.preventDefault();
					}, this.getDialog());

					setupMouseClasses(lockButton);
				}

				// Activate the reset size button.
				if (resetButton) {
					// Consider that there's an additional focusable field
					// in the dialog when the "browse" button is visible.
					dialog
					.addFocusable(resetButton,
							5 + hasFileBrowser);

					// Fills width and height fields with the original dimensions of the
					// image (stored in widget#data since widget#init).
					resetButton.on('click', function(evt) {
						// If there's a new image loaded, reset button should revert
						// cached dimensions of pre-loaded DOM element.
						if (srcChanged) {
							widthField.setValue(preLoadedWidth);
							heightField.setValue(preLoadedHeight);
						}

						// If the old image remains, reset button should revert
						// dimensions as loaded when the dialog was first shown.
						else {
							widthField.setValue(domWidth);
							heightField.setValue(domHeight);
						}

						evt.data && evt.data.preventDefault();
					}, this);

					setupMouseClasses(resetButton);
				}
			}

			function toggleLockRatio(enable) {
				// No locking if there's no radio (i.e. due to ACF).
				if (!lockButton)
					return;

				if (typeof enable == 'boolean') {
					// If user explicitly wants to decide whether
					// to lock or not, don't do anything.
					if (userDefinedLock)
						return;

					lockRatio = enable;
				}

				// Undefined. User changed lock value.
				else {
					var width = widthField.getValue(), height;

					userDefinedLock = true;
					lockRatio = !lockRatio;

					// Automatically adjust height to width to match
					// the original ratio (based on dom- dimensions).
					if (lockRatio && width) {
						height = domHeight / domWidth * width;

						if (!isNaN(height))
							heightField.setValue(Math.round(height));
					}
				}

				lockButton[lockRatio ? 'removeClass' : 'addClass']
				('cke_btn_unlocked');
				lockButton.setAttribute('aria-checked', lockRatio);

				// Ratio button hc presentation - WHITE SQUARE / BLACK SQUARE
				if (CKEDITOR.env.hc) {
					var icon = lockButton.getChild(0);
					icon.setHtml(lockRatio ? CKEDITOR.env.ie ? '\u25A0'
							: '\u25A3' : CKEDITOR.env.ie ? '\u25A1'
									: '\u25A2');
				}
			}

			function toggleDimensions(enable) {
				var method = enable ? 'enable' : 'disable';

				widthField[method]();
				heightField[method]();
			}

			var hasFileBrowser = !!(editor.config.filebrowserImageBrowseUrl || editor.config.filebrowserBrowseUrl), srcBoxChildren = [ {
				id : 'src',
				type : 'text',
				label : commonLang.url,
				onKeyup : onChangeSrc,
				onChange : onChangeSrc,
				setup : function(cke_widget) {
					this.setValue(cke_widget.data.src);
				},
				commit : function(cke_widget) {
					cke_widget.setData('src', this.getValue());
				},
				validate : CKEDITOR.dialog.validate.notEmpty('FIXME')
			} ];

			// Render the "Browse" button on demand to avoid an "empty" (hidden child)
			// space in dialog layout that distorts the UI.
			if (hasFileBrowser) {
				srcBoxChildren.push({
					type : 'button',
					id : 'browse',
					// v-align with the 'txtUrl' field.
					// TODO: We need something better than a fixed size here.
					style : 'display:inline-block;margin-top:16px;',
					align : 'center',
					label : editor.lang.common.browseServer,
					hidden : true,
					filebrowser : 'info:src'
				});
			}

			return {
				title : lang.dialogTitle,
				minWidth : 450,
				minHeight : 180,
				onLoad : function(event) {

					// Create a "global" reference to the document for this dialog instance.
					doc = this._.element.getDocument();

					// Create a pre-loader used for determining dimensions of new images.
					preLoader = createPreLoader();

					// Create a "global" reference to edited widget.
					cke_widget = this._.editor.widgets.focused;

				},
				onShow : function(event) {

					cke_widget = this._.editor.widgets.focused;

					if(cke_widget) {

						// Create a "global" reference to widget's image.
						image = cke_widget.parts.image;

						// Reset global variables.
						srcChanged = userDefinedLock = lockRatio = false;

						// Natural dimensions of the image.
						natural = getNatural(image);

						// Get the natural width of the image.
						preLoadedWidth = domWidth = natural.width;

						// Get the natural height of the image.
						preLoadedHeight = domHeight = natural.height;

						// Setup the content for ALL UI elements
						this.setupContent(cke_widget);

						// hide the creation page
						this.showPage('tab-info');
						this.showPage('tab-adv');
						this.showPage('tab-upload');
						this.hidePage('tab-create');

						// when triggered from contextual menu
						if(widget_dialog_selected_page) {
							this.showPage('tab-upload');
							this.selectPage(widget_dialog_selected_page);
							widget_dialog_selected_page = null;
						}

						// hack, make sure OK & Cancel buttons are visible
						if(document.getElementById(this.getButton('ok').domId).style.display === "none") {
							document.getElementById(this.getButton('ok').domId).style.display = "";
						}
						if(document.getElementById(this.getButton('cancel').domId).style.display === "none") {
							document.getElementById(this.getButton('cancel').domId).style.display = "";
						}

					} else {

						// if no widget is on focus, we need to disable the following tab:
						// - properties
						// - upload
						// - download
						// and navigate directly to create tab
						this.hidePage('tab-info');
						this.hidePage('tab-adv');
						this.hidePage('tab-upload');
						this.showPage('tab-create');

						//hack Hide OK & Cancel Button in this case
						document.getElementById(this.getButton('ok').domId).style.display = "none";
						document.getElementById(this.getButton('cancel').domId).style.display = "none";
					}

				},
				onOk : function() {

					if(cke_widget) {
						this.commitContent(cke_widget);
					}

					// IR-530900
					// need to clean the file stored
					cke_file = undefined;

				},
				onCancel: function() {
					// IR-530900
					// need to clean the file stored
					cke_file = undefined;
				},
				contents : [
				            {
				            	id: 'tab-create',
				            	label: lang.dialogTabCreate,
				            	elements: [{
				            		type: 'file',
				            		id: 'rco-create-button',
				            		label: lang.dialogButtonSelectFile,
				            		size: 38,
				            		onChange: function(event) {
				            			// keep file information
				            			cke_file = event;

				            		}
				            	},{
				            		type: 'button',
				            		id: 'rco-fileId',
				            		label: lang.dialogButtonCreateRCO,
				            		onClick: function(event) {
				            			var n = null;
				            			if(cke_file) {

				            				try {
				            					n = cke_file.sender.getInputElement().$;
				            				} catch(e) {
				            					n = null;
				            				}

				            				if(n && "files" in n && n.files && n.files.length > 0 && n.files[0]) {
				            					// we have a file to upload
				            					// widget case
				            					if(UWA && UWA.is(window.widget)) {

				            						var _dialog = this.getDialog();

				            						var editor = _dialog.getParentEditor();

				            						var selected_element = editor.element.$;
				            						var physicalid = null;
				            						var closest_object = undefined;
				            						// IR-530324-3DEXPERIENCER2017x
				            						if(selected_element.hasOwnProperty('closest')) {
				            							closest_object = selected_element.closest('.rich-object');
				            						} else {
				            							closest_object = selected_element.getClosest('.rich-object');
				            						}
				            						//

				            						if(closest_object) {
				            							physicalid = closest_object.dataset.physicalid;
				            						}
				            						var isCreationAuthorized = true;
				            						// check that the file name is not already used
				            						for(var entry in editor.widgets.instances) {
				            							var w = editor.widgets.instances[entry];
				            							if(w.data['rcoFileName'] == n.files[0].name) {
				            								isCreationAuthorized = false;
				            								alert(editor.lang.rcowidget.rcoDuplicate);
				            							}
				            						}
				            						
				                					// check if the file is not too big, should be below 5MB
				                					if(n.files[0].size > (5 * 1024 * 1024)) {
				                						isCreationAuthorized = false;
				                						alert(editor.lang.rcowidget.rcoSizeLimit);
				                					}

				            						if(isCreationAuthorized !== false) {

				            							require(['DS/TraceableRequirementsUtils/Services/RichContentObjectServices', 
				            							         'DS/PADUtils/PADContext'], function(RCOServices, PADContext) {

				            								var widget_context = PADContext.get();

				            								if(widget_context) {
				            									widget_context.showProgressBar();
				            								}

				            								var _rcoService = new RCOServices();
				            								_rcoService.checkinFiles({
				            									physicalid: physicalid,
				            									files: n.files,
				            									callbacks: {
				            										onComplete: function(response, options) {

				            											if(widget_context) {
				            												widget_context.displayNotification({
				            													eventID: 'success',
				            													msg: 'File uploaded.'
				            												});
				            												widget_context.hideProgressBar();
				            											}

				            											// close the dialog
				            											_dialog.getButton('ok').click();

				            											updateHTMLAfterRCOCreation(editor, response, options );


				            										}, 
				            										onFailure: function(error) {
				            											//display notif
				            											if(widget_context) {
				            												widget_context.displayNotification({
				            													eventID: 'error',
				            													msg: editor.lang.rcowidget.serverError
				            												});
				            												
				            												widget_context.hideProgressBar();
				            											}
				            											

				            											console.warn(error);
				            										},
				            										onTimeout: function(error) {
				            										    // WAFData request has timeout of 4 min here
				            											if(widget_context) {
				            												widget_context.displayNotification({
				            													eventID: 'error',
				            													msg: editor.lang.rcowidget.serverTimeout
				            												});
				            												
				            												widget_context.hideProgressBar();
				            											}
				            											

				            											console.warn(error);
				            										}
				            									}
				            								});
				            							});
				            						}

				            					} else {
				            						// TODO 3DSpace case
				            					}
				            				}
				            			}

				            		},
				            		onShow: function(event) {
				            			// hack, if the filechooser has the focus, the editor will lose the toolbar
				            			if(this.getDialog()._.currentTabId === 'tab-create') {
				            				this.focus();
				            			}	
				            		}
				            	}]
				            },
				            {
				            	id : 'tab-info',
				            	label : lang.dialogTabInfo,
				            	elements : [
				            	            {
				            	            	id : 'rcoContent',
				            	            	type : 'textarea',
				            	            	label : lang.dialogCaption,
				            	            	setup : function(cke_widget) {

				            	            		this.setValue(cke_widget.getCaption() );
				            	            	},
				            	            	commit : function(cke_widget) {

				            	            		if(this.isChanged() === true) {
				            	            			cke_widget.setCaption(this.getValue());
				            	            		}

				            	            	}
				            	            },
				            	            {
				            	            	type : 'hbox',
				            	            	widths : [ '25%', '25%', '50%' ],
				            	            	requiredContent : 'img[width,height]',
				            	            	children : [
				            	            	            {
				            	            	            	type : 'text',
				            	            	            	width : '45px',
				            	            	            	id : 'width',
				            	            	            	label : commonLang.width,
				            	            	            	validate : validateDimension,
				            	            	            	onKeyUp : onChangeDimension,
				            	            	            	onLoad : function() {
				            	            	            		widthField = this;
				            	            	            	},
				            	            	            	setup : function(
				            	            	            			cke_widget) {
				            	            	            		this
				            	            	            		.setValue(cke_widget.data.width);
				            	            	            	},
				            	            	            	commit : function(
				            	            	            			cke_widget) {
				            	            	            		var newWidth = this
				            	            	            		.getValue();
				            	            	            		cke_widget
				            	            	            		.setData(
				            	            	            				'width',
				            	            	            				newWidth);
				            	            	            		jQuery(
				            	            	            				cke_widget.parts.image.$)
				            	            	            				.width(
				            	            	            						newWidth);
				            	            	            	}
				            	            	            },
				            	            	            {
				            	            	            	type : 'text',
				            	            	            	id : 'height',
				            	            	            	width : '45px',
				            	            	            	label : commonLang.height,
				            	            	            	validate : validateDimension,
				            	            	            	onKeyUp : onChangeDimension,
				            	            	            	onLoad : function() {
				            	            	            		heightField = this;
				            	            	            	},
				            	            	            	setup : function(
				            	            	            			cke_widget) {
				            	            	            		this
				            	            	            		.setValue(cke_widget.data.height);
				            	            	            	},
				            	            	            	commit : function(
				            	            	            			cke_widget) {
				            	            	            		var newHeight = this
				            	            	            		.getValue();
				            	            	            		cke_widget
				            	            	            		.setData(
				            	            	            				'height',
				            	            	            				newHeight);
				            	            	            		jQuery(
				            	            	            				cke_widget.parts.image.$)
				            	            	            				.height(
				            	            	            						newHeight);
				            	            	            	}
				            	            	            },
				            	            	            {
				            	            	            	id : 'lock',
				            	            	            	type : 'html',
				            	            	            	style : lockResetStyle,
				            	            	            	onLoad : onLoadLockReset,
				            	            	            	setup : function(
				            	            	            			cke_widget) {
				            	            	            		toggleLockRatio(cke_widget.data.lock);
				            	            	            	},
				            	            	            	commit : function(
				            	            	            			cke_widget) {
				            	            	            		cke_widget
				            	            	            		.setData(
				            	            	            				'lock',
				            	            	            				lockRatio);
				            	            	            	},
				            	            	            	html : lockResetHtml
				            	            	            } ]
				            	            },
				            	            {
				            	            	type : 'hbox',
				            	            	id : 'alignment',
				            	            	children : [ {
				            	            		id : 'align',
				            	            		type : 'radio',
				            	            		items : [
				            	            		         [ lang.none, 'none' ],
				            	            		         [ lang.left, 'left' ],
				            	            		         [ lang.right, 'right'] ],
				            	            		         label : commonLang.align,
				            	            		         setup : function(cke_widget) {
				            	            		        	 this
				            	            		        	 .setValue(cke_widget.data.align);
				            	            		         },
				            	            		         commit : function(cke_widget) {
				            	            		        	 var newAlign = this
				            	            		        	 .getValue();
				            	            		        	 cke_widget.setData('align',
				            	            		        			 newAlign);
				            	            		        	 cke_widget.element
				            	            		        	 .setStyle(
				            	            		        			 'float',
				            	            		        			 newAlign);
				            	            		         }
				            	            	} ]
				            	            } ]
				            },
				            {
				            	id : 'tab-adv',
				            	label : lang.dialogTabAdv,
				            	elements : [
				            	            {
				            	            	type : 'html',
				            	            	id : 'rcoFileName',
				            	            	html : '',
				            	            	setup : function(cke_widget) {
				            	            		this
				            	            		.getElement()
				            	            		.setHtml(
				            	            				'<span style="font-weight:bold;">'
				            	            				+ lang.titleFileName
				            	            				+ '</span><br/>'
				            	            				+ '<span style="margin-left:10px">'
				            	            				+ cke_widget.data.rcoFileName
				            	            				+ '</span>');
				            	            	}
				            	            },
				            	            {
				            	            	type : 'html',
				            	            	id : 'rcoFileType',
				            	            	html : '',
				            	            	setup : function(cke_widget) {
				            	            		this
				            	            		.getElement()
				            	            		.setHtml(
				            	            				'<span style="font-weight:bold;">'
				            	            				+ lang.titleMIME
				            	            				+ '</span><br/>'
				            	            				+ '<span style="margin-left:10px">'
				            	            				+ cke_widget.data.rcoFileType
				            	            				+ '</span>');
				            	            	}
				            	            },
				            	            {
				            	            	type : 'html',
				            	            	id : 'rcoFileLastModified',
				            	            	html : '',
				            	            	setup : function(cke_widget) {
				            	            		this
				            	            		.getElement()
				            	            		.setHtml(
				            	            				'<span style="font-weight:bold;">'
				            	            				+ lang.titleModified
				            	            				+ '</span><br/>'
				            	            				+ '<div style="margin-left:10px; max-width: 250px; overflow:hidden; text-overflow:ellipsis;">'
				            	            				+ cke_widget.data.rcoFileLastModified
				            	            				+ '</div>');
				            	            	}
				            	            } ]
				            },
				            {
				            	id : 'tab-upload',
				            	label : lang.dialogTabUpload,
				            	elements : [ {
				            		type : 'html',
				            		html : '',
				            		setup : function(cke_widget) {

				            			var cke_path = CKEDITOR.basePath;
				            			var webapps_idx = cke_path.indexOf('webapps');
				            			var server_url = cke_path.substr(0, webapps_idx);
				            			var loadingGIF_url = server_url + 'webapps/VENREQPlugins/External/ckeditor/plugins/rcowidget/images/loading.gif';

				            			var dropZoneId = 'dropZoneRCO_' + cke_widget.editor.name;
				            			this
				            			.getElement()
				            			.setHtml(
				            					'<div id="'+dropZoneId+'" class="dropzone square"><img id="loadingImageRCO" style="margin-left: 50%; margin-right: 50%;" '
				            					+ 'src="'+loadingGIF_url+'" onload="iniDropZoneRCO();"></div>');
				            		}
				            	} ]
				            } ]
			};
		});
