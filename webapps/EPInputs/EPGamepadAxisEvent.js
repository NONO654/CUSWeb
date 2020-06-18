define('DS/EPInputs/EPGamepadAxisEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPGamepadEvent'], function (EP, EventServices, GamepadEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a gamepad.</br>
	 * It contains information about the gamepad device.</br>
	 * It occurs when the user moves a gamepad axis.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.GamepadAxisEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.GamepadAxisEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.GamepadEvent
     * @example
	 * var objectListener = {};
	 * objectListener.onGamepadAxisEvent = function (iGamepadAxisEvent) {
	 *	// an axis value has been changed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.GamepadAxisEvent, objectListener, 'onGamepadAxisEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.GamepadAxisEvent, objectListener, 'onGamepadAxisEvent');
	 */
	var GamepadAxisEvent = function (iParameters) {

		GamepadEvent.call(this, iParameters);

		/**
         * Gamepad axis value.
         *
		 * @private
         * @type {number}
         */
	    this.axisValue = 0.0;

		/**
         * Gamepad Axis ID.
         *
		 * @private
         * @type {EP.Gamepad.EAxis}
         */
	    this.axis = undefined;
	};

	GamepadAxisEvent.prototype = Object.create(GamepadEvent.prototype);
	GamepadAxisEvent.prototype.constructor = GamepadAxisEvent;
	GamepadAxisEvent.prototype.type = 'GamepadAxisEvent';

	/**
	 * Return the Gamepad axis value.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onGamepadAxisEvent = function (iGamepadAxisEvent) {
	 *	var gamepadAxisValue = iGamepadAxisEvent.getAxisValue();
	 * };
	 */
	GamepadAxisEvent.prototype.getAxisValue = function () {
		return this.axisValue;
	};

	/**
	 * Return the Gamepad Axis ID.
	 *
	 * @public
	 * @return {EP.Gamepad.EAxis}
	 * @example
	 * var objectListener = {};
	 * objectListener.onGamepadAxisEvent = function (iGamepadAxisEvent) {
	 *	if(iGamepadAxisEvent.getAxis() === EP.Gamepad.EAxis.eLSX) {
	 *		// left stick x axis value has been changed
	 *	}
	 * };
	 */
	GamepadAxisEvent.prototype.getAxis = function () {
		return this.axis;
	};

	EventServices.registerEvent(GamepadAxisEvent);

	// Expose in EP namespace.
	EP.GamepadAxisEvent = GamepadAxisEvent;

	return GamepadAxisEvent;
});
