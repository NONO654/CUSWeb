/*--------------------------------------------------------------------
[xs-wg-checkbox JS Document]

Project:		xs
Version:		1.0
Last change:    Thu, 29 Oct 2015 19:52:22 GMT
Assigned to:	d6u
Description:	code behind for xs-wg-checkbox
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-wg-checkbox
	@class xs-wg-checkbox
	@description
        Checkbox widget which wraps sp-checkbox. Accepts
        association of parameter/attribute of Boolean type


	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-wg-checkbox value="true"></xs-wg-checkbox>

	@example
	<h5>JS</h5>

		//TODO: Show some API example
*/
/* global DS*/
(function (window) {
	'use strict';

	var XSWgCheckbox;

    // Prototype
	XSWgCheckbox = {
		is: 'xs-wg-checkbox',

        // Properties
		properties: {
			label: {
				type: String,
				notify: true
			},
			mandatory: {
				type: Boolean,
				value: false
			},
			readonly: {
				type: Boolean,
				value: false
			},
			value: {
                // Type is string because the existing web services send boolean values as strings
                // type: Boolean,
				type: String,
				notify: true,
				observer: '_onValueChange'
			},
			datatype: {
				type: String,
				value: 'boolean'
			}
		},

		_onValueChange: function () {
            // There should be a valid value and type should not be boolean
      			if (this.value !== undefined && this.value !== null && typeof this.value !== 'boolean') {
              // Ignore the value change if it's a binding string
				if (this.value.indexOf('{{') !== 0) {
					this.$.checkbox.checked = String(this.value).toLowerCase() === 'true';
				}
      			}
		},

		_onCheckedChange: function () {
        	if (this.isAttached) {
        		this.value = String(this.$.checkbox.checked).toLowerCase();
        	}
		},


        // Inheritance
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	};


	window.Polymer(XSWgCheckbox);
}(this));
