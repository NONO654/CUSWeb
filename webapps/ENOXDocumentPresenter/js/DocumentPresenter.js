/**
* @module DS/ENOXDocumentPresenter/js/DocumentPresenter
* @description Module defining the Documents of a given model
*/

define(
	'DS/ENOXDocumentPresenter/js/DocumentPresenter',
	[ 'UWA/Class/View', 'DS/UIKIT/Input/Button', 'DS/UIKIT/Mask',
	'DS/CoreEvents/ModelEvents',
	'DS/ENOXDocumentPresenter/js/DocumentMainContainer',
	'DS/ENOXDocumentPresenter/js/util/DocumentCreateForm',
	'DS/DocumentManagement/DocumentManagement',
	'DS/xPortfolioQueryServices/js/infra/xPortfolioInfra',
	'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
	'DS/ENOXDocumentPresenter/js/util/DocumentSearchController',
	'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
	'DS/ENOXDocumentPresenter/js/util/DocumentCommonUtils',
	'DS/TaggerOnIndexComponent/TaggerOnIndexComponent',
	'DS/WildcardSearchComponent/WildcardSearchComponent',
	'DS/DocumentManagementCustom/js/DocumentManagementCustom',
	'DS/PlatformAPI/PlatformAPI',
	'DS/Controls/ProgressBar',
	'i18n!DS/ENOXDocumentPresenter/assets/nls/DocumentsPresenter',
	'css!DS/ENOXDocumentPresenter/css/Documents.css' ],
	function(View, Button, Mask, ModelEvents, DocumentMainContainer,
		DocumentCreateForm, DocumentManagement, xPortfolioInfra,
		i3DXCompassPlatformServices, DocumentSearchController, xNotificationsUtil,
		DocumentCommonUtils, TaggerOnIndexComponent, WildcardSearchComponent, DocumentManagementCustom, PlatformAPI, WUXProgressBar, DOC_NLS) {
			return View.extend({
				className : 'documents-presenter',

				init : function(options) {

					this.EVENTOUT_OPENINFO = 'enoxdoc-open-properties';
					this.EVENTINOUT_SELECTIONCHANGED = 'enoxdoc-selection_changed';
					this.EVENTINOUT_DOUBLECLICK = 'enoxdoc-double-click';

					this.dictionaryJSON = options.dictionaryJSON ? options.dictionaryJSON
					: {};
					this._applicationChannel = options.modelEvents ? options.modelEvents
					: new ModelEvents();
					this._globalapplicationChannel = options.applicationChannel ? options.applicationChannel
					: new ModelEvents();
					this.modelId = options.parentId;
					this._internalChannel = options.modelEvents;
					this.documentTypes = options['data-model'].documentTypes;
					this.documentSearchTypes = options.searchQueryType;
					this.tagFriends = options.tagFriends;
					this.WildcardSearch = new WildcardSearchComponent();
					this._subscribeToEvents();
					this._parent(options);
				},

				setup : function() {
					this._parent.apply(this, arguments);
				},

				registerToOpenPropery : function(callback) {
					this._registerToEvent(this.EVENTOUT_OPENINFO, callback);
				},

				registerToSelectionChanged : function(callback) {
					this._registerToEvent(this.EVENTINOUT_SELECTIONCHANGED, callback);
				},

				registerToOpenDocument : function(callback) {
					this._registerToEvent(this.EVENTINOUT_DOUBLECLICK, callback);
				},

				render : function() {
					var that = this;
					that.docRels = '';
					that.docTypes = '';
					that.docPolicies = '';

					for (var i = 0; i < that.documentTypes.length; i++) {
						if (i == 0) {
							that.docRels = that.documentTypes[i].relationship;
							that.docTypes = that.documentTypes[i].type;
							that.docPolicies = that.documentTypes[i].Policy;
							that.docTypeTexts = that.documentTypes[i].text;
						} else if (i > 0) {
							that.docRels = that.docRels + ',' + that.documentTypes[i].relationship;
							that.docTypes = that.docTypes + ',' + that.documentTypes[i].type;
							that.docPolicies = that.docPolicies + ','
							+ that.documentTypes[i].Policy;
							that.docTypeTexts = that.docTypeTexts + ','
							+ that.documentTypes[i].text;
						}
					}
					that.docRelsArray = that.docRels.split(',');
					that.docTypesArray = that.docTypes.split(',');
					that.docPoliciesArray = that.docPolicies.split(',');
					that.docTypesTextArray = that.docTypeTexts.split(',');

					var optionsDoc = {
						relInfo : {
							parentId : this.modelId,
							parentRelName : that.docRels
						},
						getVersions : true,
						securityContext : xPortfolioInfra.getSecurityContext(),
						tenantUrl: xPortfolioInfra._serviceUrl,
						tenant: 'OnPremise',
						onComplete : function(output) {
							that.documentPresenterRenderOnComplete(output);
						}
					};
					DocumentManagement.getDocumentsFromParent(optionsDoc);
					that.clearProgressBars();
					return this;
				},
				documentPresenterRenderOnComplete :  function(output){
					var that = this;
					var data = output.data;
					if (data) {
						that.initiateDocumentMainContainer(data);
					}
				},
				initiateDocumentMainContainer : function(data){
					var that = this;
					var columnData = that.enableOrDisableEdiableColumns(that.options['table-data'].columns, that);
					that.tablePresenter = new DocumentMainContainer(
						{
							dictionaryJSON : data,
							showSwitchViewAction : false,
							modelId : that.modelId,
							docOptions: that,
							columns : columnData,
							actions : [
								{
									id : 'Create',
									text : DOC_NLS.DOC_Create,
									fonticon : 'plus',
									disable :false,
									content : [ {
										id : 'CreateDocument',
										text : DOC_NLS.DOC_Create_New,
										fonticon : 'fonticon fonticon-new-create',
										selectable : true,
										disable : false,
										handler : function() {
											DocumentCreateForm.createDocumentForm(that);
										}
									}, {
										id : 'AddExistingDocument',
										text : DOC_NLS.DOC_Add_Existing,
										fonticon : 'fonticon fonticon-compare-add',
										selectable : true,
										disable : false,
										handler : function() {
											that.addExistingDocumentsSearch();
										}
									} ],
									handler : function() {
									}
								},
								{
									id : 'delete',
									text : DOC_NLS.DOC_Remove,
									fonticon : 'trash',
									disable : false,
									handler : function() {
										Mask.mask(that.container);
										that.removeDocumentsFromActionBar(that);
									}
								},
								{
									id : 'Multi',
									text : DOC_NLS.DOC_Multi,
									fonticon : 'fonticon fonticon-multisel-label fonticon fonticon-2x fonticon-select-on',
									disable : false,
									content : [ {
										id : 'ReserveSelected',
										text : DOC_NLS.DOC_Reserve_Selected,
										fonticon : 'fonticon fonticon-lock',
										selectable : true,
										disable : false,
										handler : function() {
											that.reserveDocument(that);
										}
									}, {
										id : 'UnreserveSelected',
										text : DOC_NLS.DOC_Unreserve_Selected,
										fonticon : 'fonticon fonticon-lock-open',
										selectable : true,
										disable : false,
										handler : function() {
											that.unreserveDocument(that);
										}
									}, {
										id : 'DownloadSelection',
										text : DOC_NLS.DOC_Download_Selection,
										fonticon : 'fonticon fonticon-download',
										selectable : true,
										handler : function() {
											that.downLoadSelectedDocs(that);
										}
									} ],
									handler : function() {
									}
								} ],
								itemActions : [ {
									id : 'information',
									text : DOC_NLS.DOC_Information,
									disable : false,
									fonticon : 'info',
									'event' : 'onInfoAction'
								}, {
									id : 'download',
									text : DOC_NLS.DOC_Download,
									fonticon : 'download',
									event : 'onDownload'
								}, {
									id : 'upload',
									text : DOC_NLS.DOC_Upload,
									fonticon : 'upload',
									disable : false,
									event : 'onUpload'
								}, {
									id : 'reserve',
									text : DOC_NLS.DOC_Reserve,
									disable : false,
									fonticon : 'fonticon fonticon-lock',
									event : 'onReserveAction'
								}, {
									id : 'unreserve',
									text : DOC_NLS.DOC_Unreserve,
									disable :false,
									fonticon : 'fonticon fonticon-lock-open',
									event : 'onUnreserveAction'
								}, {
									id : 'remove',
									text : DOC_NLS.DOC_Remove,
									disable : false,
									fonticon : 'trash',
									event : 'onRemoveAction'
								} ],
								contentFilter : function(item) {
									var includeItem = true;
									if (item.kind == 'reference') {
										includeItem = false;
									}
									return includeItem;
								}
							});
							that.tagInit('TagDocPresenter', this._internalChannel, data);
							that.tablePresenter.render(that);
							that.tablePresenter._stdActionbar._modelEvents.publish({ event: 'enox-collection-toolbar-disable-action', data: 'delete' });
							that.tablePresenter.subscribe(that.EVENTINOUT_SELECTIONCHANGED,
								function(data) {
									that.onSelectionChangeEvent(data);
								});

								that.tablePresenter.subscribe(that.EVENTINOUT_DOUBLECLICK, function(
									data) {
										// forward event
										that._applicationChannel.publish({
											event : that.EVENTINOUT_DOUBLECLICK,
											data : data
										});
									});

									that.tablePresenter.subscribe('onRemoveAction', function(criteria) {
										that.onRemoveAction(criteria);
									});

									that.tablePresenter.subscribe('onInfoAction', function(criteria) {
										that.onInfoAction(criteria);
									});

									that.tablePresenter.subscribe('onDownload', function(criteria) {
										that.onDownload(criteria);
									});

									that.tablePresenter.subscribe('onUpload', function(criteria) {
										that.onUpload(criteria);
									});
									that.tablePresenter.subscribe('onReserveAction', function(criteria) {
										that.onReserveAction(criteria);
									});
									that.tablePresenter.subscribe('onUnreserveAction', function(criteria) {
										that.onUnreserveAction(criteria);
									});
									var contentView = UWA.createElement('div', {
										id: 'contentviewid',
										styles : {
											width : '100%',
											height : '100%',
											display : 'table'
										}
									});
									var tableContainer = UWA.createElement('div', {
										html : that.tablePresenter,
										styles : {
											height : '100%',
											width : '100%',
											display : 'table-row'
										}
									});
									contentView.addContent(tableContainer);
									contentView.addContent(that.progressPanel);

									that.container.setContent(contentView);
									that.container.setStyle('height', '100%');

									var columnHeaderContainer = that.container.getElement('.documents-presenter li.wux-layouts-gridengine-columns-header-container');
									DocumentCommonUtils.makeDroppable(columnHeaderContainer, DOC_NLS.DOC_Landing_Page, function(e) {that.dropFileOnHeader(e);});


									that._internalChannel.subscribe({ event: 'enoxdoc-refresh-item' }, that._updateDocument.bind(that));
									setTimeout(function() {
										that.onRender();
									}, 100);
								},
								onSelectionChangeEvent : function(data){
									var that = this;
									that.selectedDocuments = data.map(function(node) {
										return node.options.id;
									});
									that._applicationChannel.publish({
										event : that.EVENTINOUT_SELECTIONCHANGED,
										data : that.selectedDocuments
									});
									if (data.length > 0) {
										that.enableActionBarCommand('delete');
									} else {
										that.disableActionBarCommand('delete');
									}
								},
								enableActionBarCommand : function(commandId){
									var that = this;
									that.tablePresenter._stdActionbar._modelEvents.publish({ event: 'enox-collection-toolbar-enable-action', data: commandId });
								},
								disableActionBarCommand : function(commandId){
									var that = this;
									that.tablePresenter._stdActionbar._modelEvents.publish({ event: 'enox-collection-toolbar-disable-action', data: commandId });
								},
								onRemoveAction : function(criteria){
									var that= this;
									if (criteria.reservedby != undefined && (criteria.reservedby == '' || criteria.reservedby == DocumentCommonUtils.getLoggedInUser())) {
										var strType = that.docRelsArray[that.docTypesTextArray.indexOf(criteria.docType)];
											that.removeDocuments(that.modelId, criteria.clickedId, strType, true);
											} else {
												xNotificationsUtil.showError(DOC_NLS.DOC_UNRESERVE_MESSAGE_USER+criteria.reservedby);
											}
										},
										onInfoAction : function(criteria){
											var that= this;
											if (criteria.reservedby != undefined && criteria.reservedby == '') {
												if (criteria.clickedId.length > 0) {
													if (criteria.editMode) {
														that.showInformation(criteria.clickedId);
													}
												}
											} else if (criteria.reservedby == undefined) {
												if (criteria.editMode) {
													that.showInformation(criteria.clickedId);
												}
											}
											else if (criteria.reservedby == DocumentCommonUtils.getLoggedInUser()) {
												that.showInformation(criteria.clickedId);
											} else {
												xNotificationsUtil.showError(DOC_NLS.DOC_UNRESERVE_MESSAGE_USER+criteria.reservedby);
											}
										},
										onDownload : function(criteria){
											var that= this;
											that.downloadDocument(criteria.clickedId);
										},
										onUpload : function(criteria){
											var that= this;
											var nodeModel = criteria.nodeModel;
											if (criteria.reservedby != undefined && (criteria.reservedby == '' || criteria.reservedby == DocumentCommonUtils.getLoggedInUser())) {
												var fileInput = UWA.createElement('input', {
													type : 'file',
													name : 'files',
													events : {
														change : function() {
															that.uploadDocument(criteria.clickedId, this.files, nodeModel);
														}
													}
												});
												fileInput.click();
											} else {
												xNotificationsUtil.showError(DOC_NLS.DOC_UNRESERVE_MESSAGE_USER+criteria.reservedby);
											}
										},
										onReserveAction : function(criteria){
											var that= this;
											if (criteria.reservedby == ''){
												Mask.mask(that.container);
												DocumentManagementCustom.reserveDocument(criteria.clickedId,
													{
														securityContext : xPortfolioInfra.getSecurityContext(),
														additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
														onComplete : function(successData) {
															that.onReserveActionOnSuccess(successData);
														},
														onFailure : function(failureData) {
															that.onReserveActionOnFailure(failureData);
														}
													});
												}
												else {
													xNotificationsUtil.showError(DOC_NLS.DOC_SELECT);
												}
											},
											onReserveActionOnSuccess : function(successData){
												var that = this;
												xNotificationsUtil.showSuccess(DOC_NLS.DOC_Select_Reserve_Success);
												Mask.unmask(that.container);
												that.render();
											},
											onReserveActionOnFailure : function(failureData){
												var that = this;
												xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve_Error+failureData.error);
												Mask.unmask(that.container);
												that.render();
											},
											onUnreserveAction : function(criteria){
												var that= this;
												if (criteria.reservedby != '' && criteria.reservedby == DocumentCommonUtils.getLoggedInUser()) {
													Mask.mask(that.container);
													DocumentManagementCustom.unreserveDocument(criteria.clickedId,
														{
															securityContext : xPortfolioInfra.getSecurityContext(),
															additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
															onComplete : function(successData) {
																that.onUnreserveActionOnSuccess(successData);
															},
															onFailure : function(failureData) {
																that.onUnreserveActiononFailure(failureData);
															}
														});
													}
													else if (criteria.reservedby != '' && criteria.reservedby != DocumentCommonUtils.getLoggedInUser()) {
														xNotificationsUtil.showError(DOC_NLS.DOC_UNRESERVE_MESSAGE_USER+criteria.reservedby);
													}
													else {
														xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve);
													}
												},
												onUnreserveActionOnSuccess :  function(successData){
													var that = this;
													xNotificationsUtil.showSuccess(DOC_NLS.DOC_Select_Unreserve_Success);
													Mask.unmask(that.container);
													that.render();
												},
												onUnreserveActionOnFailure :  function(failureData){
													var that = this;
													xNotificationsUtil.showError(DOC_NLS.DOC_Select_Unreserve_Error+failureData.error);
													Mask.unmask(that.container);
													that.render();
												},
												clearProgressBars: function(){
													if (document.getElementsByClassName('progressupload')!=null && document.getElementsByClassName('progressupload').length>0){
														document.getElementsByClassName('progressupload')[0].remove()
													}
													if (document.getElementsByClassName('progress')!=null && document.getElementsByClassName('progress').length>0){
														document.getElementsByClassName('progress')[0].remove();
													}
												},
												_updateDocument : function (itemId) {
													var that =this;
													if (itemId!=undefined) {
														that.render();
													}
												},
												enableOrDisableEdiableColumns : function(action, currentObj){
													var that = currentObj;
													if (action instanceof  Array) {
														action.forEach(function(element) {
															if (that.options.actions['enable-update'] == false){
															element.isEditable = false;
														}
														});
														return action;
													}
												},
												onRender : function() {
													this.initializeDocumentView();
													return UWA.Promise.resolve();
												},

												updateDocumentTable : function(documentIds, action) {
													var that = this;
													this.onRender().fin(function() {
														return that.onRender();
													}).fin(function success() {
														if (action == 'AddExisting') {
															action = 'Add';
															Mask.unmask(that.container);
														}
														that.updateDictionaryJson(documentIds, action);
													}, function failure() {
													});
												},
												updateDictionaryJson : function(documentIds, action) {
													var that = this;
													if ('Remove' == action) {
														if (that.tablePresenter.options.dictionaryJSON.length == 1) {
															that.tablePresenter.removeCriteria([ documentIds ]);
															this.render();
														} else {
															that.tablePresenter.removeCriteria([ documentIds ]);
														}
													}
													if ('Add' == action) {

														if (that.tablePresenter.contentSection.firstElementChild == null) {
															that.tablePresenter.addCriteria([ documentIds ]);
															this.render();
														} else {
															that.tablePresenter.addCriteria([ documentIds ]);
														}
													}
												},

												removeCriteria : function(criteria) {
													var that = this;
													var criteriaToRemove = criteria.clickedId;
													that.tablePresenter.removeCriteria([ criteriaToRemove ]);
												},
												addCriteria : function(criteria) {
													var that = this;
													var criteriaToAdd = criteria.clickedId;
													that.tablePresenter.addCriteria([ criteriaToAdd ]);
												},

												dropFileOnHeader: function (e){
													var that = this;
													var optionsEnableCreate  =that.options.actions['enable-create'];
													var optionsEnableAdd  =that.options.actions['enable-add'];
													if (e.preventDefault) {
														e.preventDefault();
													}
													if (e.dataTransfer!=undefined){
														if (optionsEnableCreate == true){
															if (e.dataTransfer.files.length > 10){
																	xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
															}
															else {
																DocumentCreateForm.createDocumentForm(that, e.dataTransfer.files);
															}
														}
														else {
															xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
														}
													}
													else {
														if (optionsEnableAdd == true){
															if (e.length == 1){
															that.connectDocumentToParent(e['0'].objectId, that.modelId, e, true);
															}
															else {
																xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
															}
														}
														else {
															xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
														}
													}
													var columnHeaderContainer = that.container.getElement('.documents-presenter ul.wux-ui-stack-h');
													if (columnHeaderContainer!= undefined){
														that.dropInvite = columnHeaderContainer.getElement('#droppable');
														that.dropInvite.addClassName('hidden');
														that.dropInvite.removeClassName('show');
														that.dropInvite.removeClassName('droppable');
													}
												},
												reserveDocument : function(currentObj) {
													var that = currentObj;
													if (that == undefined || that.selectedDocuments == undefined || that.selectedDocuments.length == 0) {
														xNotificationsUtil.showError(DOC_NLS.DOC_SELECT);
													}
													else {
														var documentId = '';
														for (i=0;i<that.selectedDocuments.length;i++){
															if (i==0){
																documentId = that.selectedDocuments[i];
															}
															else {
																documentId = documentId+','+that.selectedDocuments[i];
															}
														}
														var optionsDoc = {
															relInfo : {
																parentId : documentId,
																parentRelName : that.docRels
															},
															onComplete : function(output) {
																that.reserveDocumentOnComplete(output);
															},
															onFailure : function(failureData) {
																xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve_Error+failureData.error);
																Mask.unmask(that.container);
															}
														};
														var docIdsArr = Array.isArray(documentId) ? documentId : [ documentId ];
														DocumentManagement.getDocuments(docIdsArr, optionsDoc);
													}
												},
												unreserveDocument : function(currentObj) {
													var that = currentObj;
													if (that == undefined || that.selectedDocuments == undefined || that.selectedDocuments.length == 0) {
														xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve);
													}
													else {
														var documentId = '';
														for (i=0;i<that.selectedDocuments.length;i++){
															if (i==0){
															documentId = that.selectedDocuments[i];
														}
															else {
																documentId = documentId+','+that.selectedDocuments[i];
															}
														}
														var optionsDoc = {
															relInfo : {
																parentId : documentId,
																parentRelName : that.docRels
															},
															onComplete : function(output) {
																that.unreserveDocumentOnComplete(output);
															},
															onFailure : function(failureData) {
																xNotificationsUtil.showError(DOC_NLS.DOC_Select_Unreserve_Error+failureData.error);
																Mask.unmask(that.container);
															}
														};
														var docIdsArr = Array.isArray(documentId) ? documentId : [ documentId ];
														DocumentManagement.getDocuments(docIdsArr, optionsDoc);
													}
												},
												reserveDocumentOnComplete : function(output){
													var that = this;
													var isReserved = false;
													for (var i = 0; i < output.data.length; i++) {
														var reserveStatus = output.data[i].dataelements.reservedby;
														if (reserveStatus !=''){
															isReserved = true;
															break;
														}
													}
													if (!isReserved){
														Mask.mask(that.container);
														var index = 1;
														for (i=0;i<that.selectedDocuments.length;i++){
															DocumentManagementCustom.reserveDocument(that.selectedDocuments[i],
																{
																	securityContext : xPortfolioInfra.getSecurityContext(),
																	additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																	onComplete : function(successData) {
																		if (i == index){
																			xNotificationsUtil.showSuccess(DOC_NLS.DOC_Select_Reserve_Success);
																			Mask.unmask(that.container);
																			that.render();
																		}
																		else {
																			index++;
																		}
																	},
																	onFailure : function(failureData) {
																		xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve_Error+failureData.error);
																		Mask.unmask(that.container);
																		that.render();
																	}
																});
															}
														}
														else {
															xNotificationsUtil.showError(DOC_NLS.DOC_SELECT);
															Mask.unmask(that.container);
														}
													},
													unreserveDocumentOnComplete : function(output){
														var that = this;
														var isUnreserved = false;
														var reservedbySomeoneElse = false;
														for (var i = 0; i < output.data.length; i++) {
															var reserveBy = output.data[i].dataelements.reservedby;
															if (reserveBy ==''){
																isUnreserved = true;
																break;
															}
															if (reserveBy != DocumentCommonUtils.getLoggedInUser()){
																isUnreserved = true;
																reservedbySomeoneElse = true;
																break;
															}
														}
														if (!isUnreserved){
															Mask.mask(that.container);
															var index = 1;
															for (i=0;i<that.selectedDocuments.length;i++){
																DocumentManagementCustom.unreserveDocument(that.selectedDocuments[i],
																	{
																		securityContext : xPortfolioInfra.getSecurityContext(),
																		additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																		onComplete : function(successData) {
																			if (i == index){
																				xNotificationsUtil.showSuccess(DOC_NLS.DOC_Select_Unreserve_Success);
																				Mask.unmask(that.container);
																				that.render();
																			}
																			else {
																				index++;
																			}
																		},
																		onFailure : function(failureData) {
																			xNotificationsUtil.showError(DOC_NLS.DOC_Select_Unreserve_Error+failureData.error);
																			Mask.unmask(that.container);
																			that.render();
																		}
																	});
																}
															}
															else if (reservedbySomeoneElse) {
																xNotificationsUtil.showError(DOC_NLS.DOC_REMOVE_FROM_ACTION_MENU);
															}
															else {
																xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve);
																Mask.unmask(that.container);
															}
														},
														downLoadSelectedDocs : function(currentObj){
															var that = currentObj;
															if (that.selectedDocuments== undefined || that.selectedDocuments.length == 0) {
																xNotificationsUtil.showError(DOC_NLS.DOC_Remove_empty_error);
															}
															else {
																var optionsDoc = {
																	relInfo : {
																		parentId : that.modelId,
																		parentRelName : that.docRels
																	},
																	getVersions : true,
																	onComplete : function(output) {
																		that.downLoadSelectedDocsOnComplete(output);
																	},
																	onFailure : function(result) {
																	}
																};
																var docIdsArr = Array.isArray(that.selectedDocuments) ? that.selectedDocuments : [ that.selectedDocuments ];
																DocumentManagement.getDocuments(docIdsArr, optionsDoc);
															}
														},
														downLoadSelectedDocsOnComplete: function(output){
															var that = this;
															var allowDownload = true;
															for (var i = 0; i < output.data.length; i++) {
																var fileName = output.data[i].dataelements.fileInfo;
																if (output.data[i].relateddata.files.length == 0){
																	allowDownload = false;
																	break;
																}
															}
															if (allowDownload){
																that.downloadSelection(that);
															}
															else {
																xNotificationsUtil.showError(DOC_NLS.DOC_Download_Empty_File_errorMessage);
															}
														},
														downloadSelection : function(currentObj) {
															var that = currentObj;
															DocumentManagement.downloadDocuments(that.selectedDocuments, {
																asZip : true,
																onComplete : function(result) {
																	if (UWA.is(result, 'array')) {
																		result.forEach(function(fileInfo) {
																			if (fileInfo.downloadUrl) {
																				that.download(fileInfo.downloadUrl, fileInfo.fileName, that);
																			}
																		});
																	}
																},
																onFailure : function(result) {
																	xNotificationsUtil.showError(DOC_NLS.DOC_Files_DownloadSelection_Error);
																}
															});
														},
														download:function(url, fileName, that) {
															var xhr = new XMLHttpRequest();
															xhr.open('GET', url, true);
															xhr.responseType = 'blob';
															that.progressPanel = UWA.createElement('div', {
																html :'',
																'class' : 'progress',
																styles : {
																	width : '100%',
																	display : 'none'
																}
															});
															if (document.getElementById('contentviewid') != null){
																document.getElement('#contentviewid').addContent(that.progressPanel);
															}
															var progressbar = new WUXProgressBar(
																{
																	infiniteFlag: false,
																	emphasize: 'success',
																	value:1
																}).inject(that.progressPanel);
																if (document.getElementsByClassName('progress').length >0){
																	document.getElement('.progress').style.display = 'block';
																}
																xhr.onprogress = function(event) {
																	that.xhronprogressEvent(progressbar, event);
																};

																xhr.onload = function(event) {
																	if (this.status == 200) {
																		progressbar.value = 100;
																		document.getElement('.progress').remove();
																		that._saveBlob(this.response, fileName, that);
																		xNotificationsUtil.showSuccess(DOC_NLS.DOC_Files_download_success);
																	}
																	else {
																		xNotificationsUtil.showError(DOC_NLS.DOC_Files_Download_Error+fileName);
																		document.getElement('.progress').remove();
																	}
																};

																xhr.onerror = function(event){
																	xNotificationsUtil.showError(DOC_NLS.DOC_Files_Download_Error+fileName);
																	document.getElement('.progress').remove();
																};

																xhr.send();
															},
															_saveBlob:function(response, fileName, that) {
																if (navigator.msSaveBlob){
																	navigator.msSaveBlob(response, fileName);
																}
																else {
																	that._html5Saver(response, fileName);
																}
															},

															_html5Saver:function(blob, fileName) {
																var a = document.createElement('a');
																document.body.appendChild(a);
																a.style = 'display: none';
																var url = window.URL.createObjectURL(blob);
																a.href = url;
																a.download = fileName;
																a.click();
																document.body.removeChild(a);
															},
															removeDocumentsFromActionBar : function(currentObj) {
																var that = currentObj;
																if (that == undefined || that.selectedDocuments == undefined || that.selectedDocuments.length == 0) {
																	xNotificationsUtil.showError(DOC_NLS.DOC_SELECT);
																	Mask.unmask(that.container);
																}
																else {
																	var documentId = '';
																	for (i=0;i<that.selectedDocuments.length;i++){
																		if (i==0){
																			documentId = that.selectedDocuments[i];
																		}
																		else {
																			documentId = documentId+','+that.selectedDocuments[i];
																		}
																	}
																	var optionsDoc = {
																		relInfo : {
																			parentId : documentId,
																			parentRelName : that.docRels
																		},
																		onComplete : function(output) {
																			that.removeDocumentsFromActionBarOnComplete(output, currentObj);
																				},
																				onFailure : function(failureData) {
																					xNotificationsUtil.showError(DOC_NLS.DOC_Select_Reserve_Error+failureData.error);
																					Mask.unmask(that.container);
																				}
																			};
																			var docIdsArr = Array.isArray(documentId) ? documentId : [ documentId ];
																			DocumentManagement.getDocuments(docIdsArr, optionsDoc);
																		}
																	},
																	removeDocumentsFromActionBarOnComplete : function(output, currentObj){
																		var that = this;
																		var reservedbySomeoneElse = false;
																		for (var i = 0; i < output.data.length; i++) {
																			var reservedBy = output.data[i].dataelements.reservedby;
																			if (reservedBy != '' && reservedBy != DocumentCommonUtils.getLoggedInUser()){
																				reservedbySomeoneElse = true;
																				break;
																			}
																		}
																		if (!reservedbySomeoneElse){
																			var optionsDoc = {
																				relInfo : {
																					parentId : currentObj.modelId,
																					parentRelName : that.docRels
																				},
																				getVersions : true,
																				onComplete : function(output) {
																					that._removeDocumentsFromActionBarOnComplete(output, currentObj);
																						},
																						onFailure : function(result) {
																							Mask.unmask(that.container);
																						}
																					};
																					DocumentManagement.getDocumentsFromParent(optionsDoc);
																				}
																				else if (reservedbySomeoneElse) {
																					xNotificationsUtil.showError(DOC_NLS.DOC_REMOVE_FROM_ACTION_MENU);
																					Mask.unmask(that.container);
																				}
																				else {
																					xNotificationsUtil.showError(DOC_NLS.DOC_SELECT);
																					Mask.unmask(that.container);
																				}
																	},
																	_removeDocumentsFromActionBarOnComplete : function(output, currentObj){
																		var that  = this;
																		Mask.mask(that.container);
																		var showAlertMessage = false;
																		var data = output.data;
																		if (data) {
																			const maxIndex = that.selectedDocuments.length;
																			for (var i = 0; i < maxIndex; i++) {
																				var docId = that.selectedDocuments[i];
																				if (i == maxIndex - 1) {
																					showAlertMessage = true;
																				}
																				var strType = that.docRelsArray[that.docTypesArray.indexOf(that.getDocumentType(data, docId))];
																					that.removeDocuments(currentObj.modelId, docId, strType, showAlertMessage);
																					}
																				}
																				Mask.unmask(that.container);
																	},
																	getDocumentType : function(data, docId) {
																		var docType = '';
																		for (var i = 0; i < data.length; i++) {
																			if (data[i].id == docId) {
																				docType = data[i].type;
																			}
																		}
																		return docType;
																	},
																	getDocRelTypeFromDocType : function(docType) {
																		var docRelType = '';
																		var docTypes = this.docTypesArray;
																		var docRels = this.docRelsArray;
																		docRelType = docRels[docTypes.indexOf(docType)];
																		return docRelType;
																	},
																	getDocRelTypeFromDocText : function(docText) {
																		var docRelType = '';
																		var docTexts = this.docTypesTextArray;
																		var docRels = this.docRelsArray;
																		docRelType = docRels[docTexts.indexOf(docText)];
																		return docRelType;
																	},
																	getDocTypeFromDocText : function(docText) {
																		var docType = '';
																		var docTexts = this.docTypesTextArray;
																		var docTypes = this.docTypesArray;
																		docType = docTypes[docTexts.indexOf(docText)];
																		return docType;
																	},
																	getDocPolicyTypeFromDocText : function(docText) {
																		var docPolicy = '';
																		var docTexts = this.docTypesTextArray;
																		var docPolicies = this.docPoliciesArray;
																		docPolicy = docPolicies[docTexts.indexOf(docText)];
																		return docPolicy;
																	},
																	initializeDocumentView : function(collection) {
																		return this;
																	},

																	showInformation : function(id) {
																		this._applicationChannel.publish({
																			event : this.EVENTOUT_OPENINFO,
																			data : {id:id}
																		});
																	},

																	removeDocuments : function(modelId, documentIds, docRelType,
																		showAlertMessage) {
																			var that = this;
																			var docSelected = documentIds;
																			var docIdsArr;
																			if (docSelected != undefined) {
																				docIdsArr = Array.isArray(docSelected) ? docSelected : [ docSelected ];
																				var inputData = {
																					securityContext : xPortfolioInfra.getSecurityContext(),
																					additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																					'relInfo' : {
																						parentId : modelId,
																						parentRelName : docRelType,
																						parentDirection : 'from'
																					},
																					onComplete : function(output) {
																						that.removeDocumentsOnComplete(showAlertMessage, documentIds);
																					},
																					onFailure : function(result) {
																						that.removeDocumentsOnFailure(result, showAlertMessage);
																					}
																				};

																				DocumentManagement.disconnectDocumentFromParent(documentIds, inputData);
																			}
																		},
																		removeDocumentsOnFailure : function(result, showAlertMessage){
																			if (showAlertMessage) {
																				xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
																			}
																		},
																		removeDocumentsOnComplete : function(showAlertMessage, documentIds){
																			var that  = this;
																			if (showAlertMessage) {
																				xNotificationsUtil.showSuccess(DOC_NLS.DOC_Remove_success);
																				Mask.unmask(that.container);
																			}
																			that.updateDocumentTable(documentIds, 'Remove');
																		},
																		downloadDocument : function(documentId) {
																			var that = this;
																			DocumentManagement.downloadDocuments([ documentId ], {
																				onComplete : function(result) {
																					if (UWA.is(result, 'array')) {
																						result.forEach(function(fileInfo) {
																							if (fileInfo.downloadUrl) {
																								that.download(fileInfo.downloadUrl, fileInfo.fileName, that);
																							}
																						});
																					}
																				},
																				onFailure : function(result) {
																					xNotificationsUtil.showError(DOC_NLS.DOC_Files_DownloadSelection_Error);
																				}
																			});
																		},

																		uploadDocument : function(documentId, files, nodeModel) {
																			var that = this;
																			if (files.length>0){
																				var docFileName = '';

																				that.progressPanelUpload = UWA.createElement('div', {
																					html :'',
																					'class' : 'progressupload',
																					styles : {
																						width : '100%',
																						display : 'none'
																					}
																				});
																				document.getElement('#contentviewid').addContent(that.progressPanelUpload);
																				var progressbarUpload = new WUXProgressBar(
																					{
																						infiniteFlag: false,
																						emphasize: 'success',
																						value:10
																					}).inject(that.progressPanelUpload);
																					document.getElement('.progressupload').style.display = 'block';

																					var optionsDoc = {
																						securityContext : xPortfolioInfra.getSecurityContext(),
																						additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																						relInfo : {
																							parentId : documentId,
																							parentRelName : that.docRels
																						},
																						onComplete : function(output) {
																							if (output.data['0'].dataelements.reservedby == DocumentCommonUtils.getLoggedInUser() || output.data['0'].dataelements.reservedby == ''){
																								if (output.data['0'].relateddata.files.length <= 1){
																									if (undefined != output.data['0'].relateddata.files['0']) {
																										docFileName = output.data['0'].relateddata.files['0'].dataelements.title;
																									}
																									var fileObject = files[0];
																									if (docFileName == '') {
																										DocumentManagement.addFileToDocument({
																											id : documentId,
																											fileInfo : {
																												file : fileObject
																											}
																										}, {
																											securityContext : xPortfolioInfra.getSecurityContext(),
																											onComplete : function(output) {
																												xNotificationsUtil.showSuccess(DOC_NLS.DOC_File_upload_success);
																												progressbarUpload.value = 100;
																												document.getElement('.progressupload').remove();
																												that.render(that);
																											},
																											onFailure : function(result) {
																												xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
																												document.getElement('.progressupload').remove();
																												that.render(that);
																											}
																										});
																									}

																									else {
																										var documentInfo = {
																											id : documentId,
																											fileInfo : {
																												file : fileObject
																											},
																											newFile : false
																										};
																										var iOptions = {
																											onComplete : function(output) {
																												xNotificationsUtil.showSuccess(DOC_NLS.DOC_File_upload_success);
																												progressbarUpload.value = 100;
																												document.getElement('.progressupload').remove();
																												that.render(that);
																											},
																											onFailure : function(result) {
																												xNotificationsUtil.showError(DOC_NLS.DOC_Files_Upload_Error.substr(0, DOC_NLS.DOC_Files_Upload_Error.lastIndexOf(':')));
																												document.getElement('.progressupload').remove();
																												that.render(that);
																											}
																										};

																										DocumentManagement.modifyDocument(documentInfo, iOptions);
																									}
																								} else {
																									xNotificationsUtil.showError(DOC_NLS.DOC_Legacy_File_upload_Error);
																									document.getElement('.progressupload').remove();
																									that.render(that);
																								}
																							}
																							else {
																								xNotificationsUtil.showError(DOC_NLS.DOC_UNRESERVE_MESSAGE_USER+output.data['0'].dataelements.reservedby);
																								document.getElement('.progressupload').remove();
																								that.render(that);
																							}
																						},
																						onFailure : function(result) {
																							xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
																							document.getElement('.progressupload').remove();
																							that.render(that);
																						}
																					};
																					var docIdsArr = Array.isArray(documentId) ? documentId : [ documentId ];
																					DocumentManagement.getDocuments(docIdsArr, optionsDoc);
																				}
																				else {
																					xNotificationsUtil.showError(DOC_NLS.DOC_Document_upload_Error);
																					that.render(that);
																				}
																			},
																			isSearcSelectedTypeValid : function(selectedItems){
																				var that = this;
																				var searcSelectedTypeValid = true;
																				for (var i = 0; i < selectedItems.length; i++) {
																					var selectType = selectedItems[i];
																					if (selectType.objectType ==  this.documentSearchTypes || selectType['ds6w:type'] == this.documentSearchTypes){
																						continue;
																					}
																					else {
																						searcSelectedTypeValid = false;
																						break;
																					}
																				}
																				return searcSelectedTypeValid;
																			},
																			connectDocumentToParent : function(documentId, parentId, selectedItems,
																				showAlertMessage) {
																					var that = this;
																					that.selectedItems = selectedItems;
																					var parentRel = this.docRelsArray[0];
																					if (that.isSearcSelectedTypeValid(selectedItems)){
																						Mask.mask(that.container);
																						var documentInfo = {
																							securityContext : xPortfolioInfra.getSecurityContext(),
																							additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																							relInfo : {
																								parentId : parentId,
																								parentRelName : parentRel
																							},
																							onComplete : function(output) {
																								that.connectDocumentToParentOnComplete(output, parentId, showAlertMessage);
																							},
																							onFailure : function(result) {
																								that.connectDocumentToParentOnFailure(result, showAlertMessage);
																							}
																						};

																						DocumentManagement.connectDocumentToParent(documentId, documentInfo);
																					}
																					else {
																						Mask.unmask(that.container);
																						that.dropInvite = that.container.getElement('#droppable');
																						that.dropInvite.addClassName('hidden');
																						that.dropInvite.addClassName('fileDrop');
																						that.dropInvite.removeClassName('show');
																						that.dropInvite.removeClassName('droppable');
																						if (showAlertMessage){
																							xNotificationsUtil.showError(DOC_NLS.DOC_AddExisting_NotDocumentType_Error);
																						}
																					}
																				},
																				connectDocumentToParentOnFailure: function(result, showAlertMessage){
																					var that  = this;
																					if (showAlertMessage) {
																						Mask.unmask(that.container);
																						that.dropInvite = that.container.getElement('#droppable');
																						that.dropInvite.addClassName('hidden');
																						that.dropInvite.addClassName('fileDrop');
																						that.dropInvite.removeClassName('show');
																						that.dropInvite.removeClassName('droppable');
																						if (result.internalError.lastIndexOf('Message:A') !=-1){
																							xNotificationsUtil.showError(DOC_NLS.DOC_ERROR_ALREADY_CONNECTED);
																						}
																						else {
																							xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
																						}
																					}
																				},
																				connectDocumentToParentOnComplete : function(output, parentId, showAlertMessage){
																					var that = this;
																						var data = output.data;
																						if (data) {
																							documentId = data[0].id;

																							if (UWA.is(data, 'array')) {
																								data = data[0];
																							}
																							var createdObject = {
																								'@id' : that.selectedItems['0'].id,
																								'@attributes' : {
																									parentId : parentId,
																									'attr_name' : that.selectedItems['0']['ds6w:identifier_value'],
																									'attr_title' : that.selectedItems['0']['ds6w:label_value'],
																									'attr_version' : that.selectedItems['0']['ds6wg:minorrevision'],
																									'attr_type' : that.selectedItems['0']['ds6w:type_value'],
																									'attr_rel' : that.docRels,
																									'attr_image' : that.selectedItems['0']['type_icon_url_value']
																								}
																							};
																							if (showAlertMessage) {
																								xNotificationsUtil.showSuccess(DOC_NLS.DOC_ADD_SUCCESS);
																							}
																							that.updateDocumentTable(createdObject, 'AddExisting');
																						}
																				},
																				createDocument : function(parentId, title, docText, file,
																					showAlertMessage) {
																						var that = this;
																						var documentId = '';
																						var policy = '';
																						var type = '';
																						type = this.getDocTypeFromDocText(docText);
																						relType = this.getDocRelTypeFromDocText(docText);
																						policy = this.getDocPolicyTypeFromDocText(docText);
																						Mask.mask(that.container);
																						var documentInfo = {
																							title : title,
																							type : type,
																							policy : policy,
																							relInfo : {
																								parentId : parentId,
																								parentRelName : relType
																							}
																						};

																						if (file!= undefined){
																							documentInfo.fileInfo = {file : file};
																						}
																						if (xPortfolioInfra.getSecurityContext() != ''){
																							DocumentManagement.createDocument(
																								documentInfo,
																								{
																									securityContext : xPortfolioInfra.getSecurityContext(),
																									additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
																									onComplete : function(output) {
																										that.createDocumentOnComplete(output, parentId, showAlertMessage);
																									},
																									onFailure : function(result) {
																										that.createDocumentOnFailure(result, showAlertMessage);
																									}
																								});
																							}
																						},
																						createDocumentOnFailure : function(result, showAlertMessage){
																							var that  = this;
																							Mask.unmask(that.container);
																							if (showAlertMessage) {
																								if (result.internalError != undefined){
																									xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
																								}
																								else {
																									xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.error));
																								}
																							}
																						},
																						createDocumentOnComplete :  function(output, parentId, showAlertMessage){
																							var  that = this;
																							var data = output.data;
																							if (data) {
																								documentId = data[0].id;
																								if (data[0].dataelements['title'] == ''){
																									var documentInfo = {
																										id : documentId,
																										title : data[0].dataelements['name']
																									};
																									var iOptions = {
																										onComplete : function(output) {
																										},
																										onFailure : function(result) {
																										}
																									};
																									DocumentManagement.modifyDocument(documentInfo, iOptions);
																								}
																								// end
																								if (UWA.is(data, 'array')) {
																									data = data[0];
																								}
																								var createdObject = {
																									'@id' : data.id,
																									'@attributes' : {
																										parentId : parentId,
																										'attr_name' : data.dataelements['name'],
																										'attr_title' : data.dataelements['title'] ? data.dataelements['title']: data.dataelements['name'],
																										'attr_version' : '0',
																										'attr_revision' : data.dataelements['revision'],
																										'attr_type' : data.type,
																										'attr_rel' : that.docRels,
																										'attr_image' : data.dataelements['image']
																									}
																								};
																								that.updateDocumentTable(createdObject, 'Add');
																								if (showAlertMessage) {
																									Mask.unmask(that.container);
																									xNotificationsUtil.showSuccess(DOC_NLS.DOC_CREATE_SUCCESS);
																								}
																							}
																						},
																						publishTags : function(){
																							var OIdsList = [];
																							for (var i=0; i<this.tablePresenter.options.dictionaryJSON.length; i++){
																								OIdsList.push(this.tablePresenter.options.dictionaryJSON[i].id);
																							}
																							if (OIdsList.length == 0){
																								this.clearTags();
																							} else {
																								this._initTagger(OIdsList);
																							}
																						},

																						clearTags : function(){
																							this._TaggerOnIndexComponent.killTagProxy(this._idProxy);
																						},
																						_initTagger : function(tagPIds){
																							var that = this;
																							var onFilterChange = function(eventData){
																								that.onFilterChangeEvent(eventData);
																							};
																							var tagOption = {
																								onTagFilterChange : onFilterChange,
																								MyFriends : this.tagFriends
																							};
																							that._TaggerOnIndexComponent.setTagProxy(that._idProxy, tagOption, tagPIds);
																						},
																						onFilterChangeEvent : function(eventData){
																							var that = this;
																							if (that.tablePresenter){
																								that.tablePresenter.publishViewEvent('onContentFilterCriteriaChange', {
																									filterData: {TaggerValues:eventData.filteredSubjectList}
																								});
																							}
																						},
																						getTagProxy : function(idProxy){
																							return this._TaggerOnIndexComponent.getTagProxy(idProxy).getCurrentFilter();
																						},
																						// utility method to register to an event (event name) with the callback
																						_registerToEvent : function(event, callback) {
																							this._applicationChannel.subscribe({
																								event : event
																							}, callback);
																						},
																						tagInit : function(idProxy, parentUpdateChannel, options){
																							this._TaggerOnIndexComponent = TaggerOnIndexComponent;
																							this.tagFriends = options.tagFriends;
																							this._CSearch = [];
																							this._idProxy = idProxy;
																							options.filters = options.filters?options.filters:[];
																						},
																						_subscribeToEvents : function(){
																							var that = this;
																							PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh', function(eventData){
																								var modifiedObjIds = eventData ? (eventData.data ? (eventData.data.authored ? (eventData.data.authored.modified ? eventData.data.authored.modified: []): []): []) : [];
																								modifiedObjIds.forEach(function(docId){
																									if (docId) {
																										that._internalChannel.publish({event: 'enoxdoc-refresh-item', data : docId });
																									}
																								});
																							});

																							that._internalChannel.subscribe({event: 'refresh-tag-on-filter'},function(data){
																								var subjectDB=data;
																								var idTagProxy=widget.id+'-ItemsCommonProxy';
																								var extraData=undefined;
																								// TaggerOnIndexComponent.killAllTagProxy();
																								// that._initTagger(subjectDB);
																								that._TaggerOnIndexComponent.filterTags(that._idProxy, subjectDB);

																						});
																						},
																						addExistingDocumentsSearch : function(){
																							var  that = this;
																							var optionsDoc = {
																								relInfo : {
																									parentId : that.modelId,
																									parentRelName : that.getDocRelTypeFromDocType(that.documentSearchTypes.toString())
																								},
																								getVersions : true,
																								onComplete : function(output) {
																									that.onSuccess_addExistingDocumentsSearch(output);
																								}
																							};
																							DocumentManagement.getDocumentsFromParent(optionsDoc);
																						},
																						onSuccess_addExistingDocumentsSearch :  function(output){
																							var that = this;
																							var data = output.data;
																							var excludeStringVal = '';
																							for (var i=0; i<data.length; i++){
																								var tempid = data[i].id;
																								excludeStringVal = excludeStringVal +' '+ 'NOT (physicalid:'+tempid+')';
																							}
																							DocumentSearchController.addExistingDoc(that, excludeStringVal);
																						},
																						xhronprogressEvent :function(progressbar, event){
																							if (event.lengthComputable) {
																								var percentComplete = (event.loaded / event.total)*100;
																								if (percentComplete!=100){
																									progressbar.value = percentComplete;
																								}
																							}
																							else {
																								progressbar.value = 10;
																							}
																						}
																					});
																				});
