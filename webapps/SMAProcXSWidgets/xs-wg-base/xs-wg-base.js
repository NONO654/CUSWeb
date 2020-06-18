/*--------------------------------------------------------------------
[xs-wg-base JS Document]

Project:		xs
Version:		1.0
Last change:    Fri, 13 Nov 2015 15:10:08 GMT
Assigned to:	Aravind Mohan
Description:	TODO: Description
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-wg-base
	@class xs-wg-base
	@description
        UI elements which require error notification capability, JS
		and DOM Api's must mix XSWgBase
*/
/* global Polymer, DS */

(function (window) {
	'use strict';

	var XSWgBase;
	// Initialize if not already initialized
	// Assuming window.DS is initialized from sp-base
	window.DS.SMAProcXSWidgets = window.DS.SMAProcXSWidgets || {};

    /**
		@class XSWgBase
		@mixin
		@extends SPBase
	**/
	XSWgBase = {
		XS: function () {
			var Interface;
            // If the adapter is not yet created for this widget
			if (!this._adapter) {
				Interface = window.document.createElement('xs-widget-interface');
				this._adapter = new Interface.Adapter(this);
			}
			return this._adapter;
		},

		/**
		 * Get a Array of element of up hierarchy till xs-wg-page
		 * @param  {Node} item Node for which hierarchy is required
		 * @param  {Array} hierarchy Its a recuresive function so pass this as []
		 * @return {Array} - hierarchy till xs-wg-page
		 */
		_getUpHierarchy: function (item, hierarchy) {
			var parent;
			if (!hierarchy) {
				hierarchy = [];
			}
			// Get Parent Node
			parent = Polymer.dom(item).parentNode;
			// Its a page then its the top element
			if (item.tagName && parent.tagName === 'XS-WG-PAGE') {
				hierarchy.push(parent);
				return hierarchy;
			} else if (item.tagName && (parent.tagName === 'XS-WG-LAYOUT' || parent.tagName === 'XS-WG-SECTION')) {
				hierarchy.push(parent);
				return this._getUpHierarchy(parent, hierarchy);
			}
			// Something is wrong, exit here
			return hierarchy;
		},

		_areYouMyAncestor: function (me, droppedElement) {
			// First of all only two things can be dropped either xs-wg-item or xs-wg-layout
			// if anything other than xs-wg-layout then you are not my ancestor
			var isAncestor = false;
			var hierarchy = this._getUpHierarchy(me);
			hierarchy.forEach(function (parenthierarchy) {
				if (droppedElement.name === parenthierarchy.name) {
					isAncestor = true;
				}
			});
			return isAncestor;
		},

		getAncestorNode: function (item) {
			var parent = Polymer.dom(item).parentNode;
			if (Polymer.dom(parent).parentNode.tagName === 'XS-WG-PAGE') {
				return parent;
			}
			return this.getAncestorNode(parent);
		},

		// Returns the numeric part of the widget name if it has the same pattern as the auto
		// generated name. Useful in updating the identity to help in unique widget name creation
		parseName: function (name, prefix) {
			var nameId = null, endMatch = '[0-9]*$';
				// If there is a match
			if (name.search(new window.RegExp('^' + prefix + endMatch)) > -1) {
				nameId = window.parseInt(name.match(new window.RegExp(endMatch))[0], 10);
			}
			return nameId;
		},

		convertNodeListToArray: function (nodeList) {
			var nodeArray = [], i;
			for (i = 0; i < nodeList.length; i += 1) {
				nodeArray.push(nodeList[i]);
			}
			return nodeArray;
		},

		/**
		 * Show properties for any object
		 * @param {any} objectId object id of oject whose properties are to be shown
		 * @param {any} spDashboard sp dashboard instance
		 * @returns {Object} with property success which if is false then it has msg property explaining why it failed
		 */
		showObjectProperties: function (objectId, spDashboard) {
			var url, widgetId, PREVIEW_PREFIX;
			if (spDashboard.isInDashboard() && localStorage.getItem('XS_BETA') === 'true') {
				widgetId = spDashboard.getWidgetId();
				PREVIEW_PREFIX = 'preview-';
				if (widgetId && (widgetId.substr(0, PREVIEW_PREFIX.length) === PREVIEW_PREFIX)) {
					return {
						success: false,
						msg: 'Unable to launch Properties widget in transient mode. Please pin the Performance Study widget.'
					};
				}
				require(['DS/TransientWidget/TransientWidget'], function (Transient) {
					Transient.showWidget('ENOLCMT_AP', 'Properties', {
						SelectedItem: [{
							source: '3DSpace',
							objectId: objectId
						}],
						editProperties_editMode: 'true', // jshint ignore:line
						readOnly: 'false',
						securityContext: spDashboard.getSecurityContext(),
						isTransient: 'true'
					},
						{ mode: 'panel',
							height: 800,
							width: 650 });
				});
				return { success: true };

			} 
			url = spDashboard.getAuthenticatedJspUri('/common/emxNavigator.jsp?' + DS.SMAProcSP.SPBase.JS.toQueryString({
				isPopup: 'true',
				objectId: objectId
			}));
			window.DS.SMAProcSP.SPBase.WIN.openInWindow(url);
			return { success: true };
		}
	};
	window.DS.SMAProcXSWidgets.XSWgBase = [DS.SMAProcSP.SPBase, XSWgBase];
}(this));
