define('DS/EPInputs/EPKeyboardDisableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPKeyboardEvent'], function (EP, EventServices, KeyboardEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a keyboard.</br>
	 * It contains information about the keyboard device.</br>
	 * It occurs when the keyboard device becomes disabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.KeyboardDisableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.KeyboardDisableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.KeyboardEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardDisableEvent = function (iKeyboardDisableEvent) {
	 *	// user disabled the keyboard
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.KeyboardDisableEvent, objectListener, 'onKeyboardDisableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.KeyboardDisableEvent, objectListener, 'onKeyboardDisableEvent');
	 */
    var KeyboardDisableEvent = function (iParameters) {

    	KeyboardEvent.call(this, iParameters);
    };

    KeyboardDisableEvent.prototype = Object.create(KeyboardEvent.prototype);
    KeyboardDisableEvent.prototype.constructor = KeyboardDisableEvent;
    KeyboardDisableEvent.prototype.type = 'KeyboardDisableEvent';

    EventServices.registerEvent(KeyboardDisableEvent);

    // Expose in EP namespace.
    EP.KeyboardDisableEvent = KeyboardDisableEvent;

    return KeyboardDisableEvent;
});
