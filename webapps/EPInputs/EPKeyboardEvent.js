define('DS/EPInputs/EPKeyboardEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'], function (EP, EventServices, Event) {
	'use strict';

	/**
	 * <p>Describe an event generated from a keyboard.</br>
	 * It contains information about the keyboard device.</br>
	 * It occurs when the user manipulates the keyboard device.</p>
	 *
	 * <p>This event has specific extensions class and there are all dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.KeyboardEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.KeyboardEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.Event
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardEvent = function (iKeyboardEvent) {
	 *	// user manipulated the keyboard
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.KeyboardEvent, objectListener, 'onKeyboardEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.KeyboardEvent, objectListener, 'onKeyboardEvent');
	 */
	var KeyboardEvent = function (iParameters) {

		Event.call(this, iParameters);

		/**
         * Keyboard device
         *
		 * @private
         * @type {EP.Keyboard}
         */
		this.keyboard = EP.Devices.getKeyboard();

	};

	KeyboardEvent.prototype = Object.create(Event.prototype);
	KeyboardEvent.prototype.constructor = KeyboardEvent;
	KeyboardEvent.prototype.type = 'KeyboardEvent';

	/**
	 * Return the keyboard device.
	 *
	 * @public
	 * @return {EP.Keyboard}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardEvent = function (iKeyboardEvent) {
	 *	var keyboard = iKeyboardEvent.getKeyboard();
	 * };
	 */
	KeyboardEvent.prototype.getKeyboard = function () {
		return this.keyboard;
	};

	EventServices.registerEvent(KeyboardEvent);

	// Expose in EP namespace.
	EP.KeyboardEvent = KeyboardEvent;

	return KeyboardEvent;
});
