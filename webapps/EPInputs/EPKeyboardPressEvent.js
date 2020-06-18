define('DS/EPInputs/EPKeyboardPressEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPKeyboardEvent'], function (EP, EventServices, KeyboardEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a keyboard.</br>
	 * It contains information about the keyboard device.</br>
	 * It occurs when the user press a key.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.KeyboardPressEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.KeyboardPressEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.KeyboardEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardPressEvent = function (iKeyboardPressEvent) {
	 *	// a key has been pressed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.KeyboardPressEvent, objectListener, 'onKeyboardPressEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.KeyboardPressEvent, objectListener, 'onKeyboardPressEvent');
	 */
	var KeyboardPressEvent = function (iParameters) {

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

		/**
         * Property to indicate if the press event is a repetition.
         *
		 * @private
         * @type {boolean}
         */
	    this.repeat = false;

	};

	KeyboardPressEvent.prototype = Object.create(KeyboardEvent.prototype);
	KeyboardPressEvent.prototype.constructor = KeyboardPressEvent;
	KeyboardPressEvent.prototype.type = 'KeyboardPressEvent';

	/**
	 * Return the Key ID.
	 *
	 * @public
	 * @return {EP.Keyboard.EKey}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardPressEvent = function (iKeyboardPressEvent) {
	 *	if(iKeyboardPressEvent.getKey() === EP.Keyboard.EKey.eA) {
	 *		// key A has been pressed
	 *	}
	 * };
	 */
	KeyboardPressEvent.prototype.getKey = function () {
		return this.key;
	};

	/**
	 * Return the Modifier ID.
	 *
	 * @public
	 * @return {EP.Keyboard.FModifier}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardPressEvent = function (iKeyboardPressEvent) {
	 *	if(iKeyboardPressEvent.getModfier() & EP.Keyboard.FModifier.fShift) {
	 *		// modifier shift is activated
	 *	}
	 * };
	 */
	KeyboardPressEvent.prototype.getModifier = function () {
		return this.modifier;
	};

	/**
	 * Check if the press event is a repetition.
	 *
	 * @public
	 * @return {boolean}
	 * @example
	 * var objectListener = {};
	 * objectListener.onKeyboardPressEvent = function (iKeyboardPressEvent) {
	 *	if(iKeyboardEvent.isRepeat()) {
	 *		// user is holding down a key
	 *	}
	 * };
	 */
	KeyboardPressEvent.prototype.isRepeat = function () {
		return this.repeat;
	};

	EventServices.registerEvent(KeyboardPressEvent);

	// Expose in EP namespace.
	EP.KeyboardPressEvent = KeyboardPressEvent;

	return KeyboardPressEvent;
});
