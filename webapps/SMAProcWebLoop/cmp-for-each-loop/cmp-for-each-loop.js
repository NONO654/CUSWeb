/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
/* globals Polymer, require */
/*--------------------------------------------------------------------
[cmp-for-each-loop JS Document]

Project:        cmp
Version:        1.0
Last change:    Thu, 19 Nov 2015 20:03:22 GMT
Assigned to:    Vishakha Motwani
Description:    For each loop component <cmp-for-each-loop>
---------------------------------------------------------------------*/
/**
    @module SMAProcWebLoop
    @submodule cmp-for-each-loop
    @class cmp-for-each-loop

    @description
        This handles the code behind the 'for-each' loop component.
        It is a part of the <cmp-loop> component

    @example
        <cmp-for-each-loop id="foreachloop" name="foreachloop"></cmp-for-each-loop>

 */
(function (window) {
    'use strict';
    var polymer = window.Polymer;
    require(['DS/SMAProcWebCommonControls/ParameterChooser']);
    /**
        @class cmp-for-each-loop
    **/
    polymer({
        is: 'cmp-for-each-loop',
        properties: {
            //Variables
            selectedItem: {
                type: Object,
                value: function () {
                    return {};
                }
            },
            valueList: {
                type: Array,
                value: function () {
                    return [];
                }
            }
        },
        /**
         * The ready event occurs when the DOM  has been loaded
         * @method ready
         */
        ready: function () {
            console.log('Ready For Each Loop...');
            this.valueList = [];
        },

        //Event Handlers
        /**
         * Triggered when a parameter from the first parameter choosed will be selected
         * @event onSelectConditionParam
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onSelectConditionParam: function () {
            if (this.$.paramchooser.getSelectedParameter().index >= 0) {
                //Enabling elements which can now be edited as condition parameter is selected
                this.$.inputvalue.disabled = false;
                this.$.add.disabled = false;
                this.$.remove.disabled = false;
                this.$.moveup.disabled = false;
                this.$.movedown.disabled = false;
            }
        },
        //runs when the first time loop adapter is loaded
        initializeChoosers: function (act) {
            if (act && this.activity === undefined) {
                this.activity = act;
                this.$.paramchooser.setDataContainer(this.activity);
                this.$.inputvalue.setDataContainer(this.activity);
            }
        },
        /**
         * Triggered on clicking the '+' button, adds the constant/parameter to values list
         * @event onAdd
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onAdd: function () {
            var that = this;
                
            var valueChecker = /^(C.+)|(P.+)/
            var selectedValue = this.$.inputvalue.value || '';

            if (valueChecker.test(selectedValue)) {
                //Inserts in an array
                //Maintaining another data structure to add in the aggregate properties
                require([
                    'DS/SMAProcWebCMMUtils/SMAJSCMMUtils',
                    'DS/JSCMM/SMAJSCMMProperty'
                ], function (SMAJSCMMUtils, SMAJSCMMProperty) {
                    var tempProperty = new SMAJSCMMProperty();
                    tempProperty.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
                    tempProperty.setDataType(SMAJSCMMUtils.DataType.client.String);
                    tempProperty.setValue(selectedValue);
                    that.push('valueList', tempProperty);
                    that.selectedItem = tempProperty;
                    that.selectedItem.selected = true;
                    console.log('<' + that.is + '> added: ' + selectedValue +'.\nTotal number of values: ', that.valueList.length);
                }, console.error.bind(console));
            } else {
                console.warn('<' + that.is + '> Did not add invalid value: "' + selectedValue + '"');
            }

        },
        /**
         * Triggered on clicking the '-' button, removes the selected
         * constant/parameter to values list
         * @event onRemove
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onRemove: function () {
            if (this.selectedItem && this.selectedItem.selected) {
                var index = this.valueList.indexOf(this.selectedItem);
                //Removes the element from the array
                this.splice('valueList', index, 1);
            }
            this.selectedItem = {};
        },
        /**
         * Triggered on clicking the up arrow button, moves the selected
         * constant/parameter up by a single place in the values list
         * @event onMoveUp
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onMoveUp: function () {
            var index = this.valueList.indexOf(this.selectedItem);
            console.log('Index before moving up:' + index);
            if (index > 0) {
                //Decrements the index of the selected value in the array
                //to move it up in the list
                var newIndex = index - 1;
                this.splice('valueList', newIndex, 0, this.splice('valueList', index, 1)[0]);
                console.log('Index after moving up:' + this.valueList.indexOf(this.selectedItem));
            }
        },
        /**
         * Triggered on clicking the down arrow button, moves the selected
         * constant/parameter down by a single place in the values list
         * @event onMoveDown
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onMoveDown: function () {
            var index = this.valueList.indexOf(this.selectedItem);
            console.log('Index before moving down:' + index);
            if (index >= 0 && index < this.valueList.length - 1) {
                //Increments the index of the selected value in the array
                //to move it down in the list
                var newIndex = index + 1;
                this.splice('valueList', newIndex, 0, this.splice('valueList', index, 1)[0]);
                console.log('Index after moving down:' + this.valueList.indexOf(this.selectedItem));
            }
        },
        /**
         * Triggered on clicking a value in the values list
         * @event onSelect
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         *
         */
        onSelect: function (event) {
            var itemsDOM = Polymer.dom(this.root).querySelectorAll('.paramitem');
            [].forEach.call(itemsDOM, function (itemDOM) {
                Polymer.dom(itemDOM).classList.remove('selected');
            }, this);
            //Clear any previous selections
            this.set('selectedItem.selected', false);
            //Set the selection
            this.selectedItem = event.model.value;
            this.set('selectedItem.selected', true);
            Polymer.dom(event.currentTarget).classList.add('selected');
            console.log('onSelectVar event.currentTarget ', event.currentTarget);
            console.log('onSelectVar item ', this.selectedItem);
        },
        /**
         * Updates the user interface with the information received from the web service.
         * @method fetchPropertyValue
         */
        fetchPropertyValue: function (property) {
            return property.getValue().substring(1);
        },
        /**
         * Updates the user interface with the information received from the web service.
         * @method UpdateUI
         */
        UpdateUI: function (activity, stepId, extensionConfig) {
            console.log('Inside For Each Loop adapter UpdateUI');
            this.activity = activity;
            this.stepId = stepId;
            this.initializeChoosers(activity);
            if (extensionConfig && extensionConfig.getProperties) {
                var properties = extensionConfig.getProperties();
                if (properties) {
                    var prop;
                    prop = extensionConfig.getPropertyByName('failed runs policy');
                    var value = prop.getValue();
                    if (value !== undefined && value !== null) {
                        if (value === 'ignore') {
                            this.$.failrunpolicy.checked = true;
                        } else if (value === 'fail') {
                            this.$.failrunpolicy.checked = false;
                        }
                    }
                    prop = extensionConfig.getPropertyByName('sequential');
                    var bool = prop.getValue();
                    if (bool !== undefined && bool !== null) {
                        this.$.parallel.checked = !bool;
                    }
                    prop = extensionConfig.getPropertyByName('conditionParam');
                    value = prop.getValue();
                    if (value) {
                        this.$.paramchooser.selectParameterByName(value);
                    }
                    // aggregate property consisting of a subproperties
                    // Prop                 {name: "items", type: "aggregate", Property: Object}
                    // Prop.Properties      [{<TEXT>: "C4", index: "[0]"}, {<TEXT>: "C7", index: "[1]"}, {<TEXT>: "PParameter1", index: "[2]"}, ...]
                    prop = extensionConfig.getPropertyByName('items');
                    var subprops = prop.getProperties();
                    this.valueList = subprops.slice();
                }
            }
        },
        /**
         * Receives the values from the user interface and passes on to the web service.
         * @method Apply
         */
        Apply: function (extensionConfig) {
            console.log('Inside For Each Loop editor Apply');
            // Set descriptor values with attribute settings
            if (null === extensionConfig) {
                return false;
            }
            var condProp = extensionConfig.getPropertyByName('conditionParam');
            var selectedParameter = this.$.paramchooser.getSelectedParameter();
            var selectedParameterName = selectedParameter && selectedParameter.parameter && selectedParameter.parameter.getName();
            condProp.setValue(selectedParameterName || '');

            var failedProp = extensionConfig.getPropertyByName('failed runs policy');
            failedProp.setValue(this.$.failrunpolicy.checked ? 'ignore' : 'fail');

            var seqProp = extensionConfig.getPropertyByName('sequential');
            seqProp.setValue(this.$.parallel.checked? false : true);

            var itemProp = extensionConfig.getPropertyByName('items');
            for (var i=0; i<this.valueList.length; i++){
                this.valueList[i].setName('scalar'+i);
            }
            itemProp.setProperties(this.valueList);
        }
    });
})(this);
