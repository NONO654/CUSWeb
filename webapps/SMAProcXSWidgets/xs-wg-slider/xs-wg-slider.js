/*--------------------------------------------------------------------
[xs-wg-slider Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:47:00 GMT
Assigned to:	d6u
Description:    Numerical slider
---------------------------------------------------------------------*/
/**
 * xs-wg-slider
 * @module XSWidgetSlider
 * @requires 'XSWidget', 'xs-js'
 */
/* global DS, Polymer*/
(function () {
	'use strict';

	var getCssPrefix,
		// Private module variables
		DEFAULT;
	DEFAULT = {
		min: 0,
		max: 100,
		value: 0,
		step: 1
	};

	var typingTimer, timerInterval =900;


	getCssPrefix = function () {
		var browserPrefixes,
			tempElem,
			prefix, index;
		browserPrefixes = ['-webkit-', '-moz-', '-ms-', '-o-'];
		tempElem = document.createElement('div');
		// Find browser prefix
		for (index = 0; index < 4; index += 1) {
			prefix = browserPrefixes[index];
			tempElem.style.background = prefix + 'linear-gradient(#000,#fff)';
			if (tempElem.style.background) {
				break;
			}
		}
		return prefix;
	};


	Polymer({ // jshint ignore:line
		is: 'xs-wg-slider',
		properties: {
			//Private
			/**@property adapter
			 * @desc object that helps to communicate with the canvas
			 */
			_adp: {
				value: null
			},
			datatype: {
				notify: true,
				value: 'real',
				observer: 'datatypeChanged'
			},
			/**@property label */
			label: {
				type: String,
				notify: true
			},
			/**@property process max */
			max: {
				notify: true,
				value: ''
			},
			/**@property process min */
			min: {
				notify: true,
				value: ''
			},
			/**@property custom min */
			usermin: {
				notify: true
			},
			/**@property custom max */
			usermax: {
				notify: true
			},
			/**@property valid min - max */
			validmin: {
				type: Number,
				notify: true
			},
			validmax: {
				type: Number,
				notify: true
			},
			readonly: {
				type: Object,
				value: false,
				notify: true,
				observer: '_readOnlyChanged'
			},
			step: {
				notify: true
			},
			/**
			 * @property value*/
			value: {
				notify: true,
				observer: 'valueChanged'
			}
		},
		observers: [
			'toPercentage(value, validmin, validmax)',
			'_computeValidMinMax(min,max,usermin,usermax)'
		],
		ready: function () {
			this._adp = this.XS();
		},
		//Custom filter
		toPercentage: function (value, validmin, validmax) {
			var percentage;
			var min = validmin;
			var max = validmax;
			//dynamically assign step value if default step size of 0.001 is not enough for Real numbers to create at least 200 steps.
			if (this.datatype==='real' && (max - min)<(100*this.step)){
				this.step= (max - min)/200;
			}
			// if its crome then only set backgorund
			if (navigator.userAgent.indexOf('Chrome') !== -1) {
				//Check if the value is convertible to integer and if it has a range within
				value = (isNaN(value) || value==='') ? ((max - min)/2) : Number(value);
				//if value is less than minimum, then set the value to min
				if (value < min){
					value=min;
				}
				percentage = (value - min) <= 0 ? 0 : (value - min) * 100 / (max - min);
				this._setRangeColorGrandient(percentage + '%');
			}
		},
		/**
		 * @param  {Number} min
		 * @param  {Number} max
		 * @param  {Number} usermin
		 * @param  {Number} usermax
		 */
		_computeValidMinMax: function (min, max, usermin, usermax) {
			var value, _self, isPdata;
			_self = this;
			//searlize the data
			function validValue(value, defaultValue) {
				return value && !isNaN(value) ? Number(value) : defaultValue;
			}
			//validates and returns the correct value of min/max
			function getValidBounds(bmin, buser, bmax, sString) {
				var noError, validData;
				/**if process data is present then add the comparison with process data, else only compare with value */
				if (sString === 'min') {
					//user min should be less than value
					noError = isPdata ? (bmin <= buser && buser <= bmax) : (buser <= bmax);
				} else if (sString === 'max') {
					//user max should be greater than the value
					noError = isPdata ? (bmin <= buser && buser <= bmax) : (bmin <= buser);
				}
				if (noError) {
					//remove the error for the correct property
					if (_self.$.errorPanel.innerText.contains(sString)) {
						_self.$.errorPanel.innerText = '';
					}
					validData = buser;
				} else {
					//set error on the component in design mode
					if (_self._adp && _self._adp.whichMode() === 'design') {
						_self.$.errorPanel.innerText = 'Please enter valid ' + sString + ' in properties tab';
					}
					validData = sString === 'min' ? bmin : bmax;
				}
				if (sString === 'min') {
					validData = validData || DEFAULT.min;
				}
				else if (sString === 'max') {
					validData = validData || DEFAULT.max;
				}
				return validData;
			}
			//converting data into valid type
			value = validValue(this.value, undefined);
			usermin = validValue(usermin, DEFAULT.min);
			usermax = validValue(usermax, DEFAULT.max);
			min = validValue(min, undefined);
			max = validValue(max, undefined);
			//if the value is '' or undefined
			value = value || usermin;
			isPdata = Boolean(min !== undefined && max !== undefined);
			/**
			 * conditions for user min-max
			 * min <= usermin <= value
			 * value <= usermax <= max
			 * if the user min-max is not valid set it to the process/default state
			 */
			this.validmin = getValidBounds(min, usermin, value, 'min');
			this.validmax = getValidBounds(value, usermax, max, 'max');
		},
		_setRangeColorGrandient: function (gradient) {
			var inputRangeElem,
				prefix;
			inputRangeElem = this.$.range;
			prefix = getCssPrefix();
			inputRangeElem.style.background = prefix + 'linear-gradient(left, #2980b9 ' + gradient + ', #ccc ' + gradient + ')';
		},

		//Attribute change listeners
		datatypeChanged: function () {
			// This is required so ensure Slider thumb behaves correctly for real numbers with decimals.
			// Default step value is 1
			this.step = this.datatype === 'real' ? 0.001 : 1;
		},
		// For IE
		onInput: function () {
			this.value = this.$.range.value;
		},

		valueChanged: function (value, old) {
			this.async(function () {
				this.$.range.value = value;
			}.bind(this));
			if (this._adp && this._adp.whichMode() === 'design') {
				this._computeValidMinMax(this.min, this.max, this.usermin, this.usermax);
			}
			//IR-640832-3DEXPERIENCER2019x : Slider is overresponsive in validating input value of slider.
			//Whenever user has updated value i.e. user has done a new keystroke, timer is reset to 0. If user doesn't update value within specified time interval, validate function gets called.
			//This will stop slider component to be overresponsive.
			clearTimeout(typingTimer);
			typingTimer= setTimeout(function(){
				this._validate(value, old);
			}.bind(this), timerInterval);
		},

		// public method to return type
		returnDatatype: function (propertyName) {
			if (propertyName === 'usermin' || propertyName === 'usermax' || propertyName === 'value') {
				return 'Number';
			}
			return '';
		},
		//Private method
		//can add value, old as args so that if error is present reset the value to old valid data
		_validate: function () {
			var isValid = true,
				errorDescription, nMin, nMax, nValue;
			isValid = this.validmin !== undefined && this.validmax !== undefined;
			if (isValid && this.value) {
				nValue = parseFloat(this.value);
				nMin = parseFloat(this.validmin);
				nMax = parseFloat(this.validmax);
				if (isNaN(Number(this.value)) || isNaN(nMin) || isNaN(nMax)) {
					isValid = false;
					errorDescription = 'Please enter a valid number';
				}
				//If there are no mandatory field related errors, check for the value validity
				if (isValid) {
					isValid = nValue >= nMin && nValue <= nMax;
					errorDescription = 'Please ensure value is between ' + nMin + ' and ' + nMax + ' boundaries';
				}
				//If it's not valid
				if (this._adp && !isValid) {
					// console.log('invalid '+' min '+this.min+' max '+this.max+' value '+this.value);
					this._adp.setError({
						title: this.label || 'Slider',
						description: errorDescription
					});
				} else if (this._adp && this._adp.hasError) {
					this._adp.clearError();
				}
			}
			return isValid;
		},
		_readOnlyChanged: function () {
			if (this.readonly !== undefined && this.readonly.toString() === 'true') {
				this.$.outputvalue.readonly = true;
				// Set the readonly class on the host
				Polymer.dom(this).classList.add('is-readonly');
			} else {
				this.$.outputvalue.readonly = false;
				Polymer.dom(this).classList.remove('is-readonly');
			}
		},
		focus: function () {
			this.$.outputvalue.focus();
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
