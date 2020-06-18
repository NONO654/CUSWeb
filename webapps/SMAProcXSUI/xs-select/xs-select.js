/*--------------------------------------------------------------------
[xs-select Javascript Document]
Project:        xs
Version:        1.0
Description:    Component List
---------------------------------------------------------------------*/
/* global Polymer*/
(function () {
	'use strict';

    // Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-select',
		properties: {
            /*
            @attribute value
            @type Array
            @default []
            **/
			value: {
				notify: true,
				reflectToAttribute: true,
				observer: 'valueChanged',
				value: ''
			},
            /*
            @attribute options
            @type Array
            @default []
            **/
			options: {
				type: Array,
				notify: true,
				observer: 'optionsChanged',
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

			tooltipVisible: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true
			},

			minLength: {
				type: Number,
				value: 15,
				notify: true,
				reflectToAttribute: true
			}
		},

		optionsChanged: function () {
			var i;
			this._removeExisitingOptionTag();
			if (this.options !== undefined && this.options.length !==0) {
				//IR-599220-3DEXPERIENCER2019x - sort options (by option[i].label)
				this.options.sort(function(a,b){
					return (a.label).toLocaleString().localeCompare(b.label);
				});

				for (i = 0; i < this.options.length; i += 1) {
					this._addOptionTag(this.options[i].value, this.options[i].label, this.options[i].title);
				}
			}
		},

		_removeExisitingOptionTag: function () {
			var allOptions, i, option;
			allOptions = this.$.select.querySelectorAll('option');
			for (i = 0; i < allOptions.length; i += 1) {
				option = allOptions[i];
				option.parentElement.removeChild(option);
			}
		},

		_addOptionTag: function (value, label, title) {
			var option;
			option = document.createElement('option');
			option.value = value;
			option.title = title || label || value;
			option.innerHTML = label;
			option.selected = String(this.value) === String(value);
			this.$.select.appendChild(option);
		},

		valueChanged: function () {
			this.fire('change', { value: this.value });
		},

		selectValueChanged: function () {
			this.value = this.$.select.value;
		},
		getTitle: function(options, value, tooltipVisible, minLength){
			var opt, titleLength,tooltipMsg;
			if(tooltipVisible && value!== undefined && value!== null && options && options.length > 0){
				options.forEach(function(option) {
					if(option.value === value){
						opt=option;
					}
				});
				if(opt){
					tooltipMsg = opt.title || opt.label || opt.value;
				}else{
					tooltipMsg = '';
				}

				titleLength = tooltipMsg.length;
				if(titleLength>minLength){
					return tooltipMsg;
				}else{
					return '';
				}


			}
			return '';
		}


	});
}(this));
