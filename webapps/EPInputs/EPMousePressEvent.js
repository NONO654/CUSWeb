define('DS/EPInputs/EPMousePressEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPMouseEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, MouseEvent, Vector2D) {
	'use strict';

	/**
	 * <p>Describe an event generated from a mouse.</br>
	 * It contains information about the mouse device.</br>
	 * It occurs when the user press a mouse button.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.MousePressEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.MousePressEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.MouseEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onMousePressEvent = function (iMousePressEvent) {
	 *	// user pressed a mouse button
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.MousePressEvent, objectListener, 'onMousePressEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.MousePressEvent, objectListener, 'onMousePressEvent');
	 */
	var MousePressEvent = function (iParameters) {

		MouseEvent.call(this, iParameters);

		/**
         * Mouse Button ID.
         *
		 * @private
         * @type {EP.Mouse.EButton}
         */
		this.button = undefined;

		/**
         * Cursor pixel position in the 3D viewer.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.position = new Vector2D();

	};

	MousePressEvent.prototype = Object.create(MouseEvent.prototype);
	MousePressEvent.prototype.constructor = MousePressEvent;
	MousePressEvent.prototype.type = 'MousePressEvent';

	/**
	 * Return the Mouse Button ID.
	 *
	 * @public
	 * @return {EP.Mouse.EButton}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMousePressEvent = function (iMousePressEvent) {
	 *	if(iMousePressEvent.getButton() === EP.Mouse.EButton.eLeft) {
	 *		// left button has been pressed
	 *	}
	 * };
	 */
	MousePressEvent.prototype.getButton = function () {
		return this.button;
	};

	/**
	 * Return the cursor pixel position on the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onMousePressEvent = function (iMousePressEvent) {
	 *	var mousePosition = iMousePressEvent.getPosition();
	 *	var mouseWidth = mousePosition.x;
	 *	var mouseHeight = mousePosition.y;
	 * };
	 */
	MousePressEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(MousePressEvent);

	// Expose in EP namespace.
	EP.MousePressEvent = MousePressEvent;

	return MousePressEvent;
});
