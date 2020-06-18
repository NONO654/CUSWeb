define('DS/EPInputs/EPGamepadEnableEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGamepad',
	'DS/EPInputs/EPGamepadEvent'
], function (EP, EventServices, Gamepad, GamepadEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a gamepad.</br>
	 * It contains information about the gamepad device.</br>
	 * It occurs when the gamepad device becomes enabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.GamepadEnableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.GamepadEnableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.GamepadEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onGamepadEnableEvent = function (iGamepadEnableEvent) {
	 *	// user enabled the gamepad
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.GamepadEnableEvent, objectListener, 'onGamepadEnableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.GamepadEnableEvent, objectListener, 'onGamepadEnableEvent');
	 */
    var GamepadEnableEvent = function (iParameters) {

    	GamepadEvent.call(this, iParameters);

    	/**
         * Gamepad device
         *
		 * @private
         * @type {EP.Gamepad}
         */
    	this.gamepad = new Gamepad();
    };

    GamepadEnableEvent.prototype = Object.create(GamepadEvent.prototype);
    GamepadEnableEvent.prototype.constructor = GamepadEnableEvent;
    GamepadEnableEvent.prototype.type = 'GamepadEnableEvent';

    EventServices.registerEvent(GamepadEnableEvent);

    // Expose in EP namespace.
    EP.GamepadEnableEvent = GamepadEnableEvent;

    return GamepadEnableEvent;
});
