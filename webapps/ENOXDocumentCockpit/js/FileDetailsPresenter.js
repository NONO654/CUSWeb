/**
 * @module DS/ENOXDocumentCockpit/js/FileDetailsPresenter
 * @description Module defining the list of documents attached to a model
 */

define(
	'DS/ENOXDocumentCockpit/js/FileDetailsPresenter',
	[
		// 'DS/ENOXSplitView/js/ENOXSplitView',
		'UWA/Class/View', 'DS/UIKIT/Input/Button', 'DS/UIKIT/Mask',
		'DS/UIKIT/DropdownMenu', 'DS/CoreEvents/ModelEvents',
		'DS/ENOXDocumentCockpit/js/FilesTableMainContainer',
		'DS/DocumentManagement/DocumentManagement',
		'DS/xPortfolioQueryServices/js/infra/xPortfolioInfra',
		'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
		'DS/ResizeSensor/js/ResizeSensor',
		'DS/WildcardSearchComponent/WildcardSearchComponent',
		'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
		'DS/DocumentManagementCustom/js/DocumentManagementCustom',
		'i18n!DS/ENOXDocumentCockpit/assets/nls/DocumentCockpit'
	],
	function (View, Button, Mask, DropdownMenu, ModelEvents,
		FilesTableMainContainer, DocumentManagement,
		xPortfolioInfra, xNotificationsUtil, ResizeSensor, WildcardSearchComponent, i3DXCompassPlatformServices, DocumentManagementCustom, Document_NLS) {
	return View
	.extend({

		className: 'files-presenter',
		init: function (options) {
			this._applicationChannel = options.applicationChannel ? options.applicationChannel
				 : new ModelEvents();
			// this._applicationChannel.unsubscribe({
			// 	event: 'search-in-current-dashboard'
			// }); ;
			this._globalapplicationChannelForDocPresenter = options.applicationChannel ? options.applicationChannel
				 : new ModelEvents();
			this._localChannel = options.localChannel ? options.localChannel
				 : new ModelEvents();
			this.dataJSON = options.dataJSON ? options.dataJSON : {};

			this.docId = options.docId;
			this.WildcardSearch = new WildcardSearchComponent();

			this._parent(options);
			//this.();
		},

		setup: function () {
			this._parent.apply(this, arguments);
		},

		render: function (data) {
			// Reload the selected Models if not updated
			// if (this.selectedModels && this.selectedModels.length == 1) {
			// } // what was that used for ?

			var that = this;
			var dataJson = '';
			var Reserve_Unreserve = 'lock-open';
			var Reserve_Unreserve_text = Document_NLS.DOC_Command_Unreserve;
			var reserved = true;
			var emptyContainer=true;

			if (data == undefined) {
				dataJson = this.dataJSON;
			} else {
				dataJson = data;
				this.dataJSON = dataJson;
			}

			if(dataJson.relateddata.files.length>0){
				emptyContainer=false;
			}

			if (dataJson.dataelements['reservedby'] == "") {
				Reserve_Unreserve = 'lock';
				Reserve_Unreserve_text = Document_NLS.DOC_Command_Reserve;
				reserved = false;
			}
			this.tablePresenter = new FilesTableMainContainer({
					dataJSON: dataJson,
					kind: 'instance',
					showSwitchViewAction: false,
					_filesPresenter: this,
					actions: [{
							id: 'Reserve_Unreserve',
							text: Reserve_Unreserve_text,
							fonticon: Reserve_Unreserve,
							disable: false,
							handler: function (event, actionView) {
								that.reserve_unreserve(that, Reserve_Unreserve);
								console.log('actionView--' + actionView);
							}
						}, {
							id: 'upload',
							text: Document_NLS.DOC_Command_Upload,
							fonticon: 'upload',
							disable: false,
							// 'event': 'onUploadAction'
							handler: function () {
									//Mask.mask(that.container);
									that.uploadFiles(that);
									console.log('actionView--' + that);

							}
						}, {
							id: 'download',
							text: Document_NLS.DOC_Command_Download,
							fonticon: 'download',
							disable: false,
							handler: function () {
								if(emptyContainer){
										xNotificationsUtil.showError(Document_NLS.DOC_DELETE_No_Files_Download);
									}
								else {
								that.downloadLatestFile(that);
								}
							}

						}, {
							id: 'Multi',
							text: Document_NLS.DOC_Delete,
							fonticon: 'trash',
							disable: false,
							content: [
								//{
								// 	id : 'DeleteLatestVersion',
								// 	text : Document_NLS.DOC_Delete_Latest_Version,
								// //	fonticon : 'fonticon fonticon-lock',
								// 	selectable : true,
								// 	handler : function() {
								// 	var action='DeleteLatestVersion';
								// 		that.deleteFileAction(that,action);
								// 	}
								// },
								{
									id: 'DeleteAllVersions',
									text: Document_NLS.DOC_Delete_All_Version,
									//	fonticon : 'fonticon fonticon-lock-open',
									selectable: true,
									handler: function () {
										var action = 'DeleteAllVersions';
										Mask.mask(that.container);
										that.deleteFileAction(that, action);
									}
								}, {
									id: 'DeleteAllVersionsButLast',
									text: Document_NLS.DOC_Delete_All_Versions_But_Last,
									//fonticon : 'fonticon fonticon-download',
									selectable: true,
									handler: function () {
										var action = 'DeleteAllVersionsButLast';
										Mask.mask(that.container);
										that.deleteFileAction(that, action);
										//	that.downloadSelection(that);
									}
								}
							],
							handler: function () {}
						}
					],
					itemActions: [{
							title: Document_NLS.DOC_Command_Download,
							text: Document_NLS.DOC_Command_Download,
							fonticon: 'download',
							'event': 'onDownloadAction'
						}
					],
					contentFilter: function (item) {
						var includeItem = true;
						if (item.kind == 'reference') {
							includeItem = false;
						}
						return includeItem;
					}
					// actionView : this,
				});
			this.tablePresenter.render(that);
			//	this.tablePresenter.attachResizeSensor();
			//	this.attachResizeSensor();

			this.tablePresenter.subscribe('onDownloadAction', function (item) {
				console.log('onDownloadAction action');
				that.downloadFile(item);
				// that.removeCriteria(criteria);
				// that.removeDictionaryCriteria(criteria);
				// that.onChange();
			});

			var contentView = UWA.createElement('div', {
					styles: {
						width: '100%',
						height: '100%',
						display: 'table'
					}
				});
			var okButton = new Button({
					value: 'Ok',
					className: 'primary'
				});
			okButton.addEvent('onClick', function () {
				that.okAction();
			});
			var cancelButton = new Button({
					value: 'Cancel'
				});
			cancelButton.addEvent('onClick', function () {
				that.cancelAction();
			});

			this.actionPanel = UWA.createElement('div', {
					html: [okButton, cancelButton],
					'class': 'modal-footer',
					styles: {
						width: '100%',
						display: 'none'
					}
				});

			var tableContainer = UWA.createElement('div', {
					html: this.tablePresenter,
					styles: {
						height: '100%',
						width: '100%',
						display: 'table-row'
					}
				});
			contentView.addContent(tableContainer);
			contentView.addContent(this.actionPanel);

			this.container.setContent(contentView);
			this.container.setStyle('height', '100%');
			Mask.mask(this.container);
			this._parent();
			setTimeout(function () {
				that.onRender();
			}, 100);
			return this;
		},
		onRender: function () {
			console.log();
			this.initializeVariabilityView();
			// Mask.mask(this.container);
		},

		initializeVariabilityView: function (collection) {
			//	this.attachResizeSensor();
			Mask.unmask(this.container);
			return this;
		},

		downloadFile: function (id) {
			console.log('Downloading the files');

			var docId = id.docId;
			var fileId = id.id;
			var fileName = id.data.filesAttributes.title;
			var version = id.version;
			var options = {
				onComplete: function (result) {
					console.log('download complete ..' + result);
					if (result) {
						console.log('Result' + result);
						var xhr = new XMLHttpRequest();
						xhr.open('GET', result);
						xhr.responseType = 'blob';
						xhr.onload = function () {
							// IR-556364-3DEXPERIENCER2017x: need a specific way to download blob
							// on IE 11
							if (!window.navigator.msSaveBlob) {
								var a = document.createElement('a');
								a.href = window.URL.createObjectURL(xhr.response); // xhr.response
								// is a blob
								if (fileName) {
									a.download = fileName;
								} // Set the file name.
								a.style.display = 'none';
								document.body.appendChild(a);
								a.click();
								a = undefined;
							} else {
								window.navigator.msSaveBlob(xhr.response, fileName);
							}
						};
						xhr.send();
						xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_download_success);
					} else {
						console
						.log('Error in downloading document: ' + fileInfo.errorMessage);
					}
				},
				onFailure: function (result) {
					console.log('failed' + result);
					xNotificationsUtil.showError(Document_NLS.DOC_Files_download_failure);

				}
			};
			DocumentManagement.downloadDocument(fileId, undefined, false, options);
		},

		reserve_unreserve: function (data, action) {

			var that = data;
			var docId = that.dataJSON.id;

			if (action != undefined && action == 'lock') {
				Mask.mask(that.container);
				DocumentManagementCustom.reserveDocument(docId, {
					securityContext: xPortfolioInfra.getSecurityContext(),
					onComplete: function (successData) {
						xNotificationsUtil.showSuccess(Document_NLS.DOC_Select_Reserve_Success);

						var docOpt = {
							getVersions: true,
							onComplete: function (output) {
								var data = output.data;
								if (data) {
									if (UWA.is(data, 'array')) {
										data = data[0];
									}
								}
								that.render(data);
								Mask.unmask(that.container);

							},
							onFailure: function (output) {},
						};
						DocumentManagement.getDocuments([docId], docOpt);
					},
					onFailure: function (failureData) {
						console.log(failureData);
						xNotificationsUtil.showError(Document_NLS.DOC_Select_Reserve_Error+failureData.error);
						Mask.unmask(that.container);
					}
				});
			} else if (action != undefined && action == 'lock-open') {
				Mask.mask(that.container);
				DocumentManagementCustom.unreserveDocument(docId, {
					securityContext: xPortfolioInfra.getSecurityContext(),
					onComplete: function (successData) {
						xNotificationsUtil.showSuccess(Document_NLS.DOC_Select_Unreserve_Success);
						Mask.unmask(that.container);
						var docOpt = {
							getVersions: true,
							onComplete: function (output) {
								var data = output.data;
								if (data) {
									if (UWA.is(data, 'array')) {
										data = data[0];
									}
								}
								that.render(data);
								Mask.unmask(that.container);

							},
							onFailure: function (output) {},
						};
						DocumentManagement.getDocuments([docId], docOpt);
					},
					onFailure: function (failureData) {
						console.log(failureData);
						xNotificationsUtil.showError(Document_NLS.DOC_Select_Reserve_Error+failureData.error);
						Mask.unmask(that.container);
					}
				});
			} else {
				xNotificationsUtil.showError(Document_NLS.DOC_Select_Reserve_Error);
			}

		},
		downloadLatestFile: function (data) {
			var that = data;
			console.log('Downloading the files');

			var docId = that.dataJSON.id;
			var fileId = that.dataJSON.relateddata.files[0].id;
			var fileName = that.dataJSON.relateddata.files[0].dataelements.title;
			// var docId = id.docId;
			// var fileId = id.id;
			// var fileName = id.data.filesAttributes.title;
			//
			var options = {
				// onComplete : function (result) {
				// console.log('download complete ..');
				// }
				onComplete: function (result) {
					if (UWA.is(result, 'array')) {
						result.forEach(function (fileInfo) {
							if (fileInfo.downloadUrl) {

								xPortfolioInfra.getBlobObject(fileInfo.downloadUrl, function () {
									var blob = this.response;
									if (window.navigator.msSaveOrOpenBlob) {
										var contentType = this.getResponseHeader("content-type");
										window.navigator.msSaveOrOpenBlob(new Blob([blob], {
												type: contentType
											}), fileInfo.fileName);
									} else {
										var downloadLink = UWA.createElement('a', {
												href: window.URL.createObjectURL(blob),
												download: fileInfo.fileName,
												type: 'application/octet-stream'
											});
										downloadLink.click();
									}
								});
							} else {}
						});
					}
				},
				onFailure: function (result) {
					console.log('failed' + result);
					xNotificationsUtil.showError(Document_NLS.DOC_Files_download_failure);
				}
			};
			DocumentManagement.downloadDocuments([docId], options);
		},

		deleteFileAction: function (data, action) {
			var that = data;
			var docId = that.dataJSON.id;
			var fileId = '';
			var fileName = '';
			var versions = '';
			var versionId = '';
			var multifiles = false;
			var reserved = true;
			var loggedInUser = '';
			var owner = that.dataJSON.relateddata.ownerInfo[0].dataelements['name'];
			var access = false;
			if (that.dataJSON.relateddata.files.length > 0) {
				fileId = that.dataJSON.relateddata.files[0].id;
				fileName = that.dataJSON.relateddata.files[0].dataelements.title;
				versions = that.dataJSON.relateddata.files[0].relateddata.versions;
				if (that.dataJSON.relateddata.files.length > 1) {
					multifiles = true;
				}
				i3DXCompassPlatformServices.getUser({
					onComplete: function (data) {
						loggedInUser = data.id;
					}
				});
				if (owner != '' && owner === loggedInUser) {
					access = true;
				}
				if (multifiles) {
					xNotificationsUtil.showError(Document_NLS.DOC_Multi_Files);
					Mask.unmask(that.container);
				} else if (!access) {
					xNotificationsUtil.showError(Document_NLS.DOC_No_Access);
					Mask.unmask(that.container);

				} else {
					if (action == 'DeleteLatestVersion') {
						xNotificationsUtil.showError(Document_NLS.DOC_Files_delete_failure);

					} else if (action == 'DeleteAllVersionsButLast') {
						if (versions.length < 1) {
							xNotificationsUtil.showError(Document_NLS.DOC_DELETE_No_Versions);
							Mask.unmask(that.container);
						} else {
							var length = versions.length;
							that.deleteFile(docId, fileId, versions, length);

						}
					} else if (action == 'DeleteAllVersions') {
						if (fileId == undefined || fileId == '') {
							xNotificationsUtil.showError(Document_NLS.DOC_DELETE_No_Files);
							Mask.unmask(that.container);
						} else {
							var optionsDoc = {
								onComplete: function (output) {
									var docOpt = {
										getVersions: true,
										onComplete: function (output) {
											var data = output.data;
											if (data) {
												if (UWA.is(data, 'array')) {
													data = data[0];
												}
											}
											that.render(data);
											xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_delete_success);

										},
										onFailure: function (output) {

										},
									};
									DocumentManagement.getDocuments([docId], docOpt);
									//		xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_delete_success);

								},
								onFailure: function (output) {
									xNotificationsUtil.showError(Document_NLS.DOC_Files_delete_failure);
								Mask.unmask(that.container);
								}
							};

							DocumentManagement.deleteFile(docId, fileId, optionsDoc);
						}
					} else {
						xNotificationsUtil.showError(Document_NLS.DOC_Files_delete_failure);
								Mask.unmask(that.container);
					}
				}

			} else {
				xNotificationsUtil.showError(Document_NLS.DOC_DELETE_No_Files);
						Mask.unmask(that.container);
			}
		},

		deleteFile: function (docId, fileId, versions, length) {
			var that = this;
			var versionId = versions[length - 1].id;
			var optionsDoc = {
				onComplete: function (output) {
					length = length - 1;
					if (length > 0) {
						that.deleteFile(docId, fileId, versions, length);
					} else {
						xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_delete_success);
						Mask.unmask(that.container);
						var docOpt = {
							getVersions: true,
							onComplete: function (output) {
								var data = output.data;
								if (data) {
									if (UWA.is(data, 'array')) {
										data = data[0];
									}
								}
								that.render(data);

							},
							onFailure: function (output) {},
						};
						DocumentManagement.getDocuments([docId], docOpt);
					}

				},
				onFailure: function (output) {
					xNotificationsUtil.showError(Document_NLS.DOC_Files_delete_failure);
				},
			};
			//	DocumentManagement.getDocuments([docId], docOpt);
			DocumentManagement.deleteVersion(docId, fileId, versionId, optionsDoc);

		},

		uploadFiles: function (data) {
			var that = data;
			// if(data.reservedby !=undefined && data.reservedby==''){
			var fileInput = UWA.createElement('input', {
					type: 'file',
					name: 'files',
					events: {
						change: function () {
							that.tablePresenter.uploadDocument(that.docId, this.files);
							//	that.uploadDocument(that.docId, this.files);
						}
					}
				});
			fileInput.click();
		},
	});
});
