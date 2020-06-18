/**
 * @licence Copyright 2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0
 * @access private
 */
define('DS/ENOXRelatedItem/js/ENOXRelatedItem',
	['UWA/Core',
	 'UWA/Class/Model',
	 'UWA/Class/View',
	 'UWA/Class/Promise',
	 'DS/UIKIT/Alert',
	 'DS/UIKIT/Modal',
	 'DS/UIKIT/Scroller',
	 'DS/UIKIT/Input/Button',
	 'DS/UIKIT/Autocomplete',
	 'DS/Handlebars/Handlebars',
	 'DS/WAFData/WAFData',
	 'DS/DataDragAndDrop/DataDragAndDrop',
	 'DS/ENOXRelatedItem/js/ENOXCard',
	 'text!DS/ENOXRelatedItem/html/ENOXRelatedItem.html',
	 'css!DS/UIKIT/UIKIT.css',
	 'css!DS/ENOXRelatedItem/css/ENOXRelatedItem.css',
	 'i18n!DS/ENOXRelatedItem/assets/nls/ENOXRelatedItem'],
	function(UWA,
			UWAModel,
			UWAView,
			UWAPromise,
			Alert,
			Modal,
			Scroller,
			Button,
			Autocomplete,
			Handlebars,
			WAFData,
			DataDragAndDrop,
			ENOXCard,
			XRelatedItemTemplate,
			cssUIKIT,
			RelatedItemCSS,
			NLS
			) {
	'use strict';

	var template = Handlebars.compile(XRelatedItemTemplate);
		var ENOXRelatedItem = UWAView.extend({
							name : 'xapp-related-item',
							currentItems : [],
							allowedTypes : {},
							actions : {},
							modelEvents : null,
              // destroyCard - for destroying suggestion section
              // dynamicInputKeySearch - Item Search is dynamic or not
              // clearSelectedItems - is no item selected valid
              //customValidateSelectedItems - custom function to validate selected items
							destroyCard : true,
							dynamicInputKeySearch: true,
							clearSelectedItem: true,
							customValidateSelectedItems: null,
							itemSearchRequired: true,
							className : function() {
								return this.getClassNames('-container');
							},
							domEvents : {
								'click #clear' : '_clearCurrentItems'
							},
							/**Function to set up the Related Item page
							 * @param {object} options - object of data passed to the set up function
							 * */
							setup : function(options) {
								var that = this;
								that.modelEvents = options.modelEvents;
								that.allowedTypes = options.allowedTypes ? options.allowedTypes : {};
								that.currentItems = [];
								that.itemUtilityData = options.itemFetchData;
								that.suggestedItemUtilityData = options.suggestedItemFetchData;
								that.customValidateSelectedItems = options.customValidateSelectedItems;
								that.needImage = options.imageAvailable;
								/*For future use if Dropped Item Data to be fetched*/
								/**
								 * that.dropItemData = options.dropItemData;
								 * that.dropItemDataFetchFunction = options.dropItemDataFetchFunction;
								 * where - dropItemData is {urlFunction: dropItemURL, fetchOpts: fetchOptionsDropData, dropItemDataParserFunction: dropItemDataParserFunction}
								 * */
								if (that.customValidateSelectedItems){
									that.validationFailMessage = options.validationFailMessage?options.validationFailMessage:'Selected items cannot be added. Please select valid items...';
								}
								if (options.clearSuggestionSection === false) {
								that.destroyCard = false;
								}
								if (options.dynamicInputKeySearch === false){
									that.dynamicInputKeySearch = false;
								}
								if (options.itemSearchRequired === false){
									that.itemSearchRequired = false;
								}
								if (options.haveEmptySelection === false){
									that.clearSelectedItem = false;
								}
								//that.url = options.url;
								//that.fetchOptsFunction =  options.fetchOptsFunction;
								//that.dataParser = options.dataParserFunction;
								/** Define the content and footer section */
								var contentSection = that._frameContentSection(options);
								var arrFooter = that._frameFooterSection(options);
									that.relatedItemView = new Modal({
										closable : true,
										header : options.header,
										body : contentSection,
										footer : arrFooter,
										events : {
												onHide : function() {
												that.destroy();
											}
										}
									});
							},
							/**Function to render the Related Item page*/
							render : function() {
								var that = this;
								that.relatedItemView.inject(that.container);
								that.container.inject(widget.body);
								that.relatedItemView.show();
								that.alert = new Alert({
									visible : true,
									closable: true,
									autoHide: true,
									hideDelay: 3000,
								}).inject(that.relatedItemView.getContent(), 'top');
							},
							/**Function to create a new and add it to the container
							 * @param {object} containerScroll - container for the scroll element
							 * @param {object} scroll - scroll element with data
							 * */
							_addScroller : function(containerScroll, scroll) {
								new Scroller({
									element : scroll
								}).inject(containerScroll);
							},
							/**Function to create a ENOXCard
							 * @param {boolean} closable - is the card closable (true/false)
							 * @param {object} context - current card's context
							 * @param {object} item - current card's item details
							 * @param {object} events - events the created card holds
							 **/
               // 2---- needImage - to manage card with no image
							_createCard : function(closable, needImage, context, item, events) {
								if (item instanceof UWAModel){
									var cardView = new ENOXCard({
										closable : closable,
										context : context,
										modelKey : item,
										events : events,
										needImage: needImage
									});
									return cardView;
								}
								return true;
							},
							/**Function to fetch the Suggestion Items of the current selected item
							 * @param {object} currentItem - current selected item
							 * @param {object} card - card object of the selected item
							 **/
							//Currently holds DUMMY DATA
							_fetchSuggestedItems : function(currentItem, card) {
								var that = this;
								var url = that.suggestedItemUtilityData.url;
                // 3 --- # is passed as URL when no search for data is needed (for items or suggestions)
								if (url && url!=='#') {
									var fetchOpts = that.suggestedItemUtilityData.fetchOptsFunction('Case');
									that.connectURL(url, fetchOpts).then(function(response) {
										that._manageSuggestionSection(card,that.suggestedItemUtilityData.dataParserFunction(response));
									});
								}
							},
							/**Function called on selecting option from the search dropdown list
							 * @param {object} [item] current selected item
							 * */
							_onOptionSelect : function(item) {
								var that = this;
								var arraySelectedItem = [];
								arraySelectedItem.push(new UWAModel({
									id : item.resourceId,
									title : item.value,
									subtitle : item.subLabel1,
									image : item.picture
								}));
								that._manageCurrentItems({
									items : arraySelectedItem
								});
								that.itemSearchField.reset();
							},
							/**Function used to empty the current item section on clicking on Cancel button
							 * */
							_clearCurrentItems : function() {
								var that = this;
								var emptyView = that.getElement('.empty-list-view');
								var clearBtn = that.getElement('#clear');
								that.currentItems.splice(0);
								that.selItemSection.empty();
                //4 ---- suggestions need not be cleared
								//to be uncommented - if clearing suggestions is required
								//that.suggestionScrollContent.empty();
								if (emptyView && emptyView.hasClassName('hidden')) {
									emptyView.removeClassName('hidden');
									emptyView.addClassName('show');
								}
								// Clear should be enabled only if selected items exist
								if (clearBtn && !clearBtn.hasClassName('disabled')) {
									clearBtn.addClassName('disabled');
								}
								// Submit should be enabled only if there is a change done
								if (that.mode === 'single') {
									that.actions.submitBtn.enable();
								} else {
									that.actions.submitBtn.disable();
								}
							},
							/** Function to move the item to selected items section
							 * @param {object} [cardView] card object of the selected card
							 * @param {string} [context] selected card's context
							 * @param {object} [event] events for the current chosen card
							 **/
							_onCardSelect : function(cardView, context, event) {
								if (cardView && cardView.model && !context.currentItems.includes(cardView.model)) {
										context._manageCurrentItems({
										items : [ cardView.model ],
										ctxElement : cardView,
										event : event
									});
								}

								// after the item is moved to selected items section
								// it should be removed
								if (cardView && context.destroyCard) {
									cardView.destroy();
								}
							},
							/** Function to remove selected items in case of multi selection mode
							 * @param {object} [cardView] card object of the current card
							 * @param {object} [context] context of the current card
							 **/
							_onCardCancel : function(cardView, context) {
								if (cardView.model && context.currentItems.includes(cardView.model)) {
									context.currentItems.splice(context.currentItems.indexOf(cardView.model), 1);
								}
								var suggestions = cardView.suggestions;
								if (suggestions) {
									suggestions.forEach(function(item) {
										item.destroy();
									});
								}
								cardView.destroy();
								if (context.currentItems.length === 0) {
									var emptyView = context.getElement('.empty-list-view');
									var clearBtn = context.getElement('#clear');
									context.selItemSection.empty();
									if (emptyView&& emptyView.hasClassName('hidden')) {
										emptyView.removeClassName('hidden').addClassName('show');
									}
									if (clearBtn && !clearBtn.hasClassName('disabled')) {
										clearBtn.addClassName('disabled');
									}
									if (!(context.mode === 'single')) {
										context.actions.submitBtn.disable();
									}
								}
							},
							/**
							 * Function to fetch the service to Search for user
							 * typed item
							 *//*
							getPlatformServices : function() {
								var that = this;
								return new UWAPromise(function(resolve, reject) {
									i3DXCompassPlatformServices.getPlatformServices({
									onComplete : function(respServices) {
													if (UWA.is(respServices,'array') && respServices.length > 0) {
															that.platformServices = {};
															respServices.forEach(function(platform) {
																	that.platformServices[platform.platformId] = platform;
															});
														}
														resolve(that.platformServices);
														},
													onFailure : reject
													});
										});
							},*/
							/** Function to create content of the main Frame
							 * @param {Object} [options] options passed from the request page
							 **/
							_frameContentSection : function(options) {
								var that = this, contentSection, cssClass;
								that.mode = options.mode ? options.mode : 'single';
								if (that.mode === 'single') {
									cssClass = 'content-section-single';
								} else {
									cssClass = 'content-section-multiple';
								}
								// Create main content section element
								contentSection = new UWA.createElement('div',  {
									'class' : cssClass,
									'html' : template(options)
								});

								/** Validate section start */
								that._createValidateSection(options, contentSection);
								/** Validate section end */

								/** Reference Section start */
								that._createReferenceSection(options, contentSection);
								/** Reference Section end */
								return contentSection;
							},
							/** Function to create footer of the main Frame
							* @param {Object} [options] details passed from the request page
							**/
							_frameFooterSection : function(options) {
								var that = this, arrFooter = [];
								that.actions.submitBtn = new Button({
											id : 'xapp-related-item-submit',
											value : NLS.ConfirmationButton,
											disabled : true,
											className : 'primary',
											events : {
												onClick : function(event) {
													if (that.clearSelectedItem || (!that.clearSelectedItem && that.currentItems.length>0)){
													var extCheck = true;
															if (that.customValidateSelectedItems) {
																extCheck = that.customValidateSelectedItems(that.currentItems);
															}
														if (extCheck) {
															console.log('publish xapp-related-item-submit event');
															that.modelEvents.publish({
																			event : 'xapp-related-item-submit',
																			data : {
																					event : event,
																					items : that.currentItems
																				}
																			});
															that.relatedItemView.hide();
														} else {
															//CommonUtils.alertMessage('error', that.validationFailMessage, that.relatedItemView.getContent());
															that.alert.add({
																className : 'error',
																message : that.validationFailMessage
															});
														}
													} else {
														that.alert.add({
															className : 'error',
															message : 'Current Item cannot be blank. Please select an item.'
														});
													}
												}
											}
										});

								that.actions.cancelBtn = new Button({
									id : 'xapp-related-item-cancel',
									value : NLS.CancelButton,
									events : {
											onClick : function(event) {
											that.relatedItemView.hide();
										}
									}
								});
								arrFooter.push(that.actions.submitBtn);
								arrFooter.push(that.actions.cancelBtn);
								return arrFooter;
							},
							/** Function to create validate section
							 * @param {Object} [options] details passed from the request page
							 * @param {Object} [contentSection] container
							 **/
							_createValidateSection : function(options, contentSection) {
								var that = this, validateSection, emptyView;
								that.selItemSection = contentSection.getElement('.selected-item-section');
								validateSection = contentSection.getElement('.validate-section');
								emptyView = contentSection.getElement('.empty-list-view');
								that._makeDroppable(validateSection);
								that.dropInvite = contentSection.getElement('#drop-invite');
								that.suggestionSection = contentSection.getElement('.suggestion-section');
								if (that.mode === 'single') {
									validateSection.setStyle('height', '100px');
									that.dropInvite.addClassName('drop-invite-single');
									emptyView.setStyle('padding-top', '5%');
									if (options.currentItem && options.currentItem instanceof UWAModel) {
										that.currentItems.push(options.currentItem);
										that._manageCurrentItems({
											items : [ options.currentItem ]
										});
										emptyView.removeClassName('show').addClassName('hidden');
										contentSection.getElement('#clear').removeClassName('disabled');
									}
								} else {
									validateSection.setStyle('height', '320px');
									that.dropInvite.addClassName('drop-invite-multiple');
									emptyView.setStyle('padding-top', '30%');
								}
								if (options.suggestedItems){
									that._manageSuggestionSection({}, that.suggestedItemUtilityData.dataParserFunction(options.suggestedItems));
								}
							},
							/**Function to create Reference Section
							 * @param {Object} [contentSection] container
							 **/
							_createReferenceSection : function(options, contentSection) {
								// Create Search Section Start
								var searchSection = contentSection.getElement('.search-section');
								this._createSearchSection(options, searchSection);
								// Create Search Section End
							},
							/**Function to create Search Section
							 * @param {Object} [options] options passed by the App (to pass on list of Suggested Items)
							 * @param {Object} [searchSection] container
							 **/
							_createSearchSection : function(options, searchSection) {
								var that = this;
								that.itemSearchField = new Autocomplete({
									placeholder : NLS.SearchPlaceHolder,
									noResultsMessage : NLS.noResultMessage,
									minLengthBeforeSearch : 3,
									typeDelayBeforeSearch : 1100,
									events : {
										'onSelect' : that._onOptionSelect.bind(that)
									}
								}).inject(searchSection);
								that.itemSearchField.listData = {
									name : 'Items',
									items : [ {} ],
									configuration : {
										templateEngine : function(itemContainer,itemDataset, itemData) {
											itemContainer.addClassName('default-template people-search-template with-sub-label');
											UWA.createElement('img', {
												'src' : itemData.picture,
												'class' : 'searchResImage'
											}).inject(itemContainer);
											UWA.createElement('div', {
												'html' : itemData.value,
												'class' : 'item-label',
												'styles' : {
													'color' : '#368ec4'
												}
											}).inject(itemContainer);
											UWA.createElement('div', {
												'html' : itemData.subLabel1,
												'class' : 'sub-label',
												'styles' : {
													'font-size' : '10px'
												}
											}).inject(itemContainer);
											UWA.createElement('div', {
												'html' : itemData.subLabel2,
												'class' : 'sub-label',
												'styles' : {
													'font-size' : '10px'
												}
											}).inject(itemContainer);
										}
									}
								};
								that.itemSearchField.addDataset(that.itemSearchField.listData);
								if (that.dynamicInputKeySearch) {
									that.itemSearchField.elements.input.onkeypress = function(e) {
										var filterKey = e.target.value.trim();
										if (filterKey) {
											that.filterData(filterKey);

											/*if (!that.platformServices) {
												that.getPlatformServices().then(
														function() {
															that.filterData(filterKey);
														}, function(errors) {
															throw new Error(errors);
														});
											} else {
												that.filterData(filterKey);
											}*/
										}
									};
								} else if (that.itemSearchRequired){
									var fetchOpts = that.itemUtilityData.fetchOpts;
									that.connectURL(that.itemUtilityData.url,fetchOpts).then(function(response){
										var dataArray = that.itemUtilityData.dataParserFunction(response);
										that.itemSearchField.cleanDataset(0);
										that.itemSearchField.addItems(dataArray, that.itemSearchField.datasets[0]);
										//that.itemSearchField.listData.items.push(dataArray);
									});
								} else {
									var dataArray = that.itemUtilityData.dataParserFunction(options.suggestedItems);
									that.itemSearchField.cleanDataset(0);
									that.itemSearchField.addItems(dataArray, that.itemSearchField.datasets[0]);
								}
							},
							/** Function to handle Drag and Drop behavior
							 * @param {Object} droppableElement - container
							 **/
							_makeDroppable : function(droppableElement) {
								var that = this;
								var dragEvents = {
									enter : function() {
										droppableElement.addClassName('droppable');
										that.dropInvite.removeClassName('hidden');
										that.dropInvite.addClassName('show');
									},
									leave : function() {
										if (droppableElement.hasClassName('droppable')) {
											droppableElement.removeClassName('droppable');
										}
										that.dropInvite.removeClassName('show');
										that.dropInvite.addClassName('hidden');
									},
									over : function() {
										droppableElement.addClassName('droppable');
										that.dropInvite.removeClassName('hidden');
										that.dropInvite.addClassName('show');
									},
									drop : function(dropData, el, event) {
										dropData = UWA.is(dropData, 'string') ? JSON.parse(dropData): dropData;
										var items = dropData.data && dropData.data.items ? dropData.data.items : null;
										var acceptedItems = that._validateChosenItems(items);
										if (acceptedItems && acceptedItems.length > 0) {
											var i, itemsLength = acceptedItems.length, arrItems = [];
											for (i = 0; i < itemsLength; i++) {
												arrItems.push(new UWAModel(
													{
														id : acceptedItems[i].objectId,
														title : acceptedItems[i].displayName,
														subtitle : acceptedItems[i].displayType
													}));
											}
											that._manageCurrentItems({
												items : arrItems,
												ctxElement : el,
												event : event
											});
											/*that.modelEvents.publish({
														event : 'xapp-related-item-validate',
														data : {
															event : event,
															items : arrItems
														}
													});*/
										}
										if (droppableElement.hasClassName('droppable')) {
											droppableElement
													.removeClassName('droppable');
										}
										that.dropInvite.removeClassName('show');
										that.dropInvite.addClassName('hidden');
									}
								};
								DataDragAndDrop.droppable(droppableElement, dragEvents);
							},
							/** Function to manage the Suggestion Card section
							 * @param {Object} [card] current chosen item's card
							 * @param {array} [suggestedItems] Suggestions for the current chosen item
							 **/
							_manageSuggestionSection : function(card, suggestedItems) {
								var that = this, arraySuggestedItem = [], i, suggLength = suggestedItems.length, suggestedItemCards = [];
								var suggestionScrollSection = that.getElement('.suggestion-scroll-section');
								var eventObject, suggestedCard;
								// Creating a scroll container for Suggestion Section
								if (!suggestionScrollSection) {
									suggestionScrollSection = UWA.createElement('div', {'class' : 'suggestion-scroll-section'});
									that.suggestionScrollContent = new UWA.Element('div', {'class' : 'item-scroll-section-content'}).inject(suggestionScrollSection);
									that._addScroller(that.suggestionSection,
											suggestionScrollSection);
								} else {
									if (that.mode === 'single') {
										that.suggestionScrollContent.empty(true);
									}
								}
								// Creating Suggestion Cards for the Item suggestions
								for (i = 0; i < suggLength; i++) {
									arraySuggestedItem.push(new UWAModel({
										id : suggestedItems[i].id,
										title : suggestedItems[i].title,
										subtitle : suggestedItems[i].subtitle,
										image : suggestedItems[i].image
									}));
									eventObject = {
										'onSelect' : that._onCardSelect,
										'onCancel' : that._onCardCancel
									}
									suggestedCard = that._createCard(false, that.needImage, that, arraySuggestedItem[i], eventObject);
									suggestedCard.inject(that.suggestionScrollContent);
									suggestedItemCards.push(suggestedCard);
								}
								// Liknking the Suggestion cards created with the Item
								if (card) {
									card.suggestions = suggestedItemCards;
								}
							},
							/**
							 * Function to manage the selected items when mode is single / multi selection
							 * @param {Object} [options] details of the current selected item
							 */
							_manageCurrentItems : function(options) {
								var that = this, items = options.items, flag = true, eventObject, card;
								if (that.mode === 'multiple') {
									var scrollSection = that.getElement('.selected-item-scroll-section');
									// Creating Scroller for selected Items in multiple selection mode
									if (!scrollSection) {
										scrollSection = UWA.createElement('div',{'class' : 'selected-item-scroll-section'});
										that.scrollSectionContent = new UWA.Element('div',{'class' : 'item-scroll-section-content'}).inject(scrollSection);
										that._addScroller(that.selItemSection,scrollSection);
									}
									// Checking if the item is already present in the selected list
									that.currentItems.forEach(function(item) {
										if (item.id === items[0].id) {
											flag = false;
										}
									});
									if (flag) {
										that.currentItems.push(items[0]);
										eventObject = {
											'onCancel' : that._onCardCancel
										};
										card = that._createCard(true, that.needImage, that, items[0], eventObject);
										card.inject(that.scrollSectionContent);
										// Fetching suggestions for the selected item
										that._fetchSuggestedItems(items[0], card);
										if (that.actions.submitBtn.isDisabled()) {
											that.actions.submitBtn.enable();
										}
									}
								} else {
									var eventObject, card, suggestions;
									that.currentItems.splice(0); //Single selection only one item will be present - this will clear the array
									that.selItemSection.empty();
									that.currentItems.push(items[0]);
									eventObject = {
										'onCancel' : that._onCardCancel
									}
									card = that._createCard(false, that.needImage, that, items[0], eventObject, true);
									card.inject(that.selItemSection);
									this._fetchSuggestedItems(items[0],card);
									if (that.actions.submitBtn && that.actions.submitBtn.isDisabled) {
										that.actions.submitBtn.enable();
									}
								}
								if (that.currentItems.length > 0) {
									var emptyView = that.getElement('.empty-list-view');
									var clearBtn = that.getElement('#clear');
									if (emptyView && emptyView.hasClassName('show')) {
										emptyView.removeClassName('show');
										emptyView.addClassName('hidden');
									}
									if (clearBtn && clearBtn.hasClassName('disabled')) {
										clearBtn.removeClassName('disabled');
									}
								}
							},
							/** Function to validate items added through drag and drop
							 * @param {array} [items] - list of items to be validated
							 * @returns {array} [acceptedItems] - valid list of chosen items
							 **/
							_validateChosenItems : function(items) {
								var that = this, i, itemsLength = items.length, allowedTypes = that.allowedTypes, acceptedItems = [], rejectedItems = [];
								if (that.mode === 'single' && items.length > 1) {
									that.alert.add({
												className : 'warning',
												message : NLS.WarningForMultipleItemsSelection
											});
								} else {
									for (i = 0; i < itemsLength; i++) {
                  //5 --- allowed types have backend and display values
										if (allowedTypes.typeValues && allowedTypes.typeValues.indexOf(items[i].objectType) < 0) {
											rejectedItems.push(items[i].displayName);
										} else {
											acceptedItems.push(items[i]);
										}
									}
									if (rejectedItems.length > 0) {
										that.alert.add({
													className : 'error',
													message : NLS.AllowedTypes+allowedTypes.displayValues.toString()+NLS.TypesNotAllowed+ rejectedItems.toString()
												});
									}
								}
								return acceptedItems;
							},
							/** Function to filter for user searched items and parse related data
							 * @param {String} [filterKey] key used to search for the data
							 **/
							filterData : function(filterKey) {
								var that = this;
								var fetchOpts = that.itemUtilityData.fetchOptsFunction(filterKey);


								that.connectURL(that.itemUtilityData.url,fetchOpts).then(function(response){
									var dataAarray = that.itemUtilityData.dataParserFunction(response);
									that.itemSearchField.cleanDataset(0);
									that.itemSearchField.addItems(dataAarray, that.itemSearchField.datasets[0]);
								});
							},
							/** Function to fetch item data from the given search URL
							 * @param {String} [filterKey] key used to search for the data
							 **/
							connectURL : function(url, options) {
								return new UWAPromise(function(resolve, reject) {
									options.onComplete = resolve;
									options.onTimeout = reject;
									WAFData.authenticatedRequest(url, options);
								});

							}
						});
			return ENOXRelatedItem;
		});
