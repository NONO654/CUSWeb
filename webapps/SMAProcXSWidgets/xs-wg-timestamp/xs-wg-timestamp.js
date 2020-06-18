/*--------------------------------------------------------------------
[xs-wg-input JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:47:04 GMT
Assigned to:	d6u
Description:	Timestamp input
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-wg-timestamp
	@class xs-wg-timestamp
	@description
        Timestamp input component

	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-wg-input label="height" placeholder="Enter your number" value="50">
		</xs-wg-input>

*/
/* global DS, Polymer*/

(function (window) {
	'use strict';
	//Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-timestamp',
		properties: {
			//Private
			_adp: { value: null },
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
			//Attributes
			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},
			value: {
				type: String,
				notify: true,
				observer: 'valueChanged'
			},
			datatype: {
				type: Date,
				value: 'Date'
			},
			nolabel: {
				type: Boolean,
				value: false,
				notify: true
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
		//Change listeners
		labelChanged: function () {
			this._validate();
		},
		valueChanged: function () {
			this._validate();
		},
		mandatoryChanged: function () {
			this._validate();
		},
		//Event handlers
		/**
         * Event handler to display Calendar at the right position
         * Refer to ****IR-391964*****
         * Purpose
         * 1) Calendar is currently displayed with position:absolute.
         * When there is a container that's position: relative, calendar gets clipped off with a scrollbar
         * To avoid this, we are positioning it with position:fixed and exact co-ordinates.
         * 2) When Calendar is expected to go beyond browser viewport, display it on the top of the input
         * instead of default bottom position
         *
         * Limitations:
         * Once calendar is launched, if the user scrolls vertically or horizontally,
         * or resizes the window, calendar's position will be disturbed.
         *
         * This approach may not work in all browsers.Tested only with Chrome.
         *
         *
         * @param {click} event - Click event for sp-calendar
         */
		onShowCalendar: function (event) {
			var calendar, calendarInputHeight = 0, datePicker, calendarCoordinates, calendarYPos = 0, calendarXPos = 0, viewPortHeight = 0;
			calendar = event.currentTarget;
			//Bad to access another component's shadowDOM,but it's necessary here to position the calendar properly
			datePicker = calendar.$.datepicker;
			//Get the co-ordinates w.r.t browser viewport
			calendarCoordinates = this.DOM(this).getCoordinates(calendar);
			calendarXPos = calendarCoordinates.x;
			calendarYPos = calendarCoordinates.y;
			calendarInputHeight = calendar.clientHeight;
			//Get window's dimensions
			viewPortHeight = window.innerHeight || document.body.clientHeight || document.documentElement.clientHeight || 0;
			//If the calendar is likely to go beyond the browser viewport, show options on top;
			//300px Calendar size.TODO May want a better way than hard-coding 300
			if (viewPortHeight - calendarCoordinates.y < 300) {
				//Show datePicker on top of input in sp-calendar
				//This is a rough estimate of input and calendar heights summed
				datePicker.style.top = '-216px';
				//Reset Left
				datePicker.style.left = '';
				datePicker.style.position = 'absolute';
			} else {
				//Add height of calendar input box to position datePicker below the input box
				datePicker.style.top = calendarYPos + calendarInputHeight + 'px';
				datePicker.style.left = calendarXPos + 'px';
				//Position it based on the co-ordinates
				datePicker.style.position = 'fixed';
			}
		},

		calculateLabel: function(label, mandatory){
			if (!mandatory && label) {
				return label;
			}
			else if (mandatory && label!==''){
				return (label + ' *');
			}
		},
		//Private methods
		_validate: function () {
			//_adp may not have been initialized before attached
			if (!this._adp) {
				return;
			}

			var isValid = true, error;
			error = { title: this.label || 'Date' };
			//Perform a basic check to ensure user enters the date with digits
			isValid = this.$.calendar.validate(this.value);
			//If it's not explicitly set to be mandatory
			if (this.mandatory && this.mandatory.toString() === 'true') {
				isValid = !this.JS.isEmpty(this.value);
				error.description = 'Required';
				error.isMandError = true;
			}

			//If it's not valid
			if (this._adp && !isValid) {
				this.$.calendar.haserror=true;
				this._adp.setError(error);
			} else if (this._adp && isValid) {
				this.$.calendar.haserror=false;
				this._adp.clearError();
			}

		},
		//Public Methods
		/**
               * Public method to bring focus to input
         */
		focus: function () {
			this.$.calendar.focus();
		},
		_computeClass: function(nolabel){
			return nolabel ? 'hide' : '';
		},
		_computeClass1: function(nolabel){
			return nolabel ? 'input-field-large' : 'input-field';
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(/**
		@class XSWgTimestamp
		@constructor
		@extends SPBase
	**/
	this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
