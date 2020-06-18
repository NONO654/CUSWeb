/*--
[xs-data-tree-view JS Document]
*/
/* global Polymer*/
(function (window) {
	'use strict';
	require(['DS/Tree/TreeListView',
		'DS/Tree/TreeNodeModel',
		'DS/Tree/TreeDocument',
		'css!DS/SMAProcXSUI/xs-data-tree-view/xs-data-tree-view.css',
		'css!DS/UIKIT/UIKIT.css'
	],
	function (TreeListView, TreeNodeModel, TreeDocument) {
		var ARRAY_DIMENSION,
			TYPE,
			DATA_TYPE,
			VALUE_TYPE,
			EVENT;
			//Enums

		EVENT = {
			DATASELECTED: 'xs-data-tree-view-dataselected',
			ATTACHED: 'xs-data-tree-view-attached',
			LOADED: 'xs-data-tree-view-loaded'
		};

		TYPE = {
			Content: 'content',
			Activity: 'Activity',
			Simulation: 'Simulation'
		};

		//Custom Data Types
		//try to make it genric and easy to understand
		DATA_TYPE = {
			refcontent: 'chooser',
			string: 'string'
		};

		//valuetype exposed by iosummaryview/execution options
		VALUE_TYPE = {
			single: 'single',
			singleval: 'singleval',
			multi: 'multival',
			array: 'array'
		};

		//Array Dimension
		ARRAY_DIMENSION = {
			one: '1D',
			two: '2D',
			three: '3D',
			four: '4D'
		};

		Polymer({ // jshint ignore:line

			is: 'xs-data-tree-view',

			properties: {
				//Input - takes data in tree structures as defined by TreeListView
				data: {
					type: Object,
					observer: '__dataChanged'
				},

				//Input - key value array which filters data as valid or invalid
				dataFilterKey: {
					type: String,
					observer: '__dataFilterKeyChanged',
					notify: true
				},

				//Input - Highlight following key
				selectedKey: {
					type: String,
					observer: '__selectedKeyChanged'
				},

				//Input - key value Array for which a badge has to be shown
				allAssociatedKeys: {
					type: Array,
					observer: '__allAssociatedKeysChanged'
				},

				//Output - Currently selected item in TreeListView
				selectedItem: {
					type: Object
				},

				//Is that Selection valid based on canAssociate function
				isValidSelection: {
					type: Boolean,
					value: false,
					notify: true
				},

				//Private Variable to hold search key
				_searchKey: {
					type: String,
					notify: true
				},

				//Private Variable - holds selection to show all or only valid
				_showOnlyValidSelection: {
					type: Boolean,
					value: true,
					observer: '__showOnlyValidSelectionChanged'
				},

				//List of items having matched list based on search key
				_matchedItems: {
					type: Array,
					computed: '__computeMatchedItems(_searchKey)',
					observer: '__matchedItemsChanged'
				},

				//valid tree nodes based on dataFilterKey
				_validItems: {
					type: Array,
					observer: '__validItemsChanged',
					value: []
				},

				//Cache for storing valid tree nodes
				_validItemsCache: {
					type: Object,
					value: {}
				},

				//store only valid items i.e. this list will be free of all intermediate nodes made valid later
				_strictlyValidItems: {
					type: Array,
					value: []
				},

				//cache for storing strictly valid tree nodes
				_strictlyValidItemsCache: {
					type: Object,
					value: {}
				},

				//TreeListView Object Refrence
				_tree: {
					type: Object
				},

				_model: {
					type: Object
				},

				//cache for searches performed for showAll
				_searchedKeysCache: {
					type: Object,
					value: {}
				},

				//Old Internal Array to be used to show those items
				_oldValidItems: {
					type: Array,
					value: []
				},

				//Show loading or not
				_state: {
					value: '0'
				},

				//Flag for showing tree view
				_hideTreeModel: {
					type: Boolean,
					value: false,
					notify: true
				}

			},

			attached: function () {
				this.fire(EVENT.ATTACHED);
			},

			//Input Data changed
			__dataChanged: function () {
				var that = this,
					manager;
				this.$.content.innerHTML = '';

				if (this._tree && this._tree.getManager()) {
					//this._tree.getManager().destroy();
					//unloading tree because of IE11 specific issue
					this.unloadDocument();
				}

				this._model = new TreeDocument({
					useAsyncPreExpand: true
				});

				this._model.prepareUpdate();

				var treeData = this.data.roots;
				this.data.roots = undefined;
				for (var index = 0; index < treeData.length; index += 1) {
					var root = new TreeNodeModel(treeData[index]);
					this._model.addRoot(root);
				}

				this._model.pushUpdate();
				this._model.collapseAll();
				//To expand the tree everytime data gets updated
				this._model.getRoots()[0].expand();

				this._tree = new TreeListView(this.data);
				manager = this._tree.getManager();

				manager.onReady(function () {
					manager.loadDocument(that._model);
					//that.dispatchEvent('onReady');
				});

				this._tree.inject(this.$.content);

				//attach event listener for double click
				manager.addEventListener('dblclick', function (event, cellInfos) {
					this._onItemSelect(event, cellInfos, true);
				}.bind(this));

				manager.addEventListener('click', function (event, cellInfos) {
					this._onItemSelect(event, cellInfos);
				}.bind(this));

				//Reset all internal Variables
				this._searchKey = undefined;
				this.allAssociatedKeys = [];
				this.fire(EVENT.LOADED);
				this._validItems.splice(0, this._validItems.length);
				this._strictlyValidItems.splice(0, this._strictlyValidItems.length);
				this._validItemsCache = {};
				this._strictlyValidItemsCache = {};
			},

			unloadDocument: function () {
				try {
					this._tree && this._tree.getManager().unloadDocument();
					this._model = null;
					this.$.content.innerHTML = '';
				} catch (e) {
					console.log('Error in unloading the tree' + e);
				}
			},

			__onFilterChange: function (event) {
				event.stopPropagation();
				this._showOnlyValidSelection = event.detail.selectedindex === 0;
			},

			_onItemSelect: function (event, cellInfo, propogateSelection) {
				//event.stopPropagation();
				if (!cellInfo) {
					return;
				}
				this.selectedItem = cellInfo.nodeModel.options.data;
				this.isValidSelection = this._canAssociate(cellInfo.nodeModel.options.data.data, this.dataFilterKey);
				if (this.isValidSelection && propogateSelection) {
					this.fire(EVENT.DATASELECTED, {
						item: this.selectedItem
					});
				}
			},

			__selectedKeyChanged: function () {
				if (this._tree) {
					if (this.selectedKey === '') {
						this._tree.getManager().unselectAll();
						this.isValidSelection = false;
					} else {
						this._state = String(Number(this._state) + 1);
						var node = this._model.search({
							match: function (nodeInfo) {
								if (nodeInfo && this.selectedKey && this.selectedKey === nodeInfo.nodeModel.options.data.key) {
									return true;
								}
								return false;
							}.bind(this)
						});
						this._state = String(Number(this._state) - 1);
						if (node && node[0]) {
							this.async(function () {
								this._model.prepareUpdate();
								this._tree.getManager().unselectAll();
								node[0].reverseExpand();
								this._tree.getManager().scrollToNode(node[0]);
								node[0].show();
								node[0].select();
								this.selectedItem = node[0].options.data;
								this.isValidSelection = true;
								this._model.pushUpdate();
							}.bind(this), 100);
						}
					}
				}
			},

			__allAssociatedKeysChanged: function (value, oldValue) {
				if (this._tree && value && value.length === 0) {
					this._associatedNodes = [];
				}

				if (this._tree && this.allAssociatedKeys && this.allAssociatedKeys.length > 0 && !this.areArraysEqual(value, oldValue)) {
					this._model.prepareUpdate();
					this._associatedNodes = this._associatedNodes || [];

					//Reset Badges to blank
					this._associatedNodes.forEach(function (node) {
						node.setBadges({
							bottomRight: ''
						});
					});

					this._associatedNodes = this._model.search({
						match: function (nodeInfo) {
							if (nodeInfo && this.allAssociatedKeys.indexOf(nodeInfo.nodeModel.options.data.key) !== -1) {
								return true;
							}
							return false;
						}.bind(this)
					});

					this._associatedNodes.forEach(function (node) {
						node.setBadges({
							bottomRight: 'check'
						});
					});

					this._model.pushUpdate();

				}
			},

			areArraysEqual: function (a1, a2) {
				if ((a1 instanceof Array) && (a2 instanceof Array)) {
					if (a1.length !== a2.length) {
						return false;
					}
					else {
						var x;
						for (x = 0; x < a1.length; x++) {
							if (a1[x] !== a2[x]) {
								return false;
							}
						}
					}
				} else {
					return false;
				}
				return true;

			},

			__showOnlyValidSelectionChanged: function () {
				this._hideTreeModel = false;

				if (this._searchKey && this._searchKey !== '') {
					this.__matchedItemsChanged();
				} else if (this._tree) {
					this._model.prepareUpdate();

					var allNodesInModel = this._model.getAllDescendants().reverse();
					var numOfNodesInModel = allNodesInModel.length;

					//hide all nodes first
					for (var i = 0; i < numOfNodesInModel; i++) {
						allNodesInModel[i].hide();
					}
					this._oldValidItems = [];
					//if showOnlyValid is set, show only valid nodes
					if (this._showOnlyValidSelection) {
						//Now check if any valid node is present
						if (this._validItems.length !== 0) {
							this._validItems.forEach(function (node) {
								node.show();
							});
						} else {
							this._hideTreeModel = true;
						}
					} else {//i.e. showAll is set
						for (var i = 0; i < numOfNodesInModel; i++) {
							allNodesInModel[i].show();
						}
					}
					//TODO: This is a temporary solution for MAND IR -IR-624028-3DEXPERIENCER2018x.
					//Remove this once root cause is found.
					this._model.expandAll();
					this._model.pushUpdate();
				}

			},

			__validItemsChanged: function (value, oldValue) {
				this._oldValidItems = oldValue;
				this.__showOnlyValidSelectionChanged();
			},


			__computeMatchedItems: function (searchKey) {
				this._hideTreeModel = false; //show the tree view by default.
				var matchedItems = this._model.search({
					match: function (nodeInfo) {
						if (searchKey && nodeInfo &&
								nodeInfo.nodeModel.options.label.toLowerCase().indexOf(searchKey.toLowerCase()) !== -1) {
							return true;
						}
						return false;
					}
				});
				return matchedItems;
			},

			__matchedItemsChanged: function (value, oldValue) {
				// Applying debounce as solution to IR-614629-3DEXPERIENCER2019x as user lost focus from input field after typing first letter.
				this.debounce('__matchedItemsChanged', function (value, oldValue) {
					if (this._tree) {
						this._model.prepareUpdate();
						this._tree.getManager().unselectAll();
						if (oldValue) {
							oldValue.forEach(function (node) {
								node.unmatchSearch();
							});
						}
						this._matchedItems.forEach(function (node) {
							node.matchSearch();
							node.reverseExpand();
						});


						//Two lists to store searches based on Show ALl & Show Only valid
						var validNodesWhenShowAllEnabled = [];
						var validNodesWhenShowValidEnabled = [];
						var skipReSearch = false;
						var matchedItemsList = this._matchedItems;

						//unhide all nodes first
						this._hideTreeModel = false;
						var allNodes = this._model.getAllDescendants().reverse();
						var numOfNodesInModel = allNodes.length;
						var root = this._model.getRoots()[0];
						allNodes.forEach(function (node) {
							node.show();
						});

						switch (this._searchKey) {
						case undefined:
							break;

						case '':
							if (this._showOnlyValidSelection && this.dataFilterKey) {
								validNodesWhenShowValidEnabled = this._validItemsCache[this.dataFilterKey];
							} else {
								validNodesWhenShowAllEnabled = allNodes;
							}
							break;

						default:
							//If this search string is already searched earlier & showAll is selected.
							if (!this._showOnlyValidSelection && this._searchKey && this._searchedKeysCache[this._searchKey]) {
								skipReSearch = true;
								validNodesWhenShowAllEnabled = this._searchedKeysCache[this._searchKey];
							} else if (this._searchKey && this._matchedItems.length !== 0) {//if it is some new string to be searched or showOnlyValid is enabled
								var listAllDirectories = new Map();
								//create list of all directory nodes
								for (var i = 0; i < numOfNodesInModel; i++) {
									if (allNodes[i].getChildren()) {
										listAllDirectories.set(allNodes[i], 0);
									}
								}

								//Now find all the valid directories based on search String
								//If directory contains search string, it should be visible.
								for (var i = 0; i < numOfNodesInModel; i++) {
									var currentNode = allNodes[i];
									//if this node is already present in matched Items list. Make its parent visible if it is not root node
									if (matchedItemsList.indexOf(currentNode) !== -1 && currentNode !== root) {
										validNodesWhenShowAllEnabled.push(currentNode);
										listAllDirectories.set(currentNode.getParent(), 1);
									}//if it is root node & is present in matched nodes, store it in valid list
									else if (matchedItemsList.indexOf(currentNode) !== -1 && currentNode === root) {
										validNodesWhenShowAllEnabled.push(currentNode);
										listAllDirectories.set(currentNode, 1);
									}
								}

								//now search for valid directories till root node & add them in valid nodes list
								listAllDirectories.forEach(function (value, directory) {
									if (listAllDirectories.get(directory) === 1 && directory !== root) {
										listAllDirectories.set(directory.getParent(), 1);
									}
								});

								//Add these valid directories to valid node list
								listAllDirectories.forEach(function (key, directory) {
									if (listAllDirectories.get(directory) === 1 && validNodesWhenShowAllEnabled.indexOf(directory) === -1) {
										validNodesWhenShowAllEnabled.push(directory);
									}
								});
							}
							//Now we have list of nodes to be shown when ShowAll is enabled. Stored in validNodesWhenShowAllEnabled.
							//Next step is to find nodes when showOnlyValid is enabled.
							if (this.dataFilterKey && this._validItemsCache[this.dataFilterKey]) {
								//find details for valid nodes if dataFilterKey is available
								var listOfValidNodes = this._validItemsCache[this.dataFilterKey];
								var numValidNodes = listOfValidNodes.length;
								var listAllValidDirectories = new Map();

								//create list of valid directories
								for (var i = 0; i < numValidNodes; i++) {
									if (listOfValidNodes[i].getChildren()) {
										listAllValidDirectories.set(listOfValidNodes[i], 0);
									}
								}

								var strictlyValidNodes = this._strictlyValidItemsCache[this.dataFilterKey];
								var numStrictlyValidNodes = strictlyValidNodes.length;

								//find nodes to be displayed
								for (var i = 0; i < numStrictlyValidNodes; i++) {
									var currentNode = strictlyValidNodes[i];
									//if this node is already present in matched Items list, Make its parent visible only if it is not root node
									if (matchedItemsList.indexOf(currentNode) !== -1 && currentNode !== root) {
										validNodesWhenShowValidEnabled.push(currentNode);
										listAllValidDirectories.set(currentNode.getParent(), 1);
									} else if (matchedItemsList.indexOf(currentNode) !== -1 && currentNode === root) {
										validNodesWhenShowValidEnabled.push(currentNode);
										listAllValidDirectories.set(currentNode, 1);
									}
								}
								//now search for valid directories till root node & add them in valid nodes list
								listAllValidDirectories.forEach(function (value, directory) {
									if (listAllValidDirectories.get(directory) === 1 && directory !== root) {
										listAllValidDirectories.set(directory.getParent(), 1);
									}
								});

								//Add these valid directories to valid node list
								listAllValidDirectories.forEach(function (key, directory) {
									if (listAllValidDirectories.get(directory) === 1 && validNodesWhenShowValidEnabled.indexOf(directory) === -1) {
										validNodesWhenShowValidEnabled.push(directory);
									}
								});
							}
							//now we have list of nodes to be displayed when showOnlyValid is enabled stored in validNodesWhenShowValidEnabled
							//store these searches for future use in _searchedKeysCache if not already stored.
							if (!skipReSearch) {
								this._searchedKeysCache[this._searchKey] = validNodesWhenShowAllEnabled;
							}
							break;
						}//switch ends here

						if (this._showOnlyValidSelection && validNodesWhenShowValidEnabled.length === 0) {
							this._hideTreeModel = true;
						}
						//if showOnlyValid is set, hide remaining nodes except those in validNodesWhenShowValidEnabled
						else if (this._showOnlyValidSelection && validNodesWhenShowValidEnabled.length !== 0) {
							allNodes.forEach(function (node) {
								if (validNodesWhenShowValidEnabled.indexOf(node) === -1) {
									node.hide();
								}
							});
						} else {
							allNodes.forEach(function (node) {
								if (validNodesWhenShowAllEnabled.indexOf(node) === -1) {
									node.hide();
								}
							});
						}

						if (this._searchKey && this._matchedItems.length === 0) {
							this._hideTreeModel = true;
						}
						this._model.pushUpdate();
					}
				}, 600);
			},


			__dataFilterKeyChanged: function () {
				var that = this;
				var listOfValidNodes = [];
				this._state = String(Number(this._state) + 1);
				this._hideTreeModel = false;
				if (this._validItemsCache.hasOwnProperty(this.dataFilterKey)) {
					this._validItems = this._validItemsCache[this.dataFilterKey];
					if (this._showOnlyValidSelection && this._validItems.length === 0) {
						this._hideTreeModel = true;
						this._strictlyValidItems = [];
						//this._strictlyValidItemsCache={};
					}
				} else {
					var allNodesInModel = this._model.getAllDescendants().reverse();
					var numOfNodesInModel = allNodesInModel.length;
					var listAllDirectories = new Map(); // using Map to avoid duplication of data

					this._strictlyValidItems = [];
					//this._strictlyValidItemsCache={};
					//create list of all directory nodes
					for (var i = 0; i < numOfNodesInModel; i++) {
						if (allNodesInModel[i].getChildren()) {
							listAllDirectories.set(allNodesInModel[i], 0);
						}
					}

					//logic to find only valid nodes
					for (var i = 0; i < numOfNodesInModel; i++) {
						var currentNode = allNodesInModel[i];
						//Check if this node can be associated for given dataFilterKey
						if (that.dataFilterKey && currentNode && that._canAssociate(currentNode.options.data.data, that.dataFilterKey)) {
							listOfValidNodes.push(currentNode);
							this._strictlyValidItems.push(currentNode);
							//find its parent element & set it as valid directory. Only if current node is not root node
							if (currentNode !== that._model.getRoots()[0]) {
								listAllDirectories.set(currentNode.getParent(), 1);
							}
						}
					}

					//now find all valid directories till Root node
					listAllDirectories.forEach(function (value, directory) {
						if (listAllDirectories.get(directory) === 1 && directory !== that._model.getRoots()[0]) {
							listAllDirectories.set(directory.getParent(), 1);
						}
					});

					//Add these valid directories to valid node list
					listAllDirectories.forEach(function (key, directory) {
						if (listAllDirectories.get(directory) === 1 && listOfValidNodes.indexOf(directory) === -1) {
							listOfValidNodes.push(directory);
						}
					});

					//maintain separate list of strictly valid nodes i.e. this list is free from all intermediate nodes added later
					this._strictlyValidItemsCache[this.dataFilterKey] = this._strictlyValidItems;

					//normal list of valid nodes
					this._validItems = listOfValidNodes;
					if (this._showOnlyValidSelection && listOfValidNodes.length === 0) {
						this._hideTreeModel = true;
					}
					this._validItemsCache[this.dataFilterKey] = this._validItems;
				}
				this._state = String(Number(this._state) - 1);
			},


			reset: function () {
				if (this._tree) {
					this._tree.getManager().unselectAll();

					this.selectedKey = '';
					this._searchKey = '';
					this._hideTreeModel = false;
					/* With respect to IR-597910-3DEXPERIENCER2019x, making changes below(Uncommenting this.dataFilterKey='' statement).
					Earlier both line below was commented. If further issues comes in data tree view performace please test these statements. */
					//this._validItems = [];
					this.dataFilterKey = '';
				}
			},

			/*
				* Custom filter that checks if a given process item type is available for association
				* This API is used declaratively as a part of filter expression in the component HTML
				* @returns {Boolean} Returns true if this process item fits the datatype filter criteria set by requested party(widget property)
				*/
			_canAssociate: function (item, type) {
				//See if writing inner functions is a performance hit.If yes, move the fucntion to outside
				var processitem,
					associationSupported = false,
					choicesAvailable,
					multiValueType,
					isMultiChoiceSupported,
					rangeAvailable,
					isDatatypeSupported,
					isContenttypeSupported,
					isListSupported,
					isRangeSupported,
					isValuetypeSupported,
					isAcitivtySupported,
					isSimulationSupported,
					isAdapterSupported,
					typesSupported;
				processitem = item;
				var isArraySupported,
					isDimensionSupported;
					//If no filter is provided, all items can be associated
				if (!type) {
					return true;
				}
				//Remove all empty spaces and Split
				typesSupported = type.replace(/ /g, '').split(',');
				//Check that activity is supported or not
				isAcitivtySupported = function () {
					if (typesSupported.indexOf(TYPE.Activity) >= 0) {
						return (processitem.level === '0' && processitem.title.indexOf(TYPE.Activity) >= 0);
					}
					return false;
				};
				//Check that activity is supported or not
				isSimulationSupported = function () {
					if (typesSupported.indexOf(TYPE.Simulation) >= 0) {
						return (processitem.level === '0' && TYPE.Simulation.toLowerCase() === String(processitem.type).toLowerCase());
					}
					return false;
				};
				//currently, only DOE is supported so hardcoded this,
				//@TODO:: generalize it for any adapter
				isAdapterSupported = function () {
					return typesSupported[0] === 'doe_adapter' && processitem.level === '0' && processitem.extensionName === 'com.dassault_systemes.sma.adapter.Doe';
				};
				//Checks if data type is supported
				isDatatypeSupported = function () {
					//Consider this case for Parameter that is of type Object
					if (processitem.datatype === DATA_TYPE.refcontent) {
						return isContenttypeSupported();
					}
					//Singleval and datatypes 'string,int,real,timestamp'
					return typesSupported.indexOf(processitem.datatype) >= 0;
				};
				//Checks if value type 'single',multival','array' are supported
				isValuetypeSupported = function () {
					if (!processitem.valuetype || (processitem.valuetype === VALUE_TYPE.single || processitem.valuetype === VALUE_TYPE.singleval)) {
						if (typesSupported.indexOf(VALUE_TYPE.array) >= 0) {
							return false;
						}
						return true;
					}
					//'multival' or 'array'
					return typesSupported.indexOf(processitem.valuetype) >= 0;
				};
				//Checks if choices are supported if available
				isListSupported = function () {
					return processitem.choices.length > 0 && typesSupported.indexOf('choices') >= 0 && typesSupported.indexOf('multival') === -1;
				};

				isMultiChoiceSupported = function () {
					return processitem.valuetype === 'multival' && processitem.choices && processitem.choices.length > 0 && typesSupported.indexOf('choices') >= 0 && typesSupported.indexOf('multival') >= 0;
				};

				isArraySupported = function () {
					return VALUE_TYPE.array === processitem.valuetype;
				};
				isDimensionSupported = function () {
					var processitemValue = JSON.parse(processitem.value)[0];
					if (typesSupported.indexOf(ARRAY_DIMENSION.one) >= 0) {
						return processitemValue.children === undefined;
					} else if (typesSupported.indexOf(ARRAY_DIMENSION.two) >= 0) {
						return processitemValue.children !== undefined && processitemValue.children[0].children === undefined;
					} else if (typesSupported.indexOf(ARRAY_DIMENSION.three) >= 0) {
						return processitemValue.children !== undefined && processitemValue.children[0].children !== undefined && processitemValue.children[0].children[0].children === undefined;
					} else if (typesSupported.indexOf(ARRAY_DIMENSION.four) >= 0) {
						return processitemValue.children !== undefined &&
								processitemValue.children[0].children !== undefined &&
								processitemValue.children[0].children[0].children !== undefined &&
								processitemValue.children[0].children[0].children[0].children === undefined;
					} else {
						return false;
					}
				};
				//Content
				isContenttypeSupported = function () {
					return typesSupported.indexOf(processitem.datatype) >= 0;
				};
				//Checks if min,max boundaries are supported if available
				isRangeSupported = function () {
					return typesSupported.indexOf('range') >= 0;
				};

				choicesAvailable = function () {
					return processitem.choices && processitem.choices.length > 0;
				};

				rangeAvailable = function () {
					return !isNaN(parseFloat(processitem.maximum)) && !isNaN(parseFloat(processitem.minimum));
				};

				multiValueType = function () {
					return processitem.valuetype === 'multival' && typesSupported.indexOf('choices') === -1;
				};
				//Check if a processitem can be associated
				//If it's content
				if (processitem.syncAssist && processitem.syncAssist === TYPE.Content) {
					associationSupported = isContenttypeSupported(TYPE.Content);
				} else //processitem is activity
				if (isAcitivtySupported()) {
					associationSupported = true;
				} else //processitem is activity
				if (isSimulationSupported()) {
					associationSupported = true;
				} else //if the process item is DOE Adapter
				if (isMultiChoiceSupported()) {
					associationSupported = true;
				} else //If it has choices to be displayed
				if (choicesAvailable()) {
					associationSupported = isListSupported() && isValuetypeSupported();
				} else //If there are min and max boundaries
				if (rangeAvailable()) {
					associationSupported = isRangeSupported() && isValuetypeSupported();
				} else //If it's a multival type
				if (multiValueType()) {
					associationSupported = isValuetypeSupported();
				} else //If it's a multival type
				if (isArraySupported()) {
					associationSupported = isDatatypeSupported() && isDimensionSupported();
				} else if (isAdapterSupported()) {
					associationSupported = true;
				} else
				//If it supports the data type(string,int,..) and value type(single,multi,array)
				{
					associationSupported = isDatatypeSupported() && isValuetypeSupported();
				}
				item._enabled = Boolean(associationSupported);
				return item._enabled;
			},

			_computeClass: function (_hideTreeModel) {
				return _hideTreeModel ? 'hide' : 'browsecontent';
			},

			_computeClass1: function (_hideTreeModel) {
				return _hideTreeModel ? 'emptytree' : 'hide';
			},

			behaviors: [window.DS.SMAProcSP.SPBase]
		});
	});
}(this));
