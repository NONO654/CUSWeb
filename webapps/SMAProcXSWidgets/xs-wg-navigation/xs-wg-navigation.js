/*--------------------------------------------------------------------
[xs-wg-navigation Javascript Document]
Project:        xs
Version:        1.0
Description:    Component List
---------------------------------------------------------------------*/
/* global DS*/
(function () {
	'use strict';

	// Prototype
	window.Polymer({
		is: 'xs-wg-navigation',
		properties: {
			/*
            @attribute steps
            @type steps
            @default ''
            **/
			steps: {
				value: ''
			},
			/*
			@private
            @attribute _steps - for dom repeat get an array out of steps
            @type Array
            @default []
            **/
			_steps: {
				type: Array,
				notify: true,
				computed: '_computeSteps(steps)',
				value: []
			},
			/*
            @attribute selected - currently selected step
            @type Number
            @default 1
            **/
		   selected: {
				type: String,
				value: '1',
				notify: true
			},
			/*
            @attribute disabled
            @type Boolean
            @default false
            **/
		   disabled: {
				type: Boolean,
				value: false,
				notify: true
			},
			datatype: {
				type: String,
				value: 'integer'
			},
			label: {
				notify: true
			}
		},
		observers: [
			'_validateSelectedIndex(_steps,selected)'
			// '_computeChoices(steps)'
		],

		selectStep: function(event) {
			this.selected = String(Number(event.currentTarget.dataset.stepid) + 1);
		},

		// _computeChoices: function(steps){
		// 	var stepsArray = [], counter = 1;
		// 	this.choices = [];
		// 	this.choices_display = [];
		// 	stepsArray = this._computeSteps(steps);

		// 	stepsArray.forEach(function(st){
		// 		this.choices_display.push(st);
		// 		this.choices.push(counter);
		// 		counter++;
		// 	}.bind(this));
		// },

		returnDatatype: function (propertyName) {
			if (propertyName === 'selected') {
				return 'Number';
			}
			return '';
		},

		_validateSelectedIndex: function(_steps, selected) {
			//if no number is entered, then default should be 1.
			if(selected===""){
				this.selected='1';
			}else if (Number(selected) < 1 || Number(selected) > _steps.length) {
				this.errorMsg = 'Selected Index should be between 1 and ' + _steps.length;
			} else {
				this.errorMsg = '';
			}
		},

		_computeSteps: function(steps) {
			return steps.split(',');
		},

		_computeStepMainClass: function (index, selected) {
			return String(index + 1) === selected ? 'step selected' : 'step';
		},

		_computeIndex: function (index) {
			return index + 1;
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase]

	});
}(this));
