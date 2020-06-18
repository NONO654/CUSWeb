/*--------------------------------------------------------------------
[xs-wg-plm-data JS Document]

Project:        xs
Version:        1.0
Last change:    Wed, 11 Nov 2015 15:46:53 GMT
Assigned to:    Aravind Mohan
Description:    Gets and Sets plm data. This component tracks every
                instance which are made and works as a single entity
---------------------------------------------------------------------*/
/**

    @module SMAProcXS
    @submodule xs-wg-plm-data
    @class xs-wg-plm-data
    @description
       Gets and sets the plm data


    @example
    <h5>HTML</h5>

        <!-- Scenario 1 : Using the component to get process information |  canvas -->
        <xs-wg-plm-data uid="1215.05452.0545.5455"></xs-wg-plm-data>

        <!-- Scenario 2 : Using the component to consume process information | process browser -->
        <xs-wg-plm-data></xs-wg-plm-data>

        <!-- Scenario 3 : Using the component to consume process information | process browser -->
        <xs-wg-plm-data uid="Activity15462335454" kind="Activity" path="parameters/parama"></xs-wg-plm-data>
        <xs-wg-plm-data kind="Simulation" path="parameters/parama"></xs-wg-plm-data>

    @example
    <h5>JS</h5>
        //Async
        xsWgPlmData.getProcessData(callback);
*/
/* global DS, Polymer*/

