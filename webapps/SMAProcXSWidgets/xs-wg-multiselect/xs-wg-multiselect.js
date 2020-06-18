/*--------------------------------------------------------------------
[xs-wg-multiselectmenu JS Document]

Project:		xs
Version:		1.0
Description:	This component provides a select menu.
---------------------------------------------------------------------*/
/**
	@description
        This component provides a select menu.
    @module
	   SPProcXSUI
	@example

*/
/* global DS */

(function () {
	'use strict';
	window.Polymer({
		is: 'xs-wg-multiselect',
		properties: {
			// Private
			_adp: { value: null },
			choices: {
				type: Array,
				value: function () {
					return [];
				},
				notify: true
			},
			label: String,
			mandatory: {
				type: Boolean,
				value: false,
				notify: true,
				observer: '_validate'
			},
			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},
			value: {
				notify: true,
				observer: '_validate'
			}
		},

		ready: function () {
			// Get the adapter
			this._adp = this.XS();
		},
		attached: function () {
			this._validate();
		},

		_computeOptions: function(choices) {
			var options = [];
			choices && choices.forEach(function(choice){
				options.push({
					value: choice
				});
			});
			return options;
		},

		_onChange: function (event) {
			var value = '', _value = event.detail.value;
			if (_value && _value.length > 0){
				value = JSON.parse(_value).join('\n');
			}
			this.value = value;
		},

		_computeValue: function(value) {
			if (value && value.length >= 1 && value.indexOf('{{') === -1) {
				return JSON.stringify(value.split('\n'));
			}
			return '[]';
		},

		_calculateLabel: function (label, mandatory) {
			if (!mandatory && label) {
				return label;
			} else if (mandatory && label !== '') {
				return (label + ' *');
			}
			return '';
		},

		_validate: function () {
			var isValid, error;
			// Do not validate before Component is ready
			if (this.isAttached) {
				isValid = true;
				error = { title: this.label || 'Multi Select List' };
				// If its not explicitly set to be mandatory
				if (this.mandatory) {
					isValid = !this.JS.isEmpty(this.value);
					error.description = 'Required';
					error.isMandError = true;
				}

				// If it's valid
				if (this._adp && !isValid) {
					this._adp.setError(error);
				} else if (this._adp && isValid) {
					this._adp.clearError();
				}
			}
		},
		focus: function () {
			this.$.multiselect.focus();
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
