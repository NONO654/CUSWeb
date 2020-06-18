define('DS/EPInputs/EPKeyboardReleaseEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPKeyboardEvent'], function (EP, EventServices, KeyboardEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a keyboard.</br>
	 * It contains information about the keyboard device.</br>
	 * It occurs when the user release a key.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.KeyboardReleaseEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.KeyboardReleaseEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.KeyboardEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardReleaseEvent = function (iKeyboardReleaseEvent) {
	 *	// a key has been pressed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.KeyboardReleaseEvent, objectListener, 'onKeyboardReleaseEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.KeyboardReleaseEvent, objectListener, 'onKeyboardReleaseEvent');
	 */
	var KeyboardReleaseEvent = function (iParameters) {

		KeyboardEvent.call(this, iParameters);

		/**
         * Key ID.
         *
		 * @private
         * @type {EP.Keyboard.EKey}
         */
		this.key = undefined;

		/**
         * Modifier ID.
         *
		 * @private
         * @type {EP.Keyboard.FModifier}
         */
		this.modifier = EP.Keyboard.FModifier.fNone;

	};

	KeyboardReleaseEvent.prototype = Object.create(KeyboardEvent.prototype);
	KeyboardReleaseEvent.prototype.constructor = KeyboardReleaseEvent;
	KeyboardReleaseEvent.prototype.type = 'KeyboardReleaseEvent';

	/**
	 * Return the Key ID.
	 *
	 * @public
	 * @return {EP.Keyboard.EKey}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardReleaseEvent = function (iKeyboardReleaseEvent) {
	 *	if(iKeyboardReleaseEvent.getKey() === EP.Keyboard.EKey.eA) {
	 *		// key A has been released
	 *	}
	 * };
	 */
	KeyboardReleaseEvent.prototype.getKey = function () {
		return this.key;
	};

	/**
	 * Return the Modifier ID.
	 *
	 * @public
	 * @return {EP.Keyboard.FModifier}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardReleaseEvent = function (iKeyboardReleaseEvent) {
	 *	if(iKeyboardReleaseEvent.getModfier() & EP.Keyboard.FModifier.fShift) {
	 *		// modifier shift is activated
	 *	}
	 * };
	 */
	KeyboardReleaseEvent.prototype.getModifier = function () {
		return this.modifier;
	};

	EventServices.registerEvent(KeyboardReleaseEvent);

	// Expose in EP namespace.
	EP.KeyboardReleaseEvent = KeyboardReleaseEvent;

	return KeyboardReleaseEvent;
});
