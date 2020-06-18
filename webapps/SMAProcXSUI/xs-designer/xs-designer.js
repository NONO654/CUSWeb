/* global DS, Polymer*/
(function (window) {
	'use strict';
	var isLayoutConsistent, handlePendingRequests, //Constants
		WIDGET_COLOR_CODE, //Enums
		DragData, DropAction, DragdataType, STATE, TAB, //Module variables
		/*Layout value for view layout*/
		_savedViewLayout,
		/*Flag to check if there are any changes in view*/
		changesInViewflag,
		/*Initializes every time a change in DOM is encountered with a setTimeout callback on 1 second*/
		changeTimer;
	var toQueryString = window.DS.SMAProcSP.SPBase.JS.toQueryString;
	/**
   *Color codes of different UI elements in the Toolkit
   */
	/* COLOR_CODES = [
            '#607d8b',
            '#ff9800',
            '#9c27b0',
            '#ffc107',
            '#3f51b5',
            '#00bcd4',
            '#2196f3',
            '#03a9f4',
            '#009688',
            '#4caf50',
            '#f44336',
            '#8bc34a',
            '#cddc39',
            '#673ab7',
            '#ff5722',
            '#e91e63',
            '#795548',
            '#ffeb3b'
        ];
    */
	WIDGET_COLOR_CODE = '#368EC4';
	//Enums
	STATE = {
		active: 'is-active',
		hidden: 'is-hidden',
		ready: 'is-ready',
		loading: 'is-loading',
		visible: 'is-visible'
	};
	//All tab Ids of the tab component
	TAB = {
		tools: 'tools',
		properties: 'properties',
		rules: 'rules'
	};
	DropAction = {
		INSERT: 'INSERT',
		MOVE: 'MOVE'
	};
	DragdataType = {
		TEXT: 'text',
		URL: 'URL'
	};
	//Private methods
	/**
   * Constructor for any data that needs to be dragged and dropped
   * @param {String} dropType - Can take values INSERT,MOVE - Helps determine what needs to be done on Drop
   * @param {Object} item - Position information for MOVE or UI element tag information for INSERT
   */
	DragData = function (dropType, item, noWrap) {
		this.dropType = dropType;
		this.item = item;
		this.noWrap = noWrap;
	};
	/**
   * Checks if layout is consistent with originally saved layout.
   * @method isLayoutConsistent
   * @params {Object} data
   * @return {boolean} true or false
   * @private
   **/
	isLayoutConsistent = function (data) {
		var currentLayout, savedLayout;
		//private function to get the node for comparing the Layout
		function getDOM(_myData) {
			var myDiv = document.createElement('div');
			myDiv.innerHTML = _myData;
			return myDiv;
		}
		currentLayout = getDOM(data);
		savedLayout = getDOM(_savedViewLayout);
		return savedLayout.isEqualNode(currentLayout);
	};
	/**
   * Private method that checks for any unsaved data changes and flushes any pending requests
   * @returns {String} - Alert information telling the user the changes are being saved before navigating away
   */
	handlePendingRequests = function () {
		//Compare last saved layout with current layout
		var layout = this.$.canvas.extract();
		//If they are different, there would have been changes to the layout.So confirm navigation.
		if (!isLayoutConsistent(layout)) {
			return 'There are unsaved changes in your view.Do you still want to proceed?';
		}
	};

	//Prototype
	window.XSDesigner = Polymer({ // jshint ignore:line
		is: 'xs-designer',
		properties: {
			canvasstate: {
				type: Boolean,
				value: false
			},
			//Attributes
			//Collection of validation messages received from Canvas
			canvasvalidationinfo: {
				value: null
			},
			loadstatus: {
				value: function () {
					return STATE.loading;
				}
			},
			securityContext: {
				notify: true
			},
			/**
                    Simulation Id

                    @attribute simid
                    @type String
                    @default null
                     **/
			simid: {
				value: null,
				notify: true
			},
			/**
                    Template Id

                    @attribute templateid
                    @type String
                    @default null
                     **/
			templateid: {
				notify: true
			},
			/**
                    Template title

                    @attribute templatetitle
                    @type String
                    @default {My First Template}
                     **/
			templatetitle: {
				value: null,
				notify: true
			},
			/**
                    Template view Id

                    @attribute templateviewid
                    @type String
                    @default null
                     **/
			viewid: {
				notify: true
			},
			/**
                    Is in dasboard

                    @attribute inDashBoard
                    @type boolean
                    @default {false}
                     **/
			inDashBoard: {
				type: Boolean,
				value: false,
				notify: true
			},
			meta: {
				type: Object,
				notify: true
			},

			disabled: {
				type: Boolean,
				value: true,
				notify: true
			},

			accesses: {
				type: Array,
				observer: 'accessesChanged'
			},
			odtFlag: {
				type: Boolean,
				value: false
			},
			lastsaved: {
				type: String,
				value: '',
				notify: true
			},
			undoredoarray: {
				type: Array,
				notify: true
			},
			viewPosition: {
				type: Number,
				value: -1
			},
			counters: {
				type: Object,
				value: {
					counter: {
						undo: 0,
						redo: 0,
						undoPrev: 0,
						redoPrev: 0
					}
				}
			}
		},

		//Life cycle methods
		attached: function () {
			//Initializions
			this.canvasvalidationinfo = [];
			//listen to viewrefresh event from property inspecter to update view info for rules
			this.listen(this, 'viewrefresh', 'viewrefresh');
			this.listen(this, 'scrollintoview', 'scrollintoviewIntoCanvas');
			// Register custom event handler for window unload event to handle unsaved data changes
			window.onbeforeunload = handlePendingRequests.bind(this);
			this.fire('xs-designer-attached');
			this.listen(this, 'getTemplateState', '_setTemplateState');

		},
		/*  Below function can be used to retrieve the mode template is opened in XS application. Fire an event getTemplateState.*/
		_setTemplateState: function (event) {
			var target = event.target || event.srcElement;
			target.set('templateState', this.accesses);

		},


		scrollintoviewIntoCanvas: function (event) {
			this.querySelector('#updpnl').scrollTop = event.detail.item.offsetTop - event.detail.item.offsetHeight;
		},
		accessesChanged: function () {
			if (this.accesses && this.accesses.length > 0 && this.accesses.indexOf('write') !== -1) {
				this.disabled = false;
			} else {
				this.disabled = true;
			}
		},
		//Event handlers
		/**
     * Gets information about item being dragged in canvas
     * @param {drag} event - Triggered when an existing item on canvas is dragged
     */
		onCanvasDragstart: function (event) {
			var eventData = JSON.stringify(new DragData(DropAction.MOVE, {
				rowIndex: event.detail.rowIndex
			}));
			event.dataTransfer.setData(DragdataType.TEXT, eventData);
		},

		/**
     * Launches property inspector for an item selected in the canvas
     * @param {click} event  - Triggered when an item is selected in canvas
     * @param {Object} detail - Details of the item selected
     */
		onItemSelect: function (event) {
			//If it's not in design mode, no selection should be processed
			if (!this.designmode) {
				return;
			}
			//Set the item, meta and complete view of ui element which was selected
			this.$.propertyinspector.refresh(event.detail, this.$.canvas.view);
			//Show the properties tab
			if ((event.detail !== undefined) && event.detail.preventTabSwitch) {
				//Clear the flag so that next time on click sidebar is switched to properties tab
				event.detail.preventTabSwitch = false;
			} else {
				Polymer.Base.set('$.propertyinspector.hideName', false, this);
				this.$.tab.switchTab(TAB.properties);
			}
			//Stop the event from bubbling further
			event.stopPropagation();
		},
		/**
     * Refreshes the Property inspector and switches to Tools tab when a selected item is removed
     * @param {click} event - Triggered on deletion of a selected item from canvas
     * @param {Object} detail - Details of item deleted
     */
		onItemRemove: function (event) {
			if (!this.designmode) {
				event.preventDefault();
				return;
			}
			//Set property inspector props and item to null and hide name row
			this.$.propertyinspector.clear();
			//d6u comment
			/*this.$.propertyinspector.item = null;
            this.$.propertyinspector.hideName = true;               */
			//Show the tools tab
			this.$.tab.switchTab(TAB.tools);
			//Stop the event from bubbling further
			event.stopPropagation();
		},
		/**
            This event handler is triggered when design mode is changed in the designer.
            It can be used to perform any resets or setup before changing to a different design mode
            @method onDesignmodeChange
            @param {Object} On-click event of toggle button for changing design mode
            @return none
        **/
		onDesignmodeChange: function (event) {
			if (this.designmode && event.target.selectedindex === 0) {
				return;
			}
			var currentViewLayout;
			//Changed design mode
			this.designmode = event.target.selectedindex === 0;
			if (!this.designmode) {
				this.$.canvas.removeMutationObserver();
			}
			this.$.canvas.clearDataChanges();
			//Paint the layout
			currentViewLayout = this.$.viewData.model.definition.layout;
			this.$.canvas.paint(currentViewLayout);
			//Perform any resets required before changing to a different mode
			Polymer.Base.set('$.propertyinspector.item', null, this);
		},

		onAutoCreate: function () {
			this.$.autocreate.showCreateModal();
		},

		/**
     * Inserts a UI element in canvas on clicking the corresponding Tool from sidebar
     * @param {toolclick} event - Triggered on click of any xs-components in sidebar
     */
		onToolClick: function (event) {
			var parent, sibling;
			//If the canvas is not empty
			if (this.$.propertyinspector.item) {
				//Add the widget to the content
				var item;

				if (event.detail.noWrap) {
					item = window.document.createElement(event.detail.item);
				} else {
					item = window.document.createElement('xs-wg-item');
				}

				parent = Polymer.dom(this.$.propertyinspector.item).parentNode;
				sibling = Polymer.dom(this.$.propertyinspector.item).nextSibling;
				//Insert it to the top of this item
				item.column = this.$.propertyinspector.item.column;
				item.preventTabSwitch = true;
				Polymer.dom(parent).insertBefore(item, sibling);

				if (event.detail.noWrap) {
					//Let element get attached the call on click
					this.async(function () {
						item.onClick();
						if (item.scrollIntoViewIfNeeded) {
							item.scrollIntoViewIfNeeded();
						} else {
							if (navigator.appVersion.indexOf('Trident/') > 0) {
								/* Microsoft Internet Explorer detected in. */
								this.scrollintoviewIntoCanvas({ detail: { item: item } });
							} else {
								item.scrollIntoView(false);
							}
						}
					}.bind(this), 1E2);

				} else {
					//Insert the widget
					item.insertWidget(event.detail.item, function () {
						item.onClick();
					});
				}

			} else {
				this.$.canvas.insertWidget(event.detail.item, event.detail.noWrap);
			}
			Polymer.Base.set('$.canvas.scrollTop', this.$.canvas.scrollHeight, this);
			event.stopPropagation();
			event.preventDefault();
		},

		onCreateItem: function (event) {
			var association, itemTag;
			association = event.detail.association;
			itemTag = event.detail.item;
			this.$.canvas.insertWidgetAutoCreate(itemTag, event.detail.noWrap, event.detail.addAtLast, association);
			this.$.canvas.repaint();
		},

		/**
     * Paints canvas with the template view layout
     * @param {response} event - Triggered when template view information is received from the server
     */
		onViewReady: function (event) {
			var currentViewLayout;
			event.stopPropagation();
			event.preventDefault();
			var DEFAULT_DEFINITION = {
				device: '',
				layout: ''
			};
			this.DOM(this).indexNodesById();
			//Initialize the definition if its not yet defined
			Polymer.Base.set('$.viewData.model.definition', window.JSON.parse(this.$.viewData.model.definition) || DEFAULT_DEFINITION, this);
			//Paint the layout
			currentViewLayout = this.$.viewData.model.definition.layout;
			this.$.canvas.paint(currentViewLayout, function () {
				// To validate template for unassociated items
				this.async(function () {
					this.$.canvas.addUnAssociatedListToInfo(this.$.canvas.getUnAssociatedItemList());
				}.bind(this));
			}.bind(this));
			//Preserves the initial view of the template to undoredoarray
			this._preserveView(currentViewLayout);
		},
		/**
     * Handles the canvas ready event from canvas.
     *
     * @param {response} event - Triggered when template view information is received from the server
     */
		onCanvasReady: function () {
			this.loadstatus = STATE.ready;
			_savedViewLayout = this.$.canvas.extract(true);
			if (this.designmode && !this.disabled) {
				this.$.canvas.addMutationObserver();
			}
			this.addEventListener('canvasChanged', this._onViewSave, true);
			this.addEventListener('canvasChanged', this._canvaDOMChanged, true);
		},
		ready: function(){
			this.defaultSimIcon = this.resolveUrl('../../SMAProcXSWidgets/assets/images/process.png');
			window.top.addEventListener('message', this.receiveMessage.bind(this), false);
		},
		 simDragStart: function(event){
			var options = {}, simItem = {};
			options.data = {
				protocol: '3DXContent',
				version: '0.1',
				source: 'SIMEXPS_AP',
				data: { items: [] }
			};
			simItem.objectId = this.simid;
			simItem.objectType = 'Simulation';
			simItem.displayType = 'Simulation Process';
			simItem.contextId = this.$.dashboard.getSecurityContext();
			simItem.displayName = this.simtitle;
			simItem.templateContent = true;
			if (window.widget){
				simItem.envId =	window.widget.getValue('x3dPlatformId');
			}
			options.data.data.items[0] = simItem;
			options.data = JSON.stringify(options.data);
			event.dataTransfer.setData('Text', options.data);
		},
		/**
        templateDragStart: function(event){
            var options = {}, templateItem = {};
            options.data = {
                protocol: '3DXContent',
                version: '0.1',
                source: 'SIMEXPS_AP',
                data: { items: [] }
            };
            templateItem.objectId = this.templateid;
            templateItem.objectType = 'Simulation Template';
            templateItem.displayType = 'Simulation Template';
            templateItem.contextId = this.$.dashboard.getSecurityContext();
            templateItem.displayName = this.templatetitle;
            if (window.widget){
                templateItem.envId =	window.widget.getValue('x3dPlatformId');
            }
            options.data.data.items[0] = templateItem;
            options.data = JSON.stringify(options.data);
            event.dataTransfer.setData('Text', options.data);
        },
     * Displays any errors encountered during Saving or loading the layout
     * @param {Object} event - HTTP response information for Save request
     */
		onError: function (event) {
			if (event.detail.verb === 'GET') {
				this.$.notification.logMessage({
					type: 'error',
					text: 'Loading failed',
					autoRemove: true
				});
			} else if (event.detail.verb === 'PUT') {
				this.$.notification.logMessage({
					type: 'error',
					text: 'Saving failed',
					autoRemove: true
				});
			}
			event.stopPropagation();
		},
		/**
     * This is a session timeout handler
     * @param {request} event - the httpRequest that caused this event
     */
		onSessionTimeout: function () {
			alert('You have been disconnected from the server, please reload the page.');
		},
		/**
     * Saves changes to layout and validates it when user clicks 'Save'
     * @param {click} event - Triggers when user clicks 'Save changes' button
     */
		_onViewSave: function (event) {
			//Update the layout definition
			// Look for items which are not binded to PLM data. Add it to info list
			// Do this operation asynchronously so that it doesn't blocks saving of view
			if (event && event.stopPropagation) {
				event.stopPropagation();
			}
			changesInViewflag = false;
			var that = this;
			this.async(function () {
				this.$.canvas.addUnAssociatedListToInfo(this.$.canvas.getUnAssociatedItemList());
			}.bind(this));

			var currentViewLayout = this.$.canvas.extract();
			if (this.designmode) {
				Polymer.Base.set('$.viewData.model.definition.layout', currentViewLayout, this);
				this.lastsaved = 'Saving changes...';
				that.$.viewData.model.update(true, function () {
					//Send an event. TO be used only for ODT.
					that.odtFlag && that.fire('viewsaved', {
						savedView: _savedViewLayout
					});
					//updating the saved layout
					_savedViewLayout = currentViewLayout;
					changesInViewflag = true;
					that._timerValue(changesInViewflag, that);
				});
			} else {
				changesInViewflag = false;
				//Send an event. TO be used only for ODT.
				this.odtFlag && this.fire('viewsaved', {
					savedView: _savedViewLayout
				});
			}
		},
		/**
			* Triggers every time a change in DOM is encountered
			*	Checks wheather the change has been occured due to undo/redo action or by other user actions
			*	Checking that it saves the view to undoredoarray if is has been triggered by other user actions after 1 second
		*/
		_canvaDOMChanged: function () {
			clearTimeout(changeTimer);
			changeTimer = setTimeout(function () {
				var currentViewLayout = this.$.canvas.extract();
				if (this.designmode) {
					if (this.counters.counter.undoPrev === this.counters.counter.undo &&
						this.counters.counter.redoPrev === this.counters.counter.redo) {
						this._preserveView(currentViewLayout);
					}
					this.counters.counter.undoPrev = this.counters.counter.undo;
					this.counters.counter.redoPrev = this.counters.counter.redo;
				}
			}.bind(this), 1000);
		},
		/**
			* Changes the view to previously saved view if there is any
			* @param {custom} event - Event due to undoAction
		*/
		_undoAction: function (event) {
			event.stopPropagation();
			var layout;
			//Checks if there is any view in the array to go back to it
			if (this.viewPosition > 0) {
				layout = this.undoredoarray[this.viewPosition - 1];
				this.$.canvas.paint(layout, function () {
					this._onViewSave();
				}.bind(this));
				//Decrese the current viewPosition counter by 1 and places it to current view in the array
				this.viewPosition--;
				//Increases the counters.counter.undo counter by 1
				this.counters.counter.undo++;
			}
		},
		/**
			* Changes the view to one view ahead which has been undone if there is any
			* @param {custom} event - Event due to redoAction
		*/
		_redoAction: function (event) {
			event.stopPropagation();
			var layout;
			//Checks if there is any view in the array to go ahead to it
			if (this.viewPosition < (this.undoredoarray.length - 1)) {
				layout = this.undoredoarray[this.viewPosition + 1];
				this.$.canvas.paint(layout, function () {
					this._onViewSave();
				}.bind(this));
				//Increase the current viewPosition counter by 1 and places it to current view in the array
				this.viewPosition++;
				//Increase the counters.counter.redo counter by 1
				this.counters.counter.redo++;
			}
		},
		/**
			* Preserves the template view in undoredoarray in order to provide undo and redo feature
			* @param {custom} view - Extracted view of the template
		*/
		_preserveView: function (view) {
			if (!this.undoredoarray) {
				//If undoredoarray is not initialised, it Initializes it and saves the initial view in the array
				this.undoredoarray = [];
				this.push('undoredoarray', view);
			} else {
				this.undoredoarray.length = this.viewPosition + 1;
				//Checks the length of array and saves the view accordingly
				if (this.undoredoarray.length <= 5) {
					this.push('undoredoarray', view);
				} else {
					//If array length is 6 it shifts the oldest saved view and saves the latest view at the end of the array
					this.shift('undoredoarray');
					this.push('undoredoarray', view);
				}
			}
			this.viewPosition = this.undoredoarray.length - 1;
		},

		_timerValue: function (flag, that) {
			if (flag && that.designmode) {
				that.lastsaved = 'All changes saved';
			} else {
				that.lastsaved = '';
			}
		},

		_getDefaultProps: function () {
			return [{
				caption: 'Hidden',
				name: 'hidden',
				title: 'Sets the visibility',
				type: 'boolean',
				choices: [true, false],
				_targetWrapper: true
			}];
		},

		_fetchMeta: function () {
			//Using a direct fetch instead of sp-webservice
			//Because of proxy issue
			this.async(function () {
				this.fire('xs-designer-loaded');
			}.bind(this));

			var url = this.resolveUrl('../../SMAProcXSWidgets/assets/meta.json');
			var instance = this;
			var xhr = new XMLHttpRequest();
			var self = this;
			xhr.addEventListener('load', function () {
				var meta = JSON.parse(xhr.response);
				Object.keys(meta).forEach(function (key) {

					//If default props should be available
					var defaultProps = meta[key].nodefaultprops ? [] : self._getDefaultProps();

					meta[key].props = meta[key].props.concat(defaultProps);
				});
				//Expose meta data to the component
				instance.meta = meta;
				//Expose meta data to property inspector also
				instance.$$('#propertyinspector').meta = meta;
			});
			xhr.open('GET', url);
			xhr.overrideMimeType('application/json');
			xhr.send();
		},
		behaviors: [DS.SMAProcSP.SPBase],
		_computeClass: function (license) {
			var isVisible = '';
			if (license) {
				isVisible = this.tokenList({
					'is-visible': license.Experience_Studio === 'false' // jshint ignore:line
				});
			}
			return 'license-error-message ' + isVisible;
		},
		_computeIf: function (license) {
			if (license) {
				return license.Experience_Studio && license.Experience_Studio === 'true'; // jshint ignore:line
			}
		},
		_computeUri: function (viewid) {
			if (viewid) {
				return 'templateviews/' + viewid;
			}
		},
		_computeSrc: function(defaultSimIcon, simitem){
			return !simitem.image ? defaultSimIcon : simitem.image;
		},
		_computeClass2: function (loadstatus) {
			return 'mode-switch ' + loadstatus;
		},
		_computeClass3: function (loadstatus) {
			return 'edit-actionbar ' + loadstatus;
		},
		_computeClassActionBarMenu: function(){
			if (localStorage.getItem('XS_BETA') == 'true'){
				return 'actionBarMenus';
			} else {
				return 'hide';
			}


		},
		_computeClass5: function (loadstatus) {
			return ' sidebar ' + loadstatus;
		},
		_computeClass6: function (tab) {
			return 'workbench ' + tab;
		},
		_computeClass7: function (designmode) {
			return 'canvas ' + this.tokenList({
				design: designmode,
				preview: !designmode
			});
		},
		_computeClass8: function (designmode) {
			//Hide message in preview mode
			if (!designmode) {
				return 'savemessage ' + 'hiddenText';
			} else {
				return 'savemessage';
			}
		},

		_computeClass9: function () {
			if (localStorage.getItem('XS_BETA') !== 'true') {
				return 'hide';
			} else {
				return 'undo-redo';
			}
		},

		_computeClassProcessTitle: function(){
			if (localStorage.getItem('XS_BETA') === 'true' && this.inDashBoard) {
				return 'process-title';
			} else {
				return 'hide';
			}
		},

		_computeClassToolbar: function(){
			if (localStorage.getItem('XS_BETA') === 'true' && this.inDashBoard) {
				return 'workbenchToolbar workbenchToolbar-XS_BETA';
			} else {
				return 'workbenchToolbar';
			}
		},
		_draggableTitles: function(){
            return localStorage.getItem('XS_BETA') === 'true' && this.inDashBoard;
        },
		tokenList: function (obj) {
			var key, pieces = [];
			for (key in obj) {
				if (obj[key]) {
					pieces.push(key);
				}
			}
			return pieces.join(' ');
		},
		/**
			* Returs class for undo icon amd makes it enabled or disabled
			* @param {custom} viewPosition - Position pointer in undoredoarray
			*	@param {custom} designmode - mode of the view, that is design or preview
			* @param {custom} disabled -If editing is allowed it's true or false
			*	@returns {custom} classList to the undo icon
		*/
		_computeUndoClass: function (viewPosition, designmode, disabled) {
			if (!designmode || disabled) {
				return 'hiddenText';
			} else {
				if (viewPosition === 0) {
					return 'action-icon fonticon fonticon-undo ' + 'disable-action-icon';
				} else {
					return 'action-icon fonticon fonticon-undo';
				}
			}
		},
		/**
			* Returs class for redo icon amd makes it enabled or disabled
			* @param {custom} viewPosition - Position pointer in undoredoarray
			*	@param {custom} designmode - mode of the view, that is design or preview
			* @param {custom} disabled -If editing is allowed it's true or false
			*	@returns {custom} classList to the redo icon
		*/
		_computeRedoClass: function (viewPosition, designmode, disabled) {
			if (!designmode || disabled) {
				return 'hiddenText';
			} else {
				if (this.undoredoarray && this.undoredoarray.length === (viewPosition + 1)) {
					return 'action-icon fonticon fonticon-redo ' + 'disable-action-icon';
				} else {
					return 'action-icon fonticon fonticon-redo';
				}
			}
		},

		_computeAutoCreateClass: function (designmode, disabled) {
			if (!designmode || disabled || localStorage.getItem('XS_BETA') !== 'true') {
				return 'hiddenText';
			} else {
				return 'fonticon fonticon-brush action-icon';
			}
		},
		hasPendingUpdates: function () {
			var layout = this.$.canvas.extract(true);
			return !isLayoutConsistent(layout);
		},

		refreshData: function () {
			//Set Designer in loading state
			this.$.canvas.removeMutationObserver();
			this.undoredoarray = null;
			this.viewPosition = -1;
			this.view = undefined;
			this.loadstatus = STATE.loading;
			Polymer.dom(this.root).querySelector('#canvas').reloadPLMData();
			Polymer.dom(this.root).querySelector('#propertyinspector').refreshProcessBrowser();
			Polymer.dom(this.root).querySelector('#viewWebService').getData();
			//this.$.canvas
		},

		_shouldShowSupportTool: function () {
			return this.inDashBoard && localStorage.getItem("SIMEXPS_AP_ENABLE_SUPPORTABILITY") === 'true';
		},

		_openSupportTool: function () {
			require(['DS/TransientWidget/TransientWidget', 'DS/SMAProcWebCMMUtils/SMAJSCMMAuthoringUtils', 'DS/SMAProcWebCMMUtils/SMAJSCMMConfig'], function(TransientWidget, SMAJSCMMAuthoringUtils, SMAJSCMMConfig) {
				var objectIds = [];
				objectIds.push({physicalId: this.templateid, name: this.templatetitle});
				objectIds.push({physicalId: this.viewid, name: this.templatetitle + " view"});
				objectIds.push({physicalId: this.simid, name: this.simtitle});
				SMAJSCMMConfig.initialize().then(function(){
					SMAJSCMMAuthoringUtils.openProcess(this.simid, {
						onSuccess: function(process){
							var activities = process.getAllActivities();
							for (var i = 0; i < activities.length; i++){
								if (activities[i].getPhysicalId){
									objectIds.push({physicalId: activities[i].getPhysicalId(), name: activities[i].getName()});
								}
							}
							var transientOptions = {
								mode: 'panel',
								height: 800,
								width: 700
							};
							this._getSessionInfo().then(function(session){
								var widgetOptions = {
									mode: 'viewondrop',
									neededLicenses: ['Experience_Studio'],
									session: session,
									config: {
										diagnostics: [
											{
												path: 'DS/SMAProcWebSupportabilityUtils/diagnostics/strategies/ObjectAccessDiagnostic',
												arguments: ["__SESSION__", objectIds, 'read'],
												useSessionInfo: true
											},
											{
												path: 'DS/SMAProcWebSupportabilityUtils/diagnostics/strategies/ObjectAccessDiagnostic',
												arguments: ["__SESSION__", objectIds, 'modify'],
												useSessionInfo: true
											},
										],
										logs: [
											{
												path: 'DS/SMAProcWebSupportabilityUtils/logging/loggables/ObjectAccessLog',
												arguments: ["__SESSION__", objectIds],
												filename: 'ObjectAccess.txt',
												useSessionInfo: true
											}
										]
									}
								};
								TransientWidget.showWidget('SIMPRDX_AP', 'Support Tool', widgetOptions, transientOptions);
							}.bind(this), console.error);
						}.bind(this),
						onFailure: console.error
					});
				}.bind(this));
			}.bind(this));
		},

		_getSessionInfo: function () {
			return new Promise(function(resolve, reject){
				this.$.dashboard.getSecurityContexts().then(function(securityContext){
					var selectedCtx = this.$.dashboard.getCurrentSecurityContext();
					(securityContext || []).forEach(function (ctx) {
						ctx.name = ctx.id;
						if (ctx.name === selectedCtx){
							ctx.isSelected = true;
						}
					});

					this.$.dashboard.getPlatforms().then(function(platforms){
						var tenant = undefined;
						if (platforms && platforms.length > 0 && platforms[0].id){
							tenant = platforms[0].id;
						}
						resolve({
							spaceUrl: this.$.dashboard.getMcsUri(),
							securityContext: securityContext,
							tenant: tenant
						});
					}.bind(this), reject);						
				}.bind(this), reject);
			}.bind(this));
		},

		_showCloseConfirmation: function () {
			this.$.closeDialog.show();
		},

		_hideCloseConfirmation: function () {
			this.$.closeDialog.hide();
		},
		_showEditPropertiesPopup: function () {
    				var objId = this.templateid;
    				var ctx = window.widget.getValue('collabspaces');
    				var propertiesContext = {
    					getSecurityContext: function() {
    						return  ctx;
    					},
    					getSelectedNodes: function() {
    						return [{ getID: function() { return objId; } }];
    					}
    				};

			var widgetId = window && window.widget && window.widget.id;
			if (/^preview-/.test(widgetId)) {
				this.$.notification.logMessage({
					type: 'warning',
					text: 'Please pin the current widget before showing: Properties',
					autoRemove: true
				});
			} else {
				require(['DS/LifecycleControls/EditPropDialog'], function (EditPropDialog) {
					var propDlg = new EditPropDialog();
					propDlg.launchProperties(propertiesContext);
				}, function (error) {
					logger.warn('Failed to load LifecycleControls widget: ' + error, error);
				});
			}

    		},
		_showEditLifecyclePopup : function(){
			var items = [];
			//Object to display in lifecycle widget.
			var obj = {
				displayName : this.templatetitle,
				envId : window.widget.getValue('x3dPlatformId'),
				objectId : this.templateid,
				objectType : 'Simulation Template'
			};
			items.push(obj);
			var pref = {
				data : {
					items : items
				},
				protocol: '3DXContent',
				widgetId : window && window.widget && window.widget.id,
				source : 'SIMEXPS_AP'
			};
			var widgetPref = {
				X3DContentId : JSON.stringify(pref)
			};
			require(['DS/TransientWidget/TransientWidget'], function(Transient) {
				var transientOptions = {
					mode: 'panel',
					height: 800,
					width: 700
				};
				var widgetId = window && window.widget && window.widget.id;
				if (/^preview-/.test(widgetId)) {
					this.$.notification.logMessage({
						type: 'warning',
						text: 'Please pin the current widget before showing: Lifecycle',
						autoRemove: true
					});
				} else {
					Transient.showWidget('ENOLCMI_AP', 'Lifecycle', widgetPref, transientOptions);
				}
			}.bind(this));
			console.log('Opening lifecycle widget');
		},
		_showAttributeGroups: function () {
			var url = this.querySelector('#dashboard').getAuthenticatedJspUri('/simulationcentral/SMAAttributeGroups.jsp?' + toQueryString({
				objectId: this.templateid
			}));
			var attributesWindow = window.open(url, '', 'width=1000,height=800');
		},
		receiveMessage: function(event){
			var data =  JSON.parse(event.data);
			if (data && data.refresh){
				this.refreshData();
			}
		},
		closeTemplate: function () {
			this.fire('closeTemplate');
			//reset saved view layouts to default values
			_savedViewLayout = '';
			this.$.canvas = '';
		},

		viewrefresh: function () {
			this.$.propertyinspector.refreshRuleViewInfo(this.$.canvas.view);
		}
	});
}(this));
/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
