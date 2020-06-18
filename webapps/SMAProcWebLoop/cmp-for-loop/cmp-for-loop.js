/* global Polymer, SPBase*/
/*--------------------------------------------------------------------
[cmp-for-loop JS Document]

Project:        cmp
Version:        1.0
Last change:    Thu, 19 Nov 2015 20:03:24 GMT
Assigned to:    Vishakha Motwani
Description:    For loop component <cmp-for-loop>
---------------------------------------------------------------------*/
/**
    @module SMAProcWebLoop
    @submodule cmp-for-loop
    @class cmp-for-loop

    @description
        This handles the code behind the 'for' loop component.
        It is a part of the <cmp-loop> component

    @example
        <cmp-for-loop id="forloop" name="forloop"></cmp-for-loop>

**/
(function(window) {
    'use strict';
    require(['DS/SMAProcWebCommonControls/ParameterChooser']);
    Polymer({
        is: 'cmp-for-loop',

        /**
         * Triggered when a parameter from the first parameter choosed will be selected
         */
        onSelectConditionParam: function() {
            if (this.$.paramchooser.getSelectedParameter().index >= 0) {
                //Enabling elements which can now be edited as condition parameter is selected
                this.$.from.disabled = false;
                this.$.to.disabled = false;
                this.$.increment.disabled = false;
            }
        },
        //Event Handlers

        initializeChoosers: function (act) {
            if (act && !this.activity) {
                this.activity = act;
                this.$.paramchooser.setDataContainer(this.activity);
                this.$.from.setDataContainer(this.activity);
                this.$.to.setDataContainer(this.activity);
                this.$.increment.setDataContainer(this.activity);
            }
        },
        /**
         * Updates the user interface with the information received from the web service.
         * @method UpdateUI
         */
        UpdateUI: function(activity, stepId, extensionConfig) {
            console.log('Inside for loop adapter UpdateUI');
            this.initializeChoosers(activity);
            if (extensionConfig) {
                var properties = extensionConfig.getProperties();
                if (properties) {
                    var prop, value;
                    prop = extensionConfig.getPropertyByName('conditionParam');
                    value = prop.getValue();
                    if (value) {
                        this.$.paramchooser.selectParameterByName(value);
                    }
                    prop = extensionConfig.getPropertyByName('from');
                    value = prop.getValue();
                    if (value !== undefined && value !== null) {
                        this.$.from.value = value;
                    }
                    prop = extensionConfig.getPropertyByName('to');
                    value = prop.getValue();
                    if (value !== undefined && value !== null) {
                        this.$.to.value = value;
                    }
                    prop = extensionConfig.getPropertyByName('incr');
                    value = prop.getValue();
                    if (value !== undefined && value !== null) {
                        this.$.increment.value = value;
                    }
                    prop = extensionConfig.getPropertyByName('failed runs policy');
                    value = prop.getValue();
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
                        if (bool === true) {
                            this.$.parallel.checked = false;
                        } else if (bool === false) {
                            this.$.parallel.checked = true;
                        }
                    }
                }
            }
        },
        /**
         * Receives the values from the user interface and passes on to the web service.
         * @method Apply
         */
        Apply: function(extensionConfig) {
            if (!extensionConfig) {
                return;
            }

            var selectedParameter = this.$.paramchooser.getSelectedParameter();
            var selectedParameterName = selectedParameter && selectedParameter.parameter && selectedParameter.parameter.getName();
            var conditionParamProp = extensionConfig.getPropertyByName('conditionParam');
            conditionParamProp.setValue(selectedParameterName || '');

            var fromProp = extensionConfig.getPropertyByName('from');
            fromProp.setValue(this.$.from.value);

            var toProp = extensionConfig.getPropertyByName('to');
            toProp.setValue(this.$.to.value);

            var incrProp = extensionConfig.getPropertyByName('incr');
            incrProp.setValue(this.$.increment.value);

            var failedProp = extensionConfig.getPropertyByName('failed runs policy');
            failedProp.setValue( this.$.failrunpolicy.checked? 'ignore': 'fail');

            var seqProp = extensionConfig.getPropertyByName('sequential');
            seqProp.setValue(this.$.parallel.checked ? false : true);
        }
    });
}(this));
