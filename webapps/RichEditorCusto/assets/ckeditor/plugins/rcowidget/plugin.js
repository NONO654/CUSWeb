/**
 * @license Copyright (c) Dassault Systems - All rights reserved.
 * Bugs? Please contact Claudien Barbier (T94)
 */
/* global: language */
//'use strict';

(function () {

    // Set a unique ID for the current CKEditor session
    var rcoTimeStamp = timeStamp;
    var pluginPath = '';
    var defaultIcon = null;
    
    // Array containing the RCOs for the current editor
    var aRCOs = null;
    function toDataUrl(url, callback) {
    	var xhr = new XMLHttpRequest();
    	xhr.open('GET', url);
    	xhr.responseType = 'blob';
    	xhr.onload = function() {
    		var reader = new FileReader();
    		reader.onloadend = function() {
    			callback(reader.result);
    		}
    		reader.readAsDataURL(xhr.response);
    	};
    	xhr.send();
    }
    CKEDITOR.plugins
        .add(
            'rcowidget', {
                lang: 'de,en,es,fr,it,ja,zh,zh-cn',
                requires: 'widget,dialog',
                icons: 'rcowidget',
                
                onLoad: function (editor) {
                    CKEDITOR.addCss(".cke_image_resizer{display:none;position:absolute;bottom:2px;width: 0px;height: 0px;border-style:solid;right:2px;border-width:0 0 10px 10px;border-color:transparent transparent #ccc transparent;" + 
                            CKEDITOR.tools.cssVendorPrefix("box-shadow", "1px 1px 0px #777", !0) + ";cursor:se-resize;}.cke_image_resizer_wrapper{position:relative;display:inline-block;line-height:0;}.cke_image_resizer.cke_image_resizer_left{right:auto;left:2px;border-width:10px 0 0 10px;border-color:transparent transparent transparent #ccc;" + CKEDITOR.tools.cssVendorPrefix("box-shadow", "-1px 1px 0px #777", !0) + ";cursor:sw-resize;}.cke_widget_wrapper:hover .cke_image_resizer{display:block;}");
                },
                init: function (editor) {
                    
                    // Global variable for the path
                    pluginPath = this.path;
                    defaultIcon = pluginPath + 'images/defaultIcon.png';
                    toDataUrl(defaultIcon, function(base64Img) {
                    	defaultIcon = base64Img;
                    });
                    // Register the dialog, the button, and the command
                    CKEDITOR.dialog.add('rcowidgetDialog', this.path + 'dialogs/rcowidget.js');
                    editor.ui.addButton('RCOWidget', {
                        label: editor.lang.rcowidget.dropFiles,
                        command: 'dispRCOWidget',
                        toolbar: 'widgets',
                        icon: this.path + 'icons/rcowidget.png'
                    });
                    editor.addCommand('dispRCOWidget',
                        new CKEDITOR.dialogCommand('rcowidgetDialog'));
                    
                    // Creates the RCO
                    var rco = widgetDef(editor);
                    
                    // Register the widget
                    editor.widgets.add('rcowidget', rco);

                    /** 
                     * CONTEXTUAL MENU 
                    **/
                    editor.addMenuGroup('rcoContextualMenu', -1);

                    function isRCOSaved(editor) {
                        // The reference document is not created yet
                        if (editor.widgets.focused.data['isSaved'] == false) {
                            alert(editor.lang.rcowidget.rcoSave);
                            return false;
                        }
                        return true;
                    }
                    
                    // Register the command to checkOut the RCO
/*                    editor.addCommand("rcoCheckOut", {
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
*/
                 // Register the command to download the RCO
                    editor.addCommand("rcoDownload", {
                        exec: function (editor) {
                            if (isRCOSaved(editor))
                                callCheckout(editor.widgets.focused.data["rcoCurrentObjectId"], 'download', editor.widgets.focused.data["rcoFileName"], 'rco' ,'null', 
                                    'null', 'structureBrowser', 'APPDocuemntSummary', '');
                        }
                    });

                    editor.addCommand("rcoUpload", {
                        exec: function (editor) {
                        	editor.widgets.focused.setData('rcoDoubleClick', true);
                            editor.execCommand('dispRCOWidget');

//                        	var dialog = editor.openDialog('rcowidgetDialog', function(){
//                        		//this.selectPage('tap-upload');
//                        	});
//                        	CKEDITOR.dialog.getCurrent().selectPage('tap-upload');
//                        	var dialog = new CKEDITOR.dialog( editor, 'rcowidgetDialog' );
//                        	dialog.show();
//                        	dialog.selectPage('tap-upload');
                        }
                    });

                    // If the "menu" plugin is loaded, register the menu items.
                    if (editor.addMenuItems) {
                        editor.addMenuItems({
                            rcoContextualMenu :
                            {
                              label : editor.lang.rcowidget.cmActions,
                              icon: this.path + '/images/action.png',
                              group : 'rcoContextualMenu',
                              order : 1,
                              getItems : function() {
                                return {
                                    /*rcoCheckOut : CKEDITOR.TRISTATE_OFF,*/
                                    rcoDownload : CKEDITOR.TRISTATE_OFF ,
                                    rcoUpload : CKEDITOR.TRISTATE_OFF
                                };
                              }
                            },
                            
                            // Now add the child items to the group.
                            /*rcoCheckOut :
                            {
                              label : editor.lang.rcowidget.cmCheckOut,
                              icon: this.path + '/images/checkOut.png',
                              group : 'rcoContextualMenu',
                              command : 'rcoCheckOut',
                              order : 11
                            },*/
                            rcoDownload :
                            {
                              label : editor.lang.rcowidget.cmDl,
                              icon: this.path + '/images/download.gif',
                              group : 'rcoContextualMenu',
                              command : 'rcoDownload',
                              order : 12
                            },
                             rcoUpload :
                            {
                              label : editor.lang.rcowidget.cmUpload,
                              icon: this.path + '/images/checkOut.png',
                              group : 'rcoContextualMenu',
                              command : 'rcoUpload',
                              order : 13
                            }, 
                            rcoProperties: {
                                label: editor.lang.rcowidget.cmProperties,
                                icon: this.path + '/images/properties.png',
                                command: 'dispRCOWidget',
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
                    
                   editor.on('paste', function(event) {
                    	// event triggered when an object is pasted on CKEditor window
                    	console.log('CKEDITOR onPaste event 3DSpace', event);
                    	
                    	var ua = window.navigator.userAgent;
                    	
                    	var isEdge = false;
                    	var isIE = false;

                        var msie = ua.indexOf('Trident');
                        if (msie > 0) {
                        	isIE = true;
                        }
                        
                        var edge = ua.indexOf('Edge/');
                        if (edge > 0) {
                        	isEdge = true;
                        }
                    	
                    	var rtf_data = event.data.dataTransfer._.data["text/rtf"];
                    	
                    	var jsonData = JSON.stringify({"ooxml": rtf_data});
						// ++VMA10 ZUD IR-706727-3DEXPERIENCER2019x
						var dataValue = event.data.dataValue;
						var dataValueDIV = document.createElement('div');
                    	dataValueDIV.innerHTML = dataValue;
                    	var arrDiv = dataValueDIV.getElementsByTagName('a')
						// --VMA10 ZUD IR-706727-3DEXPERIENCER2019x
                    	
                    	if(rtf_data != undefined && !isEdge && !isIE){
		                    	$.ajax({
		                            type: 'POST',
		                            url: '../resources/richeditor/res/htmlpreview?format=rtf',
		                            dataType: 'json',
		                            data: jsonData,
		                            contentType: 'application/json',
		                            cache : false,
		                            success: function(html) {
		    			            	 //++VMA10 ZUD added IR-700982-3DEXPERIENCER2019x
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
										//--VMA10 ZUD added IR-700982-3DEXPERIENCER2019x
	
									// ++VMA10 ZUD IR-706727-3DEXPERIENCER2019x
		                           	 if(arrDiv.length> 0)
		                           	 {                    	                	   
		                            	var arrSpansAjax = div.getElementsByTagName('span')
		                            	for(var k=0; k<arrDiv.length ; k++)
		                            	{
		                            		for(var l=0 ; l< arrSpansAjax.length; l++)
		                            		{
		                            			if(arrDiv[k].innerText.trim() === arrSpansAjax[l].innerText.trim())
			                            		{
		                            				arrSpansAjax[l].innerText = ""
			                            			var link = document.createElement('a');
			                                        link.setAttribute("href", arrDiv[k].href);
			                                        link.setAttribute("target", "_blank");
			                                        link.text = arrDiv[k].text;
			                                        arrSpansAjax[l].appendChild(link)
			                            		}	
		                            		}		                            		
		                            	}
		                           	 }
									 // --VMA10 ZUD IR-706727-3DEXPERIENCER2019x
		                            	html.html = div.innerHTML;		                            	
		    			            	editor.insertHtml(html.html);
		                            },
		                	        error: function(status, error){
		                	        	console.log("error");
		    	    					console.log(error);
		                            }
		                        });
		                    	//event.preventDefault ? event.preventDefault() : (event.returnValue = false);
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
            							CKEDITOR.instances[event.editor.name].insertHtml('<img align="left" width="'+width+'" height="'+height+'" src="' + reader.result + '" />');
            						
            					   };  
            	          	   };
            	          	   reader.onerror = function (error) {
            	          	     console.log('Error: ', error);
            	          	   };
							return false; // ++VMA10 ZUD  : IR-715669-3DEXPERIENCER2019x  ::  return false statement took out of image.onload function to prevent ckeditor's image paste also, hence preventing pasting of image 2 times
                      	}   
                      	
                      	var dataTransfer = event.data.dataTransfer.$;
						if(typeof dataTransfer !== "undefined"){
							var	files = dataTransfer.files;
							var	file = files[0];
							if(files.length > 0){
								var extension = file.type.split('/').pop().toLowerCase();
								
								var fileTypes = ['jpg', 'jpeg', 'png'];
								var isImage = fileTypes.indexOf(extension) > -1;
								
								if(dataTransfer !== null && dataTransfer !== undefined 
									&& dataTransfer.files !== null && dataTransfer.files !== undefined
									&& dataTransfer.files.length !== 0 && isImage) {

								   var reader = new FileReader();
								   reader.readAsDataURL(file);
								   reader.onload = function () {
									   var image = new Image();
									   image.src = reader.result;
										   
									   image.onload = function(){
											width = image.width;
											height = image.height;
											CKEDITOR.instances[event.editor.name].insertHtml('<img align="left" width="'+width+'" height="'+height+'" src="' + reader.result + '" />');
											return false;
									   };  
								   };
								   reader.onerror = function (error) {
									 console.log('Error: ', error);
								   };
								}
							}
						}
                      	
                    });
                }
            });

    function syncArrayRCOsWithEditor() {
        
        // Here is the array with all the current RCOs
        var aTmpRCOs = {};
        var aWidgets = $('.rcowidget', $('.cke_wysiwyg_frame').contents());
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
    
    function widgetDef(editor) {
        var template = '<img alt="RCO image" src="" />',
        templateBlock = '<figure data-rcowidget-saved=\'\' title="' + editor.lang.rcowidget.titleDefault + '" class="rcowidget" style="display:inline-block">' +
        template +
        '<figcaption style="background: White;">' + editor.lang.rcowidget.captionDefault + '</figcaption>' +
        '</figure>';

        // If we have already some data
        var oldDataRCO = null;
        var isCJK = false;
        if(window.navigator.userLanguage){ //for IE only
        	var lang = language.split(',')[0];
        	if(lang.indexOf('ja') == 0 || lang.indexOf('zh') == 0 || lang.indexOf('ko') == 0)
        	{
        		isCJK = true;
        	}
        	
        }
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
            editables: isCJK ? {} : {
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
                var widget = this,
                    editor = widget.editor,
                    editable = editor.editable();
            },
            init: function () {
                
                for (var entry in CKEDITOR.instances) break;
                var editor = CKEDITOR.instances[entry];

                var editorSerialId = editor.name.substring("CKEDITOR_".length);

                //var rcoSerialId = rcoTimeStamp + '_' + this.id;
               
                var rcoSerialId = UWA.Utils.getUUID();
                var currentObjectId = jQuery('#objectInfo_' + editorSerialId).children('#objectID').html();
                
                // We are inside a form
                if (rcoTimeStamp == undefined || currentObjectId == undefined) {
                	var infos = jQuery('#loadingGifFormRMT').attr('load').split(',');
                	rcoTimeStamp = infos[3].replace(/"/g, '');
                	//rcoSerialId =  rcoTimeStamp + '_' + this.id;

                	rcoSerialId = UWA.Utils.getUUID();
                	
                	currentObjectId = infos[1].replace(/"/g, '').slice(1);
                }

                // restore existing data
            	var existingData = this.element.getAttribute('data-rcowidget-saved');
            	if(existingData){
            		if(existingData.indexOf("|")) {
            			this.data = JSON.parse(existingData.replace(/\|/g, '"'));
            		}
            		else {
                		this.data = JSON.parse(existingData.replace(/'/g, '"'));
            		}
            		
            		this.data['rcoCurrentObjectId'] = currentObjectId;
            		
                    this.on('doubleclick', function() {
                        this.setData('rcoDoubleClick', true);
                        CKEDITOR.currentInstance.execCommand('dispRCOWidget');
                    });
            		return false;
            	}
                this.on('doubleclick', function() {
                    CKEDITOR.currentInstance.execCommand('dispRCOWidget');
                });
                
                // We can set the loading gif
                var image = this.parts.image;
                if (image != undefined)
                    image.src = pluginPath + 'images/loading.gif';

                this.setData('rcoSerialId', rcoSerialId);
                this.setData('rcoCurrentObjectId', currentObjectId);
                
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

        if (element.find(".rcowidget").$.length != 0) {
            return {
                rcoContextualMenu: CKEDITOR.TRISTATE_OFF,
                rcoProperties: CKEDITOR.TRISTATE_OFF
            };
        }
    }

    CKEDITOR.on('dialogDefinition', function(ev) {
        var dialogName = ev.data.name;
        var dialogDefinition = ev.data.definition;
        
        if (dialogName == 'rcowidgetDialog') {

            var oldOnShow = dialogDefinition.onShow;
            dialogDefinition.onShow = function () {
                
                for (var entry in CKEDITOR.instances) break;
                var editor = CKEDITOR.instances[entry];
                
                var widget = editor.widgets.focused; 
                
                oldOnShow.apply(this, null);
                
                if (widget.data['rcoDoubleClick'] == true) {
                    widget.setData('rcoDoubleClick', false);
                    // This code will open the Upload tab.
                    this.selectPage('tap-upload');
                }
            };
            ev.data.definition.resizable = CKEDITOR.DIALOG_RESIZE_NONE;
        }
    });
    
    CKEDITOR.on('instanceReady', function () {
        for (var entry in CKEDITOR.instances) break;
        var editor = CKEDITOR.instances[entry];

        var head = document.getElementsByTagName('head')[0];

        // Adding the dropzone css
        var csslink = document.createElement('link');
        csslink.id = 'dropZone';
        csslink.rel = 'stylesheet';
        csslink.type = 'text/css';
        csslink.href = '../webapps/RichEditorCusto/assets/ckeditor/dropZone/css/dropzone.css';
        csslink.media = 'all';
        head.appendChild(csslink);

        // Adding the css that will insert the dropzone in CKEditor
        var csslink2 = document.createElement('link');
        csslink2.id = 'dropZoneContainer';
        csslink2.rel = 'stylesheet';
        csslink2.type = 'text/css';
        csslink2.href = CKEDITOR.plugins.getFilePath('rcowidget').substring(0, CKEDITOR.plugins.getFilePath('rcowidget').lastIndexOf('/') + 1) + 'styles/dropzoneContainer.css';
        csslink2.media = 'all';
        head.appendChild(csslink2);

        $.getScript("../webapps/RichEditorCusto/assets/ckeditor/dropZone/dropzone.js")
            .done(function (script, textStatus) {
                if ($('.cke_button__rcowidget').length == 0)
                    return;
                
                var urlToUpload = serverURLWithRoot + '/resources/richeditor/res/upload?'; // + csrfParams;
                var dropzone = new Dropzone('.cke_button__rcowidget', {
                    url: urlToUpload,
                    maxFilesize: 150, // in MB
                    uploadMultiple: false,
                    clickable: false
                });
                
                // Disable the button for CKEditor - no click available
                $('.cke_button__rcowidget').removeAttr('onclick').removeAttr('onkeydown').removeAttr('onfocus').removeAttr('onmousedown')
                    .removeAttr('onmouseup').removeAttr('href').unbind('click').removeClass('cke_button_off');
                
                $('.cke_button__rcowidget').get(0).onclick = function() {return false;};
                
                var labelRCO = $(".cke_button__rcowidget_label");
                var originalLabelRCO = labelRCO.text();
                var progressbar = null,
                    progressLabel = null;

                dropzone.on('addedfile', function(file){
                	var aWidgets = $('.rcowidget', $('.cke_wysiwyg_frame').contents());
					for (var i = 0; i < aWidgets.length; i++) {
							var rcoData = JSON.parse(decodeURIComponent(aWidgets.get(i).getAttribute('data-cke-widget-data')));
							if(rcoData.rcoFileName == file.name) {
								dropzone.removeFile(file);
								alert(editor.lang.rcowidget.rcoDuplicate);
							}
					}
                });
                dropzone.on('processing', function (file) {
                    labelRCO.text('');
                    $('.cke_button__rcowidget_label').append('<div id="progressBarRCO" style="display:inline-block; width:80px; height:15px"><div class="progress-label"></div></div>');
                    progressbar = $("#progressBarRCO");
                    progressLabel = $(".progress-label");

                    $('.dz-preview').hide();

                    progressbar.progressbar({
                        value: 0,
                        change: function () {
                            progressLabel.text(Math.round(progressbar.progressbar('value')) + '%');
                        },
                        complete: function () {
                            progressLabel.text(editor.lang.rcowidget.uploadDone);
                            setTimeout(function () {
                                labelRCO.fadeOut(TIMEOUT_VALUE * 20, function () {
                                    $(this).text(originalLabelRCO).fadeIn(TIMEOUT_VALUE * 10);
                                });
                            }, TIMEOUT_VALUE * 10);
                        }
                    });

                    progressbar.css({
                        'background': 'White'
                    });
                    $("#progressBarRCO > div").not(".progress-label").css({
                        'background': 'LightGreen'
                    });
                });

                dropzone.on('uploadprogress', function (file, progress) {
                    progressbar.progressbar("value", progress);
                });

                dropzone.on('success', function (file, serverResponse) {
                	editor.focus();
                    var element = editor.getSelection().getSelectedElement();
                    if(element) { //do not replace currently selected widget
                    	var range = editor.createRange();
                    	var nextElement = element.getNext();

						range.setStartAfter(element);
						range.setEndBefore(nextElement);
						
                    	editor.getSelection().selectRanges( [ range ] );
                    }
                    editor.execCommand('rcowidget');

                    // To separate the path from the preview
                    var _DELIMITER = '\7';
                    var data = serverResponse.path.split(_DELIMITER),
                    filePath = data[0], preview = data[1];

                    // Set the preview
                    var widget = editor.widgets.focused; 
                    
                    var imgPreview = $(file.previewElement).find('.dz-details').find('img');
                    
                    // If there is an issue with the preview, we put the default icon
                    if (imgPreview.attr('src') == undefined) {
                    	var imagePath = '';
                    	
                    	if (preview == undefined) {
                    		imagePath = defaultIcon; //pluginPath + 'images/defaultIcon.png';
                    	} else {
                    		imagePath = 'data:image/jpeg;base64,' + preview;
                    	}
                    	
                        imgPreview = $('<img width="200" height="200" alt="RCO image" class="preview-image-rco" src="' + imagePath + '" />');
                    }
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
                    widget.setData('rcoPathTempFile', filePath);

                    widget.element.$.attributes['title'].textContent = editor.lang.rcowidget.titleFileName + ': ' + file.name + '\n' + 
                        editor.lang.rcowidget.titleMIME + ': ' + file.type + '\n' + 
                        editor.lang.rcowidget.titleModified + ': ' + file.lastModifiedDate;

                    //editor.widgets.checkWidgets();
                    //widget.fixIME();
                    
                    // We save this widget in the session storage
                    addDataToSessionStorage(widget.data['rcoSerialId'], widget.data);
                    widget.setData('rcoPathTempFile', undefined);
                    widget.setData('rcoCurrentObjectId', undefined);
                });
            }).fail(function(jqxhr, settings, exception) {
                console.log('DropZone failed to load.');
            });
    });
    
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
            }
    };

    /** Defines all features related to drag-driven image resizing. **/
    function setupResizer(widget) {
        var editor = widget.editor,
            editable = editor.editable(),
            doc = editor.document,
            resizer = doc.createElement('span');

        resizer.addClass('cke_image_resizer');
        resizer.setAttribute('title', editor.lang.rcowidget.resizer);
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
