/*--------------------------------------------------------------------
[xs-wg-heading JS Document]

Project:		xs
Version:		1.0
Last change:    Thu, 29 Oct 2015 19:52:29 GMT
Assigned to:	zb8, d6u
Description:	Heading widget that can be used for labeling any section
---------------------------------------------------------------------*/
/* global DS */

(function () {
	'use strict';

	var XSWgHeading;
	// Prototype
	XSWgHeading = {
		is: 'xs-wg-heading',
		properties: { label: String, value: '', notify: true },
		_computeNoDataClass: function (label) {
			if (label && label.length > 0) {
				return 'data-available';
			}
			return '';
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	};
	window.Polymer(XSWgHeading);
}(this));
