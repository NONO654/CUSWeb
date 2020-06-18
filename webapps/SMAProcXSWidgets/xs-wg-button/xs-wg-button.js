/*--------------------------------------------------------------------
[xs-wg-button Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:35 GMT
Assigned to:	Vijaya Lakshmi Kantamneni
Description:    TODO: Description 
---------------------------------------------------------------------*/
/** 
* xs-wg-button
* @module XSWidgetButton
* @requires 'XSWidget', 'xs-js'
*/
/* global DS, Polymer*/

(function () {
    'use strict';
    Polymer({ // jshint ignore:line
        is: 'xs-wg-button',
        properties: {
            label: {
                type: String,
                value: 'Run',
                notify: true
            }
        },
        behaviors: [DS.SMAProcXSWidgets.XSWgBase]
    });
}(this));
