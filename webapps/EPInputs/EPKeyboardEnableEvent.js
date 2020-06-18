define('DS/EPInputs/EPKeyboardEnableEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPKeyboard',
	'DS/EPInputs/EPKeyboardEvent'
], function (EP, EventServices, Keyboard, KeyboardEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a keyboard.</br>
	 * It contains information about the keyboard device.</br>
	 * It occurs when the keyboard device becomes enabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.KeyboardEnableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.KeyboardEnableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.KeyboardEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardEnableEvent = function (iKeyboardEnableEvent) {
	 *	// user enabled the keyboard
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.KeyboardEnableEvent, objectListener, 'onKeyboardEnableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.KeyboardEnableEvent, objectListener, 'onKeyboardEnableEvent');
	 */
    var KeyboardEnableEvent = function (iParameters) {

    	KeyboardEvent.call(this, iParameters);

    	/**
         * Keyboard device
         *
		 * @private
         * @type {EP.Keyboard}
         */
    	this.keyboard = new Keyboard();

    };

    KeyboardEnableEvent.prototype = Object.create(KeyboardEvent.prototype);
    KeyboardEnableEvent.prototype.constructor = KeyboardEnableEvent;
    KeyboardEnableEvent.prototype.type = 'KeyboardEnableEvent';

    EventServices.registerEvent(KeyboardEnableEvent);

    // Expose in EP namespace.
    EP.KeyboardEnableEvent = KeyboardEnableEvent;

    return KeyboardEnableEvent;
});
