define('DS/EPInputs/EPDeviceDisableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPDeviceEvent'], function (EP, EventServices, DeviceEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the device becomes disabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceDisableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceDisableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceDisableEvent = function (iDeviceDisableEvent) {
	 *	// user disabled the gamepad
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceDisableEvent, objectListener, 'onDeviceDisableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceDisableEvent, objectListener, 'onDeviceDisableEvent');
	 */
    var DeviceDisableEvent = function (iParameters) {

    	DeviceEvent.call(this, iParameters);
    };

    DeviceDisableEvent.prototype = Object.create(DeviceEvent.prototype);
    DeviceDisableEvent.prototype.constructor = DeviceDisableEvent;
    DeviceDisableEvent.prototype.type = 'DeviceDisableEvent';

    EventServices.registerEvent(DeviceDisableEvent);

    // Expose in EP namespace.
    EP.DeviceDisableEvent = DeviceDisableEvent;

    return DeviceDisableEvent;
});
