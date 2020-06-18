define('DS/EPInputs/EPKeyboard', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 * Describe an object representing a keyboard.</br>
	 * It contains the state of the device.
	 *
	 * @constructor
	 * @alias EP.Keyboard
	 * @noinstancector
	 * @public
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 */
	var Keyboard = function () {

		/**
	     * Keyboard Modifier Pressed.
	     *
	     * @private
	     * @type {EP.Keyboard.FModifier}
		 * @see EP.Keyboard#getModifier
	     */
	    this.modifier = Keyboard.FModifier.fNone;

	    /**
	     * The list of keys currently pressed.
	     *
	     * @private
	     * @type {Array.<EP.Keyboard.EKey>}
		 * @see EP.Keyboard#getKeysPressed
		 * @see EP.Keyboard#isKeyPressed
	     */
		this.keysPressed = [];

	};

	/**
	 * An enumeration of all the supported keys.</br>
	 * It allows to refer in the code to a specific key.
	 *
	 * @enum {number}
	 * @public
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 * if(keyboard.isKeyPressed(EP.Keyboard.EKey.eSpace)) {
	 *	// Space key is pressed
	 * }
	 */
	Keyboard.EKey = {
		eBackspace: 8, eTab: 9, eClear: 12, eEnter: 13,
		eShift: 16, eControl: 17, eAlt: 18, ePause: 19, eCapsLock: 20,
		eEscape: 27, eSpace: 32, ePageUp: 33, ePageDown: 34, eEnd: 35, eHome: 36, eLeft: 37, eUp: 38, eRight: 39, eDown: 40,
		eInsert: 45, eDelete: 46,

		e0: 48, e1: 49, e2: 50, e3: 51, e4: 52, e5: 53, e6: 54, e7: 55, e8: 56, e9: 57,
		eA: 65, eB: 66, eC: 67, eD: 68, eE: 69, eF: 70, eG: 71, eH: 72, eI: 73, eJ: 74, eK: 75, eL: 76, eM: 77,
		eN: 78, eO: 79, eP: 80, eQ: 81, eR: 82, eS: 83, eT: 84, eU: 85, eV: 86, eW: 87, eX: 88, eY: 89, eZ: 90,

		// Windows Keys
		eLWin: 91, eRWin: 92, eApps: 93,

		// Numpad Keys
		eNumpad0: 96, eNumpad1: 97, eNumpad2: 98, eNumpad3: 99, eNumpad4: 100, eNumpad5: 101, eNumpad6: 102, eNumpad7: 103, eNumpad8: 104, eNumpad9: 105,
		eMultiply: 106, eAdd: 107, eSubtract: 109, eDecimal: 110, eDivide: 111,

		eF1: 112, eF2: 113, eF3: 114, eF4: 115, eF5: 116, eF6: 117, eF7: 118, eF8: 119, eF9: 120, eF10: 121, eF11: 122, eF12: 123,
		eNumLock: 144, eScroll: 145,

		// OEM Keys
		eOEM1: 186, ePlus: 187, eComma: 188, eMinus: 189, ePeriod: 190, eOEM2: 191, eOEM3: 192,
		eOEM4: 219, eOEM5: 220, eOEM6: 221, eOEM7: 222, eOEM8: 223,
		eOEM102: 226
	};
	Object.freeze(Keyboard.EKey);

	/**
	 * An enumeration flag of all supported modifiers (special key being pressed along with another key).</br>
	 * It allows to refer in the code to a specific modifier.
	 *
	 * @enum {number}
	 * @public
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 * if(keyboard.getModifier() & EP.Keyboard.FModifier.fShift) {
	 *	// Shift modifier is activated !
	 * }
	 */
	Keyboard.FModifier = { fNone: 0, fControl: 1 << 0, fShift: 1 << 1, fAlt: 1 << 2 };
	Object.freeze(Keyboard.FModifier);

	Keyboard.prototype.constructor = Keyboard;

	/**
	 * Return modifier value.
	 *
	 * @public
	 * @return {EP.Keyboard.FModifier} Flag value
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 * if(keyboard.getModifier() & EP.Keyboard.FModifier.fControl) {
	 *	// Control modifier is activated !
	 * }
	 * if(keyboard.getModifier() & EP.Keyboard.FModifier.fShift) {
	 *	// Shift modifier is activated !
	 * }
	 */
	Keyboard.prototype.getModifier = function () {
		return this.modifier;
	};

	/**
	 * Return the list of keys currently pressed from the keyboard device.</br>
	 * Each element is an Enum value.
	 *
	 * @public
	 * @return {Array.<EP.Keyboard.EKey>}
	 * @see EP.Keyboard#isKeyPressed
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 * var keysPressed = keyboard.getKeysPressed();
	 * for(var i=0; i&lt;keysPressed.length; i++) {
	 *	// keysPressed[i] is pressed
	 * }
	 */
	Keyboard.prototype.getKeysPressed = function () {
		return this.keysPressed.slice(0);
	};

	/**
	 * Deprecated ! Please use getKeysPressed instead !
	 *
	 * @deprecated R2019x
	 * @return {Array.<EP.Keyboard.EKey>}
	 * @see EP.Keyboard#getKeysPressed
	 */
	Keyboard.prototype.getKeyPressed = function () {
		return this.getKeysPressed();
	};

	/**
	 * Check if the key specified is pressed.
	 *
	 * @public
	 * @param {EP.Keyboard.EKey} iKey Enum value
	 * @return {boolean}
	 * @see EP.Keyboard#getKeysPressed
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 * if(keyboard.isKeyPressed(EP.Keyboard.EKey.eLeft)) {
	 *	// Left key is pressed
	 * }
	 */
	Keyboard.prototype.isKeyPressed = function (iKey) {
		return this.keysPressed.indexOf(iKey) !== -1;
	};

	// Expose in EP namespace.
	EP.Keyboard = Keyboard;

	return Keyboard;
});
