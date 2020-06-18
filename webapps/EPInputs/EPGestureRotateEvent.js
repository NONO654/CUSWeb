define('DS/EPInputs/EPGestureRotateEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureRotateEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.firstPosition = new Vector2D();
		this.secondPosition = new Vector2D();
		this.originVector = new Vector2D();
		this.lastVector = new Vector2D();
		this.vector = new Vector2D();
	};

	GestureRotateEvent.prototype = Object.create(GestureEvent.prototype);
	GestureRotateEvent.prototype.constructor = GestureRotateEvent;
	GestureRotateEvent.prototype.type = 'GestureRotateEvent';

	GestureRotateEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GestureRotateEvent.prototype.getFirstPosition = function () {
		return this.firstPosition.clone();
	};

	GestureRotateEvent.prototype.getSecondPosition = function () {
		return this.secondPosition.clone();
	};

	GestureRotateEvent.prototype.getOriginVector = function () {
		return this.originVector.clone();
	};

	GestureRotateEvent.prototype.getLastVector = function () {
		return this.lastVector.clone();
	};

	GestureRotateEvent.prototype.getVector = function () {
		return this.vector.clone();
	};

	EventServices.registerEvent(GestureRotateEvent);

	// Expose in EP namespace.
	EP.GestureRotateEvent = GestureRotateEvent;

	return GestureRotateEvent;
});
