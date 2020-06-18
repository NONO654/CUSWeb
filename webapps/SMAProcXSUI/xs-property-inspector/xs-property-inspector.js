/*--------------------------------------------------------------------
[xs-property-inspector Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:08 GMT
Assigned to:	d6u, zb8
Description:    Responsible for displaying properties of a widget in the property panel and
                facilitating property association with process data
---------------------------------------------------------------------*/
/**
	@module SMAProcXSUI

	@example
		TODO: Provide example on how to use this element
*/
/* global DS, Polymer*/
(function (window) {
	'use strict';

	// Get the polymer from scope
	var STATE, JS_INPUT, EXT_DATA_TYPE_KEY, EXT_DATA_TYPE_KIND;
	// ENUMS

	EXT_DATA_TYPE_KEY = 'XS_External';
	EXT_DATA_TYPE_KIND = 'external';

	STATE = {
		ASSOCIATED: 'is-associated',
		DRIVENBYRULE: 'is-rule-driven',
		VALID: 'is-valid',
		EXTERNAL: 'is-external'
	};
	JS_INPUT = '.js-input';

	// Prototype
	window.Polymer({
		is: 'xs-property-inspector',
		properties: {
			DEFAULTS: {
				type: Object,
				value: function () {
					return {
						PLACEHOLDER: 'Enter value or Pick',
						PLACEHOLDER1: 'Pick a content',
						PLACEHOLDER2: 'Enter a value'
					};
				}
			},
			hasNameError: {
				type: Boolean,
				value: false,
				notify: true
			},
			hideName: {
				type: Boolean,
				value: false,
				notify: true
			},
			item: {
				type: Object,
				value: null,
				notify: true
			},
			meta: {
				type: Object,
				value: null,
				observer: 'metaChanged'
			},
			props: {
				type: Array,
				value: function () {
					return [];
				}
			},
			_isRefreshing: {
				type: Boolean,
				value: false
			},
			// Attributes
			tab: {
				value: null
			},
			// Filters
			// TODO refine.No more adapter
			disabled: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true
			}
		},
		// Give meta info to rule builder
		metaChanged: function () {
			this.$.ruleInterface.meta = this.meta;
		},

		_getPlaceHolder: function (type, associates, placeholder) {
			if (placeholder && placeholder !== '') {
				return placeholder;
			} else if (type && (type.indexOf('owned_chooser') !== -1 || type.indexOf('chooser') !== -1 || type.indexOf('array') !== -1 ||
				type.indexOf('choices') !== -1 || type.indexOf('timestamp') !== -1)) {
				return this.DEFAULTS.PLACEHOLDER1;
			} else if (associates) {
				return this.DEFAULTS.PLACEHOLDER;
			}
			return this.DEFAULTS.PLACEHOLDER2;
		},

		// Private methods
		/**
		 * Checks whether the property is bounded to a data
		 * @param   {Object}  widget   - the widget on which the binding is retrieved
		 * @param   {String}  propName - Property name for which association needs to be determined
		 * @returns {String} - Instance name if match found, else null
		 */
		_getAssociatedPLMData: function (widget, propName) {
			var regex, propValue, DATA_INSTANCE_TAG = 'xs_wg_plm_data',
				instanceId;
			propValue = widget.getAttribute(propName);
			if (propValue) {
				// Regex for matching a pattern like {{ xs_wg_plm_data_10 }},spaces ignored
				regex = new RegExp('{{\\s*' + DATA_INSTANCE_TAG.replace(/\-/g, '_') + '_\\d+\\s*}}');
				if (regex.test(propValue)) {
					instanceId = regex.exec(propValue)[0].replace('{{', '').replace('}}', '').trim();
					return instanceId;
				}
			}
			return undefined;
		},

		/**
		 * Decides whether to launch process browser or 3DSearch widget
		 * @param  {Event} event Triggered on click of Associate button in any of the properties
		 */
		onLaunchDatabrowser: function (event) {
			// Get the type that the widget can be associated to
			var id, propModel, propElem;
			propModel = event.model.prop;
			if (propModel.associates) {
				id = this._computeId2(propModel);
				propElem = this.querySelector('#' + id);
			}
			if (propModel.type && propModel.type.contains(EXT_DATA_TYPE_KEY)) {
				this.$.objectSearch.plmTypes = propModel.type;
				this.searchCallback = this._associateWithProcessData.bind(this, propModel, propElem);
				this.$.objectSearch.search();
			} else {
				this.launchProcessbrowser(propModel, propElem);
			}
		},
		/**
		 * @param  {Event} event Based on the selection on 3DSearch add it to xs-wg-plm-data
		 */
		onPropertySearch: function (event) {
			// dfg
			var data, association;
			event.preventDefault();
			event.stopPropagation();
			data = event.detail.getSelectedObjects();
			if (data && data[0]) {
				association = {
					kind: EXT_DATA_TYPE_KIND,
					uid: data[0].objectId,
					path: '',
					data: {
						objectId: data[0].objectId,
						type: data[0].objectType,
						displayName: data[0].displayName
					}
				};
				this.searchCallback(association);
			}
		},

		/**
		 * @param  {Object} propModel Selected property model
		 * @param  {HTMLElement} propElem Selected property HTML Element
		 */
		launchProcessbrowser: function (propModel, propElem) {
			// Get the type that the widget can be associated to
			var filter, associatedPLMDataId;
			// Get information about what type of data this property accepts
			filter = {
				type: propModel.type
			};
			// Index the nodes (need to do this because of conditional template binding)
			this.DOM(this).indexNodesById();
			// Get the associated plm data id
			associatedPLMDataId = this._getAssociatedPLMData(this.item.widget, propModel.name);
			this.$.processbrowser.launch(filter, // Filter criteria for data to be shown
				associatedPLMDataId, // Any existing association for this property
				this._associateWithProcessData.bind(this, propModel, propElem));
		},

		// Event handlers
		/**
		 * Event handler that launches rule builder for specific property
		 * @param {click} event Triggered on click of Add rules button in any of the properties
		 */
		onLaunchRulesBuilder: function (event) {
			var propModel = event.model.prop;
			var propElem = event.target;
			this.fire('viewrefresh', {});
			// launch rule builder
			this.$.ruleInterface.launch(
				this.item,
				propModel,
				this._refreshRulesState.bind(this, propModel, propElem));
		},

		// Callback function to be invoked once association data is available
		/**
		 * This associates a property with the process association data provided
		 * @param {Object} propModel   A widget's property object that includes all information about this property
		 * @param {Object} propElem    The HTML element representing a property
		 * @param {Object} association Object representing Process data(JSON) that needs to be associated to this property
		 */
		_associateWithProcessData: function (propModel, propElem, association) {
			this.confirmRuleRemoval(this.item, function () {
				var propertyRow, elem;
				// Indicate visually that this propperty has association defined
				propertyRow = propElem.parentElement;
				elem = this.DOM(propertyRow);
				elem.addClass(STATE.ASSOCIATED).addClass(STATE.VALID);
				if (propModel.type.contains(EXT_DATA_TYPE_KEY)) {
					elem.addClass(STATE.EXTERNAL);
				}
				elem.find(JS_INPUT).elements()[0].placeholder = this._getPlaceHolder(propModel.type, propModel.associates, propModel.placeholder);
				// Call Public API of xs-wg-item to associate this property to the association data
				this.item.associate(propModel.name, association);
			}.bind(this));
		},

		confirmRuleRemoval: function (item, callback) {
			var hasRules = false, isUsedInRules = false, msg = '';
			hasRules = item.getAllRules().length > 0;
			isUsedInRules = item._isUsedInRules();
			if (hasRules || isUsedInRules) {
				if (hasRules && !isUsedInRules) {
					msg = 'All Rules created on this component will be deleted. \n\n Do you want to continue ?';
				} else if (!hasRules && isUsedInRules) {
					msg = 'All rule conditions where this component is used will be deleted. \n\n Do you want to continue ?';
				} else {
					msg = 'All Rules created on this component will be deleted. \n\n All rule conditions where this component is used will be deleted. \n\n Do you want to continue ?';
				}
				this._callback = callback;
				this._msg = msg;
				this.$.removeRuleDialog.show();
			} else {
				callback();
			}
		},

		confirmAction: function (event) {
			this.item._clearRules();
			this.item._clearUsageInRuleConditions();
			this._callback && this._callback();
			this._callback = undefined;
			this.hideRuleConfirmDialog(event);
		},

		hideRuleConfirmDialog: function (event) {
			event.stopPropagation();
			this.$.removeRuleDialog.hide();
		},

		// Callback function to be invoked once rule builder is closed
		/**
		 * This sets a class on property showing that it is driven by rule
		 * @param {Object} propModel   A widget's property object that includes all information about this property
		 * @param {Object} propElem    The HTML element representing a property
		 * @param {Object} ruleCount number of rules driving this property
		 */
		_refreshRulesState: function (propModel, propElem, ruleCount) {
			var propertyRow;
			// Indicate visually that this property is driven by rule
			propertyRow = propElem.parentElement.parentElement;
			var elem = this.DOM(propertyRow);
			var elems = elem.find(JS_INPUT).elements();
			elems && elems.forEach(function (e) {
				/* 
				below if condition is added with respect to IR-633597-3DEXPERIENCER2019x, as css was getting leaked to component hidden by dom-if method.
				this condition restrict putting css to hidden components.
				*/
				if (e.style.display !== 'none') {
					if (ruleCount > 0) {
						e.classList.add(STATE.DRIVENBYRULE);
					} else {
						e.classList.remove(STATE.DRIVENBYRULE);
					}
				}
				e.updateStyles();
			});
		},

		refreshRuleViewInfo: function (viewData) {
			this.$.ruleInterface.updateViewInfo(viewData);
		},

		/**
		 * Refresh Property inspector based on the new item
		 * @param {Element} item - xs-wg-item instance with prperties and meta information
		 * @param {Object} viewData - complete view data
		 */
		refresh: function (item, viewData) {
			this.item = item;
			this.$.ruleInterface.viewData = viewData;

			if (!item) {
				return;
			}

			window.setTimeout(function () {
				// Remove any association class if present
				var elem = this.DOM(this).find('.' + STATE.ASSOCIATED);
				elem.removeClass(STATE.ASSOCIATED).removeClass(STATE.VALID).removeClass(STATE.EXTERNAL);

				// Remove any rule class if present
				this.DOM(this).find('.' + STATE.DRIVENBYRULE).removeClass(STATE.DRIVENBYRULE);

				// Check if associations are valid for each property
				item.meta.props.forEach(function (prop) {
					// Adding this check because time out may occur after the component is detached.This issue suffered in ODTs.
					if (!this.isAttached) {
						return;
					}

					var elem;
					// Get the property element
					elem = Polymer.dom(this.root).querySelector('div[data-prop="' + prop.name + '"]');
					// adding this check as allowing filtering of properties that should not be displayed
					if (elem) {
						// If there is an association on this property
						if (elem && item.propmeta[prop.name].isAssociated) {
							Polymer.dom(elem).classList.add(STATE.ASSOCIATED);
							if (prop.type.contains(EXT_DATA_TYPE_KEY)) {
								Polymer.dom(elem).classList.add(STATE.EXTERNAL);
							}
							// Check if the association is valid
							if (item.propmeta[prop.name].isAssociationValid) {
								Polymer.dom(elem).classList.add(STATE.VALID);
							} else {
								elem = Polymer.dom(elem).querySelector(JS_INPUT);

								if (elem) {
									// If not valid, mark the sp-input field with error
									elem.placeholder = 'Error';
								}
							}
						} else if (elem) {
							elem = Polymer.dom(elem).querySelector(JS_INPUT);

							// If not associated, assign sp-input field default placeholder
							if (elem) {
								elem.placeholder = this._getPlaceHolder(prop.type, prop.associates, prop.placeholder);
							}
						}

						if (elem && item.propmeta[prop.name].isRuleDriven) {
							Polymer.dom(elem).classList.add(STATE.DRIVENBYRULE);
						}

						if (elem.updateStyles) {
							elem.updateStyles();
						}
					}
				}, this);

				// Reflect the dropdown UI
				item.meta.props.forEach(function (prop) {
					var elem, query;

					// Get the target
					var target = this._getTarget(prop);

					// Build the query to find the display ui (dropdown)
					query = '[data-js-prop="' + prop.name + '"]';

					elem = Polymer.dom(this.root).querySelector(query);
					if (elem && prop && prop.type === 'boolean') {
						elem.selectedvalue = String(target[prop.name]).toLowerCase() === 'true';
					}
				}, this);
			}.bind(this));
		},
		showChoice: function (event) {
			var model, prop;
			// Get the model
			model = event.model;
			// Get the prop name
			prop = model.prop.name;
			// Do not show the choices if its not a forced bounded property
			if (model.item.forcedProps && model.item.forcedProps[prop]) {
				return;
			}
			this.$$('[data-js-prop="' + prop + '"]').visible = true;
		},
		// Public Methods
		// When user tries to clear the association
		onClearAssociation: function (event) {
			this.confirmRuleRemoval(this.item, function () {
				// var elem = this.DOM(event.target.parentElement);
				var elem, propName;
				propName = event.model.prop.name;
				elem = this.DOM(this).find('div[data-prop="' + propName + '"]');
				elem.removeClass(STATE.ASSOCIATED).removeClass(STATE.VALID).removeClass(STATE.EXTERNAL);

				elem.elements()[0].placeholder = this._getPlaceHolder(event.model.prop.type, event.model.prop.associates, event.model.prop.placeholder);
				this.item.disassociate(event.model.prop.name);
			}.bind(this));
		},

		showExternalProperties: function (event) {
			var objectID;
			objectID = this._getTarget(event.model.prop)[event.model.prop.name];
			this.$.objectSearch.searchCallback = function () { };
			this.$.objectSearch.search('physicalid:' + objectID);
		},

		behaviors: [DS.SMAProcSP.SPBase],
		_computeClass: function (hideName) {
			return 'properties-container ' + this.tokenList({
				hideWdgName: hideName
			});
		},
		_computeClass2: function (hasNameError) {
			return 'property-input property-row-name-input ' + this.tokenList({
				inpError: hasNameError
			});
		},
		_computeClass3: function (prop) {
			return 'property-row ' + this.tokenList({
				associable: prop.accepts !== 'text'
			});
		},
		_computeId: function (prop) {
			return 'XSProp' + prop.name;
		},
		_prepareDisplayValue: function (prop) {
			var title = '';

			var target = this._getTarget(prop);

			if (this.item && this.item.propmeta[prop.name]) {
				title = this.item.propmeta[prop.name].displayTitle;
				title = title ? '{' + title + '}' : target[prop.name];

				if (target[prop.name]) {
					this.item.propmeta[prop.name].isFromBinding = true;
				}
			}

			// If its boolean convert it into a boolean representation
			// Also it should not be associated
			if (title === undefined && prop && prop.type === 'boolean') {
				title = Boolean(title);
			}

			return title;
		},
		_reflect: function (target, prop, value) {
			if (value && target.getAttribute(prop) !== value) {
				target.setAttribute(prop, value);
			} else if (value === '' && target.getAttribute(prop) !== '' && target.getAttribute(prop) !== null) {
				target.setAttribute(prop, '');
			}
			else {
				target.removeAttribute(prop);
			}
		},
		_getTarget: function (prop) {
			// Check where the value needs to be updated. Widget or its wrapper
			return !prop._targetWrapper ? this.item.widget : this.item;
		},
		_onChoiceChange: function (event) {
			var prop = event.model.prop,
				value = event.detail.selectedItem.value,
				query;

			if (prop) {
				// Check where the value needs to be updated. Widget or its wrapper
				var target = this._getTarget(prop);

				// If this value was set explicitly (reflect)
				if (target[prop.name] !== value) {
					// Reflect the choice. If its a boolean attribute (true/false) then reflect
					// only if it is true
					// if (typeof value === 'boolean') {
					this._reflect(target, prop.name, value);
					// }
				}

				// Update the target value
				target[prop.name] = value;


				this.item.notifyPath('widget.' + prop.name, value);

				// Build the query to find the display ui (sp-input)
				query = '[data-js-display="' + prop.name + '"]';

				// Construct the display value
				value = this._prepareDisplayValue(prop);

				// Reflect the input UI
				Polymer.dom(this.root).querySelector(query).value = value;
			}
		},
		clear: function () {
			this.item = null;
		},
		_onPropValueChange: function (event) {
			var propName,
				propValue;

			propName = event.model.prop.name;
			propValue = event.target.value;

			var target = this._getTarget(event.model.prop);

			if (target && propValue !== undefined &&
				propValue.toString().search(/^\{/) !== 0) {
				// If this value was set explicitly (reflect)
				if (!this.item.propmeta[propName].isFromBinding) {
					this._reflect(target, propName, propValue);
				}

				target[propName] = propValue;
				this.item.notifyPath('widget.' + propName, propValue);
			}
			// Clear the flag if any
			this.item.propmeta[propName] && (this.item.propmeta[propName].isFromBinding = false);
		},

		_onKeyPress: function (event) {
			var value = event.target.value;
			var propName = event.model.prop.name;
			var target = this._getTarget(event.model.prop);

			// if returnDatatype function is implemented then only proceed further
			if (target.returnDatatype) {
				var typereturnDatatype = target.returnDatatype(propName) || event.model.prop.type;
				var containsReal = Boolean((typereturnDatatype instanceof Array) && typereturnDatatype.includes('real'));
				if (containsReal || typereturnDatatype === 'Number') {
					var k = event.key;
					var _per = value.indexOf('.') > 0;
					if (_per && k !== 'Backspace' && k !== '+' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					} else if (k !== '.' && k !== 'Backspace' && k !== '+' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					}
				} else if (typereturnDatatype === 'NumberArray') {
					value = event.target.value.split(',').slice(-1)[0];
					var k = event.key;
					var _per = value.indexOf('.') > 0;
					if (_per && k !== 'Backspace' && k !== '+' && k !== ',' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					} else if (k !== '.' && k !== 'Backspace' && k !== ',' && k !== '+' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					}
				}
			}
		},

		/**
			@private
			@param {event} event - click event on value property input field and its overlay
		*/
		_onClick: function (event) {
			if (event.model.prop.name === 'value') {
				this.onLaunchDatabrowser(event);
			}
		},

		/**
		 * @private
		 * @param  {Object} prop property
		 * @param  {Object} item item which is loaded
		 * @param  {Boolean} disabled is compnent disabled
		 * @param  {boolean} checkForAssociation is checking for assocation to be done
		 * @desc checks if the property is to be marked as readonly or not based on prop type,any forced props
		 * @returns {Boolean} is component forced
		 */
		_isForcedProp: function (prop, item, disabled, checkForAssociation) {
			var isForced = disabled || false;

			if (!isForced && (this.item && item.forcedProps)) {
				isForced = item.forcedProps[prop.name];
			}
			if (!isForced && checkForAssociation) {
				// value property can only take value from association
				isForced = String(prop.associates).toLowerCase() === 'true' || String(prop.editable).toLowerCase() === 'false';
			}
			return isForced;
		},

		_isForcedRuleProp: function (prop, item, disabled) {
			var isForced = false;

			if (this.item && item.forcedProps) {
				isForced = item.forcedProps[prop.name];
			}

			if (isForced) {
				if (this.item.propmeta[prop.name].isRuleDriven && disabled) {
					isForced = false;
				}
			}

			return isForced;
		},

		/**
		 * filter the list of properties to be viewed in property inspector
		 * @param  {Object} item xs-wg-item instance
		 * @returns {Boolean} if its a nolist
		 */
		computeItemProps: function (item) {
			if (item && typeof item === 'object') {
				var props = [];
				if (item && item.meta) {
					props = item.meta.props.filter(function (property) {
						if (property.hasOwnProperty('nolist') && property.nolist) {
							return false;
						}
						return true;
					});
				}
				// var props = item.meta.props;
				return props;
			}
			return undefined;
		},
		_computeId2: function (prop) {
			return 'XSBind' + prop.name;
		},
		_computePropname: function (prop) {
			return prop.name;
		},
		_computeAssocClass: function (prop) {
			return prop.associates ? 'association-true rules-false' : 'association-false rules-true';
		},
		_computeClass4: function (prop) {
			return prop.associates ? 'property-input js-input value-prop' : 'property-input js-input';
		},
		refreshProcessBrowser: function () {
			this.clear();
			this.$.processbrowser.refreshProcessBrowser();
		}
	});
}(this));
