define(
		'DS/ENOXCollectionToolBar/js/ENOXGeneratedToolBar',
		[
				'DS/TreeModel/TreeDocument',
				'DS/TreeModel/TreeNodeModel',
				'DS/Tweakers/TypeRepresentationFactory',
				'DS/Tweakers/GeneratedToolbar',
				'DS/ENOXCollectionToolBar/js/ENOXCheckBoxMultipleTextComponant',
				'DS/ENOXCollectionToolBar/js/ENOXSortComponant',
				'DS/ENOXCollectionToolBar/js/ENOXFunctionIconComponant',
				'DS/ENOXCollectionToolBar/js/ENOXGroupComponant',
				'DS/ENOXCollectionToolBar/js/ENOXViewsComponant',
				'DS/ENOXCollectionToolBar/js/ENOXSearchComponant',
				'DS/CoreEvents/ModelEvents' ],
		function(TreeDocument, TreeNodeModel, TypeRepresentationFactory,
				GeneratedToolbar, ENOXCheckBoxMultipleText, ENOXSortComponant,
				ENOXFunctionIconComponant, ENOXGroupComponant,
				ENOXViewsComponant, ENOXSearchComponant, ModelEvent) {

			// ---------- Options ------------ //
			// ! All options are optional !
			// PS : For more details about attributs check the componant.
			// - checkTextOptions ()
			// 'DS/ENOXCollectionToolBar/js/ENOXCheckBoxMultipleTextComponant'
			// - sortOptions
			// 'DS/ENOXCollectionToolBar/js/ENOXSortComponant'
			// - functionIconWidget
			// 'DS/ENOXCollectionToolBar/js/ENOXFunctionIconComponant'
			// - groupOptions
			// 'DS/ENOXCollectionToolBar/js/ENOXGroupComponant'
			// - viewsOptions
			// 'DS/ENOXCollectionToolBar/js/ENOXViewsComponant'
			// - searchOptions
			// 'DS/ENOXCollectionToolBar/js/ENOXSearchComponant'
			// - modelEvent
			// 'DS/CoreEvents/ModelEvents'
			// - touch (activing the touch mode or not)
			// Boolean
			// ---------- EnD Options ------------ //

			var ENOXGeneratedToolBar = function(options) {
				if (options) {
					this._options = options;

					// CheckBoxMultipleTextComponant options
					this._checkTextOptions = this._options.checkTextOptions;

					// SortWidget options
					this._sortOptions = this._options.sortOptions;

					// FunctionIconComponant options
					this._functionIconWidget = this._options.functionIconWidget;

					// GroupComponant options
					this._groupOptions = this._options.groupOptions;

					// ViewsComponant options
					this._viewsOptions = this._options.viewsOptions;

					// SearchComponant options
					this._searchOptions = this._options.searchOptions;

					// ModelEvent
					this._options.modelEvent = options.modelEvent;

					// TouchMode
					this._options.touch = options.touch;
				}

				this._toolbarTreeDocument = new TreeDocument({});
				this._typeRepFactory = new TypeRepresentationFactory();

				this._init();
			};

			ENOXGeneratedToolBar.prototype._init = function() {

				this._generatedToolBar = null;
				if (this._checkTextOptions) {
					this._createCheckBoxMultipleText();
				}
				if (this._searchOptions) {
					this._createSearchComponant()
				}
				if (this._sortOptions) {
					this._createSortComponant();
				}
				if (this._functionIconWidget) {
					this._mapOptionsFunctionIconComponant()
				}
				if (this._groupOptions) {
					this._createGroupComponant()
				}
				if (this._viewsOptions) {
					this._createViewsComponant()
				}
				
				this._createContainerToolBar();
			};

			// Function to create the CheckBoxMultipleTextComponant
			ENOXGeneratedToolBar.prototype._createCheckBoxMultipleText = function() {
				if (this._checkTextOptions !== undefined
						&& this._checkTextOptions.active) {
					var visible;
					var enabled;
					var number;
					var check;
					if (this._checkTextOptions.initialState !== undefined) {
						visible = this._checkTextOptions.initialState.visible;
						enabled = this._checkTextOptions.initialState.enabled;
						check = this._checkTextOptions.initialState.check;
						number = this._checkTextOptions.initialState.number;
					}

					var optionsCheckBoxMultipleText = {
						single : this._checkTextOptions.single,
						multiple : this._checkTextOptions.multiple,
						withCheckBox : this._checkTextOptions.withCheckBox,
						number : number,
						check : check,
						enabled : enabled,
						visible : visible,
						touch : this._options.touch,
						modelEvent : this._options.modelEvent
					}
					this._enoxCheckBoxMultiple = new ENOXCheckBoxMultipleText(
							optionsCheckBoxMultipleText);

					this._enoxCheckBoxMultiple
							.addToTreeDocument(this._toolbarTreeDocument);
				}
			}

			// Function to create the SortComponant
			ENOXGeneratedToolBar.prototype._createSortComponant = function() {
				if (this._sortOptions !== undefined && this._sortOptions.active) {
					var visible;
					var enabled;
					var select;
					var order;
					if (this._sortOptions.initialState !== undefined) {
						visible = this._sortOptions.initialState.visible;
						enabled = this._sortOptions.initialState.enabled;
						select = this._sortOptions.initialState.select;
						order = this._sortOptions.initialState.order;
					}
					var optionsSortWidget = {
						select : select,
						visible : visible,
						enabled : enabled,
						order : order,
						values : this._sortOptions.values,
						touch : this._options.touch,
						modelEvent : this._options.modelEvent
					}
					this._ENOXSortComponant = new ENOXSortComponant(
							optionsSortWidget);
					// Register the custom typreRepresentation Factory
					this._ENOXSortComponant
							.registerTypeRepresentations(this._typeRepFactory);
					this._ENOXSortComponant
							.addToTreeDocument(this._toolbarTreeDocument);
				}
			}

			// Function to create the GroupComponant
			ENOXGeneratedToolBar.prototype._createGroupComponant = function() {
				if (this._groupOptions !== undefined
						&& this._groupOptions.active) {
					var visible;
					var enabled;
					var select;
					if (this._groupOptions.initialState !== undefined) {
						visible = this._groupOptions.initialState.visible;
						enabled = this._groupOptions.initialState.enabled;
						select = this._groupOptions.initialState.select;
					}
					var optionsGroupWidget = {
						select : select,
						visible : visible,
						enabled : enabled,
						values : this._groupOptions.values,
						touch : this._options.touch,
						modelEvent : this._options.modelEvent
					}
					this._ENOXGroupComponant = new ENOXGroupComponant(
							optionsGroupWidget);
					// Register the custom typreRepresentation Factory
					this._ENOXGroupComponant
							.registerTypeRepresentations(this._typeRepFactory);
					this._ENOXGroupComponant
							.addToTreeDocument(this._toolbarTreeDocument);
				}
			}

			// Function to create the SearchComponant
			ENOXGeneratedToolBar.prototype._createSearchComponant = function() {
				if (this._searchOptions !== undefined
						&& this._searchOptions.active) {
					var visible;
					var enabled;
					if (this._groupOptions.initialState !== undefined) {
						visible = this._searchOptions.initialState.visible;
						enabled = this._searchOptions.initialState.enabled;
					}
					var optionsSearchWidget = {
						visible : visible,
						enabled : enabled,
						touch : this._options.touch,
						modelEvent : this._options.modelEvent
					}
					this._ENOXSearchComponant = new ENOXSearchComponant(
							optionsSearchWidget);
					// Register the custom typreRepresentation Factory
					this._ENOXSearchComponant
							.registerTypeRepresentations(this._typeRepFactory);
					this._ENOXSearchComponant
							.addToTreeDocument(this._toolbarTreeDocument);
				}
			}

			// Function to create the ViewsComponant
			ENOXGeneratedToolBar.prototype._createViewsComponant = function() {
				if (this._viewsOptions !== undefined
						&& this._viewsOptions.active) {
					var visible;
					var enabled;
					var select;
					if (this._viewsOptions.initialState !== undefined) {
						visible = this._viewsOptions.initialState.visible;
						enabled = this._viewsOptions.initialState.enabled;
						select = this._viewsOptions.initialState.select;
					}
					var optionsViewsWidget = {
						select : select,
						visible : visible,
						enabled : enabled,
						values : this._viewsOptions.values,
						touch : this._options.touch,
						modelEvent : this._options.modelEvent
					}
					this._ENOXViewsComponant = new ENOXViewsComponant(
							optionsViewsWidget);
					// Register the custom typreRepresentation Factory
					this._ENOXViewsComponant
							.registerTypeRepresentations(this._typeRepFactory);
					this._ENOXViewsComponant
							.addToTreeDocument(this._toolbarTreeDocument);
				}
			}

			// Function to map the options for creating the
			// FunctionIconComponant (Array[Object] or Object)
			ENOXGeneratedToolBar.prototype._mapOptionsFunctionIconComponant = function() {
				if (this._functionIconWidget !== undefined) {
					this._ENOXFunctionIconComponant = [];
					if (Array.isArray(this._functionIconWidget.id)) {
						for (var i = 0; i < this._functionIconWidget.id.length; i++) {
							var optionsFunctionIconWidget = {
								id : this._functionIconWidget.id[i],
								icon : this._functionIconWidget.icon[i],
								visible : this._functionIconWidget.visible[i],
								enabled : this._functionIconWidget.enabled[i],
								touch : this._options.touch,
								modelEvent : this._options.modelEvent
							}
							this
									._createFunctionIconWidget(optionsFunctionIconWidget);
						}
					} else {
						var optionsFunctionIconWidget = {
							id : this._functionIconWidget.id,
							icon : this._functionIconWidget.icon,
							visible : this._functionIconWidget.visible,
							enabled : this._functionIconWidget.enabled,
							touch : this._options.touch,
							modelEvent : this._options.modelEvent
						}
						this
								._createFunctionIconWidget(optionsFunctionIconWidget);
					}

				}
			}

			// Function to create the FunctionIconWidget
			ENOXGeneratedToolBar.prototype._createFunctionIconWidget = function(
					optionsFunctionIconWidget) {
				var componantFunctionIconWidget = new ENOXFunctionIconComponant(
						optionsFunctionIconWidget);
				// Register the custom typreRepresentation Factory
				componantFunctionIconWidget
						.registerTypeRepresentations(this._typeRepFactory);
				componantFunctionIconWidget
						.addToTreeDocument(this._toolbarTreeDocument);
				this._ENOXFunctionIconComponant
						.push(componantFunctionIconWidget);
			}

			// Function to create the GeneratedToolbar
			ENOXGeneratedToolBar.prototype._createContainerToolBar = function() {
				// Search DS/Tweakers/GeneratedToolbar for more details about
				// options
				this.toolbar = new GeneratedToolbar({
					overflowManagement : 'dropdown',
					direction : 'horizontal',
					items : this._toolbarTreeDocument,
					typeRepresentationFactory : this._typeRepFactory
				});

			}

			// Function to return the toolbar
			ENOXGeneratedToolBar.prototype.getToolbar = function() {
				return this.toolbar;
			}

			return ENOXGeneratedToolBar;
		});
