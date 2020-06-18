/*XSS_CHECKED*/
define(
	'DS/ENOXDocumentCockpit/js/FilesTableMainContainer',
	[   'UWA/Class/View',
        'UWA/Class/Collection',
		'DS/DataDragAndDrop/DataDragAndDrop',
		'DS/W3DXComponents/Views/Layout/ActionsView',
		'DS/W3DXComponents/Collections/ActionsCollection',
		'DS/Core/ModelEvents', 'DS/ENOXDocumentCockpit/js/FilesTablePresenter',
		'DS/ENOXDocumentCockpit/js/util/DocCockpitCommonUtils',
		'DS/UIKIT/Iconbar',
        'DS/UIKIT/Dropdown',
		'DS/ENOXCollectionToolBar/js/ENOXCollectionToolBar',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Input/Button',
		'DS/DocumentManagement/DocumentManagement',
		'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
		'DS/xPortfolioQueryServices/js/infra/xPortfolioInfra',
		'DS/ResizeSensor/js/ResizeSensor',
		'DS/WildcardSearchComponent/WildcardSearchComponent',
		'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
		'text!DS/ENOXDocumentCockpit/assets/DataGridColumnAttributeMapping.json',
		'i18n!DS/ENOXDocumentCockpit/assets/nls/DocumentCockpit',
		'css!DS/UIKIT/UIKIT.css', 'css!DS/ENOXDocumentCockpit/css/DocumentDetails.css'
	],

	function (View, _uwa_Collection, DataDragAndDrop, ActionsView,
		ActionsCollection, ModelEvents, FilesTablePresenter, DocCockpitCommonUtils, Iconbar,
		Dropdown, ENOXCollectionToolBar, Mask, Button, DocumentManagement, xNotificationsUtil, xPortfolioInfra, ResizeSensor, WildcardSearchComponent, i3DXCompassPlatformServices, _text_ColAttrbMap, Document_NLS) {
	'use strict';

	/*
	 * TODO: 1. Touch Enable 2. Model Events/Event Management 3.
	 */

	var DEBUG_FLAG = false;
	// Reading column & corresponding attribute's map (defined as JSON). This
	// wiil help to configure no. of columns.
	var colAttrbMap = JSON.parse(_text_ColAttrbMap);

	// Main Container//
	var itemsMultiPresenter = View
		.extend({

			className: 'doc-cockpit-criteria-selector-container',

			init: function (options) {
				var that = this;

				options = options ? options : {};
				// this._containerModelEvents = new ModelEvents();

				this._currSearchText = "";
				this.searchOptions = {};
				this.WildcardSearch = new WildcardSearchComponent();

				this.showCloseAction = false;
				this.showSwitchViewAction = false;
				this.showSortAtion = false;
				this.showKpiAction = false;
				this.actions = [];
				this.itemActions = [{
						title: 'Add',
						fonticon: 'plus',
						'event': 'onAddAction',
					}
				];
				if (options.showCloseAction == true) {
					this.showCloseAction = true;
				}
				if (options.showSwitchViewAction == true) {
					this.showSwitchViewAction = true;
				}
				if (options.showSortAtion == true) {
					this.showSortAtion = true;
				}
				if (options.actions) {
					this.actions = options.actions;
				}
				if (options.itemActions) {
					this.itemActions = options.itemActions;
				}
				if (options.title) {
					this.title = options.title;
				}

				this.kind = options.kind ? options.kind : 'reference';

				//var columns = colAttrbMap['Columns'];
				var columns = options._filesPresenter.options['Columns-Data'].Columns;

				var contentOptions = {
					contentTreeOptions: {
						viewIdentifier: 'table',
						isEditable: true,
						columns: columns,
						resize: {
							rows: false,
							columns: true,
						},

						selectionData: {
							totalCount: 0,
							displayCount: 0,
							selectionCount: 0
						}, // whether to pass on data or not? manage by event
						countParentSelection: false,
					}
				};

				var commonOptions = {
					// collection : (options.collection ? options.collection : new
					// _uwa_Collection()), //Empty Collection.
					// dictionaryJSON : options.dictionaryJSON,
					dataJSON: options.dataJSON,
					kind: this.kind,
					_containerInstance: this,
					// getParentWithChild : true,
					// getAllChildrenOnParentSelection: true,
					// getParentOnChildSelection: true,
					// countParentSelection: false,
					// _parentModelEvents: this._containerModelEvents,
					// TODO: Multi actions support, hence taken it as an array
					actions: this.itemActions,
					// [{
					// title: 'Add',
					// fonticon: 'plus',
					// event: 'onAddAction',
					// },
					// {
					// title: 'Delete',
					// fonticon: 'trash',
					// event: 'onDeleteAction',
					// },
					// {
					// title: 'Open',
					// fonticon: 'folder',
					// event: 'onOpenAction',
					// }
					// ],
					contentFilter: options.contentFilter
				};

				this.contentViews = [{
						id: 'table',
						view: FilesTablePresenter,
						options: UWA.merge(contentOptions, commonOptions)
					}
				];

				this._initActionbarOptions();
				this._parent(options);
			},

			_initActionbarOptions: function () {
				this._actionbarOptions = {
					showItemCount: true,
					searchOptions: {
						layout: 'inline',
						enableCache: true,
						allowMultipleSearch: true,
						attributeFilter: [{
								"id": "files",
								"text": "File Name",
								"selected": true
							}, ],
					},
					actions: [
					],
				};

				if (this.actions) {
					this._actionbarOptions.actions = this.actions;
				}
			},

			render: function (_filesPresenter) {
				var that = this;
				if (this.title && this.title.trim().length != 0) {
					var titleSection = UWA.createElement('div', {
							html: this.title,
							styles: {
								fontFamily: 'Comic Sans MS',
								fontSize: '16px',
								color: '#77797c',
								margin: '5px 0 3px 8px',
								fontWeight: 'normal'
							}
						});
					titleSection.inject(this.container);
				}
				// headerControlsSection.call(this, this.options);
				var headerSection = this.buildFilterHeaderSection();
				headerSection.inject(this.container);

				this._stdActionbar._modelEvents.subscribe({ event: 'enox-collection-toolbar-filter-search-value'}, function (data) {
					if(that.options.dataJSON.relateddata.files){
						var idList = convertToSearchData(that.options.dataJSON.relateddata.files);
							if (idList.length>0)
								that.WildcardSearch.search(data.searchValue[0],idList,ContextSearchCB);
					}
				});

				_filesPresenter._globalapplicationChannelForDocPresenter.subscribe({
					event: 'search-in-current-dashboard'
				}, function (data) {
						if(that.options.dataJSON.relateddata.files){
						var idList = convertToSearchData(that.options.dataJSON.relateddata.files);
							if (idList.length>0)
								that.WildcardSearch.search(data,idList,GlobalSearchCB);
					}
				});

				// TJX : search integration start

				var ContextSearchCB = function(result){
					var resultListIds = [];
					for (var i=0; i<result.length; i++){
						resultListIds.push(result[i].id);
					}
				//	if (that && resultListIds.length>1){
							that.publishViewEvent('onContentFilterCriteriaChange', {
												'filterData': {'ContextSearchValues':resultListIds}
										});
					//	}
				};
				var GlobalSearchCB = function (result) {
					var resultListIds = [];
					for (var i = 0; i < result.length; i++) {
						resultListIds.push(result[i].id);
					}
					that.publishViewEvent('onContentFilterCriteriaChange', {
						'filterData': {
							'GlobalSearchValues': resultListIds
						}
					});
					//	}
				};
				var convertToSearchData = function (data) {
					var OIdsList = [];

					for (var i = 0; i < data.length; i++) {
						var element = {};
						var versions = '';
						element.id = data[i].id;
						for (var property in data[i].dataelements) {
							if (property == 'title') {
								var titleValue = data[i].dataelements[property].toLocaleLowerCase();
								element[property] = titleValue;
							}
						}
						OIdsList.push(element);
						versions = UWA.is(data[i].relateddata.versions, 'array') ? data[i].relateddata.versions
							 : false;
							 if(versions && versions.length>0 )
							 {
								 	for(var j=0;j<versions.length;j++){
										var var_element = {};
										 var_element.id=versions[j].id;
										 for (var property in versions[j].dataelements) {
											 if (property == 'title') {
												 var titleValue = versions[j].dataelements[property].toLocaleLowerCase();
												 var_element[property] = titleValue;
											 }
										 }
										 OIdsList.push(var_element);
									 	}
									}
								}
					return OIdsList;
				};

				this.contentSection = this.buildContentView();
				this.contentSection.inject(this.container);
				this.initializeContentViews();

				this.subscribe('loading-view-start', function () {
					that.maskContent();
					//	that.options._filesPresenter.attachResizeSensor();
				});
				this.subscribe('loading-view-complete', function () {
					that.unMaskContent();
				});
				this.switchView('table');
				return this;
			},

			// viewFilterer : function(filterData) {
			// this.publishViewEvent('onContentFilterCriteriaChange', {
			// 'filterData': filterData
			// });
			// console.log("View Filterer!!!");
			// },

			// viewSorter : function(sortData) {
			// console.log("View Sorter!!!");
			// },

			buildFilterHeaderSection: function () {
				var that = this;
				var headerSection = UWA.createElement('div', {
						id: 'headerCtrlSection',
						'class': 'header-ctrl-section'
					});

				this._actionbarOptions.parentContainer = headerSection;

				// Set Event handlers.
				this._actionbarOptions.onSwitch = function () {
					that.switchView.apply(that, arguments);
				};
				this._actionbarOptions.onSearch = function (filterData) {};
				// this._actionbarOptions.onSort = this.viewSorter;

				this._stdActionbar = new ENOXCollectionToolBar(this
						._getCollectionToolbarOptions());
				this._stdActionbar.inject(this._actionbarOptions.parentContainer);
				return headerSection;
			},

			_getCollectionToolbarOptions: function () {
				var collectionToolbarOptions = this._actionbarOptions ? this._actionbarOptions
					 : {};

				UWA.merge(collectionToolbarOptions, {
					withmultisel: false,
					showItemCount: true,
					filter: {},
					actions: [],
					sort: [
						// {id : "Title", text : "Title", type : "string" },
						// {id : "Type",text: "Type", type : "string" },
						// {id : "Version", text : "Version", type : "integer" },
						// {id : "Maturity", text : "Maturity", type : "string"}
					],
					views: []
				});

				return collectionToolbarOptions;
			},

			buildContentView: function () {
				var options = this.options;
				var contentSection = UWA.createElement('div', {
						id: 'contentSection',
						'class': 'content-section1'
					});

				return contentSection;
			},

			initializeContentViews: function () {
				if (this.options.dataJSON.id) {
					var docId = this.options.dataJSON.id;
					var docContainerContext = this;
				}
				if (this.contentViews && this.contentViews.length > 0
					 && this.options.dataJSON.relateddata.files.length > 0) {
					this._contentViews = {};
					var that = this;
					this.contentViews.forEach(function (contentView, index) {
						var options = contentView.options ? contentView.options : {};
						var view = new contentView.view(options);
						if (index == 0) {
							that._contentViews.currentView = contentView.id;
							that._contentViews.view = {};
						}
						that._contentViews.view[contentView.id] = view;

						// Not very good way!!! But for demo its ok.
						view.subscribe('onDisplayAndSelCountUpdate', function (data) {
							that._stdActionbar._modelEvents.publish({
								event: 'enox-collection-toolbar-items-count-update',
								data: data.displayCount
							});
						});

						view.render();
					});
				} else {
					Mask.unmask(this.container);
					this.createEmptyFileContainer(this.container, this.options._filesPresenter);

					var emptyContainerRef = this.container.getElement('#drop-inviteForFiles');
					DocCockpitCommonUtils.makeDroppable(emptyContainerRef, Document_NLS.DOC_Uploading_Page, function (e) {
						var that = this;
						if (e.preventDefault) {
							e.preventDefault();
						}
						if (e.dataTransfer != undefined && e.dataTransfer.files.length == 1) {
							that.dropInvite = emptyContainerRef.getElement('#droppable');
							that.dropInvite.addClassName('hidden');
							that.dropInvite.addClassName('fileDrop1');
							that.dropInvite.removeClassName('show');
							that.dropInvite.removeClassName('droppable1');
							console.log('Upload file scucess' + e.dataTransfer.files);
							//Mask.mask(docContainerContext.options._filesPresenter.container);
							docContainerContext.uploadDocument(docId, e.dataTransfer.files);
							//		DocumentCreateForm.createDocumentForm(DocumentPresenter,e.dataTransfer.files);
						} else {
							xNotificationsUtil.showError(Document_NLS.DOC_Multi_Files_Selected);
							this.createEmptyFileContainer(this.container, this.options._filesPresenter);
						}
					});
				}
			},

			createEmptyFileContainer: function (container, FilesPresenter) {
				var that = this;
				var emptySection = UWA.createElement('div', {
						id: 'drop-inviteForFiles',
						'class': "emptyContainerStyleForFiles",
						html: '',
					});
				var childSection1 = UWA.createElement('div', {
						id: 'childSection1',
					});
				var childSection2 = UWA.createElement('div', {
						id: 'childSection2',
					});
				var childSection3 = UWA.createElement('div', {
						id: 'childSection3',
					});
				var childSection4 = UWA.createElement('div', {
						id: 'childSection4',
					});
				var emptySectionSpan = UWA.createElement('span', {
						//	id : 'UploadConten_section_1'
						html: Document_NLS.DOC_Uploading_Page,
					});
				var emptySectionSpan1 = UWA.createElement('span', {
						html: "---------------------- " + Document_NLS.DOC_Uploading_Page_Or + " ----------------------",
					});
				var emptySectionImg = UWA
					.createElement(
						'div', {
						'class': 'empty-view-icon empty-view-icon center-block fonticon fonticon-5x fonticon-drag-drop',
						html: '',
						// styles : {width:'-webkit-fill-available','text-align' : 'center'}
					});
				var emptySectionP1 = UWA.createElement('p', {});
				var emptySectionP2 = UWA.createElement('p', {});
				var emptySectionP3 = UWA.createElement('p', {});
				var emptySectionSpan3 = new Button({
						value: Document_NLS.DOC_Empty_Container_Browse,
						// className: "Upload Content",
						onCompleteCallback: function (successCallBack) {},
						onFailureCallback: function (errDetailds, errData) {},
					});
				emptySectionSpan3.elements.input.onclick = function () {
					//Mask.mask(FilesPresenter.container);
					FilesPresenter.uploadFiles(FilesPresenter);
					return emptySectionSpan3;
				},

				childSection1.appendChild(emptySectionImg);
				childSection1.appendChild(emptySectionP1);
				childSection2.appendChild(emptySectionSpan);
				//emptySection1.appendChild(emptySectionSpan);
				childSection2.appendChild(emptySectionP2);
				childSection3.appendChild(emptySectionSpan1);
				childSection3.appendChild(emptySectionP3);
				emptySectionSpan3.inject(childSection4);
				emptySection.appendChild(childSection1);
				emptySection.appendChild(childSection2);
				emptySection.appendChild(childSection3);
				emptySection.appendChild(childSection4);
				emptySection.inject(container);
			},

			switchView: function (viewId) {
				if (this._contentViews) {
					// var id = this._contentViews.currentView;
					this.contentSection.setContent(this._contentViews.view[viewId]);
					this._contentViews.currentView = this._contentViews.view[viewId];
				}
			},

			// Publishes the event on the available views.
			publishViewEvent: function (eventName, data) {
				if (this._contentViews) {
					for (var id in this._contentViews.view) {
						// if viewstoskip is undefined or if current view is not to be skipped
						// then publish event.
						if (!(data.eventOrigin && id === data.eventOrigin)) {
							var view = this._contentViews.view[id];
							if (UWA.is(view.publish, 'function') /* && view !== data.context */) {
								view.publish(eventName, data, view);
							}
						}
					}
				}
			},

			// Subscribes events from Views and calls the specified callback.
			subscribeViewEvent: function (eventName, callback) {
				if (this._contentViews) {
					for (var viewId in this._contentViews.view) {
						var view = this._contentViews.view[viewId];
						if (UWA.is(view.subscribe, 'function') && UWA.is(callback, 'function')) {
							view.subscribe(eventName, callback);
						}
					}
				}
			},

			// unsubscribeAllViewEvent: function (eventName) {
			// 	if (this._contentViews) {
			// 		for (var viewId in this._contentViews.view) {
			// 			var view = this._contentViews.view[viewId];
			// 			if (UWA.is(view.unsubscribeAll, 'function')) {
			// 				view.unsubscribeAll(eventName);
			// 			}
			// 		}
			// 	}
			// },

			// APIs and Events
			subscribe: function (event, callback) {
				this.subscribeViewEvent(event, callback);
			},

			// unsubscribeAll: function (eventName) {
			// 	this.unsubscribeAllViewEvent(eventName);
			// },

			// changeView: function (viewId) {
			// 	this.switchView(viewId);
			// },

			maskContent: function () {
				Mask.mask(this.container);
			},

			unMaskContent: function () {
				Mask.unmask(this.container);
			},

			// showAttribute: function (attribute) {
			// 	// TODO
			// 	this.publishViewEvent('showAttribute', {
			// 		attribute: attribute
			// 	});
			// },

			// hideAttribute: function (attribute) {
			// 	// TODO
			// 	this.publishViewEvent('hideAttribute', {
			// 		attribute: attribute
			// 	});
			// },

			sortBy: function (attribute, isAccending) {
				// TODO
				this.publishViewEvent('sortBy', {
					attribute: attribute,
					isAccending: isAccending
				});
			},

			uploadDocument: function (documentId, files) {
				var that = this;
				var docFileName = '';
				var fileLength = undefined;
				var loggedInUser = '';
				var owner = that.options.dataJSON.relateddata.ownerInfo[0].dataelements['name'];
				var fileContainer = that.options._filesPresenter.container;
				fileLength = that.options.dataJSON.relateddata.files.length;
					Mask.mask(fileContainer);
				if (fileLength > 1) {

					xNotificationsUtil.showError(Document_NLS.DOC_Multi_Files);
					Mask.unmask(fileContainer);

				}
				 else {
					var optionsDoc = {

						onComplete: function (output) {
							if (undefined != output.data["0"].relateddata.files["0"]) {
								if (output.data["0"].relateddata.files.length > 1) {
									docFileName = undefined;
								} else {
									docFileName = output.data["0"].relateddata.files["0"].dataelements.title;
								}
							}
							var fileObject = files[0];
							if (docFileName == '') {
								DocumentManagement.addFileToDocument({
									id: documentId,
									fileInfo: {
										file: fileObject
									}
								}, {
									securityContext: xPortfolioInfra.getSecurityContext(),
									onComplete: function (output) {
										Mask.unmask(fileContainer);
										var docOpt = {
											getVersions: true,
											onComplete: function (output) {
												var data = output.data;
												if (data) {
													if (UWA.is(data, 'array')) {
														data = data[0];
													}
												}
												that.options._filesPresenter.render(data);
												xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_Upload_Success);

											},
											onFailure: function (output) {},
										};
										DocumentManagement.getDocuments([documentId], docOpt);
										//	xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_Upload_Success);
									},

									onFailure: function (result) {
										Mask.unmask(fileContainer);
										xNotificationsUtil.showError(Document_NLS.DOC_Files_Upload_Error);
									}
								});
							} else if (docFileName) {
								var documentInfo = {
									id: documentId,
									fileInfo: {
										file: fileObject
									},
									newFile: false
								};
								var iOptions = {
									onComplete: function (output) {
										Mask.unmask(fileContainer);
										var docOpt = {
											getVersions: true,
											onComplete: function (output) {
												var data = output.data;
												if (data) {
													if (UWA.is(data, 'array')) {
														data = data[0];
													}
												}
												that.options._filesPresenter.render(data);
												xNotificationsUtil.showSuccess(Document_NLS.DOC_Files_Upload_Success);

											},
											onFailure: function (output) {},
										};
										DocumentManagement.getDocuments([documentId], docOpt);
									},
									onFailure: function (result) {
										Mask.unmask(fileContainer);
										xNotificationsUtil.showError(Document_NLS.DOC_Files_Upload_Error);
									}
								};

								DocumentManagement.modifyDocument(documentInfo, iOptions);
							} else {
								xNotificationsUtil.showError(Document_NLS.DOC_REMOVE_FILE);
								Mask.unmask(fileContainer);
							}

						},
						onFailure: function (result) {
							xNotificationsUtil.showError(Document_NLS.DOC_Files_Upload_Error);
							Mask.unmask(fileContainer);
						}
					};
					var docIdsArr = Array.isArray(documentId) ? documentId : [documentId];
					DocumentManagement.getDocuments(docIdsArr, optionsDoc);
				}
			},

		});
	return itemsMultiPresenter;
});
