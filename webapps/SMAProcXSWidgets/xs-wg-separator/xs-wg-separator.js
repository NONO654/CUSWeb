/*--------------------------------------------------------------------
[xs-wg-separator Javascript Document]

Project:		xs
Version:		1.0
Last change:    Thu, 29 Oct 2015 19:52:45 GMT
Assigned to:	Vijaya Lakshmi Kantamneni
Description:    TODO: Description
---------------------------------------------------------------------*/
/**
 * xs-wg-separator
 * @module XSWidgetSeparator
 * @requires 'XSWidget', 'xs-js'
 */
/* global DS*/
(function () {
	'use strict';

	var XSWgSeparator;

	XSWgSeparator = {
	    is: 'xs-wg-separator',
	    behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	};
	window.Polymer(XSWgSeparator);
}());
