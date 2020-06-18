define('DS/EPInputs/EPTouchEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'], function (EP, EventServices, Event) {
	'use strict';

	/**
	 * <p>Describe an event generated from a touch device.</br>
	 * It contains information about the touch device.</br>
	 * It occurs when the user manipulates the touch device.</p>
	 *
	 * <p>This event has specific extensions class and there are all dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.TouchEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.TouchEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.Event
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchEvent = function (iTouchEvent) {
	 *	// user manipulated the touch device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.TouchEvent, objectListener, 'onTouchEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.TouchEvent, objectListener, 'onTouchEvent');
	 */
	var TouchEvent = function (iParameters) {

		Event.call(this, iParameters);

		/**
         * Touch device
         *
		 * @private
         * @type {EP.Touch}
         */
	    this.touch = EP.Devices.getTouch();

	};

	TouchEvent.prototype = Object.create(Event.prototype);
	TouchEvent.prototype.constructor = TouchEvent;
	TouchEvent.prototype.type = 'TouchEvent';

	/**
	 * Return the touch device.
	 *
	 * @public
	 * @return {EP.Touch}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchEvent = function (iTouchEvent) {
	 *	var touch = iTouchEvent.getTouch();
	 * };
	 */
	TouchEvent.prototype.getTouch = function () {
		return this.touch;
	};

	EventServices.registerEvent(TouchEvent);

	// Expose in EP namespace.
	EP.TouchEvent = TouchEvent;

	return TouchEvent;
});