(function (window) {
	'use strict';

	var EVENT,
		// Module variables
		plmData, instances, callbackQueue, identity, IDENTIFIER, PLMData, _access, _readonlyaccess,
		itemToUpdate, SIMULATION, activityid, pendingItemInstances,
		// Private methods
		isExpressionDriven, isReadonlyBasicAttr, extractId, isDataReady, forEachIOSummaryActivity, isAdapter, capitalizeFirstLetter, _updateJobStatusData;
	// Initialization
	instances = {};
	pendingItemInstances = [];
	callbackQueue = {};
	EVENT = {
		PLM_DATA_READY: 'plmdataready',
		PLM_DATA_SAVE: 'plmdatasave',
		PLM_DATA_ERROR: 'plmdataerror',
		PLM_DATA_SUCCESS: 'plmdatasuccess',
		PLM_DATA_CHANGE: 'plmdatachange',
		UPDATE_BINDING: 'updatebinding'
	};
	identity = 0;
	// Wrapper for PLMData Class - Factory
	PLMData = (function () {
		var PLMData, sources, index, indexingActivityId,
			// Enums
			KIND, ITEM_TYPE,
			// Methods
			indexBasics, indexProcessId, beginIndexing, getKind, getType, getSubType;
		KIND = {
			SIMULATION: 'simulations',
			ACTIVITY: 'activities'
		};
		ITEM_TYPE = {
			PARAMETER: 'parameters',
			ATTRIBUTE: 'attributes',
			EXECUTIONOPTIONS: 'executionoptions',
			BASICS: 'basics',
			CONTENT: 'content',
			STEPS: 'steps'
		};
		// For future data addition
		/* Content = function(item) {
            this.item = item;
        };*/
		// Gets the kind of category
		getKind = function (item) {
			// If item is a Simulation
			if (item.title === 'Simulation') {
				SIMULATION = item.objectId;
				return KIND.SIMULATION + '/';
			}
			// If item is an Activity
			if (item.title.search(/Activity/) === 0) {
				// Maintain which activity's data is being indexed for items like Steps to use later
				indexingActivityId = item.sequence;
				activityid = item.objectId;
				return KIND.ACTIVITY + '/' + item.sequence;
			}
			// If item is an Activity's step
			if (item.title.search(/Step/) === 0) {
				// Resource can only be Simulation or Activity.So 'Kind' is 'Activity' for a Step too.
				return KIND.ACTIVITY + '/' + indexingActivityId;
			}
			return undefined;
		};

		/**
         * Returns sub type information if the item is a Step.This information may be included in the path attribute
         * This API may be extended in future to handle folders or atribute groups
         * @param {Object} item - An object from the source data
		 * @returns {String} sub type
         */
		getSubType = function (item) {
			if (item.title.search(/Step/) === 0) {
				return ITEM_TYPE.STEPS + '/' + item.id;
			}
			return '';
		};
		// Get the type of process item
		getType = function (item) {
			var itemType;
			if (item.syncAssist === 'Parameter') {
				itemType = ITEM_TYPE.PARAMETER + '/' + item.title;
			} else if (item.syncAssist === 'content') {
				itemType = 'content' + '/' + item.chooser_physicalid; // jshint ignore:line
			} else if (item.syncAssist === 'Attribute') {
	            itemType = ITEM_TYPE.ATTRIBUTE + '/' + item.title;
			} else if (item.syncAssist === 'ExecOpt') {
	            itemType = ITEM_TYPE.EXECUTIONOPTIONS + '/' + item.title;
			}
			return itemType;
		};

		/**
         * Index basic attributes of Simulation/Activity.
         * We have this method because the structure for Basic attributes needs to be treated differently
         * @param {[[Type]]} source - Data
         * @param {[[Type]]} type   - activities/simulation. Blank is assumed as Simulation
         * @param {[[Type]]} id     - Path to the activity if type is 'activities'
         */
		indexBasics = function (source, type, path) {
			Object.keys(source).forEach(function (key) {
				var basic = {
					id: key,
					title: key,
					value: source[key]
				};
				// Add the reflector function
				basic.reflect = function (instance) {
					source[key] = basic.value;
					instance._setPendingUpdates(source);
				};
				basic.addPendingReflect = function () {
					source[key] = basic.value;
					return source;
				};
				if (type === KIND.ACTIVITY) {
					index[path + '/basics/' + key] = basic;
				} else {
					index['simulations//basics/' + key] = basic;
				}
			});
		};

		indexProcessId = function (data) {
			var simData = {
				basics: data.basics,
				attributes: data.attributes,
				objectId: data.id,
				title: data.attributes.title
			};
			// process id changes on instantiation hence setting a constant string. Need to find a way if we want to support multiple process
			// index[KIND.SIMULATION + '/' + data.attributes.definition.process.id + '/'] = simData;
			index[KIND.SIMULATION + '/process1/'] = simData;
		};

		/**
         * Index all data about the simulation by their kind, path and type of item (attr/param/basics..)
         * @param {Object} data - Data to be indexed
         */
		beginIndexing = function (data) {
			var kind, subType;
			// If it is not an array type it is containing basics
			if (!data.forEach) {
				index.basics = [];
				indexProcessId(data);
				indexBasics(data.basics);
				indexBasics(data.attributes);
				return;
			}
			// Constructs the process structure from plmdata
			data.forEach(function (item) {
				var itemType;
				if (item.level === '0') {
					// Get Simulation or Activity level information
					kind = getKind(item);
					// Get information for any sub type like Step.This will be included in the path
					subType = getSubType(item);
					subType = subType ? subType + '/' : '';
					// If it's an activity, index its basic attributes
					if (item.title.search(/Activity/) === 0) {
						// PATCH to add activity in index list
						index[kind + '/'] = item;
						indexBasics(item, KIND.ACTIVITY, kind);
					}
					if (isAdapter(item)) {
						item.activityid = activityid;
						item.SIMULATION = SIMULATION;
						index[kind + '/' + subType] = item;
					}
				} else if (item.level === '2') {
					itemType = getType(item);
				}

				// If itemType exist
				if (itemType) {
					// content = new Content(item);
                	if (item.datatype === 'boolean' && item.valuetype !== 'multival') {
                		if (String(item.value).toLowerCase() === 'true') {
                			item.value = 'true';
                		} else {
                			item.value = 'false';
                		}
                	}
					index[kind + '/' + subType + itemType] = item;
				}
			}, this);
		};

		PLMData = function () {
			// Initialize
			sources = {};
			index = {};
		};
		// Enum
		PLMData.prototype.SOURCE = {
			IOSUMMARYVIEW: 'iosummaryview',
			EXECUTIONOPTIONS: 'executionoptions',
			SIMULATION: 'simulation',
			EXTERNAL: 'external',
			COSDATALOADED: 'cosdataloaded',
			COSDATA: 'cosdata'
		};
		// Adds a new plm data source
		PLMData.prototype.addSource = function (source, data) {
			sources[source] = data;
			// Begin indexing the source data
			if (source !== 'cosdata') {
				beginIndexing(data);
			} else {
				sources.cosdataloaded = true;
			}
		};
		// Adds a new plm data source
		PLMData.prototype.addExternalSource = function (instance) {
			var extValue;
			extValue = {
				kind: instance.kind,
				uid: instance.uid,
				path: instance.path,
				value: instance.uid,
				title_display: 'Attribute Group' // jshint ignore:line
			};
			// Add external data source to index
			index[extValue.kind + '/' + extValue.uid + '/' + extValue.path] = extValue;
		};

		// Adds a new plm data source
		PLMData.prototype.clearAllSource = function () {
			sources = {};
			index = {};
		};

		// Returns the source
		PLMData.prototype.getSource = function (source) {
			return sources[source];
		};
		// Returns the content by kind, uid, path match
		PLMData.prototype.getContent = function (kind, uid, path) {
			return index[kind + '/' + uid + '/' + path];
		};

		// Returns the content by kind, uid, path match
		PLMData.prototype.getContent = function (kind, uid, path) {
			return index[kind + '/' + uid + '/' + path];
		};

		// Returns the value by kind, uid, path match
		/*   PLMData.prototype.getValue = function (kind, uid, path) {
                    //var content = this.getContent(kind, uid, path);
                    var content;
                    content = index[kind + '/' + uid + '/' + path];

                    //Return the item if content has an item else null
                    return content ? content.item : null;
                };*/
		// Expose the enums
		PLMData.prototype.KIND = KIND;
		PLMData.prototype.ITEM_TYPE = ITEM_TYPE;
		PLMData.prototype.item = {
			getKind: getKind,
			getType: getType
		};
		// Return the instance (Using this as Singleton)
		return PLMData;
	})();
	// Private methods
	/* Checks if a given instance represents a Read only Basic attribute (Like owner, originated..)
     * @param   {Object}   _this - PLM data instance to be checked
     * @returns {boolean}  True if it's a Read only Simulation Basic attribute or any Activity basic attribute
     */
	isReadonlyBasicAttr = function (_this) {
		var EDITABLE_ATTR, attrName;
		// Two attributes editable in Simulation Basics
		EDITABLE_ATTR = [
			'title',
			'description',
			'Simulation Study'
		];
		if (_this.isBasics(_this.path)) {
			// Get the basics attribute name
			attrName = _this.path.substr(_this.path.lastIndexOf('/') + 1);
			// Currently, all activity basic attributes(Only title available) are non-editable.
			// So a Basic attribute is editable only if it's for Simulation
			return _this.kind === plmData.KIND.SIMULATION && (EDITABLE_ATTR.indexOf(attrName) < 0) || _this.kind === plmData.KIND.ACTIVITY;
		}
	};
	/* Checks if a given instance represents a Parameter with Expression assigned.
     * @param   {Object}   _this - PLM data instance to be checked
     * @returns {boolean}  True if it's a Parameter with Expression
     */
	isExpressionDriven = function (_this) {
		var instanceData;
		if (_this.oid){
			return false;
		} else {
			instanceData = _this.getRawValue();
			return instanceData && !_this.JS.isEmpty(instanceData.Expression);
		}
	};

	/**
     * Private method that extracts the id from the string (name). Uses the identifier to match
     * @param   {String} name - example (xs_wg_plm_data_23)
     * @param   {String} identifier - example (xs_wg_plm_data)
     * @returns {String} id - example (23)
     * @example
     * extractId('xs_wg_plm_data_23', 'xs_wg_plm_data') returns 23;
     */
	extractId = function (name, identifier) {
		var nameId = null,
			endMatch = '[0-9]*$';
		// If there is a match
		if (name.search(new window.RegExp('^' + identifier + endMatch)) > -1) {
			nameId = window.parseInt(name.match(new window.RegExp(endMatch))[0], 10);
		}
		return nameId;
	};

	/**
     * Private method used to check if all the Web service responses for fetching Process data are available
     * @param   {Object}   plmData - PLMData(Private object in the module) instance
     * @returns {boolean} True if data is available from all data sources
     */
	isDataReady = function (plmData) {
		//xs-wg-cos-data is LA right now. Remove this condition once UI Dynamicity function is GA
		if (localStorage.getItem('XS_RUN') === 'true') {
			return plmData.getSource(plmData.SOURCE.IOSUMMARYVIEW) && plmData.getSource(plmData.SOURCE.EXECUTIONOPTIONS)
			&& plmData.getSource(plmData.SOURCE.SIMULATION) && plmData.getSource(plmData.SOURCE.COSDATALOADED);
		}else{
			return plmData.getSource(plmData.SOURCE.IOSUMMARYVIEW) && plmData.getSource(plmData.SOURCE.EXECUTIONOPTIONS)
			&& plmData.getSource(plmData.SOURCE.SIMULATION);
		}
	};
	isAdapter = function (item) {
		return item.level === '0' && item.extensionName && item.extensionName.contains('com.dassault_systemes.sma.adapter');
	};

	/**
     * Private method through which a callback can be registered for every Activity and ROOT level Simulation
     * Makes it easier to loop over items per activity from iosummaryview data
     * @param {function} callback - this callback function will be invoked for every activity with the following arguments
     *                            callback(activityItem, CollectionOfItemsUnderActivity, {kind:<kind>,uid:<uid>} for the acitivity)
     */
	forEachIOSummaryActivity = function (callback) {
		var associationAttr, activity, activityDetails, childItems, processData;
		associationAttr = {};
		childItems = [];
		processData = plmData.getSource(plmData.SOURCE.IOSUMMARYVIEW);
		if (processData) {
			processData.forEach(function (item) {
				// Determine the activity that's being iterated over
				if (item.level === '0') {
					// Send all level2 items for previous activity
					activity && callback && callback(activity, childItems, associationAttr);
					// Reset for current activity
					childItems = [];
					activity = item;
					// Prepare association data for current activity
					activityDetails = plmData.item.getKind(item).split('/');
					associationAttr.kind = activityDetails[0];
					associationAttr.uid = activityDetails[1];
				}
				if (item.level === '2') {
					childItems.push(item);
				}
			});
		}
		// Last level 2 object(Activity/Simulation)
		activity && callback && callback(activity, childItems, associationAttr);
	};

	_updateJobStatusData = function(plmData){
		var item, cosData, kind, uid, items = [];
		cosData = plmData.getSource(plmData.SOURCE.COSDATA);
		for (var key in cosData) {
			if (cosData.hasOwnProperty(key)) {
				if (key === 'process1') {
					kind = 'simulations';
					uid = 'process1';
					item = plmData.getContent(kind, uid, '');
					item.jobstate = cosData.process1;
				} else  {
					kind = 'activities';
					uid = key;
					item = plmData.getContent(kind, uid, '');
					if (!item) {
						uid = capitalizeFirstLetter(key);
						item = plmData.getContent(kind, uid, '');
					}
					item.jobstate = cosData[key];
				}
				items.push({
					kind: kind,
					uid: uid,
					path: ''
				});
			}
		}
		return items;
	};

	capitalizeFirstLetter = function(string) {
		return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
	};

	/**
            @class XSWgPlmData
            @constructor

        **/
	window.Polymer({
		is: 'xs-wg-plm-data',
		properties: {
			// Private
			_adp: {
				type: Object,
				value: null
			},
			_content: {
				value: null
			},
			kind: {
				type: String,
				notify: true
			},
			path: {
				type: String,
				notify: true
			},
			uid: {
				type: String,
				notify: true,
				observer: 'uidChanged'
			},
			oid: {
				type: String
			},
			// Attributes
			value: {
				type: Object,
				notify: true,
				observer: 'valueChanged'
			}
		},
		// Public properties
		get identity() {
			return identity;
		},
		set identity(value) {
			throw new Error('identity is readonly' + value);
		},
		// Private properties
		get plmData() {
			return plmData;
		},
		set plmData(value) {
			throw new Error('plmData is readonly' + value);
		},
		// Event handlers
		ready: function () {
			plmData = plmData || new PLMData();
			IDENTIFIER = this.tagName.toLowerCase().replace(/\-/g, '_') + '_';
			// Get the adapter
			this._adp = this.XS();
		},
		attached: function () {
			var plmDataValue, id;

			// Add it to the instance list
			instances[this.id] = this;

			// If it's a external data source then add it global index
			if (this.kind === plmData.SOURCE.EXTERNAL) {
				plmData.addExternalSource(this);
			}
			// Store the reference to the content
			// this._content = plmData.getContent(this.kind, this.uid, this.path);
			// Publish the value if its available
			if (isDataReady(plmData)) {
				plmDataValue = plmData.getContent(this.kind, this.uid, this.path);
				// If the compound value is present
				if (plmDataValue) {
					this.value = plmDataValue.value;

					// Validate the data
					this._validate();
				}
			}
			// Parse the widget name to get the numeric part (Only if the widget has default naming pattern)
			id = extractId(this.id, IDENTIFIER);
			// Use the highest name id to generate the identity
			identity = identity <= id ? id + 1 : identity;

			// Redo the node indexing
			this.async(function () {
				this.DOM(this).indexNodesById(this.$);
			});
		},
		detached: function () {
			// Remove it from the instance list
			 delete instances[this.id];
			 pendingItemInstances = [];
			// Use the highest name id to generate the identity
			identity = extractId(this.id, IDENTIFIER) === identity - 1 ? identity - 1 : identity;
			// Clear any errors
			this._adp.clearError();
		},
		// Event handlers
		/**
         * uid Attribute change listener
         * Re-initialize PLM data everytime a different Process' data is requested for
         */
		uidChanged: function () {
			// This condition makes sure this is for the entire Process resource and not
			// subset of the Process data(this.path would have specific subset data path in such a case)
			if (this.kind === '' && this.path === '' && this.uid) {
				// Create a new instance to reset any previous instance
				plmData = new PLMData();
			}
		},

		/**
         * Event handler when a Process data is ready
         * @param {Object}   event  dataready event triggered by sp-webservice on response
         * @param {[[Type]]} detail [[Description]]
         * @param {[[Type]]} sender [[Description]]
         */
		onDataReady: function (event) {
			var source, data, tempItems = [];
			source = event.target.id;
			data = event.target.data;
			// Add the data as its source
			// 1 'iosummaryview', this.$.iosummaryview.model
			// 2 'executionoptions', this.$.executionoptions.model
			// 3 'simulation', this.$.simulation.model
			plmData.addSource(source, data);
			// Store the data as it was when the session started
			var keyprefix = this.tagName;
			if (this.$.dashboard.isInDashboard()) {
				keyprefix = this.$.dashboard.getWidgetId();
			}
			sessionStorage.setItem(keyprefix + '_' + source, JSON.stringify(data));
			// If both the data source are added as plm data source
			if (isDataReady(plmData)) {
				// Expose the access component for rest of the instances
				_access = Polymer.dom(this.root).querySelector('#access');
				_readonlyaccess = Polymer.dom(this.root).querySelector('#readonlyaccess');
				//update COS status to plm data
				//PLM data is uddated with cos info
				_updateJobStatusData(plmData);
				// Publish the data to instances
				Object.keys(instances).forEach(function (key) {
					var instance = instances[key],
						plmDataValue;
					plmDataValue = plmData.getContent(instance.kind, instance.uid, instance.path);
					// If the compound value is present
					if (plmDataValue && plmDataValue.value) {
						instance.value = plmDataValue.value;
					}
					//Also redo the bindings for all binded component
					//redo all bindings ----
					tempItems.push({
						kind: instance.kind,
						uid: instance.uid,
						path: instance.path
					});
				}, this);

				// Publish the data to subscribers
				Object.keys(callbackQueue).forEach(function (key) {
					try {
						var queue = callbackQueue[key];
						if (queue) {
							// Notify that the data is ready through callbacks
							queue.forEach(function (callback) {
								callback(plmData);
							}, this);
						}
					}catch(ex) {}
				});
				// Broadcast PLM data is ready
				//TODO redo bindings after data is done
				this.asyncFire(EVENT.PLM_DATA_CHANGE, {type: EVENT.UPDATE_BINDING, items: tempItems});
				this.asyncFire(EVENT.PLM_DATA_READY, this);
				// Clear the queue
				callbackQueue = {};
			}
		},
		// Validates the plm data
		_validate: function () {
			var isValid, errors = [],
				item, val;
			// item = this._content.item;
			item = plmData.getContent(this.kind, this.uid, this.path);
			val = this.value;
			// When item value is empty, if it is mandatory, mark it as error. Else return without performing further validation
			if (this.JS.isEmpty(val)) {
				if (item.mandatory) {
					errors.push('Cannot be empty');
				} else {
					return true;
				}
			}
			// Min check
			if (Number(item.minimum) && Number(val) < Number(item.minimum)) {
				errors.push('Needs to be greater than or equal to ' + item.minimum);
			}
			// Max check
			if (Number(item.maximum) && Number(val) > Number(item.maximum)) {
				errors.push('Needs to be less than or equal to ' + item.maximum);
			}
			// Validate based on datatype
			// If its an integer / real
			if ((item.datatype === 'integer' || item.datatype === 'real') && isNaN(parseFloat(val))) {
				errors.push('Needs to be a number');
			}
			if (item.datatype === 'timestamp') {}
			// TODO
			// Is the value valid without any errors?
			isValid = !errors.length;
			// If there are errors, log them
			if (!isValid) {
				this._adp.setError({
					title: item.title,
					description: errors.join('\n')
				});
			} else if (this._adp.hasError) {
				// Clear the adapter error state if there are no errors
				this._adp.clearError();
			}
			return !errors.length;
		},
		valueChanged: function () {
			this.async(function () {
			// If the root has write access

			// Reflect the changes from the value back to the plm data
				if (this.oid) {
					this.getRawValue(function(item){
						var event;
						if (item) {
							this.value = item.datatype === 'boolean' ? this.value.toString() : this.value;
						}

						if (item && item.value !== this.value && !this.isActivity(item)) {
							// If the value was set by binding expression
							if (this.value && this.value.search &&
							this.value.search('{{' + this.id + '}}') === 0) {
								this.value = item.value;
							} else if (_access.accesses.indexOf('write') > -1) {
								item.value = this.value;
								itemToUpdate = item.hasOwnProperty('chooser_physicalid') ? item : null;
								if (!isAdapter(item)) {
									event = this.fire(EVENT.PLM_DATA_CHANGE);
									if (!event.isDefaultPrevented) {
										// If it was supposed to be reflected
										if (item.reflect) {
											item.reflect(this);
										} else {
											// Save the changes
											this._setPendingUpdates(item);
										}
									} else {
										// If it was supposed to be reflected
										if (item.reflect) {
											pendingItemInstances = this._addItemInstanceIfNotPresent(pendingItemInstances, item.addPendingReflect());
										} else {
											// Save the changes
											pendingItemInstances = this._addItemInstanceIfNotPresent(pendingItemInstances, item);
										}
									}
								}
							}
						} else if (!item && this.oid === undefined) {
							console.group('Unable to retrieve plmData');
							console.log(this.kind);
							console.log(this.uid);
							console.log(this.path);
							console.groupEnd();
						}
					}.bind(this));

					// There should have been a change

				} else {
					var item = plmData.getContent(this.kind, this.uid, this.path), event;

					// There should have been a change
					if (item) {
						this.value = item.datatype === 'boolean' ? this.value.toString() : this.value;
					}

					if (item && item.value !== this.value && !this.isActivity(item)) {
						// If the value was set by binding expression
						if (this.value && this.value.search &&
                        this.value.search('{{' + this.id + '}}') === 0) {
							this.value = item.value;
						} else if (_access.accesses.indexOf('write') > -1) {
							item.value = this.value;
							itemToUpdate = item.hasOwnProperty('chooser_physicalid') ? item : null;
							if (!isAdapter(item)) {
								event = this.fire(EVENT.PLM_DATA_CHANGE);
								if (!event.isDefaultPrevented) {
									// If it was supposed to be reflected
									if (item.reflect) {
										item.reflect(this);
									} else {
										// Save the changes
										this._setPendingUpdates(item);
									}
								} else {
									// If it was supposed to be reflected
									if (item.reflect) {
										pendingItemInstances = this._addItemInstanceIfNotPresent(pendingItemInstances, item.addPendingReflect());
									} else {
										// Save the changes
										pendingItemInstances = this._addItemInstanceIfNotPresent(pendingItemInstances, item);
									}
								}
							}
						}
					} else if (!item && this.oid === undefined) {
						console.group('Unable to retrieve plmData');
						console.log(this.kind);
						console.log(this.uid);
						console.log(this.path);
						console.groupEnd();
					}
				}

			});
		},
		/**
		 *  Add this sp-data instance to pending if not present
		 * @param {Array} instances global pendingItem instances
		 * @param {Object} instance current item which has to be updated
		 * @returns {Array} updated global pending instances
		 */
		_addItemInstanceIfNotPresent: function(instances, instance) {
			var isPresent = false;
			instances.forEach(function(itemInstance) {
				isPresent = itemInstance._$instance.id === instance._$instance.id;
			});
			if (!isPresent) {
				instances.push(instance);
			}
			return instances;
		},

		/**
		 *  Add this sp-data instance to pending if not present
		 * @param {Array} instances global pendingItem instances
		 * @param {Object} instance current item which has to be updated
		 * @returns {Array} updated global pending instances
		 */
		_removeItemInstanceIfPresent: function(instances, instance) {
			var index = -1, instanceIndex = -1;
			instances.forEach(function(itemInstance) {
				index++;
				if (itemInstance._$instance.id === instance._$instance.id) {
					instanceIndex  = index;
				}
			});
			if (instanceIndex !== -1) {
				instances.splice(instanceIndex, 1);
			}
			return instances;
		},

		_flushPendingItemInstances: function(instances) {
			instances.forEach(function(instance){
				instance.update();
			});
			//Clear this after calling all updates
			return [];
		},

		_setPendingUpdates: function (instance) {
			var spData;
			spData = instance._$instance;
			this._invalidateUpdates(spData, instance);
		},

		_invalidateUpdates: function (spData, instance) {
			spData._lastChanged = (new Date()).getTime();
			this.async(function () {
				// is now after last change and 1 second has passed
				if (((new Date()).getTime() - spData._lastChanged) > 1000) {
					// If yes the flush all updates
					this._flushUpdates(instance);
				}
			}.bind(this), 1001);
		},

		_flushUpdates: function (instance) {
			instance.update();
			pendingItemInstances = this._removeItemInstanceIfPresent(pendingItemInstances, instance);
			pendingItemInstances = this._flushPendingItemInstances(pendingItemInstances);
		},

		onRequest: function (event) {
			var result;
			// Check if its an update request
			if (event.detail.verb === 'PUT') {
				result = this.fire(EVENT.PLM_DATA_SAVE, this);
				// If it is not supposed to be saved
				if (result.isDefaultPrevented) {
					event.preventDefault();
				}
			}
			// Stop the event from propagating further
			event.stopPropagation();
		},
		onResponse: function (event) {
			var detail = event.detail;
			// If its an update request and a success
			if (detail.verb === 'PUT') {
				this.asyncFire(EVENT.PLM_DATA_SUCCESS, this);
			}

			// Stop the event from propagating further
			event.stopPropagation();
		},
		onIOResponse: function (event) {
			// need to update the iosummaryview data
			// if the IOSUMMARYVIEW WS is called while changing the document only
			if (event.detail.verb === 'PUT' && itemToUpdate) {
				// var io = Polymer.dom(this.root).querySelector('#iosummaryview');
				var response = event.detail.response;
				response = JSON.parse(response);
				this.updateIOsummaryData(response);
				itemToUpdate = null;
			}
		},

		onError: function (event) {
			var detail = event.detail;

			event.stopPropagation();
			if (detail.verb === 'PUT') {
				if (detail.xhr && detail.xhr.response) {
					try {
						var response = JSON.parse(detail.xhr.response);
						this.fire(EVENT.PLM_DATA_ERROR, JSON.stringify(response.errorMessage));
					} catch (ex) {
						this.fire(EVENT.PLM_DATA_ERROR, JSON.stringify(detail.xhr.response));
					}
				} else if (detail.response) {
					try {
						var response = JSON.parse(detail.response);
						this.fire(EVENT.PLM_DATA_ERROR, JSON.stringify(response.errorMessage));
					} catch (ex) {
						this.fire(EVENT.PLM_DATA_ERROR, JSON.stringify(detail.response));
					}
				} else {
					this.fire(EVENT.PLM_DATA_ERROR, 'Unable to Save Changes.');
				}
			}
		},
		// updating the content of IOSummaryview inside the SPData
		updateIOsummaryData: function (response) {
			// object to update in io.data
			var target = response.filter(function (obj) {
				// object is content chooser and the physical id of item and io.data object are same
				if (obj.hasOwnProperty('chooser_value_orig') &&
                    obj.chooser_physicalid === itemToUpdate.chooser_physicalid) { // jshint ignore:line
					return true;
				}
				return false;
			});
			// the io.data gets updated and now for next response the comparision for
			// document change occurs based on chooser_value_orig and not physicalId
			itemToUpdate.chooser_value_orig = target[0].chooser_value_orig; // jshint ignore:line
      Object.keys(target[0]).forEach(function(index){
        itemToUpdate[index] = target[0][index];
      });
		},
		// Public Methods
		// Returns the data managed by this component
		// Use the callback to subscribe
		getPLMData: function (callback, context) {
			// Initialize the queue if its empty
			callbackQueue[this.id] = callbackQueue[this.id] || [];
			// Store it so to call it when data is ready
			// Add it as the subscriber
			callbackQueue[this.id].push(callback.bind(context));
			if (isDataReady(plmData)) {
				callback.call(context, plmData);
				// Remove callback function from the queue once it's called.
				callbackQueue[this.id] && callbackQueue[this.id].pop();
			}
		},
		getInstanceById: function (id) {
			return instances[id];
		},
		/**
         * Public method that returns xs-wg-plm-data instance that has the specified attributes
         * @param   {Object}  args - Expected to be in format {kind:'kind',uid:'uid',path:'path'}. Only uid is optional
         * @returns {Object} instance - xs-wg-plm-data instance
         */
		getInstanceByAttr: function (args) {
			var instance, instanceFound;
			// Loop over instance keys until some match is found
			instanceFound = Object.keys(instances).some(function (key) {
				instance = instances[key];
				return instance.kind === args.kind && (instance.uid === args.uid || (!args.uid && !instance.uid)) && instance.path === args.path;
			});
			// If a matching instance was found, return it
			return instanceFound ? instance : null;
		},

		getAllInstanceKeys: function () {
			var keysAssociated = [];
			var instance;
			Object.keys(instances).forEach(function (key) {
				instance = instances[key];
				keysAssociated.push(instance.kind + '/' + instance.uid + '/' + instance.path);
			});
			return keysAssociated;
		},
		// Filters
		isBasics: function (path) {
			return Boolean(path && path.search(/^basics\//) > -1);
		},
		/**
         * Public method that returns information about mandatory attributes that do not have a corresponding plm data instance
         * or those that do not have any values
         * @param   {String}  checkType - 'association' or 'value'.Indicates what needs to be checked
         * @returns {Array} Collection of errors
         */
		validateMandData: function (checkType) {
			var activityTitle, instanceFound, itemsWithErrors, errors, validationMessage, ASSOCIATION_MISSING_MSG = ' Not all mandatory attributes have been exposed',
				VALUE_MISSING_MSG = ' Missing mandatory values',
				CHECK_TYPE;
			CHECK_TYPE = {
				association: 'association',
				value: 'value'
			};
			validationMessage = checkType === CHECK_TYPE.association ? ASSOCIATION_MISSING_MSG : VALUE_MISSING_MSG;
			errors = [];
			itemsWithErrors = '';
			// Iterate over all items under a Simulation and all activities
			forEachIOSummaryActivity(function (activity, items, associationAttr) {
				// Reset errors string for the each activity
				itemsWithErrors = '';
				items.forEach(function (item) {
					// If it is a mandatory attribute with no default value
					if (item.syncAssist === 'Attribute' && item.mandatory === 'true' && this.JS.isEmpty(item.value)) {
						// if the check is for Association, also validate if there is a xs-wg-plm-data instance available for it
						if (checkType === CHECK_TYPE.association) {
							instanceFound = this.getInstanceByAttr({
								kind: associationAttr.kind,
								uid: associationAttr.uid,
								path: plmData.item.getType(item)
							});
						}
						// Error if no association check applies or association check applies, but instance is unavailable
						if (checkType !== CHECK_TYPE.association || checkType === CHECK_TYPE.association && !instanceFound) {
							itemsWithErrors = itemsWithErrors ? itemsWithErrors + ',' : String(item.title || item.title_display); // jshint ignore:line
						}
					}
				}.bind(this));
				// If an activity has any Mandatory field errors, return them
				activityTitle = activity.title === 'Simulation' ? activity.title : 'Activity' + ' ' + activity.title_display; // jshint ignore:line
				itemsWithErrors && errors.push({
					title: activityTitle,
					description: validationMessage,
					isMandError: true
				});
			}.bind(this));
			// Return Simulation, all activities with their errors
			return errors;
		},
		getRawValue: function (callback) {
			// if (this.oid) {
			// 	this.$.datainterface.getData({
			// 		oid: this.oid,
			// 		kind: this.kind,
			// 		uid: this.uid,
			// 		path: this.path
			// 	}, function(data){
			// 		this.value = data.value;
			// 		callback(data);
			// 	}.bind(this));
			// } else {
			return plmData.getContent(this.kind, this.uid, this.path);
			// }
		},
		getAccess: function () {
			// For few basic attributes and expression driven paramters
			// we need the access to be readonly
			return (isReadonlyBasicAttr(this) || isExpressionDriven(this)) ? _readonlyaccess : _access;
		},
		_publishDataToInstances: function () {
			// Publish the data to instances
			Object.keys(instances).forEach(function (key) {
				var instance = instances[key],
					plmDataValue;
				plmDataValue = plmData.getContent(instance.kind, instance.uid, instance.path);
				// If the compound value is present
				if (plmDataValue && plmDataValue.value) {
					instance.value = plmDataValue.value;
				}
			}, this);
		},
		// Can be called only on plm data source singleton instance
		// Temporary: This needs to move into the separate PLM Data source component
		restore: function () {
			var source,
				io, exec, sim;

			io = Polymer.dom(this.root).querySelector('#iosummaryview');

			if (io) {
				exec = Polymer.dom(this.root).querySelector('#executionoptions');
				sim = Polymer.dom(this.root).querySelector('#simulation');

				// Restores the data from the session
				// (1. Get the data from the session storage
				// 2. Restore the data back to the webservice from which the data was first retrieved
				// 3. Add this data as the plm data source
				// 4. Publish the data back to the all plm instances)
				var keyprefix = this.tagName;
				if (this.$.dashboard.isInDashboard()) {
					keyprefix = this.$.dashboard.getWidgetId();
				}
				// A: IOSUMMARYVIEW
				source = keyprefix + '_' + plmData.SOURCE.IOSUMMARYVIEW;
				io.data = JSON.parse(sessionStorage.getItem(source));
				if (io.data) {
					plmData.addSource(source, io.data);
				}

				// B: EXECUTIONOPTIONS
				source = keyprefix + '_' + plmData.SOURCE.EXECUTIONOPTIONS;
				exec.data = JSON.parse(sessionStorage.getItem(source));
				if (exec.data) {
					plmData.addSource(source, exec.data);
				}
				// C: SIMULATION
				source = keyprefix + '_' + plmData.SOURCE.SIMULATION;
				sim.data = JSON.parse(sessionStorage.getItem(source));
				if (sim.data) {
					plmData.addSource(source, sim.data);
				}

				// Publish the data change back to the instances
				this._publishDataToInstances();
			}
		},

		updateCOSData: function(event) {
			var items = [];
			event.stopPropagation();
			this.getPLMData(function(plmdata){
				plmData.addSource(plmData.SOURCE.COSDATA, event.target.data);
				items = _updateJobStatusData(plmdata);
				this.fire(EVENT.PLM_DATA_CHANGE, {type: EVENT.UPDATE_BINDING, items: items});
			}, this);
		},

		onCOSError: function(event) {
			this.fire(EVENT.PLM_DATA_ERROR, event.detail.msg);
		},

		reloadPLMData: function (type, force) {
			var io, exec, sim, cos;
			cos = Polymer.dom(this.root).querySelector('#cosdata');
			if (type === 'COS') {
				cos.reloadData();
			} else if (cos.jobMonitor !== true || force){
				plmData.clearAllSource();
				io = Polymer.dom(this.root).querySelector('#iosummaryview');

				if (io) {
					exec = Polymer.dom(this.root).querySelector('#executionoptions');
					sim = Polymer.dom(this.root).querySelector('#simulation');
					// Call all three web services
					cos.reloadData(true);
					io.getData();
					sim.getData();
					exec.getData();
				}
			}
		},

		isActivity: function (item) {
			if (item && item.title && item.level === '0') {
				return item.title.search(/Activity/) === 0;
			}
			return false;
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase],
		_computeIf: function (kind, path, uid) {
			return !kind && !path && uid;
		},
		_computeUri: function (uid) {
			return 'simulations/' + uid + '/iosummaryview';
		},
		_computeUri2: function (uid) {
			return 'simulations/' + uid + '/executionoptions';
		},
		_computeUri3: function (uid) {
			return 'simulations/' + uid;
		}
	});
}(this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
