define('DS/EffectivityInlineEditor/EffectivityInlineEditor', [
    'DS/Handlebars/Handlebars',
    'DS/UIKIT/Mask',
    'DS/CfgAutoCompleteComponent/Presenter/CfgAutoCompletePresenter',   
    'DS/Controls/Accordeon',
    'DS/Controls/ComboBox',
    'DS/EffectivityInlineEditor/utils/CfgAutoCompleteUtils',
    'DS/EffectivityInlineEditor/utils/CommonUtils',
    'DS/EffectivityInlineEditor/utils/DictionaryUtils',
    'text!DS/EffectivityInlineEditor/templates/MonoModelTemplate.html',
    'text!DS/EffectivityInlineEditor/templates/NoModelOpenedTemplate.html',
    'i18n!DS/EffectivityInlineEditor/assets/nls/EffectivityInlineEditor',
    'css!DS/EffectivityInlineEditor/styles/EffectivityInlineEditor.css'
], function (Handlebars, Mask, AutoCompletePresenter, WUXAccordeon, WUXComboBox, CfgAutoCompleteUtils, CommonUtils, DictionaryUtils, MonoModelTemplate, NoModelOpenedTemplate, AppNLS) {
    'use strict';

    var TEMPLATES = {
        MonoModel: Handlebars.compile(MonoModelTemplate),
        NoModelOpened: Handlebars.compile(NoModelOpenedTemplate)
    };

    var EffectivityInlineEditor = function () {};

    EffectivityInlineEditor.prototype.init = function (options) {
        var that = this;
        var container = options.parentDiv;

        // Create a map to get current expressions from model name
        that.mapEffectivityExpressionFromModelName = {};
        options.varEffJsonWithLabel.effectivity.forEach(function (currentExpr) {
            that.mapEffectivityExpressionFromModelName[currentExpr.name] = currentExpr.Combinations;
        });
		
		 // Create a map to get current evolution expressions from model name
        that.mapEvoExpressionFromModelName = {};
        options.varEffJsonWithLabel.effectivity.forEach(function (currentExpr) {
            that.mapEvoExpressionFromModelName[currentExpr.name] = currentExpr.evoExp;
        });

        // Create map to get model name and current expression from model ID
        that.mapModelInfosFromModelID = {};
        options.contextData.forEach(function (model) {
            var modelName = CommonUtils.getNameFromModelBasicData(model.basicData);
            that.mapModelInfosFromModelID[model.physicalID] = {
                id: model.physicalID,
                name: modelName,
                currentExpressionRaw: that.mapEffectivityExpressionFromModelName[modelName] || [],
				currentEvoExpression:  that.mapEvoExpressionFromModelName[modelName] || "",
                displayed: false
            };
        });

        // Init the ActionBar containing the search for a Model and the add (+) icon (if more than 5 models)
        if (options.contextData.length > 5) {
            that.actionBarContainer = document.createElement('div');
            that.actionBarContainer.classList.add('effectivity-inline-editor-action-bar');
            container.appendChild(that.actionBarContainer);
            that.noModelOpenedPanel = container.appendChild(CommonUtils.createHTMLElementFromString(TEMPLATES.NoModelOpened({icon: options.iconModelURL, text: AppNLS.NO_MODELS_MSG})));
            that._createOrRefreshModelComboBox();
        } else {
            that.noActionBarMode = true;
        }

        if (options.contextData.length === 1) {
            // If only one model, just render the monoModelTemplate
            that.model = that.mapModelInfosFromModelID[Object.keys(that.mapModelInfosFromModelID)[0]];
            container.appendChild(CommonUtils.createHTMLElementFromString(TEMPLATES.MonoModel({modelName: that.model.name})));

            // Create the clean effectivity icon and the AutoComplete component
            that.autoCompletePresenter = that._createAutoCompletePresenter(that.model);
            that._createCleanEffectivityIcon(container.querySelector('.effectivity-inline-editor-monomodel-header'), that.autoCompletePresenter);
            container.querySelector('.effectivity-inline-editor-monomodel-autocomplete-container').appendChild(that.autoCompletePresenter.container);
            that.focus();
        } else {
            // If multiple models, create a WUXAccordeon component
            that.accordeon = new WUXAccordeon({
                style: 'styled',
                exclusive: false
            }).inject(container);
            that.accordeon.touchMode = true;

            // Listen to expand / collapse event and force overflow hidden on WUXAccordeon so AutoCompleteComponent is not cut
            that.accordeon.addEventListener('expand', function (data) {
                data.options.expanderTarget.elements.expanderContainer.classList.add('overflow-visible-override');
                data.options.expanderTarget.elements.bodyContainer.classList.add('overflow-visible-override');
            });
            that.accordeon.addEventListener('collapse', function (data) {
                data.options.expanderTarget.elements.expanderContainer.classList.remove('overflow-visible-override');
                data.options.expanderTarget.elements.bodyContainer.classList.remove('overflow-visible-override');
            });
            that.accordeon.elements.container.classList.add('effectivity-inline-editor-container');

            // Open all models already having an expression
            for (var key in that.mapModelInfosFromModelID) {
                if (that.mapModelInfosFromModelID.hasOwnProperty(key)) {
                    if (that.mapModelInfosFromModelID[key].currentExpressionRaw.length > 0 || that.noActionBarMode) {
                        that._addAutoCompleteSection(key);
                    }
                }
            }
        }
    };

    /**
     * Returns back the current effectivities expression
     */
    EffectivityInlineEditor.prototype.getExpressions = function () {
        var that = this;

        if (that.autoCompletePresenter) {
            return CfgAutoCompleteUtils.getExpressions(that.autoCompletePresenter, that.model);
        } else {
            return CfgAutoCompleteUtils.getExpressions(that.accordeon);
        }
    };
    
    /**
     * Focus the corresponding AutoComplete component
     * @param {(number|string)} indexOrModelId - Focus the AutoComplete component of the corresponding accordeon index (if number) or model id (if string)
     * (In monomodel mode, no param is needed)
     */
    EffectivityInlineEditor.prototype.focus = function (indexOrModelId) {
        var that = this;

        if (that.accordeon === undefined) {
            // If in monomodel mode, just focus the only AutoCompleteComponent
            CfgAutoCompleteUtils.giveFocus(that.autoCompletePresenter);
        } else if (typeof indexOrModelId === 'number' && that.accordeon.items[indexOrModelId] !== undefined) {
            CfgAutoCompleteUtils.giveFocus(that.accordeon.items[indexOrModelId]._autoCompletePresenter);
        } else if (typeof indexOrModelId === 'string') {
            for (var i = 0; i < that.accordeon.items.length; i++) {
                if (that.accordeon.items[i]._model.id === indexOrModelId) {
                    CfgAutoCompleteUtils.giveFocus(that.accordeon.items[i]._autoCompletePresenter);
                    return;
                }
            }
        }
    };

    /** 
     * Create or refresh the ComboBox from available model list
     */
    EffectivityInlineEditor.prototype._createOrRefreshModelComboBox = function () {
        var that = this;

        // There is no comboBox if only one model passed
        if (that.noActionBarMode) {
            return;
        }

        // Destroy old one (if existing)
        if (that.comboBoxModel !== undefined) {
            that.actionBarContainer.removeChild(that.comboBoxModel.elements.container);
        }

        // Create new ComboBox element
        that.comboBoxModel = new WUXComboBox({
            elementsList: CommonUtils.createWUXComboBoxElementListFromModelsMap(that.mapModelInfosFromModelID),
            enableSearchFlag: true,
            touchMode: true,
            placeholder: AppNLS.MODEL_ADD
        }).inject(that.actionBarContainer);

        // Add listener for ComboBoxModel change event, create a new AutoCompletePresenter from selected Model
        that.comboBoxModel.addEventListener('change', function () {
            if (that.comboBoxModel.selectedIndex !== -1) {
                var selectedModelID = that.comboBoxModel.elementsList[that.comboBoxModel.selectedIndex].valueItem;
                that._addAutoCompleteSection(selectedModelID);
            }
        });
    };

    /** 
     * Add an AutoComplete section (aka another Accordeon item) and remove the model from the available models list
     */
    EffectivityInlineEditor.prototype._addAutoCompleteSection = function (modelID, expandedByDefault) {
        var that = this, model = that.mapModelInfosFromModelID[modelID], modelName = model.name;

        // Hide the "No Model Opened" panel (if existing)
        if (!that.noActionBarMode) {
            that.noModelOpenedPanel.classList.add('hidden');
        }

        // Create the AutoCompletePresenter inside a new accordeon item
        var autoCompletePresenter = that._createAutoCompletePresenter(model);
        var idAccordeonItem = that.accordeon.addItem({
            header: modelName,
            expandedFlag: expandedByDefault || true,
            body: autoCompletePresenter.container,
            _autoCompletePresenter: autoCompletePresenter,
            _model: model
        });
        that.accordeon._applyTouchMode();    // TODO : bug workaround, removable when WUX Accordeon is patched

        // Deactivate keydown and keyup event for 'Space' keycode to prevent accordeon for expanding / collapsing when user press 'Space'
        CommonUtils.stopPropagationForSpaceKeyupKeydownEvent(autoCompletePresenter.container);

        // Create clean effectivity & close icons (and corresponding event listener)
        var accordeonIconsContainer = document.createElement('div');
        accordeonIconsContainer.classList.add('accordeon-icons-container');
        that.accordeon.elements.expander.elements.expanderContainer.appendChild(accordeonIconsContainer);
        that._createCleanEffectivityIcon(accordeonIconsContainer, autoCompletePresenter);
        if (!that.noActionBarMode) {
            var closeIcon = CommonUtils.createFontIconElement('close', AppNLS.MODEL_RM);
            closeIcon.addEventListener('click', function () {
                that._removeAutoCompleteSection(modelID, idAccordeonItem);
            });
            that.accordeon.elements.expander.elements.header.appendChild(closeIcon);
            accordeonIconsContainer.appendChild(closeIcon);
        }

        // Tag model as displayed and refresh comboBox
        model.displayed = true;
        that._createOrRefreshModelComboBox();
    };

    /** 
     * Remove an AutoComplete section (and tag the associated model as not displayed) 
     */
    EffectivityInlineEditor.prototype._removeAutoCompleteSection = function (modelID, accordeonIdToDelete) {
        var that = this;

        // Remove passed model expression and refresh ComboBox
        that.mapModelInfosFromModelID[modelID].currentExpression = null;
        that.mapModelInfosFromModelID[modelID].displayed = false;
        that.accordeon.deleteItem(that.accordeon.getIndexFromId(accordeonIdToDelete));
        ++that.accordeon._id;    // Prevent multiple expander with same id
        that._createOrRefreshModelComboBox();

        // Show the "No Model Opened" panel if no model displayed in accordeon
        if (that.accordeon.items.length === 0) {
            that.noModelOpenedPanel.classList.remove('hidden');
        }
    };

    /**
     * Create an AutoCompletePresenter component
     */    
    EffectivityInlineEditor.prototype._createAutoCompletePresenter = function (model) {
        // Create a temporary dictionary from effectivity expression if the full dictionary is not available
        if (model.dico === undefined) {
            model.dico = DictionaryUtils.createPartialDictionaryFromEffectivityExpression(model.currentExpressionRaw);
            model._dicoMapped = DictionaryUtils.createMapsFromDico(model.dico);
        }

        // Construct current expression
        if (model.currentExpression === undefined) {
            if (model.currentExpressionRaw.length > 0) {
                model.currentExpression = CfgAutoCompleteUtils.convertEffectivityExpressionToCfgAutoCompletePresenterFormat(model.currentExpressionRaw, model._dicoMapped.byName);
            } else {
                model.currentExpression = null;
            }
        }

        // Init CfgAutoCompletePresenter
        var autoCompletePresenter = new AutoCompletePresenter({
            currentExpression: model.currentExpression,
            dictionary: model.dico,
            editable: true,
            minLengthBeforeSearch: 0,
            withAdvancedOperator: false
        });
        autoCompletePresenter.render();

        // On first focus, get the full dictionary and update AutoCompletePresenter with it
        autoCompletePresenter._autocomplete.addEvent('onFocus', function () {
            if (!model.fullDicoAvailable) {
                Mask.mask(autoCompletePresenter._autocomplete.elements.container);
                DictionaryUtils.getModelDictionary(model).then(function () {
                    // Get full dictionary and refresh datasets
                    model.fullDicoAvailable = true;
                    autoCompletePresenter.model.set('dictionary', model.dico);
                    autoCompletePresenter.createMapDico();
                    CfgAutoCompleteUtils.refreshAutoCompleteDatasets(autoCompletePresenter);

                    if (autoCompletePresenter.getExpression().length === 0) {
                        // Just in case effectivity expression had been reset before loading dictionary
                        model.currentExpression = null;
                    } else {
                        // Recreate current expression with full dictionary
                        model.currentExpression = CfgAutoCompleteUtils.convertEffectivityExpressionToCfgAutoCompletePresenterFormat(model.currentExpressionRaw, model._dicoMapped.byName);
                    }
                    autoCompletePresenter.setExpression(model.currentExpression);
                    autoCompletePresenter.createInitialExpression();
                    CfgAutoCompleteUtils.giveFocus(autoCompletePresenter);

                    Mask.unmask(autoCompletePresenter._autocomplete.elements.container);
                });
            }
        });

        return autoCompletePresenter;
    };

    /**
     * Create the cleanEffectivityIcon and related listener
     */
    EffectivityInlineEditor.prototype._createCleanEffectivityIcon = function (container, autoCompletePresenter) {
        var cleanEffectivityIcon = CommonUtils.createFontIconElement('broom', AppNLS.EFF_CLEAR);
        cleanEffectivityIcon.addEventListener('click', function (e) {
            autoCompletePresenter.setExpression(null);
            autoCompletePresenter.createInitialExpression();
            e.stopPropagation();
            autoCompletePresenter._autocomplete.elements.input.focus();
        });
        container.appendChild(cleanEffectivityIcon);
    };

    return EffectivityInlineEditor;
});
