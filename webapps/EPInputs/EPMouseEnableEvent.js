define('DS/EPInputs/EPMouseEnableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPMouse', 'DS/EPInputs/EPMouseEvent'], function (EP, EventServices, Mouse, MouseEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a mouse.</br>
	 * It contains information about the mouse device.</br>
	 * It occurs when the mouse device becomes enabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.MouseEnableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.MouseEnableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.MouseEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseEnableEvent = function (iMouseEnableEvent) {
	 *	// user enabled the mouse
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MouseEnableEvent, objectListener, 'onMouseEnableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MouseEnableEvent, objectListener, 'onMouseEnableEvent');
	 */
	var MouseEnableEvent = function (iParameters) {

		MouseEvent.call(this, iParameters);

		/**
         * Mouse device
         *
		 * @private
         * @type {EP.Mouse}
         */
		this.mouse = new Mouse();

	};

	MouseEnableEvent.prototype = Object.create(MouseEvent.prototype);
	MouseEnableEvent.prototype.constructor = MouseEnableEvent;
	MouseEnableEvent.prototype.type = 'MouseEnableEvent';

	EventServices.registerEvent(MouseEnableEvent);

	// Expose in EP namespace.
	EP.MouseEnableEvent = MouseEnableEvent;

	return MouseEnableEvent;
});
