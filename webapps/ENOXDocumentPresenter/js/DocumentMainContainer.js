/*XSS_CHECKED*/
define(
		'DS/ENOXDocumentPresenter/js/DocumentMainContainer',
		[ 'UWA/Class/View',
				'DS/Core/ModelEvents',
				'DS/ENOXDocumentPresenter/js/DocumentTablePresenter',
				'DS/DocumentManagement/DocumentManagement', 'DS/UIKIT/Mask',
				'DS/ENOXCollectionToolBar/js/ENOXCollectionToolBar',
				'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
				'DS/ENOXDocumentPresenter/js/util/DocumentCommonUtils',
				'DS/ENOXDocumentPresenter/js/util/DocumentCreateForm',
				'DS/ENOXDocumentPresenter/js/util/DocumentSearchController',
				'DS/TaggerOnIndexComponent/TaggerOnIndexComponent',
				'DS/WildcardSearchComponent/WildcardSearchComponent',
				'DS/UIKIT/Input/Button',
				'i18n!DS/ENOXDocumentPresenter/assets/nls/DocumentsPresenter',
				'css!DS/UIKIT/UIKIT.css'],

		function(View, ModelEvents, DocumentTablePresenter,
				DocumentManagement, Mask, ENOXCollectionToolBar,
				xNotificationsUtil, DocumentCommonUtils, DocumentCreateForm, DocumentSearchController, TaggerOnIndexComponent, WildcardSearchComponent, Button, DOC_NLS, _css_uikit) {
			'use strict';

			var itemsMultiPresenter = View.extend({

						className : 'document-criteria-selector-container',

						init : function(options) {
							var that = this;

							options = options ? options : {};

							for (var i = 0; i < options.columns.length; i++) {
								var isSelectionColumn = options.columns[i];
								if (isSelectionColumn.dataIndex == 'selection') {
									options.columns.splice(0, 1);
								}
							}

							this._currSearchText = '';
							this.searchOptions = {};
							this.modelId = options.modelId;

							this.showCloseAction = false;
							this.showSwitchViewAction = false;
							this.showSortAtion = false;
							this.showKpiAction = false;
							this.actions = [];
							this.itemActions = [ {
								title : 'Add',
								fonticon : 'plus',
								event : 'onAddAction'
							} ];
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
								this.actions = that.enableOrDisableActionCommands(options.actions, options.docOptions);
							}
							if (options.itemActions) {
								this.itemActions = that.enableOrDisableContextCommands(options.itemActions, options.docOptions);
							}
							if (options.title) {
								this.title = options.title;
							}
							this._bridgeModelEvent = new ModelEvents();
							var columns = options.columns;

							var contentOptions = {
								contentTreeOptions : {
									viewIdentifier : 'table',
									isEditable : true,
                                    allowUnsafeHTMLContent : true,
									columns : columns,
									resize : {
										rows : false,
										columns : true
									},
									selectionData : {
										totalCount : 0,
										displayCount : 0,
										selectionCount : 0
									},
									countParentSelection : false
								}
							};

							var commonOptions = {
								dictionaryJSON : options.dictionaryJSON,
								getAllChildrenOnParentSelection : true,
								getParentOnChildSelection : true,
								countParentSelection : false,
								actions : this.itemActions,
								contentFilter : options.contentFilter,
								modelId : options.modelId,
								mainContainerInstance : this
							};

							this.contentViews = [ {
								id : 'table',
								view : DocumentTablePresenter,
								options : UWA.merge(contentOptions, commonOptions)
							} ];

							this._initActionbarOptions();
							this._parent(options);
						},

						_initActionbarOptions : function() {
							this._actionbarOptions = {
								showItemCount : true,
                                allowUnsafeHTMLContent : true,
								searchOptions : {
									layout : 'inline',
									enableCache : true,
									allowMultipleSearch : true,
									attributeFilter : [ {
										id : 'title',
										text : 'Title',
										selected : true
									}, {
										id : 'type',
										text : 'Type',
										selected : false
									}, {
										id : 'description',
										text : 'Description',
										selected : false
									} ]
								},
								actions : []
							};

							if (this.showSortAtion) {
								this._actionbarOptions.sortOptions = {
									attributes : [ {
										id : 'title',
										text : 'Title',
										selected : false
									} ],
									order : 'ASC'
								};
							}

							if (this.showSwitchViewAction) {
								this._actionbarOptions.switchViews = [ {
									id : 'table',
									text : 'Table',
									fonticon : 'view-list',
									selected : false
								} ];
							}

							if (this.actions) {
								this._actionbarOptions.actions = this.actions;
							}
						},
						enableOrDisableContextCommands : function(action, that){
							var optionsEnableAdd  =that.options.actions['enable-add'];
							var optionsEnableCreate  =that.options.actions['enable-create'];
							var optionsEnableRemove  =that.options.actions['enable-remove'];
							var optionsEnableReserve  =that.options.actions['enable-reserve'];
							var optionsEnableUnreserve  =that.options.actions['enable-unreserve'];
							var optionsEnableModify  =that.options.actions['enable-update'];
							var result = [];
							for (var i = 0; i < action.length; i++) {
								result[i] = action[i];
							}
							if (action instanceof  Array) {
								for (var i = 0; i < action.length; i++) {
									var element = action[i];
											if (element.id == 'delete' || element.id == 'remove'){
												if (optionsEnableRemove == false){
														result.splice(this.getIndexedObjForRemove(element.id, result), 1);
												    }
											}
											if (element.id == 'information' || element.id == 'upload'	){
												if (optionsEnableModify == false){
															result.splice(this.getIndexedObjForRemove(element.id, result), 1);
														}
											}
											if (element.id == 'reserve'){
												if (optionsEnableReserve == false){
														result.splice(this.getIndexedObjForRemove(element.id, result), 1);
													}
											}
											if (element.id == 'unreserve'){
												if (optionsEnableUnreserve == false){
														result.splice(this.getIndexedObjForRemove(element.id, result), 1);
													}
											}
								}
							}
							return result;
						},
						getIndexedObjForRemove: function(key, result){
								for (var i = 0; i < result.length; i++) {
									var keyId = result[i].id;
									if (keyId == key){
										return i;
									}
								}
						},
						enableOrDisableActionCommands : function(action, that){
							var optionsEnableAdd  =that.options.actions['enable-add'];
							var optionsEnableCreate  =that.options.actions['enable-create'];
							var optionsEnableRemove  =that.options.actions['enable-remove'];
							var optionsEnableReserve  =that.options.actions['enable-reserve'];
							var optionsEnableUnreserve  =that.options.actions['enable-unreserve'];
							var optionsEnableModify  =that.options.actions['enable-update'];
							var result = action;
							var deleteIndexArr =[];
							if (action instanceof  Array) {
								const actionIndex = action.length;
								for (var k = 0; k < actionIndex; k++) {
									var element = action[k];
									if (element.content!=undefined){
										const resultIndex = element.content.length;
											for (var j = 0; j < resultIndex; j++) {
													if (optionsEnableCreate == false)
															{
																var objToRemove = result[k].content.find(
																	function (obj) {
																		 if (obj.id === 'CreateDocument'){
																			 return obj;
																		 	}
																		 }
																	 );
																	 if (objToRemove!=undefined){
																	 	result[k].content.splice(result[k].content.indexOf(objToRemove), 1);
																	}
															}
													if (optionsEnableAdd == false)
													{
														var objToRemove = result[k].content.find(
															function (obj) {
																 if (obj.id === 'AddExistingDocument'){
																	 return obj;
																	}
																 }
															 );
															 if (objToRemove!=undefined){
															 	result[k].content.splice(result[k].content.indexOf(objToRemove), 1);
															}
													}
													if (optionsEnableReserve == false)
													{
														var objToRemove = result[k].content.find(
															function (obj) {
																 if (obj.id === 'ReserveSelected'){
																	 return obj;
																	}
																 }
															 );
															 if (objToRemove!=undefined){
															 	result[k].content.splice(result[k].content.indexOf(objToRemove), 1);
															}
													}
													if (optionsEnableUnreserve == false)
													{
														var objToRemove = result[k].content.find(
															function (obj) {
																 if (obj.id === 'UnreserveSelected'){
																	 return obj;
																	}
																 }
															 );
															 if (objToRemove!=undefined){
															 	result[k].content.splice(result[k].content.indexOf(objToRemove), 1);
															}
													}
											}
										}
										else {
											if (element.id == 'delete' || element.id == 'remove'){
												if (optionsEnableRemove == false){
														deleteIndexArr.push(k);
													}
											}
										}
								}
								for (var i = 0; i < deleteIndexArr.length; i++) {
									result.splice(deleteIndexArr[i], 1);
								}
								for (var i = 0; i < result.length; i++) {
									var element = result[i];
									if (element.content!= undefined && element.content.length == 0){
										var objToRemove = result.find(
											function (obj) {
												 if (obj.id === result[i].id){
													 return obj;
													}
												 }
											 );
											 if (objToRemove!=undefined){
												result.splice(result.indexOf(objToRemove), 1);
												}
											}
								}
							}
							return result;
						},
						render : function(DocumentPresenter) {
							var that = this;
							if (this.title && this.title.trim().length != 0) {
								var titleSection = UWA.createElement('div', {
									html : this.title,
									styles : {
										fontFamily : 'Arial',
										fontSize : '16px',
										color : '#77797c',
										margin : '5px 0 3px 8px',
										fontWeight : 'normal'
									}
								});
								titleSection.inject(this.container);
							}
							var headerSection = this.buildFilterHeaderSection();
							headerSection.inject(this.container);
							this._stdActionbar._modelEvents.subscribe({
								event : 'enox-collection-toolbar-sort-activated'
							}, function(data) {
								that.publishViewEvent('sortBy', {
									id : data.sortAttribute,
									desc : data.sortOrder === 'DESC' ? true : false
								});
							});

							this._stdActionbar._modelEvents.subscribe({ event: 'enox-collection-toolbar-filter-search-value'}, function (data) {
								if (that.options.dictionaryJSON){
									var idList = convertToSearchData(that.options.dictionaryJSON);
										if (idList.length>0){
											that.WildcardSearch.search(data.searchValue[0], idList, ContextSearchCB);
										}
								}
							});
							DocumentPresenter._globalapplicationChannel.subscribe({ event: 'search-in-current-dashboard'}, function (data) {
								if (that.options.dictionaryJSON){
									var idList = convertToSearchData(that.options.dictionaryJSON);
										if (idList.length>0){
											that.WildcardSearch.search(data, idList, GlobalSearchCB);
										}
								}
							});

							// TJX : search integration start
							that.WildcardSearch = new WildcardSearchComponent();
							var ContextSearchCB = function(result){
								var resultListIds = [];
								for (var i=0; i<result.length; i++){
									resultListIds.push(result[i].id);
								}
										that.publishViewEvent('onContentFilterCriteriaChange', {
															'filterData': {'ContextSearchValues':resultListIds}
													});
										that.options.docOptions._internalChannel.publish({event : 'refresh-tag-on-filter',data:resultListIds});
							};
							var GlobalSearchCB = function(result){
								var resultListIds = [];
								for (var i=0; i<result.length; i++){
									resultListIds.push(result[i].id);
								}
							that.publishViewEvent('onContentFilterCriteriaChange', {
												'filterData': {'GlobalSearchValues':resultListIds}
										});
							that.options.docOptions._internalChannel.publish({event : 'refresh-tag-on-filter',data:resultListIds});
							};
							var convertToSearchData = function(data){
								var OIdsList = [];

								for (var i=0; i<data.length; i++){
									var element = {};
									element.id = data[i].id;
									for (var property in data[i].dataelements) {
										if (property == 'title') {
											var titleValue = data[i].dataelements[property].toLocaleLowerCase();
											element[property] = titleValue;
										}
									}
									OIdsList.push(element);
								}
								return OIdsList;
							};

							// TJX : search integration end
							this._container = UWA.createElement('div');
							this._container.classList.add('documents-presenter');
							this.contentSection = this.buildContentView();
							this.contentSection.inject(this.container);
							this.initializeContentViews(DocumentPresenter);
							this.switchView('table');
  						return this;
						},

						viewSorter : function(sortData) {
						},

						buildFilterHeaderSection : function() {
							var that = this;
							var headerSection = UWA.createElement('div', {
								id : 'headerCtrlSection',
								'class' : 'header-ctrl-section'
							});

							this._actionbarOptions.parentContainer = headerSection;
							this._actionbarOptions.onSwitch = function() {
								that.switchView.apply(that, arguments);
							};
							this._actionbarOptions.onSearch = function(filterData) {
							};
							this._actionbarOptions.onSort = this.viewSorter;
							this._stdActionbar = new ENOXCollectionToolBar(this._getCollectionToolbarOptions());
							this._stdActionbar.inject(this._actionbarOptions.parentContainer);
							return headerSection;
						},

						_getCollectionToolbarOptions : function() {
							var collectionToolbarOptions = this._actionbarOptions ? this._actionbarOptions
									: {};

							UWA.merge(collectionToolbarOptions, {
								withmultisel : false,
								showItemCount : true,
								filter : {},
								actions : [],
								sort : [
								],
								views: [],
								itemsName: DOC_NLS.DOC_Type_Documents,
								itemName: DOC_NLS.DOC_Type_Document
							});

							return collectionToolbarOptions;
						},

						buildContentView : function() {
							var options = this.options;
							var contentSection = UWA.createElement('div', {
								id : 'contentSection',
								'class' : 'content-section'
							});

							return contentSection;
						},

						initializeContentViews : function(DocumentPresenter) {
							if (this.contentViews && this.contentViews.length > 0
									&& this.options.dictionaryJSON.length > 0) {
								this._contentViews = {};
								var that = this;
								this.contentViews.forEach(function(contentView, index) {
									var options = contentView.options ? contentView.options : {};
									options.docInstance = DocumentPresenter;
									var view = new contentView.view(options);
									if (index == 0) {
										that._contentViews.currentView = contentView.id;
										that._contentViews.view = {};
									}
									that._contentViews.view[contentView.id] = view;

									view.subscribe('onDisplayAndSelCountUpdate', function(data) {
										that._stdActionbar._modelEvents.publish({
											event : 'enox-collection-toolbar-items-count-update',
											data : data.displayCount
										});
									});
									view.render();
								});
							} else {
								Mask.unmask(this.container);
								this.createEmptyDocumentContainer(this.container, DocumentPresenter);
								//For Drop on emptySection start
								var emptyContainerRef = this.container.getElement('#drop-invite');
								DocumentCommonUtils.makeDroppable(emptyContainerRef, DOC_NLS.DOC_Landing_Page, function (e){
									var that = this;
									if (e.preventDefault) {
											e.preventDefault();
									}
									if (e.dataTransfer!=undefined){
											DocumentPresenter.tablePresenter.dropFromSystem(e, emptyContainerRef, DocumentPresenter);
									}
									else {
										DocumentPresenter.tablePresenter.dropFromSearch(e, emptyContainerRef, DocumentPresenter);
									}
								});
							}
						},
						dropFromSystem : function(e, emptyContainerRef, DocumentPresenter){
							if (e.dataTransfer.files != undefined && e.dataTransfer.files.length > 10){
								DocumentPresenter.tablePresenter.hideDroppable(emptyContainerRef);
								xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
							}
							else {
								DocumentPresenter.tablePresenter.hideDroppable(emptyContainerRef);
								DocumentCreateForm.createDocumentForm(DocumentPresenter, e.dataTransfer.files);
							}
						},

						dropFromSearch: function(e, emptyContainerRef, DocumentPresenter){
							if (e.length  == 1){
								DocumentPresenter.connectDocumentToParent(e[0].objectId, DocumentPresenter.modelId, e, true);
							}
							else {
										DocumentPresenter.tablePresenter.hideDroppable(emptyContainerRef);
										xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
							}
						},

						hideDroppable : function(emptyContainerRef){
							var that = this;
							that.dropInvite = emptyContainerRef.getElement('#droppable');
							that.dropInvite.addClassName('hidden');
							that.dropInvite.addClassName('fileDrop');
							that.dropInvite.removeClassName('show');
							that.dropInvite.removeClassName('droppable');
						},

						createEmptyDocumentContainer : function(container, DocumentPresenter) {
							var that=this;
							var emptySection = UWA.createElement('div', {
								id : 'drop-invite',
								class: 'emptyContainerStyle',
								html : ''
							});
							var childSection1 = UWA.createElement('div', {
								id : 'childSection1'
							});
							var childSection2 = UWA.createElement('div', {
								id : 'childSection2'
							});
							var childSection3 = UWA.createElement('div', {
								id : 'childSection3'
							});
							var childSection4 = UWA.createElement('div', {
								id : 'childSection4'
							});
							var emptySectionSpan = UWA.createElement('span', {
								html : DOC_NLS.DOC_Landing_Page
							});
							var emptySectionSpan1 = UWA.createElement('span', {
								html : '---------------------- '+DOC_NLS.DOC_Landing_Page_Or+' ----------------------'
							});
							var emptySectionImg = UWA.createElement(
											'div',
											{
												'class' : 'empty-view-icon empty-view-icon center-block fonticon fonticon-5x fonticon-drag-drop'
											});
							var emptySectionP1 = UWA.createElement('p', {});
							var emptySectionP2 = UWA.createElement('p', {});
							var emptySectionP3 = UWA.createElement('p', {});
							var emptySectionSpan3 = new Button({
					        value: DOC_NLS.DOC_Empty_Container_Search,
					        className: 'primary'
					    });
							emptySectionSpan3.elements.input.onclick = function () {
								 DocumentSearchController.addExistingDoc(DocumentPresenter);
					    	 return emptySectionSpan3;
							 },

							childSection1.appendChild(emptySectionImg);
							childSection1.appendChild(emptySectionP1);
							childSection2.appendChild(emptySectionSpan);
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

						switchView : function(viewId) {
							if (this._contentViews) {
								// var id = this._contentViews.currentView;
								this.contentSection.setContent(this._contentViews.view[viewId]);
								this._contentViews.currentView = this._contentViews.view[viewId];
							}
						},

						// Publishes the event on the available views.
						publishViewEvent : function(eventName, data) {
							if (this._contentViews) {
								for ( var id in this._contentViews.view) {
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
						subscribeViewEvent : function(eventName, callback) {
							if (this._contentViews) {
								for ( var viewId in this._contentViews.view) {
									var view = this._contentViews.view[viewId];
									if (UWA.is(view.subscribe, 'function') && UWA.is(callback, 'function')) {
										view.subscribe(eventName, callback);
									}
								}
							}
						},

						unsubscribeAllViewEvent : function(eventName) {
							if (this._contentViews) {
								for ( var viewId in this._contentViews.view) {
									var view = this._contentViews.view[viewId];
									if (UWA.is(view.unsubscribeAll, 'function')) {
										view.unsubscribeAll(eventName);
									}
								}
							}
						},

						// APIs and Events
						subscribe : function(event, callback) {
							this.subscribeViewEvent(event, callback);
						},

						unsubscribeAll : function(eventName) {
							this.unsubscribeAllViewEvent(eventName);
						},

						changeView : function(viewId) {
							this.switchView(viewId);
						},

						addCriteria : function(item) {
							this.publishViewEvent('addCriteria', {
								item : item
							});
						},

						removeCriteria : function(item) {
							this.publishViewEvent('removeCriteria', {
								item : item
							});
						}
					});
			return itemsMultiPresenter;
		});
