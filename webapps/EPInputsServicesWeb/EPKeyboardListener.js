define('DS/EPInputsServicesWeb/EPKeyboardListener', ['DS/EP/EP', 'DS/EPInputs/EPKeyboard'], function (EP, Keyboard) {
	'use strict';

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.KeyboardListener
	 * @private
	 * @param {EP.InputsServices} iInputsServices
	 */
	var KeyboardListener = function (iInputsServices) {
		this.inputsServices = iInputsServices;
		this.registered = false;
		this.element = undefined;
	};

	KeyboardListener.prototype.constructor = KeyboardListener;

	/**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.KeyboardListener#unRegister
	 */
	KeyboardListener.prototype.register = function (iElement) {
		var result = false;

		if (!this.registered) {
			this.element = iElement;

			this.keyboardPressCb = this.onKeyboardPress.bind(this);
			this.keyboardReleaseCb = this.onKeyboardRelease.bind(this);

			this.element.addEventListener('keydown', this.keyboardPressCb, false);
			this.element.addEventListener('keyup', this.keyboardReleaseCb, false);

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
	 * @see EP.KeyboardListener#register
	 */
	KeyboardListener.prototype.unRegister = function () {
		var result = false;

		if (this.registered) {
			this.element.removeEventListener('keydown', this.keyboardPressCb, false);
			this.element.removeEventListener('keyup', this.keyboardReleaseCb, false);

			delete this.keyboardPressCb;
			delete this.keyboardReleaseCb;

			delete this.element;

			this.registered = false;
			result = true;
		}

		return result;
	};

	/**
	 *
	 *
	 * @private
	 * @param {KeyboardEvent} iKeyboardEvent
	 */
	KeyboardListener.prototype.onKeyboardPress = function (iKeyboardEvent) {
		if (iKeyboardEvent.keyCode === 44) {
			return;
		}

	    var modifier = Keyboard.FModifier.fNone;
	    if (iKeyboardEvent.ctrlKey) {
	        modifier |= Keyboard.FModifier.fControl;
	    }
	    if (iKeyboardEvent.shiftKey) {
	        modifier |= Keyboard.FModifier.fShift;
	    }
	    if (iKeyboardEvent.altKey) {
	        modifier |= Keyboard.FModifier.fAlt;
	    }

	    this.inputsServices.onKeyboardPress(iKeyboardEvent.keyCode, modifier, iKeyboardEvent.repeat);
	};

	/**
	 *
	 *
	 * @private
	 * @param {KeyboardEvent} iKeyboardEvent
	 */
	KeyboardListener.prototype.onKeyboardRelease = function (iKeyboardEvent) {
		if (iKeyboardEvent.keyCode === 44) {
			return;
		}

		var modifier = Keyboard.FModifier.fNone;
		if (iKeyboardEvent.ctrlKey) {
			modifier |= Keyboard.FModifier.fControl;
		}
		if (iKeyboardEvent.shiftKey) {
			modifier |= Keyboard.FModifier.fShift;
		}
		if (iKeyboardEvent.altKey) {
			modifier |= Keyboard.FModifier.fAlt;
		}

	    this.inputsServices.onKeyboardRelease(iKeyboardEvent.keyCode, modifier);
	};

	// Expose in EP namespace.
	EP.KeyboardListener = KeyboardListener;

	return KeyboardListener;
});
