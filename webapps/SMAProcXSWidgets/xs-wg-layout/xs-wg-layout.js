/*--------------------------------------------------------------------
[xs-wg-layout JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:48 GMT
Description:	TODO: Description
---------------------------------------------------------------------*/
/* global DS, Polymer*/

(function (window) {
	'use strict';

	var STATE = {
		COLLAPSED: 'is-collapsed',
		SELECTED: 'is-selected',
		HANDLEDRAGOVER: 'is-dragover',
		COLUMNDRAGOVER: 'is-dragover'
	};
	var EVENT = {
		ITEM_SELECT: 'itemselect',
		ITEM_REMOVE: 'itemremove',
		ITEM_DRAGREMOVE: 'itemdragremove'
	};
	var DROPACTION = {
		INSERT: 'INSERT',
		MOVE: 'MOVE'
	};
	var WIDHT = {
		SMALL: 300, // one column layout is forced
		MEDIUM: 450 // two column layout is forced
	};

	var identity, LAYOUT_IDENTIFIER;
	var _selectedLayout, _prevDragOver;
	identity = 1;
	LAYOUT_IDENTIFIER = 'layout_';

	Polymer({ // jshint ignore:line
		is: 'xs-wg-layout',
		behaviors: [DS.SMAProcXSWidgets.XSWgBase],
		properties: {
			widget: {
				type: Object,
				value: function () {
					return this;
				}
			},
			vertical: {
				type: Number,
				value: 1,
				reflectToAttribute: true, // to prevent migration problem. Ideally never add reflect to attribute
				observer: 'verticalChanged'
			},
			column: {
				type: String,
				value: '1',
				notify: true,
				reflectToAttribute: true // to prevent migration problem. Ideally never add reflect to attribute
			},
			iscollapsible: {
				type: Boolean,
				value: true,
				notify: true
				// observer: '_iscollapsibleChanged' // for now it is not going to change
			},
			collapsed: {
				type: Boolean,
				value: false,
				notify: true,
				observer: 'verticalChanged'
			},
			collapsedInDesignMode: {
				type: Boolean,
				value: false,
				notify: true
			},
			label: {
				type: String,
				notify: true,
				value: ''
			},
			name: {
				type: String,
				reflectToAttribute: true, // name attribute and it needs to be saved
				notify: true,
				value: ''
			},
			_maxColumnLevel: {
				type: Number,
				value: 3,
				notify: true
			},
			_isDesignMode: {
				type: Boolean,
				notify: true,
				value: false
			},
			hidden: {
				type: Boolean,
				notify: true,
				value: false,
				observer: 'hiddenChanged'
			},

			disabled: {
				type: Boolean,
				value: false,
				notify: true
			},
			_lastHovered: {
				type: Number
			}
		},

		listeners: {
			xsWgLayoutExpand: 'onXsWgLayoutExpand'
		},
		// --------------Lifecycle Events--------------//
		ready: function () {
			// To avoid any migration problem
			this.vertical = this.vertical ? this.vertical : 1;
			this.column = this.column ? this.column : '1';
			// Internal variable init
			this._hover = false;
		},

		attached: function () {
			// Parse the widget name to get the numeric part (Only if the widget has default naming pattern)
			var nameId = this.parseName(this.name, LAYOUT_IDENTIFIER);
			// Use the highest name id to generate the identity
			identity = identity <= nameId ? nameId + 1 : identity;
			// To add name for root layout element
			if (this.name.length === 0) {
				this.name = LAYOUT_IDENTIFIER + identity;
				identity += 1;
			}
			this.id = this.name;
			this._adp = this.XS();

			window.addEventListener('resize', this.resizeChildren.bind(this));
			// Do Initial resize
			this.async(function () {
				this.resizeChildren();
				this.hiddenChanged();
			}.bind(this), 1E2);

			// Set designmode to true
			this._isDesignMode = this._adp.whichMode() === 'design';
			this.disabled = this._adp.isDisabled();
			this._isTopLayout = Polymer.dom(this).parentNode.tagName === 'XS-WG-PAGE';

			this.getAllRules().forEach(function (rule) {
				rule.setTarget(this);
			}.bind(this));
			this.fire('xs-wg-layout-attached');
		},

		dettached: function () {
			identity = this.parseName(this.name, LAYOUT_IDENTIFIER) === identity - 1 ? identity - 1 : identity;
			window.removeEventListener('resize', this.resizeChildren.bind(this));
		},

		verticalChanged: function () {
			var children;
			this.resizeChildren();
			children = Polymer.dom(this).children;
			children.forEach(function (child) {
				if (child.verticalChanged) {
					child.verticalChanged();
				}
			});
		},

		// --------------Property Observers--------------//

		hiddenChanged: function () {
			if (this.hidden) {
				this.$.handle.style.backgroundImage = 'repeating-linear-gradient(135deg, rgba(224, 197, 197, 0.3), rgba(0, 0, 0, 0.3) 1px, transparent 2px, transparent 3px, rgba(0, 0, 0, 0.3) 3px)';
				this.$.hiddenOverlay.classList.add('hiddenOverlay');
			} else {
				this.$.handle.style.backgroundImage = 'none';
				this.$.hiddenOverlay.classList.remove('hiddenOverlay');
			}
		},
		// ----Rules Support Start-------//
		// get array of all rules
		getAllRules: function (prop) {
			var children = Polymer.dom(this).children, i, child, l;
			var rules = [];
			for (i = 0, l = children.length, child; (i < l) && (child = children[i]); i += 1) {
				if (prop && child.tagName === 'XS-WG-RULE' && child.prop === prop) {
					rules.push(child);
				} else if (prop === undefined && child.tagName === 'XS-WG-RULE') {
					rules.push(child);
				}
			}
			return rules;
		},

		addNewRule: function (propname, propvalue, priority) {
			var xsRule = document.createElement('xs-wg-rule');
			xsRule.prop = propname;
			xsRule.value = propvalue;
			xsRule.setAttribute('column', '1');
			xsRule.priority = Number(priority);
			Polymer.dom(this).appendChild(xsRule);
			return xsRule;
		},

		// ----Rules Support End---------//
		// --------------User interaction Event Listeners--------------//

		onConfirmRemove: function (event) {
			var rulesPresent = false, childPresent = false, i, dataAttribute;
			var allItems = this.querySelectorAll('xs-wg-item');
			if (allItems.length > 0){
				childPresent = true;
				for (i = 0; i < allItems.length; i += 1) {
					for (dataAttribute in allItems[i].dataset) {
					 if (dataAttribute.indexOf('trg') === 0) {
					    	rulesPresent = true;
					    	break;
					  }
				    }
				}
			}
			if (childPresent && rulesPresent) {
				this.fire('confirmDelete', {
					item: this,
					method: 'onRemove',
					msg: 'This will delete all the components inside the Panel and make some rules unusable. Do you want to delete?'
				});
			} else if (childPresent) {
				this.fire('confirmDelete', {
					item: this,
					method: 'onRemove',
					msg: 'This will delete all the components inside the Panel. Do you want to delete?'
				});
			} else {
				this.onRemove();
			}
			event.stopPropagation();
		},

		// Expand this section
		onXsWgLayoutExpand: function () {
			this.collapsed = false;
		},

		// Removing the layout
		onRemove: function () {
			var items = Polymer.dom(this).children;
			// remove each item and then remove the layout
			items.forEach(function (item) {
				// TODO: Check that related xs-wg-plm-data is also removed
				item.onRemove && item.onRemove();
			});
			Polymer.dom(Polymer.dom(this).parentNode).removeChild(this);
			this.fire(EVENT.ITEM_REMOVE, this);
		},

		/* Click on Handle selects the element is design
		  and toggle collapse property in other modes
		  Common Interface with xs-wg-item*/
		onClick: function (event) {
			event && event.stopPropagation();
			if (this._isDesignMode) {
				this.fire(EVENT.ITEM_SELECT, this);
			} else {
				this.toggleCollapse();
			}
		},

		toggleCollapse: function () {
			// If i am collapsible then toggle my collapsed property
			if (this.iscollapsible && !this.preventTabSwitch) {
				this.collapsed = !this.collapsed;
			}
			this.preventTabSwitch = false;
		},

		// Common Interface with xs-wg-item
		unselect: function () {
			this.DOM(this.$.overlay).removeClass(STATE.SELECTED);
			this.DOM(this.$.handle).removeClass(STATE.SELECTED);
			if (_selectedLayout !== this) {
				_selectedLayout && _selectedLayout.unselect();
			}
			_selectedLayout = undefined;
		},

		// Common Interface with xs-wg-item
		select: function () {
			if (_selectedLayout) {
				_selectedLayout.unselect();
			}
			_selectedLayout = this;
			this.DOM(this.$.overlay).addClass(STATE.SELECTED);
			this.DOM(this.$.handle).addClass(STATE.SELECTED);
		},

		// To make layout responsive
		resizeChildren: function () {
			// IF not attached then no offset width found
			this.async(function () {
				if (!this.isAttached || this.offsetWidth === 0) {
					return;
				}
				if (this.offsetWidth <= WIDHT.SMALL) {
					this._maxColumnLevel = 1;
				} else if (this.offsetWidth <= WIDHT.MEDIUM) {
					this._maxColumnLevel = 2;
				} else {
					this._maxColumnLevel = 3;
				}
			}.bind(this), 1E2);
		},

		// --------------Hover on handle--------------//
		onHandleMouseLeave: function () {
			this._hover = false;
		},

		onHandleMouseOver: function () {
			if (this._isDesignMode) {
				this._hover = true;
			}
		},

		// --------------Drag on Layout's Handle--------------//
		onLayoutDragStart: function (event) {
			var eventData;
			if (this._isDesignMode) {
				// Set Data and image to drag event
				eventData = {
					dropType: 'MOVE',
					item: {
						name: this.name
					}

				};
				// Keep the drag image a bit low from pointer
				event.dataTransfer.setDragImage && event.dataTransfer.setDragImage(this, 12, 12);
				event.dataTransfer.setData('text', JSON.stringify(eventData));
			}
		},

		// --------------Drop on Layout's Handle--------------//
		onHandleDragEnter: function (event) {
			if (this._isDesignMode && !this._isTopLayout) {
				this._preventDefaultForce(event);
				this.removeDragOver(event);
				_prevDragOver = this.$.main;
				event.dataTransfer.dropEffect = 'move';
				this.$.main.classList.add(STATE.HANDLEDRAGOVER);
			} else {
				event.dataTransfer.dropEffect = 'none';
			}
		},

		onHandleDragOver: function (event) {
			if (this._isDesignMode) {
				this._preventDefaultForce(event);
				if (_prevDragOver !== this.$.main) {
					this.onHandleDragEnter(event);
				}

				// firefox issue with removing is-dragover class on dragLeave from handle of component
				if (navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
					this._lastHovered = (new Date()).getTime();
					this.async(function(){
						if (((new Date).getTime() - this._lastHovered) > 1e2){
							this._removeDropZone(event);
						}
					}.bind(this), 1e2 + 1);
				}
			}
		},

		onHandleDragLeave: function (event) {
			if (this._isDesignMode) {
				this._preventDefaultForce(event);
				this.removeDragOver(event);
			}
		},

		onHandleDrop: function (event) {
			var dragData, parent, droppedElem;
			if (this._isDesignMode) {
				this.removeDragOver(event);
				dragData = JSON.parse(event.dataTransfer.getData('text'));
				if (dragData.dropType === DROPACTION.INSERT) {
					this._insertWidget(event, dragData.item, this.column, dragData.noWrap, true);
					this._preventDefaultForce(event);
				} else if (dragData.dropType === DROPACTION.MOVE) {
					parent = this._getAncestorNode(this);
					droppedElem = parent.querySelector('[name=' + dragData.item.name + ']');
					if (droppedElem && droppedElem !== this && !this._areYouMyAncestor(this, droppedElem)) {
						if (this.isInsertAfter(droppedElem, this)) {
							this.insertAfter(droppedElem);
						} else {
							Polymer.dom(Polymer.dom(this).parentNode).insertBefore(droppedElem, this);
						}
						droppedElem.column = this.column;
						if (droppedElem._clearPrevDragOver) {
							droppedElem._clearPrevDragOver();
						}
					}
					this._preventDefaultForce(event);
				}
			}
		},

		// --------------Drop on Layout's Columns--------------//
		onColumnDragEnter: function (event) {
			if (this._isDesignMode && !this._isTopLayout) {
				this._preventDefaultForce(event);
				if (this.sleepMyDragOver) {
					return;
				}
				this.removeDragOver(event);
				_prevDragOver = event.currentTarget;
				event.dataTransfer.dropEffect = 'move';
				_prevDragOver.classList.add(STATE.COLUMNDRAGOVER);
			} else {
				event.dataTransfer.dropEffect = 'none';
			}
		},

		onColumnDragOver: function (event) {
			if (this._isDesignMode && !this._isTopLayout) {
				this._preventDefaultForce(event);
				if (event.currentTarget !== _prevDragOver && !this.sleepMyDragOver) {
					this.onColumnDragEnter(event);
				}
			}
		},

		onColumnDragLeave: function (event) {
			if (this._isDesignMode && !this._isTopLayout) {
				this._preventDefaultForce(event);
				this.removeDragOver(event);
			}
		},

		onColumnDrop: function (event) {
			var dragData, parent, droppedElem, colnum;
			if (this._isDesignMode) {
				this.removeDragOver(event);
				colnum = 1;
				if (event.target.dataset.column) {
					colnum = Number(event.target.dataset.column);
				} else if (event.target.column) {
					colnum = Number(event.target.column);
				}
				// Get the data
				dragData = JSON.parse(event.dataTransfer.getData('text'));
				// If its an insert
				if (dragData.dropType === DROPACTION.INSERT) {
					this._insertWidget(event, dragData.item, colnum, dragData.noWrap, false);
					this._preventDefaultForce(event);
				} else if (dragData.dropType === DROPACTION.MOVE) {
					parent = this._getAncestorNode(this);
					droppedElem = parent.querySelector('[name=' + dragData.item.name + ']');
					this._addWidget(event, dragData.item.name, colnum);
					this._preventDefaultForce(event);
					if (droppedElem._clearPrevDragOver) {
						droppedElem._clearPrevDragOver();
					}
				}
			}
		},


		// --------------Private Functions--------------//
		removeDragOver: function (event) {
			this.fire(EVENT.ITEM_DRAGREMOVE);
			if (_prevDragOver) {
				_prevDragOver.classList.remove(STATE.HANDLEDRAGOVER);
				_prevDragOver.classList.remove(STATE.COLUMNDRAGOVER);
				_prevDragOver = undefined;
			}
			this.$.main.classList.remove(STATE.HANDLEDRAGOVER);
			event.currentTarget.classList.remove(STATE.COLUMNDRAGOVER);
		},

		_removeDropZone: function(){
			this.$.main.classList.remove(STATE.HANDLEDRAGOVER);
		},

		_collapseInDesignMode: function(){
			if (this._isDesignMode && this.iscollapsible){
				this.collapsedInDesignMode = !this.collapsedInDesignMode;
			}
		},

		_removeDragOver: function () {
			this.$.main.classList.remove(STATE.HANDLEDRAGOVER);
			this.$.column1.classList.remove(STATE.COLUMNDRAGOVER);
			this.$.column2.classList.remove(STATE.COLUMNDRAGOVER);
			this.$.column3.classList.remove(STATE.COLUMNDRAGOVER);
			if (!this.sleepMyDragOver) {
				this.sleepMyDragOver = true;
				this.async(function () {
					this.sleepMyDragOver = false;
				}.bind(this), 1E2);
			} else {
				this.debounce('noDragOver', function () {
					this.sleepMyDragOver = true;
					this.async(function () {
						this.sleepMyDragOver = false;
					}.bind(this), 2E2);
				}.bind(this), 1E2);
			}
		},

		_insertWidget: function (event, tag, columnnumber, noWrap, atThisPosition) {
			var wrapItem, notmalItem;
			if (noWrap) {
				wrapItem = window.document.createElement(tag);
				wrapItem.column = columnnumber;
				if (atThisPosition) {
					Polymer.dom(Polymer.dom(this).parentNode).insertBefore(wrapItem, this);
				} else {
					Polymer.dom(this).appendChild(wrapItem);
				}
			} else {
				notmalItem = window.document.createElement('xs-wg-item');
				notmalItem.column = columnnumber;
				if (atThisPosition) {
					Polymer.dom(Polymer.dom(this).parentNode).insertBefore(notmalItem, this);
				} else {
					Polymer.dom(this).appendChild(notmalItem);
				}
				notmalItem.insertWidget(tag);
			}
		},

		_addWidget: function (event, name, columnnumber) {
			var ancestor = this._getAncestorNode(this);
			var droppedElem = ancestor.querySelector('[name=' + name + ']');
			if (droppedElem && droppedElem.name !== this.name && !this._areYouMyAncestor(this, droppedElem)) {
				droppedElem.column = columnnumber;
				Polymer.dom(this).appendChild(droppedElem);
			}
		},

		// Get Top node for searching of component
		_getAncestorNode: function (item) {
			var hierarchy = this._getUpHierarchy(item);
			if (hierarchy.length > 0) {
				return hierarchy[hierarchy.length - 1];
			}
			return undefined;
		},

		insertAfter: function (item) {
			var parent = Polymer.dom(this).parentNode;
			// Improve and generalize this condition
			if (this.nextSibling && this.nextSibling.tagName && (this.nextSibling.tagName.toLowerCase() === 'xs-wg-item' || this.nextSibling.tagName.toLowerCase() === 'xs-wg-layout' || this.nextSibling.tagName.toLowerCase() === 'xs-wg-section')) { // jshint ignore:line
				Polymer.dom(Polymer.dom(this).parentNode).insertBefore(item, this.nextSibling);
			} else {
				Polymer.dom(parent).appendChild(item);
			}
		},

		// Need to decide we need to insert before or after
		isInsertAfter: function (item, refItem) {
			if ((Polymer.dom(item).parentNode === Polymer.dom(refItem).parentNode) && (item.column === refItem.column) && (refItem.offsetTop > item.offsetTop)) {
				return true;
			}
			return false;
		},

		_preventDefaultForce: function (event) {
			event.preventDefault();
			event.stopPropagation();
		},


		// --------------Compute class based on attributes--------------//
		_computeDraggable: function (designmode, disabled) {
			if (designmode && !disabled) {
				return true;
			}
			return false;
		},

		_computeMainClass: function (label, isDesignMode, _isTopLayout, hidden) {
			// Hide complete layout in case its not in design mode, no label, not collapsible and even no children
			if (hidden && !isDesignMode) {
				return 'no-display';
			}
			if (_isTopLayout) {
				return 'layout_main_container';
			}
			return 'layout_container';
		},

		_computeHandleClass: function (label, isDesignMode, _isTopLayout) {
			// Hide top handle in case its not in design mode, no label, not collapsible
			// OR if its the top bar
			if (_isTopLayout) {
				return 'no-display';
			}
			return 'designer-handle ';
		},

		_computeClassBody: function (iscollapsible, collapsed, designMode, collapsedInDesignMode, _isTopLayout) {
			if (designMode && collapsedInDesignMode){
				return 'no-display';
			} else if (iscollapsible && collapsed && !designMode) {
				return 'no-display';
			} else if (_isTopLayout) {
				return 'layout-main-body layout-body';
			}
			return 'layout-body';
		},

		_computeClassColumn1: function (vertical, _maxColumnLevel, _isTopLayout) {
			if (this.vertical === 3 && this._maxColumnLevel === 3) {
				return 'one-third-width right-dashed-border';
			} else if (this.vertical !== 1 && this._maxColumnLevel !== 1) {
				return 'one-half-width right-dashed-border';
			} else if (_isTopLayout) {
				return 'full-width no-min-height';
			}
			return 'full-width';
		},

		_computeClassColumn2: function (vertical, _maxColumnLevel) {
			if (vertical === 3 && _maxColumnLevel === 3) {
				return 'one-third-width';
			} else if (vertical !== 1 && _maxColumnLevel !== 1) {
				return 'one-half-width';
			} else if (vertical > _maxColumnLevel) {
				return 'full-width top-dashed-border';
			}
			return 'full-width no-min-height';
		},

		_computeClassColumn3: function (vertical, _maxColumnLevel) {
			if (vertical === 3 && _maxColumnLevel === 3) {
				return 'one-third-width left-dashed-border';
			} else if (vertical === 3) {
				return 'full-width top-dashed-border';
			}
			return 'full-width no-min-height';
		},

		_computeDeleteClass: function (_hover, disabled) {
			if (!_hover || disabled) {
				return 'no-display';
			}
			return 'remove fonticon fonticon-trash ';
		},

		_computeCollapseIconClass: function (collapsed, designMode, collapsedInDesignMode) {
			if (designMode && collapsedInDesignMode){
				return 'fonticon xs-wg-collapse-icon is-collapsed';
			} else if (collapsed && !designMode){
				return 'fonticon xs-wg-collapse-icon is-collapsed';
			} else {
				return 'fonticon xs-wg-collapse-icon';
			}
		},

		_computeCollapseContainerClass: function (iscollapsible) {
			return iscollapsible ? 'xs-wg-collapse-icon-container' : 'no-display';
		}
	});
}(this));
