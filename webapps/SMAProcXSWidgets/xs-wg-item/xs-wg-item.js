/*--------------------------------------------------------------------
[xs-wg-item JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:47 GMT
Assigned to:	Aravind Mohan
Description:	The wrapper component for any UI element
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-wg-item
	@class xs-wg-item
	@description
        //TODO: Write the description about the component


	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-wg-item order="2">

		</xs-wg-item>

	@example
	<h5>JS</h5>

		//TODO: Show some API example
*/

/* global Polymer, DS, requestAnimationFrame */

(function(window) {
	'use strict';
	var WG_ITEM_TAG, SEPARATOR_TAG, WG_PATH, WG_IDENTIFIER, PROP_INSP_TAG, //Enums
		STATE, EVENT, DragData, DragdataType, DropAction, //Module variables
		identity, rulesetIdentity;
	//Initialize
	PROP_INSP_TAG = 'xs-property-inspector';
	WG_ITEM_TAG = 'xs-wg-item';
	SEPARATOR_TAG = 'xs-widget-separator';
	WG_PATH = '../../SMAProcXSWidgets/{tag}/{tag}.html';
	WG_IDENTIFIER = 'cmp_';
	identity = 0;
	rulesetIdentity = 0;
	STATE = {
		VISIBLE: 'is-visible',
		SELECTED: 'is-selected',
		DRAGOVER: 'is-dragover'
	};
	EVENT = {
		ITEM_SELECT: 'itemselect',
		ITEM_REMOVE: 'itemremove',
		ITEM_ASSOCIATE: 'itemassociate',
		ITEM_DISASSOCIATE: 'itemdisassociate',
		ITEM_DRAGREMOVE: 'itemdragremove',
		NAME_EXISTS: 'nameexists',
		NAME_UNIQUE: 'nameunique',
		ITEM_RESIZE_START: 'itemresizestart'
	};
	//TODO: Add Events and elements name here like xs-wg-item events name xsPropChanged
	DragData = function(dropType, item) {
		this.dropType = dropType;
		this.item = item;
	};
	DragdataType = {
		TEXT: 'text',
		URL: 'URL'
	};
	DropAction = {
		INSERT: 'INSERT',
		MOVE: 'MOVE'
	};
	//Private Function

	//To allow a smoother dragover
	var _prevDrag;
	var _selectedItem;
	/**
		@class XSWgItem
		@constructor
		@extends SPBase
	**/
	Polymer({ // jshint ignore:line
		is: 'xs-wg-item',
		properties: {
			adapter: {
				type: Object,
				value: function() {
					return {};
				},
				notify: true
			},
			forcedProps: {
				value: null
			},
			hint: {
				type: String,
				value: '',
				notify: true,
				reflectToAttribute: true,
				observer: '_onHintChange'
			},
			_hints: {
				type: Array,
				value: function() {
					return [];
				}
			},
			_errorMessage: {
				type: String,
				value: '',
				notify: true
			},
			name: {
				type: String,
				value: '',
				notify: true,
				reflectToAttribute: true
			},
			state: {
				type: String,
				value: '',
				notify: true
			},
			isDraggable: {
				type: Boolean,
				value: false,
				notify: true
			},
			disabled: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'disabledChanged'
			},
			hidden: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'hiddenChanged'
			},
			width: {
				type: Number,
				value: 100,
				notify: true
			},
			_ruleListners: {
				type: Object,
				value: {}
			},
			_metaProps: {
				type: Array,
				value: ['hidden'],
				readonly: true,
				notify: false
			},
			column: {
				type: String,
				value: '1',
				notify: true,
				reflectToAttribute: true
			}
		},
		_getWidget: function () {
			var children = Polymer.dom(this).children;
			if (children) {
				return children[0];
			}
			return undefined;
		},
		//Life cycle
		ready: function() {
			var instance = this;
			this.column = this.column ? this.column : '1';
			//Provide the widget getter
			Object.defineProperty(this, 'widget', {
				get: instance._getWidget
			});
		},
		_adjustWidth: function() {
			//If the widget is supposed to take the full width
			var widthClass = this.widget.fullWidth ? 'full-width' : 'spaced-width';
			Polymer.dom(this).classList.add(widthClass);
		},
		attached: function () {
			this.fire('xs-wg-item-attached');
			var nameId;
			this.rulesSupported = true;
			this._hidden = this.hidden;
			if (this.widget) {
				//    if(this.widget.ruleProp === undefined){
				//      this.rulesSupported = false;
				//    }
				//Fetch the adapter reference
				this._fetchAdapterRef();
				this.isDraggable = this.adapter.isInDesignMode();
				this.disabled = this.adapter.isDisabled();
				//Setup the adapter listeners
				this.adapter.listenOn('error', function(error) {
					this._errorMessage = error.description;
				}, this);
				this.adapter.listenOn('clearerror', function() {
					this._errorMessage = '';
				}, this);


				//Import the widget if not yet imported
				window.Polymer.Base.importHref([this.resolveUrl(WG_PATH.replace(/\{tag\}/g, this.widget.tagName.toLowerCase()))], function() {
					var isMand = this._isMandatory();
					//Set the mandatory flag if required
					if (isMand) {
						Polymer.dom(this.$.mandatoryFlag).classList.add(isMand);
					}

					this._adjustWidth();
				}.
					bind(this));
			}
			//Parse the widget name to get the numeric part (Only if the widget has default naming pattern)
			nameId = this.parseName(this.name, WG_IDENTIFIER);
			//Use the highest name id to generate the identity
			identity = identity <= nameId ? nameId + 1 : identity;
			//If the wrapped widget has a mandatory property set to true
			//display the mandatory flag
			if (this._isMandatory()) {
				Polymer.dom(this.$.mandatoryFlag).classList.add('is-visible');
			}
			//Wait for few milliseconds so the component is rendered before adjusting the width
			//				this._adjustWidth(500);
			//In case rules are supported for this.widget
			if (this.rulesSupported) {
				//set this.widget as target element in rules
				var rules = this.convertNodeListToArray(this.getAllRules());
				rules.forEach(function(rule) {
					rule.setTarget.call(rule, this.widget);
				}.bind(this));
				this._ruleListners = {};
				for (var dataAttribute in this.dataset) {
					if (dataAttribute.indexOf('trg') === 0) {
						this.addRuleTriggerListner(dataAttribute, this.dataset[dataAttribute]);
					}
				}
				//Exeute all conditions after this item is attached
				//TODO: Need to check if xs-widget-binder is alredy doing this, if yes remove this call
				//this.executeAllConditions();


			}
		},

		disabledChanged: function(){
			if (this.disabled){
				this.isDraggable = false;
			}
		},

		executeAllConditions: function() {
			//send first notification in case its in preview module
			//TODO: clean this code of reading data attributes again and again
			this.async(function() {
				if (!this.isDraggable) {
					for (var dataAttribute in this.dataset) {
						if (dataAttribute.indexOf('trg') === 0) {
							this.sendNotificationToPage(this.dataset[dataAttribute], true);
						}
					}
				}
			}.
				bind(this));
		},
		//get array of all rules
		getAllRules: function(prop) {
			if (prop === undefined) {
				return this.querySelectorAll('xs-wg-rule');
			} else {
				return this.querySelectorAll('xs-wg-rule[prop=' + prop + ']');
			}
		},
		addRuleTriggerListner: function(triggerName, propertyName) {
			///This function loops over all data attributes and add a listerns for all
			//In case a listner exists then don't add another listner.
			//keep a array of trigger ids that we need to pass to event for a particular listner
			if (!this._ruleListners.hasOwnProperty(propertyName)) {
				// /this.test.hasOwnProperty('dd')
				this._ruleListners[propertyName] = [];
				if (this._metaProps.indexOf(propertyName) !== -1) {
					this.listen(this, propertyName + '-changed', 'onRulePropChanged');
				} else {
					this.listen(this.widget, propertyName + '-changed', 'onRulePropChanged');
				}
			}
			this._ruleListners[propertyName].push(triggerName);
		},
		removeRuleTriggerListner: function(triggerName, propertyName) {
			if (this._ruleListners.hasOwnProperty(propertyName)) {
				this._ruleListners[propertyName].pop(triggerName);
				if (this._ruleListners[propertyName].length === 0) {
					this.unlisten(this.widget, propertyName + '-changed', 'onRulePropChanged');
					delete this._ruleListners[propertyName];
				}
			}
		},
		onRulePropChanged: function(event) {
			// Do now apply rules in case it is design mode
			if (!this.isDraggable) {
				//TODO:  instead of getting zeroth array element remove changed part and then convert dash case to camel case
				//DONE
				var propDashName = event.type.substr(0, event.type.lastIndexOf('-'));
				this.sendNotificationToPage(Polymer.CaseMap.dashToCamelCase(propDashName));
			}
		},
		sendNotificationToPage: function(propertyChanged, all) {
			if (this._ruleListners.hasOwnProperty(propertyChanged) && this._ruleListners[propertyChanged].length > 0) {
				var triggerList = this._ruleListners[propertyChanged];
				var propValue = '';
				var isNotBinded = true;
				var elementForChange;
				var datatype;
				if (this._metaProps.indexOf(propertyChanged) !== -1) {
					propValue = this[propertyChanged];
					elementForChange = this;
				} else {
					propValue = this.widget[propertyChanged];
					elementForChange = this.widget;
				}


				//TODO: needs to find a better way to pass this info
				if (propertyChanged === 'value') {
					datatype = this.widget.datatype;
				}

				this.fire('xsPropChanged', {
					property: propertyChanged,
					propValue: propValue,
					triggerList: triggerList,
					datatype: datatype
				});
			}
		},
		addNewRule: function(propname, propvalue, priority) {
			var xsRule = document.createElement('xs-wg-rule');
			xsRule.prop = propname;
			xsRule.value = propvalue;
			xsRule.priority = Number(priority);
			Polymer.dom(this).appendChild(xsRule);
			return xsRule;
		},

		detached: function() {
			//Use the highest name id to generate the identity
			identity = this.parseName(this.name, WG_IDENTIFIER) === identity - 1 ? identity - 1 : identity;
			//If there is an adp on the widget clear the error if any
			if (this.widget && this.widget._adp && this.widget._adp.hasError) {
				this.widget._adp.clearError();
			}
			for (var dataAttribute in this.dataset) {
				if (dataAttribute.indexOf('trg') === 0) {
					this.removeRuleTriggerListner(dataAttribute, this.dataset[dataAttribute]);
				}
			}
		},

		_clearUsageInRuleConditions: function() {
			//Before removing any item, remove xs-wg-trigger depending on this item
			var selectors = [];
			for (var dataAttribute in this.dataset) {
				if (dataAttribute.indexOf('trg') === 0) {
					selectors.push('xs-wg-rule-trigger[data-' + Polymer.CaseMap.camelToDashCase(dataAttribute) + '=' + this.dataset[dataAttribute] + ']');
				}
			}
			this.fire('itemremovetrigger', selectors);
		},

		_clearRules: function() {
			var rules = this.convertNodeListToArray(this.getAllRules());
			rules.forEach(function(rule){
				rule.remove();
			});
		},

		//Event handlers
		onRemove: function() {
			this._clearRules();
			this._clearUsageInRuleConditions();
			//Removes xs-wg-item from layout
			var parent = Polymer.dom(this).parentNode;
			Polymer.dom(parent).removeChild(this);
			//Trigger the remove event. The actual remove event happens in xs-designer
			//This clears the properties in property inspector after the widget is removed
			this.fire(EVENT.ITEM_REMOVE, this);
		},

		_isUsedInRules: function() {
			var usedInRules = false;
			for (var dataAttribute in this.dataset) {
				if (dataAttribute.indexOf('trg') === 0) {
					usedInRules = true;
				}
			}
			return usedInRules;
		},

		confirmDelete: function(event){
			event.stopPropagation();
			event.preventDefault();
			if (this._isUsedInRules()){
				this.fire('confirmDelete', {
					item: this,
					method: 'onRemove',
					msg: 'Deleting this component will make some rules unusable. Do you want to delete this component?'
				});
			} else {
				this.onRemove();
			}

		},

		onClick: function() {
			//If the widget is supposed to take the full width
			this.widget.fullWidth && Polymer.dom(this).classList.add('full-width');

			//Show the selection as overlay
			_selectedItem && _selectedItem.unselect();
			this.select();
			_selectedItem = this;
			//Fix for issue where user required to click twice to go to properties page.
			this.async(function(){
				this.fire(EVENT.ITEM_SELECT, this);
			}.bind(this));
		},

		unselect: function() {
			this.DOM(this.$.overlay).removeClass(STATE.SELECTED);
		},
		select: function() {
			this.DOM(this.$.overlay).addClass(STATE.SELECTED);
		},
		onDragStart: function(event) {
			var eventData = new DragData(DropAction.MOVE, {
				name: event.currentTarget.name
			});
			event.dataTransfer.setData(DragdataType.TEXT, JSON.stringify(eventData));
		},
		onDragOver: function(event) {
			//On an item can be dragged and dropped, so if item drag is blocked it should not listen for drop
			if (!this.isDraggable) {
				return;
			}
			this.DOM(this).addClass(STATE.DRAGOVER);
			//Remove the dragover states
			this.fire(EVENT.ITEM_DRAGREMOVE);
			//If there is a previously dragged over elem
			//remove its dragover state
			if (_prevDrag !== this) {
				//Clears any previous dragover states
				this._clearPrevDragOver();
			}
			event.preventDefault();
		},
		onDragLeave: function() {
			_prevDrag = this;
			this._clearPrevDragOver();
			this.fire(EVENT.ITEM_DRAGREMOVE);
		},
		//When a tool / widget is dropped
		//TODO: Handle widget drop and stop any other item from getting dropped
		onDrop: function(event) {
			if (!this.isDraggable) {
				return;
			}
			var dragData, item, srcElem, parent;
			event.preventDefault();
			//Clears any previous dragover states
			this._clearPrevDragOver();
			this.DOM(this).removeClass(STATE.DRAGOVER);
			//Get the data
			dragData = JSON.parse(event.dataTransfer.getData(DragdataType.TEXT));
			//If its an insert
			if (dragData.dropType === DropAction.INSERT) {
				parent = Polymer.dom(this).parentNode;
				if (dragData.noWrap) {
					item = window.document.createElement(dragData.item);
					item.column = this.column;
					Polymer.dom(parent).insertBefore(item, this);
				} else {
					//Add the widget to the content
					item = window.document.createElement('xs-wg-item');
					//Insert it to the top of this item
					item.column = this.column;
					Polymer.dom(parent).insertBefore(item, this);
					//Insert the widget
					item.insertWidget(dragData.item);
				}

				//Remove the drag style
				this.DOM(this).removeClass(STATE.DRAGOVER);
				event.stopPropagation();
			} else if (dragData.dropType === DropAction.MOVE) {
				parent = this.getAncestorNode(this);
				//Move Widget on top of this item
				srcElem = parent.querySelector('[name=' + dragData.item.name + ']');
				if (srcElem && srcElem !== this && !this._areYouMyAncestor(this, srcElem)) {
					if (this.isInsertAfter(srcElem, this)) {
						this.insertAfter(srcElem);
					} else {
						Polymer.dom(Polymer.dom(this).parentNode).insertBefore(srcElem, this);
					}
					srcElem.column = this.column;
				}
				this.DOM(this).removeClass(STATE.DRAGOVER);
				event.stopPropagation();
			}
		},

		insertAfter: function(item) {
			var parent = Polymer.dom(this).parentNode;
			if (this.nextSibling && this.nextSibling.tagName && (this.nextSibling.tagName.toLowerCase() === 'xs-wg-item' || this.nextSibling.tagName.toLowerCase() === 'xs-wg-section' || this.nextSibling.tagName.toLowerCase() === 'xs-wg-layout')) { // jshint ignore:line
				Polymer.dom(Polymer.dom(this).parentNode).insertBefore(item, this.nextSibling);
			} else {
				Polymer.dom(parent).appendChild(item);
			}
		},

		//Need to decide we need to insert before or after
		isInsertAfter: function(item, refItem) {

			if ((Polymer.dom(item).parentNode === Polymer.dom(refItem).parentNode) && (item.column === refItem.column) && (refItem.offsetTop > item.offsetTop)) {
				return true;
			} else {
				return false;
			}

		},

		getSection: function (item) {
			var section, numberOfElements, i, parentsection;
			var sections = item.parentNode.querySelectorAll('xs-wg-item.full-width');
			numberOfElements = sections.length;
			for (i = 0; i < numberOfElements; i += 1) {
				section = sections[i];
				if (parentsection && parentsection.offsetTop < section.offsetTop && section.offsetTop < item.offsetTop) {
					parentsection = section;
				} else if (!parentsection && section.offsetTop < item.offsetTop) {
					parentsection = section;
				}
			}
			return parentsection;
		},

		_clearPrevDragOver: function () {
			// Remove the dragover states
			this.fire(EVENT.ITEM_DRAGREMOVE);
			if (_prevDrag) {
				Polymer.dom(_prevDrag).classList.remove(STATE.DRAGOVER);
			}
		},
		_fetchAdapterRef: function() {
			//If adapter exist then keep a reference to it
			if (this.widget && this.widget.XS) {
				this.adapter = this.widget.XS();
			}
		},
		//Public methods
		//Inserts the widget into itself
		insertWidget: function(tag, callback) {
			//Import the widget if not yet imported
			window.Polymer.Base.importHref([this.resolveUrl(WG_PATH.replace(/\{tag\}/g, tag))], function() {
				var widget;
				// Create the widget
				widget = window.document.createElement(tag);
				// Create the name and id
				widget.id = WG_IDENTIFIER + identity;
				this.name = widget.id;
				// Insert it
				Polymer.dom(this).appendChild(widget);
				// Fetch the adapter reference
				this._fetchAdapterRef();
				this.isDraggable = this.adapter.isInDesignMode();
				identity = identity + 1;
				// Let the caller know that the widget has been inserted
				if (callback) {
					callback();
				}

				// for scroll
				this.async(function() {
					this._adjustWidth();
					if (this.scrollIntoViewIfNeeded) {
						this.scrollIntoViewIfNeeded();
					} else {
						if (navigator.appVersion.indexOf('Trident/') > 0) {
							/* Microsoft Internet Explorer detected in. */
							this.fire('scrollintoview', { item: this });
						 } else {
							this.scrollIntoView(false);
						 }
					}
				}.bind(this));
			}.bind(this), function(){
				var errorMsg = 'Your session has expired. A new login is required.';
				if (callback) {
					callback(errorMsg);
					this.onRemove();
				}
			}.bind(this));
		},
		//Associates property of a widget with a process item
		// Property - String & item - Object
		associate: function(prop, association) {
			var args = {
				widget: this.widget,
				prop: prop,
				association: association
			};
			this.asyncFire(EVENT.ITEM_ASSOCIATE, args);
		},
		//Disassociates property of a widget from a process item
		disassociate: function(prop) {
			var args = {
				widget: this.widget,
				prop: prop
			};
			this.asyncFire(EVENT.ITEM_DISASSOCIATE, args);
		},
		_isMandatory: function() {
			//We have to do this weird check because the webservice can cause the mandatory value to be
			// true or 'true' or 'TRUE' format !!!
			if (this.widget && this.widget.mandatory && this.widget.mandatory.toString().toLowerCase() === 'true') {
				return STATE.VISIBLE;
			} else {
				return '';
			}
		},
		listeners: {
			click: 'onClick',
			dragstart: 'onDragStart',
			dragover: 'onDragOver',
			dragleave: 'onDragLeave',
			drop: 'onDrop'
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase],
		_computeClass: function(state, isHidden) {
			return state + 'content ' + state + (isHidden ? ' is-hidden' : '');
		},
		_computeClass3: function(error) {
			var isVisible = error ? 'is-visible' : '';
			return 'wg-item-error-container ' + isVisible;
		},
		_computeIf: function(hint) {
			return hint && hint.length > 0;
		},
		_computeErrorDesc: function(adapter) {
			if (adapter && adapter.error) {
				return ' ' + adapter.error.description;
			}
		},
		_onHintChange: function() {
			this._hints = this.hint ? this.hint.split('\n') : '';
		},
		hiddenChanged: function(value) {
			this._hidden = value;
		}
	});
}(this));
