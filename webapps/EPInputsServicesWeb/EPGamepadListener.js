define('DS/EPInputsServicesWeb/EPGamepadListener', ['DS/EP/EP'], function (EP) {
	'use strict';

    /**
	 *
	 *
	 * @constructor
	 * @alias EP.GamepadListener
	 * @private
	 * @param {EP.InputsServices} iInputsServices
	 */
	var GamepadListener = function (iInputsServices) {
		this.inputsServices = iInputsServices;
	    this.registered = false;
	};

	GamepadListener.prototype.constructor = GamepadListener;

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.GamepadListener#unRegister
	 */
	GamepadListener.prototype.register = function () {
		var result = false;

	    if (!this.registered) {
	    	this.runAnimationCb = this.runAnimation.bind(this);
	    	this.lastTimestamp = 0;
	    	this.requestId = window.requestAnimationFrame(this.runAnimationCb);

	    	this.registered = true;
	    	result = true;
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 * @return {boolean} true: success, false: failure
	 * @see EP.GamepadListener#register
	 */
	GamepadListener.prototype.unRegister = function () {
		var result = false;

	    if (this.registered) {
	    	window.cancelAnimationFrame(this.requestId);
	    	delete this.lastTimestamp;
	    	delete this.runAnimationCb;

	    	this.registered = false;
	    	result = true;
	    }

	    return result;
	};

    /**
	 *
	 *
	 * @private
	 */
	GamepadListener.prototype.runAnimation = function () {
	    this.requestId = window.requestAnimationFrame(this.runAnimationCb);

	    this.gamepads = this.gamepads || navigator.getGamepads();

	    var gamepad = this.gamepads[0];
	    delete this.gamepads;
	    if (gamepad !== undefined && gamepad !== null) {
	    	var newTimestamp = gamepad.timestamp;
	    	if (this.lastTimestamp === newTimestamp) {
	    		return;
	    	}

	    	this.lastTimestamp = newTimestamp;

	    	var buttonValues = [];
	    	var axisValues = [];

			/*
	    	var buttonCount = gamepad.buttons.length;
	    	var axisCount = gamepad.axes.length;

	    	var eDPadState;

	    	// mapping "standard"
	    	// Xbox 360 Controller (XInput STANDARD GAMEPAD)
	    	if (buttonCount === 16 && axisCount === 4) {
	    		buttonValues[0] = gamepad.buttons[0].value;
	    		buttonValues[1] = gamepad.buttons[1].value;
	    		buttonValues[2] = gamepad.buttons[2].value;
	    		buttonValues[3] = gamepad.buttons[3].value;
	    		buttonValues[4] = gamepad.buttons[4].value;
	    		buttonValues[5] = gamepad.buttons[5].value;
	    		buttonValues[6] = gamepad.buttons[8].value;
	    		buttonValues[7] = gamepad.buttons[9].value;
	    		buttonValues[8] = gamepad.buttons[10].value;
	    		buttonValues[9] = gamepad.buttons[11].value;
	    		buttonValues[10] = gamepad.buttons[12].value;
	    		buttonValues[11] = gamepad.buttons[13].value;
	    		buttonValues[12] = gamepad.buttons[14].value;
	    		buttonValues[13] = gamepad.buttons[15].value;

	    		axisValues[0] = gamepad.axes[0];
	    		axisValues[1] = -gamepad.axes[1];
	    		axisValues[2] = gamepad.axes[2];
	    		axisValues[3] = -gamepad.axes[3];
	    		axisValues[4] = gamepad.buttons[6].value;
	    		axisValues[5] = gamepad.buttons[7].value;
	    	}
	    		// mapping ""
	    		// USB GAMEPAD 8116 (Vendor: 1a34 Product: 0802)
	    	else if (buttonCount === 10 && axisCount === 10) {
	    		buttonValues[0] = gamepad.buttons[0].value;
	    		buttonValues[1] = gamepad.buttons[1].value;
	    		buttonValues[2] = gamepad.buttons[2].value;
	    		buttonValues[3] = gamepad.buttons[3].value;
	    		buttonValues[4] = gamepad.buttons[4].value;
	    		buttonValues[5] = gamepad.buttons[5].value;
	    		buttonValues[6] = gamepad.buttons[6].value;
	    		buttonValues[7] = gamepad.buttons[7].value;
	    		buttonValues[8] = gamepad.buttons[8].value;
	    		buttonValues[9] = gamepad.buttons[9].value;
	    		// 0: Up, 1: Up/Right, 2: Right, 3: Right/Down, 4: Down, 5: Down/Left, 6: Left, 7: Left/Up
	    		eDPadState = Math.round((gamepad.axes[9] + 1) * 7 / 2);
	    		buttonValues[10] = (eDPadState === 7 || eDPadState === 0 || eDPadState === 1) ? 1 : 0;
	    		buttonValues[11] = (eDPadState === 3 || eDPadState === 4 || eDPadState === 5) ? 1 : 0;
	    		buttonValues[12] = (eDPadState === 5 || eDPadState === 6 || eDPadState === 7) ? 1 : 0;
	    		buttonValues[13] = (eDPadState === 1 || eDPadState === 2 || eDPadState === 3) ? 1 : 0;

	    		axisValues[0] = gamepad.axes[0];
	    		axisValues[1] = -gamepad.axes[1];
	    		axisValues[2] = gamepad.axes[2];
	    		axisValues[3] = -gamepad.axes[5];
	    		var eTriggerAxisValue = gamepad.axes[6];
	    		axisValues[4] = (eTriggerAxisValue <= 0.0) ? -eTriggerAxisValue : 0.0;
	    		axisValues[5] = (eTriggerAxisValue >= 0.0) ? eTriggerAxisValue : 0.0;
	    	}
	    		// mapping ""
	    		// Logitech RumblePad 2 USB (Vendor: 046d Product: c218)
	    		// Generic   USB  Joystick   (Vendor: 0079 Product: 0006)
	    	else if (buttonCount === 12 && axisCount === 10) {
	    		buttonValues[0] = gamepad.buttons[0].value;
	    		buttonValues[1] = gamepad.buttons[1].value;
	    		buttonValues[2] = gamepad.buttons[2].value;
	    		buttonValues[3] = gamepad.buttons[3].value;
	    		buttonValues[4] = gamepad.buttons[4].value;
	    		buttonValues[5] = gamepad.buttons[5].value;
	    		buttonValues[6] = gamepad.buttons[8].value;
	    		buttonValues[7] = gamepad.buttons[9].value;
	    		buttonValues[8] = gamepad.buttons[10].value;
	    		buttonValues[9] = gamepad.buttons[11].value;
	    		// 0: Up, 1: Up/Right, 2: Right, 3: Right/Down, 4: Down, 5: Down/Left, 6: Left, 7: Left/Up
	    		eDPadState = Math.round((gamepad.axes[9] + 1) * 7 / 2);
	    		buttonValues[10] = (eDPadState === 7 || eDPadState === 0 || eDPadState === 1) ? 1 : 0;
	    		buttonValues[11] = (eDPadState === 3 || eDPadState === 4 || eDPadState === 5) ? 1 : 0;
	    		buttonValues[12] = (eDPadState === 5 || eDPadState === 6 || eDPadState === 7) ? 1 : 0;
	    		buttonValues[13] = (eDPadState === 1 || eDPadState === 2 || eDPadState === 3) ? 1 : 0;

	    		axisValues[0] = gamepad.axes[0];
	    		axisValues[1] = -gamepad.axes[1];
	    		axisValues[2] = gamepad.axes[2];
	    		axisValues[3] = -gamepad.axes[5];
	    		axisValues[4] = gamepad.buttons[6].value;
	    		axisValues[5] = gamepad.buttons[7].value;
	    	}
			*/

			if (gamepad.mapping === 'standard') {
				buttonValues[0] = gamepad.buttons[0].value;
	    		buttonValues[1] = gamepad.buttons[1].value;
	    		buttonValues[2] = gamepad.buttons[2].value;
	    		buttonValues[3] = gamepad.buttons[3].value;
	    		buttonValues[4] = gamepad.buttons[4].value;
	    		buttonValues[5] = gamepad.buttons[5].value;
	    		buttonValues[6] = gamepad.buttons[8].value;
	    		buttonValues[7] = gamepad.buttons[9].value;
	    		buttonValues[8] = gamepad.buttons[10].value;
	    		buttonValues[9] = gamepad.buttons[11].value;
	    		buttonValues[10] = gamepad.buttons[12].value;
	    		buttonValues[11] = gamepad.buttons[13].value;
	    		buttonValues[12] = gamepad.buttons[14].value;
	    		buttonValues[13] = gamepad.buttons[15].value;

	    		axisValues[0] = gamepad.axes[0];
	    		axisValues[1] = -gamepad.axes[1];
	    		axisValues[2] = gamepad.axes[2];
	    		axisValues[3] = -gamepad.axes[3];
	    		axisValues[4] = gamepad.buttons[6].value;
	    		axisValues[5] = gamepad.buttons[7].value;

				this.inputsServices.onGamepad(buttonValues, axisValues);
			}
	    }
	};

	// Expose in EP namespace.
	EP.GamepadListener = GamepadListener;

	return GamepadListener;
});
