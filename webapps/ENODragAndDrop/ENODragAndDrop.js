/*! Copyright 2014 Dassault Systèmes */
/* globals define */

define('DS/ENODragAndDrop/ENODragAndDrop',

/**
 * A helper for playing with HTML5 drag and drop.
 *
 * Will help you avoid common pitfalls through a simple API.
 *
 * This will enable you to perform such behaviours:
 *
 * - Saying that part of your application can receive a drag (be droppable) and be notified when it does
 *     - When a drag enter your dropzone
 *     - When a drag leaves your dropzone
 *     - When a drag hovers your dropzone
 * - Saying that part of your application can be draggable and be notified when it does
 *     - When a drag happens be notified when it stops
 * - Removing any drag events from an object
 *
 * Source:
 *
 * - http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html
 * - https://www.inkling.com/blog/2013/10/html5s-drag-and-drop-problem/
 * - https://dev.opera.com/articles/drag-and-drop/
 *
 * @example
 *
 *  Check the sample inside: CAADemoRedWire.edu\CAADemoToDoUIKitWX.mweb
 *
 * @module DS/DataDragAndDrop/DataDragAndDrop
 */

function () {

    'use strict';

    // Toggle the ability to select text, might conflict with dragging thus this function
    function setTextSelection (element, select) {
        var selectorAttribute = select ? '' : 'none',
            browserSelectCss = [
            'WebkitTouchCallout',
            'WebkitUserSelect',
            'KhtmlUserSelect',
            'MozUserSelect',
            'MsUserSelect',
            'UserSelect'
        ];

        // Apply styles
        browserSelectCss.forEach(function (selector) {
            try {
                element.style[selector] = selectorAttribute;
            } catch (e) {}
        });
    }

    // CSS helper
    function rmCls (el, cls) {
        el.className = el.className.replace(new RegExp('(^|\\s)' + cls + '(?:\\s|$)'), '$1');
    }

    function addCls (el, cls) {
        if (!hasCls(el, cls)) {
            el.className = (el.className.trim() + ' ' + cls).trim();
        }
    }

    function contains (string, word, separator) {
        return (separator) ? (separator + string + separator).indexOf(separator + word + separator) > -1 : string.indexOf(word) > -1;
    }

    function hasCls (el, cls) {
        return !!(el.className && contains(el.className, cls, ' '));
    }
    // END CSS helper

    /** Cross browser event handling */
    function addEvent (evnt, elem, func) {
        if (elem.addEventListener) {   // W3C DOM
           elem.addEventListener(evnt, func, false);
        } else if (elem.attachEvent) { // IE DOM
           elem.attachEvent('on' + evnt, func, false);
        }
     }

    function removeEvent (evnt, elem, func) {
        if (elem.removeEventListener) { // W3C DOM
           elem.removeEventListener(evnt, func, false);
         } else if (elem.detachEvent) {  // IE DOM
           elem.detachEvent('on' + evnt, func);
        }
     }

    function preventDefault (event) {
        event.preventDefault && event.preventDefault();
        event.returnValue = false;

        if ((event.cancelable === undefined || event.cancelable === true) && event.defaultPrevented === undefined) {
            event.defaultPrevented = true;
        }
    }

    function stopPropagation (event) {
        event.stopPropagation && event.stopPropagation();
        event.cancelBubble = true;
    }

    function stop (event) {
        stopPropagation(event);
        preventDefault(event);
    }
    // END Cross browser event handling

    /** @lends module:DS/DataDragAndDrop/DataDragAndDrop# */
    var exports = {

        /**
         * Set an item as draggable, adding the necessary properties and biding the mandatory events.
         * @param  {Element} element - A node element.
         * @param  {Object}  options - Additional options.
         *
         * @param  {String}   options.data  - The `data` you want to pass with this drag.
         * @param  {Function} options.start - A function to call when drag starts for a draggable element. Will be passed the dragged element and the event.
         * @param  {Function} options.stop  - A function to call when drag end for a draggable element. Will be passed the dragged element and the event.
         */
        draggable: function (element, options) {

            var dragEvents;

            // Only add if _dragEvents does not exists to avoid conflicting drop events
            // Also do not add if not a node
            if (element && element.nodeType !== 1 || element._dragEvents) { return; }

            element.setAttribute('draggable', true);
            element._dragEvents = {};

            dragEvents = {

                /** The `dragstart` event handler */
                dragstart: function (event) {
                    // Disable text selection on element
                    setTextSelection(this, false);

                    // copy, move, link, copyLink, copyMove, linkMove, all, none, uninitialized
                    // All means we can set different cursor type afterwards
                    event.dataTransfer.effectAllowed = 'all';

                    // Set a data for the drag (required by FF else no drag)
                    try { // IE fix
                        if (options.data) {
                            event.dataTransfer.setData('text', options.data);
                        } else {
                            event.dataTransfer.setData('text', this.innerHTML);
                        }
                    } catch (e) {}

                    // Call options.start
                    options.start && options.start(this, event);

                    // Add class `dragging` for ease of use
                    addCls(this, 'dragging');
                },

                /** The `dragend` event handler */
                dragend: function (event) {
                    // Re-enable text selection on element
                    setTextSelection(this, true);

                    // Call options.stop
                    options.stop && options.stop(this, event);

                    // Remove class `dragging`
                    rmCls(this, 'dragging');
                }
            };

            // Configure events from eventsListeners
            Object.keys(dragEvents).forEach(function (eventName) {
                element._dragEvents[eventName] = dragEvents[eventName];
                addEvent(eventName, element, element._dragEvents[eventName]);
            });
        },

        /**
         * Set an item as droppable, adding the necessary properties and biding the mandatory events.
         * @param  {Element} element - A node element.
         * @param  {Object}  options - Additional options.
         *
         * @param  {Function} options.enter - A function to call when the drag enter a droppable element. Will be passed the droppable element and the event.
         * @param  {Function} options.leave - A function to call when the drag leave a droppable element. Will be passed the droppable element and the event.
         * @param  {Function} options.over  - A function to call when the drag hover a droppable element. Will be passed the droppable element and the event.
         *                                    This function is called each time the mouse moves. If it returns `false`, drop will not be called.
         * @param  {Function} options.drop  - A function to call when a drop occurs on a droppable element. Will be passed the dataTransfer, the element and the event.
         */
        droppable: function (element, options) {

            var dragEvents;

            // Only add if _dragEvents does not exists to avoid conflicting drop events
            // Also do not add if not a node
            if (element && [1, 9].indexOf(element.nodeType) === -1) { return; }

            element._dragEvents = {};

            dragEvents = {

                /** The `dragenter` event handler */
                dragenter: function (event) {
                    // Call options.enter
                    options.enter && options.enter(this, event);
                },

                /** The `dragover` event handler */
                dragover: function (event) {
                    // Call options.over and check for result. Will prevent drop if it returns `false`
                    if (!options.over || options.over && options.over(this, event) !== false) {
                        // Needed to allow a drop action
                        // see: http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html
                        preventDefault(event);
                    }
                },

                /** The `dragleave` event handler */
                dragleave: function (event) {
                    // Call options.leave
                    options.leave && options.leave(this, event);
                },

                /** The `drop` event handler */
                drop: function (event) {
                    // Needed to allow a drop action
                    // see: http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html
                    stop(event);

                    // Call options.drop
                    options.drop && options.drop(event.dataTransfer.getData('text'), this, event);
                }
            };

            // Configure events from eventsListeners
            Object.keys(dragEvents).forEach(function (eventName) {
                element._dragEvents[eventName] = dragEvents[eventName];
                addEvent(eventName, element, element._dragEvents[eventName]);
            });
        },

        /**
         * Remove the drag drop events attached to the provided element.
         * @param  {Element} element - A DOM element.
         */
        clean: function (element) {

            // Only clean if _dragEvents exists to avoid conflicting drop events
            // Also do not clean if not a node
            if (element && element.nodeType !== 1 || !element._dragEvents) { return; }

            for (var name in element._dragEvents) {
                if (element._dragEvents.hasOwnProperty(name)) {
                    removeEvent(name, element, element._dragEvents[name]);
                }
            }

            delete element._dragEvents;

            if (element.getAttribute('draggable')) {
                element.removeAttribute('draggable');
            }
        },

        /**
         * Set both drag and drop items.
         * @param  {Element} dragElements - An array of DOM nodes.
         * @param  {Element} dropElements - An array of DOM nodes.
         * @param  {Object}  options      - Additional options.
         *
         * @param  {String}   options.data  - The `data` you want to pass with this drag.
         * @param  {Function} options.start - A function to call when drag starts for a draggable element. Will be passed the dragged element and the event.
         * @param  {Function} options.stop  - A function to call when drag end for a draggable element. Will be passed the dragged element and the event.
         * @param  {Function} options.enter - A function to call when the drag enter a droppable element. Will be passed the droppable element and the event.
         * @param  {Function} options.leave - A function to call when the drag leave a droppable element. Will be passed the droppable element and the event.
         * @param  {Function} options.over  - A function to call when the drag hover a droppable element. Will be passed the droppable element and the event.
         *                                    This function is called each time the mouse move. If it returns `false`, drop will not be called.
         * @param  {Function} options.drop  - A function to call when a drop occurs on a droppable element. Will be passed the dataTransfer, the element and the event.
         */
        on: function (dragElements, dropElements, options) {
            [].forEach.call(dragElements, function (element) {
                exports.draggable(element, options);
            });

            [].forEach.call(dropElements, function (element) {
                exports.droppable(element, options);
            });
        },

        /**
         * Remove the drag drop events attached to the provided elements.
         * @param  {Element[]} dragElements - An array of DOM nodes.
         * @param  {Element[]} dropElements - An array of DOM nodes.
         */
        off: function (dragElements, dropElements) {
            [].slice.call(dragElements).concat([].slice.call(dropElements)).forEach(function (element) {
                exports.clean(element);
            });
        }
    };

    return exports;
});


