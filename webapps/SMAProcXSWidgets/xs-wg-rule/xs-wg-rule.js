/*--------------------------------------------------------------------
[xs-wg-rule JS Document]
Description:	The wrapper component for rules
---------------------------------------------------------------------*/
/**
	@module SMAProcXSWidgets
	@submodule xs-wg-rule
	@class xs-wg-rule
	@description The component listens to the state change of triggers
  if all the conditions are satisfied, it applies rules. Else it removes the rules.
  The component also creates/deletes rule-trigger component based on rule-builder.
*/
/* global SPBase, Polymer*/
(function () {
	'use strict';

    // global constants for all the rules in current page
	var CONDITIONCHANGE, rulesStack, _meta, addRuleToStack, removeRuleFromStack, getValidRuleValue, isPropertyType;

	CONDITIONCHANGE = 'state-changed';
    // rulesStack contains the rule that is applied on the cpm-property
    // if a new rule condition is getting satisified, it will check if the new rule has higher priority or not  rulesStack = [{cmp1-lable : [rule1-priority] }]
	rulesStack = {};

    // add the rule on the stack and returns the valid value for prop
	addRuleToStack = function () {
		var ruleKey, ruleObj, currentRuleStack, booleanProps;
		booleanProps = [];
		ruleKey = this._target.id + this.prop;
        // extracting if the rules of the same target+prop is applied or not.
		currentRuleStack = rulesStack[ruleKey] || [];
        // while apply the first rule, fetch the original value and set it to the rule object
        // once the original is set, don't change it
		if (currentRuleStack.length === 0 && !this.original) {
			booleanProps = this.meta.props.filter(function (prop) {
				return prop.type.toLowerCase() === 'boolean';
			});
			if (isPropertyType(this.meta, 'boolean', this.prop)) {
				this.original = this.getCorrectTarget(this.meta, this.prop, this._target)[this.prop];
			} else {
                // for non boolean props, the default value is undefined as that cannot be applied to the target prop e.g. label
				this.original = this.getCorrectTarget(this.meta, this.prop, this._target)[this.prop] || '';
			}
		} else if (currentRuleStack.length > 0) {
            // take the original value from the previous rule stored in the stack
			this.original = currentRuleStack[0].original;
		}
        // current rule object
		ruleObj = this;
		currentRuleStack.push(ruleObj);
        // sort the currentRuleStack based on priority
		if (currentRuleStack.length > 1) {
			currentRuleStack.sort(function (rule1, rule2) { return rule2.priority - rule1.priority; });
		}
		rulesStack[ruleKey] = currentRuleStack;
		return getValidRuleValue.call(this);
	};
	isPropertyType = function (meta, stype, cprop) {
		var allValidProps, propReturn;
		allValidProps = meta.props.filter(function (prop) {
			return prop.type.toLowerCase() === stype;
		});
		propReturn = [];
		for (var i = 0; i < allValidProps.length; i++) {
			var check = allValidProps[i].name.toLowerCase() === String(cprop).toLowerCase();
			if (check) {
				propReturn.push(allValidProps[i]);
			}
		}
		propReturn = propReturn.length > 0 ? propReturn : false;
		return propReturn;
	};
    // removes the rule from the stack and returns the valid value for prop
	removeRuleFromStack = function () {
		var ruleKey, temp, ruleObj, currentRuleStack;
		ruleKey = this._target.id + this.prop;
		ruleObj = this;
        // extracting the rules applied for current target + prop
		currentRuleStack = rulesStack[ruleKey];
		rulesStack[ruleKey] = [];
		temp = [];
		temp = currentRuleStack.filter(function (rule) {
			return rule.priority !== ruleObj.priority;
		});
        // update the rulesStack for current target and prop
		rulesStack[ruleKey] = temp;
		return getValidRuleValue.call(this);
	};

    /**
     * returns the validValue for the target element's prop
     * if no rules are valid, it returns original, else returns the value of high priority rule
     * @private
     */
	getValidRuleValue = function () {
		var ruleKey;
		ruleKey = this._target.id + this.prop;
		return rulesStack[ruleKey].length > 0 ? rulesStack[ruleKey][0].value : this.original;
	};

	Polymer({ // jshint ignore:line
		is: 'xs-wg-rule',
		properties: {
			_target: {
				type: Object,
				notify: false
			},
			meta: {
				type: Object,
				notify: false
			},
			prop: {
				type: String,
				reflectToAttribute: true
			},
            // true value of the property when all conditions are satisfied
			value: {
				type: String,
				reflectToAttribute: true,
				notify: true
			},
			original: {
                // keep this value as object so no type casting is required
				type: Object
                // computed: '_computeOriginal(meta, prop, _target, toogle)'
			},
			priority: {
				type: Number,
				reflectToAttribute: true,
				notify: true
                // value: 0
			},
			behaviors: [SPBase],
            // extra property to keep info that rules are applied or not
			isRuleApplied: {
				type: Boolean,
				value: false
			}
		},

		listeners: {
			'log-rule-trigger': 'logRuleTrigger'
		},
        // Life cycle methods
		attached: function () {
            // Listen to condition change event
			this.latestConditionState = true;
			this.listen(this, CONDITIONCHANGE, '_onConditionStatusChanged');
		},
		detached: function () {
            // stop listening to everyting
			this.unlisten(this, CONDITIONCHANGE, '_onConditionStatusChanged');
		},

        /**
         * Any time any condition for this rule is changed then evaluate whether to apply rule or unapply them
         * @private
         * @param  {} event
         */
		_onConditionStatusChanged: function (event) {
            // Stop its propogation
			event.stopPropagation();
            // flag to be save the original value before the rule is applied
			this.haveOrg = this.haveOrg;
            // get the target condition who thowed this event
			var target = Polymer.dom(event).rootTarget;
            // In case some condition has failed and rule is applied then unapply it
			this.latestConditionState = target.state;
			if (!target.state && this.isRuleApplied) {
				this._unApplyRule();
			}
            // In case rule is not applied and some condition is satisfied
            // then apply the rules if all conditions are statisfied
			else if (target.state && !this.isRuleApplied) {
				if (this._areAllConditionsSatisfied()) {
					this._applyRule();
				}
			}
            // there can be other two combinations of target's state and isRuleApplied
            // Skip them as none of them makes sense
		},

        // Private functions
        /**
         * @private
         * loops through all conditions and returns true if all conditions are valid
         */
		_areAllConditionsSatisfied: function () {
			var conditions, falseConditions;
            // get all conditions reference
			conditions = this.getAllConditions();
            // search if any condition is false
			falseConditions = conditions.some(function (condition) {
				return !condition.state;
			});
            // if all conditions are statisfied
			return !falseConditions;
		},

        /**
         * Apply this rule and add that to the rulestack
         * @private
         */
		_applyRule: function () {
            // Fetch input type from published properties and then deserialize the value to it.
            // When rule is to be executed for the first time, this.meta is not available so it fails
			// to prevent that doing this operation async
			if (this.meta && this.meta.props) {
				this.async(function () {
					var type, targetC, validValue;
					if (this.latestConditionState) {
						this.isRuleApplied = true;
						type = this.meta.props.filter(function (property) {
							return property.name === this.prop;
						}.bind(this))[0].type;
						targetC = this.getCorrectTarget(this.meta, this.prop, this._target);
						validValue = addRuleToStack.call(this);
						if (type === 'boolean') {
							validValue = validValue.toLowerCase() === 'true';
						} else {
							validValue = Polymer.Base.deserialize(validValue, type);
						}
						targetC[this.prop] = validValue;
					}
				}.bind(this));
			}
		},
        /**
         * Unapply the rule
         * @private
         */
		_unApplyRule: function () {
			this.isRuleApplied = false;
			var targetC, propValue, type;
			targetC = this.getCorrectTarget(this.meta, this.prop, this._target);
			propValue = removeRuleFromStack.call(this);
			type = this.meta.props.filter(function (property) {
				return property.name === this.prop;
			}.bind(this))[0].type;
			if(type === 'boolean'){
				targetC[this.prop] = String(propValue).toLowerCase() === 'true';
			}else{
				targetC[this.prop] = propValue;
			}
		},
        // Public functions
        /**
         * xs-wg-item will use this function to set the target(widget- UI element)
         * @public
         * @param  {} target
         */
		setTarget: function (target) {
            // _target is a private property
			this._target = target;
			if (_meta && _meta[this._target.tagName.toLowerCase()] !== undefined) {
				this.meta = _meta[this._target.tagName.toLowerCase()];
			}
		},
        /**
         *
         * @public
         * @param  {Object} meta
		 * @desc set meta info of parent element
         */
		setMetaInfo: function (meta) {
			_meta = _meta || meta;
			if (this._target && _meta) {
				this.meta = _meta[this._target.tagName.toLowerCase()];
			}
		},
		getCorrectTarget: function (meta, prop, target) {
			if (meta && prop) {
				var targetWrapper = meta.props.filter(function (property) {
					return property.name === prop;
				})[0]['_targetWrapper'];
				if (targetWrapper) {
					target = Polymer.dom(target).parentNode;
				}
			}
			return target;
		},
        /**
         * creates new rule-trigger and adds to itself and fires trgUpdateItem event
         * @public
         * @param  {String} itemName component name which is to be used to create the condition
         * @param  {String} property item Property
         * @param  {Number} operator condition number
         * @param  {String} value conditionValue
         */
		addNewCondition: function (itemName, property, operator, value) {
			var condition = document.createElement('xs-wg-rule-trigger');
			condition.value = value;
			condition.operator = operator;
			var triggerDataAttribute = 'trg' + Date.now();
            // set data atribute on condition
			condition.dataset[triggerDataAttribute] = property;
			var trgdetails = {
				triggerName: triggerDataAttribute,
				prop: property,
				newItem: itemName
			};
			this.fire('trgUpdateItem', trgdetails);
			Polymer.dom(this).appendChild(condition);
			return condition;
		},
        /**
         * Remove this rule
         * @public
         */
		remove: function () {
            // First remove all conditions then remove rule
            // get all conditions reference
			var conditions = this.getAllConditions();
            // if state for any condition is false then return false
			conditions.forEach(function (condition) {
				condition.remove();
			}, this);
            // remove this rule from dom
			Polymer.dom(Polymer.dom(this).parentNode).removeChild(this);
		},
        /**
         * get array of all conditions
         * @public
         */
		getAllConditions: function () {
			var conditionNode = this.querySelectorAll('xs-wg-rule-trigger');
			var conArray = [];
			for (var i = 0; i < conditionNode.length; i += 1) {
				conditionNode[i].initMetaData();
				conArray.push(conditionNode[i]);
			}
			return conArray;
            // this return array of node which dom repeat is not able to process
            // return Array.from(this.querySelectorAll('xs-wg-rule-trigger'));
		},

		logRuleTrigger: function (event) {
			var triggers, _item, operator, state, prepend = '', operatorList = [{
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
			this.debounce('log-trigger-info', function () {
				if (this._target && this._target.tagName === 'XS-WG-ITEM' || this._target.tagName === 'XS-WG-LAYOUT' || this._target.tagName === 'XS-WG-SECTION') {
					_item = this._target;
				} else {
					_item = Polymer.dom(this._target).parentNode;
				}

				console.group('Component(' + (this.priority + 1) + ') -> ' + _item.name + ' : Property: ' + this.prop + ' : Rule Value: ' + this.value); // jshint ignore:line
				console.log('Rule Applied ' + this.isRuleApplied); // jshint ignore:line
				triggers = this.querySelectorAll('xs-wg-rule-trigger');
				for (var i = 0; i < triggers.length; i += 1) {
					triggers[i].initMetaData();
					state = triggers[i].state ? 'Passed' : 'Failed';
					operatorList.forEach(function (op) { // jshint ignore:line
						if (op.value === triggers[i].operator) {
							operator = op.label;
						}
					}); // jshint ignore:line
					if (triggers[i].isEqualNode(event.detail.trigger)) {
						prepend = 'Rule Check Triggered by : ';
					} else {
						prepend = '';
					}
					// Set state to Pass and fail based on true - false
					// Set item name with label for easy identification
					console.log(prepend + state + ' : ' + triggers[i].itemname + '-->' + triggers[i].prop + ' ' + operator + ' ' + triggers[i].value); // jshint ignore:line
				}
				console.groupEnd();  // jshint ignore:line
			}, 1000);
		},

		clearRuleStack: function(){
			rulesStack = {};
		}


	});
}(this));
