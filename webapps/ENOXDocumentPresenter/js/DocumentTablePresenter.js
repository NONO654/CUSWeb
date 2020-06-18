/*XSS_CHECKED*/
define(
		'DS/ENOXDocumentPresenter/js/DocumentTablePresenter',
		[ 'UWA/Class/View', 'UWA/Class/Listener', 'UWA/Core',
				'DS/Tree/TreeNodeModel', 'DS/Tree/TreeListView', 'DS/Tree/TreeDocument',
				'DS/Controls/Button', 'DS/Core/ModelEvents', 'DS/UIKIT/DropdownMenu',
				'DS/xPortfolioUXCommons/util/ScrollUtil',
				'DS/xPortfolioQueryServices/js/infra/xPortfolioInfra',
				'DS/DocumentManagement/DocumentManagement',
				'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
				'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
				'DS/ENOXDocumentPresenter/js/util/DocumentCommonUtils',
				'DS/DocumentManagementCustom/js/DocumentManagementCustom',
				'i18n!DS/ENOXDocumentPresenter/assets/nls/DocumentsPresenter',
				'css!DS/UIKIT/UIKIT.css' ],
		function(View, Listener, UWACore, TreeNodeModel, TreeListView, TreeDocument,
				WUXButton, ModelEvents, IconDropdown, ScrollUtil,
				xPortfolioInfra, DocumentManagement, i3DXCompassPlatformServices, xNotificationsUtil, DocumentCommonUtils, DocumentManagementCustom, DOC_NLS) {

			'use strict';
			var tableView = View.extend({
						tagName : 'div',
						className : 'generic-detail',
						params : {},

						init : function(options) {

							var that = this;
							that.docOptions= options.docInstance;
							that.mainContainerInstance = options.mainContainerInstance;
							that.showAlertMessage = false;
							var options1 = options;
							options1 = TreeListView.SETTINGS.STANDARD_CHECKBOXES;

							options1.columns.forEach(myFunction);
							options1.selection.preSelection = true;
							options1.selection.enableListSelection = true;
							options1.performances.renderingMode = 'standard';

							function myFunction(item) {
								if (item.text != 'Tree') {
									options.contentTreeOptions.columns.splice(0, 0, item);
								}
							}
							UWA.extend(options, this.defaults, true);
							this._modelEvents = new ModelEvents();
							this.modelId = options.modelId;
							if (options.modelEvents) {
								this.modelEvents = options.modelEvents;
							}
							if (undefined == options.withActionsTree){
								options.withActionsTree = true;
							}
							if (options.actions && options.withActionsTree) {
								this.actionsTreeListView = new ActionsTreeListView({
									actions : options.actions,
									withActionsTree : options.withActionsTree,
                                    allowUnsafeHTMLContent : false,
									_modelEvents : this._modelEvents,
									registerActionsCellContent : this.customRegisterReusableCellContent,
									showScrollbarsOnHover : false
								});
							}

							this.dicoVersion = '2.0';
							this.tableListView = new contentTreeListView(UWA.merge(
															{
																	viewIdentifier : options.viewIdentifier,
																	dicoVersion : this.dicoVersion,
                                                                    allowUnsafeHTMLContent : true,
																	dictionaryJSON : options.dictionaryJSON,
																	actionsTreeListView : (options.withActionsTree && this.actionsTreeListView) ? this.actionsTreeListView
																			: undefined,
																	_modelEvents : this._modelEvents,
																	getAllChildrenOnParentSelection : options.getAllChildrenOnParentSelection,
																	getParentOnChildSelection : options.getParentOnChildSelection,
																	actions : options.actions,
																	registerActionsCellContent : this.customRegisterReusableCellContent,
																	withActionsTree : options.withActionsTree,
																	contentFilter : options.contentFilter,
																	showScrollbarsOnHover : true,
																	onDropCell: this._handleOnDrop.bind(that)
																},
													 	options.contentTreeOptions
														));
							this._parent(options);
							this.tableListView.onNodeDblClick(function(options) {
								that.onNodeDblClickEvent(options);
							}.bind(this));
							this.tableListView._loadJsonUpdated.call(this.tableListView);
							this.tableListView.options.selectionData.displayCount = this.tableListView.options.selectionData.totalCount = this.tableListView.getNodeCount(this.tableListView);
							this.manageTreeListViewScrolling(that.docOptions);

							if (UWA.is(options.actions, 'array')) {
								options.actions.forEach(function(action) {
									var eventName = action.event;
									if (eventName) {
										that.subscribe('internal_' + eventName, function(eventData) {
											var subDico = that.getDOCDicoFromNodeDetails(eventData);
											that._modelEvents.publish({
												event : eventName,
												data : subDico,
												context : null
											});
										});
									}
								});

							}

							this.subscribe('internal_onAddAction', function(eventData) {
								that.getDOCDicoFromNodeDetails(eventData);
							});

							this.subscribe('loadDOCDictionary', function(data) {
								that.loadDOCDictionary(data);
							});
						},
						onNodeDblClickEvent : function(options){
							var that = this;
							if (options.dataIndex != 'tree' && (options.nodeModel.options.dictionaryItem.dataelements.reservedby=='' || options.nodeModel.options.dictionaryItem.dataelements.reservedby == DocumentCommonUtils.getLoggedInUser())){
								var optionsEnableModify  =that.docOptions.options.actions['enable-update'];
								if (optionsEnableModify == true){
									var nodeInfo = options.nodeModel.options;
									this._modelEvents.publish({
										event : 'enoxdoc-double-click',
										data : {
											id : nodeInfo.id,
											name : nodeInfo.label,
											image : nodeInfo.dictionaryItem.dataelements.image,
											version : nodeInfo.dictionaryItem.dataelements.revision
										}
									});
								}
								else {
										xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
								}
							}
						},
						_handleOnDrop : function(dragEvent, dropInfos) {
							var that = this.docOptions;
							var optionsEnableModify  =that.options.actions['enable-update'];
							if (optionsEnableModify == true){
								var docId = dropInfos.nodeModel._options.dictionaryItem.id;
								var fileList = dragEvent.dataTransfer.files;
								if (fileList.length>1){
									xNotificationsUtil.showError(DOC_NLS.DOC_Multi_Files_Upload_Error);
										var dropInvite = document.getElement('.documents-presenter li.wux-layouts-gridengine-columns-header-container #droppable');
										dropInvite.addClassName('hidden');
										dropInvite.removeClassName('show');
										dropInvite.removeClassName('droppable');
								}
								else {
									that.uploadDocument(docId, fileList);
								}
							}
							else {
										xNotificationsUtil.showError(DOC_NLS.DOC_OPERATION_NOT_ALLOWED);
							}
						},
						/*
						 * Call this function to get subDico either from nodeModel or nodeRowID It
						 * would be called on click of add action.
						 */
						getDOCDicoFromNodeDetails : function(nodeDetails) {
							var that = this;
							var subDicoObj = {};
							subDicoObj.clickedId = null;
							subDicoObj.nodeModel = '';
							if (nodeDetails) {
								var nodeToAdd = nodeDetails.nodeModel ? nodeDetails.nodeModel
										: that.tableListView.getManager().getTreeNodeModelFromRowID(
												nodeDetails.nodeRowID);
								if (nodeToAdd.options.dictionaryItem.dataelements == undefined) {
									subDicoObj.clickedId = nodeToAdd.options.dictionaryItem['@id'];
									subDicoObj.editMode = true;
									subDicoObj.docType = nodeToAdd.options.dictionaryItem['@attributes'].attr_type;
									subDicoObj.nodeModel = that.tableListView.options.treeDocument;
									return subDicoObj;
								} else {
									subDicoObj.clickedId = nodeToAdd.options.id;
									subDicoObj.reservedby = nodeToAdd.options.dictionaryItem.dataelements.reservedby;
									subDicoObj.docType = nodeToAdd._options.dictionaryItem.type;

									if (nodeToAdd.options.dictionaryItem.dataelements.reservedby == '') {
										subDicoObj.editMode = true;
									}
									if (nodeToAdd.options.dictionaryItem.dataelements.reservedby != '') {
										subDicoObj.editMode = false;
									}
									subDicoObj.docType = nodeToAdd._options.dictionaryItem.type;
									subDicoObj.nodeModel = that.tableListView.options.treeDocument;
								}
							}
							return subDicoObj;
						},

						loadDOCDictionary : function(dictionary) {
							if (dictionary) {
								this.options.dictionaryJSON = dictionary;
								this.tableListView._loadJsonUpdated(dictionary);
								this.tableListView.options.selectionData.displayCount = this.tableListView.getVisibleNodeCount();
								this.publish('onDisplayAndSelCountUpdate',
										this.tableListView.options.selectionData, null);
							}
						},
						render : function() {
							this.container.style.height = '100%';
							this.container.style.display = 'flex';
							var tableListViewDiv = UWA.createElement('div', {
								styles : {
									width : '100%',
									height : '100%',
									display : 'inline-block'
								},
								'class' : 'content-tree-section'
							});
							tableListViewDiv.addContent(this.tableListView);
							this.container.addContent(tableListViewDiv);

							if (this.options.withActionsTree && this.actionsTreeListView) {
								tableListViewDiv.setStyle('width', 'calc( 100% - 30px )');
								var actionsListViewDiv = UWA.createElement('div', {
									styles : {
										width : '40px',
										height : '100%',
										display : 'inline-block'
									},
									'class' : 'action-tree-section'
								});
								actionsListViewDiv.addContent(this.actionsTreeListView);
								this.actionsTreeListView.elements.container.setStyle('display',
										'inline');
								this.container.addContent(actionsListViewDiv);
							}

							// Publish the event so as to display count information on render.
							this.publish('onDisplayAndSelCountUpdate',
									this.tableListView.options.selectionData, null);
							return this;
						},
						manageTreeListViewScrolling : function(DocumentsPresenter) {
							var that = this;
							if (!this.options.actions
									|| (UWA.is(this.options.actions, 'array') && this.options.actions.length === 0)
									|| !this.options.withActionsTree){
								return;
							}

							var contentTableManager = this.tableListView.getManager();
							var actionsTableManager = this.actionsTreeListView ? this.actionsTreeListView.getManager(): undefined;
							var contentReadyPromise = new UWA.Promise(function(resolve, reject) {
								contentTableManager.onReady(resolve);
							});
							var actionsReadyPromise = new UWA.Promise(function(resolve, reject) {
								actionsTableManager.onReady(resolve);
							});
							this.tableListView.getManager().onReady(function() {
								this._treeDocument.onNodeModelUpdate(function(){
									var nodeOptions = arguments['0'].data.nodeModel._options;
									if (nodeOptions.oldLabel){
											if (nodeOptions.label!=null && nodeOptions.label!=''){
											var documentInfo = {
												id : nodeOptions.id,
												title : nodeOptions.label
											};
											var iOptions = {
												securityContext : xPortfolioInfra.getSecurityContext(),
												additionalHeaders : DocumentManagementCustom.addCfgAuthoringContextToHeader(),
												onComplete : function(output) {
													if (!that.showAlertMessage){
														xNotificationsUtil.showSuccess(DOC_NLS.DOC_Title_Update);
														that.showAlertMessage = true;
														DocumentsPresenter.render();
													}
												},
												onFailure : function(result) {
													if (!that.showAlertMessage){
														xNotificationsUtil.showError(DocumentCommonUtils.getErrorMessage(result.internalError));
														that.showAlertMessage = true;
														DocumentsPresenter.render();
													}
												}
											};
											DocumentManagement.modifyDocument(documentInfo, iOptions);
										}
										else {
												if (!that.showAlertMessage){
													xNotificationsUtil.showError(DOC_NLS.DOC_Title_NotEmpty);
													that.showAlertMessage = true;
													DocumentsPresenter.render();
										}
											}
										}
								}
							);
							});
							UWA.Promise.all([ contentReadyPromise, actionsReadyPromise ]).then(
									function(){
										that.loadPromise(that);
									}
										);

							// Content Table Manager onReady handler:
							contentTableManager.onReady(function() {
								that.actionsTreeListView
										&& that.actionsTreeListView.getManager().onReady(function() {
										});
							});
						},
						loadPromise: function(currentObj){
							var that = currentObj;
								var contentScroller = that.tableListView.getManager().elements.scroller;
								var actionsScroller = that.actionsTreeListView.getManager().elements.scroller;

								contentScroller.elements.container.setStyle('overflow-y', 'hidden');
								actionsScroller.elements.container.setStyle('overflow-x', 'disabled');

								contentScroller.elements.container.addEvent('wheel',
												function(event) {
													event.preventDefault();
													// when pooled rows count is less or equal to total rows,
													// return as no need to scroll.
													var contentTableManager = this.tableListView.getManager();
													var actionsTableManager = this.actionsTreeListView ? this.actionsTreeListView.getManager(): undefined;
													if (contentTableManager.getPoolNumberOfRows() == (contentTableManager.getNumberOfRows() - 1)) {
														return;
													}
													if (actionsTableManager.getPoolNumberOfRows() == (actionsTableManager.getNumberOfRows() - 1)) {
														return;
													}
													var delta = UWA.Event.wheelDelta(event);
													var normalizedScroll = ScrollUtil.normalizeWheel(event);

													var deltaToScrollY = Math.abs(normalizedScroll.pixelY);

													var maxDeltaY = ScrollUtil.maxWheelDelta(event).y;

													var currentDeltaY = 0;

													while (currentDeltaY <= deltaToScrollY) {
														currentDeltaY = currentDeltaY + maxDeltaY;
														var newScrollTop = actionsScroller.elements.container.scrollTop
																+ (normalizedScroll.spinY * maxDeltaY);
														actionsScroller.elements.container.scrollTop = newScrollTop;
													}
													actionsScroller.setPosition({
														x : 0,
														y : -actionsScroller.elements.container.scrollTop
													}, false);

													actionsScroller._modelEvents.publish({
														event : 'SCROLL',
														context : actionsScroller
													});
												});

								// Action Scroll Event
								actionsScroller.onScroll(function(event) {
											var actionPos = this.getPosition();
											var contentPos = that.tableListView.getManager().elements.scroller.getPosition();
											that.tableListView.getManager().elements.scroller.setPosition({
												x : 0,
												y : actionPos.y
											}, false);

											that.tableListView.getManager().elements.scroller.elements.container.scrollTop = Math.abs(actionPos.y);
											that.tableListView.getManager().elements.scroller.elements.container.scrollLeft = Math.abs(contentPos.x);
											that.tableListView.getManager().elements.scroller._modelEvents.publish({
														event : 'SCROLL',
														data : {
															originatedFrom : 'ActionScroller'
														},
														context : that.tableListView.getManager().elements.scroller
													});
										});
						},
						// function to subscribe to events, from this UI.
						subscribe : function(eventName, callback) {
							if (this._modelEvents) {
								this._modelEvents.subscribe({
									event : eventName
								}, callback);
							}
						},

						unsubscribeAll : function(eventName) {
							if (this._modelEvents) {
								this._modelEvents.unsubscribeAll({
									event : eventName
								});
							}
						},

						// Function to publis events from this UI.
						publish : function(eventName, eventData, context) {
							if (this._modelEvents) {
								this._modelEvents.publish({
									event : eventName,
									data : eventData,
									context : context
								});
							}
						},

						// Call this function with call/apply so as to pass the context
						customRegisterReusableCellContent : function() {
							var that = this;
							var reusableCntId = '_reusableActionsContent';
							if (UWA.is(this.options.actions, 'array')) {
								if (this.options.actions.length == 1) {
									var action = this.options.actions[0];
									that.getManager().registerReusableCellContent(
													{
														id : reusableCntId,
														buildContent : function() {
															var actionBtn = new WUXButton({
																icon : action.fonticon,
																displayStyle : 'lite',
																label : action.title,
																showLabelFlag : false,
                                                                allowUnsafeHTMLLabel: false
															});
															actionBtn.getContent().setStyle('margin-right', '10');
															actionBtn.getContent().addEvent('click',
																			function() {
																				var cellInfos = this.parentNode.dsView.getCellInfos();
																				if (cellInfos) {
																					that.options._modelEvents.publish({
																								event : 'internal_' + action.event,
																								data : {
																									nodeRowID : that.options.withActionsTree ? cellInfos.virtualRowID	: undefined,
																									nodeModel : !that.options.withActionsTree ? target.parentNode.dsView._getNodeModel(): undefined
																								},
																								context : null
																							});
																				}
																			});
															return actionBtn;
														}
													});
								} else {
									var subActions = [];
									this.options.actions.forEach(function(action) {
										subActions.push({
											selected : action.selected ? action.selected : false,
											fonticon : action.fonticon,
											description : action.description,
											title : action.title ? action.title : '',
											text : action.text ? action.text : action.title ? action.title : '',
											'event' : action.event ? action.event : undefined
										});
									});
									this.getManager().registerReusableCellContent(
													{
														id : reusableCntId,
														buildContent : function(cellView) {
															var actionBtn = new WUXButton({
																icon : {
																	iconName : 'angle-down'
																},
																displayStyle : 'lite',
																showLabelFlag : false,
                                                                allowUnsafeHTMLLabel: false
															});
															actionBtn.getContent().setStyle('margin-right', '10');
															actionBtn.addEventListener('buttonclick',
																			function(event) {
																				var actionButton = event.dsModel;
																				var cellInfos = this.parentNode.dsView.getCellInfos();
																				if (cellInfos) {
																					var data = {
																						nodeRowID : that.options.withActionsTree ? cellInfos.virtualRowID: undefined,
																						nodeModel : !that.options.withActionsTree ? this.parentNode.dsView._getNodeModel(): undefined
																					};
																					actionButton.actionDropdown.data = data;
																				}
																			});
															actionBtn.actionDropdown = new IconDropdown({
																target : actionBtn.getContent(),
																renderTo : widget ? widget.body : document.body,
																items : subActions,
																bound : true,
																position : 'bottom left',
																offset : {
																	x : 0,
																	y : 0
																},
																events : {
																	onClick : function(e, item) {
																		if (item.event) {
																			that.options._modelEvents.publish({
																				event : 'internal_' + item.event, // 'onAddAction',
																				data : this.data,
																				context : null
																			});
																		}
																	}
																}
															});
															return actionBtn;
														}
													});
								}
							}
							return '_reusableActionsContent';
						}
					});

			// Actions Icon Tree List View.
			var ActionsTreeListView = TreeListView.extend(
							Listener,
							{
								defaults : {
									apiVersion : 2,
									height : '100%',
									width : '10%',
									display : 'inline',
									columns : [

											{
												text : '',
												dataIndex : 'actionCol',
												width : '40',
												isSortable : false,
												isEditable : false,
												isSelectable : false,
												onCellRequest : function(cellInfos) {
													if (!cellInfos.isHeader) {
														var reusableContent = cellInfos.cellView.reuseCellContent('_reusableActionsContent');
													}
												}
											}, {
												text : '',
												dataIndex : 'tree',
												isHidden : true
											} ],

									selection : {
										nodes : true,
										cells : false,
										rowHeaders : false,
										columnHeaders : false,
										unselectAllOnEmptyArea : false,
										toggle : true,
										canMultiSelect : true
									}
								},

								init : function(options) {
									UWA.extend(options, this.defaults, true);
									options.treeDocument = new TreeDocument(
											{
												useAsyncPreExpand : true,
												shouldAcceptDrop : function(options) {
													return true;
												},
												shouldAcceptDrag : function(draggedNode) {
													return true;
												},
												shouldBeEditable : function(nodeModel) {
													if (nodeModel._options.dictionaryItem != undefined) {
														if (nodeModel._options.dictionaryItem.dataelements!= undefined && nodeModel._options.dictionaryItem.dataelements.reservedby == '') {
															return true;
														} else {
															return false;
														}
													} else {
														return true;
													}
												},
												shouldBeSelected : function(nodeModel) {
													return true;
												}
											});
									this._parent(options);
									this.options._actionsRegContentId = this.options.registerActionsCellContent.call(this);
								}
							});

			// Content tree list view definition.
			var contentTreeListView = TreeListView.extend(
							Listener,
							{
								defaults : {
									treeDocument : {},
									apiVersion : 2,
									height : '100%',
									width : '80%',
									expanderStyle : 'triangle',
									selection : {
										nodes : true,
										cells : false,
										rowHeaders : true,
										columnHeaders : true,
										unselectAllOnEmptyArea : true,
										toggle : true,
										canMultiSelect : true
									},
									node : [],

									criteriaFilters : {
										searchData : {},
										searchText : ''
									},
									onDragStartCell : function(dragEvent, dropInfos) {
													var data = dropInfos.nodeModel.options.grid;
													var DAndDDdata = {
												  protocol: '3DXContent',
												  version: '1.1',
												  source:  widget.data.appId,
												  widgetId: widget.id,
												  data: {
												    items: [
												      {
												        envId: widget.getValue('x3dPlatformId'),
												        serviceId: '3DSpace',
												        contextId: '',
												        objectId: dropInfos.nodeModel.options.id,
												        objectType: data.type,
												        displayName: dropInfos.nodeModel.options.label,
												        displayType: data.type
												      }
												    ]
												  }
												};
													dragEvent.dataTransfer.setData('text', JSON.stringify(DAndDDdata));
									},
									onDragLeaveColumnHeader : function(e, dndInfos) {
									},
									onDragOverColumnHeader : function(e, dndInfos) {
										var dropInvite = document.getElement('.documents-presenter li.wux-layouts-gridengine-columns-header-container #droppable');
										dropInvite.removeClassName('hidden');
										dropInvite.addClassName('show');
										dropInvite.addClassName('droppable');
									},
									events : {
										onChangeSelection : function(selCount) {
											this.options._modelEvents.publish({
												event : 'onDisplayAndSelCountUpdate',
												data : this.options.selectionData,
												context : null
											});
										}
									},

									applyCriteriaFilter_v2 : function(event) {
				              var that = this;
				              var taggerData = event.filterData.TaggerValues;
				              var ContextSearchData = event.filterData.ContextSearchValues;
				              var GlobalSearchData = event.filterData.GlobalSearchValues;
				              var searchText = UWA.is(event.filterData.searchValue, 'array') ? event.filterData.searchValue[0] : event.filterData.searchValue;
				              searchText = searchText ? searchText.toLowerCase() : undefined;
				              var checkBoxSts = event.filterData.typeFilter ? event.filterData.typeFilter : undefined;

				              var rootNodesArr = this.options.treeDocument.getRoots();
				              var tmpTotalNodes = 0;
				              var tmpTotalChildNodes = 0;
				              var hiddenNodeCount = 0;
				              tmpTotalNodes = rootNodesArr.length;
				              var filterType = null;
				              var filterValues = null;
				              if (taggerData){// && taggerData.length>0){
				            	  filterType = 'TaggerValues';
				            	  filterValues = taggerData;
				              } else {
				            	  if (ContextSearchData){// && ContextSearchData.length>0){
				            		  filterType = 'ContextSearchValues';
				            		  filterValues = ContextSearchData;
				            	  } else {
				            		  if (GlobalSearchData){// && GlobalSearchData.length>0){
				            			  filterType = 'GlobalSearchValues';
				            			  filterValues = GlobalSearchData;
				            		  }
				            	  }
				              }
				              if (rootNodesArr && rootNodesArr.length > 0) {
				                  rootNodesArr.filter(function(rootNode) {
				                	  if (filterType !== null){
				                		  if (!rootNode.xFiltersMerge){
				                			  rootNode.xFiltersMerge = {};
				                		  }
				                		  var pid = rootNode._options.dictionaryItem.id;
				                		  if (filterValues.indexOf(pid) != -1){
				                			  rootNode.xFiltersMerge[filterType] = true;
				                		  } else {
				                			  rootNode.xFiltersMerge[filterType] = false;
				                		  }
				                	  }
				            		  if (searchText && searchText.length>0){
				            			  var updateCountAndReturn = false;
				                          var rootNodeLabel = rootNode.getLabel().toLowerCase();
				                          var childNodesArr = rootNode.getChildren();
				                          if (checkBoxSts) {
				                              if (checkBoxSts[rootNode.options.criteriaType] == false && !rootNode.isHidden()) {
				                                  rootNode.hide();
				                                  updateCountAndReturn = true;
				                              } else if (checkBoxSts[rootNode.options.criteriaType] == true && rootNode.isHidden() && rootNodeLabel.contains(searchText)) {
				                                  rootNode.show();
				                                  if (searchText == '' && (childNodesArr == null || childNodesArr.length < 0)) {
				                                      updateCountAndReturn = true;
				                                  }
				                              } else if (checkBoxSts[rootNode.options.criteriaType] == false && rootNode.isHidden()) {
				                                  return;
				                              } else if (checkBoxSts[rootNode.options.criteriaType] == true && !rootNode.isHidden()) {
				                                  if (searchText == '' && (childNodesArr == null || childNodesArr.length < 0)) {
				                                      updateCountAndReturn = true;
				                                  }
				                              }
				                              if (updateCountAndReturn) {
				                                  return;
				                              }
				                          }
				                          var filteredNodes = [];

				                          if (rootNode.isHidden() &&
				                              (rootNodeLabel.contains(searchText) || filteredNodes.length > 0)) {
				                              rootNode.show();
				                          } else if (!rootNode.isHidden() &&
				                              (!rootNodeLabel.contains(searchText) && filteredNodes.length <= 0)) {
				                              rootNode.hide();
				                          }
				                	  }
				                  });
				                  if (filterType !== null){
				                	  that.applyAllFilters();
				                  }
				                  that.options.selectionData.displayCount = that.getVisibleNodeCount();
				                  that.options._modelEvents.publish({
				                      event: 'onDisplayAndSelCountUpdate',
				                      data: that.options.selectionData,
				                      context: null
				                  });
				              }
				          }

								},
								applyAllFilters : function() {
									var rootNodesArr = this.options.treeDocument.getRoots();
									if (rootNodesArr && rootNodesArr.length > 0) {
									rootNodesArr.filter(function(rootNode) {
										if (rootNode.xFiltersMerge){
											var isFiltered = true;
											Object.keys(rootNode.xFiltersMerge).forEach(function(key) {
												if (rootNode.xFiltersMerge[key] == false){
													isFiltered = false;
												}
											});
											if (isFiltered){
												rootNode.show();
											} else {
												rootNode.hide();
											}
										}
									});
										}
									},
								getNodeCount : function() {
									function _countNodes(inputNode) {
										var count = 0;
										if (inputNode && inputNode.hasChildren()) {
											var count = inputNode.getChildren().length;
											inputNode.getChildren().forEach(function(node) {
												count += _countNodes(node);
											});
										}
										return count;
									}
									var nodeCount = 0;

									if (this.options.treeDocument) {
										var nodeCount = _countNodes(this.options.treeDocument._getTrueRoot());
									}
									return nodeCount;
								},

								getVisibleNodeCount : function() {
									function _countVisibleNodes(inputNode) {
										var count = 0;
										if (inputNode.getParent() != null && !inputNode.isHidden()){
											count++;
										}
										var childNodesArr = inputNode.getChildren();
										if (childNodesArr) {
											childNodesArr = (UWA.is(childNodesArr, 'array') && childNodesArr.length > 0) ? childNodesArr: null;
											childNodesArr.forEach(function(childNode) {
												if (childNode && !childNode.isHidden()) {
													if (childNode.getChildren()
															&& (childNode.getChildren().length > 0)) {
														count += _countVisibleNodes(childNode);
													} else {
														count += 1;
													}
												}
											});
										}
										return count;
									}
									var nodeCount = 0;
									if (this.options.treeDocument) {
										nodeCount = _countVisibleNodes(this.options.treeDocument._getTrueRoot());
									}
									return nodeCount;
								},

								_loadJsonUpdated : function(dictionary) {
									if (dictionary) {
										this.options.dictionaryJSON = dictionary;
										this.dicoVersion = '2.0';
									}
									if (this.dicoVersion) {
										this.options.treeDocument.prepareUpdate();
										if (this.options.actionsTreeListView) {
											this.options.actionsTreeListView.options.treeDocument.prepareUpdate();
										}
										switch (this.dicoVersion) {
										case '2.0': {
											var documentclassArr = this.options.dictionaryJSON;

											var actionsTreeRootNode = this.options.actionsTreeListView ? this.options.actionsTreeListView.options.treeDocument._getTrueRoot(): undefined;
											var contentTreeRootNode = this.options.treeDocument._getTrueRoot();

											this.options.treeDocument.empty();
											if (actionsTreeRootNode) {
												this.options.actionsTreeListView.options.treeDocument.empty();
											}

											this.getTreeNodeModelFromDicoObject(contentTreeRootNode,
													actionsTreeRootNode, DOC_NLS.DOC_Type_Document,
													DOC_NLS.DOC_Type_Document, documentclassArr);
										}
											break;

										default:
											break;
										}
										this.options.treeDocument.pushUpdate();
										if (this.options.actionsTreeListView) {
											this.options.actionsTreeListView.options.treeDocument.pushUpdate();
										}
									}
								},
								addSubDictionary : function(subDictionary) {
									var that = this;
									if (subDictionary) {
										subDictionary.forEach(function(item) {
													var dictionaryItem = item;
													var criteriaType = 'Document';
													var colTypeText = DOC_NLS.item;
													var actionsTreeRootNode = that.options.actionsTreeListView ? that.options.actionsTreeListView.options.treeDocument: undefined;
													that.addCriteria(that.options.treeDocument, actionsTreeRootNode,
															criteriaType, colTypeText, dictionaryItem);
												});
									}
								},

								addCriteria : function(contentTreeDocument, actionTreeDocument,
										typeOfCriteria, colTypeText, dictionaryItem) {
									var that = this;
									var colsArray = this.options.columns;
									var bActionTreeExists = this.options.actionsTreeListView ? true: false;
									var treeColVal = '';
									var gridValue = {};
									var loggedInUser = '';
									var defaultState = '';
									i3DXCompassPlatformServices.getUser({
										onComplete : function(data) {
											loggedInUser = data.id;
										}
									});

									if (dictionaryItem['@attributes'].attr_type == 'Document') {
										defaultState = 'IN_WORK';
									}
									if (dictionaryItem['@attributes'].attr_type == 'Product Specification') {
										defaultState = 'Plan';
									}

									this.options.columns.forEach(function(colObj) {
												var valAttrb = colObj.valueAttribute;
												if (colObj && colObj.dataIndex == 'tree') {
													treeColVal = dictionaryItem['@attributes'].attr_title;
												} else if (colObj && colObj.dataIndex == 'type') {
													if (dictionaryItem['@attributes'].attr_type == DOC_NLS.DOC_TYPE_Product_Specification) {
														gridValue[valAttrb] = DOC_NLS.DOC_Type_Specification;
													}
													if (dictionaryItem['@attributes'].attr_type == DOC_NLS.DOC_Type_Document) {
														gridValue[valAttrb] = DOC_NLS.DOC_Type_Document;
													}
												} else if (colObj && colObj.dataIndex == 'state') {
													gridValue[valAttrb] = defaultState;
												} else if (colObj && colObj.dataIndex == 'owner') {
													gridValue[valAttrb] = loggedInUser;
												} else if (colObj && colObj.dataIndex == 'reservedby') {
													gridValue[valAttrb] = '<span title='+DOC_NLS.DOC_Unreserve+' class="fonticon fonticon-lock-open site-icon"></span>';
												} else if (colObj && colObj.dataIndex == 'revision') {
												gridValue[valAttrb] = dictionaryItem['@attributes'].attr_version;
												}
												else if (colObj && colObj.dataIndex == 'version') {
												 gridValue[valAttrb] = 'V1';
											 } else {
													gridValue[valAttrb] = '';
												}
											});

									var matchedModels = contentTreeDocument.search({
										match : function(nodeInfos) {
											if (dictionaryItem['@id']
													&& nodeInfos.nodeModel.options.id == dictionaryItem['@id']) {
												return true;
											}
										}
									});
									var contentNodeModel;
									var actionNodeModel;
									if (matchedModels.length == 0) {
										if (bActionTreeExists) {
											actionNodeModel = new TreeNodeModel({
												id : dictionaryItem['@id'],
												label : '',
												children : [],
												grid : {
													actionCol : ''
												}
											});
											if (actionTreeDocument) {
												actionTreeDocument.addChild(actionNodeModel);
											}
										}
										var image = '';
										if (dictionaryItem['@attributes'].attr_image) {
											image = dictionaryItem['@attributes'].attr_image;
										}
										var dictionaryItemNode = UWA.clone(dictionaryItem);

										contentNodeModel = new TreeNodeModel({
											id : dictionaryItem['@id'],
											label : treeColVal, // dicoItem.name,
											icons : image ? [ image ] : [], // [dicoItem.get('image')]
											criteriaType : typeOfCriteria,
											children : null,
											grid : gridValue,
											actionNode : actionNodeModel,
											dictionaryItem : dictionaryItemNode
										});

										// addCriteria
										contentTreeDocument.addChild(contentNodeModel);

									} else {
										contentNodeModel = matchedModels[0];
										actionNodeModel = bActionTreeExists ? contentNodeModel.options.actionNode: undefined;
									}

									var optionsDoc = {
										relInfo : {
											parentId : dictionaryItem['@attributes'].parentId,
											parentRelName : dictionaryItem['@attributes'].attr_rel
										},
										getVersions : true,
										onComplete : function(output) {
											var data = output.data;
											if (data) {
												that._loadJsonUpdated(data);
												that.options.selectionData.displayCount = that.getVisibleNodeCount();
												that.options._modelEvents.publish({
													event : 'onDisplayAndSelCountUpdate',
													data : that.options.selectionData,
													context : null
												});
											}
										},
										onFailure : function(result) {
										}
									};
									DocumentManagement.getDocumentsFromParent(optionsDoc);
								},
								removeCriteria : function(subDictionary) {
									var getNode = function(treeNode, id, toBeRemoved) {
										var matchedModels = treeNode.search({
											match : function(nodeInfos) {
												if (nodeInfos.nodeModel.options.id == id) {
													return true;
												}
											}
										});
										var childNode;
										if (matchedModels && matchedModels.length == 1) {
											childNode = matchedModels[0];
										}

										if (toBeRemoved && childNode) {
											if (childNode.options.actionNode) {
												childNode.options.actionNode.remove();
											}
											treeNode.removeChild(childNode);
										}
										return childNode;
									};
									var removeData = [];
 								if (UWA.is(subDictionary, 'array')) {
										removeData.push(subDictionary);
									}
									var rootNode = this.options.treeDocument._getTrueRoot();
									removeData.forEach(function(items) {
										if (UWA.is(items, 'array')) {
											var node = rootNode;
											items.forEach(function(itemId, index) {
												node = getNode(node, itemId, (index == items.length - 1));
											});
										}
									});
									this.options.dictionaryJSON.pop(subDictionary);
								},

								init : function(options) {
									var that = this;
									UWA.extend(options, this.defaults, true);
									options.treeDocument = new TreeDocument(
											{
												useAsyncPreExpand : true,
												shouldAcceptDrop : function(options) {
													return true;
												},
												shouldAcceptDrag : function(draggedNode) {
													return true;
												},
												shouldBeEditable : function(nodeModel) {
													if (nodeModel._options.dictionaryItem != undefined) {
														if (nodeModel._options.dictionaryItem.dataelements!=undefined && nodeModel._options.dictionaryItem.dataelements.reservedby == '') {
															return true;
														}
														if (nodeModel._options.dictionaryItem.dataelements!=undefined && nodeModel._options.dictionaryItem.dataelements.reservedby == DocumentCommonUtils.getLoggedInUser()) {
															return true;
														} else {
															return false;
														}
													} else {
														return true;
													}
												},

												shouldBeSelected : function(nodeModel) {
													return true;
												}
											});
									// call method to register cell content for actions column.
									if (options.withActionsTree == false) {
										if (options.columns) {
											options.columns.push({
												text : '',
												dataIndex : 'actionCol',
												valueAttribute : 'actionCol',
												width : 'auto',
												isSortable : false,
												isEditable : false,
												isSelectable : false,
												onCellRequest : function(cellInfos) {
													if (!cellInfos.isHeader) {
														var reusableContent = cellInfos.cellView.reuseCellContent('_reusableActionsContent');
													}
												}
											});
										}
									}

									this._parent(options);

									this.options._actionsRegContentId = this.options.registerActionsCellContent.call(this);
									// handling selection events
									this.registerSelectionEvents();

									this.dicoVersion = this.options.dicoVersion;
									this.elements.container.style.height = '100%';

									this.options._modelEvents.subscribe({
										event : 'sortBy'
									}, function(event) {
										that.sortByEvent(event);
									});

									this.options._modelEvents.subscribe({
										event : 'onContentFilterCriteriaChange'
									}, function(event) {
										that.applyCriteriaFilterEvent(event);
									});

									this.options._modelEvents.subscribe({
										event : 'addCriteria'
									},
											function(eventData) {
												if (eventData.item) {
													var subDictionary = eventData.item;
													that.addSubDictionary(subDictionary);
													that.options.selectionData.displayCount = that.getVisibleNodeCount();
													that.options._modelEvents.publish({
														event : 'onDisplayAndSelCountUpdate',
														data : that.options.selectionData,
														context : null
													});
												}
											});

									this.options._modelEvents.subscribe({
										event : 'removeCriteria'
									},
											function(eventData) {
												if (eventData.item) {
													var items = eventData.item;
													that.removeCriteria(items);
													that.options.selectionData.displayCount = that.getVisibleNodeCount();
													that.options._modelEvents.publish({
														event : 'onDisplayAndSelCountUpdate',
														data : that.options.selectionData,
														context : null
													});
												}
											});

									if (this.options.withActionsTree) {
										this.options.treeDocument._bindEventOnDocument('postExpand',
												function(modelEvt) {
													if (modelEvt.parent) {
														modelEvt.parent.options.actionNode.expand();
													}
												});
										this.options.treeDocument._bindEventOnDocument('postCollapse',
												function(modelEvt) {
													if (modelEvt.parent) {
														modelEvt.parent.options.actionNode.collapse();
													}
												});
										this.options.treeDocument._bindEventOnDocument('hide', function(
												modelEvt) {
											if (modelEvt.data.nodeModel.options.actionNode)
												{
													modelEvt.data.nodeModel.options.actionNode.hide();
												}
										});

										this.options.treeDocument._bindEventOnDocument('show', function(
												modelEvt) {
											if (modelEvt.data.nodeModel.options.actionNode)
												{
													modelEvt.data.nodeModel.options.actionNode.show();
												}
										});
									}
									this.contentFilter = options.contentFilter;
								},
								sortByEvent : function(event){
								var that = this;
								that.options.treeDocument.prepareUpdate();
								that.options.dictionaryJSON.sort(this.options.sortColumnContent);
								that.options.treeDocument.pushUpdate();
								},
								applyCriteriaFilterEvent: function (event){
									var that = this;
									that.options.treeDocument.prepareUpdate();
									that.options.applyCriteriaFilter_v2.call(that, event);
									that.options.treeDocument.pushUpdate();
								},
								registerSelectionEvents : function() {
									var executeThis = true;
									var that = this;
									if (executeThis) {
										var xso = this.getManager().getDocument().getXSO();
										xso.onAdd(that._onSelectionChange.bind(that));
										xso.onPostAdd(that._onSelectionChange.bind(that));
										xso.onRemove(that._onSelectionChange.bind(that));
									}
								},
								_onSelectionChange : function() {
									this.options._modelEvents.publish({
										event : 'enoxdoc-selection_changed',
										data : this.options.treeDocument.getSelectedNodes()
									});
								},
								/* Function to get tree node model for input dico item */
								getTreeNodeModelFromDicoObject : function(contentsParentNode,
										actionsParentNode, typeOfCriteria, colTypeText, dico) {
									var that = this;
									if (dico && UWA.is(dico, 'array')) {
										var treeNodeArr = [];

										dico.forEach(function(dicoItem) {
											var includeItem = true;
											if (UWA.is(that.contentFilter, 'function')) {
												includeItem = that.contentFilter(dicoItem);
											}
											if (includeItem) {
												var contentNode = that.createTreeNodeFromDicoItem(typeOfCriteria,
														colTypeText, dicoItem);
												contentsParentNode.addChild(contentNode);
												if (actionsParentNode && contentNode.options.actionNode) {
													actionsParentNode.addChild(contentNode.options.actionNode);
												}
											}
										});
									}
								},

								createTreeNodeFromDicoItem : function(typeOfCriteria, colTypeText,
										dicoItem) {
									var that = this;
									var colsArray = this.options.columns;
									var bActionTreeExists = this.options.actionsTreeListView ? true: false;
									var treeColVal = '';
									var gridValue = {};
									var loggedInUser = '';
									var serviceURL = that.getPlatformServiceURL('3DSpace');
									if (serviceURL == '') {
										serviceURL = that.getPlatformServiceURL('3DSpace');
									}
									i3DXCompassPlatformServices.getUser({
										onComplete : function(data) {
											loggedInUser = data.id;
										}
									});
									colsArray.forEach(function(colObj) {
												var valAttrb = colObj.valueAttribute;
												if (colObj && colObj.dataIndex == 'tree') {
													treeColVal = dicoItem['dataelements'][valAttrb] ? dicoItem['dataelements'][valAttrb]
															: '';
												} else if (colObj && colObj.dataIndex == 'type') {
													if (dicoItem[valAttrb] == 'Product Specification') {
														dicoItem[valAttrb] = DOC_NLS.DOC_Type_Specification;
													}
													if (dicoItem[valAttrb] == 'Document') {
														dicoItem[valAttrb] = DOC_NLS.DOC_Type_Document;
													}
													gridValue[valAttrb] = dicoItem[valAttrb] ? dicoItem[valAttrb] : '';
												} else if (colObj && colObj.dataIndex == 'owner') {
													if (dicoItem['relateddata']['ownerInfo'][0]['dataelements'] !=undefined){
																gridValue[valAttrb] = dicoItem['relateddata']['ownerInfo'][0]['dataelements']['name'] ? dicoItem['relateddata']['ownerInfo'][0]['dataelements']['name']
															: '';
														}
														else {
															gridValue[valAttrb] ='';
														}
												} else if (colObj && colObj.dataIndex == 'reservedby') {
													if (dicoItem['dataelements'][valAttrb] == '') {
														gridValue[valAttrb] = '<span title='+DOC_NLS.DOC_Unreserve+' class="fonticon fonticon-lock-open site-icon"></span>';
													} else {
														if (dicoItem['dataelements'][valAttrb] == loggedInUser) {
															gridValue[valAttrb] = '<span title=\"'+DOC_NLS.DOC_Reserve_ByMe+'\" class="fonticon fonticon-lock-user site-icon"></span>';
														} else {
															gridValue[valAttrb] = '<span title='+DOC_NLS.DOC_Reserve+' class="fonticon fonticon-lock site-icon"></span>';
														}
													}
												} else if (colObj && colObj.dataIndex == 'revision') {
													gridValue[valAttrb] = dicoItem.dataelements.revision;
												}
												else if (colObj && colObj.dataIndex == 'version') {
											 	if (dicoItem.relateddata.files.length == 1) {
													 if (dicoItem.relateddata.files['0'].relateddata != undefined) {
														 gridValue[valAttrb] = 'V'
																 + (dicoItem.relateddata.files['0'].relateddata.versions.length + 1);
													 } else {
														 gridValue[valAttrb] = 'V1';
													 }
												 } else if (dicoItem.relateddata.files.length == 0) {
													 gridValue[valAttrb] = 'V0';
												 }
												 else {
													   gridValue[valAttrb] = '<span title='+DOC_NLS.DOC_MULTIPLE_FILE_VERSIONS+' class="wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-media-gallery"></span>';
												 }
											 } else {
													gridValue[valAttrb] = dicoItem['dataelements'][valAttrb] ? dicoItem['dataelements'][valAttrb]
															: '';
												}
											});

									var image = '';
									if (dicoItem['dataelements']['image']) {
										if (dicoItem.type == 'Document') {
											image = serviceURL + "/" + "common/images/iconSmallDocument.gif";
										}
										else if (dicoItem.type == 'Specification') {
											image = serviceURL + "/"
													+ "common/images/iconSmallSpecification.gif";
										}
										else {
											if (dicoItem["dataelements"]['image'].indexOf('fcs')!=-1){
												image = serviceURL + "/"
														+ "common/images/utilDetailsTreeBlank.gif";
											}
											else {
												image = dicoItem['dataelements']['image'];
											}
										}
									}
									dicoItem.id = dicoItem['id'];
									var tmpTreeNode = new TreeNodeModel({
										id : dicoItem.id,
										label : treeColVal,
										icons : image ? [ image ] : [],
										criteriaType : '',
										dictionaryItem : UWA.clone(dicoItem),
										children : null,
										grid : gridValue,
										actionNode : bActionTreeExists ? new TreeNodeModel({
											id : dicoItem.id,
											label : '',
											children : [],
											grid : {
												actionCol : ''
											}
										}) : undefined
									});
									return tmpTreeNode;
								},
						getPlatformServiceURLOnComplete : function(data, service){
							var platformServices = data[0];
							var serviceURL = platformServices[service];
							return serviceURL;
						},
						getPlatformServiceURL : function(service) {
							var that = this;
							var serviceURL = '';
							i3DXCompassPlatformServices.getPlatformServices({
								onComplete : function(data) {
									serviceURL = that.getPlatformServiceURLOnComplete(data, service);
								}
							});
							return serviceURL;
						}
					});

			return tableView;
		});
