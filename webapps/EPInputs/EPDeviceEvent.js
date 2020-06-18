define('DS/EPInputs/EPDeviceEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPEventServices/EPEvent'], function (EP, EventServices, Event) {
	'use strict';

	/**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the user manipulates the device.</p>
	 *
	 * <p>This event has specific extensions class and there are all dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.Event
     * @example
	 * var objectListener = {};
	 * objectListener.onDeviceEvent = function (iDeviceEvent) {
	 *	// user manipulated the device
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceEvent, objectListener, 'onDeviceEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceEvent, objectListener, 'onDeviceEvent');
	 */
	var DeviceEvent = function (iParameters) {

		Event.call(this, iParameters);

		/**
         * Device
         *
		 * @private
         * @type {EP.Device}
         */
		this.device = EP.Devices.getDevice(iParameters.index);
	};

	DeviceEvent.prototype = Object.create(Event.prototype);
	DeviceEvent.prototype.constructor = DeviceEvent;
	DeviceEvent.prototype.type = 'DeviceEvent';

	/**
	 * Return the device.
	 *
	 * @public
	 * @return {EP.Device}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceEvent = function (iDeviceEvent) {
	 *	var device = iDeviceEvent.getDevice();
	 * };
	 */
	DeviceEvent.prototype.getDevice = function () {
		return this.device;
	};

	EventServices.registerEvent(DeviceEvent);

	// Expose in EP namespace.
	EP.DeviceEvent = DeviceEvent;

	return DeviceEvent;
});
