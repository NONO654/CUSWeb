(function(GLOBAL) {
    // This is the generic element for the components that make up a chart. It
    // provides a generic template  for specifying behavior that should exist on all
    // chart components

    if (typeof GLOBAL.DS.RAComponents.chartcomponent !== 'undefined') {
        return;
    }

    var chartComponentPrototype = { is: 'ra-chartcomponent' };

    chartComponentPrototype.createdCallback = function() {
        var that = this;

        this.callbacks = {};

        this.overlayElements = [];

        this.lastClick;
        this.clickCoordinates = [0, 0];

        d3.select(this).on('click', function(e) {
            // This uses the d3 event handling capability to enable use of the
            // d3.mouse method to obtain  mouse position relative to the
            // chartcomponent element on a click.
            that._onClick(e);
        });

        this.errorHandler = function(e, errorType) {
            console.error(e);
        };

        this._setPopover = function() {};
        // TODO: Add a non-inherited overlay element as the popover? With a shade
        // div?

        this.chartEvents = [];
    };

    // This is here as a placeholder in case we need it in the future.
    // Even though it doesn't do anything, it should still be called in all elements
    // that implement ra-chartelement as a behavior for future compatibility
    // reasons.

    // ERROR HANDLING:
    /*
 * Each component can be assigned its own error handler using the
 * setErrorHandler method. The idea behind this behavior is that centralized
 * handling/display of error messages can be delegated to a central error
 * handler, likely on the chart container or in the application code where it
 * can be delegated to the chart container.
 */
    chartComponentPrototype.handleError = function(error, errorType) {
        this.errorHandler(error, errorType);
    };

    chartComponentPrototype.setErrorHandler = function(fn) {
        this.errorHandler = fn;
    };

    chartComponentPrototype.getPopover = function(args) {
        return this._getPopover(args);
    };

    chartComponentPrototype.setPopover = function(fn) {
        this._getPopover = fn;
    };

    chartComponentPrototype.on = function(eventName, fn) {
        this.callbacks[eventName] = fn;
    };

    chartComponentPrototype.setClickDataFunction = function(fn) {
        this.clickDataFunction = fn;

        /*
    Click data payload:
    {
        event
        nearestSelection
        tbd?
    }
     */
    };

    chartComponentPrototype._onClick = function(e) {
        // Store last click
        this.lastClickEvent = d3.event;
        this.clickCoordinates = d3.mouse(this);

        if (typeof this.callbacks.click === 'undefined') {
            return;
        }

        var clickArg = {};
        this.callbacks.click(clickArg);
    };

    chartComponentPrototype.removeOverlayElements = function(filter) {
        var that = this;

        var elements = this.querySelectorAll('ra-overlayelement');

        if (typeof filter === 'function') {
            elements = Array.prototype.filter.call(elements, filter);
        }

        Array.prototype.forEach.call(elements, function(el) {
            that.removeChild(el);
        });

        // var div;
        // while(div = this.overlayElements.splice(0, 1)[0]){
        //  this.removeChild(div);
        //}
    };

    chartComponentPrototype.getContextMenu = function(args) {
        // Creates a context menu containing <args>. Returns the overlay element
        // containing the context menu, which can be handled like any overlay
        // element.

        var that = this;

        var items = args.items || args;
        var height = items.length * 20;
        if (args.title) {
            height += 20;
        }

        var overlayArgs = {
            position: 'last-click',
            width: 150,
            height: height
        };

        var overlayEl = this.getOverlayElement(overlayArgs);

        var ctx = document.createElement('ra-contextmenu');
        ctx.setupMenu(args);
        overlayEl.appendChild(ctx);

        overlayEl.addEventListener('click', function(e) {
            that.removeOverlayElements();
            e.stopPropagation();
            e.preventDefault();
        });

        return overlayEl;
    };

    chartComponentPrototype.getOverlayElement = function(args) {
        if (args.position === 'last-click') {
            // Compute last click and send its coordinates.
            if (this.clickCoordinates) {
                args.position =
                    'coordinates ' +
                    this.clickCoordinates[0] +
                    ' ' +
                    this.clickCoordinates[1];
            } else {
                args.position = 'coordinates 0 0 ';
            }
        }

        var el = document.createElement('ra-overlayelement');
        el.setOverlayAttributes(args);

        this.appendChild(el);
        // this.overlayElements.push(el);

        if (!el.initialized) {
            el.initializeElement();
        }

        // If 'el' has a .content element, return it. Else, return 'el'.
        // UPDATED: Always returns 'el' since we need to use the overlay element
        // methods  to add callbacks.
        return el;
    };

    chartComponentPrototype.propagateChartEvent = function(args, sources) {
        // Note on propagation: the DOM is always an acyclic graph, so as long as we
        // never  propagate back to the event that spawned a selector.

        // However, when we allow both upwards and downward propagation and node
        // skipping, we can create  a cyclic graph since we're overriding the DOM
        // structure. To make sure this doesn't happen, we  maintain all ancestor
        // elements a chart event has propagated to, and never propagate an event  to
        // any element

        var that = this;

        if (typeof sources === 'undefined') {
            sources = [];
        }

        if (sources.indexOf(this) !== -1) {
            // This should never happen! If this happens, a chart event has been
            // manually propagated somewhere in the code  in a manner that formed a
            // loop.
            console.error(
                'Chart event propagation cycle detected! Propagation must be acyclic to prevent infinite loops.'
            );

            // Don't propagate if this is a loop.
            return;
        }

        if (this.chartEventListeners) {
            this.chartEventListeners.forEach(function(listener) {
                if (listener.filter(args, sources)) {
                    listener.listener.call(that, args, sources);
                }
            });
        }

        sources.push(this);
        var parent = this.parentElement;

        if (
            this.chartParent &&
            sources.indexOf(this.chartParent) === -1 &&
            this.chartParent.propagateChartEvent
        ) {
            this.chartParent.propagateChartEvent(args, sources);
        } else if (
            parent &&
            sources.indexOf(parent) === -1 &&
            parent.propagateEvent
        ) {
            parent.propagateChartEvent(args, sources);
        }

        var children = this.childNodes;

        Array.prototype.forEach.call(children, function(child) {
            if (sources.indexOf(child) === -1 && child.propagateChartEvent) {
                child.propagateChartEvent(args, sources);
            }
        });
    };

    chartComponentPrototype.addChartEventListener = function(listener, filter) {
        if (typeof this.chartEventListeners === 'undefined') {
            this.chartEventListeners = [];
        }
        filter =
            filter ||
            function() {
                return true;
            };

        this.chartEventListeners.push({ listener: listener, filter: filter });
    };

    chartComponentPrototype.positionLastMouse = function(args) {};

    Polymer(chartComponentPrototype);
    GLOBAL.DS.RAComponents.chartcomponent = chartComponentPrototype;
})(this);
