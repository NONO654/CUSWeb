//TODO add example
/* global Polymer*/
(function (window) {
	'use strict';
	var xsRuleBuilder, operatorList, supportedWidgets;
	/**
     * @todo for string operators include regex or contains some string
     */
	operatorList = [{
		value: 0,
		title: 'equals',
		label: '=='
	}, {
		value: 1,
		title: 'not equals',
		label: '!='
	}, {
		value: 2,
		title: 'greater than',
		label: '>'
	}, {
		value: 3,
		title: 'less than',
		label: '<'
	}, {
		value: 4,
		title: 'greater than or equals',
		label: '>='
	}, {
		value: 5,
		title: 'less than or equals',
		label: '<='
	}];
	//supportedWidgets = ['xs-wg-checkbox', 'xs-wg-input-text', 'xs-wg-slider', 'xs-wg-dropdown', 'xs-wg-timestamp', 'xs-wg-run'];
	//Prototype
	xsRuleBuilder = {
		is: 'xs-rule-builder',
		properties: {
			//Public properties
			//rule Node giving rule info
			ruleNode: {
				type: Object
				// value: {}
			},
			//complete view Data
			viewInfo: {
				type: Object
				// value: {}
			},
			//meta info
			meta: {
				type: Object,
				observer: 'computeSupportedWidgets'
			},
			_cname: {
				type: String,
				computed: 'getCompLabel(ruleNode, viewInfo)'
			},
			_rulePropDataType: {
				type: String,
				computed: '_getRulePropDataType(ruleNode)'
			},
			toggle: {
				type: Boolean,
				value: false
			},
			conditions: {
				type: Array,
				notify: true,
				computed: 'getConditions(meta,viewInfo,ruleNode,toggle)'
			},
			/**
             * list of items that are eligible for building the conditions
             * the item should be supported widget type and is not the widget on which the rule is being build
             */
			eligibleItems: {
				type: Array,
				computed: 'getAllItems(meta,viewInfo)'
			},
			/**
             * locks editing of any condition
             */
			disabled: {
				type: Boolean,
				value: false
			},
			condToggle: {
				type: Boolean,
				value: false
			}
		},
		computeSupportedWidgets: function (meta) {
			supportedWidgets = Object.keys(meta).filter(function (widgetName) {
				if ((meta[widgetName].hasOwnProperty('norules') && meta[widgetName].norules) 
					|| (localStorage.getItem('XS_RUN') !== 'true' && widgetName === 'xs-wg-run')){
					return false;
				}
				return true;
			});
		},
		//Get name of component
		getCompName: function (ruleNode) {
			if (ruleNode && ruleNode.tagName && ruleNode.tagName.toLowerCase() === 'xs-wg-rule') {
				return Polymer.dom(ruleNode).parentNode.name;
			}
		},
		//Get name of component
		getCompLabel: function (ruleNode) {
			var parentNode, name = '',
				label;
			if (ruleNode && ruleNode.tagName && ruleNode.tagName.toLowerCase() === 'xs-wg-rule') {
				parentNode = Polymer.dom(ruleNode).parentNode;
				if (parentNode) {
					name = parentNode.name;
					if (parentNode.tagName === 'XS-WG-LAYOUT' || parentNode.tagName === 'XS-WG-SECTION') {
						label = parentNode.label;
					} else {
						label = parentNode.widget ? parentNode.widget.label : undefined;
					}
				}

			}
			if (label && label.length > 30) {
				label = label.substring(0, 30).trim() + '...';
			}
			return label ? label + ' (' + name + ')' : name;
		},

		_getRulePropDataType: function(ruleNode) {
			var parentNode,
				type = '';
			if (ruleNode && ruleNode.tagName && ruleNode.tagName.toLowerCase() === 'xs-wg-rule') {
				parentNode = Polymer.dom(ruleNode).parentNode;
				if (parentNode) {
					if (parentNode.tagName === 'XS-WG-LAYOUT' || parentNode.tagName === 'XS-WG-SECTION') {
						type = parentNode.returnDatatype ? parentNode.returnDatatype(ruleNode.prop) : '';
					} else if (parentNode.widget && parentNode.widget.returnDatatype){
						type = parentNode.widget.returnDatatype(ruleNode.prop);
					}
				}

			}
			return type;
		},

		/**
         * @param  {String/Number} value true value of select tag
         * @param  {String/Number} item test value
         * returns boolean on comparing option value and true value of select tag to set the attribute selected
         */
		getSelectedOption: function (value, item) {
			return (String(value) === String(item));
		},
		/**
         * @param  {Object} viewInfo
         * @param  {String} itemname
         * returns array of applicable operators based on select component in the condition
         */
		getConditionOperators: function (viewInfo, itemname) {
			if (viewInfo && itemname) {
				var datatype = this.getDataType(itemname);
				return operatorList.filter(function (checkType) {
					if (datatype === 'real' || datatype === 'integer' || datatype === 'Date') {
						return true;
					} else if (datatype === 'boolean') {
						//for boolean only === condition matters as, value can equal to true or false.
						return checkType.value === 0;
					} else {
						// for string supporting only equals and not equals
						if (checkType.value === 0 || checkType.value === 1) {
							return true;
						}
					}
				});
			}
		},
		/**
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {String} propname
         * Computes placeholder for the rule true value input text box
         */
		_getPlaceHolder: function (meta, viewInfo, propname) {
			var prop = this.getRulePropInfo(meta, viewInfo, propname);
			if (prop && prop.placeholder) {
				return prop.placeholder;
			} else {
				return 'Enter new value';
			}
		},
		/**
		 * @param  {Object} meta meta info
		 * @param  {Object} viewInfo view info
		 * @param  {String} propname propname
		 * @desc get choices if the rule is applied to property supporting drop-down (readonly, mandatory, etc)
		 * @returns {Object} false if no choices available and proplist of properties has choices
		 */
		getChoices: function (meta, viewInfo, propname) {
			var prop = this.getPropObject(meta, viewInfo, propname);
			if (prop.choices && prop.choices.length > 0) {
				return this.getSelectOptionsFromArray(prop.choices);
			} else {
				return false;
			}
		},

		getDataChoices: function(meta, viewInfo) {
			var options = [], itemInfo = this.getItemInfo(viewInfo, meta);
			itemInfo.choices && itemInfo.choices.forEach(function(choice){
				options.push({
					value: choice.choices,
					label: choice.choices_display  // jshint ignore:line
				});
			});
			return options;
		},

		/**
		 * @param  {Object} meta meta info
		 * @param  {Object} viewInfo view info
		 * @param  {String} propname propname
		 * @desc get choices if the rule is applied to property supporting drop-down (readonly, mandatory, etc)
		 * @returns {Object} if its a multi choice prop then true else false
		 */
		isMultiChoiceProp: function (meta, viewInfo, propname) {
			var prop = this.getPropObject(meta, viewInfo, propname);
			return (prop.type === 'multichoice');
		},

		/**
		 * @param  {Object} meta meta info
		 * @param  {Object} viewInfo view info
		 * @param  {String} propname propname
		 * @desc get choices if the rule is applied to property supporting drop-down (readonly, mandatory, etc)
		 * @returns {Object} if its a multi choice prop then true else false
		 */
		isStringProp: function (meta, viewInfo, propname) {
			var prop = this.getPropObject(meta, viewInfo, propname);
			return !((prop.choices && prop.choices.length > 0) || prop.type === 'multichoice');
		},

		getItemInfo: function (viewInfo, meta) {
			var cname, itemInfo;
			cname = this.getCompName(this.ruleNode);
			if (viewInfo === undefined || meta === undefined) {
				return [];
			}

			itemInfo = viewInfo.filter(function (info) {
				if (cname && info.cname === cname) {
					return true;
				}
				return false;
			})[0];
			return itemInfo;
		},

		getPropObject: function(meta, viewInfo, propname) {
		  var props, prop, itemInfo = this.getItemInfo(viewInfo, meta);
			if (itemInfo === undefined) {
				return [];
			}
			props = this.meta[itemInfo.widgetname.toLowerCase()].props;
			prop = props.filter(function (p) {
				if (p.name === propname) {
					return true;
				}
				return false;
			})[0];
			return prop;
		},

		getSelectOptionsFromArray: function (value) {
			var selectOptions = [];
			value && value.forEach(function (item) {
				selectOptions.push({
					value: item,
					label: item
				});
			});
			return selectOptions;
		},
		getRulePropInfo: function (meta, viewInfo, propname) {
			var cname = this.getCompName(this.ruleNode);
			if (viewInfo === undefined || meta === undefined) {
				return [];
			}
			var itemInfo = viewInfo.filter(function (info) {
				if (cname && info.cname === cname) {
					return true;
				}
			})[0];
			if (itemInfo === undefined) {
				return [];
			}
			var props = this.meta[itemInfo.widgetname.toLowerCase()].props;
			var prop = props.filter(function (p) {
				if (p.name === propname) {
					return true;
				}
			})[0];
			return prop;
		},
		/**
         * provides the choices if available for the condition value
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {String} propname
         * @param  {String} cname
         */
		getChoices2: function (meta, viewInfo, propname, cname) {
			var choices;
			if (viewInfo && meta) {
				var itemInfo = viewInfo.filter(function (info) {
					if (info.cname === cname) {
						return true;
					}
				})[0];
				if (itemInfo) {
					//get the list of supported property list only.
					var props = this.getPropertyList(meta, viewInfo, cname);
					var prop = props.filter(function (p) {
						if (p.name === propname) {
							return true;
						}
					})[0];
					// Support choices from drop-down and boolean type widgets
					if (prop && (prop.choices || prop.type === 'choices')) {
						if (prop.choices) {
							choices = prop.choices.map(function (choice) {
								return {
									'choices': choice,
									'choices_display': choice
								};
							});
						} else {
							choices = itemInfo.choices;
						}
					}
				}
			}
			return choices;
		},
		/**
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {String} propname
         * @param  {String} cname
         * @desc returns the array of choices for the selected property of the selected target component
         */
		getChoicesUI: function (meta, viewInfo, propname, cname) {
			var choicesUI;
			var choices = this.getChoices2(meta, viewInfo, propname, cname);
			if (choices && choices.forEach && choices.length > 1) {
				if (choicesUI === undefined) {
					choicesUI = [];
				}
				// Adding a blank value for rule condition selection
				choicesUI.push({
					value: '',
					label: '',
					title: 'No value selected'
				});
				choices.forEach(function (ch) {
					choicesUI.push({
						value: ch.choices,
						label: ch.choices_display // jshint ignore:line
					});
				});
			}
			return choicesUI;
		},
		/**
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {Object} ruleNode
         * @param  {boolean} toggle optional
         * @desc computes and returns all the conditions (rule-trigger instances for a particular rule-node) whenever there is change in arguments
         */
		getConditions: function (meta, viewInfo, ruleNode) {
			var allConditions = ruleNode.getAllConditions();
			//toggle the conditions after the this.conditions is updated
			this.async(function () {
				this.condToggle = !this.condToggle;
			}.bind(this));
			return allConditions;
		},
		/**
         * @param  {Array} conditions
         * @desc returns true if no conditions are found which is used to display no conditions message
         */
		checkConditions: function (conditions) {
			return (conditions.length <= 0);
		},
		/**
         * add new condition to the current rule
         */
		addCondition: function () {
			var newConditionDetails = {};
			//In case some conditions are present
			if (this.$.conditions.items && this.$.conditions.items.length > 0) {
				//fetching the last condition details
				var conditionItem = this.$.conditions.items[this.$.conditions.items.length - 1];
				newConditionDetails['itemname'] = conditionItem.itemname;
				newConditionDetails['prop'] = conditionItem.prop;
				newConditionDetails['operator'] = conditionItem.operator;
				newConditionDetails['value'] = String(conditionItem.value);
			} else {
				var firstItem = this.eligibleItems[0];
				if (firstItem === undefined) {
					alert('No valid components are available for creating rules.');
					return;
				}
				var itemName = firstItem.value;
				var prop = this.getPropertyList(this.meta, this.viewInfo, itemName);
				//only valid properties shall be present
				var propname = prop[0].name;
				var choices = this.getChoices2(this.meta, this.viewInfo, propname,
					itemName);
				var choiceValue = '';
				if (choices) {
					choiceValue = typeof choices[0] === 'object' ? choices[0].choices : choices[0];
				}
				newConditionDetails['itemname'] = itemName;
				newConditionDetails['prop'] = propname;
				newConditionDetails['operator'] = '0';
				newConditionDetails['value'] = String(choiceValue);
			}
			//creating new condition
			this.ruleNode.addNewCondition(newConditionDetails.itemname,
				newConditionDetails.prop,
				newConditionDetails.operator,
				newConditionDetails.value);
			// this.toggle = !this.toggle;
			this.condToggle = !this.condToggle;
			//switching the toggle for bindings to work properly
			this.async(function () {
				this.toggle = !this.toggle;
				this.condToggle = !this.condToggle;
			}.bind(this), 100);			
		},
		/**
         * returns the list of eligible items using which can be used to build conditions
         * @param  {Object} meta
         * @param  {Object} viewInfo
         */
		getAllItems: function (meta, viewInfo) {
			var cname = this.getCompName(this.ruleNode);
			var eligibleItems = [];
			this.computeSupportedWidgets(meta);
			if (meta && viewInfo && supportedWidgets) {
				viewInfo.forEach(function (xsWgItem) {
					if (cname && xsWgItem.cname !== cname && supportedWidgets.indexOf(xsWgItem.widgetname.toLowerCase()) !== -1) {
						eligibleItems.push({
							value: xsWgItem.cname,
							label: xsWgItem.displayname
						});
					}
				});
			}
			/**
             *@todo add the property if the eligible items has prop as choices or not
             */
			return eligibleItems;
		},
		/**
         * @desc listener for change in condition's target
         * @function setCorrectProp
         * @param  {Object} event
         */
		setCorrectProp: function (event) {
			var conditionInstance = event.model[this.$.conditions.as];
			if (conditionInstance) {
				//TODO for this condition is its prop valid if yes then ok else set correct prop
				var correctPropList = this.getPropertyList(this.meta, this.viewInfo,
					conditionInstance.itemname);

				var propFound = correctPropList.filter(function (condt) {
					return condt.name === conditionInstance.prop;
				});
				//if the condition is present, then set the property from the condition
				if (propFound !== undefined && propFound.length === 1) {
					//In case prop is not changed but value choices might have changed
					// this.setCorrectValue(event);
				} else {
					//set first prop as property
					conditionInstance.prop = correctPropList[0].name;
				}
				this.toggle = !this.toggle;
				//In case prop is not changed but value choices might have changed
				this.async(function () {
					this.setCorrectValue(event);
					this.toggle = !this.toggle;
					this.condToggle = !this.condToggle;
				}.bind(this));
			}
		},
		/**
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {String} itemname
         * @desc returns the array of properties which are enabled for creating rule conditions
         */
		getPropertyList: function (meta, viewInfo, itemname) {
			var properties;
			if (viewInfo === undefined || meta === undefined) {
				return [];
			}
			var itemInfo = viewInfo.filter(function (info) {
				return info.cname === itemname;
			})[0];
			if (itemInfo === undefined) {
				return [];
			}
			properties = this.meta[itemInfo.widgetname.toLowerCase()].props;
			//return only those properties which are enabled to be used for conditions
			return properties.filter(function (property) {
				return (property.hasOwnProperty('ruleCondition') && property.ruleCondition);
			});
		},

		/**
         * @param  {Object} meta
         * @param  {Object} viewInfo
         * @param  {String} itemname
         * @desc retuns the array of choices for the condition's value field in format acceptable by xs-select
         */
		getPropertyListUI: function (meta, viewInfo, itemname) {
			var properties, propertiesUI;
			properties = this.getPropertyList(meta, viewInfo, itemname);
			if (properties && properties.forEach) {
				properties.forEach(function (prop) {
					if (propertiesUI === undefined) {
						propertiesUI = [];
					}
					propertiesUI.push({
						value: prop.name,
						label: prop.caption
					});
				});
			}
			return propertiesUI;
		},
		/**
         * @param  {Object} event
         * @desc listerner for the value change of condition's property
         */
		setCorrectValue: function (event) {
			var value = '';
			var conditionInstance = event.model[this.$.conditions.as];
			if (conditionInstance) {
				//TODO for this condition is its prop valid if yes then ok else set correct prop
				var correctChoicesIFany = this.getChoices2(this.meta, this.viewInfo,
					conditionInstance.prop, conditionInstance.itemname);
				if (correctChoicesIFany) {
					if (typeof correctChoicesIFany[0] === 'object') {
						value = String(correctChoicesIFany[0].choices);
					} else {
						value = String(correctChoicesIFany[0]);
					}
				}
				conditionInstance.value = value;
				//get the control of value field and set the value on UI elements
				var parent = event.target.parentElement;
				parent = parent.classList.contains('condition') ? parent : parent.parentElement;
				var valueDiv = parent.children[3];
				var valueType = valueDiv.dataset.valuetype;
				if (valueDiv && valueType) {
					for (var i = 0; i < valueDiv.children.length; i++) {
						var elem = valueDiv.children[i];
						if (elem.className.contains(valueType)) {
							elem.value = value;
						}
					}
				}
			}
			this.condToggle = !this.condToggle;
		},
		/**
         * @function
         * @desc removes all the conditions of the current rule and the rule itself
         */
		removeRule: function () {
			this.fire('refreshrepeat', this.ruleNode);
			this.ruleNode.remove();
		},
		/**
         * @param  {Object} event when user clicks on removing condition
         * @desc removes the current condition of the rule
         */
		removeCondition: function (event) {
			var conditionInstance = event.model[this.$.conditions.as];

			this.async(function () {
				this.toggle = !this.toggle;
			}.bind(this), 100);

			conditionInstance.remove();
		},
		/**
         * @param  {Number} sequence
         * @desc computes the sequence no for the rule
         */
		getSequenceNumber: function (sequence) {
			return sequence + 1;
		},
		/**
         * @param  {String} cmpName name of the component
         * @desc returns the datatype of the component
         */
		getDataType: function (cmpName) {
			if (cmpName && cmpName !== '') {
				return this.viewInfo.filter(function (item) {
					if (item.cname === cmpName) {
						return item;
					}
				})[0].datatype;
			}
		},
		/**
         * @param  {String} cmpName
         * @desc returns if the component used for condition is of date type or not
         */
		dateType: function (cmpName) {
			var datatype = this.getDataType(cmpName);
			return datatype === 'Date';
		},
		/**
         * @param  {boolean} disabled
         * @desc computes the class for the delete button of the condition for showing/hiding
         */
		computeClass: function (disabled) {
			return disabled ? 'remove-condition-disabled' : 'remove-condition fonticon fonticon-trash';
		},
		/**
		 * @param  {Object} meta
		 * @param  {Object} viewInfo
		 * @param  {String} prop
		 * @param  {String} itemname
		 * @param  {boolean} cond
		 * @desc sets the data-valuetype attribute for the condition-value div
		 */
		getValueType: function (meta, viewInfo, prop, itemname) {
			var valueType = this.getChoices2(meta, viewInfo, prop, itemname);
			if (valueType) {
				return 'choices';
			}
			return this.dateType(itemname) ? 'calendar' : 'input';
		},

		getConditionValue: function (value) {
			return value;
		},

		_onKeyPress: function(event) {
			var value = event.target.value;
			// if returnDatatype function is implemented then only proceed further
			if (this._rulePropDataType !== '' && this._rulePropDataType !== undefined) {
				var containsReal = Boolean((this._rulePropDataType instanceof Array) && this._rulePropDataType.includes('real'));
				if (containsReal || this._rulePropDataType === 'Number') {
					var k = event.key;
					var _per = value.indexOf('.') > 0;
					if (_per && k !== 'Backspace' && k !== '+' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					} else if (k !== '.' && k !== 'Backspace' && k !== '+' && k !== '-' && isNaN(k)) {
						event.preventDefault();
					}
				} else if (this._rulePropDataType === 'NumberArray') {
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
		}
	};

	window.Polymer(xsRuleBuilder);

}(this));
