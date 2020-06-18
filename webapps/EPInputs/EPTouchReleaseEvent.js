define('DS/EPInputs/EPTouchReleaseEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPTouchEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, TouchEvent, Vector2D) {
	'use strict';

	/**
	 * <p>Describe an event generated from a touch device.</br>
	 * It contains information about the touch device.</br>
	 * It occurs when the user ceases a contact on the touch device.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.TouchReleaseEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.TouchReleaseEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.TouchEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchReleaseEvent = function (iTouchReleaseEvent) {
	 *	// user released on the touch device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.TouchReleaseEvent, objectListener, 'onTouchReleaseEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.TouchReleaseEvent, objectListener, 'onTouchReleaseEvent');
	 */
	var TouchReleaseEvent = function (iParameters) {

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
	};

	TouchReleaseEvent.prototype = Object.create(TouchEvent.prototype);
	TouchReleaseEvent.prototype.constructor = TouchReleaseEvent;
	TouchReleaseEvent.prototype.type = 'TouchReleaseEvent';

	/**
	 * Return the touch id.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchReleaseEvent = function (iTouchReleaseEvent) {
	 *	if(iTouchReleaseEvent.getId() === 0) {
	 *		// touch id 0 has been released
	 *	}
	 * };
	 */
	TouchReleaseEvent.prototype.getId = function () {
		return this.id;
	};

	/**
	 * Return the contact pixel position on the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var objectListener = {};
	 * objectListener.onTouchReleaseEvent = function (iTouchReleaseEvent) {
	 *	var touchPosition = iTouchReleaseEvent.getPosition();
	 *	var touchWidth = touchPosition.x;
	 *	var touchHeight = touchPosition.y;
	 * };
	 */
	TouchReleaseEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(TouchReleaseEvent);

	// Expose in EP namespace.
	EP.TouchReleaseEvent = TouchReleaseEvent;

	return TouchReleaseEvent;
});
