define('DS/EffectivityInlineEditor/utils/CommonUtils', function () {
    'use strict';

    var CommonUtils = {

        /**
         * Create an HTMLElement from string (for example, an Handlebars function return value)
         * @param {string} string - HTML element as string
         * @return {HTMLElement} the rendered HTMLElement
         */
        createHTMLElementFromString: function (templateString) {
            var tmp = document.createElement('div');
            tmp.innerHTML = templateString;
            return tmp.firstChild;
        },

        /**
         * Create and return a fonticon element from fonticon name
         * @param {string} effectivity expression old format
         * @return {DOMElement} fonticon DOM element
         */
        createFontIconElement: function (fontIconName, tooltip) {
            var element = document.createElement('span');
            element.classList.add('fonticon');
            element.classList.add('fonticon-' + fontIconName);
            if (tooltip !== undefined && tooltip !== null) {
                element.title = tooltip;
            }
            return element;
        },

        /**
         * Create ComboBox element list from the map of model (based on displayed attribute)
         * @param {Object} map of models (from EffectivtyInlineEditor component)
         * @param {Object[]} array representing the element list of WUXComboBox component
         * @return {Object[]} elementsList of the WUXComboBox component
         */
        createWUXComboBoxElementListFromModelsMap: function (mapModels) {
            var elementsList = [];
            for (var key in mapModels) {
                if (mapModels.hasOwnProperty(key) && !mapModels[key].displayed) {
                    elementsList.push({labelItem: mapModels[key].name, valueItem: mapModels[key].id});
                }
            }
            return elementsList;
        },

        /**
         * Returns the name of the model from the basicData array of each model in the contextData object
         * @param {Object[]} basicData array (as in model object found in contextData array)
         * @return {string} name of model
         */
        getNameFromModelBasicData : function (arrList) {
            var modelName = '';
            for (var i = 0 ; i < arrList.length ; i++) {
                if (arrList[i].name === 'name') {
                    var attrValue = arrList[i].value;
                    if (attrValue !== null && attrValue !== undefined) {
                        modelName = attrValue[0];
                    } 
                    return modelName;
                }
            }
            return modelName;                            
        },

        /**
         * Stop the propagation of keydown and keyup event on a DOM Element if space was pressed (keyCode 32)
         * @param {DOMElement} the DOM Element on which propagation shoud be disabled
         */
        stopPropagationForSpaceKeyupKeydownEvent: function (element) {
            element.addEventListener('keydown', function (e) {
                if (e.keyCode === 32) {
                    e.stopPropagation();
                }
            });
            element.addEventListener('keyup', function (e) {
                 if (e.keyCode === 32) {
                     e.stopPropagation();
                 }
             });
        }
    };

    return CommonUtils;
});
