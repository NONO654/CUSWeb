define('DS/EPInputs/EPMouse', ['DS/EP/EP', 'MathematicsES/MathVector2DJSImpl'], function (EP, Vector2D) {
	'use strict';

	/**
	 * Describe an object representing a mouse.</br>
	 * It contains the state of the device.
	 *
	 * @constructor
	 * @alias EP.Mouse
	 * @noinstancector
	 * @public
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 */
	var Mouse = function () {

		/**
	     * Cursor pixel position in the 3D viewer.
	     *
	     * @private
	     * @type {DSMath.Vector2D}
		 * @see EP.Mouse#getPosition
	     */
	    this.position = new Vector2D();

		/**
	     * The list of buttons currently pressed.
	     *
	     * @private
	     * @type {Array.<EP.Mouse.EButton>}
		 * @see EP.Mouse#getButtonsPressed
		 * @see EP.Mouse#isButtonPressed
	     */
		this.buttonsPressed = [];
	};

	/**
	 * An enumeration of all supported mouse buttons.</br>
	 * It allows to refer in the code to a specific mouse button.
	 *
	 * @enum {number}
	 * @public
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 * if(mouse.isButtonPressed(EP.Mouse.EButton.eLeft)) {
	 *	// Left mouse button is pressed
	 * }
	 */
	Mouse.EButton = { eLeft: 0, eMiddle: 1, eRight: 2 };
	Object.freeze(Mouse.EButton);

	Mouse.prototype.constructor = Mouse;

	/**
	 * Return the cursor pixel position in the 3D viewer.
	 *
	 * @public
	 * @return {DSMath.Vector2D}
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 * var mousePosition = mouse.getPosition();
	 * var mouseWidth = mousePosition.x;
	 * var mouseHeight = mousePosition.y;
	 */
	Mouse.prototype.getPosition = function () {
		return this.position.clone();
	};

	/**
	 * Return the list of buttons currently pressed from the mouse device.</br>
	 * Each element is an Enum value.
	 *
	 * @public
	 * @return {Array.<EP.Mouse.EButton>}
	 * @see EP.Mouse#isButtonPressed
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 * var buttonsPressed = mouse.getButtonsPressed();
	 * for(var i=0; i&lt;buttonsPressed.length; i++) {
	 *	// buttonsPressed[i] is pressed
	 * }
	 */
	Mouse.prototype.getButtonsPressed = function () {
		return this.buttonsPressed.slice(0);
	};

	/**
	 * Deprecated ! Please use getButtonsPressed instead !
	 *
	 * @deprecated R2019x
	 * @public
	 * @return {Array.<EP.Mouse.EButton>}
	 * @see EP.Mouse#getButtonsPressed
	 */
	Mouse.prototype.getButtonPressed = function () {
		return this.getButtonsPressed();
	};

	/**
	 * Check if the button specified is pressed.
	 *
	 * @public
	 * @param {EP.Mouse.EButton} iMouseButton Enum value
	 * @return {boolean}
	 * @see EP.Mouse#getButtonsPressed
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 * if(mouse.isButtonPressed(EP.Mouse.EButton.eMiddle)) {
	 *	// Middle mouse button is pressed
	 * }
	 */
	Mouse.prototype.isButtonPressed = function (iMouseButton) {
		return this.buttonsPressed.indexOf(iMouseButton) !== -1;
	};

	// Expose in EP namespace.
	EP.Mouse = Mouse;

	return Mouse;
});
