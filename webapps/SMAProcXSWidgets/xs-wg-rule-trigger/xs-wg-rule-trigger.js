/*--------------------------------------------------------------------
[xs-wg-rule-trigger JS Document]

Project:
Version:
Last change:
Assigned to:
Description:	The wrapper component for rules
---------------------------------------------------------------------*/
/**

	@module SMAProcXSWidgets
	@submodule xs-wg-rule-trigger
	@class xs-wg-rule-trigger
	@description
        //TODO: Write the description about the component


	@example

*/
/* global SPBase, Polymer*/

(function () {
	'use strict';

	var searializeDate, EVENTS;

	EVENTS = {
		STATE_CHANGED: 'state-changed',
		PROP_UPDATE: 'trgUpdateProp',
		ITEM_UPDATE: 'trgUpdateItem',
		PROP_CHANGED: 'prop-changed',
		ITEM_NAME_CHANGED: 'itemname-changed',
		LOG_RULE_TRIGGER: 'log-rule-trigger',
		REMOVE_CONDITION: 'removeCondition'
	};
    /**
     * @param  {String} value
     * returns the timestamp for the date value
     * @return {Number} time
     */
	searializeDate = function (value) {
		value = isNaN(value) ? value : Number(value);
		return new Date(value).getTime();
	};

	Polymer({ // jshint ignore:line
		is: 'xs-wg-rule-trigger',

		properties: {
			operator: {
                // number starting from 0 till conditions that we support
				type: Number,
				reflectToAttribute: true
			},
			state: {
				type: Boolean,
				value: false
				// observer: '_stateChanged'
                // notify: true TODO: Analyze why state-changed event is not thrown
			},
			value: {
				type: String,
				reflectToAttribute: true
			},
			prop: {
				type: String,
				value: '',
				notify: true
			},
			itemname: {
				type: String,
				value: '',
				notify: true
			}
		},

		behaviors: [SPBase],
		//called when the validate condition is called
		_stateChanged: function () {
			this.fire(EVENTS.STATE_CHANGED);
		},

		propChanged: function () {
            // send notification to xs-wg-page that this condition's prop is getting updated
            // so that source UI element listneing for such change can remove its attribute
			var details = this._getTriggerAttribute();
			this.dataset[details.triggerName] = this.prop;
			details.newprop = this.prop;
			this.fire(EVENTS.PROP_UPDATE, details);
		},

		itemNameChanged: function () {
			var trgdetails = this._getTriggerAttribute();
			trgdetails.newItem = this.itemname;
			this.fire(EVENTS.ITEM_UPDATE, trgdetails);
		},
        // Public functions

		initMetaData: function () {
			if (this.metaDataInit !== true) {
				var trgdetail = this._getTriggerAttribute();
				this.prop = trgdetail.prop;
				this.fire('trgInit', {
					target: this,
					trgdetails: trgdetail
				});
				this.metaDataInit = true;
			}
		},

        // to be called by xs-wg-page to set initial item name if any
		setMetaData: function (itemName, propName) {
			this.itemname = itemName;
			this.prop = propName || this.prop;
			this.listen(this, EVENTS.PROP_CHANGED, 'propChanged');
			this.listen(this, EVENTS.ITEM_NAME_CHANGED, 'itemNameChanged');
		},

		/* Types supported for deserialization:
		* - Number
		* - Boolean
		* - String
		* - Object (JSON)
		* - Array (JSON)
		* - Date//if(this.value.indexOf("{{") !== 0){
		*/
			 // Validated the condition and updated the state of this element
			 // Case 2 and above cases should strictly be for number and date type
	 validateCondition: function (updatedValue, datatype) {
		 if (updatedValue && updatedValue.indexOf('{{') === 0) {
			 return;
		 }
					 // serialize the values
		 var trueValue = this._getConditionValueForCompare(this.value, datatype);
		 var componentValue = this._getConditionValueForCompare(updatedValue, datatype);
		 var isANumber = this._isANumber(updatedValue);
		 switch (this.operator) {
		 case 0:
									 // 'Equal to'
			 this.state = componentValue === trueValue;
			 break;
		 case 1:
									 // 'Not Equal to';
			 this.state = componentValue !== trueValue;
			 break;
		 case 2:
									 // 'check for given value is greater than condition value',
			 if(isANumber){
				 this.state = componentValue > trueValue;
			 }else{
				 this.state = false;
			 }
			 break;
		 case 3:
									 // ' given value less than condition value',
			 if(isANumber){
				 this.state = componentValue < trueValue;
			 }else{
				 this.state = false;
			 }
			 break;
		 case 4:
									 // 'given value is greater than or equals condition value'
			 if(isANumber){
				 this.state = componentValue >= trueValue;
			 }else{
				 this.state = false;
			 }
			 break;
		 case 5:
									 // 'given value is less than or equals condition value'
			 if(isANumber){
				 this.state = componentValue <= trueValue;
			 }else{
				 this.state = false;
			 }
			 break;
		 default:
			 this.state = false;
		 }
		 this.logtrigger();
		 this._stateChanged();
	 },

	 _isANumber: function(updatedValue){
		 if(updatedValue==='' || updatedValue===null || updatedValue===undefined){
			 return false;
		 }else{
			 return true;
		 }
	 },

		logtrigger: function () {
			if (localStorage.getItem('XS_RULES_CONSOLE') === 'true') {
				this.fire(EVENTS.LOG_RULE_TRIGGER, { trigger: this });
			}
		},

        // Removes this condition
		remove: function () {
			// send notification to xs-wg-page that this condition is getting removed
			// so that source UI element listneing for such change can remove its attribute
			this.fire(EVENTS.REMOVE_CONDITION, this._getTriggerAttribute());
			// remove condition from dom
			Polymer.dom(Polymer.dom(this).parentNode).removeChild(this);
		},

        // Private Functions

        // Date has to compaired by geting time
        // and number should be compaired by deserialize it to number type
        // rest other types can be compaired in serialized format
		_getConditionValueForCompare: function (conValue, datatype) {
			var type = this._getType(conValue, datatype);
			var lhs = conValue || '';
			if (type === 'Date') {
				return searializeDate(conValue);
			}
			if (type === 'Number') {
				return Number(conValue);
			}
			if (type === 'Boolean') {
				lhs = conValue ? conValue.toLowerCase() === 'true' : false;
				return String(lhs);
			}
			return lhs;
		},
        // put this function is sp base or xs-wg-base
        // currently implemented for date and number only
        // TODO : for array, object , String, Boolean
		_getType: function (value, datatype) {
			if (value instanceof Date || datatype === 'Date') {
				return 'Date';
			}
			if (!isNaN(value) && (datatype === 'int' || datatype === 'integer' || datatype === 'real')) {
				return 'Number';
			}
			if (typeof value === 'boolean' || datatype === 'boolean') {
				return 'Boolean';
			}
			return 'string';
		},

        // finding custom data attributes having trg prefix which is available on source change element
		_getTriggerAttribute: function () {
            // TODO: use regexp instead of find function
			var attrkeys = Object.keys(this.dataset).filter(function (element) {
				return element.indexOf('trg') === 0;
			});

            // There should be only one data-trg*** attribute on condition
			return {
				triggerName: attrkeys[0],
				prop: this.dataset[attrkeys[0]]
			};
		}
	});
}(this));
