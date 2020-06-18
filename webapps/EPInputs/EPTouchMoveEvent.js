define('DS/EPInputs/EPTouchMoveEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPTouchEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, TouchEvent, Vector2D) {
	'use strict';

	/**
	 * <p>Describe an event generated from a touch device.</br>
	 * It contains information about the touch device.</br>
	 * It occurs when the user moves a contact on the touch device.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.TouchMoveEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.TouchMoveEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.TouchEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchMoveEvent = function (iTouchMoveEvent) {
	 *	// user moved the touch contact
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.TouchMoveEvent, objectListener, 'onTouchMoveEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.TouchMoveEvent, objectListener, 'onTouchMoveEvent');
	 */
	var TouchMoveEvent = function (iParameters) {

		TouchEvent.call(this, iParameters);

		/**
         * Touch id.
         *
		 * @private
         * @type {number}
         */
		this.id = undefined;

		/**
         * Contact pixel position in the 3D viewer.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.position = new Vector2D();

		/**
         * Contact delta pixel position on the 3D viewer.
		 * The delta pixel position is the difference between the last known pixel position and the new pixel position.
         *
		 * @private
         * @type {DSMath.Vector2D}
         */
	    this.deltaPosition = new Vector2D();
	};

	TouchMoveEvent.prototype = Object.create(TouchEvent.prototype);
	TouchMoveEvent.prototype.constructor = TouchMoveEvent;
	TouchMoveEvent.prototype.type = 'TouchMoveEvent';

	/**
	 * Return the touch id.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchMoveEvent = function (iTouchMoveEvent) {
	 *	if(iTouchMoveEvent.getId() === 0) {
	 *		// touch id 0 has been moved
	 *	}
	 * };
	 */
	TouchMoveEvent.prototype.getId = function () {
		return this.id;
	};

	/**
	 * Return the contact pixel position on the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchMoveEvent = function (iTouchMoveEvent) {
	 *	var touchPosition = iTouchMoveEvent.getPosition();
	 *	var touchWidth = touchPosition.x;
	 *	var touchHeight = touchPosition.y;
	 * };
	 */
	TouchMoveEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	/**
	 * Return the contact delta pixel position on the 3D viewer.</br>
	 * The delta pixel position is the difference between the last known pixel position and the new pixel position.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchMoveEvent = function (iTouchMoveEvent) {
	 *	var touchDeltaPosition = iTouchMoveEvent.getDeltaPosition();
	 *	var touchDeltaWidth = touchDeltaPosition.x;
	 *	var touchDeltaHeight = touchDeltaPosition.y;
	 * };
	 */
	TouchMoveEvent.prototype.getDeltaPosition = function () {
		return this.deltaPosition.clone();
	};

	EventServices.registerEvent(TouchMoveEvent);

	// Expose in EP namespace.
	EP.TouchMoveEvent = TouchMoveEvent;

	return TouchMoveEvent;
});
