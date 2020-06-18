define('DS/EPInputs/EPGesturePanEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GesturePanEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.deltaPosition = new Vector2D();
		this.firstPosition = new Vector2D();
		this.secondPosition = new Vector2D();
		this.directionFromOrigin = new Vector2D();
	};

	GesturePanEvent.prototype = Object.create(GestureEvent.prototype);
	GesturePanEvent.prototype.constructor = GesturePanEvent;
	GesturePanEvent.prototype.type = 'GesturePanEvent';

	GesturePanEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GesturePanEvent.prototype.getDeltaPosition = function () {
		return this.deltaPosition.clone();
	};

	GesturePanEvent.prototype.getFirstPosition = function () {
		return this.firstPosition.clone();
	};

	GesturePanEvent.prototype.getSecondPosition = function () {
		return this.secondPosition.clone();
	};

	GesturePanEvent.prototype.getDirectionFromOrigin = function () {
		return this.directionFromOrigin.clone();
	};

	EventServices.registerEvent(GesturePanEvent);

	// Expose in EP namespace.
	EP.GesturePanEvent = GesturePanEvent;

	return GesturePanEvent;
});
