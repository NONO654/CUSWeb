define('DS/EPInputs/EPGamepadDisableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPGamepadEvent'], function (EP, EventServices, GamepadEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a gamepad.</br>
	 * It contains information about the gamepad device.</br>
	 * It occurs when the gamepad device becomes disabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.GamepadDisableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.GamepadDisableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.GamepadEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onGamepadDisableEvent = function (iGamepadDisableEvent) {
	 *	// user disabled the gamepad
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.GamepadDisableEvent, objectListener, 'onGamepadDisableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.GamepadDisableEvent, objectListener, 'onGamepadDisableEvent');
	 */
    var GamepadDisableEvent = function (iParameters) {

    	GamepadEvent.call(this, iParameters);
    };

    GamepadDisableEvent.prototype = Object.create(GamepadEvent.prototype);
    GamepadDisableEvent.prototype.constructor = GamepadDisableEvent;
    GamepadDisableEvent.prototype.type = 'GamepadDisableEvent';

    EventServices.registerEvent(GamepadDisableEvent);

    // Expose in EP namespace.
    EP.GamepadDisableEvent = GamepadDisableEvent;

    return GamepadDisableEvent;
});
