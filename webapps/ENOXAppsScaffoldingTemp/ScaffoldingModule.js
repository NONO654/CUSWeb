/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : UX Scaffolding
 *
 * @author VLH2
 */

define('DS/ENOXAppsScaffoldingTemp/ScaffoldingModule', ['UWA/Class/Events', 'DS/Handlebars/Handlebars'], function (Events, Handlebars) {

    // Extend from Class.Events for event dispatching / listening
    return Events.extend({

        firstRender: true,
        isAttached: false,

        init: function (module, config) {  

        	debugger;
            // Create wrapper method for Scaffolding lifecycle method
            if (typeof module === 'function') {
                this._constructor = module.prototype.constructor;
                this._attach = module.prototype.attach;
                this._detach = module.prototype.detach;
                this._destroy = module.prototype.destroy;
            } else {
                this._constructor = module.constructor;
                this._attach = module.attach;
                this._detach = module.detach;
                this._destroy = module.destroy;
            }

            // If template option, create the associated render method from it
            if (module.template !== undefined && module.template !== null) {
                this._render = Handlebars.compile(module.template);
            } else {
                if (typeof module === 'function') {
                    this._render = module.prototype.render;
                } else {
                    this._render = module.render;
                }
            }            

            // Merging user module into scaffolding module
            if (typeof module === 'function') {
            	UWA.merge(this, module.prototype , true);
            } else {
            	UWA.merge(this, module , true);
            }

            // Call constructor
            this._constructor(config);
        },

        render: function (container) {
            
        	debugger;
        	
            // Render the new node
            var newNode;
            if (this.template) {
                newNode = document.createElement('div');
                newNode.innerHTML = this._render(this.templateContext);
            } else {
                newNode = this._render();
            }

            if (this.firstRender) {
                // If first render, attach element to DOM...
                this.attach(container, newNode);
                this.firstRender = false;
            } else {
                this._dispatchEvent('beforeUpdate');

                // Replace rootNode by rerendered one
                var oldRootNode = this.rootNode;
                this.rootNode = newNode;
                this.container.insertBefore(newNode, oldRootNode);
                this.container.removeChild(oldRootNode);

                this._dispatchEvent('updated');
            }
        },

        attach: function (container, node) {
            this._dispatchEvent('beforeAttach');

            this.container = container;
            this.rootNode = node;

            if (this._attach !== undefined) {
                // ...using provided attach method
                this._attach(container, node);
            } else {
                // ... or using appendChild
                container.appendChild(node);
            }

            this._dispatchEvent('attached');
        },

        detach: function () {
            this._dispatchEvent('beforeDetach');

            if (detach !== undefined) {
                this._detach();
            } else {
                this.container.removeChild(this.rootNode);
            }

            this._dispatchEvent('detached');
        },

        destroy: function () {
            this._dispatchEvent('beforeDestroy');

            // Remove element from his container then call destroy method
            this._destroy(this.rootNode);
            this.container.removeChild(this.rootNode);

            this._dispatchEvent('destroyed');
        },

        _dispatchEvent: function (eventName, args, context) {
            // Check if a callback is define for the event (onEvent syntax)
            var capitalizedEventName = eventName.charAt(0).toUpperCase() + eventName.slice(1);
            var eventCallback = this['on' + capitalizedEventName];

            if (typeof eventCallback === 'function') {    // TODO VLH2: more robust check needed ? (will fail for Object, Date or String for exemple)
                eventCallback(args, context);
            }

            // Dispatch event
            this.dispatchEvent(eventName, args, context);
        }
    });
});
