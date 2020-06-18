/*XSS_CHECKED*/
/**
 * Sample is available at FW
 * DS/ENOXCollectionToolBarTst/ENOXCollectionToolBar_sampleV2.html
 */

define(
		'DS/ENOXCollectionToolBar/js/ENOXCollectionToolBarV2',
		[
				'DS/Core/ModelEvents',
				'DS/Handlebars/Handlebars',
				'DS/Controls/Toggle',
				'DS/UIKIT/Iconbar',
				'DS/UIKIT/DropdownMenu',
				'DS/UIKIT/Tooltip',
				'DS/ResizeSensor/js/ResizeSensor',
				'DS/ENOXViewFilter/js/ENOXBasicFilter',
				'i18n!DS/ENOXCollectionToolBar/assets/nls/ENOXCollectionToolBar',
				'text!DS/ENOXCollectionToolBar/html/ENOXCollectionToolBarV2.html',
				'css!DS/ENOXCollectionToolBar/css/ENOXCollectionToolBarV2.css',
				'css!DS/UIKIT/UIKIT.css' ],

		function(ModelEvents, Handlebars, Toggle, Iconbar, DropdownMenu,
				Tooltip, ResizeSensor, ENOXViewFilter,
				nls_ENOXCollectionToolBarV2, html_ENOXCollectionToolBarV2,
				css_ENOXCollectionToolBarV2, css_uikit

		) {

			'use strict';

			Handlebars.registerHelper('sort_type_check2', function(currentType,
					compareToType, opts) {
				if (currentType == compareToType)
					return opts.fn(this);
				else
					return opts.inverse(this);
			});

			var template = Handlebars.compile(html_ENOXCollectionToolBarV2);

			var ENOXCollectionToolBarV2 = function(options) {
				this._init(options);
			};

			/** ***************************************************INITIALIZATION************************************************************ */
			ENOXCollectionToolBarV2.prototype._init = function(options) {
				this._options = options ? UWA.clone(options, false) : {};

				this._modelEvents = options.modelEvents ? options.modelEvents
						: new ModelEvents();

				// Default values if not provided by options
				var defaults = {
					currentNbitems : 0,
					currentNbSelections : 0
				};

				this._options.multiselectActionCount = (this._options.multiselActions && this._options.multiselActions.length > 0) ? this._options.multiselActions.length
						: undefined;
				this._options.itemName = (options.itemName) ? options.itemName
						: nls_ENOXCollectionToolBarV2.Item;
				this._options.itemsName = (options.itemsName) ? options.itemsName
						: nls_ENOXCollectionToolBarV2.Items;
				UWA.merge(this._options, defaults);

				this._setMultiselectionActions();
				this._subscribeToEvents();
				this._initDivs();
				this._render();
			};

			ENOXCollectionToolBarV2.prototype._initDivs = function() {
				this._container = document.createElement('div');
				this._options.nls = nls_ENOXCollectionToolBarV2;
				this._container.innerHTML = template(this._options);

				this._container = this._container
						.querySelector('.enox-collection-toolbar-container');
				this._multiSelectContainer = this._container
						.querySelector('.enox-collection-toolbar-withmultisel');
				this._countContainer = this._container
						.querySelector('.enox-collection-toolbar-item-count');
				this._itemCountContainer = this._container
						.querySelector('.enox-collection-toolbar-item-count-inner');
				this._filterIconContainer = this._container
						.querySelector('.enox-collection-toolbar-filter');
				this._filterTextContainer = this._container
						.querySelector('.enox-basic-filter-container');
				this._finalItemContainer = this._container
						.querySelector('.enox-collection-toolbar-finalItem');
				this._filterContainer = this._container
						.querySelector('.enox-collection-toolbar-search-textbox-container');
				this._multiselectionContainer = this._container
						.querySelector('.enox-collection-toolbar-multiselection');
				this._multiselectionOptions = this._container
						.querySelector('#enox-collection-toolbar-multiselect-options');
				this._multiselectionCount = this._container
						.querySelector('.enox-collection-toolbar-multiselect-count');
				this._multiselectionDivider = this._container
						.querySelector('#enox-collection-toolbar-multiselect-divider');
				this._actionsContainer = this._container
						.querySelector('.enox-collection-toolbar-actions');
				this._rightMenuContainer = this._container
						.querySelector('.enox-collection-toolbar-right-menu');
				this._rightMenuContainerWrapper = this._container
						.querySelector('.enox-collection-toolbar-right-menu-wrapper');

				// This test is for setting the width of the actionToolBar
				// depending if we show the TextField (itemCount) and the
				// CheckBox (selectItem).
				// By default :
				// TextField : 200px
				// CheckBox : 20px
				if (this._options.showItemCount && this._options.withmultisel) {
					this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
							+ ' '
							+ 'enox-collection-toolbar-right-menu-wrapper-width-with-checkBox';
				} else {
					if (this._options.showItemCount) {
						this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
								+ ' '
								+ 'enox-collection-toolbar-right-menu-wrapper-width-with-text';
					} else {
						this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
								+ ' '
								+ 'enox-collection-toolbar-right-menu-wrapper-width';
					}
				}
			};

			ENOXCollectionToolBarV2.prototype.inject = function(parentcontainer) {
				parentcontainer.appendChild(this._container);
			};

			/**
			 * FUNCTIONALITIES INITIALIZATION
			 */

			ENOXCollectionToolBarV2.prototype._render = function() {
				var that = this;
				this._actionsIconBar = new Iconbar(
						{
							renderTo : this._actionsContainer,
							events : {
								onClick : function(e, i) {
									if (i && !i.disabled) {
										if (i.allowSelectRetain) {
											i.selected = !i.selected;
											i.selected ? i.elements.container
													.addClassName("enox-collection-toolbar-filter-activated")
													: i.elements.container
															.removeClassName("enox-collection-toolbar-filter-activated");
										}
									}
								}
							}
						});

				// This test is for setting the width of the actionToolBar
				// depending of if we show the TextField (itemCount) and the
				// checkBox select.
				if (this._options.showItemCount && this._options.withmultisel) {
					this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
							+ ' '
							+ 'enox-collection-toolbar-right-menu-wrapper-width-with-checkBox';
				} else {
					if (this._options.showItemCount) {
						this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
								+ ' '
								+ 'enox-collection-toolbar-right-menu-wrapper-width-with-text';
					} else {
						this._rightMenuContainerWrapper.className = this._rightMenuContainerWrapper.className
								+ ' '
								+ 'enox-collection-toolbar-right-menu-wrapper-width';
					}
				}

				this._renderSearch();
				this._renderMultiselection();
				this._renderOtherActions();
				this._renderViews();
				this._renderSort();

			};

			/**
			 * EVENTS HANDLED
			 */

			ENOXCollectionToolBarV2.prototype._subscribeToEvents = function() {
				var that = this;
				this._listSubscription = [];

				this._listSubscription
						.push(this._modelEvents
								.subscribe(
										{
											event : 'enox-collection-toolbar-select-all-checkbox-partial'
										},
										function(itemCount) {
											that._selectionToggler.mixedState = true;
										}));

				this._listSubscription
						.push(this._modelEvents
								.subscribe(
										{
											event : 'enox-collection-toolbar-select-all-checkbox-uncheck'
										},
										function(itemCount) {
											that._selectionToggler.mixedState = false;
											that._selectionToggler.checkFlag = false;
										}));

				this._listSubscription
						.push(this._modelEvents
								.subscribe(
										{
											event : 'enox-collection-toolbar-select-all-checkbox-checked'
										},
										function(itemCount) {
											that._selectionToggler.mixedState = false;
											that._selectionToggler.checkFlag = true;
										}));

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-items-count-update'
				}, function(itemCount) {
					that._updateItemCount(itemCount)
				}));

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-reset-sort'
				}, function() {
					that._resetSort();
				}));

				// Color the action in the toolbar (event CSS)
				// data :
				// { id : 'idAction', icon : 'iconAction'}
				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-color-selected-action'
				}, function(data) {
					var painterIcon = document.querySelector('#' + data.id);
					var iconContainer = painterIcon.getChildren()[0];
					iconContainer.removeAttribute('class');
					// Add the blue color on the icon when it selected
					iconContainer.setAttribute('class', 'fonticon fonticon-'
							+ data.icon + ' painter-selected');
				}));

				this._listSubscription
						.push(this._modelEvents
								.subscribe(
										{
											event : 'enox-collection-toolbar-multiselect-icon-update-count'
										},
										function(number) {
											that
													._updateIconMultiselectNumber(number)
										}));

				/*
				 * this._listSubscription.push(this._modelEvents.subscribe({
				 * event: 'enox-collection-toolbar-selections-count-update'},
				 * function (count) { that._multiselectionCount.innerHTML =
				 * count; that._multiselectionWrapperContainer.style.display =
				 * (count === 0) ? 'none' : 'inline-block'; }));
				 */

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-set-multisel-actions'
				}, function(options) {
					that._multiselectActionsDD.destroy();
					that._setMultiselectionActions(options);
					that._renderMultiselection(options);
				}));

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-add-action'
				}, function(item) {
					that._actionsIconBar.addItem({
						id : item.id,
						fonticon : item.icon,
						text : item.title,
						handler : item.onClick
					});
				}));

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-remove-action'
				}, function(id) {
					that._actionsIconBar.menu.removeItem(id);
				}));

				this._listSubscription
						.push(this._modelEvents
								.subscribe(
										{
											event : 'enox-collection-toolbar-disable-action'
										},
										function(id) {
											that._actionsIconBar.menu
													.disableItem(id);
											that._actionsIconBar.getItem(id).className = 'enox-collection-toolbar-hide';
										}));

				this._listSubscription.push(this._modelEvents.subscribe({
					event : 'enox-collection-toolbar-enable-action'
				}, function(id) {
					that._actionsIconBar.menu.enableItem(id);
				}));

			};

			/** MULTISELCTIONS */

			ENOXCollectionToolBarV2.prototype._renderMultiselection = function(
					options) {
				var that = this;

				this.currentNbitems = this._options.currentNbitems ? this._options.currentNbitems
						: 0;
				this.currentNbSelections = this._options.currentNbSelections ? this._options.currentNbSelections
						: 0;

				// <!> We cannot have the checkBox without the text <!>
				// Text ItemCount
				if (this._options.showItemCount) {
					// CheckBox Multiple
					if (this._options.withmultisel) {
						UWA.extendElement(this._multiSelectContainer);
						this._selectionToggler = new Toggle({
							type : 'checkbox',
							allowUnsafeHTMLLabel : false
						}).inject(this._multiSelectContainer);
						this._selectionToggler
								.addEventListener(
										'buttonclick',
										function(e) {
											that._selectionToggler.checkFlag ? that._modelEvents
													.publish({
														event : 'enox-collection-toolbar-all-selected'
													})
													: that._modelEvents
															.publish({
																event : 'enox-collection-toolbar-all-unselected'
															});
										});

					}
					if (this.currentNbitems > 1) {
						this._itemCountContainer.innerHTML = this.currentNbitems
								+ " " + this._options.itemsName;
					} else {
						this._itemCountContainer.innerHTML = this.currentNbitems
								+ " " + this._options.itemName;
					}
				}

				// IconBar Multiple
				if (this._multiselectionActions) {
					var itemsMultipleActionBar = [];
					for (var i = 0; i < this._multiselectionActions.length; i++) {
						itemsMultipleActionBar.push({
							id : this._multiselectionActions[i].id,
							text : this._multiselectionActions[i].text,
							fonticon : this._multiselectionActions[i].fonticon,
							handler : this._multiselectionActions[i].handler
						})
					}

					var contentMultipleActionBar = {
						type : 'dropdownmenu',
						options : {
							items : itemsMultipleActionBar,
							events : {
								onClick : function(e, item) {
									if (item && !item.disabled) {
										item.handler(e, item);
									}
								}
							}
						}
					}

					var iconMultipleActionBar = {
						className : 'enox-collection-toolbar-multiselect-icon',
						id : 'iconMultipleActionBar',
						fonticon : 'select-on',
						text : nls_ENOXCollectionToolBarV2.Multiselection_Tooltip,
						disabled : false,
						content : contentMultipleActionBar
					}

					this._actionsIconBar.addItem(iconMultipleActionBar);

					// Code to manage the 'sub' number of the
					// iconMultipleActionBar
					// Get the iconMultipleActionBar
					this._multiActionIcon = this._container
							.querySelector('#iconMultipleActionBar');
					// Create a html <sub> in the iconMultipleActionBar (whom
					// manage the number of selection made)
					var subMultiActionIcon = document.createElement("sub");
					subMultiActionIcon.setAttribute('class',
							'enox-collection-toolbar-multiselect-count');
					this.numberOfSelection = document.createTextNode('');
					this._updateIconMultiselectNumber(this.currentNbSelections);

					subMultiActionIcon.appendChild(this.numberOfSelection);
					this._multiActionIcon.appendChild(subMultiActionIcon);
					// End code to manage the sub number of the
					// iconMultipleActionBar

					// Remove a issue css when iconSortActionBar go in the
					// reponsive menu
					this._actionsIconBar.overflowMenu
							.getItem('iconMultipleActionBar').elements.container.classList
							.remove('enox-collection-toolbar-multiselect-icon')

					this._actionsIconBar.addItem({
						className : 'divider'
					});

				} /*
					 * else if (this._options.multiselActionCallback &&
					 * this._multiselectionWrapperContainer) {
					 * that._multiselectionOptions .addEventListener("click",
					 * function() {
					 * that._options.multiselActionCallback.call(null,
					 * that._multiselectionWrapperContainer); }); }
					 */

			};

			/**
			 * SEARCH
			 */

			ENOXCollectionToolBarV2.prototype._renderSearch = function() {
				var that = this;
				if (this._options.filter) {
					// Icon Search
					this._actionsIconBar
							.addItem({
								id : 'enox-search',
								fonticon : 'search',
								text : nls_ENOXCollectionToolBarV2.Search_Tooltip,
								handler : function(e, i) {
									var filter = that._searchComponent._container;
									filter.style.display = (filter.style.display === 'none') ? 'inline-block'
											: 'none';
									if (filter.style.display !== 'none') {
										i.elements.container
												.addClassName("enox-collection-toolbar-filter-activated");
										that._searchComponent.searchTextBox
												._updateInnerInputFocus(0);
										// that._searchComponent.searchTextBox.elements.input.focus();

									} else {
										if (i.elements.container
												.hasClassName("enox-collection-toolbar-filter-activated")) {
											i.elements.container
													.removeClassName("enox-collection-toolbar-filter-activated");
											that._searchComponent._modelEvents
													.publish({
														event : 'enox-basic-filter-reset-search'
													});
										}
									}
									that._resize();
								}
							});
					this._actionsIconBar.addItem({
						className : 'divider'
					});
					// Filter (SearchComponent) input
					var filterOptions = this._options.filter
					this.filterWidth = this._options.filter.width ? this._options.filter.width
							: 400;
					// Variable to manage the resize of the filter (resize
					// function)
					this.resizeFilter = false;
					this._searchComponent = new ENOXViewFilter(filterOptions);
					this._searchComponent._modelEvents
							.subscribe(
									{
										event : 'enox-basic-filter-search-value'
									},
									function(data) {
										that._modelEvents
												.publish({
													event : 'enox-collection-toolbar-filter-search-value',
													data : data
												});
									});
					this.filter = UWA
							.extendElement(this._searchComponent._autocomplteWrapper);
					this._searchComponent.inject(this._filterContainer);
					this._searchComponent._container.style.display = 'none';

					// This loop is for removing every node how is not a real
					// element in the dom (like text)
					for (var t = 0; t < this._rightMenuContainer.childNodes.length; t++) {
						if (this._rightMenuContainer.childNodes[t].nodeType != Node.ELEMENT_NODE) {
							this._rightMenuContainer
									.removeChild(this._rightMenuContainer.childNodes[t]);
						}
					}
				}
			};

			/**
			 * OTHER ACTIONS
			 */

			// Parameter :
			// Object
			// {id : '' , text : '' , fonticon : '', ()}
			ENOXCollectionToolBarV2.prototype._renderOtherActions = function() {
				var actions = this._options.actions;
				// IconAction Customize
				if (actions) {
					this._wrapperContent = [];
					for (var i = 0; i < actions.length; i++) {
						var that = this;
						var action = actions[i];
						actions[i].disabled = actions[i].disabled || false;
						var contentItems = actions[i].content || [];
						var content;
						// Test if the content have many action
						if (contentItems.length > 0) {
							var itemSubAction = [];
							for (var t = 0; t < contentItems.length; t++) {
								var item = contentItems[t];
								item.parent = actions[i].id;
								// Add the event
								// enox-collection-toolbar-action-activated for
								// every item
								if (item.handler) {
									var handlerUser = item.handler
									var handleAction = function(e, i) {
										that._publishEventItemOtherAction(this)
										// Fire the user custom event
										if (handlerUser) {
											handlerUser(e, this);
										}
									}.bind(item);

									item.handler = handleAction;
								} else {
									item.handler = function(e, i) {
										that._publishEventItemOtherAction(this)
									}.bind(item);
								}

								itemSubAction.push(item)
							}
							content = {
								type : action.type ? action.type
										: 'dropdownmenu',
								options : {
									items : itemSubAction,
									responsiveMode : true
								}

							}
							this._wrapperContent[actions[i].id] = content;
							var className = actions[i].className ? actions[i].className
									: '';
							this._actionsIconBar
									.addItem({
										className : className,
										id : actions[i].id,
										fonticon : actions[i].fonticon,
										text : actions[i].text,
										disabled : actions[i].disabled,
										content : this._wrapperContent[actions[i].id],
										// handler : handleAction,
										selected : false,
										allowSelectRetain : actions[i].allowSelectRetain
									});
						} else {
							// Add the event
							// enox-collection-toolbar-action-activated
							// on the item
							var handleAction = function(e, i) {
								console
										.log('Publish event : enox-collection-toolbar-action-activated'
												+ ' id : ' + this.id)
								that._modelEvents
										.publish({
											event : 'enox-collection-toolbar-action-activated',
											data : this.id
										});
								// Fire the user custom event
								if (this.handler) {
									this.handler(e, this)
								}
							}.bind(action);
							this._actionsIconBar
									.addItem({
										className : className,
										id : actions[i].id,
										fonticon : actions[i].fonticon,
										text : actions[i].text,
										handler : handleAction,
										selected : false,
										allowSelectRetain : actions[i].allowSelectRetain,
										disabled : actions[i].disabled
									});
						}
					}
				}
			};

			ENOXCollectionToolBarV2.prototype._publishEventItemOtherAction = function(
					item) {
				console
						.log('Publish event : enox-collection-toolbar-action-activated'
								+ ' id : ' + item.id)
				if (item.changeIconSelection) {
					// Get the iconAction in the actionBar
					var itemAction = this._container.querySelector('#'
							+ item.parent);
					var iconContainer = itemAction.getChildren()[0];
					// Remove the icon (class)
					iconContainer.removeAttribute('class');
					// Add the new icon (class)
					iconContainer.setAttribute('class', 'fonticon fonticon-'
							+ item.fonticon);
				}
				this._modelEvents.publish({
					event : 'enox-collection-toolbar-action-activated',
					data : item.id
				});
			}

			/**
			 * VIEWS
			 */

			ENOXCollectionToolBarV2.prototype._renderViews = function() {

				var views = this._options.views;

				if (views && views.length > 0) {
					var that = this, currentView;
					// Add a divider in the left if searchComponant,
					// multiselComponent or otherActionComponent are set
					if (this._options.actions || this._options.withmultisel
							|| this._searchComponent) {
						this._actionsIconBar.addItem({
							className : 'divider'
						});
					}
					// Set the currentView
					currentView = this._find(views, this._options.currentView);
					var itemsViewsActionBar = [];
					// Add every views in the dropdownmenu
					for (var i = 0; i < views.length; i++) {
						var view = views[i];
						// Add the event
						// enox-collection-toolbar-switch-view-activated for
						// every items
						var handleViews = function(e, i) {
							var iconContainer = that._iconViewsActionBarContainer
									.getChildren()[0];
							// Remove the icon (class)
							iconContainer.removeAttribute('class');
							// Add the new icon (class)
							iconContainer.setAttribute('class',
									'fonticon fonticon-' + this.fonticon);
							console
									.log('Publish event : enox-collection-toolbar-switch-view-activated'
											+ 'id : ' + this.id)
							that._modelEvents
									.publish({
										event : 'enox-collection-toolbar-switch-view-activated',
										data : this.id
									});
							// Fire the user custom event
							if (this.handler) {
								this.handler(e, this)
							}
						}.bind(view);
						itemsViewsActionBar
								.push({
									id : views[i].id,
									title : views[i].text,
									text : views[i].text,
									fonticon : views[i].fonticon,
									handler : handleViews,
									selectable : views[i].selectable ? views[i].selectable
											: true,
									selected : views[i].id === currentView.id ? true
											: false
								})
					}

					var contentViewsActionBar = {
						type : 'dropdownmenu',
						options : {
							responsiveMode : true,
							items : itemsViewsActionBar
						}
					}

					var iconViewsActionBar = {
						id : 'iconViewsActionBar',
						fonticon : currentView.fonticon,
						text : currentView.text,
						disabled : currentView.disabled ? currentView.disabled
								: false,
						content : contentViewsActionBar
					}

					this._actionsIconBar.addItem(iconViewsActionBar);

					// Variable to get the IconViewsBarContainer
					this._iconViewsActionBarContainer = this._container
							.querySelector('#iconViewsActionBar');

				}
			};

			/*
			 * SORT
			 */
			ENOXCollectionToolBarV2.prototype._renderSort = function() {
				var sortOptions = this._options.sort;
				var that = this;
				if (sortOptions && sortOptions.length > 0) {
					this._asc = 'ASC';
					this._desc = 'DESC';
					var itemsSortActionBar = [];
					var nameCurrentTitle;
					for (var i = 0; i < sortOptions.length; i++) {
						var selectFirstMenu = false;
						var subItemsSortActionBar = [
								{
									id : sortOptions[i].id + '-ASC',
									fonticon : sortOptions[i].type === 'integer' ? 'sort-num-asc'
											: 'sort-alpha-asc',
									text : 'ASC',
									selectable : true,
									selected : this._options.currentSort ? this._options.currentSort.id === sortOptions[i].id
											&& this._options.currentSort.order == 'ASC' ? true
											: false
											: false,
									handler : function(e) {
										that._handlerSort(this, that._asc);
									}.bind(sortOptions[i])
								},
								{
									id : sortOptions[i].id + '-DESC',
									fonticon : sortOptions[i].type === 'integer' ? 'sort-num-desc'
											: 'sort-alpha-desc',
									text : 'DESC',
									selectable : true,
									selected : this._options.currentSort ? this._options.currentSort.id === sortOptions[i].id
											&& this._options.currentSort.order == 'DESC' ? true
											: false
											: false,
									handler : function(e) {
										that._handlerSort(this, that._desc)
									}.bind(sortOptions[i])
								} ];
						if (this._options.currentSort
								&& this._options.currentSort.id === sortOptions[i].id) {
							nameCurrentTitle = sortOptions[i].text;
							selectFirstMenu = true;
						}
						itemsSortActionBar.push({
							id : sortOptions[i].id,
							text : sortOptions[i].text,
							fonticon : sortOptions[i].fonticon,
							handler : sortOptions[i].handler,
							items : subItemsSortActionBar,
							selectable : true,
							selected : selectFirstMenu
						})
					}

					var contentSortActionBar = {
						type : 'dropdownmenu',
						options : {
							items : itemsSortActionBar
						}
					}

					var iconSortActionBar = {
						id : 'iconSortActionBar',
						fonticon : 'sort-alpha-asc',
						disabled : false,
						text : this._options.currentSort ? nls_ENOXCollectionToolBarV2.sortBy
								+ nameCurrentTitle
								: nls_ENOXCollectionToolBarV2.sort,
						content : contentSortActionBar
					}

					this._actionsIconBar.addItem(iconSortActionBar);

					// Variable to get the IconViewsBarContainer
					this._sortBase = this._container
							.querySelector('#iconSortActionBar');

					// This event on the 3 dot menu is for avoid a issue css on
					// the icon multiselect in the responsive mode
					this._actionsIconBar.overflowMenuTrigger
							.addEventListener(
									"click",
									function() {
										that._actionsIconBar.overflowMenu
												.getItem('iconMultipleActionBar').elements.container.classList
												.remove('enox-collection-toolbar-multiselect-icon')
									});

					this._activateCurrentSort(this._options.currentSort);
				}
			};

			ENOXCollectionToolBarV2.prototype._handlerSort = function(attribut,
					order) {
				var that = this;

				this._setTextSort(attribut.text + " " + order);
				this._selectSort(attribut.id, order);
				this._changeIconSort(attribut.type, order);

				console
						.log('Publish event : [enox-collection-toolbar-sort-activated]'
								+ ' order by : ' + attribut.id + ' ' + order)
				that._modelEvents.publish({
					event : 'enox-collection-toolbar-sort-activated',
					data : {
						sortOrder : order,
						sortAttribute : attribut.id
					}
				})

			}

			ENOXCollectionToolBarV2.prototype._changeIconSort = function(type,
					order) {

				// icon desktop
				var iconContainer = this._sortBase.getChildren()[0];
				// icon responsive
				var itemOverflowMenu = this._actionsIconBar.overflowMenu
						.getItem('iconSortActionBar').elements;
				// Remove the icon (class)
				iconContainer.removeAttribute('class');
				itemOverflowMenu.icon.removeAttribute('class');
				// Add the new icon (class)
				switch (type) {
				case 'integer':
					iconContainer
							.setAttribute('class',
									'fonticon fonticon-sort-num-'
											+ order.toLowerCase());
					itemOverflowMenu.icon
							.setAttribute('class',
									'fonticon fonticon-sort-num-'
											+ order.toLowerCase());
					break;
				case 'string':
					iconContainer.setAttribute('class',
							'fonticon fonticon-sort-alpha-'
									+ order.toLowerCase());
					itemOverflowMenu.icon.setAttribute('class',
							'fonticon fonticon-sort-alpha-'
									+ order.toLowerCase());
					break;
				default:
				}

			}

			ENOXCollectionToolBarV2.prototype._selectSort = function(id, order) {
				// IconBar have 2 dropmenu distinct one for the desktop and the
				// second for responsive mode.
				// And for each subMenu work independently

				order = order.toUpperCase()
				// Test for the dropmenu desktop
				if (this._actionsIconBar.getItem('iconSortActionBar').content.component) {
					var menuSort = this._actionsIconBar
							.getItem('iconSortActionBar').content.component.items;
					var firstMenu;
					// unselected all items and select only the current
					for (var i = 0; i < menuSort.length; i++) {
						// The first menu which should be selected
						if (menuSort[i].id === id) {
							firstMenu = menuSort[i];
						}
						if (menuSort[i].id === id + '-' + order) {
							// add the css selected
							if (menuSort[i].elements) {
								menuSort[i].elements.container
										.addClassName('selected')
							}
							// Set the propertie selected to true
							menuSort[i].selected = true;
						} else {
							// Remove the css selected
							if (menuSort[i].elements) {
								menuSort[i].elements.container
										.removeClassName('selected')
							}
							// Set the propertie selected to false
							menuSort[i].selected = false;
						}
					}
					// Select the parent menu of the subMenu
					firstMenu.selected = true;
					if (firstMenu.elements) {
						firstMenu.elements.container.addClassName('selected');
					}
				}

				// Test for the dropmenu responsive
				if (this._actionsIconBar.overflowMenu) {
					var menuSortOverFlow = this._actionsIconBar.overflowMenu.items;
					var firstMenuOverFlow;
					// unselected all items and select only the current
					for (var i = 0; i < menuSortOverFlow.length; i++) {
						// The first menu which should be selected
						if (menuSortOverFlow[i].id === id) {
							firstMenuOverFlow = menuSortOverFlow[i];
						}
						if (menuSortOverFlow[i].id === id + '-' + order) {
							// add the css selected
							if (menuSortOverFlow[i].elements) {
								menuSortOverFlow[i].elements.container
										.addClassName('selected')
							}
							// Set the propertie selected to false
							menuSortOverFlow[i].selected = true;
						} else {
							// Remove the css selected
							if (menuSortOverFlow[i].elements) {
								menuSortOverFlow[i].elements.container
										.removeClassName('selected')
							}
							// Set the propertie selected to false
							menuSortOverFlow[i].selected = false;
						}
					}
					// Select the parent menu of the subMenu
					firstMenuOverFlow.selected = true;
					if (firstMenuOverFlow.elements) {
						firstMenuOverFlow.elements.container
								.addClassName('selected');
					}
				}

			}

			// Method to reset the sort (work only if the dropdownmenu was
			// created)
			ENOXCollectionToolBarV2.prototype._resetSort = function() {
				// Test for iconSortMenu in desktop
				if (this._actionsIconBar.getItem('iconSortActionBar').content.component) {
					var menuSort = this._actionsIconBar
							.getItem('iconSortActionBar').content.component.items;
					for (var i = 0; i < menuSort.length; i++) {
						// Remove the css selected
						menuSort[i].elements.container
								.removeClassName('selected')
						// Set the propertie selected to false
						menuSort[i].selected = false;
					}
				}
				// Test for iconSortMenu in responsive
				if (this._actionsIconBar.overflowMenu) {
					var menuSortOverFlow = this._actionsIconBar.overflowMenu.items;
					// Remove all items selected
					for (var i = 0; i < menuSortOverFlow.length; i++) {
						menuSortOverFlow[i].elements.container
								.removeClassName('selected')
						// Set the propertie selected to false
						menuSortOverFlow[i].selected = false;
					}
				}
				console
						.log('Publish event : [enox-collection-toolbar-sort-activated]')
				this._modelEvents.publish({
					event : 'enox-collection-toolbar-sort-reset',
					data : {}
				})
			}

			ENOXCollectionToolBarV2.prototype._setTextSort = function(text) {
				// Menu desktop
				var item = this._actionsIconBar.getItem('iconSortActionBar');
				item.tooltip.getBody().innerText = nls_ENOXCollectionToolBarV2.sortBy
						+ text;
				// Menu responsive
				var itemOverflowMenu = this._actionsIconBar.overflowMenu
						.getItem('iconSortActionBar');
				itemOverflowMenu.elements.content.innerText = nls_ENOXCollectionToolBarV2.sortBy
						+ text;
			}

			// Set the toolbar at the value (sortBy)
			// Parameter :
			// 1 : {id : "name", order : "order"}
			ENOXCollectionToolBarV2.prototype._activateCurrentSort = function(
					sortBy) {
				if (sortBy) {
					var currentSort = this._find(this._options.sort, sortBy.id);
					this._setTextSort(currentSort.text + " " + sortBy.order)
					this._selectSort(currentSort.id, sortBy.order);
					this._changeIconSort(currentSort.type, sortBy.order);
				}
			};

			ENOXCollectionToolBarV2.prototype._resize = function() {
				var that = this, width;
				var total_width = this._container.offsetWidth;

				// Evaluate the marge
				var widthToolBar = this._actionsContainer.offsetWidth
						+ (this._countContainer ? this._countContainer.offsetWidth
								: 0)
						+ (this._multiSelectContainer ? this._multiSelectContainer.offsetWidth
								: 0) + this.filterWidth + 20;
				var width = total_width - widthToolBar;
				// console.log('marge width : '+width);

				if (width > 0) {
					if (that.filter) {
						that.filter.style.width = this.filterWidth + 'px';
						if (this.resizeFilter) {
							// Set the filter in the same line as the toolbar
							that.filter.style.position = '';
							that.filter.style.top = '';
							that.filter.style.left = '';
							// <!><!><!>
							// This test is made for reordering the div to avoid
							// a gap
							// issue between the actionBar and the filter
							if (this._rightMenuContainer.childNodes[1] === this._filterContainer) {
								this._rightMenuContainer
										.removeChild(this._filterContainer);
								this._rightMenuContainer.insertBefore(
										this._filterContainer,
										this._rightMenuContainer.children[0]);
							}
							// <!><!><!>
							this.resizeFilter = false;
						}
					}
				} else {
					if (that.filter) {
						that.filter.style.width = total_width + 'px';
						if (!this.resizeFilter) {
							// Set the filter below the toolbar
							that.filter.style.position = 'absolute';
							that.filter.style.top = '48px';
							that.filter.style.left = '0px';
							// <!><!><!>
							// This test is made for reordering the div to avoid
							// a gap
							// issue between the actionBar and the filter
							if (this._rightMenuContainer.childNodes[0] === this._filterContainer) {
								this._rightMenuContainer
										.removeChild(this._filterContainer);
								this._rightMenuContainer
										.appendChild(this._filterContainer);
							}
							// <!><!><!>
							this.resizeFilter = true;
						}
					}
				}
				this._actionsIconBar.resize();

				/*
				 * if
				 * (this._actionsIconBar.classList.contains('iconbar-overflow-menu-trigger')) { }
				 */

				this._modelEvents.publish({
					event : 'enox-collection-toolbar-on-toolbar-height-change',
					data : that._container.offsetHeight
				});
			};

			// Method to find a id in a array and set the selected property
			ENOXCollectionToolBarV2.prototype._find = function(array, id) {
				var currentObj;
				array.forEach(function(item) {
					if (item.id === id) {
						item.selected = true;
						currentObj = item;
						return;
					}
				})
				if (!currentObj) {
					currentObj = array[0];
					array[0].selected = true;
				}
				return currentObj;
			};

			// Method to update the number display in the iconMultiselect
			ENOXCollectionToolBarV2.prototype._updateItemCount = function(
					itemCount) {
				this.currentNbitems = itemCount;
				if (itemCount === 1) {
					this._itemCountContainer.innerHTML = itemCount + " "
							+ this._options.itemName;
				} else {
					this._itemCountContainer.innerHTML = itemCount + " "
							+ this._options.itemsName;
				}
			};

			ENOXCollectionToolBarV2.prototype._setMultiselectionActions = function(
					options) {
				this._multiselectionActions = options ? options
						: this._options.multiselActions;
			};

			// Method to update the number display in the iconMultiselect
			ENOXCollectionToolBarV2.prototype._updateIconMultiselectNumber = function(
					number) {
				this.currentNbSelections = number;
				if (number > 99) {
					this.numberOfSelection.nodeValue = '+99';
				} else {
					this.numberOfSelection.nodeValue = number;
				}
			};

			// Function to manage the resize toolbar
			// <!><!><!><!><!><!><!><!><!><!><!><!>
			// Must be attach after the DOM is generate
			// <!><!><!><!><!><!><!><!><!><!><!><!>
			ENOXCollectionToolBarV2.prototype.attachResizeSensor = function() {
				var that = this;
				this.resizeSensor = new ResizeSensor(
						this._container,
						function() {
							if (that._container.offsetWidth > 0
									&& that._container.offsetWidth !== that._currentWidth) {
								that._resize();
								that._currentWidth = that._container.offsetWidth;
							}
						});
			};

			return ENOXCollectionToolBarV2;
		});
