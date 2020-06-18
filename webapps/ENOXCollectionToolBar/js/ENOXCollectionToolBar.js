/*XSS_CHECKED*/
/** Sample is available at FW ENOXTriptych.tst/ENOTriptychTst.mweb/src/ENOXTriptych_sample.html */
define('DS/ENOXCollectionToolBar/js/ENOXCollectionToolBar', [
	'DS/Core/ModelEvents',
	'DS/Handlebars/Handlebars',
	'DS/Controls/Toggle',
	'DS/UIKIT/Iconbar',
	'DS/UIKIT/IconDropdown',
	'DS/UIKIT/DropdownMenu',
	'DS/UIKIT/Tooltip',
    'DS/ResizeSensor/js/ResizeSensor',
	'DS/ENOXViewFilter/js/ENOXBasicFilter',
	'i18n!DS/ENOXCollectionToolBar/assets/nls/ENOXCollectionToolBar',
	'text!DS/ENOXCollectionToolBar/html/ENOXCollectionToolBar.html',
	'css!DS/ENOXCollectionToolBar/css/ENOXCollectionToolBar.css',
	'css!DS/UIKIT/UIKIT.css'
	],

	function (
			ModelEvents,
			Handlebars,
			Toggle,
			Iconbar,
			IconDropdown,
			DropdownMenu,
			Tooltip,
            ResizeSensor,
			ENOXViewFilter,
			nls_ENOXCollectionToolBar,
			html_ENOXCollectionToolBar,
			css_ENOXCollectionToolBar,
			css_uikit

	) {

	/**
	 * example of options here below:
	 */

	'use strict';

	Handlebars.registerHelper('sort_type_check', function(currentType, compareToType, opts) {
		if(currentType == compareToType)
			return opts.fn(this);
		else
			return opts.inverse(this);
	});

	var template = Handlebars.compile(html_ENOXCollectionToolBar);

	var ENOXCollectionToolBar = function (options) {
		this._init(options);
	};
	/*****************************************************INITIALIZATION*************************************************************/

	ENOXCollectionToolBar.prototype._init = function(options){
		this._options = options ? UWA.clone(options, false) : {};
		var defaults = {currentNbitems : 0, currentNbSelections: 0};	//Default values if not provided by options
		//this._myID = "collectionToolbar_instance_" + Date.now();
		UWA.merge(this._options, defaults);
		this._options.multiselectActionCount = (this._options.multiselActions && this._options.multiselActions.length > 0) ? this._options.multiselActions.length : undefined;
		this._options.itemName = (options.itemName) ? options.itemName : nls_ENOXCollectionToolBar.Item;
		this._options.itemsName = (options.itemsName) ? options.itemsName : nls_ENOXCollectionToolBar.Items;
		this._modelEvents = options.modelEvents ? options.modelEvents : new ModelEvents();
		this._applicationChannel = options.applicationChannel ? options.applicationChannel : new ModelEvents();
        this._setMultiselectionActions();
		this._subscribeToEvents();
		this._initDivs();
		this._render();
	};

	ENOXCollectionToolBar.prototype._initDivs = function () {
		this._container = document.createElement('div');
		this._options.nls = nls_ENOXCollectionToolBar;
		this._container.innerHTML = template(this._options);

		this._container = this._container.querySelector('.enox-collection-toolbar-container');
		this._multiSelectContainer = this._container.querySelector('.enox-collection-toolbar-withmultisel');
		this._itemCountContainer = this._container.querySelector('.enox-collection-toolbar-item-count-inner');
		this._filterIconContainer = this._container.querySelector('.enox-collection-toolbar-filter');
		this._finalItemContainer = this._container.querySelector('.enox-collection-toolbar-finalItem');
		this._filterContainer = this._container.querySelector('.enox-collection-toolbar-search-textbox-container');
		this._multiselectionWrapperContainer = this._container.querySelector('.enox-collection-toolbar-multiselection-wrapper');
		this._multiselectionContainer = this._container.querySelector('.enox-collection-toolbar-multiselection');
		this._multiselectionOptions = this._container.querySelector('#enox-collection-toolbar-multiselect-options');
		this._multiselectionCount = this._container.querySelector('.enox-collection-toolbar-multiselect-count');
		this._multiselectionDivider = this._container.querySelector('#enox-collection-toolbar-multiselect-divider');
		this._actionsContainer = this._container.querySelector('.enox-collection-toolbar-actions');
		this._viewsBase = this._container.querySelector('#enox-collection-toolbar-views-base');
		this._sortBase = UWA.extendElement(this._container.querySelector('#enox-collection-toolbar-sort-base'));
		this._rightMenuContainer = this._container.querySelector('.enox-collection-toolbar-right-menu');


        //[xlv:040618]:START
        //To avoid "w.parentElement.hasClassName is not a function" kind of error on hover of sort dropdown menu & icons in it.
        var sortOrderDivs = this._container.getElementsByClassName('enox-collection-toolbar-sort-order');
        if(sortOrderDivs && sortOrderDivs.length > 0) {
            for(var i =0 ; i< sortOrderDivs.length; i++){
                var srtOrdrDiv =  sortOrderDivs[i];
                if(srtOrdrDiv) {
                    UWA.extendElement(srtOrdrDiv);
                    var childElems = srtOrdrDiv.children; //assuming all of these are span elements for icons for asc/desc order.
                    for(var j=0 ; j <childElems.length ; j++){
                        UWA.extendElement(childElems[j]);
                    }
                }
            };
        }
	    //[xlv:040618]:END
        /************************************************* responsive ******************************************/
	};

	ENOXCollectionToolBar.prototype.inject = function(parentcontainer) {
	    var that = this;
		parentcontainer.appendChild(this._container);
        this._resizeSensorInst = new ResizeSensor(this._container, function(e) {
            if(that._container.offsetWidth > 0 && that._container.offsetWidth !== that._currentWidth){
                that._resize();
                that._currentWidth = that._container.offsetWidth;
            }
        });
	};

	/*****************************************************FUNCTIONALITIES INITIALIZATION**********************************************/

	ENOXCollectionToolBar.prototype._render = function () {
		var that = this;
		if(this._options.withmultisel){
			UWA.extendElement(this._multiSelectContainer);
			this._selectionToggler = new Toggle({ type: 'checkbox', allowUnsafeHTMLLabel: false}).inject(this._multiSelectContainer);
			this._selectionToggler.addEventListener('buttonclick', function(e) {
     		that._selectionToggler.checkFlag ?
							that._modelEvents.publish({event: 'enox-collection-toolbar-all-selected'}) :
							that._modelEvents.publish({event: 'enox-collection-toolbar-all-unselected'}) ;
	 		});
		}
		this._renderSearch();
		this._renderMultiselection();
		this._renderOtherActions();
		this._renderViews();
		this._renderSort();
	};

	/*****************************************************EVENTS HANDLED*************************************************************/

	ENOXCollectionToolBar.prototype._subscribeToEvents= function() {
		var that= this;
		this._listSubscription = [];

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-hide-checkbox'}, function (itemCount) {
			if(that._selectionToggler){
				that._selectionToggler.hide();
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-show-checkbox'}, function (itemCount) {
			if(that._selectionToggler){
				that._selectionToggler.show();
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-select-all-checkbox-partial'}, function (itemCount) {
			if(that._selectionToggler){
				that._selectionToggler.checkFlag = true;
				that._selectionToggler.mixedState = true;
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-select-all-checkbox-uncheck'}, function (itemCount) {
			if(that._selectionToggler){
				that._selectionToggler.mixedState = false;
				that._selectionToggler.checkFlag = false;
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-select-all-checkbox-checked'}, function (itemCount) {
			if(that._selectionToggler){
				that._selectionToggler.mixedState = false;
				that._selectionToggler.checkFlag = true;
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-items-count-update'}, function (itemCount) {
		    if (itemCount === 0 || itemCount === 1) { that._itemCountContainer.innerHTML = itemCount + " " + that._options.itemName; }
		    else { that._itemCountContainer.innerHTML = itemCount + " " + that._options.itemsName; }
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-selections-count-update'}, function (count) {
				that._multiselectionCount.innerHTML = count;
				that._multiselectionWrapperContainer.style.display = (count === 0) ? 'none' : 'inline-block';
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-set-multisel-actions'}, function (options) {
			that._multiselectActionsDD.destroy();
			that._setMultiselectionActions(options);
			that._renderMultiselection(options);
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-add-action'}, function (item) {
			that._actionsIconBar.addItem({id:item.id, fonticon: item.icon, text: item.title, handler:item.onClick});
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-remove-action'}, function (id) {
				that._actionsIconBar.menu.removeItem(id);
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-disable-action'}, function (id) {
			var item = that._actionsIconBar.getItem(id);
			if(item){
				/*******Extra code - had to add because iconbar does not support disable of dropdown and handler*********/
				that._actionsIconBar.menu.removeItem(item.id);
				that._actionsIconBar.addItem({id:item.id, fonticon: item.fonticon, text: item.text,
					handlerfun :item.handlerfun, selected : false, allowSelectRetain:item.allowSelectRetain});
				var item = that._actionsIconBar.getItem(item.id);
				item.disabled = true;
				/*******Extra code - to be removed once the changes are received from uikit/iconbar component***********/

				item.elements.container.addClassName("enox-collection-toolbar-item-disable");
				that._actionsIconBar.menu.disableItem(id);
			}
		}));

		this._listSubscription.push(this._modelEvents.subscribe({ event: 'enox-collection-toolbar-enable-action'}, function (id) {
			that._actionsIconBar.menu.enableItem(id);
			var item = that._actionsIconBar.getItem(id);
			if(item){
				that._actionsIconBar.menu.removeItem(item.id);
				that._actionsIconBar.addItem({id:item.id, fonticon: item.fonticon, text: item.text, content : that._wrapperContent[item.id],
					handlerfun :item.handlerfun, selected : false, allowSelectRetain:item.allowSelectRetain});
			}
		}));
	};

	/***************************************************** SEARCH *************************************************************/

	ENOXCollectionToolBar.prototype._renderSearch = function () {
		var that = this;

		this.filterIconbar = new Iconbar(
			{renderTo: this._filterIconContainer, tooltipsTrigger :"touch", items : [{id: "enox-collection-toolbar-search-id", fonticon : 'search', text: nls_ENOXCollectionToolBar.Search_Tooltip,
			handler : function(e,i){
				var filter = that._searchComponent._container;
				filter.style.display = (filter.style.display === 'none') ? 'inline-block' : 'none';
				if(filter.style.display !== 'none'){
					i.elements.container.addClassName("enox-collection-toolbar-filter-activated");
					that._searchComponent.searchTextBox._updateInnerInputFocus(0);
				    // that._searchComponent.searchTextBox.elements.input.focus();
				}else{
					if(i.elements.container.hasClassName("enox-collection-toolbar-filter-activated")) {
						i.elements.container.removeClassName("enox-collection-toolbar-filter-activated");
						that._searchComponent._modelEvents.publish({event: 'enox-basic-filter-reset-search'});
					}
				}
				that._resize();
			}}]});
		if(!this._searchComponent){
			var filterOptions = this._options.filter ? this._options.filter : {};
			this._searchComponent = new ENOXViewFilter(filterOptions);
			this._searchComponent._modelEvents.subscribe({ event: 'enox-basic-filter-search-value'}, function (data) {
				that._modelEvents.publish({event: 'enox-collection-toolbar-filter-search-value', data : data});
			});
			this.filter = UWA.extendElement(this._searchComponent._autocomplteWrapper);
			this._searchComponent.inject(this._filterContainer);
			// this._searchComponent._container.style.display = 'none';
			this.setSearchVisibility(false);
		}
	};

	ENOXCollectionToolBar.prototype.setSearchVisibility = function(flag){
		var searchIcon = this.filterIconbar.getItem("enox-collection-toolbar-search-id");
		if(flag){
			this._searchComponent._container.style.display = 'inline-block';
			if(searchIcon)searchIcon.elements.container.addClassName("enox-collection-toolbar-filter-activated");
		}else{
			this._searchComponent._container.style.display = 'none';
			if(searchIcon)searchIcon.elements.container.removeClassName("enox-collection-toolbar-filter-activated");
		}
	};

	ENOXCollectionToolBar.prototype.setSearchText = function(input){
		if(this._searchComponent){
			this._searchComponent.setText(input);
		}
	};

	/*****************************************************MULTISELCTIONS*************************************************************/

	ENOXCollectionToolBar.prototype._renderMultiselection = function (options) {
		var that = this;
		if(this._multiselectionActions){
			this._multiselectActionsDD = new DropdownMenu({target: this._multiselectionOptions, items: [],
				events : {
					onClick : function(e,i){i.handler(e,i);}.bind(this)
				}});
			for(var i = 0; i < this._multiselectionActions.length ; i++){
				this._multiselectActionsDD.addItem({id:this._multiselectionActions[i].id, text: this._multiselectionActions[i].text,fonticon : this._multiselectionActions[i].fonticon,
					handler : this._multiselectionActions[i].handler});
			}
			new Tooltip({target: this._multiselectionContainer, body: nls_ENOXCollectionToolBar.Multiselection_Tooltip});
		}else if (this._options.multiselActionCallback && this._multiselectionWrapperContainer ) {
			that._multiselectionOptions.addEventListener("click", function(){
			that._options.multiselActionCallback.call(null,that._multiselectionWrapperContainer);
			});
		}

		if(this._multiselectionWrapperContainer){
			this._multiselectionWrapperContainer.style.display = (this._options.currentNbSelections === 0) ? 'none' : 'inline-block';
			if(this._multiselectionDivider)this._multiselectionDivider.style.display = (this._options.currentNbSelections === 0) ? 'none' : 'inline-block';
		}
	};

	/*****************************************************OTHER ACTIONS*************************************************************/

	ENOXCollectionToolBar.prototype._renderOtherActions = function () {
		var actions = this._options.actions;
		if(actions){
			this._wrapperContent = [];
			this._actionsIconBar = new Iconbar({renderTo: this._actionsContainer, tooltipsTrigger :"touch", events : {
				onClick : function(e,i){
					if(i && !i.disabled){
						if(i.allowSelectRetain){
							i.selected = !i.selected;
							i.selected ? i.elements.container.addClassName("enox-collection-toolbar-filter-activated") : i.elements.container.removeClassName("enox-collection-toolbar-filter-activated");
						}
						if(!i.content){
							i.handlerfun(e,i);
						}
					}
				}
			}});
			for(var i = 0; i < actions.length ; i++){
				var that = this;
				actions[i].disabled = actions[i].disabled || false;
				var contentItems = actions[i].content || [];
				var content = {};
				if(contentItems.length > 0){
					content = {
						type: 'dropdownmenu',
                options: {items: contentItems,
									events: {
	        					onClick: function (e, item) { if(item && !item.disabled){
											this.handler(e,item);
										} }.bind(actions[i])
	    						}
								}

					}
					this._wrapperContent[actions[i].id] = content;
					var className = actions[i].className ? actions[i].className : '';
					this._actionsIconBar.addItem({className: className, id:actions[i].id, fonticon: actions[i].fonticon, text: actions[i].text, disabled : actions[i].disabled,
						content : this._wrapperContent[actions[i].id], handlerfun :actions[i].handler, selected	 : false, allowSelectRetain:actions[i].allowSelectRetain});
				}else{
					this._actionsIconBar.addItem({ className: className, id:actions[i].id, fonticon: actions[i].fonticon, text: actions[i].text,
						handlerfun :actions[i].handler, selected : false, allowSelectRetain:actions[i].allowSelectRetain, disabled:actions[i].disabled});
				}

				if(actions[i].disabled){
					this._modelEvents.publish({ event: 'enox-collection-toolbar-disable-action', data:actions[i].id});
				}
			}
		}
	};

	/*****************************************************VIEWS *************************************************************/

	ENOXCollectionToolBar.prototype._renderViews = function () {
		var that = this, currentView;
		var views = this._options.views;
		if(views && views.length > 0){
			currentView = this._find(views, this._options.currentView);
			this._viewsBase.className = "fonticon fonticon-" + currentView.fonticon;
			var _viewsTooltip = new Tooltip({target: this._viewsBase, body: currentView.text, trigger: 'touch'});
			var _viewsDropdown = new IconDropdown({
				target: this._viewsBase,
				items: [],
				events: {
					onClick: function (e, item) {
						that._viewsBase.set('class', item.elements.icon.className);
						_viewsTooltip.setBody(item.description);
						that._modelEvents.publish({event: 'enox-collection-toolbar-switch-view-activated', data : item.id});
					}
				}
			});
			for(var i = 0; i < views.length ; i++){
				_viewsDropdown.addItem({id:views[i].id, fonticon: views[i].fonticon, description: views[i].text, selected : views[i].selected});
			}

		}
	};

	ENOXCollectionToolBar.prototype._renderSort = function () {
		var sortOptions = this._options.sort;
		if(sortOptions && sortOptions.length > 0){
			this._sortBase.className = "fonticon fonticon-fonticon fonticon-sorting";
			new Tooltip({target: this._sortBase, body: nls_ENOXCollectionToolBar.Sort_Tooltip, trigger: 'touch'});

			this._sortDropdown = new DropdownMenu({
				target: this._sortBase, items: [], events : {
					onClick : function(e, i){
						var sortOrder, sortAttribute = i.id;
						var target = UWA.extendElement(e.target);

						if(target.hasClassName('fonticon')){
							this._sortBase.set('class', target.className);
							this._updateSortStyleInDD(target, i.id);

							if(target.hasClassName('order-desc')) sortOrder = "DESC";
							else if(target.hasClassName('order-asc')) sortOrder = "ASC"
								else sortOrder = "";

							this._modelEvents.publish({event: 'enox-collection-toolbar-sort-activated', data : {sortOrder : sortOrder, sortAttribute: sortAttribute}});
						}
					}.bind(this)
				}
			});

			for(var i = 0; i < sortOptions.length ; i++){
				this._sortDropdown.addItem({id:sortOptions[i].id, className:"enox-collection-toolbar-sort-item", text: sortOptions[i].text, name:sortOptions[i].type});
			}
			for(var i = 0; i < this._sortDropdown.items.length ; i++){
				var _sortRow = this._container.querySelector('#enox-collection-toolbar-sort-item-' + this._sortDropdown.items[i].id);
				this._sortDropdown.items[i].elements.container.appendChild(_sortRow);
			}
			this._activateCurrentSort();
		}
	};

	ENOXCollectionToolBar.prototype._setMultiselectionActions = function (options) {
		this._multiselectionActions = options ? options : this._options.multiselActions;
	};

	ENOXCollectionToolBar.prototype._updateSortStyleInDD = function (target, id) {
		this._sortOrders = this._sortDropdown.elements.container.getElementsByClassName('enox-collection-toolbar-order-style');
		if(this._sortOrders && this._sortOrders.length > 0 ){
			for(var j = 0; j<this._sortOrders.length ; j++){
				var el = UWA.extendElement(this._sortOrders[j]);
				if(el.hasClassName("enox-collection-toolbar-sort-activated"))
					el.removeClassName("enox-collection-toolbar-sort-activated");

				if(target.className === el.className && el.getParent().id === "enox-collection-toolbar-sort-item-" + id)
					el.addClassName("enox-collection-toolbar-sort-activated");
			}
		}
	};

	ENOXCollectionToolBar.prototype._activateCurrentSort = function () {
		if(this._options.currentSort){
			var currentSort = this._find(this._options.sort, this._options.currentSort.id);
			if(currentSort.type === "string" && this._options.currentSort.order === "ASC"){
				this._sortBase.className = "fonticon-sort-alpha-asc";
			}
			else if(currentSort.type === "string" && this._options.currentSort.order === "DESC"){
				this._sortBase.className = "fonticon-sort-alpha-desc";
			}
			else if(currentSort.type === "integer" && this._options.currentSort.order === "ASC"){
				this._sortBase.className = "fonticon-sort-num-asc";
			}
			else if(currentSort.type === "integer" && this._options.currentSort.order === "DESC"){
				this._sortBase.className = "fonticon-sort-num-desc";
			}
			var sortItemInDD = this._sortDropdown.elements.container.querySelector("#enox-collection-toolbar-sort-item-" + this._options.currentSort.id);
			var sortOrderIconInDD = sortItemInDD.querySelector('.' + this._sortBase.className);
			this._updateSortStyleInDD(sortOrderIconInDD);
			this._sortBase.className = "fonticon " + this._sortBase.className;
		}
	};

    ENOXCollectionToolBar.prototype._resize = function () {
        var that = this, width;
        var total_width = this._container.offsetWidth;
        var width = total_width - (this._rightMenuContainer.offsetWidth - this._filterContainer.offsetWidth + (this._itemCountContainer? this._itemCountContainer.offsetWidth :0) + (this._multiSelectContainer ? this._multiSelectContainer.offsetWidth : 0));
        if (width >= 420) {
        	that.filter.style.width = "400px";
            //that._filterContainer.style.width = "400px";
        } else if (width < 420 && width >= 320) {
        	that.filter.style.width = "300px";

        } else if (width < 320 && width >= 220) {
        	that.filter.style.width = "200px";
        }else if (width < 220 && width >= 120) {
        	that.filter.style.width = "120px";
        }else {
        	if(that._container.offsetHeight > 70){
        		width = total_width - (this._rightMenuContainer.offsetWidth - this._filterContainer.offsetWidth + (this._multiSelectContainer ? this._multiSelectContainer.offsetWidth : 0)) - 20;
        	}
        	if(width > 70){
        		that.filter.style.width = width + "px";
        	}else {
        		that.filter.style.width = "70px";
        	}
        }
        this._modelEvents.publish({event: 'enox-collection-toolbar-on-toolbar-height-change', data : that._container.offsetHeight});
	};


	ENOXCollectionToolBar.prototype._find = function (array, id) {
		var currentObj;
		/*function check(obj){
			return obj.id === id;
		}
		var currentObj = array.find(check);*/ //Not supported on IE11. Supported on IE12.
		array.forEach(function(item){
			if(item.id === id){
				item.selected = true;
				currentObj = item;
				return;
			}
		})
		if(!currentObj){
			currentObj = array[0];
			array[0].selected = true;
		}
		return currentObj;
	};


  //Below function seems to be not used anywhere. Kept to avoid any other app breaking for it!!!
	ENOXCollectionToolBar.prototype.attachResizeSensor = function () {
	    var that = this;
	    function debounce(func, wait, immediate) {
	        var timeout;
	        return function () {
	            var context = this, args = arguments;
	            var later = function () {
	                timeout = null;
	                if (!immediate) func.apply(context, args);
	            };
	            var callNow = immediate && !timeout;
	            clearTimeout(timeout);
	            timeout = setTimeout(later, wait);
	            if (callNow) func.apply(context, args);
	        };
	    };

	    var myEfficientFn = debounce(this._resizeToolbar,200, false);
	    this.resizeSensor = new ResizeSensor(this._container, function () {
	        myEfficientFn();
	    });
	};

	ENOXCollectionToolBar.prototype._injectFinalItem = function (htmlElement) {
		UWA.extendElement(this._finalItemContainer);
	htmlElement.inject(this._finalItemContainer);
	};

	return ENOXCollectionToolBar;
});
