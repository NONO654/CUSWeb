/*--------------------------------------------------------------------
[xs-wg-multi-value-textfield JS Document]

Project:		xs-wg
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:50 GMT
Assigned to:	Thomas Esterle (TEE1)
Description:	TODO: Description
---------------------------------------------------------------------*/
/**

	@module SMAProcXS-WG
	@submodule xs-wg-multi-value-textfield
	@class xs-wg-multi-value-textfield
	@description
        //TODO: Write the description about the component


	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-wg-multi-value-textfield>

		</xs-wg-multi-value-textfield>

	@example
	<h5>JS</h5>

		//TODO: Show some API example
*/
/* global DS, Polymer*/
(function () {
	'use strict';
	var PLACEHOLDER;
	PLACEHOLDER={
		"false": 'Enter values delimited by return key',
		"true": ''
	};
	//Prototype
	window.Polymer({
		is: 'xs-wg-multi-value-textfield',
		properties: {
			//Private
			_adp: { value: null},
			datatype: {
				type: String,
				value: ''
			},
			label: {
				notify: true,
				observer: 'labelChanged'
			},
			mandatory: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'mandatoryChanged'
			},
			placeholder: { notify: true },
			//Attributes
			readonly: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'readonlyChanged'
			},
			value: {
				notify: true,
				observer: 'valueChanged'
			}

		},
		//Life cycle
		ready: function () {
			//Get the adapter
			this._adp = this.XS();
		},
		attached: function () {
			this._validate();
		},
		//Attribute change listeners
		labelChanged: function () {
			this._validate();
		},
		readonlyChanged: function (newVal) {
			if (newVal) {
				Polymer.dom(this.$.multivalInput).removeAttribute('primary');
			} else {
				Polymer.Base.set('$.multivalInput.primary', true, this);
			}
			this.$.multivalInput.placeholder=PLACEHOLDER[this.readonly];
		},
		valueChanged: function () {
			this._validate();
		},
		mandatoryChanged: function () {
			this._validate();
		},

		//Private methods
		_validate: function () {
			var isValid = true, error;
			error = { title: this.label || 'Multivalue Text Input' };
			//If its not explicitly set to be mandatory
			if (this.mandatory && this.mandatory.toString() === 'true') {
				isValid = !this.JS.isEmpty(this.value);
				error.description = 'Required';
				error.isMandError = true;
			}

			if (isValid && this.datatype === 'real' && this.value !== undefined) {
				isValid = this.value === '' || (this.valuetype === 'multival' ? this.value.split('\n').filter(isNaN).length === 0 : !isNaN(this.value));
				error.description = this.valuetype === 'multival' ? 'List of real numbers expected' : 'Single real number expected';
			} else if (isValid && (this.datatype === 'int' || this.datatype === 'integer') && this.value !== undefined) {
				var lhs = this.valuetype === 'multival' ? this.value.split('\n').join('') : this.value;
				var rhs = this.valuetype === 'multival' ? this.value.split('\n').join('') : this.value;
				isValid = (this.value === '')  || (parseInt(lhs) === rhs);
				error.description = this.valuetype === 'multival' ? 'List of integers expected' : 'Single integer expected';
			}

			//If its not valid
			if (this._adp && !isValid) {
				this.$.multivalInput.haserror=true;
				this._adp.setError(error);
			} else if (this._adp && isValid) {
				this.$.multivalInput.haserror=false;
				this._adp.clearError();
			}
		},
		//Public methods
		/**
               * Public method to bring focus to input
         */
		focus: function () {
			this.$.multivalInput.focus();
		},
		calculateLabel: function(label, mandatory){
			if (!mandatory && label) {
				return label;
			}
			else if (mandatory && label!==''){
				return (label + ' *');
			}
		},
		notifyError: function(event) {
			this._adp.notify({
				text: event.detail.msg,
				type: 'error',
				autoRemove: true
			});
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(/**
		@class XS-WGMultiValueTextfield
		@constructor
		@extends XSWg
	**/
	this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
