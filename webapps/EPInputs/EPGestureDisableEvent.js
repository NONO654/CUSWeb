define('DS/EPInputs/EPGestureDisableEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent'
], function (EP, EventServices, GestureEvent) {
    'use strict';

    var GestureDisableEvent = function (iParameters) {

    	GestureEvent.call(this, iParameters);
    };

    GestureDisableEvent.prototype = Object.create(GestureEvent.prototype);
    GestureDisableEvent.prototype.constructor = GestureDisableEvent;
    GestureDisableEvent.prototype.type = 'GestureDisableEvent';

    EventServices.registerEvent(GestureDisableEvent);

    // Expose in EP namespace.
    EP.GestureDisableEvent = GestureDisableEvent;

    return GestureDisableEvent;
});
