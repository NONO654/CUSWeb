define('DS/EPInputs/EPMouseMoveEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPMouseEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, MouseEvent, Vector2D) {
	'use strict';

	/**
	 * <p>Describe an event generated from a mouse.</br>
	 * It contains information about the mouse device.</br>
	 * It occurs when the user moves the mouse cursor.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.MouseMoveEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.MouseMoveEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.MouseEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseMoveEvent = function (iMouseMoveEvent) {
	 *	// user moved the mouse
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MouseMoveEvent, objectListener, 'onMouseMoveEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MouseMoveEvent, objectListener, 'onMouseMoveEvent');
	 */
	var MouseMoveEvent = function (iParameters) {

		MouseEvent.call(this, iParameters);

		/**
         * Cursor pixel position in the 3D viewer.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.position = new Vector2D();

		/**
         * Cursor delta pixel position on the 3D viewer.
		 * The delta pixel position is the difference between the last known pixel position and the new pixel position.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.deltaPosition = new Vector2D();

	};

	MouseMoveEvent.prototype = Object.create(MouseEvent.prototype);
	MouseMoveEvent.prototype.constructor = MouseMoveEvent;
	MouseMoveEvent.prototype.type = 'MouseMoveEvent';

	/**
	 * Return the cursor pixel position on the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseMoveEvent = function (iMouseMoveEvent) {
	 *	var mousePosition = iMouseMoveEvent.getPosition();
	 *	var mouseWidth = mousePosition.x;
	 *	var mouseHeight = mousePosition.y;
	 * };
	 */
	MouseMoveEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	/**
	 * Return the cursor delta pixel position on the 3D viewer.</br>
	 * The delta pixel position is the difference between the last known pixel position and the new pixel position.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMouseMoveEvent = function (iMouseMoveEvent) {
	 *	var mouseDeltaPosition = iMouseMoveEvent.getDeltaPosition();
	 *	var mouseDeltaWidth = mouseDeltaPosition.x;
	 *	var mouseDeltaHeight = mouseDeltaPosition.y;
	 * };
	 */
	MouseMoveEvent.prototype.getDeltaPosition = function () {
		return this.deltaPosition.clone();
	};

	EventServices.registerEvent(MouseMoveEvent);

	// Expose in EP namespace.
	EP.MouseMoveEvent = MouseMoveEvent;

	return MouseMoveEvent;
});
