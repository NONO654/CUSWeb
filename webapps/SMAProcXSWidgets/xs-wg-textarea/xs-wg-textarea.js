/*--------------------------------------------------------------------
[xs-wg-textarea Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:47:02 GMT
Assigned to:	d6u
Description:    Multiline text area
---------------------------------------------------------------------*/
/**
 * xs-wg-textarea
 * @module XSWidgetTextarea
 * @requires 'XSWidget', 'xs-js'
 */
/* global DS, Polymer*/
(function () {
	'use strict';

    // Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-textarea',
		properties: {
            // Private
			_adp: { value: null },
			label: {
				notify: true,
				observer: 'labelChanged'
			},
			haserror: {
				type: Boolean,
				notify: true,
				reflectToAttribute: true,
				observer: 'haserrorChanged'
			},
			mandatory: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true,
				observer: 'mandatoryChanged'
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
				type: String,
				notify: true,
				observer: 'valueChanged'
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
		labelChanged: function () {
			this._validate();
		},
		valueChanged: function () {
			this._validate();
		},
		mandatoryChanged: function () {
			this._validate();
		},
        // Private methods
		_validate: function () {
			var isValid = true, error;
			error = { title: this.label || 'Text Area' };
            // If its not explicitly set to be mandatory
			if (this.mandatory && this.mandatory.toString() === 'true') {
				isValid = !this.JS.isEmpty(this.value);
				error.description = 'Required';
				error.isMandError = true;
			}
            // If its not valid
			if (this._adp && !isValid) {
				this._adp.hasError = true;
				this._adp.setError(error);
				this.DOM(this.$.textarea).addClass('haserror');
			} else if (this._adp && isValid) {
				this._adp.hasError = false;
				this.DOM(this.$.textarea).removeClass('haserror');
				this._adp.clearError();
			}
		},
        // Public methods
        /**
               * Public method to bring focus to input
         */
		focus: function () {
			this.$.textarea.focus();
		},

		calculateLabel: function (label, mandatory) {
			if (!mandatory && label) {
				return (label);
			} else if (mandatory && label !== '') {
				return (label + ' *');
			}
			return '';
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
