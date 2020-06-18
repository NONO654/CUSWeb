define('DS/ENOXDocumentPresenter/js/util/DocumentCreateForm',
		['DS/UIKIT/Input/Text',
		 'DS/UIKIT/Input/Select',
		 'DS/UIKIT/Input/File',
		 'UWA/Core',
		 'DS/UIKIT/Form',
		 'DS/UIKIT/Input/Button',
		 'DS/UIKIT/Modal',
		 'DS/ENOXDocumentPresenter/js/DocumentPresenter',
	 	 'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
		 'DS/ResizeSensor/js/ResizeSensor',
		 'i18n!DS/ENOXDocumentPresenter/assets/nls/DocumentsPresenter'
		 ],
		function (Text, Select, File, Core, Form, Button, Modal, DocumentPresenter, xNotificationsUtil, ResizeSensor, DOC_NLS) {

		    'use strict';
	var DocumentCreateForm =  {
			DOCCreateModal: undefined,
			severityButtonGroup: null,
			currentModelObjectForRefresh : undefined,
			createOrEditFlag: true,
			DOCFormFile : [],
			pushFormContentOnHide : function() {
				document.documentElement.getElement('.documentmodal').parentNode.removeChild(document.documentElement.getElement('.documentmodal'));
				if (DocumentCreateForm.DOCFormFile.length>0){
						//DocumentCreateForm.DOCFormFile.clear();
						while (DocumentCreateForm.DOCFormFile.length > 0) {
							DocumentCreateForm.DOCFormFile.pop();
						}
					}
      },
			attachResizeSensor: function (container) {
				 var that = this;
				 that.resizeSensor = new ResizeSensor(container, function () {
						 that.resize(container);
				 });
			 },

			 resize: function (container) {
				 var that = this;
					 var width = container.offsetWidth;
					 if (width < 868) {
						 		that.resizeForSmallWindow();
					 } else {
						 		that.resizeForNormalWindow();
					 }
			 },
			 resizeForSmallWindow : function(){
				 if (document.documentElement.getElement('.div-file')!=null){
				 		document.documentElement.getElement('.div-file').style.display='inline-table';
					}
					 if (document.documentElement.getElement('.documentmodal .modal-content .modal-footer')!=null){
						 document.documentElement.getElement('.documentmodal .modal-content .modal-footer').style['text-align'] = 'left';
						 // document.documentElement.getElement('.documentmodal .modal-content #headermand').style['margin-left'] = '10px';
					 }
					 if (document.documentElement.getElement('#containerid') != null){
							for (var i = 1; i <= document.documentElement.getElement('#containerid').childNodes.length; i++) {
								 if (document.documentElement.getElement('#containerid').childNodes[i] != undefined){
											document.documentElement.getElement('#containerid').childNodes[i].getElement('.div-file').style.display = 'inline-table';
										}
							}
				}
				if (document.documentElement.getElement('.documentmodal .modal-content') !=null){
						document.documentElement.getElement('.documentmodal .modal-content').style.width = '250px';
				}
			 },
			 resizeForNormalWindow : function(){
				 if (document.documentElement.getElement('.div-file')!=null){
				 		document.documentElement.getElement('.div-file').style.display='flex';
			 		}
					if (document.documentElement.getElement('.documentmodal .modal-content .modal-footer')!=null){
				 			document.documentElement.getElement('.modal-content .modal-footer').style['text-align'] = 'right';
							// document.documentElement.getElement('.modal-content #headermand').style['margin-left'] = '500px';
			 		}
					if (document.documentElement.getElement('#containerid') != null && document.documentElement.getElement('#containerid').childNodes != null){
						 for (var i = 1; i <= document.documentElement.getElement('#containerid').childNodes.length; i++) {
							 if (document.documentElement.getElement('#containerid').childNodes[i] != undefined){
										document.documentElement.getElement('#containerid').childNodes[i].getElement('.div-file').style.display = 'flex';
									}
						 }
			 }
			 if (document.documentElement.getElement('.documentmodal .modal-content') !=null && document.documentElement.getElement('.documentmodal .modal-content') != undefined){
				 			document.documentElement.getElement('.documentmodal .modal-content').style.width = '784px';
						}
			 },
            createBody: function(files) {
								var rowLength = 1;

                var el = UWA.createElement('div', {
												'class': 'container',
												id : 'containerid',
				                 html: [
													 {
                	    	        	  tag: 'div',
																		'class': 'row',
										  							 html: {
																						tag: 'div',
																						html: [
																							{
																								tag: 'div',
																								'class': 'col-md-2',
																								html: [
																									{
																											tag: 'span',
																											html: DOC_NLS.DOC_Create_Document_Title
																									}
																								]
																						}, {
					                	    	              tag: 'div',
					                	    	              'class': 'col-md-2',
					                	    	              html: [
																									{
																											tag: 'span',
																											html:DOC_NLS.DOC_Create_Document_Type
																											//'class': 'mand-asterisk fonticon fonticon-asterisk-alt'
																									}
					                	    	              ]
					                	    	          },
																						{
																								tag: 'div',
																								'class': 'col-md-2',
																								html: [
																												{
																														tag: 'span',
																														html:DOC_NLS.DOC_Create_Document_File
																												}
																								]
																							}

																						]
																		}
                	    	          },
																	{
			                 	    	        	  tag: 'div',
			 																		'class': 'row',
			 										  							 html: {
			 																						tag: 'div',
			 																						html: [
			 																									{
			 																											 tag: 'div',
			 																											 html: UWA.createElement(
			 																														 'div', {
																																		 id:'TitleDivField'+rowLength,
			 																															 'class': 'col-md-2',
			 																															 html: DocumentCreateForm.createTextField(rowLength)
			 																														 })
			 																									}, {
			 																											 tag: 'div',
			 																											 html: UWA.createElement(
			 																														 'div', {
																																		 id:'TypeDivField'+rowLength,
			 																															 'class': 'col-md-2',
			 																															 html: DocumentCreateForm.createSelectField(rowLength)
			 																														 })
			 																									},
			 																									{
			 																											 tag: 'div',
			 																											 html: UWA.createElement(
			 																														 'div', {
																																		 id:'FileDivField'+rowLength,
			 																															 'class': 'col-md-4',
			 																															 html: DocumentCreateForm.createFileField(rowLength, files)
			 																														 })
			 																									}

			 																						]
			 																		}
			                 	    	          }
														]
                });
                return el;
            },
            createTextField: function(rowLength){
                var mandText = new Text({
                    id: 'Title'+rowLength,
                    name: 'Title'+rowLength,
                    value: '',
                    multiline: false,
                    rows: 1,
                    required: false
                });
                return mandText;
            },
						createSelectField: function(rowLength){
							var optionsArray = [];
							var docTypeText = [];
							docTypeText = this.docTypeTexts.split(',');
							for (var i = 0; i < docTypeText.length; i++) {
								if (i==0){
								optionsArray.push({ 'value' : docTypeText[i], 'selected' : true});
							}
							else {
								optionsArray.push({ 'value' : docTypeText[i]});
							}
							}

							var mandSelect =  new Select({
									name: 'Type',
									id: 'Type'+rowLength,
									custom: true,
									options: optionsArray,
                                    placeholder: false
							});
							mandSelect.elements.input.onchange = function () {
									var strType = DocumentCreateForm.formFieldContent.getValue('Type');
									if (strType != '') {
											DocumentCreateForm.doneBtn.elements.input.disabled = false;
											DocumentCreateForm.doneBtn.elements.input.removeClassName('disabled');
									}
									else {
											DocumentCreateForm.doneBtn.elements.input.disabled = true;
											DocumentCreateForm.doneBtn.elements.input.addClassName('disabled');
									}
							};
							return mandSelect;
						},
						createFileField: function(rowLength, fileObj){
							var that =this;
							var mandFile = '';
							var fileDiv = '';
							if (document.documentElement.getElement('.modal-content .modal-footer').style['text-align'] == '' ||
								document.documentElement.getElement('.modal-content .modal-footer').style['text-align'] == 'right'){
									fileDiv = new UWA.createElement('div', {
                								'class': 'div-file',
																id: 'fileDiv'+rowLength,
																styles :{
																	display:'flex',
																	width:'315px'
																}
            									});
									document.documentElement.getElement('.modal-content .modal-footer').style['text-align'] = 'right';
								}
								else {
									fileDiv = new UWA.createElement('div', {
                								'class': 'div-file',
																id: 'fileDiv'+rowLength,
																styles :{
																	display:'inline-table',
																	width:'315px'
																}
            									});
								document.documentElement.getElement('.modal-content .modal-footer').style['text-align'] = 'left';
								}
									var text_input = UWA.createElement('input', {
										'class':'form-control form-control-root'
									});
									text_input.id = 'FileText'+rowLength;
									text_input.type = 'text';
									text_input.file = '';
									text_input.setAttribute('placeholder', DOC_NLS.DOC_Select_A_File);
						            text_input.readOnly = true;
									text_input.addEventListener('click', function () { that.uploadFile(rowLength); }, false);
									//var button_input = document.createElement('input');
									//		button_input.addEventListener('click', function () { that.uploadFile(rowLength);}, false);
									//		button_input.type = 'button';
									//		button_input.class = 'col-md-2';
									//		button_input.id = 'File'+rowLength;
									//		button_input.value = DOC_NLS.DOC_Browse;

									var button_input = new Button({
									    value: DOC_NLS.DOC_Browse,
									    events: {
									        onClick: function () {
									            that.uploadFile(rowLength);
									        }
									    },
											id: 'File'+rowLength
									});
									button_input.getContent().setStyle('min-width', '80px');
									button_input.getContent().setStyle('margin-left', '10px');

											var varButton = new Button({icon : 'fonticon fonticon-minus', className: 'default', id :'removeButton'+rowLength});
											varButton.addEvent('onClick', function () {
											var  removedRowId = this.getId().substr('12');
											var  replacedRowId = '';
											var nextId = '';
											document.documentElement.getElement('#containerid #divNewRow'+removedRowId).remove();
											var tempRowId = removedRowId;
											for (var i = removedRowId; i < document.documentElement.getElement('#containerid').children.length; i++) {
												if (i == removedRowId){
													nextId = document.documentElement.getElement('#containerid').children[removedRowId].id.substr('9');
													document.getElementById('Title'+nextId).id = 'Title'+removedRowId;
													document.getElementById('Type'+nextId).id = 'Type'+removedRowId;
													document.getElementById('FileText'+nextId).id = 'FileText'+removedRowId;
													document.getElementById('File'+nextId).id = 'File'+removedRowId;
													document.getElementById('fileDiv'+nextId).id = 'fileDiv'+removedRowId;
													document.getElementById('removeButton'+nextId).id = 'removeButton'+removedRowId;
													document.getElementById('TitleDivField'+nextId).id = 'TitleDivField'+removedRowId;
													document.getElementById('TypeDivField'+nextId).id = 'TypeDivField'+removedRowId;
													document.getElementById('FileDivField'+nextId).id = 'FileDivField'+removedRowId;
													document.getElementById('divNewRow'+nextId).id = 'divNewRow'+removedRowId;
													DocumentCreateForm.DOCFormFile.splice(removedRowId, 1);
												}
												else {
													nextId = document.documentElement.getElement('#containerid').children[tempRowId].id.substr('9');
													document.getElementById('Title'+nextId).id = 'Title'+tempRowId;
													document.getElementById('Type'+nextId).id = 'Type'+tempRowId;
													document.getElementById('FileText'+nextId).id = 'FileText'+tempRowId;
													document.getElementById('File'+nextId).id = 'File'+tempRowId;
													document.getElementById('fileDiv'+nextId).id = 'fileDiv'+tempRowId;
													document.getElementById('removeButton'+nextId).id = 'removeButton'+tempRowId;
													document.getElementById('TitleDivField'+nextId).id = 'TitleDivField'+tempRowId;
													document.getElementById('TypeDivField'+nextId).id = 'TypeDivField'+tempRowId;
													document.getElementById('FileDivField'+nextId).id = 'FileDivField'+tempRowId;
													document.getElementById('divNewRow'+nextId).id = 'divNewRow'+tempRowId;
													DocumentCreateForm.DOCFormFile.splice(tempRowId-1, 1);
												}
												rowLength--;
												tempRowId++;
											}
											var rowLength = document.documentElement.getElement('#containerid').children.length;
											if (rowLength < 11){
												DocumentCreateForm.addRowButton.elements.input.removeClassName('disabled');
												}
											});
											text_input.inject(fileDiv);
											button_input.inject(fileDiv); //fileDiv.appendChild(button_input);
											if (rowLength>1){
												varButton.inject(fileDiv);
											}
  										return fileDiv;
						},
						uploadFile: function(rowLength)
							{
								var that =this;
								var file_input = document.createElement('input');
							  file_input.type = 'file';
								file_input.id='fileInputId'+rowLength;
								file_input.addEventListener('change', function () { that.updateFile(rowLength, file_input);}, false);
							  file_input.click();
							},
							updateFile: function(rowLength, file_input){
								var that =this;
								if (DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+rowLength) == null){
									that.updateFile(rowLength-1, file_input);
								}
									if (file_input.files[0]!=undefined){
											var fileObj =[];
											fileObj.push(file_input.files[0]);
											if (DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+rowLength) != null){
												if (DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+rowLength).value == ''){
														DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+rowLength).value=fileObj[0].name.substr(0, fileObj[0].name.indexOf('.'));
												}
												DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+rowLength).value=fileObj[0].name;
												DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+rowLength).file=fileObj[0];
												DocumentCreateForm.DOCFormFile[rowLength] = fileObj[0];
										}
								}
							},
			formFieldContent : new Form({
				fields: [
							{
								type: 'html',
								name: 'CAFormBody',
								id: 'CAFormBody',
								html: '<div id=DOCFormDiv></div>'
							}
						],
				         events: {
							}
			}),
			CANameContainer : new Text({
	       		 name: 'CAName',
	    		 id: 'CAName',
	    		 required: false,
	    		 value: '',
	    		 hide: true
			}),

			createButton: function(DocumentPresenter){
			    DocumentCreateForm.doneBtn = new Button({
			        value: DOC_NLS.DOC_FORM_Create,
			        className: 'primary',
			        onCompleteCallback: function (DOCDetails) {
			        	DocumentCreateForm.DOCCreateModal.hide();
			        },
			        onFailureCallback: function (errDetailds, errData) {
			        }
			    });
			    DocumentCreateForm.doneBtn.elements.input.onclick = function () {
						 	var showAlertMessage = false;
			        var valid = DocumentCreateForm.formFieldContent.validate(false, false);
			        if (valid) {
									var rowLength = document.documentElement.getElement('#containerid').children.length;
									var titleArray = [];
									var typeArray = [];
									var fileArray = [];
									for (var i = 1; i < rowLength; i++) {
										var title = document.documentElement.getElement('#containerid #Title'+i).value;
										var type = document.documentElement.getElement('#containerid #Type'+i).value;
										var file = DocumentCreateForm.DOCFormFile[i];
										titleArray[i-1] = title;
										typeArray[i-1] = type;
										fileArray[i-1] = file;
									}
									if (DocumentCreateForm.DOCFormFile.length > 0){
										while (DocumentCreateForm.DOCFormFile.length > 0) {
											DocumentCreateForm.DOCFormFile.pop();
										}
									}
									DocumentCreateForm.DOCCreateModal.hide();
									for (var j = 0; j < titleArray.length; j++) {
										if (j == titleArray.length-1){
												showAlertMessage = true;
												DocumentPresenter.createDocument(DocumentPresenter.modelId, titleArray[j], typeArray[j], fileArray[j], showAlertMessage);
										}
										else {
												DocumentPresenter.createDocument(DocumentPresenter.modelId, titleArray[j], typeArray[j], fileArray[j], showAlertMessage);
										}
									}
			        }
			    };

			    return DocumentCreateForm.doneBtn;
			},

			cancelButton : new Button({
			    value: DOC_NLS.DOC_FORM_Cancel,
			    events: {
			        onClick: function () {
						DocumentCreateForm.DOCCreateModal.hide();
			        }
			    }
			}),
			addRowButton : new Button({
			    icon: 'fonticon fonticon-plus',
					className: 'default',
			    events: {
			        onClick: function () {
								var rowLength = document.getElementById('containerid').children.length;
								var containerEL =Core.extendElement(document.body).getElement('#containerid');
								if (rowLength == 10){
									DocumentCreateForm.addNewRowEL(rowLength).inject(containerEL);
									DocumentCreateForm.addRowButton.elements.input.addClassName('disabled');
								}
								else if (rowLength > 10) {
									DocumentCreateForm.addRowButton.elements.input.addClassName('disabled');
								}
								else {
									DocumentCreateForm.addNewRowEL(rowLength).inject(containerEL);
								}
			        }
			    }
			}),
			addNewRowEL: function(rowLength, fileObj) {
                var newel = UWA.createElement('div', { //top div
															'class': 'row',
															id : 'divNewRow'+rowLength,
						                	html: [
																					{
																							 tag: 'div',
																							 html: UWA.createElement(
																										 'div', {
																											 'id':'TitleDivField'+rowLength,
																											 'class': 'col-md-2',
																											 html: DocumentCreateForm.createTextField(rowLength)
																										 })
																					}, {
																							 tag: 'div',
																							 html: UWA.createElement(
																										 'div', {
																											 'id':'TypeDivField'+rowLength,
																											 'class': 'col-md-2',
																											 html: DocumentCreateForm.createSelectField(rowLength)
																										 })
																					},
																					{
																							 tag: 'div',
																							 html: UWA.createElement(
																										 'div', {
																											 'id':'FileDivField'+rowLength,
																											 'class': 'col-md-4',
																											 html: DocumentCreateForm.createFileField(rowLength, fileObj)
																										 })
																					}

																	]

                });
                return newel;
            },

			createDocumentForm: function(DocumentPresenter, files){
				this.DOCCreateModal = null;
				this.docTypeTexts = DocumentPresenter.docTypeTexts;
				this.DOCCreateModal = new Modal({
								    closable: true,
								    className: 'documentmodal',
								    title: DOC_NLS.DOC_Create_Document,
								    header: '<h4>' + DOC_NLS.DOC_Create_Document + '</h4>',
								    //header: "<h4>"+DOC_NLS.DOC_Create_Document+"</h4><span id='headermand' style='margin-left:500px'><h7>"+DOC_NLS.DOC_Create_Document_Header1 +"<font color='#d60900'>*</font>"+DOC_NLS.DOC_Create_Document_Header2 +"</h7></span>",
								    body: DocumentCreateForm.formFieldContent,
								    footer: [DocumentCreateForm.addRowButton, DocumentCreateForm.createButton(DocumentPresenter), DocumentCreateForm.cancelButton],
			                        events: {
			                            onHide: (DocumentCreateForm.pushFormContentOnHide).bind(DocumentCreateForm.DOCCreateModal)
			                        }
								});

				this.DOCCreateModal.inject(widget.body).show();
				var DOCFormDivElem = Core.extendElement(document.body).getElement('#DOCFormDiv');
				DOCFormDivElem.innerHTML = '';
				this.createBody(files).inject(DOCFormDivElem);

				var abstractElem = document.getElementById('Abstract');
				if (abstractElem) {
						abstractElem.focus();
					}

				var EditDOCDIVElem = Core.extendElement(document.body).getElement('#EditDOCDIV');
				if (EditDOCDIVElem){
					 	EditDOCDIVElem.hide();
					}
				DocumentCreateForm.doneBtn.show();
				if (files!=undefined && files!=null){
							DocumentCreateForm.doneBtn.elements.input.disabled = false;
							DocumentCreateForm.doneBtn.elements.input.removeClassName('disabled');
							for (var i = 0; i < files.length; i++) {
									var fileObj = files[i];
									var rowLength = document.getElementById('containerid').children.length;
									var containerEL =Core.extendElement(document.body).getElement('#containerid');
									var tempFileList = [];
									tempFileList.push(fileObj);
									if (i>0){
										var index = i+1;
										DocumentCreateForm.addNewRowEL(rowLength, fileObj).inject(containerEL);
										DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+index).value=fileObj.name.substr(0, fileObj.name.indexOf('.'));
										DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+index).value=fileObj.name;
										DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+index).file=fileObj;
										DocumentCreateForm.DOCFormFile[index] = fileObj;
									}
									else {
										var index = i+1;
										DocumentCreateForm.formFieldContent.elements.container.getElement('#Title'+index).value=fileObj.name.substr(0, fileObj.name.indexOf('.'));
										DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+index).value=fileObj.name;
										DocumentCreateForm.formFieldContent.elements.container.getElement('#FileText'+index).file=fileObj;
										DocumentCreateForm.DOCFormFile[index] = fileObj;
									}
							}
						}
						DocumentCreateForm.addRowButton.elements.input.removeClassName('disabled');
						if (document.documentElement.getElement('.documents-presenter').clientWidth < 950) {
 							 this.resizeForSmallWindow();
 					 }
					 else {
							this.resizeForNormalWindow();
					}
						this.attachResizeSensor(DocumentPresenter.container);
			}
	};

	return DocumentCreateForm;
});
