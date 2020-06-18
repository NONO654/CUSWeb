define('DS/EPInputs/EPGamepadEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'], function (EP, EventServices, Event) {
	'use strict';

	/**
	 * <p>Describe an event generated from a gamepad.</br>
	 * It contains information about the gamepad device.</br>
	 * It occurs when the user manipulates the gamepad device.</p>
	 *
	 * <p>This event has specific extensions class and there are all dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.GamepadEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.GamepadEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.Event
     * @example
	 * var objectListener = {};
	 * objectListener.onGamepadEvent = function (iGamepadEvent) {
	 *	// user manipulated the gamepad
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.GamepadEvent, objectListener, 'onGamepadEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.GamepadEvent, objectListener, 'onGamepadEvent');
	 */
	var GamepadEvent = function (iParameters) {

		Event.call(this, iParameters);

		/**
         * Gamepad device
         *
		 * @private
         * @type {EP.Gamepad}
         */
		this.gamepad = EP.Devices.getGamepad();
	};

	GamepadEvent.prototype = Object.create(Event.prototype);
	GamepadEvent.prototype.constructor = GamepadEvent;
	GamepadEvent.prototype.type = 'GamepadEvent';

	/**
	 * Return the gamepad device.
	 *
	 * @public
	 * @return {EP.Gamepad}
	 * @example
	 * var objectListener = {};
	 * objectListener.onGamepadEvent = function (iGamepadEvent) {
	 *	var gamepad = iGamepadEvent.getGamepad();
	 * };
	 */
	GamepadEvent.prototype.getGamepad = function () {
		return this.gamepad;
	};

	EventServices.registerEvent(GamepadEvent);

	// Expose in EP namespace.
	EP.GamepadEvent = GamepadEvent;

	return GamepadEvent;
});
