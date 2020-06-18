define('DS/EPInputs/EPGamepad', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * Describe an object representing a gamepad.</br>
	 * It contains the state of the device.
	 *
	 * @constructor
	 * @alias EP.Gamepad
	 * @noinstancector
	 * @public
     * @example
	 * var gamepad = EP.Devices.getGamepad();
	 */
	var Gamepad = function () {

		/**
	     * Axis values.
	     *
	     * @private
	     * @type {Array.<number>}
		 * @see EP.Gamepad#getAxisValue
	     */
	    this.axisValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

		/**
	     * The list of buttons currently pressed.
	     *
	     * @private
	     * @type {Array.<EP.Gamepad.EButton>}
		 * @see EP.Gamepad#getButtonsPressed
		 * @see EP.Gamepad#isButtonPressed
	     */
		this.buttonsPressed = [];
	};

	/**
	 * An enumeration of all supported gamepad buttons.</br>
	 * It allows to refer in the code to a specific gamepad button.
	 *
	 * @enum {number}
	 * @public
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 * if(gamepad.isButtonPressed(EP.Gamepad.EButton.e1)) {
	 *	// Gamepad button 1 is pressed
	 * }
	 */
	Gamepad.EButton = {
	    // Generic
	    e1: 0,
	    e2: 1,
	    e3: 2,
	    e4: 3,

	    e5: 4,
	    e6: 5,

        // Manage as axis
	    // e7 -> EAxis.eLT
        // e8 -> EAxis.eRT

	    e9: 6,
	    e10: 7,

	    eLS: 8,
	    eRS: 9,

	    eDPadUp	: 10,
	    eDPadDown: 11,
	    eDPadLeft: 12,
	    eDPadRight: 13,

	    // XBox
	    eA: 0, // e1
	    eB: 1, // e2
	    eX: 2, // e3
	    eY: 3, // e4

	    eLB: 4, // e5
	    eRB: 5, // e6

	    eBack: 6, // e9
	    eStart: 7 // e10
	};
	Object.freeze(Gamepad.EButton);

	/**
	 * An enumeration of all supported gamepad axis.</br>
	 * It allows to refer in the code to a specific gamepad axis.
	 *
	 * @enum {number}
	 * @public
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 * var gamepadAxisValue = gamepad.getAxisValue(EP.Gamepad.EAxis.eLSX);
	 */
	Gamepad.EAxis = {
	    eLSX: 0,
	    eLSY: 1,
	    eRSX: 2,
	    eRSY: 3,
	    eLT: 4,
	    eRT: 5
	};
	Object.freeze(Gamepad.EAxis);

	Gamepad.prototype.constructor = Gamepad;

	/**
	 * Return the axis value.
	 *
	 * @public
	 * @param {EP.Gamepad.EAxis} iGamepadAxis Enum value
	 * @return {number}
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 * var gamepadAxisValue = gamepad.getAxisValue(EP.Gamepad.EAxis.eLSX);
	 */
	Gamepad.prototype.getAxisValue = function (iGamepadAxis) {
	    return this.axisValues[iGamepadAxis];
	};

	/**
	 * Return the list of buttons currently pressed from the gamepad device.</br>
	 * Each element is an Enum value.
	 *
	 * @public
	 * @return {Array.<EP.Gamepad.EButton>}
	 * @see EP.Gamepad#isButtonPressed
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 * var buttonsPressed = gamepad.getButtonsPressed();
	 * for(var i=0; i&lt;buttonsPressed.length; i++) {
	 *	// buttonsPressed[i] is pressed
	 * }
	 */
	Gamepad.prototype.getButtonsPressed = function () {
		return this.buttonsPressed.slice(0);
	};

	/**
	 * Deprecated ! Please use getButtonsPressed instead !
	 *
	 * @deprecated R2019x
	 * @public
	 * @return {Array.<EP.Gamepad.EButton>}
	 * @see EP.Gamepad#getButtonsPressed
	 */
	Gamepad.prototype.getButtonPressed = function () {
		return this.getButtonsPressed();
	};

	/**
	 * Check if the button specified is pressed.
	 *
	 * @public
	 * @param {EP.Gamepad.EButton} iGamepadButton Enum value
	 * @return {boolean}
	 * @see EP.Gamepad#getButtonsPressed
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 * if(gamepad.isButtonPressed(EP.Gamepad.EButton.e1)) {
	 *	// gamepad button 1 is pressed
	 * }
	 */
	Gamepad.prototype.isButtonPressed = function (iGamepadButton) {
		return this.buttonsPressed.indexOf(iGamepadButton) !== -1;
	};

	// Expose in EP namespace.
	EP.Gamepad = Gamepad;

	return Gamepad;
});
