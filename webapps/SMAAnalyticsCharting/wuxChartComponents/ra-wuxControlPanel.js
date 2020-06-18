//XSS_CHECKED
(function(GLOBAL, template) {
    GLOBAL.DS.RAObjects.WUXUtils.defineComponent('ra-wuxcontrolpanel');

    define(
        'ra-wuxcontrolpanel',
        [
            'UWA/Core',
            'UWA/Element',
            'UWA/Controls/Abstract',
            'DS/Core/Core',
            'DS/Tweakers/TypeRepresentationFactory',
            'DS/Windows/DockingElement',
            'DS/Controls/ButtonGroup',
            'DS/Controls/Toggle',
            'DS/Controls/LineEditor',
            'DS/Controls/Editor',
            'DS/Controls/Button',
            'DS/Controls/ComboBox'
        ],
        function(
            UWA,
            Element,
            Abstract,
            WUX,
            TypeRepFactory,
            WUXDockingElement,
            WUXButtonGroup,
            WUXToggle,
            WUXLineEditor,
            WUXEditor,
            WUXButton,
            WUXCombob
        ) {
            'use strict';

            WUX.setFullscreen();
            widget.body.style.overflow = 'auto';

            var layout, typeRepFactories, objects;

            function generateTweakerObject(
                sectionId,
                modelObj,
                container,
                configObject,
                changeCB
            ) {
                configObject = configObject || {};

                // Basic information
                var tweakerOptions = {
                    model: modelObj,
                    typePath: 'object',
                    semantics: { configuration: configObject }
                };

                typeRepFactories[sectionId].generateView(tweakerOptions.model, {
                    typePath: tweakerOptions.typePath,
                    semantics: tweakerOptions.semantics,
                    onViewCreated: function(v) {
                        if (v !== undefined) {
                            if (typeRepFactories[sectionId].currentTweaker) {
                                typeRepFactories[sectionId].currentTweaker.
                                    getContent().
                                    parentNode.removeChild(
                                        typeRepFactories[
                                            sectionId
                                        ].currentTweaker.getContent()
                                    );
                            }
                            typeRepFactories[sectionId].currentTweaker = v;
                            typeRepFactories[sectionId].currentTweaker.inject(
                                container
                            );

                            // And we add a listener on the "change" event to update
                            // the object overview
                            v.addEventListener('change', function(e) {
                                if (changeCB) {
                                    changeCB();
                                }
                            });
                        }
                    }
                });
            }

            var controlPanelPrototype = {
                is: 'ra-wuxcontrolpanel',
                behaviors: [GLOBAL.DS.RAComponents.callbacks]
            };

            controlPanelPrototype.createdCallback = function() {
                this.modelObject = {};
                this.configObject = {};
            };

            controlPanelPrototype.setModel = function(model, config) {
                this.modelObject = model;

                if (typeof config !== 'undefined') {
                    this.configObject = config;
                }

                this.render();
            };

            controlPanelPrototype.setConfig = function(config) {
                this.configObject = config;

                this.render();
            };

            controlPanelPrototype.render = function() {};

            Polymer(controlPanelPrototype);
            return controlPanelPrototype;
        }
    );
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
