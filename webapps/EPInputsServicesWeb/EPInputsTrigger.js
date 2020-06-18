define('DS/EPInputsServicesWeb/EPInputsTrigger', [
    'DS/EP/EP',
	'DS/ExperiencePlay/EPJSONMessage',
	'MathematicsES/MathVector2DJSImpl',
	'DS/EPInputs/EPMouseMoveEvent',
	'DS/EPInputs/EPMousePressEvent',
	'DS/EPInputs/EPMouseReleaseEvent',
	'DS/EPInputs/EPMouseClickEvent',
	'DS/EPInputs/EPMouseDoubleClickEvent',
	'DS/EPInputs/EPMouseWheelEvent',
	'DS/EPInputs/EPKeyboard',
	'DS/EPInputs/EPKeyboardPressEvent',
	'DS/EPInputs/EPKeyboardReleaseEvent',
	'DS/EPInputs/EPGamepadAxisEvent',
	'DS/EPInputs/EPGamepadPressEvent',
	'DS/EPInputs/EPGamepadReleaseEvent'
], function (EP, JSONMessage, Vector2D,
	MouseMoveEvent, MousePressEvent, MouseReleaseEvent, MouseClickEvent, MouseDoubleClickEvent, MouseWheelEvent,
	Keyboard, KeyboardPressEvent, KeyboardReleaseEvent,
	GamepadAxisEvent, GamepadPressEvent, GamepadReleaseEvent) {
	'use strict';

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.InputsTrigger
	 * @private
	 */
	var InputsTrigger = function () {

	};

	InputsTrigger.prototype.constructor = InputsTrigger;

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.TargetEvent
	 * @private
	 * @param {string} iEventName
	 */
	var TargetEvent = function (iEventName) {

		this.eventName = iEventName;
		this.parameters = [];
	};

	TargetEvent.prototype.constructor = TargetEvent;

	TargetEvent.prototype.addParameter = function (iType, iName, iValue) {
		if (typeof iType !== 'number') {
			throw new TypeError('iType argument is not an enum element');
		}

		if (typeof iName !== 'string') {
			throw new TypeError('iName argument is not a string');
		}

		if (iValue === undefined) {
			throw new TypeError('iValue argument is not defined');
		}

		this.parameters.push(iType);
		this.parameters.push(iName);
		this.parameters.push(iValue);
	};

	TargetEvent.prototype.toMessage = function () {
		var message = new JSONMessage('', '', this.eventName);

		message.SetTypedNamedParameters.apply(message, this.parameters);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseMoveTrigger
	 * @private
	 */
	var MouseMoveTrigger = function () {
		InputsTrigger.call(this);

		this.deltaPositionIntervalList = [];
		this.positionIntervalList = [];
	};

	MouseMoveTrigger.prototype = Object.create(InputsTrigger.prototype);
	MouseMoveTrigger.prototype.constructor = MouseMoveTrigger;

	MouseMoveTrigger.prototype.addDeltaPositionInterval = function (iDeltaPositionMin, iDeltaPositionMax) {
		if (!(iDeltaPositionMin instanceof Vector2D)) {
			throw new TypeError('iDeltaPositionMin argument is not a Vector2D');
		}

		if (!(iDeltaPositionMax instanceof Vector2D)) {
			throw new TypeError('iDeltaPositionMax argument is not a Vector2D');
		}

		if (iDeltaPositionMin.x > iDeltaPositionMax.x || iDeltaPositionMin.y > iDeltaPositionMax.y) {
			throw new RangeError('iDeltaPositionMin argument value is upper than iDeltaPositionMax argument value');
		}

		this.deltaPositionIntervalList.push(iDeltaPositionMin.x);
		this.deltaPositionIntervalList.push(iDeltaPositionMin.y);
		this.deltaPositionIntervalList.push(iDeltaPositionMax.x);
		this.deltaPositionIntervalList.push(iDeltaPositionMax.y);
	};

	MouseMoveTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MouseMoveTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MouseMoveEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eDoubleArray, 'deltaPositionIntervalList', this.deltaPositionIntervalList,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MousePressTrigger
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	var MousePressTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.positionIntervalList = [];
		this.button = iButton;
	};

	MousePressTrigger.prototype = Object.create(InputsTrigger.prototype);
	MousePressTrigger.prototype.constructor = MousePressTrigger;

	MousePressTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MousePressTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MousePressEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseReleaseTrigger
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	var MouseReleaseTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.positionIntervalList = [];
		this.button = iButton;
	};

	MouseReleaseTrigger.prototype = Object.create(InputsTrigger.prototype);
	MouseReleaseTrigger.prototype.constructor = MouseReleaseTrigger;

	MouseReleaseTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MouseReleaseTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MouseReleaseEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseClickTrigger
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	var MouseClickTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.positionIntervalList = [];
		this.button = iButton;
	};

	MouseClickTrigger.prototype = Object.create(InputsTrigger.prototype);
	MouseClickTrigger.prototype.constructor = MouseClickTrigger;

	MouseClickTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MouseClickTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MouseClickEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseDoubleClickTrigger
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	var MouseDoubleClickTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.positionIntervalList = [];
		this.button = iButton;
	};

	MouseDoubleClickTrigger.prototype = Object.create(InputsTrigger.prototype);
	MouseDoubleClickTrigger.prototype.constructor = MouseDoubleClickTrigger;

	MouseDoubleClickTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MouseDoubleClickTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MouseDoubleClickEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseWheelTrigger
	 * @private
	 */
	var MouseWheelTrigger = function () {
		InputsTrigger.call(this);

		this.wheelDeltaValueIntervalList = [];
		this.positionIntervalList = [];
	};

	MouseWheelTrigger.prototype = Object.create(InputsTrigger.prototype);
	MouseWheelTrigger.prototype.constructor = MouseWheelTrigger;

	MouseWheelTrigger.prototype.addWheelDeltaValueInterval = function (iWheelDeltaValueMin, iWheelDeltaValueMax) {
		if (typeof iWheelDeltaValueMin !== 'number') {
			throw new TypeError('iWheelDeltaValueMin argument is not a number');
		}

		if (typeof iWheelDeltaValueMax !== 'number') {
			throw new TypeError('iPositionMax argument is not a number');
		}

		if (iWheelDeltaValueMin > iWheelDeltaValueMax) {
			throw new RangeError('iWheelDeltaValueMin argument value is upper than iWheelDeltaValueMax argument value');
		}

		this.wheelDeltaValueIntervalList.push(iWheelDeltaValueMin);
		this.wheelDeltaValueIntervalList.push(iWheelDeltaValueMax);
	};

	MouseWheelTrigger.prototype.addPositionInterval = function (iPositionMin, iPositionMax) {
		if (!(iPositionMin instanceof Vector2D)) {
			throw new TypeError('iPositionMin argument is not a Vector2D');
		}

		if (!(iPositionMax instanceof Vector2D)) {
			throw new TypeError('iPositionMax argument is not a Vector2D');
		}

		if (iPositionMin.x > iPositionMax.x || iPositionMin.y > iPositionMax.y) {
			throw new RangeError('iPositionMin argument value is upper than iPositionMax argument value');
		}

		this.positionIntervalList.push(iPositionMin.x);
		this.positionIntervalList.push(iPositionMin.y);
		this.positionIntervalList.push(iPositionMax.x);
		this.positionIntervalList.push(iPositionMax.y);
	};

	MouseWheelTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', MouseWheelEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eDoubleArray, 'wheelDeltaValueIntervalList', this.wheelDeltaValueIntervalList,
										JSONMessage.EValueType.eDoubleArray, 'positionIntervalList', this.positionIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.KeyboardPressTrigger
	 * @private
	 * @param {EP.Keyboard.EKey} iKey
	 * @param {EP.Keyboard.FModifier} [iModifier=EP.Keyboard.FModifier.fNone]
	 * @param {boolean} [iRepeat=false]
	 */
	var KeyboardPressTrigger = function (iKey, iModifier, iRepeat) {
		InputsTrigger.call(this);

		this.key = iKey;
		this.modifier = iModifier || Keyboard.FModifier.fNone;
		this.repeat = iRepeat || false;
	};

	KeyboardPressTrigger.prototype = Object.create(InputsTrigger.prototype);
	KeyboardPressTrigger.prototype.constructor = KeyboardPressTrigger;

	KeyboardPressTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', KeyboardPressEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'key', this.key,
										JSONMessage.EValueType.eInt, 'modifier', this.modifier,
										JSONMessage.EValueType.eBool, 'repeat', this.repeat);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.KeyboardReleaseTrigger
	 * @private
	 * @param {EP.Keyboard.EKey} iKey
	 * @param {EP.Keyboard.FModifier} [iModifier=EP.Keyboard.FModifier.fNone]
	 */
	var KeyboardReleaseTrigger = function (iKey, iModifier) {
		InputsTrigger.call(this);

		this.key = iKey;
		this.modifier = iModifier || Keyboard.FModifier.fNone;
	};

	KeyboardReleaseTrigger.prototype = Object.create(InputsTrigger.prototype);
	KeyboardReleaseTrigger.prototype.constructor = KeyboardReleaseTrigger;

	KeyboardReleaseTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', KeyboardReleaseEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'key', this.key,
										JSONMessage.EValueType.eInt, 'modifier', this.modifier);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.GamepadAxisTrigger
	 * @private
	 * @param {EP.Gamepad.EAxis} iAxis
	 */
	var GamepadAxisTrigger = function (iAxis) {
		InputsTrigger.call(this);

		this.axis = iAxis;
		this.axisValueIntervalList = [];
	};

	GamepadAxisTrigger.prototype = Object.create(InputsTrigger.prototype);
	GamepadAxisTrigger.prototype.constructor = GamepadAxisTrigger;

	GamepadAxisTrigger.prototype.addAxisValueInterval = function (iAxisValueMin, iAxisValueMax) {
		if (typeof iAxisValueMin !== 'number') {
			throw new TypeError('iAxisValueMin argument is not a number');
		}

		if (typeof iAxisValueMax !== 'number') {
			throw new TypeError('iAxisValueMax argument is not a number');
		}

		if (iAxisValueMin > iAxisValueMax) {
			throw new RangeError('iAxisValueMin argument value is upper than iAxisValueMax argument value');
		}

		this.axisValueIntervalList.push(iAxisValueMin);
		this.axisValueIntervalList.push(iAxisValueMax);
	};

	GamepadAxisTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', GamepadAxisEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eDoubleArray, 'axisValueIntervalList', this.axisValueIntervalList);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.GamepadPressTrigger
	 * @private
	 * @param {EP.Gamepad.EButton} iButton
	 */
	var GamepadPressTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.button = iButton;
	};

	GamepadPressTrigger.prototype = Object.create(InputsTrigger.prototype);
	GamepadPressTrigger.prototype.constructor = GamepadPressTrigger;

	GamepadPressTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', GamepadPressEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button);

		return message;
	};

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.GamepadReleaseTrigger
	 * @private
	 * @param {EP.Gamepad.EButton} iButton
	 */
	var GamepadReleaseTrigger = function (iButton) {
		InputsTrigger.call(this);

		this.button = iButton;
	};

	GamepadReleaseTrigger.prototype = Object.create(InputsTrigger.prototype);
	GamepadReleaseTrigger.prototype.constructor = GamepadReleaseTrigger;

	GamepadReleaseTrigger.prototype.toMessage = function () {
		var message = new JSONMessage('', '', GamepadReleaseEvent.prototype.type);

		message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', this.button);

		return message;
	};

	// Expose in EP namespace.
	EP.InputsTrigger = InputsTrigger;
	EP.TargetEvent = TargetEvent;

	EP.MouseMoveTrigger = MouseMoveTrigger;
	EP.MousePressTrigger = MousePressTrigger;
	EP.MouseReleaseTrigger = MouseReleaseTrigger;
	EP.MouseClickTrigger = MouseClickTrigger;
	EP.MouseDoubleClickTrigger = MouseDoubleClickTrigger;
	EP.MouseWheelTrigger = MouseWheelTrigger;

	EP.KeyboardPressTrigger = KeyboardPressTrigger;
	EP.KeyboardReleaseTrigger = KeyboardReleaseTrigger;

	EP.GamepadAxisTrigger = GamepadAxisTrigger;
	EP.GamepadPressTrigger = GamepadPressTrigger;
	EP.GamepadReleaseTrigger = GamepadReleaseTrigger;

	return EP;
});
