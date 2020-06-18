/*--------------------------------------------------------------------
[xs-wg-dropdownmenu JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:40 GMT
Assigned to:	Raghavendra Narasapurapu
Description:	This component provides a select menu.
---------------------------------------------------------------------*/
/**
	@description
        This component provides a select menu.
    @module
	   SPProcXSUI
	@example

*/
/* global Polymer, DS */

(function () {
	'use strict';

	// Private Methods
	// Life cycle methods
	// Event handlers
	// Constants
	// Enums
	// Module variables
	// Prototype
	Polymer({  // jshint ignore:line
		is: 'xs-wg-dropdown',
		properties: {
			// Private
			_adp: { value: null },
			_error: Object,
			choices: {
				type: Array,
				value: function () {
					return [];
				},
				notify: true,
				observer: 'choicesChanged'
			},
			choices_display: { // jshint ignore:line
				type: Array,
				value: function () {
					return [];
				},
				notify: true,
				observer: 'choicesDisplayChanged'
			},
			userchoices: {
				type: String,
				notify: true,
				observer: 'userchoicesChanged',
				value: ''
			},
			label: String,
			mandatory: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'mandatoryChanged'
			},
			placeholder: String,
			// Attributes
			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},
			haserror: {
				type: Boolean,
				value: false,
				notify: true
			},
			value: {
				notify: true,
				observer: 'valueChanged'
			},
			datatype: {
				type: String,
				value: 'string'
			}
		},
		// Life cycle
		ready: function () {
			// Get the adapter
			this._adp = this.XS();
		},
		attached: function () {
			this._validate();
		},

		// Change listeners
		valueChanged: function () {this._validate();
			var checkNum = this.value;
			/*
			Below If condition is added with repect  IR-641343-3DEXPERIENCER2019x where if given integer value (say 20) to real type in dropdown
			it will get changed to real(20.0), to prevent this this additional check is done. Please go to IR for detail description.
			*/
			if (Number(checkNum)){
				if (this.choices.indexOf(String(parseInt(checkNum))) !== -1) {
					this.$.sMenu.value = parseInt(checkNum) ;
				}
			}
			else if (this.choices.indexOf(this.value) !== -1) {
				// make sure that option is still valid
				// it will get called while loading to set value of dropdown
				// view rules if options changed - option change will happen after this
            	this.$.sMenu.value = this.value;
			}
		},

		choicesChanged: function () {
			var i;
			this._removeExisitingOptionTag();
			for (i = 0; i < this.choices.length; i += 1) {
				this._addOptionTag(this.choices[i]); // jshint ignore:line
			}
			if (this.choices_display && this.choices_display.length > 0) {  // jshint ignore:line
				this.choicesDisplayChanged(this.choices_display); // jshint ignore:line
			}
		},

		_removeExisitingOptionTag: function () {
			var allOptions, i, option;
			allOptions = this.$.sMenu.querySelectorAll('option');
			// index from 1 as we don't want to remove 'first option of 'Select an item'
			for (i = 1; i < allOptions.length; i += 1) {
				option = allOptions[i];
				option.parentElement.removeChild(option);
			}
		},

		_addOptionTag: function (value) {
			var option;
			option = document.createElement('option');
			option.value = value;
			option.selected = this.value === value;
			this.$.sMenu.appendChild(option);
		},

		choicesDisplayChanged: function (choicesDisplay) {
			var i, options, option;
			for (i = 0; i < this.choices.length; i += 1) {
				options = this.$.sMenu.querySelectorAll('option');
				option = this._getOptionTagFromNodeListByValue(options, this.choices[i]);
				if (option &&  choicesDisplay !== undefined && choicesDisplay[i] !== undefined) {
					option.title = choicesDisplay[i] || this.choices[i]; // jshint ignore:line
					option.innerHTML = this.toShorterString(choicesDisplay[i] || this.choices[i]);
				}
			}
		},

		userchoicesChanged: function (userChoices) {
			var _userChoices;
			if (userChoices !== undefined && userChoices !== null && userChoices !== '' && userChoices !== false) {
				try {
					_userChoices = JSON.parse(userChoices);
				} catch (ex) {
					//console.warn('Unable to parse user choices');
				}
			}
			// Valid value mean after option changes
			// selected value is still in options then select it else set first one by default
			// Initial load change hanler - should not disrupt anything
			if (_userChoices !== undefined) {
				var i = 0;
				// Remove existing choices
				this._removeExisitingOptionTag();
				// Create new choices based on user selection - Make sure they are from original choices
				// From UI user will not be able to do so as user choices needs to be selected from available choices only
				for (i = 0; i < _userChoices.length; i += 1) {
					this._addOptionTag(_userChoices[i]);
				}
				if (this.choices_display && this.choices_display.length > 0) {  // jshint ignore:line
					this.choicesDisplayChanged(this.choices_display); // jshint ignore:line
				}
				// if its not a valid value then make first option tag as selected
				if (_userChoices.indexOf(this.value) === -1) {
					this.$.defaultoption.disabled = false;
					this.$.defaultoption.selected = true;
					this.$.defaultoption.disabled = true;
					this.value = '';
				}
			} else { // When rule is unapplied - userchoices will be set to undefined hence original state of choices is required
				this.choicesChanged();
				this.valueChanged();
			}
			// Revalidate the component after this update
			this._validate();
		},

		_getOptionTagFromNodeListByValue: function (options, value) {
			var i = 0, option;
			for (i = 0; i < options.length; i += 1) {
				if (String(options[i].value) === String(value)) {
					option = options[i];
					break;
				}
			}
			return option;
		},

		mandatoryChanged: function () {
			this._validate();
		},
		// Private methods
		_validate: function () {
			var isValid, error;
			// Do not validate before Component is ready
			if (this.isAttached) {
				isValid = true;
				error = { title: this.label || 'Dropdown List' };
				// If its not explicitly set to be mandatory
				if (this.mandatory) {
					isValid = !this.JS.isEmpty(this.value);
					error.description = this.$.requiredMsg.value;
					error.isMandError = true;
				}

				// If it's valid
				if (this._adp && !isValid) {
					this.haserror = true;
					this._adp.setError(error);
				} else if (this._adp && isValid) {
					this.haserror = false;
					this._adp.clearError();
				}
			}
		},
		_isEmpty: function () {
			return this.JS.isEmpty(this.value);
		},

		// Public methods
		/**
         * Public method to bring focus to input
         */
		focus: function () {
			this.$.sMenu.focus();
		},
		toShorterString: function (value) {
			if (value && value.length >= 200) {
				return value.substring(0, 200)+'...';
			} else if (value && value.length <200){
				return value;
			}
			return '';
		},
		calculateLabel: function (label, mandatory) {
			if (!mandatory && label) {
				return label;
			} else if (mandatory && label !== '') {
				return (label + ' *');
			}
			return '';
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase],
		_computeInputClass: function (haserror) {
			var inputClass;
			inputClass = 'form-control select-input ';
			inputClass += (haserror ? 'has-error' : '');
			return inputClass;
		},
		_onChange: function () {
        	this.value = this.$.sMenu.value;
		}

	});
}(this));
