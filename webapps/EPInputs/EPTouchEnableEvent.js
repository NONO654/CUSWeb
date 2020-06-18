define('DS/EPInputs/EPTouchEnableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPTouch', 'DS/EPInputs/EPTouchEvent'], function (EP, EventServices, Touch, TouchEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a touch device.</br>
	 * It contains information about the touch device.</br>
	 * It occurs when the touch device becomes enabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.TouchEnableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.TouchEnableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.TouchEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchEnableEvent = function (iTouchEnableEvent) {
	 *	// user enabled the touch device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.TouchEnableEvent, objectListener, 'onTouchEnableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.TouchEnableEvent, objectListener, 'onTouchEnableEvent');
	 */
	var TouchEnableEvent = function (iParameters) {

		TouchEvent.call(this, iParameters);

		/**
         * Touch device
         *
		 * @private
         * @type {EP.Touch}
         */
		this.touch = new Touch();

	};

	TouchEnableEvent.prototype = Object.create(TouchEvent.prototype);
	TouchEnableEvent.prototype.constructor = TouchEnableEvent;
	TouchEnableEvent.prototype.type = 'TouchEnableEvent';

	EventServices.registerEvent(TouchEnableEvent);

	// Expose in EP namespace.
	EP.TouchEnableEvent = TouchEnableEvent;

	return TouchEnableEvent;
});
