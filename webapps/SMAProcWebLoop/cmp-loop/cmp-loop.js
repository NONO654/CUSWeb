/*--------------------------------------------------------------------
[cmp-loop JS Document]

Project:        cmp
Version:        1.0
Last change:    Thu, 19 Nov 2015 20:03:26 GMT
Assigned to:    Vishakha Motwani
Description:    Loop component <cmp-loop>
---------------------------------------------------------------------*/
/**
    @module SMAProcWebLoop
    @submodule cmp-loop
    @class cmp-loop

    @description
        This handles the code behind the basic loop components.
        Importing this component handles the import of other
        loop components.

    @example
        <cmp-loop id="loop" name="loop"></cmp-loop>

 */
require(['DS/SMAProcWebCommonControls/ParameterChooser', 'DS/SMAProcWebCommonControls/ExtensionChooser'], function () {
    'use strict';
    var LOOP_DO_UNTIL = 'com.dassault_systemes.sma.plugin.LoopPIDoUntil';
    var LOOP_FOR = 'com.dassault_systemes.sma.plugin.LoopPIFor';
    var LOOP_FOREACH = 'com.dassault_systemes.sma.plugin.LoopPIForEach';
    var LOOP_WHILE = 'com.dassault_systemes.sma.plugin.LoopPIWhile';

    var LOOP_DESCRIPTORS = {
        'Do Until': LOOP_DO_UNTIL,
        'For': LOOP_FOR,
        'For Each': LOOP_FOREACH,
        'While': LOOP_WHILE
    };
    var DESCRIPTORS = {};
    DESCRIPTORS[LOOP_DO_UNTIL] = 'Do Until';
    DESCRIPTORS[LOOP_FOR] = 'For';
    DESCRIPTORS[LOOP_FOREACH] = 'For Each';
    DESCRIPTORS[LOOP_WHILE] = 'While';

    /**
        @class cmp-loop
    **/
    Polymer({
        is: 'cmp-loop',
        properties: {
            ExtensionEditorImpl: {
                value: function () {
                    return {
                        UpdateUI: this.UpdateUI.bind(this),
                        Apply: this.Apply.bind(this)
                    };
                }
            }
        },
        listeners: {
            'pcw-extension-selected': '_extensionChanged'
        },

        _getLoopElementFor: function (extensionName) {
            switch (extensionName) {
            case LOOP_DO_UNTIL:
                return this.$.dountilloop;
            case LOOP_FOR:
                return this.$.forloop;
            case LOOP_FOREACH:
                return this.$.foreachloop;
            case LOOP_WHILE:
                return this.$.whileloop;
            }
            return null;
        },
        _extensionChanged: function (e) {
            if (e) {
                e.stopPropagation();
            }
            for (var descriptor in LOOP_DESCRIPTORS) {
                if (descriptor && LOOP_DESCRIPTORS.hasOwnProperty(descriptor)) {
                    this._getLoopElementFor(LOOP_DESCRIPTORS[descriptor]).setAttribute('hidden', '');
                }
            }
            var loopElement = this._getLoopElementFor(this.$.pluginchooser.selectedExtension);
            if (loopElement) {
                try {
                    loopElement.initializeChoosers(this.activity);
                    if (loopElement.UpdateUI && this.extensionConfig) {
                        loopElement.UpdateUI(this.activity, this.stepId, this.extensionConfig);
                    } else {
                        console.error('Could not get element for UpdateUI, or element is not yet ready');
                    }
                } catch (e) {
                    console.warn('Failed to initialize choosers:', e);
                }
                loopElement.removeAttribute('hidden');
            }
        },
        /**
         * Updates the user interface with the information received from the web service.
         */
        UpdateUI: function (activity, stepId, ExtensionConfig) {
            var that = this;
            require(['DS/Usage/TrackerAPI'], function(TrackerAPI){
                var timer = TrackerAPI.getTimer(that.tagName.toLocaleLowerCase()+'Tracker', {appID:'SIMPRCW_AP'});
                timer.stop();
            });
            this.activity = activity;
            this.stepId = stepId;
            this.extensionConfig = ExtensionConfig;
            if (this.extensionConfig) {
                var prop = this.extensionConfig.getPropertyByName('type');
                var descriptorName = LOOP_DESCRIPTORS[prop.getValue()];
                this.$.pluginchooser.selectedExtension = descriptorName;
                this._extensionChanged();
            }
        },
        /**
         * Receives the values from the user 0interface and passes on to the web service.
         * @method Apply
         */
        Apply: function () {
            // Set descriptor values with attribute settings
            var extensionConfig = this.extensionConfig;
            if (!extensionConfig) { return; }
            var prop = this.extensionConfig.getPropertyByName('type');
            var extensionName = this.$.pluginchooser.selectedExtension;
            var extensionShortName = DESCRIPTORS[extensionName];
            prop.setValue(extensionShortName);
            var loopElement = this._getLoopElementFor(extensionName);
            if (loopElement) {
                loopElement.Apply(this.extensionConfig);
            } else {
                console.error('Could not get element for Apply');
            }
        }
    });
});
