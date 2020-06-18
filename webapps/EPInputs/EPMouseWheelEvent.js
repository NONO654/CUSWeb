define('DS/EPInputs/EPMouseWheelEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPMouseEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, MouseEvent, Vector2D) {
	'use strict';

	/**
	 * <p>Describe an event generated from a mouse.</br>
	 * It contains information about the mouse device.</br>
	 * It occurs when the user moves the mouse wheel.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.MouseWheelEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.MouseWheelEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.MouseEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseWheelEvent = function (iMouseWheelEvent) {
	 *	// user moved the mouse wheel
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MouseWheelEvent, objectListener, 'onMouseWheelEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MouseWheelEvent, objectListener, 'onMouseWheelEvent');
	 */
	var MouseWheelEvent = function (iParameters) {

		MouseEvent.call(this, iParameters);

		/**
         * Mouse wheel delta value.
		 * The delta value is the difference between the last known value and the new value.
         *
		 * @private
         * @type {number}
         */
	    this.wheelDeltaValue = 0.0;

		/**
         * Cursor pixel position in the 3D viewer.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.position = new Vector2D();

	};

	MouseWheelEvent.prototype = Object.create(MouseEvent.prototype);
	MouseWheelEvent.prototype.constructor = MouseWheelEvent;
	MouseWheelEvent.prototype.type = 'MouseWheelEvent';

    /**
	 * Return the mouse wheel delta value.</br>
	 * The delta value is the difference between the last known value and the new value.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseWheelEvent = function (iMouseWheelEvent) {
	 *	var mouseWheelDeltaValue = iMouseWheelEvent.getWheelDeltaValue();
	 * };
	 */
	MouseWheelEvent.prototype.getWheelDeltaValue = function () {
	    return this.wheelDeltaValue;
	};

	/**
	 * Return the cursor pixel position on the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseWheelEvent = function (iMouseWheelEvent) {
	 *	var mousePosition = iMouseWheelEvent.getPosition();
	 *	var mouseWidth = mousePosition.x;
	 *	var mouseHeight = mousePosition.y;
	 * };
	 */
	MouseWheelEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(MouseWheelEvent);

	// Expose in EP namespace.
	EP.MouseWheelEvent = MouseWheelEvent;

	return MouseWheelEvent;
});
