define('DS/EPInputs/EPDevices', [
    'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
    'MathematicsES/MathVector2DJSImpl',
	'DS/EPInputs/EPMouseEnableEvent',
	'DS/EPInputs/EPMouseDisableEvent',
	'DS/EPInputs/EPMouseMoveEvent',
	'DS/EPInputs/EPMousePressEvent',
	'DS/EPInputs/EPMouseReleaseEvent',
	'DS/EPInputs/EPMouseClickEvent',
	'DS/EPInputs/EPMouseDoubleClickEvent',
	'DS/EPInputs/EPMouseWheelEvent',
	'DS/EPInputs/EPTouchEnableEvent',
	'DS/EPInputs/EPTouchDisableEvent',
	'DS/EPInputs/EPTouchMoveEvent',
	'DS/EPInputs/EPTouchIdleEvent',
	'DS/EPInputs/EPTouchPressEvent',
	'DS/EPInputs/EPTouchReleaseEvent',
	'DS/EPInputs/EPMultiTouchEvent',
	'DS/EPInputs/EPGestureEnableEvent',
	'DS/EPInputs/EPGestureDisableEvent',
	'DS/EPInputs/EPGestureTapEvent',
	'DS/EPInputs/EPGestureDoubleTapEvent',
	'DS/EPInputs/EPGestureDragEvent',
	'DS/EPInputs/EPGestureHoldEvent',
	'DS/EPInputs/EPGestureSwipeEvent',
	'DS/EPInputs/EPGesturePanEvent',
	'DS/EPInputs/EPGesturePinchEvent',
	'DS/EPInputs/EPGestureRotateEvent',
	'DS/EPInputs/EPKeyboardEnableEvent',
	'DS/EPInputs/EPKeyboardDisableEvent',
	'DS/EPInputs/EPKeyboardPressEvent',
	'DS/EPInputs/EPKeyboardReleaseEvent',
	'DS/EPInputs/EPGamepadEnableEvent',
	'DS/EPInputs/EPGamepadDisableEvent',
    'DS/EPInputs/EPGamepadAxisEvent',
    'DS/EPInputs/EPGamepadPressEvent',
    'DS/EPInputs/EPGamepadReleaseEvent',
	'DS/EPInputs/EPDeviceEnableEvent',
	'DS/EPInputs/EPDeviceDisableEvent',
    'DS/EPInputs/EPDeviceAxisEvent',
    'DS/EPInputs/EPDevicePressEvent',
    'DS/EPInputs/EPDeviceReleaseEvent',
	'DS/EPInputs/EPDeviceTrackerEvent'
], function (EP, EventServices, Vector2D,
	MouseEnableEvent, MouseDisableEvent, MouseMoveEvent, MousePressEvent, MouseReleaseEvent, MouseClickEvent, MouseDoubleClickEvent, MouseWheelEvent,
	TouchEnableEvent, TouchDisableEvent, TouchMoveEvent, TouchIdleEvent, TouchPressEvent, TouchReleaseEvent, MultiTouchEvent,
	GestureEnableEvent, GestureDisableEvent, GestureTapEvent, GestureDoubleTapEvent, GestureDragEvent, GestureHoldEvent, GestureSwipeEvent, GesturePanEvent, GesturePinchEvent, GestureRotateEvent,
	KeyboardEnableEvent, KeyboardDisableEvent, KeyboardPressEvent, KeyboardReleaseEvent,
	GamepadEnableEvent, GamepadDisableEvent, GamepadAxisEvent, GamepadPressEvent, GamepadReleaseEvent,
	DeviceEnableEvent, DeviceDisableEvent, DeviceAxisEvent, DevicePressEvent, DeviceReleaseEvent, DeviceTrackerEvent) {
    'use strict';

	/**
	 * <p>Describe an object which contains all the device controllers.</br>
	 * It also provides information about device controllers state through accessors.</br>
	 * It is also possible to get notified when device event occurs through the EP.EventServices.</p>
	 *
	 * <p>Device controllers & Events currently managed :</br>
	 * - Mouse : MouseEvent -> MouseEnableEvent, MouseDisableEvent, MouseMoveEvent, MousePressEvent, MouseReleaseEvent, MouseClickEvent, MouseDoubleClickEvent, MouseWheelEvent.</br>
	 * - Touch : MultiTouchEvent, TouchEvent -> TouchEnableEvent, TouchDisableEvent, TouchMoveEvent, TouchIdleEvent, TouchPressEvent, TouchReleaseEvent.</br>
	 * - Keyboard : KeyboardEvent -> KeyboardEnableEvent, KeyboardDisableEvent, KeyboardPressEvent, KeyboardReleaseEvent.</br>
     * - Gamepad : GamepadEvent -> GamepadEnableEvent, GamepadDisableEvent, GamepadPressEvent, GamepadReleaseEvent, GamepadAxisEvent.</br>
	 * - Device : DeviceEvent -> DeviceEnableEvent, DeviceDisableEvent, DevicePressEvent, DeviceReleaseEvent, DeviceAxisEvent, DeviceTrackerEvent.</p>
	 *
	 * @namespace
	 * @alias EP.Devices
	 * @public
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 * var touch = EP.Devices.getTouch();
	 * var keyboard = EP.Devices.getKeyboard();
     * var gamepad = EP.Devices.getGamepad();
	 * var device = EP.Devices.getDevice(0);
	 */
    var Devices = {};

	/**
	 * Mouse device.
	 *
	 * @private
	 * @type {EP.Mouse}
	 * @see EP.Devices.getMouse
	 */
	var mouse;

	/**
	 * Keyboard device.
	 *
	 * @private
	 * @type {EP.Keyboard}
	 * @see EP.Devices.getKeyboard
	 */
	var keyboard;

    /**
	 * Gamepad device.
	 *
	 * @private
	 * @type {EP.Gamepad}
	 * @see EP.Devices.getGamepad
	 */
	var gamepad;

	/**
	 * Touch device.
	 *
	 * @private
	 * @type {EP.Touch}
	 * @see EP.Devices.getTouch
	 */
	var touch;

	/**
	 * Generic device list.
	 *
	 * @private
	 * @type {Array.<EP.Device>}
	 * @see EP.Devices.getDevice
	 */
	var deviceList = [];

	/**
	 * Return the mouse device.</br>
	 * Return undefined when the mouse doesn't exist or is disabled.
	 *
	 * @public
	 * @return {EP.Mouse}
	 * @example
	 * var mouse = EP.Devices.getMouse();
	 */
	Devices.getMouse = function () {
		return mouse;
	};

	/**
	 * Return the keyboard device.</br>
	 * Return undefined when the keyboard doesn't exist or is disabled.
	 *
	 * @public
	 * @return {EP.Keyboard}
	 * @example
	 * var keyboard = EP.Devices.getKeyboard();
	 */
	Devices.getKeyboard = function () {
		return keyboard;
	};

    /**
	 * Return a gamepad device.</br>
	 * Return undefined when the gamepad doesn't exist or is disabled.
	 *
	 * @public
	 * @return {EP.Gamepad}
	 * @example
	 * var gamepad = EP.Devices.getGamepad();
	 */
	Devices.getGamepad = function () {
	    return gamepad;
	};

	/**
	 * Return the touch device.</br>
	 * Return undefined when the touch doesn't exist or is disabled.
	 *
	 * @public
	 * @return {EP.Touch}
	 * @example
	 * var touch = EP.Devices.getTouch();
	 */
	Devices.getTouch = function () {
		return touch;
	};

	/**
	 * Return a generic device.</br>
	 * Return undefined when the device doesn't exist or is disabled.
	 *
	 * @public
	 * @param {number} [iIndex]
	 * @return {EP.Device}
	 * @example
	 * var device = EP.Devices.getDevice(0);
	 */
	Devices.getDevice = function (iIndex) {
		return deviceList[iIndex || 0];
	};

	/**
	 * Return an array of all generic device.
	 *
	 * @public
	 * @return {Array.<EP.Device>}
	 * @example
	 * var deviceList = EP.Devices.getDeviceList();
	 */
	Devices.getDeviceList = function () {
		return deviceList.slice(0);
	};

	Devices.doubleClickTime = 500;

	var buttonClickDate = [];
	var buttonDoubleClickStatus = [false, false, false];

	var onMouseEnableEvent = function (iMouseEnableEvent) {
		mouse = iMouseEnableEvent.getMouse();
	};

	var onMouseDisableEvent = function () {
		mouse = undefined;
	};

	var onMouseMoveEvent = function (iMouseMoveEvent) {
	    mouse.position = iMouseMoveEvent.getPosition();
	};

	var onMousePressEvent = function (iMousePressEvent) {
	    var button = iMousePressEvent.getButton();
	    if (mouse.buttonsPressed.indexOf(button) === -1) {
	        mouse.buttonsPressed.push(button);
	    }
	};

	var onMouseReleaseEvent = function (iMouseReleaseEvent) {
	    var button = iMouseReleaseEvent.getButton();
	    var index = mouse.buttonsPressed.indexOf(button);
	    if (index !== -1) {
	        mouse.buttonsPressed.splice(index, 1);
	    }
	};

	var onTouchEnableEvent = function (iTouchEnableEvent) {
		touch = iTouchEnableEvent.getTouch();
	};

	var onTouchDisableEvent = function () {
		touch = undefined;
	};

	var onTouchMoveEvent = function (iTouchMoveEvent) {
		touch.positionsById[iTouchMoveEvent.getId()] = iTouchMoveEvent.getPosition();
	};

	var onTouchPressEvent = function (iTouchPressEvent) {
		var id = iTouchPressEvent.getId();
		if (touch.idsPressed.indexOf(id) === -1) {
			touch.idsPressed.push(id);
			touch.positionsById[id] = iTouchPressEvent.getPosition();
		}
	};

	var onTouchReleaseEvent = function (iTouchReleaseEvent) {
		var id = iTouchReleaseEvent.getId();
		var index = touch.idsPressed.indexOf(id);
		if (index !== -1) {
			touch.idsPressed.splice(index, 1);
			touch.positionsById[id] = undefined;
		}
	};

	var onKeyboardEnableEvent = function (iKeyboardEnableEvent) {
		keyboard = iKeyboardEnableEvent.getKeyboard();
	};

	var onKeyboardDisableEvent = function () {
		keyboard = undefined;
	};

	var onKeyboardPressEvent = function (iKeyboardPressEvent) {
	    var key = iKeyboardPressEvent.getKey();
	    if (keyboard.keysPressed.indexOf(key) === -1) {
	        keyboard.keysPressed.push(key);
	    }
	    keyboard.modifier = iKeyboardPressEvent.getModifier();
	};

	var onKeyboardReleaseEvent = function (iKeyboardReleaseEvent) {
	    var key = iKeyboardReleaseEvent.getKey();
	    var index = keyboard.keysPressed.indexOf(key);
	    if (index !== -1) {
	        keyboard.keysPressed.splice(index, 1);
	    }
	    keyboard.modifier = iKeyboardReleaseEvent.getModifier();
	};

	var onGamepadEnableEvent = function (iGamepadEnableEvent) {
		gamepad = iGamepadEnableEvent.getGamepad();
	};

	var onGamepadDisableEvent = function () {
		gamepad = undefined;
	};

	var onGamepadPressEvent = function (iGamepadPressEvent) {
	    var button = iGamepadPressEvent.getButton();
	    if (gamepad.buttonsPressed.indexOf(button) === -1) {
	        gamepad.buttonsPressed.push(button);
	    }
	};

	var onGamepadReleaseEvent = function (iGamepadReleaseEvent) {
	    var button = iGamepadReleaseEvent.getButton();
	    var index = gamepad.buttonsPressed.indexOf(button);
	    if (index !== -1) {
	        gamepad.buttonsPressed.splice(index, 1);
	    }
	};

	var onGamepadAxisEvent = function (iGamepadAxisEvent) {
		var axis = iGamepadAxisEvent.getAxis();
		var axisValue = iGamepadAxisEvent.getAxisValue();
		gamepad.axisValues[axis] = axisValue;
	};

	var onDeviceEnableEvent = function (iDeviceEnableEvent) {
		var device = iDeviceEnableEvent.getDevice();
		deviceList[device.getIndex()] = device;
	};

	var onDeviceDisableEvent = function (iDeviceDisableEvent) {
		var device = iDeviceDisableEvent.getDevice();
		deviceList[device.getIndex()] = undefined;
	};

	var onDevicePressEvent = function (iDevicePressEvent) {
		var device = iDevicePressEvent.getDevice();
		var button = iDevicePressEvent.getButton();
		if (device.buttonsPressed.indexOf(button) === -1) {
			device.buttonsPressed.push(button);
		}
	};

	var onDeviceReleaseEvent = function (iDeviceReleaseEvent) {
		var device = iDeviceReleaseEvent.getDevice();
		var button = iDeviceReleaseEvent.getButton();
		var index = device.buttonsPressed.indexOf(button);
		if (index !== -1) {
			device.buttonsPressed.splice(index, 1);
		}
	};

	var onDeviceAxisEvent = function (iDeviceAxisEvent) {
		var device = iDeviceAxisEvent.getDevice();
		var axis = iDeviceAxisEvent.getAxis();
		var axisValue = iDeviceAxisEvent.getAxisValue();
		device.axisValues[axis] = axisValue;
	};

	var onDeviceTrackerEvent = function (iDeviceTrackerEvent) {
		var device = iDeviceTrackerEvent.getDevice();
		var tracker = iDeviceTrackerEvent.getTracker();
		var trackerValue = iDeviceTrackerEvent.getTrackerValue();
		device.trackerValues[tracker] = trackerValue;
	};

	EventServices.addListener(MouseEnableEvent, onMouseEnableEvent);
	EventServices.addListener(MouseDisableEvent, onMouseDisableEvent);
	EventServices.addListener(MouseMoveEvent, onMouseMoveEvent);
	EventServices.addListener(MousePressEvent, onMousePressEvent);
	EventServices.addListener(MouseReleaseEvent, onMouseReleaseEvent);
	EventServices.addListener(TouchEnableEvent, onTouchEnableEvent);
	EventServices.addListener(TouchDisableEvent, onTouchDisableEvent);
	EventServices.addListener(TouchMoveEvent, onTouchMoveEvent);
	EventServices.addListener(TouchPressEvent, onTouchPressEvent);
	EventServices.addListener(TouchReleaseEvent, onTouchReleaseEvent);
	EventServices.addListener(KeyboardEnableEvent, onKeyboardEnableEvent);
	EventServices.addListener(KeyboardDisableEvent, onKeyboardDisableEvent);
	EventServices.addListener(KeyboardPressEvent, onKeyboardPressEvent);
	EventServices.addListener(KeyboardReleaseEvent, onKeyboardReleaseEvent);
	EventServices.addListener(GamepadEnableEvent, onGamepadEnableEvent);
	EventServices.addListener(GamepadDisableEvent, onGamepadDisableEvent);
	EventServices.addListener(GamepadPressEvent, onGamepadPressEvent);
	EventServices.addListener(GamepadReleaseEvent, onGamepadReleaseEvent);
	EventServices.addListener(GamepadAxisEvent, onGamepadAxisEvent);
	EventServices.addListener(DeviceEnableEvent, onDeviceEnableEvent);
	EventServices.addListener(DeviceDisableEvent, onDeviceDisableEvent);
	EventServices.addListener(DevicePressEvent, onDevicePressEvent);
	EventServices.addListener(DeviceReleaseEvent, onDeviceReleaseEvent);
	EventServices.addListener(DeviceAxisEvent, onDeviceAxisEvent);
	EventServices.addListener(DeviceTrackerEvent, onDeviceTrackerEvent);

	/**
	 * Process to execute when devices are initializing.
	 *
	 * @private
	 * @see EP.Devices.dispose
	 */
	Devices.initialize = function () {
		EventServices.addListener(MouseEnableEvent, onMouseEnableEvent);
		EventServices.addListener(MouseDisableEvent, onMouseDisableEvent);
		EventServices.addListener(MouseMoveEvent, onMouseMoveEvent);
		EventServices.addListener(MousePressEvent, onMousePressEvent);
		EventServices.addListener(MouseReleaseEvent, onMouseReleaseEvent);
		EventServices.addListener(TouchEnableEvent, onTouchEnableEvent);
		EventServices.addListener(TouchDisableEvent, onTouchDisableEvent);
		EventServices.addListener(TouchMoveEvent, onTouchMoveEvent);
		EventServices.addListener(TouchPressEvent, onTouchPressEvent);
		EventServices.addListener(TouchReleaseEvent, onTouchReleaseEvent);
		EventServices.addListener(KeyboardEnableEvent, onKeyboardEnableEvent);
		EventServices.addListener(KeyboardDisableEvent, onKeyboardDisableEvent);
		EventServices.addListener(KeyboardPressEvent, onKeyboardPressEvent);
		EventServices.addListener(KeyboardReleaseEvent, onKeyboardReleaseEvent);
		EventServices.addListener(GamepadEnableEvent, onGamepadEnableEvent);
		EventServices.addListener(GamepadDisableEvent, onGamepadDisableEvent);
		EventServices.addListener(GamepadPressEvent, onGamepadPressEvent);
		EventServices.addListener(GamepadReleaseEvent, onGamepadReleaseEvent);
		EventServices.addListener(GamepadAxisEvent, onGamepadAxisEvent);
		EventServices.addListener(DeviceEnableEvent, onDeviceEnableEvent);
		EventServices.addListener(DeviceDisableEvent, onDeviceDisableEvent);
		EventServices.addListener(DevicePressEvent, onDevicePressEvent);
		EventServices.addListener(DeviceReleaseEvent, onDeviceReleaseEvent);
		EventServices.addListener(DeviceAxisEvent, onDeviceAxisEvent);
		EventServices.addListener(DeviceTrackerEvent, onDeviceTrackerEvent);
	};

	/**
	 * Process to execute when devices are disposing.
	 *
	 * @private
	 * @see EP.Devices.initialize
	 */
	Devices.dispose = function () {
		EventServices.removeListener(MouseEnableEvent, onMouseEnableEvent);
		EventServices.removeListener(MouseDisableEvent, onMouseDisableEvent);
		EventServices.removeListener(MouseMoveEvent, onMouseMoveEvent);
		EventServices.removeListener(MousePressEvent, onMousePressEvent);
		EventServices.removeListener(MouseReleaseEvent, onMouseReleaseEvent);
		EventServices.removeListener(TouchEnableEvent, onTouchEnableEvent);
		EventServices.removeListener(TouchDisableEvent, onTouchDisableEvent);
		EventServices.removeListener(TouchMoveEvent, onTouchMoveEvent);
		EventServices.removeListener(TouchPressEvent, onTouchPressEvent);
		EventServices.removeListener(TouchReleaseEvent, onTouchReleaseEvent);
		EventServices.removeListener(KeyboardEnableEvent, onKeyboardEnableEvent);
		EventServices.removeListener(KeyboardDisableEvent, onKeyboardDisableEvent);
		EventServices.removeListener(KeyboardPressEvent, onKeyboardPressEvent);
		EventServices.removeListener(KeyboardReleaseEvent, onKeyboardReleaseEvent);
		EventServices.removeListener(GamepadEnableEvent, onGamepadEnableEvent);
		EventServices.removeListener(GamepadDisableEvent, onGamepadDisableEvent);
		EventServices.removeListener(GamepadPressEvent, onGamepadPressEvent);
		EventServices.removeListener(GamepadReleaseEvent, onGamepadReleaseEvent);
		EventServices.removeListener(GamepadAxisEvent, onGamepadAxisEvent);
		EventServices.removeListener(DeviceEnableEvent, onDeviceEnableEvent);
		EventServices.removeListener(DeviceDisableEvent, onDeviceDisableEvent);
		EventServices.removeListener(DevicePressEvent, onDevicePressEvent);
		EventServices.removeListener(DeviceReleaseEvent, onDeviceReleaseEvent);
		EventServices.removeListener(DeviceAxisEvent, onDeviceAxisEvent);
		EventServices.removeListener(DeviceTrackerEvent, onDeviceTrackerEvent);
	};

	Devices.sendMouseEnableEvent = function () {
		var parameters = {};
		var newEvt = new MouseEnableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendMouseDisableEvent = function () {
		var parameters = {};
		var newEvt = new MouseDisableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendMouseMoveEvent = function (iPosition) {
	    var position = new Vector2D();
	    position.x = iPosition.x;
	    position.y = iPosition.y;

	    // The mouse really moved
	    if (position.x !== mouse.position.x || position.y !== mouse.position.y) {
	    	var deltaPosition = Vector2D.sub(position, mouse.position);

	    	var parameters = {};
	    	parameters.position = position;
	    	parameters.deltaPosition = deltaPosition;
	    	var newEvt = new MouseMoveEvent(parameters);
	        newEvt.position = position;
	        newEvt.deltaPosition = deltaPosition;
	        EventServices.dispatchEvent(newEvt);

	        // Click & DoubleClick : Cancel Event
	        buttonClickDate.length = 0;
	        buttonDoubleClickStatus = [false, false, false];
	    }
	};

	Devices.sendMousePressEvent = function (iButton, iDoubleClick) {
		var parameters = {};
		parameters.position = mouse.getPosition();
		parameters.button = iButton;
		var newEvt = new MousePressEvent(parameters);
	    newEvt.position = mouse.getPosition();
	    newEvt.button = iButton;
	    EventServices.dispatchEvent(newEvt);

	    // Click & DoubleClick : Start Event
	    if (buttonClickDate[iButton] === undefined) {
	        buttonClickDate[iButton] = new Date();
	    }
	    else {
	        var currentDate = new Date();
	        var elapsed = currentDate.getTime() - buttonClickDate[iButton].getTime();
	        if (iDoubleClick || (iDoubleClick === undefined && elapsed < Devices.doubleClickTime)) {
	            buttonDoubleClickStatus[iButton] = true;
	            buttonClickDate[iButton] = undefined;
	        }
	        else {
	            buttonClickDate[iButton] = currentDate;
	        }
	    }
	};

	Devices.sendMouseReleaseEvent = function (iButton) {
		var parameters = {};
		parameters.position = mouse.getPosition();
		parameters.button = iButton;
		var newEvt = new MouseReleaseEvent(parameters);
	    newEvt.position = mouse.getPosition();
	    newEvt.button = iButton;
	    EventServices.dispatchEvent(newEvt);

	    // Click & DoubleClick : Send Event
	    if (buttonDoubleClickStatus[iButton]) {
	    	newEvt = new MouseDoubleClickEvent(parameters);
	        newEvt.position = mouse.getPosition();
	        newEvt.button = iButton;
	        EventServices.dispatchEvent(newEvt);

	        buttonDoubleClickStatus[iButton] = false;
	    }
	    else if (buttonClickDate[iButton] !== undefined) {
	    	newEvt = new MouseClickEvent(parameters);
	        newEvt.position = mouse.getPosition();
	        newEvt.button = iButton;
	        EventServices.dispatchEvent(newEvt);
	    }
	};

	Devices.sendMouseWheelEvent = function (iWheelDeltaValue) {
		var parameters = {};
		parameters.position = mouse.getPosition();
		parameters.wheelDeltaValue = iWheelDeltaValue;
		var newEvt = new MouseWheelEvent(parameters);
	    newEvt.position = mouse.getPosition();
	    newEvt.wheelDeltaValue = iWheelDeltaValue;
	    EventServices.dispatchEvent(newEvt);
	};

	Devices.sendTouchEnableEvent = function () {
		var parameters = {};
		var newEvt = new TouchEnableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendTouchDisableEvent = function () {
		var parameters = {};
		var newEvt = new TouchDisableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendMultiTouchEvent = function (iEventTypeList, iIdList, iPositionList) {
		var positions = iPositionList.map(function (iPosition) {
			var position = new Vector2D();
			position.x = iPosition.x;
			position.y = iPosition.y;
			return position;
		});
		var parameters = {};
		parameters.eventTypes = iEventTypeList;
		parameters.ids = iIdList;
		parameters.positions = positions;
		var newEvt = new MultiTouchEvent(parameters);
		newEvt.eventTypes = iEventTypeList;
		newEvt.ids = iIdList;
		newEvt.positions = positions;

		for (var te = 0; te < newEvt.touchEventList.length; te++) {
			EventServices.dispatchEvent(newEvt.touchEventList[te]);
		}

		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureEnableEvent = function () {
		var parameters = {};
		var newEvt = new GestureEnableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureDisableEvent = function () {
		var parameters = {};
		var newEvt = new GestureDisableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureTapEvent = function (iElapsedTime, iPosition) {
		var position = new Vector2D();
		position.x = iPosition.x;
		position.y = iPosition.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.position = position;
		var newEvt = new GestureTapEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.position = position;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureDoubleTapEvent = function (iElapsedTime, iPosition) {
		var position = new Vector2D();
		position.x = iPosition.x;
		position.y = iPosition.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.position = position;
		var newEvt = new GestureDoubleTapEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.position = position;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureDragEvent = function (iElapsedTime, iPosition, iDeltaPosition, iDirectionFromOrigin) {
		var position = new Vector2D();
		position.x = iPosition.x;
		position.y = iPosition.y;
		var deltaPosition = new Vector2D();
		deltaPosition.x = iDeltaPosition.x;
		deltaPosition.y = iDeltaPosition.y;
		var directionFromOrigin = new Vector2D();
		directionFromOrigin.x = iDirectionFromOrigin.x;
		directionFromOrigin.y = iDirectionFromOrigin.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.position = position;
		parameters.deltaPosition = deltaPosition;
		parameters.directionFromOrigin = directionFromOrigin;
		var newEvt = new GestureDragEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.position = position;
		newEvt.deltaPosition = deltaPosition;
		newEvt.directionFromOrigin = directionFromOrigin;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureHoldEvent = function (iElapsedTime, iPosition) {
		var position = new Vector2D();
		position.x = iPosition.x;
		position.y = iPosition.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.position = position;
		var newEvt = new GestureHoldEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.position = position;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureSwipeEvent = function (iDirection, iDuration) {
		var direction = new Vector2D();
		direction.x = iDirection.x;
		direction.y = iDirection.y;
		var parameters = {};
		parameters.direction = direction;
		parameters.duration = iDuration;
		var newEvt = new GestureSwipeEvent(parameters);
		newEvt.direction = direction;
		newEvt.duration = iDuration;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGesturePanEvent = function (iElapsedTime, iDeltaPosition, iFirstPosition, iSecondPosition, iDirectionFromOrigin) {
		var deltaPosition = new Vector2D();
		deltaPosition.x = iDeltaPosition.x;
		deltaPosition.y = iDeltaPosition.y;
		var firstPosition = new Vector2D();
		firstPosition.x = iFirstPosition.x;
		firstPosition.y = iFirstPosition.y;
		var secondPosition = new Vector2D();
		secondPosition.x = iSecondPosition.x;
		secondPosition.y = iSecondPosition.y;
		var directionFromOrigin = new Vector2D();
		directionFromOrigin.x = iDirectionFromOrigin.x;
		directionFromOrigin.y = iDirectionFromOrigin.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.deltaPosition = deltaPosition;
		parameters.firstPosition = firstPosition;
		parameters.secondPosition = secondPosition;
		parameters.directionFromOrigin = directionFromOrigin;
		var newEvt = new GesturePanEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.deltaPosition = deltaPosition;
		newEvt.firstPosition = firstPosition;
		newEvt.secondPosition = secondPosition;
		newEvt.directionFromOrigin = directionFromOrigin;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGesturePinchEvent = function (iElapsedTime, iFirstPosition, iSecondPosition, iDistance) {
		var firstPosition = new Vector2D();
		firstPosition.x = iFirstPosition.x;
		firstPosition.y = iFirstPosition.y;
		var secondPosition = new Vector2D();
		secondPosition.x = iSecondPosition.x;
		secondPosition.y = iSecondPosition.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.firstPosition = firstPosition;
		parameters.secondPosition = secondPosition;
		parameters.distance = iDistance;
		var newEvt = new GesturePinchEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.firstPosition = firstPosition;
		newEvt.secondPosition = secondPosition;
		newEvt.distance = iDistance;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGestureRotateEvent = function (iElapsedTime, iFirstPosition, iSecondPosition, iOriginVector, iLastVector, iVector) {
		var firstPosition = new Vector2D();
		firstPosition.x = iFirstPosition.x;
		firstPosition.y = iFirstPosition.y;
		var secondPosition = new Vector2D();
		secondPosition.x = iSecondPosition.x;
		secondPosition.y = iSecondPosition.y;
		var originVector = new Vector2D();
		originVector.x = iOriginVector.x;
		originVector.y = iOriginVector.y;
		var lastVector = new Vector2D();
		lastVector.x = iLastVector.x;
		lastVector.y = iLastVector.y;
		var vector = new Vector2D();
		vector.x = iVector.x;
		vector.y = iVector.y;
		var parameters = {};
		parameters.elapsedTime = iElapsedTime;
		parameters.firstPosition = firstPosition;
		parameters.secondPosition = secondPosition;
		parameters.originVector = originVector;
		parameters.lastVector = lastVector;
		parameters.vector = vector;
		var newEvt = new GestureRotateEvent(parameters);
		newEvt.elapsedTime = iElapsedTime;
		newEvt.firstPosition = firstPosition;
		newEvt.secondPosition = secondPosition;
		newEvt.originVector = originVector;
		newEvt.lastVector = lastVector;
		newEvt.vector = vector;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendKeyboardEnableEvent = function () {
		var parameters = {};
		var newEvt = new KeyboardEnableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendKeyboardDisableEvent = function () {
		var parameters = {};
		var newEvt = new KeyboardDisableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendKeyboardPressEvent = function (iKey, iModifier/*, iRepeat*/) {
		var parameters = {};
		parameters.key = iKey;
		parameters.modifier = iModifier;
		parameters.repeat = keyboard.keysPressed.indexOf(iKey) !== -1;
	    var newEvt = new KeyboardPressEvent(parameters);
	    newEvt.key = iKey;
	    newEvt.modifier = iModifier;
	    newEvt.repeat = keyboard.keysPressed.indexOf(iKey) !== -1;
	    EventServices.dispatchEvent(newEvt);
	};

	Devices.sendKeyboardReleaseEvent = function (iKey, iModifier) {
		var parameters = {};
		parameters.key = iKey;
		parameters.modifier = iModifier;
		var newEvt = new KeyboardReleaseEvent(parameters);
	    newEvt.key = iKey;
	    newEvt.modifier = iModifier;
	    EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGamepadEnableEvent = function () {
		var parameters = {};
		var newEvt = new GamepadEnableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGamepadDisableEvent = function () {
		var parameters = {};
		var newEvt = new GamepadDisableEvent(parameters);
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGamepadPressEvent = function (iButton) {
		var parameters = {};
		parameters.button = iButton;
		var newEvt = new GamepadPressEvent(parameters);
		newEvt.button = iButton;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGamepadReleaseEvent = function (iButton) {
		var parameters = {};
		parameters.button = iButton;
		var newEvt = new GamepadReleaseEvent(parameters);
		newEvt.button = iButton;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendGamepadAxisEvent = function (iAxisValue, iAxis) {
		var parameters = {};
		parameters.axisValue = iAxisValue;
		parameters.axis = iAxis;
		var newEvt = new GamepadAxisEvent(parameters);
		newEvt.axisValue = iAxisValue;
		newEvt.axis = iAxis;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDeviceEnableEvent = function (iIndex, iButtonNames, iAxisNames, iTrackerNames) {
		var parameters = {};
		parameters.index = iIndex;
		parameters.buttonNames = iButtonNames;
		parameters.axisNames = iAxisNames;
		parameters.trackerNames = iTrackerNames;
		var newEvt = new DeviceEnableEvent(parameters);
		newEvt.index = iIndex;
		newEvt.buttonNames = iButtonNames;
		newEvt.axisNames = iAxisNames;
		newEvt.trackerNames = iTrackerNames;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDeviceDisableEvent = function (iIndex) {
		var parameters = {};
		parameters.index = iIndex;
		var newEvt = new DeviceDisableEvent(parameters);
		newEvt.index = iIndex;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDevicePressEvent = function (iIndex, iButton, iButtonName) {
		var parameters = {};
		parameters.index = iIndex;
		parameters.button = iButton;
		parameters.buttonName = iButtonName;
		var newEvt = new DevicePressEvent(parameters);
		newEvt.index = iIndex;
		newEvt.button = iButton;
		newEvt.buttonName = iButtonName;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDeviceReleaseEvent = function (iIndex, iButton, iButtonName) {
		var parameters = {};
		parameters.index = iIndex;
		parameters.button = iButton;
		parameters.buttonName = iButtonName;
		var newEvt = new DeviceReleaseEvent(parameters);
		newEvt.index = iIndex;
		newEvt.button = iButton;
		newEvt.buttonName = iButtonName;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDeviceAxisEvent = function (iIndex, iAxisValue, iAxis, iAxisName) {
		var parameters = {};
		parameters.index = iIndex;
		parameters.axisValue = iAxisValue;
		parameters.axis = iAxis;
		parameters.axisName = iAxisName;
		var newEvt = new DeviceAxisEvent(parameters);
		newEvt.index = iIndex;
		newEvt.axisValue = iAxisValue;
		newEvt.axis = iAxis;
		newEvt.axisName = iAxisName;
		EventServices.dispatchEvent(newEvt);
	};

	Devices.sendDeviceTrackerEvent = function (iIndex, iTrackerValue, iTracker, iTrackerName) {
		var parameters = {};
		parameters.index = iIndex;
		parameters.trackerValue = iTrackerValue;
		parameters.tracker = iTracker;
		parameters.trackerName = iTrackerName;
		var newEvt = new DeviceTrackerEvent(parameters);
		newEvt.index = iIndex;
		newEvt.trackerValue = iTrackerValue;
		newEvt.tracker = iTracker;
		newEvt.trackerName = iTrackerName;
		EventServices.dispatchEvent(newEvt);
	};

	// Expose in EP namespace.
	EP.Devices = Devices;

	return Devices;
});
