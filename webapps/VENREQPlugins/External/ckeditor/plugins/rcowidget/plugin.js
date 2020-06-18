/**
 * @license Copyright (c) Dassault Systems - All rights reserved.
 * This plugin allows a user to create a rich content object inside his HTML content.
 * This new object is basically a Microsoft Office Document (Word, Excel, or others) and can be edited 
 * by opening its content directly in Word (Edit in Word).
 * 
 * After the save, the data is updated automatically.
 * 
 * Author: TRM Team
 */

(function() {

	// local plugin path
	var pluginPath = '';
	var defaultIcon = '';

	// generate uuid
	var rco_uuid = generateUUID();
	
	// create global variable
	window.widget_dialog_selected_page = null;
	
	//Array contaning the RCOs for the current editor
	var aRCOs = null;
	
	CKEDITOR.plugins.add('rcowidget',{
		lang: 'de,en,es,fr,it,ja,zh,zh-cn',
		requires: 'widget,dialog,clipboard',
		icons: 'rcowidget',
		
		onLoad: function (editor) {
            CKEDITOR.addCss(".cke_image_resizer{display:none;position:absolute;bottom:2px;width: 0px;height: 0px;border-style:solid;right:2px;border-width:0 0 10px 10px;border-color:transparent transparent #ccc transparent;" + 
                    CKEDITOR.tools.cssVendorPrefix("box-shadow", "1px 1px 0px #777", !0) + ";cursor:se-resize;}.cke_image_resizer_wrapper{position:relative;display:inline-block;line-height:0;}.cke_image_resizer.cke_image_resizer_left{right:auto;left:2px;border-width:10px 0 0 10px;border-color:transparent transparent transparent #ccc;" + CKEDITOR.tools.cssVendorPrefix("box-shadow", "-1px 1px 0px #777", !0) + ";cursor:sw-resize;}.cke_widget_wrapper:hover .cke_image_resizer{display:block;}");
        },
        
        init: function(editor) {
        	
        	// Global variable for the path
            pluginPath = this.path;
        	// Global variable for the path
            defaultIcon = pluginPath + 'images/defaultIcon.png';
            
            var rco = widgetDef(editor);
            
            // register the dialog
            CKEDITOR.dialog.add('rcowidgetDialog', this.path + 'dialogs/rcowidget.js');
            
            /* PROTOTYPE ADDED BY JX5 - START */
            var rcoCmdPluginName = 'rcowidgetDialog';
            editor.ui.addButton('rcowidgetCmd', {
            	label: editor.lang.rcowidget.cmdManageRCO,
            	command: 'dispRCOWidget',
            	toolbar: 'insert',
            	icon: this.path + 'icons/rcowidget.png'
            });
            
            /*editor.addCommand(rcoCmdPluginName,
                    new CKEDITOR.dialogCommand(rcoCmdPluginName));*/

            /* PROTOTYPE ADDED BY JX5 - END */
            
            // register the properties command
            editor.addCommand('dispRCOWidget',
                    new CKEDITOR.dialogCommand(rcoCmdPluginName));
            
            //register the widget
            editor.widgets.add('rcowidget', rco);
            
            /**
             * CONTEXTUAL MENU
             */
            editor.addMenuGroup('rcoContextualMenu', -1);
            
            function isRCOSaved(editor) {
                // The reference document is not created yet
                if (editor.widgets.focused.data['isSaved'] == false) {
                    alert(editor.lang.rcowidget.rcoSave);
                    return false;
                }
                return true;
            }
            
            // Register the command to download the RCO
            editor.addCommand("rcoDownload", {
                exec: function (editor) {
                
                	var physicalid = '';
                	var selected_element = editor.widgets.focused.element.$;
                	var rco_data = editor.widgets.focused.data;
                	
                	// check if we are in a widget environment
                	if(UWA && UWA.is(window.widget)) {
                		
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
                    	
                    	require(['DS/TraceableRequirementsUtils/Utils', 'DS/DocumentManagement/DocumentManagement'], function(REQUtils, DocumentManagement) {
                    		
                    		var options = {
                					tenant: REQUtils.getTenant(),
                					securityContext: REQUtils.getSecurityContext(),
                					tenantUrl: REQUtils.get3DSpaceUrl(),
                					onComplete: function(url) {
                						if(UWA.is(url)) {
                							window.open(url + '&__fcs__attachment=true', '_self');
                						}
                					},
                					onTimeout: function(err) {
                 						// FIXME
                						alert('Download failure');
                					},
                					onFailure: function(err) {
                						// FIXME
                						alert('Download failure');
                					}
                			}
                    		
                    		// download the document according to filename and format
                    		var fileInformation = {
                    			title: 	rco_data['rcoFileName'],
                    			format: 'rco'
                    		};
                			DocumentManagement.downloadDocument(physicalid /*objectID*/, fileInformation /*fileID*/, false /*icheckout*/, options /*options*/);
                    		
                    	});
                	} else {
                		 // in 3DSpace Structure Browser
                		 if (isRCOSaved(editor)) {
                			 
                			 if(window.editableTable){
                				 physicalid = jQuery(this).closest("tr[o]").attr("o");
            				 }else{
            					 physicalid = jQuery("input[name='objectId']").val();
            				 }
                			 
                			 var fileName = rco_data['rcoFileName'];
                			 var format = 'rco';
                			 var action = 'download';
                			 
                			 if(callCheckout) {
                				 
                				 callCheckout(physicalid, action, fileName, format, 'null', 'null', 'structureBrowser', 'APPDocuemntSummary', '');
                			 }
                		 }
                			 
                	}

                }
            });
            
            editor.addCommand("rcoUpload", {
            	exec: function (editor) {
            		widget_dialog_selected_page = 'tab-upload';
            		editor.execCommand('dispRCOWidget');
            	}
            });
            
            editor.addCommand("rcoProperties", {
            	exec: function (editor) {
            		widget_dialog_selected_page = 'tab-adv';
            		 editor.execCommand('dispRCOWidget');
            	}
            }); 
            
            // If the "menu" plugin is loaded, register the menu items.
            if (editor.addMenuItems) {
            	editor.addMenuItems({
            		rcoContextualMenu : {
            			label : editor.lang.rcowidget.cmActions,
            			icon: this.path + '/images/action.png',
                        group : 'rcoContextualMenu',
                        order : 1,
                        getItems : function() {
                        	return {
                        		rcoDownload : CKEDITOR.TRISTATE_OFF,
                        		rcoUpload : CKEDITOR.TRISTATE_OFF
                        	};
                        }
            		},
            		rcoDownload : {
            			label : editor.lang.rcowidget.cmDl,
                        icon: this.path + '/images/download.png',
                        group : 'rcoContextualMenu',
                        command : 'rcoDownload',
                        order : 12
            		},
            		rcoUpload : {
            			
            			label : editor.lang.rcowidget.cmUpload,
                        icon: this.path + '/images/upload.png',
                        group : 'rcoContextualMenu',
                        command : 'rcoUpload',
                        order : 13
            		},
            		rcoProperties: {
                        label: editor.lang.rcowidget.cmProperties,
                        icon: this.path + '/images/properties.png',
                        command: 'rcoProperties',
                        group: 'rcoContextualMenu',
                        order: 2
                    }
            	});
            }
            
            // If the "contextmenu" plugin is loaded, register the listeners.
            if (editor.contextMenu) {
            	
            	editor.contextMenu.addListener(function(element, selection) {
            		return getSelectedRCOWidget(editor, element);
            	});
            }
            
            /**
             * EVENTS
             */
            editor.on('destroy', function(event) {
            	// nothing here for now
            });
            
            editor.on('change', function(event) {
            	// nothing here for now
            });
            
            editor.on('paste', function(event) {
            	// event triggered when an object is pasted on CKEditor window
            	console.log('CKEDITOR onPaste event', event);
            	
            	var ua = window.navigator.userAgent;
            	
            	var isEdge = false;
            	var isIE = false;

                var msie = ua.indexOf('MSIE ');
                if (msie > 0) {
                	isIE = true;
                }
                
                var edge = ua.indexOf('Edge/');
                if (edge > 0) {
                	isEdge = true;
                }
            	
            	var physicalid = '';
            	var selected_element = event.editor.element.$; 

            	if(!event.data.dataTransfer) {
            		return;
            	}
            	
            	var files, items, dataTransfer,  _results;
            	var dataTransfer = event.data.dataTransfer.$;

            	var rtf_data = event.data.dataTransfer._.data["text/rtf"];
				
			//++VMA10 added IR-685550-3DEXPERIENCER2019x
				var div = document.createElement('div');
				div.id = "tdOperation"
				div.innerHTML = event.data.dataValue;
				var allDivTd = div.getElementsByTagName("TD");
				
				for(var i=0 ; i< allDivTd.length ; i++)
				{
					if(allDivTd[i].vAlign=="bottom")
						{
							allDivTd[i].style.verticalAlign = "bottom"
						}else if(allDivTd[i].vAlign =="")
						{
							allDivTd[i].style.verticalAlign = "middle";
						}else if(allDivTd[i].vAlign="top")
						{
							allDivTd[i].style.verticalAlign = "top";
						}
				}
				
				event.data.dataValue = div.innerHTML; 
			//--VMA10

            	if(rtf_data != undefined && !isEdge && !isIE){
	            	require(['DS/TraceableRequirementsUtils/Services/RequirementWebServices', 'DS/PADUtils/PADContext','DS/CKEditor/CKEditor'], function (RequirementWebServices, PADContext, CKEditor) {RequirementWebServices.handlePasteEvent({
		     				json: {
		     					"ooxml": rtf_data
		      				},
		         			onComplete: function(html ) {
								html = JSON.parse(html);
								
								// ++VMA10 ZUD added IR-700982-3DEXPERIENCER2019x
									var div = document.createElement('div')
		                            	div.innerHTML = html.html
		                            	div.id = "containerDiv";
		                            	var tables = div.getElementsByTagName('table');
		                            	if(tables.length > 0)
		                            	{
		                            		for(var a=0; a< tables.length ; a++)
		                            		{
		                            			removeHeightOfDiv(tables[a])
		                            	 	}
		                            	}
		                            	function removeHeightOfDiv(table)
		                            	{
		                            		var childs = [].slice.call(table.getElementsByTagName('td')) ;
		                            		childs = childs.filter(function (x){ return x.getAttribute('rowSpan')!=null})
		                            		childs = childs.filter(function (x){return x.style.getPropertyValue('writing-mode')!=""})

		                            		for(var i=0; i< childs.length ; i++)
		                            		{   	var tdTag = childs[i];
		                            					                            			
		                            				var rowspan = tdTag.getAttribute('rowspan');
		                            				var divsInTD  =  tdTag.getElementsByTagName('div');
		                            				for(var j=0; j < divsInTD.length ; j++)
		                            				{
		                            					if( rowspan !=null)
		                            					{
		                            						divsInTD[j].style.removeProperty('height');
		                            					}
		                            				}				
		                            		}
		                            	}
		                            	html.html = div.innerHTML;		                            			                     
								// --VMA10 ZUD added IR-700982-3DEXPERIENCER2019x
								
				            	editor.insertHtml(html.html);
		         			},
		         			onFailure: function(error){
		    					console.log("error");
		    					console.log(error);
		         			}
		    			});
	            	});
	            	return false;
            	}
            	
            
          	var imageAsfile = event.data.dataTransfer._.files[0];

          	if(rtf_data == undefined && imageAsfile != undefined && !isEdge && !isIE){
	          	  var reader = new FileReader();
	          	   reader.readAsDataURL(imageAsfile);
	          	   reader.onload = function () {
					   var image = new Image();
		          	   image.src = reader.result;
						   
					   image.onload = function(){
							width = image.width;
							height = image.height;
							CKEDITOR.instances[event.editor.name].insertHtml('<img width="'+width+'" height="'+height+'" src="' + reader.result + '" />');
							return false;
					   };  
	          	   };
	          	   reader.onerror = function (error) {
	          	     console.log('Error: ', error);
	          	   };
          	}   
          	
          	
    			var files, items, _results = [],
			 	item, file, entry;
    			
    			// treat the paste/drop scenario only if the dataTransfer contains files
    			if(dataTransfer !== null && dataTransfer !== undefined 
    				&& dataTransfer.files !== null && dataTransfer.files !== undefined
    				&& dataTransfer.files.length !== 0) {
    				
    				
        			files = dataTransfer.files;
    				if(files.length) {
    					items =  dataTransfer.items;
    					if(items && items.lenght && (items[0].webkitGetAsEntry != null)) {
    							
    							item = items[0];
    							if ((item.webkitGetAsEntry != null) && (entry = item.webkitGetAsEntry())) {
    								
    								if (entry.isFile) {
    									_results.push(item.getAsFile());
    									
    								} else {
    									_results.push(void 0);
    								}
    								
    							} else if (item.getAsFile != null) {
    								
    								if ((item.kind == null) || item.kind === "file") {
    									
    									_results.push(item.getAsFile());
    									
    								} else {
    									
    									_results.push(void 0)
    								}
    								
    							} else {
    								_results.push(void 0);
    							}
    						
    					} else {
    	
    							file = files[0];
    							_results.push(file);
    					}
    				}
    				

                	if(UWA && UWA.is(window.widget)) {
                		
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
                    	
                    	
                    	// Check if the operation is accepted
                    	var isCreationAuthorized = true;
        				if(_results.length > 0) {
        					
        					// check that the file name is not already used
        					for(var entry in editor.widgets.instances) {
        						var w = editor.widgets.instances[entry];
                                if(w.data['rcoFileName'] == _results[0].name) {
                                	isCreationAuthorized = false;
                                	alert(editor.lang.rcowidget.rcoDuplicate);
                                }
        					}
        					
        					// check if the file is not too big, should be below 5MB
        					if(_results[0].size > (5 * 1024 * 1024)) {
        						isCreationAuthorized = false;
        						alert(editor.lang.rcowidget.rcoSizeLimit);
        					}
        					       					
        				}
        				
        				if(isCreationAuthorized !== false) {
        					
                    		require(['DS/TraceableRequirementsUtils/Services/RichContentObjectServices', 
                    		         'DS/PADUtils/PADContext'], function(RCOServices, PADContext) {
                    			
                    			var _rcoService = new RCOServices();
                    			
    							var widget_context = PADContext.get();

								if(widget_context) {
									widget_context.showProgressBar();
								}
                    			
                    			_rcoService.checkinFiles({
                    				physicalid: physicalid,
                    				files: _results,
                    				callbacks: {
                    					onComplete: function(response, options) {
                    						
											if(widget_context) {
												widget_context.displayNotification({
													eventID: 'success',
													msg: 'File uploaded.'
												});
												widget_context.hideProgressBar();
											}
                    						// update widget data
                    						
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
                    	                        imagePath = defaultIcon;
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
                    	                    
                    	                    //
                    						
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
                    						// the WAFData request has a timeout of 4 min
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
	
            		}
    				
    			}
    			

            });
        }
	});
	
	
	function widgetDef(editor) {
		
		var template = '<img alt="RCO image" src="" />',
        templateBlock = '<figure data-rcowidget-saved=\'\' title="' + editor.lang.rcowidget.titleDefault + '" class="rcowidget" style="display:inline-block">' +
        template +
        '<figcaption style="background: White;">' + editor.lang.rcowidget.captionDefault + '</figcaption>' +
        '</figure><p></p>';
		
		// If we have already some data
        var oldDataRCO = null;
        
        return {
        	inline: false,
        	allowedContent: {
                figcaption: {
                    styles: 'background'
                },
                figure: {
                    classes: '!rcowidget',
                    styles: 'float,display',
                        attributes: '!title, !data-rcowidget-saved'
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
                if (el.hasClass('rcowidget') == true) {
                    return el;
                }
                return false;
            },
            downcast: function (el) {
                if (el.hasClass('rcowidget') == true) {
                    var attrs = el.attributes;
                    attrs['data-rcowidget-saved'] = JSON.stringify(this.data).replace(/"/g, '|');
                    delete this.data['rcoCurrentObjectId'];
                    return el;
                }
                return false;
            },
            fixIME: function ()	{
            	this.parts.caption.$.parentElement.setAttribute("data-cke-widget-upcasted", 1);
            },
            setPreview: function (content) {
                this.parts.image.setAttributes({
                    src: jQuery(content).attr('src'),
                    alt: jQuery(content).attr('alt'),
                    "data-cke-saved-src" : jQuery(content).attr('src')
                });
                setupResizer(this);
            },
            setCaption: function (caption) {
            	this.parts.caption.setText(caption);
            },
            getCaption: function () {
            	return this.parts.caption.getText();
            },
            data: function () {
                var cke_widget = this,
                    editor = cke_widget.editor,
                    editable = editor.editable();
            },
            init: function () {

            	for (var entry in CKEDITOR.instances) break;
                var editor = CKEDITOR.instances[entry];

                var editorSerialId = editor.name.substring("CKEDITOR_".length);
                
                var rcoSerialId = rco_uuid + '_' + this.id;

                // restore existing data
            	var existingData = this.element.getAttribute('data-rcowidget-saved');
            	
            	if(existingData){
            		if(existingData.indexOf("|")) {
            			this.data = JSON.parse(existingData.replace(/\|/g, '"'));
            		}
            		else {
                		this.data = JSON.parse(existingData.replace(/'/g, '"'));
            		}
            		
            		return false;
            	}
            	
            	// We can set the loading gif
                var image = this.parts.image;
                if (image != undefined)
                    image.src = pluginPath + 'images/loading.gif';
                
                this.setData('rcoSerialId', rcoSerialId);
                
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
            	// nothing here for now
            }
        };
	}
	
	function getSelectedRCOWidget(editor, element) {
		
		if (!element) {
            var sel = editor.getSelection();
            element = sel.getSelectedElement();
        }
		
		if (element.find(".rcowidget").$.length != 0) {
			
			return {
                rcoContextualMenu: CKEDITOR.TRISTATE_OFF,
                rcoProperties: CKEDITOR.TRISTATE_OFF
            };
		}
	}

	
	CKEDITOR.on('instanceReady', function () {
			
		// nothing to do here
	});
	
	
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

	CKEDITOR.plugins.rcowidget = {
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
            },
            getDefaultIcon: function() {
            	
            	return defaultIcon;
            }
			
	};
	
	/** Defines all features related to drag-driven image resizing. **/
    function setupResizer(cke_widget) {
        var editor = cke_widget.editor,
            editable = editor.editable(),
            doc = editor.document,
            resizer = doc.createElement('span');

        resizer.addClass('cke_image_resizer');
        resizer.setAttribute('title', editor.lang.rcowidget.resizer);
        resizer.append(new CKEDITOR.dom.text('\u200b', doc));

        // Inline widgets don't need a resizer wrapper as an image spans the entire widget.
        if (!cke_widget.inline) {
            var oldResizeWrapper = cke_widget.element.getFirst(),
                resizeWrapper = doc.createElement('span');

            resizeWrapper.addClass('cke_image_resizer_wrapper');
            resizeWrapper.append(cke_widget.parts.image);
            resizeWrapper.append(resizer);
            cke_widget.element.append(resizeWrapper, true);

            // Remove the old wrapper which could came from e.g. pasted HTML
            // and which could be corrupted (e.g. resizer span has been lost).
            if (oldResizeWrapper.is('span'))
                oldResizeWrapper.remove();
        } else
            cke_widget.wrapper.append(resizer);

        // Calculate values of size variables and mouse offsets.
        resizer.on('mousedown', function (evt) {
            var image = cke_widget.parts.image,

                // "factor" can be either 1 or -1. I.e.: For right-aligned images, we need to
                // subtract the difference to get proper width, etc. Without "factor",
                // resizer starts working the opposite way.
                factor = cke_widget.data.align == 'right' ? -1 : 1,

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
                    cke_widget.setData({
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
        cke_widget.on('data', function () {
            resizer[cke_widget.data.align == 'right' ? 'addClass' : 'removeClass']('cke_image_resizer_left');
        });
    }
	

	/**
	 * Method used to generate a UUID for RCO elements
	 */
	function generateUUID() {

		function random() {
			return Math.floor((1 + Math.random()) * 0x10000).toString(16)
					.substring(1);
		}

		return random() + random() + '-' + random() + '-' + random() + '-'
				+ random() + '-' + random() + random() + random();
	}

})();
