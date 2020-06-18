define('DS/EPInputs/EPGestureTapEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureTapEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.position = new Vector2D();
	};

	GestureTapEvent.prototype = Object.create(GestureEvent.prototype);
	GestureTapEvent.prototype.constructor = GestureTapEvent;
	GestureTapEvent.prototype.type = 'GestureTapEvent';

	GestureTapEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GestureTapEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(GestureTapEvent);

	// Expose in EP namespace.
	EP.GestureTapEvent = GestureTapEvent;

	return GestureTapEvent;
});
