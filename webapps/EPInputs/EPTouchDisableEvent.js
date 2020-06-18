define('DS/EPInputs/EPTouchDisableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPTouchEvent'], function (EP, EventServices, TouchEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a touch device.</br>
	 * It contains information about the touch device.</br>
	 * It occurs when the touch device becomes disabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.TouchDisableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.TouchDisableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.TouchEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchDisableEvent = function (iTouchDisableEvent) {
	 *	// user disabled the touch device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.TouchDisableEvent, objectListener, 'onTouchDisableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.TouchDisableEvent, objectListener, 'onTouchDisableEvent');
	 */
    var TouchDisableEvent = function (iParameters) {

    	TouchEvent.call(this, iParameters);
    };

    TouchDisableEvent.prototype = Object.create(TouchEvent.prototype);
    TouchDisableEvent.prototype.constructor = TouchDisableEvent;
    TouchDisableEvent.prototype.type = 'TouchDisableEvent';

    EventServices.registerEvent(TouchDisableEvent);

    // Expose in EP namespace.
    EP.TouchDisableEvent = TouchDisableEvent;

    return TouchDisableEvent;
});
