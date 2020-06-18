/*--------------------------------------------------------------------
[xs-canvas Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:45:58 GMT
Assigned to:	Aravind Mohan
Description:    Paints the layout.
---------------------------------------------------------------------*/
/**
	@module SMAProcXSUI

	@example
		TODO: Provide example on how to use this element
*/
/* global DS, Polymer*/

(function (window) {
	'use strict';

	var CanvasAdapter, NotBindedInfoList = [], associationBrokenItems =[], mutationObserver, // Constants
		totalXsWgItemsAttached=0, itemListlength=0, //global variables
		DEFAULT_LAYOUT, LAYOUT_WRAPPER, WG_ITEM_TAG, LAST_LAYOUT_QUERY, WG_PATH, EVENT, // Enums
		STATE, DROP_ACTION, DRAG_DATA_TYPE;
	STATE = {
		OVER: 'is-over',
		VISIBLE: 'is-visible'
	};
	DROP_ACTION = {
		INSERT: 'INSERT',
		MOVE: 'MOVE'
	};
	DRAG_DATA_TYPE = {
		TEXT: 'text',
		URL: 'URL'
	};
	EVENT = {
		CANVAS_READY: 'canvasready'
	};
	// Initialize
	WG_ITEM_TAG = 'xs-wg-item';
	LAST_LAYOUT_QUERY = 'xs-wg-layout';
	LAYOUT_WRAPPER = '<template id="autobind" is="dom-bind"><div id="view">{layout}</div></template>';
	WG_PATH = '../../SMAProcXSWidgets/{tag}/{tag}.html';
	DEFAULT_LAYOUT = '<xs-wg-page id="wg_page_1" index="0" name="page1">' + '<xs-wg-layout vertical="1" name="layout_1">' + '</xs-wg-layout>' + '</xs-wg-page>';
	CanvasAdapter = (function () {
		var CanvasAdapter = {};

		/**
		 *
		 *
		 * @param {xs-canvas} canvas xs-canvas instance
		 * @param {HTMLElement} widget xs-wg-* instance
		 */
		function setFocusOnUI(canvas, widget) {
			var elem;
			try {
				elem = widget.parentElement;
				// Call the click event on the element
				// Bring the UI element to view
				if (navigator.appVersion.indexOf('Trident/') > 0) {
					/* Microsoft Internet Explorer detected in. */
					canvas.fire('scrollintoview', { item: elem });
				 } else {
					elem.scrollIntoView(false);
				 }
				// If its in design mode focus the item
				if (canvas.isInDesignMode()) {
					// Show it as selected
					elem.click();
				} else {
					widget.fire('xsWgLayoutExpand');
					widget.focus();
				}
			} catch (ex) {
				console.warn(ex.message); // jshint ignore:line
				console.trace(this); // jshint ignore:line
			}
		}
		/**
		 *
		 *
		 * @param {xs-canvas} canvas xs-canvas instance
		 * @param {HTMLElement} widget xs-wg-* instance
		 * @returns {HTMLElement} widget which can be focuses
		 */
		function getFocusableWidget(canvas, widget) {
			var elem;
			// If the UI element is no more in the DOM
			if (!canvas.$.template.contains(widget)) {
				widget = null;
			}
			// Get whether the widget is a UI element
			// It is assumed that all UI element will be wrapped by a xs-wg-item
			// If its a plmdata instance and not a ui element get the first matching
			// bounded element
			if (widget && Polymer.dom(widget).parentNode.tagName.toLowerCase() !== 'xs-wg-item') {
				var expr;
				// Build the expression to find the association
				expr = canvas.extract().match(new RegExp('\\w*="{{' + widget.id + '}}"'))[0];
				// Get the first matching association
				elem = canvas.DOM(canvas.$.template).find('[' + expr + ']').elements()[0];
			}
			// If the widget is the actual element
			if (!elem) {
				elem = widget;
			} else if (Polymer.dom(elem).parentNode.tagName.toLowerCase() === 'xs-wg-item') {
				// If the associated elment was not yet found
				elem = null;
			}
			return elem;
		}
		CanvasAdapter.onSetError = function (error) {
			var canvas = CanvasAdapter._instance,
				focusableWidget;
			// Get a focussable widget
			focusableWidget = getFocusableWidget(canvas, this.widget);
			if (focusableWidget) {
				// If the error is forced or focussable widget is the same as the callee
				if (focusableWidget.id === this.widget.id) {
					error.force = true;
				}
				// On user action
				error.focus = function () {
					setFocusOnUI(canvas, focusableWidget);
				};
				// Create a new info item
				this._infoItem = canvas.$.info.createInfoItem(focusableWidget.id, error);
			}
		};
		CanvasAdapter.isInDesignMode = function () {
			return CanvasAdapter._instance.isInDesignMode();
		};
		CanvasAdapter.whichMode = function () {
			return CanvasAdapter._instance.whichMode();
		};
		CanvasAdapter.onClearError = function () {
			// Clear the error from the UI
			if (this._infoItem) {
				CanvasAdapter._instance.$.info.clear(this._infoItem.id);
				this._infoItem = null;
			}
		};
		CanvasAdapter.notify = function (msgData) {
			CanvasAdapter._instance.$.notification.logMessage(msgData);
		};
		CanvasAdapter.isDisabled = function () {
			return CanvasAdapter._instance.disabled;
		};

		return CanvasAdapter;
	})();
	// Prototype
	window.XSCanvas = window.Polymer({
		is: 'xs-canvas',
		properties: {
			/**
			All the date related to the simulation process the view needs to be bound to

			@attribute data
			@type Object
			@default null
            **/
			_data: {
				type: Object
			},
			state: {
				type: String,
				notify: true,
				observer: '_showMessage'
			},
			/**
			Ignores the data changes made and wont propage those changes to the server

			@attribute ignoredatachange
			@type Boolean
			@default false
            **/
			ignoredatachange: {
				type: Boolean,
				value: false,
				notify: true
			},
			meta: {
				notify: true,
				observer: 'metaChanged'
			},
			// Attributes
			/**
			Unique id(Physical id) os the simulation process the view needs to be bound to

			@attribute uid
			@type String
			@default null
            **/
			uid: {
				notify: true,
				observer: 'uidChanged'
			},
			_draggedOverItem: {
				type: Object
			},
			_insertAfter: {
				type: Boolean,
				value: false
			},
			mode: {
				type: String
			},

			disabled: {
				type: Boolean,
				value: false,
				notify: true
			}
		},
		observers: [

		],
		// Readonly
		get view() {
			return this.DOM(this.$.template).find('#view').elements()[0];
		},
		set view(value) {
			throw new Error('This is a readonly property' + value);
		},
		// Lifecycle methods
		ready: function () {
			// Set the interface
			CanvasAdapter._instance = this;
			this.$.wginterface.define(CanvasAdapter);
			this.addEventListener('associationBroken', this._checkAssociation, true);
			this.addEventListener('associationChanged', this._refreshBrokenAssociation, true);
		},

		_refreshBrokenAssociation: function(event){
			var index;
			for (var i=0;i<associationBrokenItems.length;i++){
				if (associationBrokenItems[i].id===event.detail.id){
					index=i;
				}
			}
			if (index){
				associationBrokenItems.splice(index, 1);
			} else if (index===0){
				associationBrokenItems=[];
			}
			event.stopPropagation();
		},

		metaChanged: function () {
			this.onTemplateBound();
		},
		// Private methods

		//check which association is broken
		_checkAssociation: function(event){
			var flag=false;
			var arrayLength=associationBrokenItems.length;
			// Below statement is changed as event.srcElemet is not supported in firefox which caused this IR-633592-3DEXPERIENCER2019x
			var eventElement = event.srcElement || event.target;
			for (var i=0;i<arrayLength;i++){
				if (associationBrokenItems[i].id!==eventElement.id){
					flag=true;
				}
			}
			if (arrayLength===0){
				associationBrokenItems.push(eventElement);
			} else if (flag){
				associationBrokenItems.push(eventElement);
			}
			event.stopPropagation();
		},

		// asynchronously inserts the widget
		// Needs to be called on xs-canvas context (this = xs-canvas)
		_insertWidgetAsync: function (tag, noWrap, addAtLast, addAtTop) {
			var updpnl = this.$.updpnl,
				lastItem;
			// Show that the progress started
			updpnl.update();
			if (!addAtLast && !addAtTop) {
				lastItem = Polymer.dom(this.$.template).querySelector('[name="' + this._draggedOverItem + '"]');
			}

			// Doing this async inorder to ensure handle on layout if default layout was inserted
			// Push it to the end of event queue using requestanimationframe
			this.async(function () {
				var item;
				// Create the item widget and insert it as the last item in the view
				lastItem = lastItem || this.DOM(this).find(LAST_LAYOUT_QUERY + ':first-child').elements()[0] || this.DOM(this).find(LAST_LAYOUT_QUERY).elements()[0];

				if (noWrap) {
					item = window.document.createElement(tag);
					item.column = lastItem ? lastItem.column : 1;
					this._placeDraggedItem(item, lastItem, addAtTop);
					this.async(function () {
						if (item.scrollIntoViewIfNeeded) {
							item.scrollIntoViewIfNeeded();
						} else {
							if (navigator.appVersion.indexOf('Trident/') > 0) {
								/* Microsoft Internet Explorer detected in. */
								this.fire('scrollintoview', { item: item });
								 } else {
								item.scrollIntoView(false);
								 }
						}
					});
					updpnl.done();
				} else {
					item = window.document.createElement(WG_ITEM_TAG);
					// If there is an item present inside the layout insert it as the last item else
					// inserts it as the only item inside the layout
					item.column = lastItem ? lastItem.column : 1;
					this._placeDraggedItem(item, lastItem, addAtTop);
					item.insertWidget && item.insertWidget(tag, function (error) {
						// Stop showing the progress
						updpnl.done();
						if (error && error.length > 0){
							this.$.notification.logMessage({
								type: 'error',
								text: error
							});
						}
					}.bind(this));
				}


				this._refreshEmptyTextVisibility();
			}.
				bind(this), 1E2);
		},
		_import: function (urls, callback) {
			var url = urls.pop();
			// If there were no urls to be imported
			if (!url) {
				callback();
				return;
			}
			url = this.resolveUrl(url);
			window.Polymer.Base.importHref(url, function () {
				// Check if there are urls still left
				if (urls.length) {
					this._import(urls, callback);
				} else {
					callback();
				}
			}.
				bind(this));
		},
		// Imports the required dependency and brushes the layout onto the canvas
		// callback is optional
		_brush: function (layout, callback) {
			var urls = [], that=this;
			// If there are widgets present in the layout
			if (layout) {
				layout.match(/<\/[\w,\-]*>/g).forEach(function (element) { // jshint ignore:line
					var url = WG_PATH.replace(/\{tag\}/g, element.replace(/<\//, '').replace(/>/, ''));
					// If the url is not already added to the list
					if (urls.indexOf(url) === -1) {
						urls.push(url);
					}
				});
			}
			this._import(urls, function () {
				//For migration related issues
				var tempLayout=LAYOUT_WRAPPER.replace('{layout}', layout || '');
				var domParser = new DOMParser();
				var parsedData = domParser.parseFromString(tempLayout, 'text/html');

				//get the list of xs-wg-items in the view
				var itemList = parsedData.querySelectorAll('template')[0].content ? parsedData.querySelectorAll('template')[0].content.querySelectorAll('xs-wg-item') : undefined;
				//IE11 fails to get data from above line. Following line is first step to get data in IE11
				var testString = parsedData.querySelectorAll('template')[0];
				//If it is not IE11, we will have data in itemList. If itemList is undefined, try getting data from testString.
				itemList = (itemList === undefined) ? testString.querySelectorAll('xs-wg-item') : itemList;
				if (itemList &&  itemList.length > 0 && !itemList[0].hasAttribute('column')){ // if column attribute is not availble, then it is migrated template
					itemListlength = itemList.length;
					if (itemListlength > 0){
						that.addEventListener('xs-wg-item-attached', that._callWhenItemAttached, true);
					} else {
						that.addEventListener('xs-wg-page-attached', that.onTemplateBound, true);
					}
				} else { //normal way
					that.addEventListener('xs-wg-page-attached', that.onTemplateBound, true);
				}

				// Later use polymer's injectBoundHTML API. This would avoid the use of autobinding
				Polymer.dom(this.$.template).innerHTML = LAYOUT_WRAPPER.replace('{layout}', layout || '');
				// If a callback has been set
				this.async(function () {
					if (callback) {
						callback();
					}
					// Refresh the empty canvas text
					this._refreshEmptyTextVisibility();
				}.bind(this), 10);
			}.bind(this));
		},

		/**
		 * TO keep check on number of xs-wg-item components attached
		 */
		_callWhenItemAttached: function () {
			//attach a new event listener, remove previous & increase count for total xs-wg-items attached
			this.addEventListener('xs-wg-item-attached', function onAttached() {
				totalXsWgItemsAttached++;
				if (totalXsWgItemsAttached === itemListlength){
					totalXsWgItemsAttached=0;
					itemListlength=0;
					this.onTemplateBound();
				}
				this.removeEventListener('xs-wg-item-attached', onAttached);
			});
		},

		// Refreshes the visibility of canvas empty text based on changes in the layout
		// Needs xs-canvas context (this = xs-canvas)
		_refreshEmptyTextVisibility: function () {
			// Polup: TODO
			// Push it to the end of event queue using requestanimationframe
			this.async(function () {
				var layout = this.extract(),
					emptytext = this.DOM(this.$.emptytext);
					// If the layout doesnt even have one ui element
				if (layout === '' || (!layout.match(/xs-wg-item/g) && !layout.match(/xs-wg-section/g) && (layout.match(/xs-wg-layout/g) || []).length === 2)) {
					emptytext.addClass(STATE.VISIBLE);
				} else {
					emptytext.removeClass(STATE.VISIBLE);
				}
			}.
				bind(this));
		},
		// Public methods
		// optional callback
		paint: function (layout, callback) {
			// Show that the progress started
			this.$.updpnl.update();
			// If layout is empty, short circuit and display Empty canvas placeholder message
			if (!layout) {
				this._brush(layout, function () {
					this.fire(EVENT.CANVAS_READY, {});
					this.$.updpnl.done();
					callback && callback();
				}.
					bind(this));
				return;
			}
			// If data is already available
			if (this._data) {
				this._brush(layout, function(){
					this.fire(EVENT.CANVAS_READY, {});
					callback && callback();
				}.bind(this));
			} else {
				// Wait till the plm data is available
				this.$.wgplmdata.getPLMData(function (plmData) {
					this._data = {
						iosummaryview: plmData.getSource(plmData.SOURCE.IOSUMMARYVIEW),
						executionoptions: plmData.getSource(plmData.SOURCE.EXECUTIONOPTIONS),
						simulation: plmData.getSource(plmData.SOURCE.SIMULATION)
					};
					// Brush the layout onto the canvas
					this._brush(layout, function () {
						// Make the UI element's visible
						this.DOM(this.$.template).addClass(STATE.VISIBLE);
						// Useful only on first time load
						// Eg. Designer can use this to make build/test button and save changes visible
						// Trigger the event that canvas is ready
						// This is to ensure that required data is availble for the canvas
						// before working on it
						this.fire(EVENT.CANVAS_READY, {});
						callback && callback();
					}.
						bind(this));
				}, this);
			}
		},
		repaint: function (callback) {
			var layout = this.extract();
			this.paint(layout, callback);
		},
		// Clears all the changes which happened to the data
		clearDataChanges: function () {
			this.$.wgplmdata.restore();
		},
		insertWidget: function (tag, noWrap, addAtLast) {
			// If there is an existing layout
			if (Polymer.dom(this.DOM(this).find('#view').elements()[0]).innerHTML) {
				// Asynchronously insert the widget
				this._insertWidgetAsync(tag, noWrap, addAtLast);
			} else {
				// Paint the default layout and then insert the widget
				this.paint(DEFAULT_LAYOUT, this._insertWidgetAsync.bind(this, tag, noWrap));
			}
		},

		insertWidgetAutoCreate: function(tag, noWrap, addAtLast, association){
			if (Polymer.dom(this.DOM(this).find('#view').elements()[0]).innerHTML) {
				this._insertWidgetAutoCreateAsync(tag, noWrap, addAtLast, association);
			} else {
				this.paint(DEFAULT_LAYOUT, this._insertWidgetAutoCreateAsync.bind(this, tag, noWrap, addAtLast, association));
			}
		},

		_insertWidgetAutoCreateAsync: function(tag, noWrap, addAtLast, association){
			var item, lastItem, updpnl = this.$.updpnl;
			item = window.document.createElement(WG_ITEM_TAG);
			lastItem = lastItem || this.DOM(this).find(LAST_LAYOUT_QUERY + ':first-child').elements()[0] || this.DOM(this).find(LAST_LAYOUT_QUERY).elements()[0];
			// If there is an item present inside the layout insert it as the last item else
			// inserts it as the only item inside the layout
			item.column = lastItem ? lastItem.column : 1;
			if (noWrap) {
				item = window.document.createElement(tag);
				item.column = lastItem ? lastItem.column : 1;
				this._placeDraggedItem(item, lastItem, !addAtLast);
				this.async(function () {
					if (item.scrollIntoViewIfNeeded) {
						item.scrollIntoViewIfNeeded();
					} else {
						if (navigator.appVersion.indexOf('Trident/') > 0) {
							/* Microsoft Internet Explorer detected in. */
							this.fire('scrollintoview', { item: item });
							 } else {
							item.scrollIntoView(false);
							 }
					}
				});
				updpnl.done();
			} else {
				item = window.document.createElement(WG_ITEM_TAG);
				// If there is an item present inside the layout insert it as the last item else
				// inserts it as the only item inside the layout
				item.column = lastItem ? lastItem.column : 1;
				this._placeDraggedItem(item, lastItem, !addAtLast);
				item.insertWidget && item.insertWidget(tag, function () {
					// Stop showing the progress
					updpnl.done();
					item.associate('value', association);
				});
			}
		},

		insertWidgetAtTop: function (tag, noWrap, addAtTop) {
			// If there is an existing layout
			if (Polymer.dom(this.DOM(this).find('#view').elements()[0]).innerHTML) {
				// Asynchronously insert the widget
				this._insertWidgetAsync(tag, noWrap, false, addAtTop);
			} else {
				// Paint the default layout and then insert the widget
				this.paint(DEFAULT_LAYOUT, this._insertWidgetAsync.bind(this, tag, noWrap));
			}
		},

		// Returns the layout definition as a text
		extract: function () {
			var view, layout = '', nodes = Polymer.dom(this.$.template).childNodes;
			// Relay the layout
			this.$.binder.relayLayoutBindings(this.view);
			view = Polymer.dom(this.root).querySelector('#view') || nodes[0];
			if (view) {
				layout = Polymer.dom(view).innerHTML;
			}
			// remove the class information from the layout before returning
			return layout.replace(/^<div id="view">|<\/div>$/g, '').replace(/class="[a-zA-Z0-9:;\.\s\(\)\-\,]*"/g, ''); // jshint ignore:line
		},
		// Returns true if the canvas has any errors
		hasErrors: function () {
			return this.$.info.hasNonMandErrors();
		},
		hasMandErrors: function () {
			return this.$.info.hasMandErrors();
		},
		// Shows the summary dialog
		showSummary: function () {
			this.$.info.showSummary();
		},
		isInDesignMode: function () {
			return Polymer.dom(this).classList.contains('design');
		},
		whichMode: function () {
			var canvasMode = Polymer.dom(this).classList;
			var mode = canvasMode.contains('design') ? 'design' : canvasMode.contains('preview') ? 'preview' : '';
			if (mode === '' && this.mode !== undefined && this.mode.length > 0) {
				return this.mode;
			} else if (mode && mode.length > 0) {
				return mode;
			}
			return 'run';
		},

		attached: function () {

			var template = Polymer.dom(this.root).querySelector('#template');
			template.addEventListener('dragstart', this._onDragStart.bind(this), true);
		},

		detached: function(){
			 this.removeMutationObserver();
			 NotBindedInfoList = [];
		 },

		// Event handlers
		_onDragStart: function (event) {
			// If its not in design mode dont allow drag
			if (!this.isInDesignMode()) { // event.preventDefault();
				// event.stopPropagation();
			} else {
				this._draggedItem = Polymer.dom(event).localTarget;
			}
		},
		onDragOver: function (event) {
			var target = event.target,
				name = target.dataset.name;
			if (this.isInDesignMode()) {
				if ((!this._draggedItem || this._draggedItem.name !== name) && event.target.dataset.name) {
					if (event.offsetY > event.target.offsetHeight / 2) {
						this._insertAfter = true;
					} else {
						this._insertAfter = false;
					}
				}
				// If its an item
				if (name) {
					this._draggedOverItem = name;
				}
				event.preventDefault();
			}
		},
		onDragLeave: function (event) {
			// If its out of canvas bound
			if (this.isInDesignMode()) {
				if (!Polymer.dom(event).rootTarget.dataset.name) {
					this._removeDragOver();
				}
				event.preventDefault();
			}
		},
		onDrop: function (event) {
			var dragLocation, dragData, srcElems;
			try {
				if (this.isInDesignMode()) {
					event.preventDefault();
					//get the target location
					dragLocation = event.target;
					// Get the data
					dragData = JSON.parse(event.dataTransfer.getData(DRAG_DATA_TYPE.TEXT));
					// If its an insert
					if (dragData.dropType === DROP_ACTION.INSERT) {
						//check where to inserts
						if (dragLocation.className.contains('savedmessage')){
							//insert widget at the topLayout
							this.insertWidgetAtTop(dragData.item, dragData.noWrap, true);
						} else {
							// Insert a widget at the end
							this.insertWidget(dragData.item, dragData.noWrap, true);
						}
						// Remove the drag style
						this._removeDragOver();
					} else if (dragData.dropType === DROP_ACTION.MOVE) {
						// Move Widget on top of this item
						srcElems = Polymer.dom(this.DOM(this).find(LAST_LAYOUT_QUERY).elements()[0]).querySelectorAll('[name=' + dragData.item.name + ']');
						var topLayout = this.DOM(this).find(LAST_LAYOUT_QUERY + ':first-child').elements()[0] || this.DOM(this).find(LAST_LAYOUT_QUERY).elements()[0];
						// Reset column to 1 in case it is dropped on canvas
						srcElems[0].column = 1;
						Polymer.dom(topLayout).appendChild(srcElems[0]);
						this._removeDragOver();
					}

					window.setTimeout(this._showSelection.bind(this), 500);
				}
			} catch (ex) {
				console.warn(ex);
			}
			// Not stopping propagation because a top level container may need to listen to drop event for other purposes than move or insert
			// Ex: In dashboard, a new experience can be dropped on the canvas. This needs to be captured by the dropzone container
			// event.stopPropagation();
		},
		_removeDragOver: function () {
			if (this.isInDesignMode()) {
				Polymer.dom(this.$.template).querySelectorAll('.is-dragover').forEach(function (item) {
					Polymer.dom(item).classList.remove('is-dragover');
				});
			}
		},
		_placeDraggedItem: function (item, refItem, addAtTop) {
			var parent, tempNode;
			if (addAtTop){
				if (refItem.is === 'xs-wg-layout'){
					tempNode=Polymer.dom(refItem).childNodes[0];
					Polymer.dom(refItem).insertBefore(item, tempNode);
				}
			} else if (refItem) {
				// Get the parent layout
				parent = Polymer.dom(refItem).parentNode;
				// If its a toolclick add it to the end of the layout
				// If the last item is a layout
				if (refItem.is === 'xs-wg-layout' || refItem.is === 'xs-wg-section') {
					Polymer.dom(refItem).appendChild(item);
				} else if (this._insertAfter) {
					refItem = Polymer.dom(refItem).nextSibling;
					//If there is a sibling item then insert before that
					if (!refItem) {
						Polymer.dom(parent).insertBefore(item, refItem);
					} else {
						Polymer.dom(parent).appendChild(item);
					}
					//Clear the flag
					this._insertAfter = false;
				} else {
					Polymer.dom(parent).insertBefore(item, refItem);
				}
			}
		},

		onItemAssociate: function (event) {
			// Remove the current association if any
			this.$.binder.disassociate(this.view, event.detail);
			// Do new the association
			this.async(function () {
				this.$.binder.associate(this.view, event.detail);
				this.clearDataChanges();
				// Refresh
				this.validate();
				// Preserve the selection to select it back after the repaint
				this._selectedItem = event.detail.widget.id;
				this.repaint();
			}.bind(this), 1E1);
		},
		onItemDisassociate: function (event) {
			// Nullify the widget property
			// NOTES:
			// What would happen if a widget has a default set ?
			// Does it expect to get back default? - Maybe it shud handle by attribute change
			// watcher
			// widget[args.prop] = null;
			this.$.binder.disassociate(this.view, event.detail);
			// Refresh
			this.validate();
			// Preserve the selection to select it back after the repaint
			this._selectedItem = event.detail.widget.id;
			this.repaint();
		},
		// When a widget item gets removed
		onItemRemove: function (event) {
			try {
				var widget = event.detail.widget;
				// Clear the preserved selected item if the removed widget is the preserved item
				if (widget.id === this._selectedItem) {
					this._selectedItem = null;
				}
				// Clear the bindings if any present on this widget
				this.$.binder.clearBindings(this.view, widget);
				// Refresh the empty canvas text
				this._refreshEmptyTextVisibility();
				// Revalidate the experience
				this.debounce('repaint', function () {
					this.validate();
					this.repaint();
				}.bind(this), 2E2);
			} catch (ex) {
				// TODO warn
				window.console.warn(ex);
			}
		},
		/**
		 * Event handler that responds to click in the view
		 * This is to check if any wg-item was selected
		 * @param {custom} event - Custom event dispatched by xs-wg-item on click
		 */
		onItemSelect: function (event) {
			var sItem, data, dataRawValue;
			// If it's not in a design mode do nothing
			if (!this.isInDesignMode()) {
				return;
			}
			sItem = event.detail;
			sItem.meta = JSON.parse(JSON.stringify(this.meta[sItem.widget.tagName.toLowerCase()]));
			// Attach meta data to each item that helps Property inspector display properties
			sItem.propmeta = {};
			sItem.meta.props.forEach(function (prop) {
				// Reset for each iteration
				sItem.propmeta[prop.name] = {};
				// Check if the property is bound to a PLM data instance
				sItem.propmeta[prop.name].isAssociated = this.$.binder.checkForBinding(sItem.widget, prop.name);
				// Check if the property is driven by rule
				sItem.propmeta[prop.name].isRuleDriven = this.$.binder.checkForRules(sItem, prop.name);
				// If it is associated, make sure it's valid
				if (sItem.propmeta[prop.name].isAssociated) {
					data = this.$.binder.getBoundData(this.view, sItem.widget, prop.name);
					dataRawValue = data ? data.getRawValue() : null;
					if (dataRawValue) {
						sItem.propmeta[prop.name].isAssociationValid = true;
						sItem.propmeta[prop.name].displayTitle = dataRawValue.title_display || dataRawValue.title; // jshint ignore:line
					}
				}
			}.
				bind(this));

			// Remove the selection from previous item
			if (this._selectedItem) {
				var item = this.DOM(this).find('[name="' + this._selectedItem + '"]').elements()[0];
				item && item.unselect && item.unselect();
			}
			// Preserve the selection
			this._selectedItem = sItem.widget.id;

			// Ask wg-item to set itself as selected
			sItem.select && sItem.select();
		},

		/**
         * Public method that returns list of xs-wg-item which are not binded with plm data
         * @returns {Array} Collection of Objects having information like item name, property and label if available
         */
		getUnAssociatedItemList: function () {
			var noBindItems = [];
			var view = Polymer.dom(this.DOM(this).find('#view').elements()[0]);
			// Loop over all the meta objects
			Object.keys(this.meta).forEach(function (tagName) {
				var validAssociateProps = [];
				// get list of props which can be associated with PLM data
				this.meta[tagName].props.forEach(function (prop) {
					if (prop.associates) {
						validAssociateProps.push(prop);
					}
				});
				// to skip items like xs-wg-layout and xs-wg-heading
				if (validAssociateProps.length > 0) {
					// Find all items for a given tag name
					[].forEach.call(view.querySelectorAll(tagName), function (item) {
						// Loop over all the properties which can be associated
						validAssociateProps.forEach(function (prop) {
							// Check that given property can be associated or not
							if (!this.$.binder.checkForBinding(item, prop.name)) {
								// If it can be binded but no binding available
								var parentNode = Polymer.dom(item).parentNode;
								noBindItems.push({
									id: parentNode.name + 'noBind' + prop.name,
									item: parentNode,
									title: item.label ? item.label : parentNode.name,
									description: prop.caption + ' not associated with any data. Use the Properties panel to associate the value with data.',
									type: 'warning',
									focus: function () {
										var xsWgItem = this.querySelector('xs-wg-item[name' + '=' + parentNode.name + ']');
										if (xsWgItem) {
											xsWgItem.click();
											if (navigator.appVersion.indexOf('Trident/') > 0) {
												/* Microsoft Internet Explorer detected in. */
												this.fire('scrollintoview', { item: xsWgItem });
											 } else {
												xsWgItem.scrollIntoView(false);
											 }
										}
									}.bind(this)
								});
							}
						}.bind(this));
					}.bind(this));
				}
			}.bind(this));

			// to add items with broken associations
			if (associationBrokenItems.length>0) {
				// Find all items
				associationBrokenItems.forEach(function (item) {
					var parentNode = Polymer.dom(item).parentNode;
					var tempList =[];
					noBindItems.forEach(function(nonbindedItem){
						tempList.push(nonbindedItem.id);
					});
					if (tempList.indexOf(item.id+'noBindvalue')===-1){
						noBindItems.push({
							id: item.id + 'brokenBind',
							item: parentNode,
							title: item.id,
							description: item.id + ' association broken.',
							type: 'error',
							focus: function () {
								var xsWgItem = this.querySelector('xs-wg-item[name' + '=' + parentNode.name + ']');
								if (xsWgItem) {
									xsWgItem.click();
									if (navigator.appVersion.indexOf('Trident/') > 0) {
										/* Microsoft Internet Explorer detected in. */
										this.fire('scrollintoview', { item: xsWgItem });
											 } else {
										xsWgItem.scrollIntoView(false);
											 }
								}
							}.bind(this)
						});
					}
				}.bind(this));
			}
			return noBindItems;
		},

		/**
		 * Public method to add items to info, cache them and clear them before next addition
		 * @param  {Array} infoList list of items to be added into info list
		 */
		addUnAssociatedListToInfo: function (infoList) {
			// If something already exist then remove it first
			if (NotBindedInfoList !== undefined && NotBindedInfoList.length > 0) {
				NotBindedInfoList.forEach(function (oldInfo) {
					this.$.info.clear(oldInfo.id);
				}.bind(this));
			}

			if (associationBrokenItems.length>0){
				associationBrokenItems.forEach(function(oldInfo){
					this.$.info.clear(oldInfo.id);
				}.bind(this));
			}

			NotBindedInfoList = infoList;
			// Add all info items to list
			if (NotBindedInfoList !== undefined && NotBindedInfoList.length > 0) {
				NotBindedInfoList.forEach(function (newInfo) {
					this.$.info.createInfoItem(newInfo.id, newInfo);
				}.bind(this));
			}
		},

		_onPLMDataChange: function (event) {
			//if the data should be saved
			if (!this.ignoredatachange){
				// if there are any errors including Mand Errors
				if (this.hasErrors() || this.hasMandErrors()) {
					// Stop triggering any updates
					event.preventDefault();
					this._refreshState();
					//if (this.whichMode() !== 'preview' && this.whichMode() !== 'design') {
					this.$.notification.lastMessageId = this.$.notification.logMessage({
						type: 'error',
						text: 'Please correct the errors.',
						autoRemove: true
					}, this.$.notification.lastMessageId);
					this.state='is-saved';
					//}
				} else {//the data should not be saved, then do not show any notification (preview mode)
					// Refresh the data state
					this.state = 'is-updating';
				}
			}  else {
				//stop the save
				event.preventDefault();
				// Refresh the data state
				this._refreshState();
			}
			event.stopPropagation();
		},

		_onCOSDataChange: function(event) {
			if (event.detail.type === 'updatebinding' && this.view){
				//stop the save
				event.preventDefault();
				this.$.binder.executeBinding(this.view, this.meta, event.detail.items);
			}
		},

		_refreshState: function () {
			this.state = this._data.iosummaryview.$state || this._data.executionoptions.$state || this._data.simulation.$state;
		},
		_onPLMDataSave: function (event) {
			// If the data should not be saved
			if (this.ignoredatachange) {
				// Stop the save
				event.preventDefault();
				// Refresh the data state
				this._refreshState();
			} else if (this.hasErrors()) {
				// If the data was supposed to be saved but it has errors
				// Stop the save
				event.preventDefault();
				// Show error notification
				this.$.notification.logMessage({
					type: 'error',
					text: 'Unable to save changes. Please correct the errors.',
					autoRemove: true
				});
				// Refresh the data state
				this.state = 'is-failing';
			}
		},
		// this.showSummary();
		// event.stopPropagation();
		_onPLMDataSuccess: function () {
			//Refresh the data state
			this.state = 'is-saved';
			this.$.notification.removeAllMessages();
			// Refresh the data state
			//            this._refreshState();
		},

		_onPLMDataError: function (event) {
			this.$.notification.logMessage({
				type: 'error',
				text: 'Unable to save changes\n' + event.detail
			});
			// Refresh the data state
			this.state = 'is-error';
			// Refresh the data state
			//            this._refreshState();
		},

		_onDataRefresh: function(event) {
			event.stopPropagation();
			this.reloadPLMData(event.detail.type, true);
		},

		//For showing notification to use in non-obstrusive way in sticky position
		_showMessage: function (newValue, oldValue) {
			if (!this.hasErrors() && !this.hasMandErrors()){
				if (oldValue==='is-updating' && newValue==='is-saved'){
					this._savedMessage='All changes saved';
				} else if (newValue==='is-updating'){
					this._savedMessage='Saving changes...';
				} else if (newValue==='' || newValue==='is-error') {
					this._savedMessage='';
				} else {
					this._savedMessage='';
				}
			} else {
				this._savedMessage='';
			}
		},

		// Life cycle events
		uidChanged: function () {
			this._data = undefined;
			this.DOM(this.$.template).removeClass(STATE.VISIBLE);
			//To avoid error propogation if user drags a new template
			associationBrokenItems =[];
		},

		_showSelection: function () {
			if (this._selectedItem) {
				// Find the item which contains the widget and make the selection
				var item = this.DOM(this).find('[name="' + this._selectedItem + '"]').elements()[0];
				// If the item exist
				if (item) {
					this._callWhenAttached(item, function () {
						item.preventTabSwitch = true;
						// If its anything else (doesnt affect the layout selection)
						item.onClick();
					});
					/*to bring scrollbar to current component(referred as Item in this function) positon.
					Solution/IR-603327-3DEXPERIENCER2019x/09-10-2018.*/
					//this.querySelector('#showextraspaceatbottom').scrollTop = 2 * item.offsetTop;
					this.querySelector('#updpnl').scrollTop = item.offsetTop - item.offsetHeight;

				}
			}
		},

		/**
		 * TO call some function after component is attached
		 * @param  {Node} node - node for which we are waiting to get attached
		 * @param  {Function} callback - Function which is to be called after component is attached
		 */
		_callWhenAttached: function (node, callback) {
			if (node.isAttached) {
				callback();
			} else {
				node.addEventListener(node.tagName.toLowerCase() + '-attached', function onAttached() {
					node.removeEventListener(node.tagName.toLowerCase() + '-attached', onAttached);
					callback();
				});
			}
		},
		/**
		 * When the view gets bounded to DOM
		 */
		onTemplateBound: function () {
			var domBind;
			// Trigger validation once the view is loaded
			domBind = this.querySelector('#autobind');
			// Check if the meta information is ready
			if ((this.meta !== undefined) && (this.view !== undefined) && (domBind !== undefined) && domBind.isAttached === true) {
				this.isInDesignMode && this._showSelection();
				this.async(function () {
					this.validate();
				}.bind(this), 1E2);
				/*With Reference to IR-635594-3DEXPERIENCER2019x, Rule Count Ddecrement was not happenning. below statement is added as part of logic. */
				associationBrokenItems = [];
				//NotBindedInfoList= [];
				this.$.binder.execute(this.view, this.meta);
				//console.log(associationBrokenItems);
				// After bindings are in place execute the rules
				this.$.binder.executeRules(this.view, this.meta);
				// Show that the progress is done
				this.$.updpnl.done();
			}
		},

		addMutationObserver: function(){
			var canvas, config, callback, that=this;
			if (!mutationObserver && this.whichMode() === 'design'){
				canvas = this.$.template;
				config = { attributes: true, childList: true, subtree: true };
				callback = function(mutationsList) {
					for (var mutation = 0; mutation < mutationsList.length; mutation++) {
						if (mutationsList[mutation].type === 'childList' && that.isValidChild(mutationsList[mutation])){
							that.fire('canvasChanged');
						} else if (mutationsList[mutation].type === 'attributes' && that.isValidAttribute(mutationsList[mutation])) {
							that.fire('canvasChanged');
						}
					}
				};
				mutationObserver = new MutationObserver(callback);
				mutationObserver.observe(canvas, config);
			}
		},

		removeMutationObserver: function(){
			if (mutationObserver){
				mutationObserver.disconnect();
				mutationObserver = undefined;
			}
		},

		isValidChild: function(child){
			var node;
			if (child.addedNodes.length === 1){
				node = child.addedNodes[0].nodeName.toLowerCase();
				if (this.meta.hasOwnProperty(node) || node === 'xs-wg-plm-data' || node === 'xs-wg-rule' || node === 'xs-wg-rule-trigger' || node === 'xs-wg-item'){
					return true;
				}
			} else if (child.removedNodes.length === 1){
				node = child.removedNodes[0].nodeName.toLowerCase();
				if (this.meta.hasOwnProperty(node) || node === 'xs-wg-plm-data' || node === 'xs-wg-rule' || node === 'xs-wg-rule-trigger' || node === 'xs-wg-item'){
					return true;
				}
			}
			return false;
		},

		isValidAttribute: function(attribute){
			var node, attributeAvailable;
			if (attribute.attributeName !== 'class'){
				node = attribute.target.nodeName.toLowerCase();
				if (this.meta.hasOwnProperty(node)){
					attributeAvailable = this.meta[node].props.filter(function(prop){
						return prop.name === attribute.attributeName;
					});
					if (attributeAvailable.length > 0){
						return true;
					}
				} else if (node === 'xs-wg-plm-data' || node === 'xs-wg-rule' || node === 'xs-wg-rule-trigger' || node === 'xs-wg-item'){
					return true;
				}
			}
			return false;
		},

		// Note: If you are wondering why this wasw commented.
		/*
        Inconsistency in getting warning message if there were more than one mandatory attribute in a given
        entity (simulation / activity). This search could easily become an expensive operation.
        Also we are not soo sure if this is going to help the method developer or the user.
        Technically this is creating too much of complexity to handle along with errors.
        What the summary shows is always whats based on the built view.
        At later point we could do such checks and warn the methods developer before releasing such
        Experience.
        - Aravind Mohan
        */
		validate: function () {
			var CheckType = {
				Association: 'association',
				Value: 'value'
			};
			// Initialize
			this._mandItemsStore = this._mandItemsStore || {};
			// Clear the items from mand items store
			this._clearMandItemsStore(this._mandItemsStore, CheckType.Association);
			// this._clearMandItemsStore(this._mandItemsStore, CheckType.Value);
			// If in design mode
			if (this.isInDesignMode()) {
				// Validates mandatory data for association
				this._validateMandData(CheckType.Association, this.$.info.InfoItemType.warning, this._mandItemsStore);
			} else {
				// Validates mandatory data for association
				this._validateMandData(CheckType.Association, this.$.info.InfoItemType.error, this._mandItemsStore);
			}
		},
		// Show the missing mandatory values
		// this._validateMandData(CheckType.Value, this.$.info.InfoItem.Type.error, this._mandItemsStore);
		_clearMandItemsStore: function (store, checkType) {
			var items;
			// Clear any existing items
			items = store[checkType];
			if (items) {
				items.forEach(function (item) {
					this.$.info.clear(item.id);
				}, this);
			}
		},
		/**
		 * Validate the experience designed till now
		 * @returns none
		 */
		_validateMandData: function (checkType, type, store) {
			var items;
			// Get the warning info
			items = this.$.wgplmdata.validateMandData(checkType);
			items.forEach(function (item, index) {
				// Create a new info item
				item.type = type;
				item.id = checkType + '_' + index;
				item._infoItem = this.$.info.createInfoItem(item.id, item);
			}, this);
			// Persist
			store[checkType] = items;
		},

		_computeClassDesignerHeight: function(designmode){
			if (designmode){
				return 'showextraspaceatbottom';
			} else {
				return 'shownoextraspace';
			}
		},

		listeners: {
			dragover: 'onDragOver',
			dragleave: 'onDragLeave',
			drop: 'onDrop'
			//'xs-wg-page-attached': 'onTemplateBound'
		},
		reloadPLMData: function (type, force) {
			if (type === undefined) {
				this._selectedItem = null;
				this._data = undefined;
			}
			this.$.wgplmdata.reloadPLMData(type, force);
		},
		behaviors: [DS.SMAProcSP.SPBase]
	});
}(this));
/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
