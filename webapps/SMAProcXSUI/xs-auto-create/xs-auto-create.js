/*--
[xs-data-tree-view JS Document]
*/
/* global Polymer*/
(function(window) {
	'use strict';
	require(['DS/Tree/TreeListView',
		'DS/Tree/TreeNodeModel',
		'DS/Tree/TreeDocument',
		'css!DS/SMAProcXSUI/xs-auto-create/xs-auto-create.css',
		'css!DS/UIKIT/UIKIT.css'
	],
	function(TreeListView, TreeNodeModel, TreeDocument) {
		var BADGE_BASE64_IMAGE,
			ARRAY_DIMENSION,
			TYPE,
			DATA_TYPE,
			VALUE_TYPE,
			EVENT,
			WIDGET_MODEL_ID;
		//Enums

		EVENT = {
			DATASELECTED: 'xs-data-tree-view-dataselected',
			ATTACHED: 'xs-data-tree-view-attached',
			LOADED: 'xs-data-tree-view-loaded'
		};

		BADGE_BASE64_IMAGE = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABcAAAARCAYAAAA2cze9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEh'
		+'ZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAxNzowNjowNyAxNToxMjoxNwfBJzAAAAB3SURBVDhP1dTdEkAgEIbhXTeOK4/P'
		+'ZDTav6SD3hMOeGwNOJ3RoJZ8HNIcOO+cz55+wSUYdeMajLrwEk5r/dJ9xj0YiThutJYbgZE5ufSAKIzcbSmxFhipn7809V0ERurkGhCFkbktb6gFvsK2eNEWuqxq1l8u0QE1A4TC4KrTdAAAAABJRU5ErkJggg==';

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

		WIDGET_MODEL_ID = 'item';
		var
			init,
			ModelItem,
			isActivity,
			isStep,
			typesInReadableFormat,
		 	indexBasicAttributes,
			indexSimExecOptions,
			indexProcessData,
			getTypeInReadableFormat,
			isAdapter,
			TYPE,
			DATA_TYPE,
			PLMDATA_TYPE,
			DEFAULT_ICON,
			ROOT = 'ROOT',
			TITLE_DISPLAY = 'title_display';

		typesInReadableFormat = {
			string: 'String',
			real: 'Real',
			integer: 'Integer',
			'int': 'Integer',
			Activity: 'Activity',
			doe_adapter: 'Adapter', // jshint ignore:line
			timestamp: 'Date',
			range: 'Range',
			media: 'Content',
			multival: 'Multivalue',
			owned_chooser: 'Plmobject - owned', // jshint ignore:line
			chooser: 'Plmobject - referenced',
			'2D': 'Array',
			choices: 'Choices',
			'boolean': 'Boolean',
			text: 'Text'
		};
		// This type information is used to mark the PLM data type for each item displayed in the browser
		TYPE = {
			Activity: 'Activity',
			Basics: 'Basics',
			ExecOpt: 'ExecOpt',
			Parameter: 'Parameter',
			Attribute: 'Attribute',
			Simulation: 'Simulation',
			Step: 'Step',
			Content: 'content'
		};
		// Data types exposed by iosummaryview/execution options
		DATA_TYPE = {
			string: 'string'
		};
		DEFAULT_ICON = 'custom-fonticon-default';
		// This is a mapping information stored between TYPE and types exposed by xs-wg-plm-data
		PLMDATA_TYPE = {
			Attribute: 'ATTRIBUTE',
			Parameter: 'PARAMETER',
			ExecOpt: 'EXECUTIONOPTIONS',
			Basics: 'BASICS',
			content: 'CONTENT'
		};
		/**
			 * Private method that determines whether an object provided represents an activity
			 * by checking its title.
			 * @param   {Object}  item Object representing an Activity details
			 * @returns {Boolean} true if it is Acitivy,false if not.
			 */
		isActivity = function (item) {
			return item.level === '0' && item.title.indexOf(TYPE.Activity) >= 0;
		};
		/**
			 * Private method that determines whether an object provided represents a Step
			 * by checking its title.
			 * @param   {Object}  item Object representing an Activity details
			 * @returns {Boolean} true if it is Acitivy,false if not.
			 */
		isStep = function (item) {
			return item.level === '0' && item.title.indexOf(TYPE.Step) >= 0;
		};

		getTypeInReadableFormat = function (data) {
			var type = '';
			if (data.choices) {
				type = 'Choices';
			} else if (data.datatype) {
				type = typesInReadableFormat[data.datatype];
			} else if (!data.datatype && typesInReadableFormat[data]) {
				type = typesInReadableFormat[data];
			}
			return type;
		};

		isAdapter = function (item, adapterType) {
			var ADAPTER = {
				doe: 'com.dassault_systemes.sma.adapter.Doe'
			};
			return isStep(item) && item.extensionName === ADAPTER[adapterType];
		};

		/**
			 * Constructor for each item in the process browser
			 * This creates a Skeleton structure based on the process item data and any Type information provided
			 * @param   {Object} data - All the data available for this object
			 * @param   {string} type - Optional parameter that can be used to specify if it's execution options, iosummaryview data or basic attributes.
			 * @param		{String} key - This additional information will be used in getting all details required for the skeleton structure
			 * @returns {Object} A skeleton structure with {Type, isDirectory, Data} information
			 */
		ModelItem = function (data, type, key) {
			var item;
			// Initial skeleton of ModelItem
			item = {
				data: data,
				key: key
			};
			// Basics data has a different structure, so treat it differently
			if (type === TYPE.Basics) {
				item.Type = TYPE.Basics;
				item.isDir = false;
				return item;
			}
			// if not basics, update the item based on the type and level
			switch (data.level) {
			case '0':
				if (isActivity(data)) {
					item.Type = TYPE.Activity;
					item.isDir = true;
				}
				if (isStep(data)) {
					item.Type = TYPE.Step;
					item.isDir = true;
				}
				if (data.title === TYPE.Simulation) {
					item.Type = TYPE.Simulation;
					item.isDir = true;
				}
				break;
			case '1':
				item.Type = data.title;
				item.header = true;
				break;
			case '2':
				item.Type = data.syncAssist;
				item.mandatory = data.mandatory && data.mandatory === 'true';
				break;
			default:
				break;
			}
			return item;
		};
		/**
		 * Private method that indexes Simulation details to make it suitable for using in UI
		 * @param {JSON} SimulationDetails - Simulation JSON
		 */
		indexBasicAttributes = function (SimulationDetails) {
			var EDITABLE_ATTR, NON_EDITABLE_BASICS;

			EDITABLE_ATTR = ['title', 'description', 'Simulation Study'];
			NON_EDITABLE_BASICS = ['name', 'revision', 'locked', 'modified', 'owner', 'originated', 'Simulation Kind'];

			this.basicattributes = {};
			this.basicattributes[ROOT] = [];

			// Editable attributes
			EDITABLE_ATTR.forEach(function (basicattr) {
				this.basicattributes[ROOT].push(new ModelItem({
					id: basicattr,
					title: basicattr,
					value: SimulationDetails.attributes[basicattr],
					datatype: DATA_TYPE.string
				}, TYPE.Basics, this.PLMData.KIND.SIMULATION + '//' + this.PLMData.ITEM_TYPE[PLMDATA_TYPE.Basics] + '/' + basicattr));
			}.bind(this));

			// Non-editable basic attributes
			NON_EDITABLE_BASICS.forEach(function (basicattr) {
				this.basicattributes[ROOT].push(new ModelItem({
					id: basicattr,
					title: basicattr,
					value: SimulationDetails.basics[basicattr],
					datatype: DATA_TYPE.string
				}, TYPE.Basics, this.PLMData.KIND.SIMULATION + '//' + this.PLMData.ITEM_TYPE[PLMDATA_TYPE.Basics] + '/' + basicattr));
			}.bind(this));
		};

		/**
		 * Private method that indexes ExecutionOptions to make it suitable for using in UI
		 * @param {JSON} ExecutionOptions - ExecutionOptions JSON
		 */
		indexSimExecOptions = function (ExecutionOptions) {
			var index, activityId, dirId, size, execData, kind, uid, path, activityList;
			dirId = ROOT;
			activityList = [];
			kind = this.PLMData.KIND.SIMULATION;
			uid = '';
			this.execoptions = {};
			this.execoptions[dirId] = [];
			size = ExecutionOptions.length;
			// Record all data that's direct descendants(Exceptions: activities) of Process
			for (index = 1; index < size; index += 1) {
				execData = ExecutionOptions[index];
				// item = new ModelItem(ExecutionOptions[index]);
				if (isActivity(execData)) {
					kind = this.PLMData.KIND.ACTIVITY;
					uid = execData.sequence;
					dirId = activityId = execData.objectId;
					activityList.push(dirId);
					this.execoptions[dirId] = this.execoptions[dirId] || [];
				}
				if (isStep(execData)) {
					dirId = execData.id;
					path = 'steps/' + dirId + '/';
					this.execoptions[dirId] = this.execoptions[dirId] || [];
					// Record steps for all activities
					this.steps[activityId] = this.steps[activityId] || [];
					this.steps[activityId].push(new ModelItem(execData, '', kind + '/' + uid + '/' + path));
				}
				if (execData.level === '2') {
					if ((dirId === ROOT) || (activityList.indexOf(dirId) !== -1)) {
						path = this.PLMData.ITEM_TYPE[PLMDATA_TYPE.ExecOpt] + '/' + execData.title;
					} else {
						path = 'steps/' + dirId + '/' + this.PLMData.ITEM_TYPE[PLMDATA_TYPE.ExecOpt] + '/' + execData.title;
					}
					this.execoptions[dirId].push(new ModelItem(execData, '', kind + '/' + uid + '/' + path));
				}
			}
		};

		/**
		 * Private method that indexes IOSummaryView to make it suitable for using in UI
		 * @param {JSON} processData - IOSummaryView JSON
		 * @param {JSON} processId - processId
		 */
		indexProcessData = function (processData, processId) {
			var index,
				activityId,
				item,
				size,
				simObjectid,
				step,
				stepIndex,
				actNode,
				parentNode,
				indexedData,
				numberOfSteps,
				kind,
				uid,
				path,
				propFolder = {},
				exectionFolder = {};
			//             mcsURL = this.$.dashboard.getMcsUri();
			kind = this.PLMData.KIND.SIMULATION;
			uid = '';
			path = '';
			indexedData = {};
			// mcsURL +  processData[0].icon.replace('..', '')
			processData[0].type = TYPE.Simulation;
			propFolder.parent = processData[0];
			propFolder.type = 'PropertiesFolder';
			exectionFolder.parent = processData[0];
			exectionFolder.type = 'ExecutionFolder';
			this.processTreeData.roots.push({
				label: processData[0].title_display,	   // jshint ignore:line
				icons: [{
					iconName: 'fast-forward'
				}],
				data: new ModelItem(processData[0], undefined, String(this.PLMData.KIND.SIMULATION + '/' + processId + '/')),
				grid: {
					type: 'Simulation'
				},
				children: [{
					label: 'Properties',
					icons: [{
						iconName: 'attributes'
					}],
					grid: [{
						type: ''
					}],
					data: new ModelItem(propFolder),
					children: []
				}, {
					label: 'Execution Options',
					icons: [{
						iconName: 'computer-server'
					}],
					grid: [{
						type: ''
					}],
					data: new ModelItem(exectionFolder),
					children: []
				}]
			});

			var rootNode = this.processTreeData;

			indexedData.ROOT = rootNode;


			// Add basic attributes for Root
			this.basicattributes[ROOT].forEach(function (attrib) {
				rootNode.roots[0].children[0].children.push({
					label: attrib.data.id,
					icons: [{
						iconName: DEFAULT_ICON
					}],
					data: attrib,
					grid: {
						type: getTypeInReadableFormat(attrib.data)
					}
				});
			});

			// Add Execution Options for Root
			this.execoptions[ROOT].forEach(function (option) {
				rootNode.roots[0].children[1].children.push({
					label: option.data.title_display,  // jshint ignore:line
					data: option,
					icons: [{
						iconName: DEFAULT_ICON
					}],
					grid: {
						type: getTypeInReadableFormat(option.data)
					}
				});
			});


			// First object in IOSummaryview collection contains Simulation information
			simObjectid = processData[0].objectId;
			this.heading = processData[0][TITLE_DISPLAY];
			size = processData.length;

			// Record all data that's direct descendants(Exceptions: activities) of Simulation
			for (index = 1; index < size; index += 1) {
				item = new ModelItem(processData[index]);
				if (item.Type === TYPE.Content) {
					path = this.PLMData.ITEM_TYPE[PLMDATA_TYPE[item.Type]] + '/' + processData[index].chooser_physicalid; // jshint ignore:line
				} else {
					path = this.PLMData.ITEM_TYPE[PLMDATA_TYPE[item.Type]] + '/' + processData[index].title;
				}

				item = new ModelItem(processData[index], '', kind + '/' + uid + '/' + path);

				if (!isActivity(item.data)) {
					// Only level 2 elements are allowed
					// Block owned document attributes to be listed/ Hence adding a dirty fix to prevent them

					if (item.data.level === '2' && !(item.data.syncAssist === 'Attribute' && item.data.documentId !== undefined && item.data.documentId.length >= 0)) {
						// attributes/parameters/content owned directly by simulation
						rootNode.roots[0].children.push({
							label: item.data.title || item.data.title_display, // jshint ignore:line
							data: item,
							icons: [{
								iconName: DEFAULT_ICON
							}],
							grid: {
								type: getTypeInReadableFormat(item.data)
							}
						});
					}
				} else {
					activityId = item.data.objectId;
					uid = item.data.sequence;
					kind = this.PLMData.KIND.ACTIVITY;
					break;
				}
			}


			parentNode = rootNode;

			// Looping for all activities parameters / attributes / content
			for (index; index < size; index += 1) {
				item = new ModelItem(processData[index]);
				// If item is not an activity, keep adding data to this index until the next activity is encountered in IOSummaryview
				if (!isActivity(item.data)) {
					if (item.data.level === '2' && !(item.data.syncAssist === 'Attribute' && item.data.documentId !== undefined && item.data.documentId.length >= 0)) {
						if (item.Type === TYPE.Content) {
							path = this.PLMData.ITEM_TYPE[PLMDATA_TYPE[item.Type]] + '/' + processData[index].chooser_physicalid;// jshint ignore:line
						} else {
							path = this.PLMData.ITEM_TYPE[PLMDATA_TYPE[item.Type]] + '/' + processData[index].title;
						}

						actNode.children.push({
							label: item.data.title_display || item.data.title,	 // jshint ignore:line
							data: new ModelItem(processData[index], '', kind + '/' + uid + '/' + path),
							icons: [{
								iconName: DEFAULT_ICON
							}],
							grid: {
								type: getTypeInReadableFormat(item.data)
							}
						});
					}
				} else {
					// If item is an activity
					activityId = item.data.objectId;
					uid = item.data.sequence;
					propFolder.parent = item;
					propFolder.type = 'PropertiesFolder';
					exectionFolder.parent = item;
					exectionFolder.type = 'ExecutionFolder';
					// Only basics to be shown for activity is the Title information
					var activityTitle = [new ModelItem({
						id: TITLE_DISPLAY,
						title: 'title',
						datatype: DATA_TYPE.string,
						value: item.data[TITLE_DISPLAY]
					}, TYPE.Basics, this.PLMData.KIND.ACTIVITY + '/' + uid + '/' + this.PLMData.ITEM_TYPE[PLMDATA_TYPE.Basics] + '/' + TITLE_DISPLAY)];

					actNode = {
						label: item.data.title_display, // jshint ignore:line
						data: new ModelItem(processData[index], '', kind + '/' + uid + '/'),
						icons: [{
							iconName: 'play'
						}],
						grid: {
							type: 'Activity'
						},
						children: [{
							label: 'Properties',
							grid: [{
								type: ''
							}],
							icons: [{
								iconName: 'attributes'
							}],
							data: new ModelItem(propFolder),
							children: [{
								label: activityTitle[0].data.title,
								data: activityTitle[0],
								icons: [{
									iconName: DEFAULT_ICON
								}],
								grid: {
									type: getTypeInReadableFormat('string')
								}
							}]
						}, {
							label: 'Execution Options',
							grid: [{
								type: ''
							}],
							icons: [{
								iconName: 'computer-server'
							}],
							data: new ModelItem(exectionFolder),
							children: []
						}]
					};

					indexedData[activityId] = actNode;

					this.execoptions[activityId].forEach(function (option) {	// jshint ignore:line
						actNode.children[1].children.push({
							label: option.data.title_display,	// jshint ignore:line
							data: option,
							icons: [{
								iconName: DEFAULT_ICON
							}],
							grid: {
								type: getTypeInReadableFormat(option.data)
							}
						});
					});			      // jshint ignore:line

					// Maintain InternalId to objectId mapping for each activity
					this._oiduidmap[item.data.sequence] = activityId;
					// If it's a direct descendant of process, add it to root
					if (item.data.parentId === simObjectid) {
						parentNode = rootNode.roots[0];
					} else {
						parentNode = indexedData[item.data.parentId];
					}

					parentNode.children.push(actNode);


					numberOfSteps = (this.steps[activityId] || []).length;
					for (stepIndex = 0; stepIndex < numberOfSteps; stepIndex += 1) {
						step = this.steps[activityId][stepIndex];
						// create the step node
						var stepIcon = '',
							stepNode;
						switch (step.data.extensionName.replace('com.dassault_systemes.sma.adapter.', '')) {
						case 'Download':
							stepIcon = 'download';
							break;
						case 'Upload':
							stepIcon = 'upload';
							break;
						case 'DeleteContent':
							stepIcon = 'clear';
							break;
						default:
							stepIcon = 'list-ordered';
							break;
						}
						stepNode = {
							label: step.data.title_display,	     // jshint ignore:line
							icons: [{
								iconName: stepIcon
							}],
							data: step,
							grid: {
								type: getTypeInReadableFormat(step.data)
							},
							children: [{
								label: 'Execution Options',
								grid: [{
									type: ''
								}],
								icons: [{
									iconName: 'computer-server'
								}],
								data: step,
								children: []
							}]
						};
						// currently, only supporting DOE, so hard-coded.
						// @TODO : generalize it so that later on, more adapters can be supported.
						if (isAdapter(step.data, 'doe')) {
							stepNode.grid.type = 'DOE Adapter';
						}

						// Steps execution options
						this.execoptions[step.data.id].forEach(function (itemExec) {	     // jshint ignore:line
							stepNode.children[0].children.push({
								label: itemExec.data.title_display,		  // jshint ignore:line
								data: itemExec,
								icons: [{
									iconName: DEFAULT_ICON
								}],
								grid: {
									type: getTypeInReadableFormat(itemExec.data)
								}
							});
						});				     // jshint ignore:line

						actNode.children.push(stepNode);
					}
				}
			}
			this.processTreeData = rootNode;
			this.data = this.processTreeData;
		};

		/**
		 * Private methods that takes care of any initializations required before process browser is launched
		 * @param {JSON} PLMData - This method is called once PLM data is prepared by xs-wg-plm-data
		 */
		init = function (PLMData) {
			var processId;
			this.PLMData = PLMData;
			this.steps = {};
			// Index Basic attributes from Simulation details data
			this.processTreeData = {
				isEditable: false,
				height: 'auto',
				isSortable: false,
				enableDragAndDrop: false,
				show: {
					rowHeaders: false,
					columnHeaders: false
				},
				selection: {
					unselectAllOnEmptyArea: true,
					toggle: false,
					canMultiSelect: true
				},
				columns: [{
					text: 'Type',
					dataIndex: 'type',
					isEditable: false,
					isSortable: false,
					width: 170
				}],
				roots: []
			};

			// process id changes on instantiation hence setting a constant string. Need to find a way if we want to support multiple process
			// processId = PLMData.getSource(PLMData.SOURCE.SIMULATION).attributes.definition.process.id;
			processId = 'process1';
			indexBasicAttributes.call(this, PLMData.getSource(PLMData.SOURCE.SIMULATION));
			// Index Execution options data
			indexSimExecOptions.call(this, PLMData.getSource(PLMData.SOURCE.EXECUTIONOPTIONS));
			// Index process data.This uses Simulation details, Execution options read in previous steps.
			indexProcessData.call(this, PLMData.getSource(PLMData.SOURCE.IOSUMMARYVIEW), processId);

			if (this.isAttached) {
				this.passDataToTreeView = true;
				// this.treeViewAttached();
			} else {
				this.passDataToTreeView = true;
			}
		};

		window.Polymer({ // jshint ignore:line

			is: 'xs-auto-create',

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
					notify:true
				},
				// Extra added Properties
				heading: {
					type: String,
					value: 'Auto Create Template'
				},

				selectedItemArray: {
					type: Array,
					value: []
				},
				/**
				Stores Internal Id --> Object id for activities
				@attribute _oiduidmap
				@type Object
				@default null
				**/
				_oiduidmap: {
					type: Object,
					value: function () {
						return {};
					}
				}
			},

			attached: function() {
				// this.fire(EVENT.ATTACHED);
				this.$.plmdata.getPLMData(init, this);
			},

			//Input Data changed
			__dataChanged: function() {
				var that = this,
					manager;
				this.$.content.innerHTML = '';

				if (this._tree && this._tree.getManager()){
					this._tree.getManager().destroy();
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

				manager.onReady(function() {
					manager.loadDocument(that._model);
					//that.dispatchEvent('onReady');
				});

				this._tree.inject(this.$.content);

				//attach event listener for double click
				manager.addEventListener('dblclick', function(event, cellInfos) {
					this._onItemSelect(event, cellInfos, true);
				}.bind(this));

				manager.addEventListener('click', function(event, cellInfos) {
					this._onItemSelect(event, cellInfos);
				}.bind(this));

				//Reset all internal Variables
				this._searchKey = undefined;
				this.allAssociatedKeys = [];
				this.fire(EVENT.LOADED);
				this._validItems.splice(0, this._validItems.length);
				this._strictlyValidItems.splice(0, this._strictlyValidItems.length);
				this._validItemsCache = {};
				this._strictlyValidItemsCache= {};
			},

			__onFilterChange: function(event) {
				event.stopPropagation();
				this._showOnlyValidSelection = event.detail.selectedindex === 0;
			},

			_onItemSelect: function(event, cellInfo, propogateSelection) {
				//event.stopPropagation();
				if (!cellInfo) {
					return;
				}
				this.selectedItem = cellInfo.nodeModel.options.data;
				this.isValidSelection = this._canAssociate(cellInfo.nodeModel.options.data.data, this.dataFilterKey);
				if (this.isValidSelection){
					// this.fire(EVENT.DATASELECTED, {
					// 	item: this.selectedItem
					// });
					this.selectedItemArray.push(this.selectedItem);
				}
			},

			__selectedKeyChanged: function() {
				if (this._tree) {
					if (this.selectedKey === '') {
						this._tree.getManager().unselectAll();
						this.isValidSelection = false;
					} else {
						this._state = String(Number(this._state) + 1);
						var node =this._model.search({
							match: function(nodeInfo) {
								if (nodeInfo && this.selectedKey && this.selectedKey === nodeInfo.nodeModel.options.data.key) {
									return true;
								}
								return false;
							}.bind(this)
						});
						this._state = String(Number(this._state) - 1);
						if (node && node[0]){
							this.async(function() {
								this._model.prepareUpdate();
								this._tree.getManager().unselectAll();
								node[0].reverseExpand();
								this._tree.getManager().scrollToNode(node[0]);
								node[0].show();
								node[0].select();
								this.selectedItem=node[0].options.data;
								this.isValidSelection = true;
								this._model.pushUpdate();
							}.bind(this), 100);
						}
					}
				}
			},

			__allAssociatedKeysChanged: function(value, oldValue) {
				if (this._tree && value && value.length === 0){
					this._associatedNodes = [];
				}

				if (this._tree && this.allAssociatedKeys && this.allAssociatedKeys.length > 0 && !this.areArraysEqual(value, oldValue)) {
					this._model.prepareUpdate();
					this._associatedNodes = this._associatedNodes || [];

					//Reset Badges to blank
					this._associatedNodes.forEach(function(node) {
						node.setBadges({
							bottomRight: ''
						});
					});

					this._associatedNodes = this._model.search({
						match: function(nodeInfo) {
							if (nodeInfo && this.allAssociatedKeys.indexOf(nodeInfo.nodeModel.options.data.key) !== -1) {
								return true;
							}
							return false;
						}.bind(this)
					});

					this._associatedNodes.forEach(function(node) {
						node.setBadges({
							bottomRight: BADGE_BASE64_IMAGE
						});
					});

					this._model.pushUpdate();

				}
			},

			areArraysEqual: function(a1, a2) {
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

			__showOnlyValidSelectionChanged: function() {
				this._hideTreeModel=false;

				if (this._searchKey && this._searchKey!== ''){
					this.__matchedItemsChanged();
				} else if (this._tree) {
					this._model.prepareUpdate();

					var allNodesInModel=this._model.getAllDescendants().reverse();
					var numOfNodesInModel=allNodesInModel.length;

					//hide all nodes first
					for (var i=0; i<numOfNodesInModel; i++){
						allNodesInModel[i].hide();
					}
					this._oldValidItems = [];
					//if showOnlyValid is set, show only valid nodes
					if (this._showOnlyValidSelection){
						//Now check if any valid node is present
						if (this._validItems.length!==0){
							this._validItems.forEach(function(node){
								node.show();
							});
						} else {
							this._hideTreeModel=true;
						}
					} else {//i.e. showAll is set
						for (var i=0; i<numOfNodesInModel; i++){
							allNodesInModel[i].show();
						}
					}

					this._model.pushUpdate();
				}

			},

			__validItemsChanged: function(value, oldValue) {
				this._oldValidItems = oldValue;
				this.__showOnlyValidSelectionChanged();
			},


			__computeMatchedItems: function(searchKey) {
				this._hideTreeModel=false; //show the tree view by default.
				var matchedItems = this._model.search({
					match: function(nodeInfo) {
						if (searchKey && nodeInfo &&
																nodeInfo.nodeModel.options.label.toLowerCase().indexOf(searchKey.toLowerCase()) !== -1) {
							return true;
						}
						return false;
					}
				});
				return matchedItems;
			},

			__matchedItemsChanged: function(value, oldValue) {
				if (this._tree) {
					this._model.prepareUpdate();
					this._tree.getManager().unselectAll();
					if (oldValue){
						oldValue.forEach(function(node) {
							node.unmatchSearch();
						});
					}

					this._matchedItems.forEach(function(node) {
						node.matchSearch();
						node.reverseExpand();
					});

					//Two lists to store searches based on Show ALl & Show Only valid
					var validNodesWhenShowAllEnabled=[];
					var validNodesWhenShowValidEnabled=[];
					var skipReSearch=false;
					var matchedItemsList=this._matchedItems;

					//unhide all nodes first
					this._hideTreeModel=false;
					var allNodes=this._model.getAllDescendants().reverse();
					var numOfNodesInModel=allNodes.length;
					var root = this._model.getRoots()[0];
					allNodes.forEach(function(node){
						node.show();
					});

					switch (this._searchKey) {
					case undefined:
						break;

					case '':
						if (this._showOnlyValidSelection && this.dataFilterKey){
							validNodesWhenShowValidEnabled=this._validItemsCache[this.dataFilterKey];
						} else {
							validNodesWhenShowAllEnabled = allNodes;
						}
						break;

					default:
						//If this search string is already searched earlier & showAll is selected.
						if (!this._showOnlyValidSelection && this._searchKey && this._searchedKeysCache[this._searchKey]){
							skipReSearch=true;
							validNodesWhenShowAllEnabled=this._searchedKeysCache[this._searchKey];
						} else if (this._searchKey && this._matchedItems.length!== 0){//if it is some new string to be searched or showOnlyValid is enabled
							var listAllDirectories=new Map();
							//create list of all directory nodes
							for (var i=0; i<numOfNodesInModel; i++){
								if (allNodes[i].getChildren()){
									listAllDirectories.set(allNodes[i], 0);
								}
							}

							//Now find all the valid directories based on search String
							//If directory contains search string, it should be visible.
							for (var i=0; i<numOfNodesInModel; i++){
								var currentNode= allNodes[i];
								//if this node is already present in matched Items list. Make its parent visible if it is not root node
								if (matchedItemsList.indexOf(currentNode)!== -1 && currentNode!== root){
									validNodesWhenShowAllEnabled.push(currentNode);
									listAllDirectories.set(currentNode.getParent(), 1);
								}//if it is root node & is present in matched nodes, store it in valid list
								else if (matchedItemsList.indexOf(currentNode)!==-1 && currentNode===root){
									validNodesWhenShowAllEnabled.push(currentNode);
									listAllDirectories.set(currentNode, 1);
								}
							}

							//now search for valid directories till root node & add them in valid nodes list
							listAllDirectories.forEach(function(value, directory){
								if (listAllDirectories.get(directory)===1 && directory !== root){
									listAllDirectories.set(directory.getParent(), 1);
								}
							});

							//Add these valid directories to valid node list
							listAllDirectories.forEach(function(key, directory){
								if (listAllDirectories.get(directory)===1 && validNodesWhenShowAllEnabled.indexOf(directory)===-1){
									validNodesWhenShowAllEnabled.push(directory);
								}
							});
						}
						//Now we have list of nodes to be shown when ShowAll is enabled. Stored in validNodesWhenShowAllEnabled.
						//Next step is to find nodes when showOnlyValid is enabled.
						if (this.dataFilterKey && this._validItemsCache[this.dataFilterKey]){
							//find details for valid nodes if dataFilterKey is available
							var listOfValidNodes=this._validItemsCache[this.dataFilterKey];
							var numValidNodes= listOfValidNodes.length;
							var listAllValidDirectories= new Map();

							//create list of valid directories
							for (var i=0; i<numValidNodes; i++){
								if (listOfValidNodes[i].getChildren()){
									listAllValidDirectories.set(listOfValidNodes[i], 0);
								}
							}

							var strictlyValidNodes = this._strictlyValidItemsCache[this.dataFilterKey];
							var numStrictlyValidNodes = strictlyValidNodes.length;

							//find nodes to be displayed
							for (var i=0; i<numStrictlyValidNodes; i++){
								var currentNode= strictlyValidNodes[i];
								//if this node is already present in matched Items list, Make its parent visible only if it is not root node
								if (matchedItemsList.indexOf(currentNode)!== -1 && currentNode!== root){
									validNodesWhenShowValidEnabled.push(currentNode);
									listAllValidDirectories.set(currentNode.getParent(), 1);
								} else if (matchedItemsList.indexOf(currentNode)!==-1 && currentNode===root){
									validNodesWhenShowValidEnabled.push(currentNode);
									listAllValidDirectories.set(currentNode, 1);
								}
							}

							//now search for valid directories till root node & add them in valid nodes list
							listAllValidDirectories.forEach(function(value, directory){
								if (listAllValidDirectories.get(directory)===1 && directory !== root){
									listAllValidDirectories.set(directory.getParent(), 1);
								}
							});

							//Add these valid directories to valid node list
							listAllValidDirectories.forEach(function(key, directory){
								if (listAllValidDirectories.get(directory)===1 && validNodesWhenShowValidEnabled.indexOf(directory)===-1){
									validNodesWhenShowValidEnabled.push(directory);
								}
							});
						}
						//now we have list of nodes to be displayed when showOnlyValid is enabled stored in validNodesWhenShowValidEnabled
						//store these searches for future use in _searchedKeysCache if not already stored.
						if (!skipReSearch){
							this._searchedKeysCache[this._searchKey]= validNodesWhenShowAllEnabled;
						}
						break;
					}//switch ends here

					if (this._showOnlyValidSelection && validNodesWhenShowValidEnabled.length===0){
						this._hideTreeModel=true;
					}
					//if showOnlyValid is set, hide remaining nodes except those in validNodesWhenShowValidEnabled
					else if (this._showOnlyValidSelection && validNodesWhenShowValidEnabled.length!==0){
						allNodes.forEach(function(node){
							if (validNodesWhenShowValidEnabled.indexOf(node)===-1){
								node.hide();
							}
						});
					} else {
						allNodes.forEach(function(node){
							if (validNodesWhenShowAllEnabled.indexOf(node)===-1){
								node.hide();
							}
						});
					}

					if (this._searchKey && this._matchedItems.length===0){
						this._hideTreeModel = true;
					}

					this._model.pushUpdate();
				}
			},

			__dataFilterKeyChanged: function() {
				var that = this;
				var listOfValidNodes =[];
				this._state = String(Number(this._state) + 1);
				this._hideTreeModel=false;
				if (this._validItemsCache.hasOwnProperty(this.dataFilterKey)) {
					this._validItems = this._validItemsCache[this.dataFilterKey];
					if (this._showOnlyValidSelection && this._validItems.length===0){
						this._hideTreeModel=true;
						this._strictlyValidItems=[];
						//this._strictlyValidItemsCache={};
					}
				} else {
					var allNodesInModel=this._model.getAllDescendants().reverse();
					var numOfNodesInModel=allNodesInModel.length;
					var listAllDirectories=new Map(); // using Map to avoid duplication of data

					this._strictlyValidItems=[];
					//this._strictlyValidItemsCache={};
					//create list of all directory nodes
					for (var i=0; i<numOfNodesInModel; i++){
						if (allNodesInModel[i].getChildren()){
							listAllDirectories.set(allNodesInModel[i], 0);
						}
					}

					//logic to find only valid nodes
					for (var i=0;i<numOfNodesInModel;i++){
						var currentNode=allNodesInModel[i];
						//Check if this node can be associated for given dataFilterKey
						if (that.dataFilterKey && currentNode && that._canAssociate(currentNode.options.data.data, that.dataFilterKey)){
							listOfValidNodes.push(currentNode);
							this._strictlyValidItems.push(currentNode);
							//find its parent element & set it as valid directory. Only if current node is not root node
							if (currentNode!== that._model.getRoots()[0]){
								listAllDirectories.set(currentNode.getParent(), 1);
							}
						}
					}

					//now find all valid directories till Root node
					listAllDirectories.forEach(function(value, directory){
						if (listAllDirectories.get(directory)===1 && directory !== that._model.getRoots()[0]){
							listAllDirectories.set(directory.getParent(), 1);
						}
					});

					//Add these valid directories to valid node list
					listAllDirectories.forEach(function(key, directory){
						if (listAllDirectories.get(directory)===1 && listOfValidNodes.indexOf(directory)===-1){
							listOfValidNodes.push(directory);
						}
					});

					//maintain separate list of strictly valid nodes i.e. this list is free from all intermediate nodes added later
					this._strictlyValidItemsCache[this.dataFilterKey]=this._strictlyValidItems;

					//normal list of valid nodes
					this._validItems = listOfValidNodes;
					if (this._showOnlyValidSelection && listOfValidNodes.length===0){
						this._hideTreeModel=true;
					}
					this._validItemsCache[this.dataFilterKey] = this._validItems;
				}
				this._state = String(Number(this._state) - 1);
			},


			reset: function() {
				if (this._tree) {
					this._tree.getManager().unselectAll();
					this.selectedKey = '';
					this._searchKey = '';
				}
			},

			/*
         * Custom filter that checks if a given process item type is available for association
         * This API is used declaratively as a part of filter expression in the component HTML
         * @returns {Boolean} Returns true if this process item fits the datatype filter criteria set by requested party(widget property)
      */
			_canAssociate: function(item, type) {
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
				isAcitivtySupported = function() {
					if (typesSupported.indexOf(TYPE.Activity) >= 0) {
						return (processitem.level === '0' && processitem.title.indexOf(TYPE.Activity) >= 0);
					}
					return false;
				};
				//Check that activity is supported or not
				isSimulationSupported = function() {
					if (typesSupported.indexOf(TYPE.Simulation) >= 0) {
						return (processitem.level === '0' && TYPE.Simulation.toLowerCase() === String(processitem.type).toLowerCase());
					}
					return false;
				};
				//currently, only DOE is supported so hardcoded this,
				//@TODO:: generalize it for any adapter
				isAdapterSupported = function(){
					return typesSupported[0] === 'doe_adapter' && processitem.level === '0' && processitem.extensionName === 'com.dassault_systemes.sma.adapter.Doe';
				};
				//Checks if data type is supported
				isDatatypeSupported = function() {
					//Consider this case for Parameter that is of type Object
					if (processitem.datatype === DATA_TYPE.refcontent) {
						return isContenttypeSupported();
					}
					//Singleval and datatypes 'string,int,real,timestamp'
					return typesSupported.indexOf(processitem.datatype) >= 0;
				};
				//Checks if value type 'single',multival','array' are supported
				isValuetypeSupported = function() {
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
				isListSupported = function() {
					return processitem.choices.length > 0 && typesSupported.indexOf('choices') >= 0 && typesSupported.indexOf('multival') === -1;
				};

				isMultiChoiceSupported = function() {
					return processitem.valuetype === 'multival' && processitem.choices && processitem.choices.length > 0 && typesSupported.indexOf('choices') >= 0 && typesSupported.indexOf('multival') >= 0;
				};

				isArraySupported = function() {
					return VALUE_TYPE.array === processitem.valuetype;
				};
				isDimensionSupported = function() {
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
				isContenttypeSupported = function() {
					return typesSupported.indexOf(processitem.datatype) >= 0;
				};
				//Checks if min,max boundaries are supported if available
				isRangeSupported = function() {
					return typesSupported.indexOf('range') >= 0;
				};

				choicesAvailable = function() {
					return processitem.choices && processitem.choices.length > 0;
				};

				rangeAvailable = function() {
					return !isNaN(parseFloat(processitem.maximum)) && !isNaN(parseFloat(processitem.minimum));
				};

				multiValueType = function() {
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
				} else if (isAdapterSupported()){
					associationSupported = true;
				} else
				//If it supports the data type(string,int,..) and value type(single,multi,array)
				{
					associationSupported = isDatatypeSupported() && isValuetypeSupported();
				}
				item._enabled = Boolean(associationSupported);
				return item._enabled;
			},

			showCreateModal: function(){
				var filter;
				this.$.modalcontainer.show();
				filter = {
					type: 'string,multiline,real,int,integer,range'
				};
				// It is taking to much times to process invalid items for tee list view
				this.async(function () {
					this.dataFilterKey = filter.type;
					this && this.$.searchprocessbrowser.focus();
					if (this.passDataToTreeView) {
						// this.data = this.processTreeData;
						this.$.searchprocessbrowser.focus();
						this.passDataToTreeView = false;
					}
					this.allAssociatedKeys = this.$.plmdata.getAllInstanceKeys();
				}.bind(this));
			},

			onOkay: function(){
				var association, selectedItems = this.selectedItemArray;
				if (selectedItems.length > 0){
					selectedItems.forEach(function(selectedItem){
						association = this._prepareAssociation(selectedItem);
						this.fire('createitem', {
							association: association,
							item: 'xs-wg-input-text',
							noWrap: false,
							addAtLast: true
						});
					}.bind(this));
				}
				this.selectedItemArray = [];
				this.reset();
				this.$.modalcontainer.hide();
			},

			onDismiss: function(){
				this.selectedItemArray = [];
				this.reset();
				this.$.modalcontainer.hide();
			},

			// TODO: Need to refactor this code. We should add typeInReadableFormat property
			// to meta.json & get rid of this function.
			_listSupportedTypes: function (treeDataFilterKey) {
				var typesInUserReadableFormat;
				switch (treeDataFilterKey) {
				case 'string,multiline,real,int,integer,range':
					typesInUserReadableFormat = 'String, multiline, real, integer, range';
					break;

				case 'owned_chooser,chooser':
					typesInUserReadableFormat = 'Plmobject - owned or referenced';
					break;

				case 'chooser':
					typesInUserReadableFormat = 'Plmobject - referenced';
					break;

				case 'array,int,integer,real,2D':
					typesInUserReadableFormat = '2d array of real, integer';
					break;

				case 'choices':
					typesInUserReadableFormat = 'Choices';
					break;

				case 'timestamp':
					typesInUserReadableFormat = 'Date';
					break;
				case 'boolean':
					typesInUserReadableFormat = 'Boolean';
					break;

				case 'string,multiline':
					typesInUserReadableFormat = 'Multiline string';
					break;

				case 'range,real,int,integer':
					typesInUserReadableFormat = 'Range, integer, real';
					break;

				case 'multival':
					typesInUserReadableFormat = 'Multivalue';
					break;

				case 'Activity,Simulation':
					typesInUserReadableFormat = 'Activity, Simulation';
					break;

				case 'doe_adapter':
					typesInUserReadableFormat = 'DOE Adapter';
					break;

				case 'Activity':
					typesInUserReadableFormat = 'Activity';
					break;

				case 'multival,choices':
					typesInUserReadableFormat = 'Multivalue from choices';
					break;

				default:
					typesInUserReadableFormat = 'String';
					break;
				}
				return typesInUserReadableFormat;
			},

			/**
			 * Private method that formats the selected process item to a format
			 * suitable for property inspector.
			 * Exposing on prototype to help for unit testing
			 */
			_prepareAssociation: function (item) {
				var key = item.key;

				var keyArray = key.split('/');
				var asscociation = {};

				asscociation.data = item.data;
				if (item.Type === TYPE.Simulation) {
					asscociation.kind = this.PLMData.KIND.SIMULATION;
					asscociation.uid = keyArray[1];
					asscociation.path = '';
				}			else if (keyArray[0] && keyArray[0] === this.PLMData.KIND.SIMULATION) {
					asscociation.kind = this.PLMData.KIND.SIMULATION;
					asscociation.uid = undefined;
					for (var ii = 1; ii < keyArray.length; ii++) {
						if (asscociation.path) {
							asscociation.path = asscociation.path + '/' + keyArray[ii];
						} else {
							asscociation.path = keyArray[ii];
						}
					}
				} else {
					asscociation.kind = this.PLMData.KIND.ACTIVITY;
					asscociation.uid = keyArray[1];
					for (var ii = 2; ii < keyArray.length; ii++) {
						if (asscociation.path) {
							asscociation.path = asscociation.path + '/' + keyArray[ii];
						} else {
							asscociation.path = keyArray[ii];
						}
					}
				}
				return asscociation;
			},

			_computeClass: function(_hideTreeModel){
				return _hideTreeModel ? 'hide' : 'browsecontent';
			},

			_computeClass1: function(_hideTreeModel){
				return _hideTreeModel ? 'emptytree' : 'hide';
			},

			_computeHeading: function(heading){
				return 'Select From Simulation ' + heading;
			},
			behaviors: [window.DS.SMAProcSP.SPBase]
		});
	});
}(this));
