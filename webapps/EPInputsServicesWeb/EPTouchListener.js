define('DS/EPInputsServicesWeb/EPTouchListener', [
	'DS/EP/EP',
	'DS/EPInputs/EPTouchMoveEvent',
	'DS/EPInputs/EPTouchIdleEvent',
	'DS/EPInputs/EPTouchPressEvent',
	'DS/EPInputs/EPTouchReleaseEvent'
], function (EP, TouchMoveEvent, TouchIdleEvent, TouchPressEvent, TouchReleaseEvent) {
	'use strict';

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.TouchListener
	 * @private
	 * @param {EP.InputsServices} iInputsServices
	 */
	var TouchListener = function (iInputsServices) {
		this.inputsServices = iInputsServices;
		this.registered = false;
		this.element = undefined;
	};

	TouchListener.prototype.constructor = TouchListener;

	/**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.TouchListener#unRegister
	 */
	TouchListener.prototype.register = function (iElement) {
		var result = false;

		if (!this.registered) {
			this.element = iElement;

			this.touchStartCb = this.onTouchStart.bind(this);
			this.touchEndCb = this.onTouchEnd.bind(this);
			this.touchCancelCb = this.onTouchCancel.bind(this);
			this.touchMoveCb = this.onTouchMove.bind(this);

			this.element.addEventListener('touchstart', this.touchStartCb, false);
			this.element.addEventListener('touchend', this.touchEndCb, false);
			this.element.addEventListener('touchcancel', this.touchCancelCb, false);
			this.element.addEventListener('touchmove', this.touchMoveCb, false);

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
	 * @see EP.TouchListener#register
	 */
	TouchListener.prototype.unRegister = function () {
		var result = false;

		if (this.registered) {
			this.element.removeEventListener('touchstart', this.touchStartCb, false);
			this.element.removeEventListener('touchend', this.touchEndCb, false);
			this.element.removeEventListener('touchcancel', this.touchCancelCb, false);
			this.element.removeEventListener('touchmove', this.touchMoveCb, false);

			delete this.touchStartCb;
			delete this.touchEndCb;
			delete this.touchCancelCb;
			delete this.touchMoveCb;

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
	 * @param {TouchEvent} iTouchEvent
	 */
	TouchListener.prototype.onTouchStart = function (iTouchEvent) {
		var eventTypeList = [];
		var idList = [];
		var positionList = [];

		var touch;
		var t;
		for (t = 0; t < iTouchEvent.targetTouches.length; t++) {
			touch = iTouchEvent.targetTouches[t];
			eventTypeList.push(TouchIdleEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		var index;
		for (t = 0; t < iTouchEvent.changedTouches.length; t++) {
			touch = iTouchEvent.changedTouches[t];
			index = idList.indexOf(touch.identifier);
			eventTypeList[index] = TouchPressEvent.prototype.type;
		}

		this.inputsServices.onMultiTouch(eventTypeList, idList, positionList);
	};

	/**
	 *
	 *
	 * @private
	 * @param {TouchEvent} iTouchEvent
	 */
	TouchListener.prototype.onTouchEnd = function (iTouchEvent) {
		var eventTypeList = [];
		var idList = [];
		var positionList = [];

		var touch;
		var t;
		for (t = 0; t < iTouchEvent.targetTouches.length; t++) {
			touch = iTouchEvent.targetTouches[t];
			eventTypeList.push(TouchIdleEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		for (t = 0; t < iTouchEvent.changedTouches.length; t++) {
			touch = iTouchEvent.changedTouches[t];
			eventTypeList.push(TouchReleaseEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		this.inputsServices.onMultiTouch(eventTypeList, idList, positionList);
	};

	/**
	 *
	 *
	 * @private
	 * @param {TouchEvent} iTouchEvent
	 */
	TouchListener.prototype.onTouchCancel = function (iTouchEvent) {
		var eventTypeList = [];
		var idList = [];
		var positionList = [];

		var touch;
		var t;
		for (t = 0; t < iTouchEvent.targetTouches.length; t++) {
			touch = iTouchEvent.targetTouches[t];
			eventTypeList.push(TouchIdleEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		for (t = 0; t < iTouchEvent.changedTouches.length; t++) {
			touch = iTouchEvent.changedTouches[t];
			eventTypeList.push(TouchReleaseEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		this.inputsServices.onMultiTouch(eventTypeList, idList, positionList);
	};

	/**
	 *
	 *
	 * @private
	 * @param {TouchEvent} iTouchEvent
	 */
	TouchListener.prototype.onTouchMove = function (iTouchEvent) {
		var eventTypeList = [];
		var idList = [];
		var positionList = [];

		var touch;
		var t;
		for (t = 0; t < iTouchEvent.targetTouches.length; t++) {
			touch = iTouchEvent.targetTouches[t];
			eventTypeList.push(TouchIdleEvent.prototype.type);
			idList.push(touch.identifier);
			positionList.push({ x: touch.clientX - touch.target.offsetLeft, y: touch.clientY - touch.target.offsetTop });
		}

		var index;
		for (t = 0; t < iTouchEvent.changedTouches.length; t++) {
			touch = iTouchEvent.changedTouches[t];
			index = idList.indexOf(touch.identifier);
			eventTypeList[index] = TouchMoveEvent.prototype.type;
		}

		this.inputsServices.onMultiTouch(eventTypeList, idList, positionList);
	};

	// Expose in EP namespace.
	EP.TouchListener = TouchListener;

	return TouchListener;
});
