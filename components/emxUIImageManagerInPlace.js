/* js dependency: define, jQuery, emxUIConstants, emxNavigatorHelp.js, getTopWindow, ../plugins/libs/jqueryui/1.10.3/css/jquery-ui.js, UIKIT.js, ../plugins/hammer/jquery.hammer
 * additional js dependency for 3DLiveExamine: emxUIImageManager.js, ENOVIA3DLiveExamine.js, ENOVIA3DLiveExamineExtension.js
 * 
 * css dependency: UIKIT.css, emxUIImageManagerInPlace.css, ../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css
 */

define(
	    [
	        // UWA
	        'UWA/Core',
	        'UWA/Element',
	        'UWA/Event',
	        'UWA/Utils/Client',
	        'UWA/Controls/Abstract',
	        'UWA/Utils/InterCom',

	        // UIKIT
	        'DS/UIKIT/Modal',
	        'DS/UIKIT/Alert',
	        'DS/UIKIT/Input/Button',
	        'DS/UIKIT/Carousel',
	        
	        '../plugins/hammer/jquery.hammer'

	    ],

	function (UWA, Element, Event, Client, Abstract, InterCom, Modal, Alert, Button, Carousel, Hammer) {
	    'use strict';
	    
	    var WRAPPER_ID = 'img-viewer-wrapper', WRAPPER_SELECTOR = '#' + WRAPPER_ID;
	    var manager = {
	    		objectId: null,
	    		imageCollection: null,
	    		hasModifyAccess: null,
	    		socket: null,

	    		primaryIndicator: null,
	    		carousel: null,
	    		dialogElement: null,
	    		displayAlert: function(msg){
	    			new Alert({
	    			    visible: true,
	    			    autoHide: true,
	    			    messages: [
	    			        { message: msg, className: "error" },
	    			    ]
	    			}).inject(getTopWindow().document.body);							
	    		},
	    		renderPrimaryIndicator: function() {
	    			var index = this.getCurrentImageIndex();
	    			if(index == -1){
	    				return;
	    			}
	    			if(this.imageCollection[index].isPrimary) {
	    				this.primaryIndicator.show();
	    			}
	    			else{
	    				this.primaryIndicator.hide();
	    			}
	    		},
	    		getPrimaryImageIndex: function(){
	    			var primaryIndex = -1;
	    			jQuery.each(this.imageCollection, function(index, imageData){
	    				if(imageData.isPrimary) {
	    					primaryIndex = index;
	    					return false;
	    				}
	    			});
	    			return primaryIndex;
	    		},
	    		setPrimaryImageIndex: function(index){
	    			jQuery.each(this.imageCollection, function(i, imageData){
	    				imageData.isPrimary = (i == index);
	    			});
	    			this.dispatchEvent('primaryImageChanged');
	    		},
	    		onPrimaryImageChanged: function(){
	    			var that = this;
	    			that.renderPrimaryIndicator();
	    			that.socket.dispatchEvent('objectChanged', {
	    				oid: that.objectId
	    			});
	    		},
	    		getImageIndex: function(fileName){
	    			var index = -1;
	    			jQuery.each(this.imageCollection, function(i, imageData){
	    				if(imageData.fileName == fileName) {
	    					index = i;
	    					return false;
	    				}
	    			});
	    			return index;
	    		},
	    		getCurrentImageIndex: function(){
	    			var that = this;
	    			if(that.imageCollection.length == 0) {
	    				return -1;
	    			}
	    			return that.carousel.slides.indexOf(that.carousel.current);
	    		},
	    		goToImage: function(index){
	    			var that = this;
	    			if(that.imageCollection.length == 0) {
	    				return;
	    			}
	    			if(index == -1){
	    				index = that.getPrimaryImageIndex();
	    			}
		            that.carousel.current.removeClassName('active');
		            that.carousel.setActive(index);
		            that.dispatchEvent('currentImageChanged');
	    		},

	    		onCurrentImageChanged: function(){
	    			var that = this;
					that.renderPrimaryIndicator();
					
					//code for 3DLiveExamine
					jQuery("#divImage", WRAPPER_SELECTOR).remove();
					jQuery(".carousel-control", WRAPPER_SELECTOR).css("width", ""); 
    				var index = that.getCurrentImageIndex(); 
    				
    				if(index == -1){
    					return;
    				}
    				var ext = that.imageCollection[index].fileExtn.toLowerCase();
    				
    				if(that.imageCollection[index].show3dImage || ext=="svg" || ext == "swf" || ext == "3dxml" || ext == "cgr"){
    					var image = jQuery("img", WRAPPER_SELECTOR).eq(index).hide().parent().append('<div id="divImage" style="margin-left:15px;margin-right:15px;height:400px">' + 
    							'</div>');
    					changeBGImage(index, that.imageCollection);
						jQuery(".carousel-control", WRAPPER_SELECTOR).css("width", "15px"); 
    				}
	    		},
	    		
	    		getImageCollection: function(initialImage){
	    			var that = this;
				    jQuery.ajax({
				    	dataType: "json",
		    	        cache: false,
				    	url: "../components/emxImageManagerJSON.jsp?objectId=" + that.objectId
				    })
				    .done(function(fullImageData){
			    		if(fullImageData.action != "success" && result.message){ 
			    			that.displayAlert(result.message);
			    			return;
			    		}
				    	that.imageCollection = fullImageData.images;
				    	that.hasModifyAccess = fullImageData.hasModifyAccess;
				    	that.dispatchEvent('imageCollectionChanged', initialImage);
					    jQuery('button.checkinImage', that.dialogElement).prop("disabled", !that.hasModifyAccess);
					    jQuery('button.deleteImage', that.dialogElement).prop("disabled", !that.hasModifyAccess);
					    jQuery('button.primaryImage', that.dialogElement).prop("disabled", !that.hasModifyAccess);
				    })
				    .fail(function(jqXHR, textStatus, errorThrown){
				    	that.displayAlert(textStatus + ": " + errorThrown);
				    });							            
	    		},
	    		
	    		onImageCollectionChanged: function(initialImage){
	    			var that = this;
	    			if(that.imageCollection.length == 0) {
	    				jQuery('.blank-msg', that.dialogElement).show();
	    				jQuery('.carousel', that.dialogElement).hide();
	    			}
	    			else{
	    				jQuery('.blank-msg', that.dialogElement).hide();
	    				jQuery('.carousel', that.dialogElement).show();
	    			}
	    			
	    			that.carousel.remove(Array.apply(null, {length: that.carousel.slides.length}).map(function(value, index, array){return array.length - index - 1;})); //remove all current slides
	    			
			    	var imageHTML = '';
			    	jQuery.each(that.imageCollection, function(index, imageData){
			    		if(imageData.show3dImage){
			    			imageHTML += imageData.imageIcon3d;
			    		}
			    		else{
			    			imageHTML += '<img id="Image' + index + '" src="' + imageData.imageURL + '"/>';
			    		}
			    	});
			    	var slides = Element.getElement.call(document, ".carousel-slides");
			    	slides.setContent(imageHTML);
			    	
			    	that.carousel.add(that.carousel.getSlides());
			    	
			    	if(that.imageCollection.length > 0){
			    		if(initialImage == undefined) {
			    			initialImage = that.getPrimaryImageIndex();
			    		}
			    		
			    		if(initialImage == -1){
			    			initialImage = 0;
			    		}
			    		
			    		if(jQuery.type(initialImage) === "string") { //must be a file name
			    			that.goToImage(that.getImageIndex(initialImage));
			    		}else{
					    	that.goToImage(initialImage <  that.imageCollection.length - 1 ? initialImage : that.imageCollection.length - 1);
			    		}
			    	}
	    			
	    		},
	    		
	    		onCommandSelectPrimaryImage: function(){
	    			var that = this;
			    	var index = that.getCurrentImageIndex();
			    	
			    	if(index == -1 || index == that.getPrimaryImageIndex()) {
			    		return;
			    	}
			    	var emxTableRowId = that.imageCollection[index].checkBoxValue;
			    	var csrf = getSecureTokenJSON();
			    	
			    	jQuery.ajax({
				    	dataType: "json",
		    	        cache: false,
			    		url: "../components/emxImageManagerSetPrimaryImage.jsp?&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=" + that.objectId + "&emxTableRowId=" + emxTableRowId,
			    		data: csrf
			    	})
			    	.done(function(result){
			    		if(result.action != "success" && result.message){
			    			that.displayAlert(result.message);
			    		}
			    		else{
			    			that.setPrimaryImageIndex(index);
			    		}
			    	})
				    .fail(function(jqXHR, textStatus, errorThrown){
				    	that.displayAlert(textStatus + ": " + errorThrown);
				    });							            
	    		},
	    		
	    		onCommandDeleteImage: function(){
	    			var that = this;
			    	var index = that.getCurrentImageIndex();
			    	if(index == -1) {
			    		return;
			    	}
			    	var emxTableRowId = that.imageCollection[index].checkBoxValue;
			    	var csrf = getSecureTokenJSON();
			    	
			    	jQuery.ajax({
				    	dataType: "json",
		    	        cache: false,
			    		url: "../components/emxImageManagerDeleteImage.jsp?&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=" + that.objectId + "&emxTableRowId=" + emxTableRowId,
			    		data: csrf
			    	})
			    	.done(function(result){
			    		if(result.action != "success" && result.message){
			    			that.displayAlert(result.message);
			    		}
			    		else{
				    		if(index == that.getPrimaryImageIndex()){
				    			that.socket.dispatchEvent('objectChanged', {
				    				oid: that.objectId
				    			});
				    		}
			    			that.getImageCollection(index); //refresh whole collection in case primary image is deleted
			    		}
			    	})
				    .fail(function(jqXHR, textStatus, errorThrown){
				    	that.displayAlert(textStatus + ": " + errorThrown);
				    });							            
	    		},
	    		
	    		validateFiles: function (files){
		    		if(!files || files.length == 0) {
		    			return false;
		    		}
		    		
		    		for (var i = 0, f; f = files[i]; i++) {
		    			var filename 		= f.name;
		    			var fileSuffix 		= filename.split('.').pop();
		    			if(emxUIConstants.IMAGE_ALLOWED_FORMATS.indexOf(fileSuffix) == -1) {
		    				return false;
		    			}
		    		}
		    		return true;
	    		},
	    		
	    		isPayloadFile: function(dataTransfer){
	    			return jQuery.inArray("Files", dataTransfer.types) != -1;
	    		},

	    		init: function (objectId) {
	    			var that = this;
	    			that.objectId = objectId;
	    			that.addEvent('primaryImageChanged', that.onPrimaryImageChanged.bind(that));
	    			that.addEvent('currentImageChanged', that.onCurrentImageChanged.bind(that));
	    			that.addEvent('imageCollectionChanged', that.onImageCollectionChanged.bind(that));
			    	that.addEvent('command:selectPrimaryImage', that.onCommandSelectPrimaryImage.bind(that));
			    	that.addEvent('command:deleteImage', that.onCommandDeleteImage.bind(that));
			    	that.socket = new InterCom.Socket(); 
			    	that.socket.subscribeServer('enovia.bus.server', getTopWindow());   
	    			
			    	var dialogContainer = typeof emxEditableTable == "undefined" && document.getElementById("pageContentDiv");
				    var dialog = new Modal({
				        closable: true,
				        header: 
				        	 '<button type="button" class="btn-xs imgtoolbar checkinImage" title="' + emxUIConstants.IMAGE_COMMAND_DNDUPLOAD + '"><img src="../common/images/iconActionAppend.png" /></button>' + 
						'<button type="button" class="btn-xs imgtoolbar deleteImage" title="' + emxUIConstants.IMAGE_COMMAND_DELETE + '"><img src="../common/images/iconActionDelete.png" /></button>' + 
						'<button type="button" class="btn-xs imgtoolbar primaryImage" title="' + emxUIConstants.IMAGE_COMMAND_SETASPRIMARY + '"><img src="../common/images/iconSmallPrimaryImage.png" /><img class="primary-indicator" src="../common/images/iconSmallPrimaryImage.gif" /></button>' + 
						'<button type="button" class="btn-xs imgtoolbar helpImage" title="' + emxUIConstants.IMAGE_COMMAND_HELP + '"><img src="../common/images/iconActionHelp.png" /></button>', 
				        body:   '<div class="img-viewer-outer"><div class="img-viewer-inner" ><div id="img-viewer-wrapper" ><div class="blank-msg">' + emxUIConstants.IMAGE_NO_IMAGE_ASSOC + '</div></div></div></div>', 
				    }).inject(dialogContainer ? dialogContainer : document.body);
				    
				    that.dialogElement = dialog.getContent();
				    
				    jQuery('button.checkinImage', that.dialogElement)
				    .on({
				    	drop: function(e){
				    		jQuery(this).trigger("dragleave");
				    		if(!e.originalEvent.dataTransfer) {
				    			return;
				    		}
				    		var files = e.originalEvent.dataTransfer.files;
				    		
				    		if(!that.validateFiles(files)){
				    			that.displayAlert(emxUIConstants.INVALID_IMAGE_EXTENSION_MESSAGE + emxUIConstants.IMAGE_ALLOWED_FORMATS);
				    			return;
				    		}
				    		
				    		jQuery(e.originalEvent.target).addClass("inprogress");
				    		setTimeout(function(){
					    		var formData = new FormData();
					    		/* 
					    		//this breaks the upload
					    		var csrf = getSecureTokenJSON();
					    		for (var key in csrf) {
					    			if (csrf.hasOwnProperty(key)) {
					    				formData.append(key, csrf[key]);
					    			}
					    		} */
					    		jQuery.each(files, function(k, file) {
					    			formData.append('file_'+k, file);
					    		});
					    	    jQuery.ajax({
					    	        url: '../common/emxExtendedPageHeaderFileUploadImage.jsp?objectId=' + that.objectId,
					    	        type: 'POST',
					    	        data: formData,
					    	        cache: false,
					    	        contentType: false,
					    	        processData: false,
					    	    })
					    	    .done(function (data) {
				    	        	if(data.trim().match("^ERROR")){
								    	that.displayAlert(data.trim().substr(5));
				    	        	}
						    		if(that.getPrimaryImageIndex() == -1){ //first image checked in
						    			that.socket.dispatchEvent('objectChanged', {
						    				oid: that.objectId
						    			});
						    		}
				    	        	that.getImageCollection(files[0].name);
				    	        })
				    	        .fail(function (jqXHR, textStatus, errorThrown) {
							    	that.displayAlert(textStatus + ": " + errorThrown);
				    	        })
				    	        .always(function(){
				    	        	jQuery(e.originalEvent.target).removeClass("inprogress");
					    	    });
				    		}, 0);
				    	},
				    	dragover: function(e){
				    		e.preventDefault();
				            e.stopPropagation();
				            
				    		if(!e.originalEvent.dataTransfer) {
				    			return;
				    		}

				    		if(that.isPayloadFile(e.originalEvent.dataTransfer))
				    		{
					            jQuery(e.target).addClass("droptarget");
				    		}
				    		else{
				    			jQuery(e.target).addClass("droperror");
				    		}
				    	},
				    	dragleave: function(e){
				    		e.preventDefault();
				            e.stopPropagation();
				            jQuery(e.target).removeClass("droptarget");
				            jQuery(e.target).removeClass("droperror");
				    	}
				    });
				    
				    jQuery('button.deleteImage', that.dialogElement)
				    .on("click", function(){
				    	that.dispatchEvent('command:deleteImage');
				    });
				    
				    jQuery('button.primaryImage', that.dialogElement)
				    .on("click", function(event){
				    	event.preventDefault();
				    	that.dispatchEvent('command:selectPrimaryImage');
				    });
				    
				    jQuery('button.helpImage', that.dialogElement).on("click", function(){
				    	openHelp("emxhelpimagesview", "component", emxUIConstants.STR_HELP_LANGUAGE, emxUIConstants.STR_HELP_ONLINE_LANGUAGE,'', "Components");
				    });

				    that.dialogElement.getElements("button.close").forEach(function (element) {
				        element.addEvent("click", function () {
				        	dialog.hide();
				        	dialog.destroy();
				        });
				    });
				    
				    var isSouth;
				    function getOriginalEvent(event){
				    	while(event.originalEvent && event.originalEvent.target) {
				    		event = event.originalEvent;
				    	}
				    	return event;
				    }
				    jQuery(".modal-content", that.dialogElement).resizable({
				    	handles: "e, s, se, w, sw",
						aspectRatio: true,
						start: function( event ) {
							isSouth = jQuery(getOriginalEvent(event).target).hasClass("ui-resizable-s");
						},
				    	resize: function( event, ui ) {
				    	    ui.element.width("").height("").css("left", ""); //override default resizing logic
				    	    if(isSouth){
				    	    	var ratio = jQuery('.img-viewer-outer', that.dialogElement).width()/jQuery('.img-viewer-outer', that.dialogElement).height();
				    	    	ui.element.parent().width(ui.originalSize.width + (ui.size.height - ui.originalSize.height) * ratio);
				    	    }
				    	    else {
				    	    	ui.element.parent().width(ui.originalSize.width + 2 * (ui.size.width - ui.originalSize.width));
				    	    }
				    	}
				    });
				    
				    jQuery(that.dialogElement).addClass('img-viewer'); //css customization
				    jQuery("DIV.modal-wrap", that.dialogElement).addClass('img-viewer'); //css customization
				    
				    dialog.show();
				    
				    jQuery('DIV.modal-overlay').addClass("img-viewer");

				    that.primaryIndicator = jQuery(".primary-indicator", that.dialogElement);
				    
				    var wrapper = Element.getElement.call(document, WRAPPER_SELECTOR);
				    var slides = UWA.createElement('div').inject(wrapper);
		                       
		            that.carousel = new Carousel({ 
		            		autoPlay: false,
		            		slides: slides, 
		            		slideSelector: '>img',
		            		events: {
		            			onSlide: function(){ 
		            					that.dispatchEvent('currentImageChanged');
		            				},
		            		}
		            });
				    jQuery('.img-viewer-inner', that.dialogElement).hammer({preventDefault: true})
				    .on("swipeleft", function(event){
				    	that.carousel.slide('right');
				    }).on("swiperight", function(event){
				    	that.carousel.slide('left');				    
				    });
		            
		            jQuery(".carousel-control", WRAPPER_SELECTOR).on('click', function(){
		            	//code for 3DLiveExamine: hide 3d container right after each click
		            	jQuery("#divImage", WRAPPER_SELECTOR).css("visibility", "hidden");
		            });
		            
		            that.getImageCollection();
	    		} //init
	    };
	    var ImageMananger = Abstract.extend(manager);
	    return ImageMananger;
	} //function
); //define      				
