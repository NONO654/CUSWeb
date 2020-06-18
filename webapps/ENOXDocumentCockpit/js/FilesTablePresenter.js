/*XSS_CHECKED*/
define(
	'DS/ENOXDocumentCockpit/js/FilesTablePresenter',
	['UWA/Class/View', 'UWA/Class/Listener', 'DS/Tree/TreeNodeModel',
		'DS/Tree/TreeListView', 'DS/Tree/TreeDocument', 'DS/Controls/Button',
		'DS/Core/ModelEvents', 'DS/UIKIT/DropdownMenu', 'DS/Controls/Toggle',
		'DS/Controls/SpinBox', 'DS/Core/PointerEvents',
		'DS/xPortfolioUXCommons/util/ScrollUtil',
		'DS/xPortfolioUXCommons/NotificationsUtil/xNotificationsUtil',
		'DS/UIKIT/Mask',
		'i18n!DS/ENOXDocumentCockpit/assets/nls/DocumentCockpit',
		'css!DS/UIKIT/UIKIT.css'],
	function (View, Listener, TreeNodeModel, TreeListView, TreeDocument,
		WUXButton, ModelEvents, IconDropdown, Toggle, SpinBox, PointerEvents,
		ScrollUtil, xNotificationsUtil, Mask, Document_NLS) {

	"use strict";
	var tableView = View
		.extend({
			tagName: 'div',
			className: 'generic-detail',
			params: {},

			init: function (options) {
				var that = this;
				UWA.extend(options, this.defaults, true);

				this._modelEvents = new ModelEvents();

				if (options.modelEvents) {
					this.modelEvents = options.modelEvents;
				}
				if (undefined == options.withActionsTree)
					options.withActionsTree = true;

				// if actions options defined then only show actions tree list view.
				if (options.actions && options.withActionsTree) {
					this.actionsTreeListView = new ActionsTreeListView({
							actions: options.actions,
							withActionsTree: options.withActionsTree,
							_modelEvents: this._modelEvents,
							registerActionsCellContent: this.customRegisterReusableCellContent,
							showScrollbarsOnHover: false
						})
				}
				this.tableListView = new contentTreeListView(
						UWA
						.merge({
							viewIdentifier: options.viewIdentifier,
							dataJSON: options.dataJSON,
							kind: options.kind,
							actionsTreeListView: (options.withActionsTree && this.actionsTreeListView) ? this.actionsTreeListView
							 : undefined,
							_modelEvents: this._modelEvents,
							getAllChildrenOnParentSelection: options.getAllChildrenOnParentSelection,
							getParentOnChildSelection: options.getParentOnChildSelection,
							actions: options.actions,
							registerActionsCellContent: this.customRegisterReusableCellContent,
							withActionsTree: options.withActionsTree,
							contentFilter: options.contentFilter,
							showScrollbarsOnHover: true,
							onDropCell: this._handleOnDrop.bind(that),
							performances: {
								resizeDebounceTimeout: 100,
							}
						}, options.contentTreeOptions)); // tmp : content tree options

				this._parent(options);

				// Call to load the dictionary by creating tree nodes.
				this.tableListView._loadDictionaryJsonUpdated.call(this.tableListView);
				this.tableListView.options.selectionData.displayCount = this.tableListView.options.selectionData.totalCount = this.tableListView
					.getNodeCount(this.tableListView);

				this.manageTreeListViewScrolling();

				if (UWA.is(options.actions, 'array')) {
					options.actions.forEach(function (action) {
						var eventName = action.event;
						if (eventName) {
							that.subscribe('internal_' + eventName, function (eventData) {
								console.log("Internal On Event Action : " + eventData.toString());
								var subDico = '';

								var item = {};
								if (eventData) {
									var actionNode = eventData.nodeModel ? eventData.nodeModel
										 : that.tableListView.getManager().getTreeNodeModelFromRowID(
											eventData.nodeRowID);
									if (actionNode) {
										item = actionNode.options.dictionaryItem;
									}
								}
								UWA.merge(subDico, {
									item: item
								});
								that._modelEvents.publish({
									event: eventName,
									data: item,
									context: null
								})
							});
						}
					});

				}

			},

			_handleOnDrop: function (dragEvent, dropInfos) {
				console.log('_handleOnDrop');
				var that = this;
				var docId = dropInfos.nodeModel._options.dictionaryItem.docId;
				var fileList = dragEvent.dataTransfer.files;
				if (fileList.length > 1) {
					xNotificationsUtil.showError(Document_NLS.DOC_Multi_Files_Selected);
					var dropInvite = document.getElement('.documents-presenter li.wux-layouts-gridengine-columns-header-container #droppable');
					dropInvite.addClassName('hidden');
					dropInvite.removeClassName('show');
					dropInvite.removeClassName('droppable');
				} else {
					that.options._containerInstance.uploadDocument(docId, fileList);
				}
			},
			render: function () {
				var that = this;
				this.container.style.height = '100%';
				this.container.style.display = 'flex';
				var tableListViewDiv = UWA.createElement('div', {
						styles: {
							width: 'calc( 100% - 30px )',
							height: '100%',
							display: 'inline-block'
						}
					});
				tableListViewDiv.addContent(this.tableListView);
				this.container.addContent(tableListViewDiv);

				if (this.options.withActionsTree && this.actionsTreeListView) {
					var actionsListViewDiv = UWA.createElement('div', {
							styles: {
								width: '30px',
								height: '100%',
								display: 'inline-block'
							}
						});
					actionsListViewDiv.addContent(this.actionsTreeListView);
					this.actionsTreeListView.elements.container.setStyle('display',
						'inline');
					this.container.addContent(actionsListViewDiv);

					// To keep the action columns size constant
					this.actionsTreeListView
					.getManager()
					.onReady(
						function () {
						var scrollerContainer = that.actionsTreeListView.getContent()
							.getElement('.wux-layouts-gridengine-scroller-container');
						var observer = new MutationObserver(
								function (records) {
								records
								.forEach(function (record) {
									if (record.attributeName == 'has-overflow-y') {
										if (record.target.attributes["has-overflow-y"].nodeValue == 'true') {
											// tableListViewDiv.setStyle('width', 'calc( 100% - 46px
											// )');
											// actionsListViewDiv.setStyle('width', '46px');
											tableListViewDiv.setStyle('width', 'calc( 100% - 26px )');
											actionsListViewDiv.setStyles({
												'width': '46px',
												marginLeft: '-20px'
											});
										} else {
											tableListViewDiv.setStyle('width', 'calc( 100% - 30px )');
											actionsListViewDiv.setStyles({
												'width': '30px',
												marginLeft: '0px'
											});
										}
									}
								});
							});

						observer.observe(scrollerContainer, {
							attributes: true
						});
					});
				}
				// Publish the event so as to display count information on render.
				this.publish('onDisplayAndSelCountUpdate',
					this.tableListView.options.selectionData, null);
				return this;
			},

			manageTreeListViewScrolling: function () {
				// if we dont have actions or if we dont have separate actions tree list
				// view then return.
				var that = this;
				if (!this.options.actions
					 || (UWA.is(this.options.actions, 'array') && this.options.actions.length === 0)
					 || !this.options.withActionsTree)
					return;

				var contentTableManager = this.tableListView.getManager();
				var actionsTableManager = this.actionsTreeListView ? this.actionsTreeListView
					.getManager()
					 : undefined;
				var contentReadyPromise = new UWA.Promise(function (resolve, reject) {
						contentTableManager.onReady(resolve);
					});
				var actionsReadyPromise = new UWA.Promise(function (resolve, reject) {
						actionsTableManager.onReady(resolve);
					});

				UWA.Promise
				.all([contentReadyPromise, actionsReadyPromise])
				.then(
					function () {
					var contentScroller = that.tableListView.getManager().elements.scroller;
					var actionsScroller = that.actionsTreeListView.getManager().elements.scroller;

					contentScroller.elements.container.setStyle('overflow-y', 'hidden');
					actionsScroller.elements.container.setStyle('overflow-x',
						'disabled');

					contentScroller.elements.container
					.addEvent(
						'wheel',
						function (event) {
						event.preventDefault();
						// when pooled rows count is less or equal to total rows,
						// return as no need to scroll.
						if (contentTableManager.getPoolNumberOfRows() == (contentTableManager
								.getNumberOfRows() - 1)) {
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
							'x': 0,
							'y': -actionsScroller.elements.container.scrollTop
						}, false);

						actionsScroller._modelEvents.publish({
							event: 'SCROLL',
							context: actionsScroller,
						});
					});

					// Action Scroll Event
					actionsScroller
					.onScroll(function (event) {
						var actionPos = this.getPosition();
						var contentPos = that.tableListView.getManager().elements.scroller
							.getPosition();
						// console.log('[actionsScroller.onScroll] Y Pos old: ' +
						// contentPos.y + ' Y Pos new: ' + actionPos.y);
						that.tableListView.getManager().elements.scroller.setPosition({
							'x': 0,
							'y': actionPos.y
						}, false);

						that.tableListView.getManager().elements.scroller.elements.container.scrollTop = Math
							.abs(actionPos.y);
						that.tableListView.getManager().elements.scroller.elements.container.scrollLeft = Math
							.abs(contentPos.x);
						that.tableListView.getManager().elements.scroller._modelEvents
						.publish({
							event: 'SCROLL',
							data: {
								originatedFrom: 'ActionScroller',
							},
							context: that.tableListView.getManager().elements.scroller,
						});
					});
				});

			},

			// function to subscribe to events, from this UI.
			subscribe: function (eventName, callback) {
				if (this._modelEvents) {
					this._modelEvents.subscribe({
						event: eventName
					}, callback);
				}
			},

			// Function to publis events from this UI.
			publish: function (eventName, eventData, context) {
				if (this._modelEvents) {
					this._modelEvents.publish({
						event: eventName,
						data: eventData,
						context: context
					});
				}
			},
			// Call this function with call/apply so as to pass the context
			customRegisterReusableCellContent: function () {
				var that = this;
				var reusableCntId = '_reusableActionsContent';
				if (UWA.is(this.options.actions, 'array')) {
					if (this.options.actions.length == 1) {
						var action = this.options.actions[0];
						that
						.getManager()
						.registerReusableCellContent({
							id: reusableCntId, // '_' + action.icon + 'ActionBtn', //NOTE: to
							// be configurable for deleteAction

							buildContent: function () {
								var actionBtn = new WUXButton({
										icon: action.fonticon, // 'plus',
										displayStyle: 'lite',
										label: action.title,
										showLabelFlag: false,
                                        allowUnsafeHTMLLabel : false
									});
							//	actionBtn.getContent().setStyle('margin-right', '10');
								actionBtn
								.getContent()
								.addEvent(
									'click',
									function () {
									var cellInfos = this.parentNode.dsView.getCellInfos();
									if (cellInfos) {
										that.options._modelEvents
										.publish({
											event: "internal_" + action.event, // 'onAddAction',
											// VERY IMP: DO CHECK IF ACTION NODE GIVES PROPER ID IN
											// CASE OF SORT in CONTENT TREE???
											data: {
												nodeRowID: that.options.withActionsTree ? cellInfos.virtualRowID
												 : undefined, // From Row id we can calculate the
												// corresponding node from content tree.
												nodeModel: !that.options.withActionsTree ? target.parentNode.dsView
												._getNodeModel()
												 : undefined,
											},
											context: null
										});
									}
								});
								return actionBtn;
							}
						});
					} else {
						var subActions = [];
						this.options.actions.forEach(function (action) {
							subActions.push({
								selected: action.selected ? action.selected : false,
								fonticon: action.fonticon,
								description: action.description,
								title: action.title ? action.title : '',
								text: action.text ? action.text : action.title ? action.title : '',
								'event': action.event ? action.event : undefined
							});
						});
						this
						.getManager()
						.registerReusableCellContent({
							id: reusableCntId, // NOTE: to be configurable for deleteAction
							buildContent: function (cellView) {
								var actionBtn = new WUXButton({
										// icon: 'open-down', //'plus',
										icon: {
											iconName: 'angle-down'
										},
										displayStyle: 'lite',
										// label : action.title,
										showLabelFlag: false
									});
								actionBtn
								.addEventListener(
									'buttonclick',
									function (event) {
									console.log('on event');
									var actionButton = event.dsModel;
									var cellInfos = this.parentNode.dsView.getCellInfos();
									if (cellInfos) {
										var data = {
											nodeRowID: that.options.withActionsTree ? cellInfos.virtualRowID
											 : undefined, // From Row id we can calculate the
											// corresponding node from content tree.
											nodeModel: !that.options.withActionsTree ? this.parentNode.dsView
											._getNodeModel()
											 : undefined,
										}
										actionButton.actionDropdown.data = data;
									}
								});
								actionBtn.actionDropdown = new IconDropdown({
										target: actionBtn.getContent(),
										renderTo: widget ? widget.body : document.body,
										items: subActions,
										bound: true,
										// contextual: true,
										position: 'bottom left',
										offset: {
											x: 0,
											y: 0
										},
										events: {
											onClick: function (e, item) {
												// console.log('target : ' + target);
												if (item.event) {
													that.options._modelEvents.publish({
														event: "internal_" + item.event, // 'onAddAction',
														data: this.data,
														context: null
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
				return '_reusableActionsContent'; // content id
			}
		});

	// Actions Icon Tree List View.
	var ActionsTreeListView = TreeListView
		.extend(
			Listener, {
			defaults: {
				apiVersion: 2,
				height: '100%',
				width: '20%',
				display: 'inline',
                allowUnsafeHTMLContent : false,
				columns: [{
						text: '',
						dataIndex: 'tree',
						isHidden: true,
						width: '0',
					},
					{
						text: '',
						dataIndex: 'actionCol', // NOTE: Make it customizable.
						width: '29',
						isSortable: false,
						isEditable: false,
						isSelectable: false,
						// Whenever column is rendered it will call this function to request
						// cell content.
						onCellRequest: function (cellInfos) {
							if (!cellInfos.isHeader) {
								var reusableContent = cellInfos.cellView
									.reuseCellContent('_reusableActionsContent'); //
							}
						}
					}
				],

				selection: {
					nodes: false,
					cells: false,
					rowHeaders: false,
					columnHeaders: false,
					unselectAllOnEmptyArea: false,
					toggle: true,
					canMultiSelect: false
				},
			},

			init: function (options) {
				var that = this;

				UWA.extend(options, this.defaults, true);

				options.treeDocument = new TreeDocument({
						useAsyncPreExpand: true, // Preferably set to true...
						shouldAcceptDrop: function (options) {
							return false;
						},
						// Draggable?
						shouldAcceptDrag: function (draggedNode) {
							return false;
						},
						// makes row editable and selectable by checkbox.
						shouldBeEditable: function (nodeModel) {
							return false;
						},
						shouldBeSelected: function (nodeModel) {
							return false;
						}
					});
				this._parent(options);

				// call method to register cell content for actions column.
				this.options._actionsRegContentId = this.options.registerActionsCellContent
					.call(this);
			},
		});
	// Content tree list view definition.
	var contentTreeListView = TreeListView
		.extend(
			Listener, {
			defaults: {
				treeDocument: {},
				apiVersion: 2,
				height: '100%',
				width: '80%',
				// display : 'inline-block',
                allowUnsafeHTMLContent : true,
				expanderStyle: 'triangle',
				selection: {
					nodes: true,
					cells: false,
					rowHeaders: true,
					columnHeaders: true,
					unselectAllOnEmptyArea: true,
					toggle: true,
					canMultiSelect: true
				},
				node: [],

				criteriaFilters: {
					searchData: {},
					searchText: '',
				},
				events: {
					// coming from custom multi select handler.
					onChangeSelection: function (selCount) {
						var that = this;
						this.options._modelEvents.publish({
							event: 'onDisplayAndSelCountUpdate',
							data: this.options.selectionData,
							context: null
						});
					},
				},
				// new implementation:
				applyCriteriaFilter_v2: function (event) {
						var that = this;
						var taggerData = event.filterData.TaggerValues;
						var ContextSearchData = event.filterData.ContextSearchValues;
						var GlobalSearchData = event.filterData.GlobalSearchValues;
						var searchText = UWA.is(event.filterData.searchValue, 'array') ? event.filterData.searchValue[0] : event.filterData.searchValue;
						searchText = searchText ? searchText.toLowerCase() : undefined;
						var checkBoxSts = event.filterData.typeFilter ? event.filterData.typeFilter : undefined;

						var rootNodesArr = this.options.treeDocument.getRoots();
						console.log("TreeDocument Root Nodes Count: " + rootNodesArr.length);
						var tmpTotalNodes = 0;
						var tmpTotalChildNodes = 0;
						var hiddenNodeCount = 0;
						tmpTotalNodes = rootNodesArr.length;
						var filterType = null;
						var filterValues = null;
						if(taggerData){// && taggerData.length>0){
							filterType = "TaggerValues";
							filterValues = taggerData;
						}else{
							if(ContextSearchData){// && ContextSearchData.length>0){
								filterType = "ContextSearchValues";
								filterValues = ContextSearchData;
							}else {
								if(GlobalSearchData){// && GlobalSearchData.length>0){
									filterType = "GlobalSearchValues";
									filterValues = GlobalSearchData;
								}
							}
						}
						if (rootNodesArr && rootNodesArr.length > 0) {
								rootNodesArr.filter(function(rootNode) {
									if(filterType !== null){
										if(!rootNode.xFiltersMerge){
											rootNode.xFiltersMerge = {};
										}
										var pid = rootNode._options.dictionaryItem.id;
										if (filterValues.indexOf(pid) != -1){
											rootNode.xFiltersMerge[filterType] = true;
										}else{
											rootNode.xFiltersMerge[filterType] = false;
										}
									}
								if(searchText && searchText.length>0){
									var updateCountAndReturn = false;
												var rootNodeLabel = rootNode.getLabel().toLowerCase();
												var childNodesArr = rootNode.getChildren();
												if (checkBoxSts) {
														if (checkBoxSts[rootNode.options.criteriaType] == false && !rootNode.isHidden()) {
																rootNode.hide();
																updateCountAndReturn = true;
														} else if (checkBoxSts[rootNode.options.criteriaType] == true && rootNode.isHidden() && rootNodeLabel.contains(searchText)) {
																rootNode.show();
																if (searchText == "" && (childNodesArr == null || childNodesArr.length < 0)) {
																		updateCountAndReturn = true;
																}
														} else if (checkBoxSts[rootNode.options.criteriaType] == false && rootNode.isHidden()) {
																return;
														} else if (checkBoxSts[rootNode.options.criteriaType] == true && !rootNode.isHidden()) {
																if (searchText == "" && (childNodesArr == null || childNodesArr.length < 0)) {
																		updateCountAndReturn = true;
																}
														}
														if (updateCountAndReturn) {
																return;
														}
												}
												var filteredNodes = [];

												if (childNodesArr && childNodesArr.length > 0) {
														tmpTotalChildNodes += childNodesArr.length;
														filteredNodes = childNodesArr.filter(function(childNode) {
																var childNodeLabel = childNode.getLabel().toLowerCase();
																if (childNodeLabel.contains(searchText)) {
																		if (childNode.isHidden()) {
																				childNode.show();
																		}
																		return true;
																} else {
																		if (!childNode.isHidden()) {
																				childNode.hide();
																		}
																		return false;
																}
														});
												}
												if (rootNode.isHidden() &&
														(rootNodeLabel.contains(searchText) || filteredNodes.length > 0)) {
														rootNode.show();
												} else if (!rootNode.isHidden() &&
														(!rootNodeLabel.contains(searchText) && filteredNodes.length <= 0)) {
														rootNode.hide();
												}
									}
								});
								if(filterType !== null){
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
					if(rootNode.xFiltersMerge){
						var isFiltered = true;
						Object.keys(rootNode.xFiltersMerge).forEach(function(key) {
							if(rootNode.xFiltersMerge[key] == false){
								isFiltered = false;
							}
						});
						if (isFiltered){
							rootNode.show();
						}else{
							rootNode.hide();
						}
					}
				});
					}
				},

			getNodeCount: function () {
				function _countNodes(inputNode) {
					var count = 0;
					if (inputNode && inputNode.hasChildren()) {
						var count = inputNode.getChildren().length;
						inputNode.getChildren().forEach(function (node) {
							count += _countNodes(node);
						})
					}
					return count;
				}
				var nodeCount = 0;

				if (this.options.treeDocument) {
					var nodeCount = _countNodes(this.options.treeDocument._getTrueRoot());
				}
				return nodeCount;
			},

			getVisibleNodeCount: function () {
				// recursive function.
				function _countVisibleNodes(inputNode) {
					var count = 0;
					// Dont count if node's parent is null, that means its the true root
					// node.
					if (inputNode.getParent() != null && !inputNode.isHidden())
						count++;

					var childNodesArr = inputNode.getChildren();
					if (childNodesArr) {
						childNodesArr = (UWA.is(childNodesArr, 'array') && childNodesArr.length > 0) ? childNodesArr
						 : null;
						// Iterate each child node and find if it has children which are
						// visible.
						childNodesArr.forEach(function (childNode) {
							if (childNode && !childNode.isHidden()) {
								if (childNode.getChildren()
									 && (childNode.getChildren().length > 0)) {
									count += _countVisibleNodes(childNode); // check if childnode has
									// any visible children
									// iteratively.
								} else { // if no children for this node then increament count for
									// this node.
									count += 1;
								}
							}
						});
					}
					return count;
				}
				var nodeCount = 0;
				if (this.options.treeDocument) {
					nodeCount = _countVisibleNodes(this.options.treeDocument
							._getTrueRoot());
				}
				return nodeCount;
			},
			_loadDictionaryJsonUpdated: function (data) {
				console.log('Loading dictionary');
				var that = this;
				if (data) {
					this.options.dataJSON = data;
				}
				this.options.treeDocument.prepareUpdate();
				if (this.options.actionsTreeListView) {
					this.options.actionsTreeListView.options.treeDocument.prepareUpdate();
				}
				var actionsTreeRootNode = this.options.actionsTreeListView ? this.options.actionsTreeListView.options.treeDocument
					._getTrueRoot()
					 : undefined;
				var contentTreeRootNode = this.options.treeDocument._getTrueRoot();

				this.options.treeDocument.empty();
				if (actionsTreeRootNode) {
					this.options.actionsTreeListView.options.treeDocument.empty();
				}
				var dictionaryItems = this
					.getFilesDetailsFromDocument(this.options.dataJSON);
				this.getTreeNodeModelForFiles(contentTreeRootNode,
					actionsTreeRootNode, dictionaryItems);
				this.options.treeDocument.pushUpdate();
				if (this.options.actionsTreeListView) {
					this.options.actionsTreeListView.options.treeDocument.pushUpdate();
				}

			},
			getFilesDetailsFromDocument: function (data) {
				var dictionaryItems = [];
				var docId = data.id;
				var versions = '';
				if (data) {
					console.log('Passed 1' + data);

					var fileDetails = UWA.is(data.relateddata.files, 'array') ? data.relateddata.files
						 : false;
					if (fileDetails && fileDetails.length > 0) {
						console.log('Passed 2' + fileDetails);
						for (var i = 0; i < fileDetails.length; i++) {
							if (fileDetails[i].relateddata.versions) {
								versions = UWA.is(fileDetails[i].relateddata.versions, 'array') ? fileDetails[i].relateddata.versions
									 : false;
							}
							var version = 1;
							if (versions && versions.length > 0) {
								version = versions.length + 1;
							}
							console.log('in file loop');
							var fileId = fileDetails[i]['id'];
							var filesAttributes = fileDetails[i]['dataelements'];
							var data = {
								fileId: fileId,
								filesAttributes: filesAttributes
							};
							dictionaryItems.push({
								type: 'Files',
								id: fileId,
								data: data,
								version: 'V' + version,
								docId: docId
							})
							if (versions && versions.length > 0) {
								console.log('passed 3' + fileDetails);
								for (var j = versions.length - 1; j >= 0; j--) {
									version = j + 1;
									console.log('in version loop');
									var fileId = versions[j]['id'];
									var filesAttributes = versions[j]['dataelements'];
									var data = {
										fileId: fileId,
										filesAttributes: filesAttributes
									};
									dictionaryItems.push({
										type: 'Files',
										id: fileId,
										data: data,
										version: 'V' + version,
										docId: docId
									})
								}
							}
						}
					}
				}

				return dictionaryItems;
			},

			getTreeNodeModelForFiles: function (contentsParentNode,
				actionsParentNode, dictionaryObjects) {
				var that = this;
				if (dictionaryObjects && UWA.is(dictionaryObjects, 'array')) {
					var treeNodeArr = [];
					for (var k = 0; k < dictionaryObjects.length; k++) {
						var fileId = dictionaryObjects[k]['id'];
						var contentNode = that.createTreeNodeForFiles(
								dictionaryObjects[k]['type'], dictionaryObjects[k]['version'],
								dictionaryObjects[k], dictionaryObjects[k].data);
						if (contentNode) {
							contentsParentNode.addChild(contentNode);
							if (actionsParentNode && contentNode.options.actionNode) {
								actionsParentNode.addChild(contentNode.options.actionNode);
							}
						}
					}
				}
			},

			createTreeNodeForFiles: function (type, version,
				dictionaryItem, data) {
				var that = this;
				var Reserve_Unreserve = that.options.dataJSON.dataelements['reservedby'];
				var status_Icon = "";
				if (Reserve_Unreserve != undefined) {
					if (Reserve_Unreserve == "") {
						status_Icon = '<span title='+Document_NLS.DOC_Command_Unreserve+' class="fonticon fonticon-lock-open site-icon"></span>';
					} else {
						status_Icon = '<span title=\''+Document_NLS.DOC_Tooltip_Reserve+'\' class="fonticon fonticon-lock-user site-icon"></span>';
					}

				}
				var colsArray = this.options.columns;
				var bActionTreeExists = this.options.actionsTreeListView ? true
					 : false;
				var treeColVal = '';
				var gridValue = {};

				var dicoItem = dictionaryItem;
				colsArray
				.forEach(function (colObj) {
					var dataIndex = colObj.dataIndex;
					if (colObj && colObj.dataIndex == "tree") {
						treeColVal = data.filesAttributes['title'] ? data.filesAttributes['title']
							 : '';
					} else if (colObj && colObj.dataIndex == "version") {
						gridValue[dataIndex] = version;
					} else if (colObj && colObj.dataIndex == "status") {
						gridValue[dataIndex] = status_Icon;
					} else {
						gridValue[dataIndex] = '';
					}
				});

				var image = "";
				if (dicoItem.attributes && dicoItem.attributes._image) {
					image = dicoItem.attributes._image.value;
				}

				var tmpTreeNode = new TreeNodeModel({
						id: dicoItem.id,
						label: treeColVal, // dicoItem.name,
						icons: image ? [image] : [], // [dicoItem.get('image')]
						criteriaType: type,
						dictionaryItem: UWA.clone(dicoItem),
						children: null,
						grid: gridValue,
						data: data,
						actionNode: bActionTreeExists ? new TreeNodeModel({
							id: dicoItem.id,
							label: '',
							children: [],
							grid: {
								actionCol: '',
							}
						}) : undefined,
					});

				return tmpTreeNode;
			},

			init: function (options) {
				var that = this;

				UWA.extend(options, this.defaults, true);

				options.treeDocument = new TreeDocument({
						useAsyncPreExpand: true, // Preferably set to true...

						shouldAcceptDrop: function (options) {
							return false;
						},

						// Draggable?
						shouldAcceptDrag: function (draggedNode) {
							return true;
						},
						// makes row editable and selectable by checkbox.
						shouldBeEditable: function (nodeModel) {
							return false; // no checkboxes.
						},

						shouldBeSelected: function (nodeModel) {
							return true; // /selection expand collapse row id issue. so set to
							// false.
						},
					});
				if (options.columns) {
					var columns = UWA.clone(options.columns);
					columns
					.forEach(function (column) {
						if (column.kind) {
							if (column.kind == options.kind) {
								column.isHidden = false;
							} else {
								column.isHidden = true;
							}
						}
					});
					options.columns = columns;
				}

				// call method to register cell content for actions column.
				if (options.withActionsTree == false) {
					if (options.columns) {
						options.columns.push({
							text: '',
							dataIndex: 'actionCol', // NOTE: Make it customizable.
							valueAttribute: 'actionCol', // NOTE: Make it customizable.
							width: 'auto',
							isSortable: false,
							isEditable: false,
							isSelectable: false,
							// Whenever column is rendered it will call this function to request
							// cell content.
							onCellRequest: function (cellInfos) {
								if (!cellInfos.isHeader) {
									var reusableContent = cellInfos.cellView
										.reuseCellContent('_reusableActionsContent'); //
								}
							}
						});
					}
				}

				this._parent(options);

				this.options._actionsRegContentId = this.options.registerActionsCellContent
					.call(this);
				this.elements.container.style.height = '100%';

				this.options._modelEvents.subscribe({
					event: 'onDownloadAction'
				}, function (eventData) {
					if (eventData.item) {
						var criteria = eventData.item;
						console.log('criteria---------' + criteria)
					}
				});

				this.options._modelEvents.subscribe({
					event: 'onContentFilterCriteriaChange'
				}, function (event) {
					that.options.treeDocument.prepareUpdate();
					that.options.applyCriteriaFilter_v2.call(that, event);
					that.options.treeDocument.pushUpdate();
				});
				//
				// if (this.options.withActionsTree) {
				// 	this.options.treeDocument._bindEventOnDocument('postExpand',
				// 		function (modelEvt) {
				// 		// console.log('Content tree: post expand event');
				// 		if (modelEvt.parent) {
				// 			modelEvt.parent.options.actionNode.expand();
				// 		}
				// 	});
				// 	// Post Collapse on content tree collapse action nodes from actions
				// 	// tree.
				// 	this.options.treeDocument._bindEventOnDocument('postCollapse',
				// 		function (modelEvt) {
				// 		// console.log('Content tree: post collapse event');
				// 		if (modelEvt.parent) {
				// 			modelEvt.parent.options.actionNode.collapse();
				// 		}
				// 	});
				// 	// Hide event on content tree will hide associated action node.
				// 	this.options.treeDocument._bindEventOnDocument('hide', function (
				// 			modelEvt) {
				// 		// console.log('Content tree: node hide event');
				// 		if (modelEvt.data.nodeModel.options.actionNode);
				// 		modelEvt.data.nodeModel.options.actionNode.hide();
				// 	});
				// 	// Show event on content tree node will show associated action node
				// 	// from actions tree.
				// 	this.options.treeDocument._bindEventOnDocument('show', function (
				// 			modelEvt) {
				// 		// console.log('Content tree: node show event');
				// 		if (modelEvt.data.nodeModel.options.actionNode);
				// 		modelEvt.data.nodeModel.options.actionNode.show();
				// 	});
				// }

				this.contentFilter = options.contentFilter;

			},
			onChangeAttribute: function (changeObject) {
				console.log();
				this.options._modelEvents.publish({
					event: 'onChangeAttribute',
					data: changeObject
				});
			}

		}); // End of Content tree list view.

	return tableView;
});
