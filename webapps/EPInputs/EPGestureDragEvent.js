define('DS/EPInputs/EPGestureDragEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureDragEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.position = new Vector2D();
		this.deltaPosition = new Vector2D();
		this.directionFromOrigin = new Vector2D();
	};

	GestureDragEvent.prototype = Object.create(GestureEvent.prototype);
	GestureDragEvent.prototype.constructor = GestureDragEvent;
	GestureDragEvent.prototype.type = 'GestureDragEvent';

	GestureDragEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GestureDragEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	GestureDragEvent.prototype.getDeltaPosition = function () {
		return this.deltaPosition.clone();
	};

	GestureDragEvent.prototype.getDirectionFromOrigin = function () {
		return this.directionFromOrigin.clone();
	};

	EventServices.registerEvent(GestureDragEvent);

	// Expose in EP namespace.
	EP.GestureDragEvent = GestureDragEvent;

	return GestureDragEvent;
});
