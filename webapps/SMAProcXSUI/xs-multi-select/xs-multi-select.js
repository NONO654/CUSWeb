// Copyright 2016 Dassault Systemes Simulia Corp.
/*--------------------------------------------------------------------
[xs-multi-select Javascript Document]
Project:        xs
Version:        1.0
---------------------------------------------------------------------
@example
	<xs-multi-select id="multiSelect"></xs-multi-select>
	options should be given in below format
		[{
			value: '1',
			label: 'one'
		},{
			value: '2',
			label: 'two'
		}]
		Note : Label property is optional - if not provided value will be used as label also

	Selection can be read as value property - which is stringified array
	'"["1", "2"]"'

	Component fires change event on change in selection

	Component height is harcoded to 150px - can be directly overrided on component tag
*/
(function () {
	'use strict';
	var CLASS = {
		SELECTION : 'is-selected'
	};
	// Prototype
	window.Polymer({
		is: 'xs-multi-select',
		properties: {
			/*
				@attribute value - Array of values selected
				@type String
				@default undefined
				**/
			value: {
				type: String,
				notify: true,
				observer: 'valueChanged'
			},
			/*
				@attribute _value - Array of values selected
				@type Array - selected values in array format - private variable
				@default []
				**/
			_value: {
				type: Array,
				notify: true,
				observer: '_valueChanged'
				//value: []
			},
			/*
				@attribute options having choices and choices display (label) for value
				@type Array of objects
				@default []
				**/
			options: {
				type: Array,
				notify: true,
				value: []
			},
			/*
				@attribute disabled
				@type Boolean
				@optional
				@default false
      		 **/
			disabled: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true
			},

			/*
				@attribute required
				@type Boolean
				@optional
				@default false
      		 **/
			required: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true
			}
		},

		/**
		 * Lifecycle event listener - attached
		 * Initializes selection arrays
		 */
		attached: function () {
			this._availableChoicesSelection = [];
			this._selectedChoicesSelection = [];
		},

		/**
		 * if valid value is passed then it parses it and uses it internally
		 * if value passed is undefined or null or '' then nothing happens - to clear value pass "[]"
		 * Fires change event with value as argument
		 * @param {String} value - value passed to this component which should be stringyfied Array
		 */
		valueChanged: function (value) {
			if (value !== undefined && value !== null && value !== '') {
				this._value = JSON.parse(value);
				this.fire('change', { value: value });
			}
		},

		/**
		 * When selection changes internally then it updates valie property
		 * @param {Array} _value parsed format for value property
		 */
		_valueChanged: function (_value) {
			this.value = JSON.stringify(_value);
		},

		/**
		 * Moves selected options in available choices to selected choices
		 * @param {Event} event - MouseClick event on clicking select button on component
		 */
		toogleSelectedOption: function (event) {
			this.toogleSelection(event.target, this._availableChoicesSelection);
		},

		/**
		 * Moves selected options in selected choices to available choices
		 * @param {Event} event - MouseClick event on clicking deselect button on component
		 */
		toogleSelectedValue: function (event) {
			this.toogleSelection(event.target, this._selectedChoicesSelection);
		},

		/**
		 * Deselects options from Selected choices
		 */
		deselect: function () {
			this._selectedChoicesSelection.forEach(function(val) {
				this.splice('_value', this._value.indexOf(val), 1);
				this.notifyPath('_value', this._value);
			}.bind(this));
			this.$.availablechoices.render();
			this._clearSelection();
		},

		/**
		 * Selects options from Available choices
		 */
		select: function () {
			this._availableChoicesSelection.forEach(function(value) {
				this.push('_value', value);
			}.bind(this));
			this.$.availablechoices.render();
			this._clearSelection();
		},
		/**
		 * on clicking any option in any of the list - toogles the selection
		 * @param {HTMLElement} optEntity - options div which is clicked on
		 * @param {Array} list - based on available choices or selected choices - list is different
		 */
		toogleSelection: function(optEntity, list) {
			if (optEntity.classList.contains(CLASS.SELECTION)) {
				optEntity.classList.remove(CLASS.SELECTION);
				list.splice(list.indexOf(optEntity.dataset.value), 1);
			} else if (!this.disabled) {
				optEntity.classList.add(CLASS.SELECTION);
				list.push(optEntity.dataset.value);
			}
			// Disable/Enable the select button based on available selection
			this.$.select.disabled = this._availableChoicesSelection.length === 0;
			this.$.deselect.disabled = this._selectedChoicesSelection.length === 0;
		},

		/**
     * @not pure
     * Clears the selection on already selected options and also value change
     */
		_clearSelection: function () {
			var selectDivs = this.querySelectorAll('div.'+ CLASS.SELECTION);
			for (var i = 0 ; i < selectDivs.length; i += 1) {
				selectDivs[i].classList.remove(CLASS.SELECTION);
			}
			this._availableChoicesSelection = [];
			this._selectedChoicesSelection = [];
			this.$.select.disabled = true;
			this.$.deselect.disabled = true;
			this._valueChanged(this._value);
		},

		/**
		 * @not pure - dependency - this.options
		* Computes the label for value based on its value
		* @param {String} value actual option value
		* @returns {String} based on options if label is present it will be returned
		*/
		_computeLabel: function (value) {
			var label = value;
			this.options.forEach(function(opt){
				if (opt.value === value &&  opt.label !== undefined) {
					label = opt.label;
				}
			});
			return label;
		},

		/**
		 * Computes class for selected list based on value on required property
		 * @param {Array} value selected value
		 * @param {Boolean} required is value selection compulsary
		 * @returns {String} class which is to be applied in selected list div
		 */
		_computeSelectChoiceListClass: function(value, required) {
			var selectClass = 'selected-choices-list';
			if (required && value.length === 0) {
				selectClass += ' is-required';
			}
			return selectClass;
		},

		/**
		 * @not pure - dependency - this.options
		 * If any option is already selected then don't show it in available licenses
		 * filter for dom-repeat - available choices
		 * @param {Object} opt option item from list of options
		 * @returns {Boolean} is opt is already selected then false
		 */
		filterAvailableOptions: function (opt) {
			return !(this._value && this._value.indexOf(opt.value) !== -1);
		},

		/**
		 * Focus to this element
		 */
		focus: function() {
			this.$.availablechoices.render();
		}
	});
}(this));
