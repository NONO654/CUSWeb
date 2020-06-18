define('DS/EPInputs/EPTouch', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * Describe an object representing a touch device.</br>
	 * It contains the state of the device.
	 *
	 * @constructor
	 * @alias EP.Touch
	 * @noinstancector
	 * @public
	 * @example
	 * var touch = EP.Devices.getTouch();
	 */
	var Touch = function () {

		/**
	     * Contact pixel position in the 3D viewer by touch id.
	     *
	     * @private
	     * @type {Object<number, DSMath.Vector2D>}
		 * @see EP.Touch#getPositionById
	     */
		this.positionsById = {};

		/**
	     * The list of touch ids currently pressed.
	     *
	     * @private
	     * @type {Array.<number>}
		 * @see EP.Touch#getIdsPressed
		 * @see EP.Touch#isIdPressed
	     */
		this.idsPressed = [];
	};

	Touch.prototype.constructor = Touch;

	/**
	 * Return the contact pixel position in the 3D viewer by touch id.
	 *
	 * @public
	 * @param {number} iTouchId
	 * @return {DSMath.Vector2D}
	 * @example
	 * var touch = EP.Devices.getTouch();
	 * var touchPosition = touch.getPositionById(0);
	 * var touchWidth = touchPosition.x;
	 * var touchHeight = touchPosition.y;
	 */
	Touch.prototype.getPositionById = function (iTouchId) {
		return this.positionsById[iTouchId] !== undefined ? this.positionsById[iTouchId].clone() : undefined;
	};

	/**
	 * Return the list of touch ids currently pressed on the touch device.</br>
	 *
	 * @public
	 * @return {Array.<number>}
	 * @see EP.Touch#isIdPressed
	 * @example
	 * var touch = EP.Devices.getTouch();
	 * var idsPressed = touch.getIdsPressed();
	 * for(var i=0; i&lt;idsPressed.length; i++) {
	 *	// idsPressed[i] is pressed
	 * }
	 */
	Touch.prototype.getIdsPressed = function () {
		return this.idsPressed.slice(0);
	};

	/**
	 * Check if the touch id specified is pressed.
	 *
	 * @public
	 * @param {number} iTouchId
	 * @return {boolean}
	 * @see EP.Touch#getIdsPressed
	 * @example
	 * var touch = EP.Devices.getTouch();
	 * if(touch.isIdPressed(0)) {
	 *	// touch id 0 is pressed
	 * }
	 */
	Touch.prototype.isIdPressed = function (iTouchId) {
		return this.idsPressed.indexOf(iTouchId) !== -1;
	};

	// Expose in EP namespace.
	EP.Touch = Touch;

	return Touch;
});
