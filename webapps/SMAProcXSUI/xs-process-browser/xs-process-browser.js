/*--

 */
/* global Polymer*/
(function (window) {
	'use strict';

	var
		indexBasicAttributes,
		indexProcessData,
		typesInReadableFormat,
		getTypeInReadableFormat,
		indexSimExecOptions,
		init,
		isActivity,
		isStep,
		isAdapter,
		showBrowser,
		ModelItem,
		DEFAULT_ICON,
		// Event handlers
		// Constants
		ROOT = 'ROOT',
		TITLE_DISPLAY = 'title_display',
		// Enums
		EVENT = {
			dataprepared: 'plmdata-prepared',
			dataselect: 'dataselect'
		},

		TYPE,
		DATA_TYPE,
		PLMDATA_TYPE;
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

	DEFAULT_ICON = 'right';
	// This is a mapping information stored between TYPE and types exposed by xs-wg-plm-data
	// TODO may get rid of this once the Enums are converged
	PLMDATA_TYPE = {
		Attribute: 'ATTRIBUTE',
		Parameter: 'PARAMETER',
		ExecOpt: 'EXECUTIONOPTIONS',
		Basics: 'BASICS',
		content: 'CONTENT'
	};
	// Data types exposed by iosummaryview/execution options
	DATA_TYPE = {
		string: 'string'
	};

	typesInReadableFormat = {
		string: 'String',
		real: 'Real',
		integer: 'Integer',
		"int": 'Integer',
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
		"boolean": 'Boolean',
		text: 'Text'
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
	 *                        This additional information will be used in getting all details required for the skeleton structure
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
	 * @param {JSON} processDetails - Simulation JSON
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
	 * @param {JSON} - ExecutionOptions JSON
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
			var execData = ExecutionOptions[index];
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
	};

	/**
	 * Private method to show the Process browser
	 */
	showBrowser = function () {
		this.$.modalcontainer.show();
		// Register Esc key listener to dismiss
		window.onkeydown = function (event) {
			if (event.keyCode === 27) {
				this.$.modalcontainer.hide();
				window.onkeydown = null;
			}
		}.bind(this);
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
				canMultiSelect: false
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

		if (this.$.treeview.isAttached) {
			this.passDataToTreeView = true;
			this.treeViewAttached();
		} else {
			this.passDataToTreeView = true;
		}
	};
	// Prototype
	/**
	@class XSProcessBrowser
	@constructor
	@extends SPBase
	**/
	window.XSProcessBrowser = Polymer({	    // jshint ignore:line
		is: 'xs-process-browser',
		properties: {
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
			},
			/**
			Callback method that's invoked once an item selected

			@attribute callback
			@type Function
			@default null
			 **/
			callback: {
				type: Object,
				value: function () {
					return null;
				}
			},

			// Attributes
			/**
			Introduced this in order to be able to trigger some custom filters
			on every directory change
			//TODO - Get rid of it

			@attribute datatypefilter
			@type String
			@default null
			 **/
			datatypefilter: {
				type: Object,
				value: function () {
					return {};
				}
			},
			/**
			Heading of the Process browser that depends on the Simulation title

			@attribute heading
			@type String
			@default 'Process Browser'
			 **/
			heading: {
				type: String,
				value: 'Process Browser'
			},
			// Saves step info
			steps: {
				type: Object,
				value: function () {
					return {};
				}
			},
			// if true, user can't bind new data
			disabled: {
				type: Boolean,
				value: false,
				notify: true
			}
		},
		// Life cycle methods
		attached: function () {
			this.$.plmdata.getPLMData(init, this);
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

		// Event handlers
		/**
		 * Dismisses process browser
		 */
		onDismiss: function () {
			this.$.modalcontainer.hide();
			this.$.treeview.reset();
		},

		/* Event is triggered when an user clicks on Okay */
		onOkay: function () {
			// If no selection has been done on the tree so far, hide the popup window.
			var kind, uid, path;
			if (this.$.treeview.isValidSelection && !this.disabled) {
				var association = this._prepareAssociation(this.$.treeview.selectedItem);
				kind = association.kind ? association.kind : '';
				uid = association.uid ? association.uid : '';
				path = association.path ? association.path : '';
				if (this.associatedPLMData && this.associatedPLMData.kind === kind &&
					this.associatedPLMData.uid === uid && this.associatedPLMData.path === path) {
					this.$.modalcontainer.hide();
					this.$.treeview.reset();
				} else {
					this.callback && this.callback(association);
					// Dismiss the Process browser
					this.$.modalcontainer.hide();
					this.$.treeview.reset();
					this.asyncFire(EVENT.dataselect, {
						association: association
					});
				}
			}
		},

		treeViewAttached: function () {
			if (this.passDataToTreeView) {
				this.$.treeview.data = this.processTreeData;
				this.$.treeview.$.searchprocessbrowser.focus();
				this.asyncFire(EVENT.dataprepared);
				this.passDataToTreeView = false;
			}
		},

		// Public methods
		/**
		 * Launch process browser
		 * @param {Object}   filter              Filter that determines what process data the browser shows
		 * @param {Object}   associatedPLMDataId Currently associated xs-wg-plm-data id.This is used in navigating to the right level
		 *                                       when browser is launched
		 * @param {Function} callback            Callback method to be called by process browser once some data is selected
		 */
		launch: function (filterCriteria, associatedPLMDataId, callback) {
			this._callWhenLoaded(this.$.treeview, function() {
				this.callback = callback;
				this.associatedPLMData = false;
				// Show the Process browser
				showBrowser.call(this);
				// It is taking to much times to process invalid items for tee list view
				this.async(function () {
					this.$.treeview.dataFilterKey = filterCriteria.type;
					this.$.treeview.$ && this.$.treeview.$.searchprocessbrowser.focus();
					//need to find a way to select this element
					if (associatedPLMDataId) {
						this.associatedPLMData = this.$.plmdata.getInstanceById(associatedPLMDataId);
						this.$.treeview.selectedKey = this.associatedPLMData.kind + '/' + this.associatedPLMData.uid + '/' + this.associatedPLMData.path;
					} else {
						this.$.treeview.selectedKey = '';
					}
					this.$.treeview.allAssociatedKeys = this.$.plmdata.getAllInstanceKeys();
				}.bind(this));
			}.bind(this));
		},

		/**
		 * TO call some function after component is attached
		 * @param  {Node} node - node for which we are waiting to get attached
		 * @param  {Function} callback - Function which is to be called after component is attached
		 */
		_callWhenLoaded: function (node, callback) {
			if (node.isAttached) {
				callback();
			} else {
				node.addEventListener(node.tagName.toLowerCase() + '-loaded', function onLoaded() {
					node.removeEventListener(node.tagName.toLowerCase() + '-loaded', onLoaded);
					callback();
				});
			}
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

		behaviors: [window.DS.SMAProcSP.SPBase],
		_computeHeading: function (heading) {
			return 'Associate From Simulation ' + heading;
		},
		_computeDisabled: function (isValidSelection, disabled) {
			if (isValidSelection && !disabled) {
				return false;
			}
			return true;
		},
		refreshProcessBrowser: function () {
			this.$.plmdata.getPLMData(init, this);
		}
	});
}(this));
