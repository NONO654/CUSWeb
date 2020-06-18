define('DS/EPInputs/EPMouseEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'], function (EP, EventServices, Event) {
	'use strict';

	/**
	 * <p>Describe an event generated from a mouse.</br>
	 * It contains information about the mouse device.</br>
	 * It occurs when the user manipulates the mouse device.</p>
	 *
	 * <p>This event has specific extensions class and there are all dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.MouseEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.MouseEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.Event
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseEvent = function (iMouseEvent) {
	 *	// user manipulated the mouse
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MouseEvent, objectListener, 'onMouseEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MouseEvent, objectListener, 'onMouseEvent');
	 */
	var MouseEvent = function (iParameters) {

		Event.call(this, iParameters);

		/**
         * Mouse device
         *
		 * @private
         * @type {EP.Mouse}
         */
	    this.mouse = EP.Devices.getMouse();

	};

	MouseEvent.prototype = Object.create(Event.prototype);
	MouseEvent.prototype.constructor = MouseEvent;
	MouseEvent.prototype.type = 'MouseEvent';

	/**
	 * Return the mouse device.
	 *
	 * @public
	 * @return {EP.Mouse}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseEvent = function (iMouseEvent) {
	 *	var mouse = iMouseEvent.getMouse();
	 * };
	 */
	MouseEvent.prototype.getMouse = function () {
		return this.mouse;
	};

	EventServices.registerEvent(MouseEvent);

	// Expose in EP namespace.
	EP.MouseEvent = MouseEvent;

	return MouseEvent;
});
