/*--------------------------------------------------------------------
[xs-wg-input JS Document]

Project:        xs
Version:        1.0
Last change:    Wed, 11 Nov 2015 15:46:45 GMT
Assigned to:    Aravind Mohan, d6u
Description:    This is a input text widget which could be used to associate
                a parameter/attribute of type text.
---------------------------------------------------------------------*/
/**

    @module SMAProcXS
    @submodule xs-wg-input
    @class xs-wg-input
    @description
        Input Text widget is a widgetized wrapper on sp-input.
        A parameter or an attribute can be associated.

    @example
    <h5>HTML</h5>

        <!-- Show how this component can be declared -->
        <xs-wg-input label="height" placeholder="Enter your number" value="50">
        </xs-wg-input>

*/
/* global DS, Polymer*/
(function () {
	'use strict';

	var isNumber;
	isNumber = function (datatype) {
		return datatype.match(/^(real|int|integer)$/);
	};
    // Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-input-text',
		properties: {
            // Private
			__adp: { value: null },
			datatype: {
				type: String,
				value: 'string',
				notify: true
			},
			label: {
				type: String,
				notify: true
			},
			mandatory: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'mandatoryChanged'
			},
			max: {
				type: Number,
				notify: true
			},
			min: {
				type: Number,
				notify: true
			},
			placeholder: {
				type: String,
				notify: true
			},
            // Attributes
			readonly: {
				type: Boolean,
				notify: true
			},
			value: {
				notify: true,
				observer: 'valueChanged'
			},
			haserror: {
				type: Boolean,
				notify: true,
				reflectToAttribute: true
			}
		},
        // Life cycle
		ready: function () {
            // Get the adapter
			this._adp = this.XS();
            // Polyfill to isInteger
			Number.isInteger = Number.isInteger || function (value) {
				return typeof value === 'number' &&
                  isFinite(value) &&
                  Math.floor(value) === value;
			};
		},
		attached: function () {
			this._validate();
		},
        // Change listeners
		valueChanged: function () {
			this._validate();
		},
		mandatoryChanged: function () {
			this._validate();
		},
        // keypress event listener to prevent wrong inputs
		_keypressed: function (event) {
			var k = event.key || String.fromCharCode(event.keyCode), _per;
            // in integer & real we have added support for exponential notation.
            // we need to recheck if we really want to support exponential for Integer.
			if (this.datatype === 'integer' || this.datatype === 'real') {
				_per = this.value.indexOf('.') > 0;
              // if real or exponential number is entered, user can enter period once only
				if (_per && k !== 'Backspace' && k !== 'e' && k !== '+' && k !== '-' && isNaN(k)) {
					event.preventDefault();
				} else if (k !== '.' && k !== 'Backspace' && k !== 'e' && k !== '+' && k !== '-' && isNaN(k)) {
					event.preventDefault();
				}
			}
		},
        // Private methods
		_validate: function () {
			var isValid = true, error, num;
			error = {
				title: this.label || 'Text Input'
			};
            // If it's not explicitly set to be mandatory
			if (this.mandatory && this.mandatory.toString() === 'true') {
				isValid = !this.JS.isEmpty(this.value);
				error.description = 'Required';
				error.isMandError = true;
			}

            // If there are no mandatory field related error, check for the value validity
			if (isValid && isNumber(this.datatype)) {
				isValid = !isNaN(this.value);
				error.description = 'Please enter a valid number';
			}

            // For integer datatype -> if the number is exponential number, check if it is integer
			if (isValid && this.datatype === 'integer') {
				num = Number(this.value);
				isValid = Number.isInteger(num);
				error.description = 'Please enter a valid integer';
			}

			if (isValid && !this.JS.isEmpty(this.min) && !this.JS.isEmpty(this.max)) {
				isValid = !this.JS.isEmpty(this.value) && !this.JS.isEmpty(this.value) && parseFloat(this.value) >= parseFloat(this.min) && parseFloat(this.value) <= parseFloat(this.max);
				error.description = 'Please enter a value between ' + this.min + ' and ' + this.max;
			}
            // If it's not valid
			if (this._adp && !isValid) {
				this.$.input.haserror = true;
				this._adp.setError(error);
			} else if (this._adp && isValid) {
				this.$.input.haserror = false;
				this._adp.clearError();
			}
		},
        // Public methods
        /**
         * Public method to bring focus to input
         */
		focus: function () {
			this.$.input.focus();
		},
		calculateLabel: function (label, mandatory) {
			if (!mandatory && label) {
				return label;
			} else if (mandatory && label !== '') {
				return (label + ' *');
			}
			return '';
		},
		_displayRange: function (min, max) {
            // return this.tokenList({ 'is-visible': min !== null }) + ' range-info ' + this.tokenList({ 'is-visible': min !== null });
			if (!(this.JS.isEmpty(min) || this.JS.isEmpty(max))) {
				return 'Range: ' + min + ' - ' + max;
			}
			return undefined;
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(
    /**
            @class XSWgInputText
            @constructor
            @extends SPBase
        **/
    this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
