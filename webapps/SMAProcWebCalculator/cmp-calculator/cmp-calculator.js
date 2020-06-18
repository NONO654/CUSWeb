/*--------------------------------------------------------------------
[cmp-calcultor JS Document]

Project:        cmp
Version:        1.0
Last change:    Fri, 20 Nov 2015 18:08:11 GMT
Assigned to:    Amit Saran
-------------------------------------------
Updated by:     KSA7
Updated on:     June 21, 2019
---------------------------------------------------------------------*/
/**
 * cmp-calculator
 * @module calculator
 * @requires 'CMPUi'
 */
require([
        'DS/Usage/TrackerAPI',
        'DS/SMAProcWebContents/PolyUtils',
        'DS/SMAProcWebContents/ContentService',
        'DS/SMAProcWebCommonControls/CalculatorEditor'
    ],
    function(TrackerAPI, PolyUtils, ContentService) {
        'use strict';

        var ALLOW_EXCEPTIONAL_VALUES = '#option AllowExceptionalValue\n';
       
        Polymer({
            is: 'cmp-calculator',

            ready: function() {
                this.ExtensionEditorImpl = this;
            },

            UpdateUI: function(actId, stepId, extensionConfig) {
                console.log('Inside calculator UpdateConfig');
                var me = this;

                this._activity = actId;
                this._stepId = stepId;
                this._extensionConfig = extensionConfig;
                var timer = TrackerAPI.getTimer(this.tagName.toLocaleLowerCase() + 'Tracker', {
                    appID: 'SIMPRCW_AP'
                });
                timer.stop();
                
                var expression = '';
                if (extensionConfig) {
                    var prop = extensionConfig.getPropertyByName('expression');
                    if (prop) {
                        expression = extensionConfig.getPropertyValue(prop);
                       
                        if(expression.indexOf(ALLOW_EXCEPTIONAL_VALUES) > -1){
                            expression = expression.replace(ALLOW_EXCEPTIONAL_VALUES, '');
                            this.$.allowExCheck.checked = true;
                        }
                    }
                }

                var contentService = new ContentService(this._activity);
                PolyUtils.whenComponentReady(this.$.editor).then(function(el){
                    el.setContentService(contentService);
                    el.setActivity(me._activity);
                    var parameters = me._activity.getParameters();
                    el.setModel(parameters, expression);
                    el.setExceptionalFlag(me.$.allowExCheck.checked);
                }); 
            },

            
            changeExceptionValue: function(){
                if(this.$.editor){
                    this.$.editor.setExceptionalFlag(this.$.allowExCheck.checked);
                }
            },

            Apply: function() {
                var expression = this.$.editor.expression;
                
                var extensionConfig = this._extensionConfig;

                if (extensionConfig) {
                    var prop = extensionConfig.getPropertyByName('expression');
                    if (prop) {
                        if(this.$.allowExCheck.checked){
                            expression = ALLOW_EXCEPTIONAL_VALUES + expression;
                        }
                        extensionConfig.setPropertyValue(prop, expression);
                    }
                }
            },


            Cancel: function() {},
        });
    });
