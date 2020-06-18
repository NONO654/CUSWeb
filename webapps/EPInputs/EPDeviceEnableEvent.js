define('DS/EPInputs/EPDeviceEnableEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPDevice', 'DS/EPInputs/EPDeviceEvent'], function (EP, EventServices, Device, DeviceEvent) {
    'use strict';

    /**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the device becomes enabled.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceEnableEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceEnableEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceEnableEvent = function (iDeviceEnableEvent) {
	 *	// user enabled the device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceEnableEvent, objectListener, 'onDeviceEnableEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceEnableEvent, objectListener, 'onDeviceEnableEvent');
	 */
    var DeviceEnableEvent = function (iParameters) {

    	DeviceEvent.call(this, iParameters);

    	this.device = new Device(iParameters.index, iParameters.buttonNames, iParameters.axisNames, iParameters.trackerNames);
    };

    DeviceEnableEvent.prototype = Object.create(DeviceEvent.prototype);
    DeviceEnableEvent.prototype.constructor = DeviceEnableEvent;
    DeviceEnableEvent.prototype.type = 'DeviceEnableEvent';

    EventServices.registerEvent(DeviceEnableEvent);

    // Expose in EP namespace.
    EP.DeviceEnableEvent = DeviceEnableEvent;

    return DeviceEnableEvent;
});
