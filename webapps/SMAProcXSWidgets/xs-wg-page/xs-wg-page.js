/*--------------------------------------------------------------------
[xs-wg-page JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:52 GMT
Assigned to:	Aravind Mohan
Description:	TODO: Description
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-wg-page
	@class xs-wg-page
	@description
        //TODO: Write the description about the component


	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-wg-page>

		</xs-wg-page>

	@example
	<h5>JS</h5>

		//TODO: Show some API example
*/
/* global Polymer*/

(function () {
	'use strict';

  // Public Methods
  /**
  @class XSWgPage
  @constructor
  **/
	Polymer({ // jshint ignore:line
		is: 'xs-wg-page',

		attached: function () {
			this.fire('xs-wg-page-attached');
		},

		_callRuleTriggers: function (event) {
			var triggerList, selector, ruleTrigger;
			event.stopPropagation();
      // listen to change events and then call validateCondition method on triggers
			triggerList = event.detail.triggerList;
			triggerList.forEach(function (trigger) {
			  selector = 'xs-wg-rule-trigger[data-' + trigger + '=' + event.detail.property + ']';
			  ruleTrigger = this.querySelector(selector);
         // We may not need this check. Remoave it after testing
				if (ruleTrigger) {
	        ruleTrigger.validateCondition(event.detail.propValue, event.detail.datatype);
				}
			}, this);
		},

		_removeRuleCondition: function (event) {
			var item;
			event.stopPropagation();
			item = this._getItemForTrigger(event.detail.triggerName, event.detail.prop);
			if (item) {
				item.removeAttribute('data-' + Polymer.CaseMap.camelToDashCase(event.detail.triggerName));
			}
		},

		_getItemForTrigger: function (triggerName, property) {
			var selector;
			if (property === undefined || triggerName === undefined) {
				return undefined;
			}
			selector = 'xs-wg-item[data-' + Polymer.CaseMap.camelToDashCase(triggerName) + '=' + property + ']';
			return this.querySelector(selector);
		},

		_initXSWGTrigger: function (event) {
			var item;
			event.stopPropagation();
			if (event.detail.newCont) {
				item = this.getItemByName(event.detail.itemName);
			}
			item = this._getItemForTrigger(event.detail.trgdetails.triggerName,
                                              event.detail.trgdetails.prop);
			if (item) {
				event.detail.target.setMetaData(item.name, event.detail.trgdetails.prop);
			}
		},

		_updateItemXSWGTrigger: function (event) {
			var item, newItem;
			event.stopPropagation();
			item = this._getItemForTrigger(event.detail.triggerName, event.detail.prop);
			if (item) {
        // Remove that attribute from current element
				item.removeAttribute('data-' + Polymer.CaseMap.camelToDashCase(event.detail.triggerName));
        // Set attribute to new item
			}
			newItem = this.getItemByName(event.detail.newItem);
			if (newItem) {
				newItem.dataset[event.detail.triggerName] = event.detail.prop;
			}
		},

		_updatepropXSWGTrigger: function (event) {
			var item;
			event.stopPropagation();
			item = this._getItemForTrigger(event.detail.triggerName, event.detail.prop);
			if (item) {
				item.setAttribute('data-' + Polymer.CaseMap.camelToDashCase(event.detail.triggerName), event.detail.newprop);
			}
		},

		_itemremovetrigger: function (event) {
			event.stopPropagation();
			event.detail.forEach(function (selector) {
				var trigElement = this.querySelector(selector);
				if (trigElement) {
					trigElement.remove();
				}
			}.bind(this));
		},

		_confirmDelete: function (event) {
			this._deleteItem = {
				item: event.detail.item,
				method: event.detail.method
			};
			this._msg = event.detail.msg;
			this.$.deleteDialog.show();
		},

		confirmRemove: function (event) {
			this._deleteItem.item[this._deleteItem.method]();
			this.hideMe(event);
		},

		hideMe: function (event) {
			this.$.deleteDialog.hide();
			event.stopPropagation();
		},

		containsItem: function (itemName) {
			return this.getItemByName(itemName) !== undefined;
		},

		getItemByName: function (itemName) {
			var element;
			if (itemName === undefined) {
				return undefined;
			}
			element = this.querySelectorAll('xs-wg-item[name=' + itemName + ']');
			if (element.length === 1) {
				return element[0];
			} else if (element.length >= 1) {
				// Log error console.log('Multiple itmes with same name found.');
			}
			return undefined;
		},

		getAllItems: function () {
			return this.querySelectorAll('XS-WG-ITEM');
		},

		ready: function () {
			this.listen(this, 'xsPropChanged', '_callRuleTriggers');
			this.listen(this, 'removeCondition', '_removeRuleCondition');
			this.listen(this, 'trgInit', '_initXSWGTrigger');
			this.listen(this, 'trgUpdateItem', '_updateItemXSWGTrigger');
			this.listen(this, 'trgUpdateProp', '_updatepropXSWGTrigger');
			this.listen(this, 'itemremovetrigger', '_itemremovetrigger');
			this.listen(this, 'confirmDelete', '_confirmDelete');
		}
	});
}(this));
