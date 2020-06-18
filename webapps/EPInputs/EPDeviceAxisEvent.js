define('DS/EPInputs/EPDeviceAxisEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPDeviceEvent'], function (EP, EventServices, DeviceEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the user moves a device axis.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceAxisEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceAxisEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
     * @example
	 * var objectListener = {};
	 * objectListener.onDeviceAxisEvent = function (iDeviceAxisEvent) {
	 *	// an axis value has been changed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceAxisEvent, objectListener, 'onDeviceAxisEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceAxisEvent, objectListener, 'onDeviceAxisEvent');
	 */
	var DeviceAxisEvent = function (iParameters) {

		DeviceEvent.call(this, iParameters);

		/**
         * Device axis value.
         *
		 * @private
         * @type {number}
         */
	    this.axisValue = 0.0;

		/**
         * Device Axis ID.
         *
		 * @private
         * @type {number}
         */
	    this.axis = undefined;

		/**
         * Device Axis name.
         *
		 * @private
         * @type {string}
         */
	    this.axisName = undefined;

	};

	DeviceAxisEvent.prototype = Object.create(DeviceEvent.prototype);
	DeviceAxisEvent.prototype.constructor = DeviceAxisEvent;
	DeviceAxisEvent.prototype.type = 'DeviceAxisEvent';

	/**
	 * Return the Device axis value.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceAxisEvent = function (iDeviceAxisEvent) {
	 *	var deviceAxisValue = iDeviceAxisEvent.getAxisValue();
	 * };
	 */
	DeviceAxisEvent.prototype.getAxisValue = function () {
		return this.axisValue;
	};

	/**
	 * Return the Device Axis ID.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceAxisEvent = function (iDeviceAxisEvent) {
	 *	if(iDeviceAxisEvent.getAxis() === 1) {
	 *		// axis 1 value has been changed
	 *	}
	 * };
	 */
	DeviceAxisEvent.prototype.getAxis = function () {
		return this.axis;
	};

	/**
	 * Return the Device Axis name.
	 *
	 * @public
	 * @return {string}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceAxisEvent = function (iDeviceAxisEvent) {
	 *	if(iDeviceAxisEvent.getAxisName() === 'axis1') {
	 *		// axis 1 value has been changed
	 *	}
	 * };
	 */
	DeviceAxisEvent.prototype.getAxisName = function () {
		return this.axisName;
	};

	EventServices.registerEvent(DeviceAxisEvent);

	// Expose in EP namespace.
	EP.DeviceAxisEvent = DeviceAxisEvent;

	return DeviceAxisEvent;
});
