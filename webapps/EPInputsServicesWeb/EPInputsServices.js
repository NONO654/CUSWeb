define('DS/EPInputsServicesWeb/EPInputsServices', [
    'DS/EP/EP',
	'DS/ExperienceKernel/ExperienceKernel',
	'DS/ExperiencePlay/EPJSONMessage',
    'DS/EPInputsServicesWeb/EPKeyboardListener',
    'DS/EPInputsServicesWeb/EPMouseListener',
	'DS/EPInputsServicesWeb/EPTouchListener',
    'DS/EPInputsServicesWeb/EPGamepadListener',
	'DS/EPInputs/EPDevices',
	'DS/EPInputs/EPMouseEnableEvent',
	'DS/EPInputs/EPMouseDisableEvent',
	'DS/EPInputs/EPMouseMoveEvent',
	'DS/EPInputs/EPMousePressEvent',
	'DS/EPInputs/EPMouseReleaseEvent',
	'DS/EPInputs/EPMouseWheelEvent',
	'DS/EPInputs/EPTouchEnableEvent',
	'DS/EPInputs/EPTouchDisableEvent',
	'DS/EPInputs/EPMultiTouchEvent',
	'DS/EPInputs/EPKeyboardEnableEvent',
	'DS/EPInputs/EPKeyboardDisableEvent',
	'DS/EPInputs/EPKeyboardPressEvent',
	'DS/EPInputs/EPKeyboardReleaseEvent',
	'DS/EPInputs/EPGamepadEvent',
	'DS/EPInputs/EPGamepadEnableEvent',
	'DS/EPInputs/EPGamepadDisableEvent'
], function (EP, EK, JSONMessage, KeyboardListener, MouseListener, TouchListener, GamepadListener, Devices,
	MouseEnableEvent, MouseDisableEvent, MouseMoveEvent, MousePressEvent, MouseReleaseEvent, MouseWheelEvent,
	TouchEnableEvent, TouchDisableEvent, MultiTouchEvent,
	KeyboardEnableEvent, KeyboardDisableEvent, KeyboardPressEvent, KeyboardReleaseEvent,
	GamepadEvent, GamepadEnableEvent, GamepadDisableEvent) {
	'use strict';

	var nodePool = 'InputsServicesWeb';
	var windowEvent = 'WindowEvent';
	var inputsEvent = 'InputsEvent';
	var inputsPool = 'InputsEngine';

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.InputsServices
	 * @private
	 * @param {boolean} iEngineMode
	 */
	var InputsServices = function (iEngineMode) {
		this.engineMode = iEngineMode;

		if (this.engineMode) {
			var ekNodeOptions = {};
			ekNodeOptions.pool = nodePool;
			ekNodeOptions.onText = this.onText.bind(this);
			ekNodeOptions.onBinary = this.onBinary.bind(this);
			ekNodeOptions.onHypervisorConnect = this.onHypervisorConnect.bind(this);
			ekNodeOptions.onHypervisorDisconnect = this.onHypervisorDisconnect.bind(this);
			ekNodeOptions.onDisconnect = this.onDisconnect.bind(this);

			this.ekNode = new EK.Node(ekNodeOptions);
			this.inputsEKNodeId = this.ekNode.connect(inputsPool).select();
		}

		this.keyboardListener = undefined;
		this.mouseListener = undefined;
		this.touchListener = undefined;
		this.gamepadListener = undefined;
	};

	InputsServices.prototype.constructor = InputsServices;

    /**
	 *
	 *
	 * @private
	 * @param {string} iText
	 */
	InputsServices.prototype.onText = function () {

	};

    /**
	 *
	 *
	 * @private
	 * @param {ArrayBuffer} iBinary
	 */
	InputsServices.prototype.onBinary = function () {

	};

    /**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onHypervisorConnect = function () {

	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onHypervisorDisconnect = function () {

	};

	/**
	 *
	 *
	 * @private
	 * @param {Object} iNodeId
	 * @param {string} iPool
	 */
	InputsServices.prototype.onDisconnect = function () {

	};

    /**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#disableKeyboard
	 */
	InputsServices.prototype.enableKeyboard = function (iElement) {
		var result = false;

		if (!(iElement instanceof Element)) {
			throw new TypeError('iElement argument is not a Element');
	    }

	    if (this.keyboardListener === undefined) {
	        this.keyboardListener = new KeyboardListener(this);
	        result = this.keyboardListener.register(iElement);
	        if (result) {
	        	this.onKeyboardEnable();
	        }
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#enableKeyboard
	 */
	InputsServices.prototype.disableKeyboard = function () {
		var result = false;

	    if (this.keyboardListener !== undefined) {
	    	result = this.keyboardListener.unRegister();
	    	if (result) {
	    		this.onKeyboardDisable();
	    	}
	        delete this.keyboardListener;
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#disableMouse
	 */
	InputsServices.prototype.enableMouse = function (iElement) {
		var result = false;

		if (!(iElement instanceof Element)) {
			throw new TypeError('iElement argument is not a Element');
		}

	    if (this.mouseListener === undefined) {
	        this.mouseListener = new MouseListener(this);
	        result = this.mouseListener.register(iElement);
	        if (result) {
	        	this.onMouseEnable();
	        }
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#enableMouse
	 */
	InputsServices.prototype.disableMouse = function () {
		var result = false;

	    if (this.mouseListener !== undefined) {
	    	result = this.mouseListener.unRegister();
	    	if (result) {
	    		this.onMouseDisable();
	    	}
	        delete this.mouseListener;
	    }

	    return result;
	};

	/**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#disableTouch
	 */
	InputsServices.prototype.enableTouch = function (iElement) {
		var result = false;

		if (!(iElement instanceof Element)) {
			throw new TypeError('iElement argument is not a Element');
		}

	    if (this.touchListener === undefined) {
	        this.touchListener = new TouchListener(this);
	        result = this.touchListener.register(iElement);
	        if (result) {
	        	this.onTouchEnable();
	        }
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#enableTouch
	 */
	InputsServices.prototype.disableTouch = function () {
		var result = false;

	    if (this.touchListener !== undefined) {
	    	result = this.touchListener.unRegister();
	    	if (result) {
	    		this.onTouchDisable();
	    	}
	        delete this.touchListener;
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#disableGamepad
	 */
	InputsServices.prototype.enableGamepad = function () {
		var result = false;

	    if (this.gamepadListener === undefined) {
	        this.gamepadListener = new GamepadListener(this);
	        result = this.gamepadListener.register();
	        if (result) {
	        	this.onGamepadEnable();
	        }
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.InputsServices#enableGamepad
	 */
	InputsServices.prototype.disableGamepad = function () {
		var result = false;

	    if (this.gamepadListener !== undefined) {
	    	result = this.gamepadListener.unRegister();
	    	if (result) {
	    		this.onGamepadDisable();
	    	}
	        delete this.gamepadListener;
	    }

	    return result;
	};


	/**
	 *
	 *
	 * @private
	 * @param {EP.InputsTrigger} iInputsTrigger
	 * @param {EP.TargetEvent} iTargetEvent
	 * @see EP.InputsServices#unregisterTargetEvent
	 */
	InputsServices.prototype.registerTargetEvent = function (iInputsTrigger, iTargetEvent) {
		if (!(iInputsTrigger instanceof EP.InputsTrigger)) {
			throw new TypeError('iInputsTrigger argument is not a EP.InputsTrigger');
		}

		if (!(iTargetEvent instanceof EP.TargetEvent)) {
			throw new TypeError('iTargetEvent argument is not a EP.TargetEvent');
		}

		if (this.engineMode) {
			var message = new JSONMessage('RegisterTargetEvent', nodePool);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eObject, 'inputsTrigger', iInputsTrigger.toMessage(),
											JSONMessage.EValueType.eObject, 'targetEvent', iTargetEvent.toMessage());

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
	};

	/**
	 *
	 *
	 * @private
	 * @param {EP.InputsTrigger} iInputsTrigger
	 * @param {EP.TargetEvent} iTargetEvent
	 * @see EP.InputsServices#registerTargetEvent
	 */
	InputsServices.prototype.unregisterTargetEvent = function (iInputsTrigger, iTargetEvent) {
		if (!(iInputsTrigger instanceof EP.InputsTrigger)) {
			throw new TypeError('iInputsTrigger argument is not a EP.InputsTrigger');
		}

		if (!(iTargetEvent instanceof EP.TargetEvent)) {
			throw new TypeError('iTargetEvent argument is not a EP.TargetEvent');
		}

		if (this.engineMode) {
			var message = new JSONMessage('UnregisterTargetEvent', nodePool);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eObject, 'inputsTrigger', iInputsTrigger.toMessage(),
											JSONMessage.EValueType.eObject, 'targetEvent', iTargetEvent.toMessage());

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
	};


	/**
	 *
	 *
	 * @private
	 * @param {{x: number, y: number}} iViewerSize
	 */
	InputsServices.prototype.onWindowResize = function (iViewerSize) {
		if (this.engineMode) {
			var message = new JSONMessage(windowEvent, nodePool, 'WindowResizeEvent');
			message.SetTypedNamedParameters(JSONMessage.EValueType.eObject, 'viewerSize', iViewerSize);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onMouseEnable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MouseEnableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMouseEnableEvent();

	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onMouseDisable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MouseDisableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMouseDisableEvent();
	};

	/**
	 *
	 *
	 * @private
	 * @param {{x: number, y: number}} iPosition
	 */
	InputsServices.prototype.onMouseMove = function (iPosition) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MouseMoveEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eObject, 'position', iPosition);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMouseMoveEvent(iPosition);
	};

	/**
	 *
	 *
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	InputsServices.prototype.onMousePress = function (iButton) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MousePressEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', iButton);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMousePressEvent(iButton);
	};

	/**
	 *
	 *
	 * @private
	 * @param {EP.Mouse.EButton} iButton
	 */
	InputsServices.prototype.onMouseRelease = function (iButton) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MouseReleaseEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'button', iButton);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMouseReleaseEvent(iButton);
	};

	/**
	 *
	 *
	 * @private
	 * @param {number} iWheelDeltaValue
	 */
	InputsServices.prototype.onMouseWheel = function (iWheelDeltaValue) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MouseWheelEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eDouble, 'wheelDeltaValue', iWheelDeltaValue);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMouseWheelEvent(iWheelDeltaValue);
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onTouchEnable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, TouchEnableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendTouchEnableEvent();

	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onTouchDisable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, TouchDisableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendTouchDisableEvent();
	};

	/**
	 *
	 *
	 * @private
	 * @param {Array.<string>} iEventTypeList
	 * @param {Array.<number>} iIdList
	 * @param {Array.<{x: number, y: number}>} iPositionList
	 */
	InputsServices.prototype.onMultiTouch = function (iEventTypeList, iIdList, iPositionList) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, MultiTouchEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eStringArray, 'eventTypes', iEventTypeList,
											JSONMessage.EValueType.eIntArray, 'ids', iIdList,
											JSONMessage.EValueType.eObjectArray, 'positions', iPositionList);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendMultiTouchEvent(iEventTypeList, iIdList, iPositionList);
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onKeyboardEnable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, KeyboardEnableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendKeyboardEnableEvent();
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onKeyboardDisable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, KeyboardDisableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendKeyboardDisableEvent();
	};

	/**
	 *
	 *
	 * @private
	 * @param {EP.Keyboard.EKey} iKey
     * @param {EP.Keyboard.FModifier} iModifier
     * @param {boolean} iRepeat
	 */
	InputsServices.prototype.onKeyboardPress = function (iKey, iModifier, iRepeat) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, KeyboardPressEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'key', iKey,
											JSONMessage.EValueType.eInt, 'modifier', iModifier,
											JSONMessage.EValueType.eBool, 'repeat', iRepeat);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendKeyboardPressEvent(iKey, iModifier, iRepeat);
	};

	/**
	 *
	 *
	 * @private
	 * @param {EP.Keyboard.EKey} iKey
     * @param {EP.Keyboard.FModifier} iModifier
	 */
	InputsServices.prototype.onKeyboardRelease = function (iKey, iModifier) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, KeyboardReleaseEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eInt, 'key', iKey,
											JSONMessage.EValueType.eInt, 'modifier', iModifier);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendKeyboardReleaseEvent(iKey, iModifier);
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onGamepadEnable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, GamepadEnableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendGamepadEnableEvent();
	};

	/**
	 *
	 *
	 * @private
	 */
	InputsServices.prototype.onGamepadDisable = function () {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, GamepadDisableEvent.prototype.type);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendGamepadDisableEvent();
	};

    /**
	 *
	 *
	 * @private
	 * @param {Array.<number>} iButtonValues
     * @param {Array.<number>} iAxisValues
	 */
	InputsServices.prototype.onGamepad = function (iButtonValues, iAxisValues) {
		if (this.engineMode) {
			var message = new JSONMessage(inputsEvent, nodePool, GamepadEvent.prototype.type);
			message.SetTypedNamedParameters(JSONMessage.EValueType.eIntArray, 'buttonValues', iButtonValues,
											JSONMessage.EValueType.eDoubleArray, 'axisValues', iAxisValues);

			this.ekNode.sendText(this.inputsEKNodeId, message.ToJSON());
		}
		Devices.sendGamepadEvent(iButtonValues, iAxisValues);
	};

	// Expose in EP namespace.
	EP.InputsServices = InputsServices;

	return InputsServices;
});
