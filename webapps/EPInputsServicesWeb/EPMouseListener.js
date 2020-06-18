define('DS/EPInputsServicesWeb/EPMouseListener', ['DS/EP/EP'], function (EP) {
	'use strict';

	/**
	 *
	 *
	 * @constructor
	 * @alias EP.MouseListener
	 * @private
	 * @param {EP.InputsServices} iInputsServices
	 */
	var MouseListener = function (iInputsServices) {
		this.inputsServices = iInputsServices;
		this.registered = false;
		this.element = undefined;
	};

	MouseListener.prototype.constructor = MouseListener;

	/**
	 *
	 *
	 * @private
	 * @param {Element} iElement
	 * @return {boolean} true: success, false: failure
	 * @see EP.MouseListener#unRegister
	 */
	MouseListener.prototype.register = function (iElement) {
		var result = false;

		if (!this.registered) {
			this.element = iElement;

			this.windowResizeCb = this.onWindowResize.bind(this);
			this.mouseMoveCb = this.onMouseMove.bind(this);
			this.mousePressCb = this.onMousePress.bind(this);
			this.mouseReleaseCb = this.onMouseRelease.bind(this);
			this.mouseWheelCb = this.onMouseWheel.bind(this);

			this.element.addEventListener('resize', this.windowResizeCb, false);
			this.element.addEventListener('mousemove', this.mouseMoveCb, false);
			this.element.addEventListener('mousedown', this.mousePressCb, false);
			this.element.addEventListener('mouseup', this.mouseReleaseCb, false);
			this.element.addEventListener('mousewheel', this.mouseWheelCb, false);

			this.onWindowResize();

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
	 * @see EP.MouseListener#register
	 */
	MouseListener.prototype.unRegister = function () {
		var result = false;

		if (this.registered) {
			this.element.removeEventListener('resize', this.windowResizeCb, false);
			this.element.removeEventListener('mousemove', this.mouseMoveCb, false);
			this.element.removeEventListener('mousedown', this.mousePressCb, false);
			this.element.removeEventListener('mouseup', this.mouseReleaseCb, false);
			this.element.removeEventListener('mousewheel', this.mouseWheelCb, false);

			delete this.windowResizeCb;
			delete this.mouseMoveCb;
			delete this.mousePressCb;
			delete this.mouseReleaseCb;
			delete this.mouseWheelCb;

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
	 * @param {Event} iEvent
	 */
	MouseListener.prototype.onWindowResize = function () {
		var viewerSize = {};
		viewerSize.x = this.element.clientWidth;
		viewerSize.y = this.element.clientHeight;

		this.inputsServices.onWindowResize(viewerSize);
	};

	/**
	 *
	 *
	 * @private
	 * @param {MouseEvent} iMouseEvent
	 */
	MouseListener.prototype.onMouseMove = function (iMouseEvent) {
	    var mousePosition = {};
	    mousePosition.x = iMouseEvent.clientX - iMouseEvent.target.offsetLeft;
	    mousePosition.y = iMouseEvent.clientY - iMouseEvent.target.offsetTop;

	    this.inputsServices.onMouseMove(mousePosition);
	};

	/**
	 *
	 *
	 * @private
	 * @param {MouseEvent} iMouseEvent
	 */
	MouseListener.prototype.onMousePress = function (iMouseEvent) {
	    this.inputsServices.onMousePress(iMouseEvent.button);
	};

	/**
	 *
	 *
	 * @private
	 * @param {MouseEvent} iMouseEvent
	 */
	MouseListener.prototype.onMouseRelease = function (iMouseEvent) {
	    this.inputsServices.onMouseRelease(iMouseEvent.button);
	};

	/**
	 *
	 *
	 * @private
	 * @param {MouseEvent} iMouseEvent
	 */
	MouseListener.prototype.onMouseWheel = function (iMouseEvent) {
	    this.inputsServices.onMouseWheel(iMouseEvent.wheelDelta / 120.0);
	};

	// Expose in EP namespace.
	EP.MouseListener = MouseListener;

	return MouseListener;
});
