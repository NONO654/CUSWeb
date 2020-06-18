define('DS/EPInputs/EPDevicePressEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPDeviceEvent'], function (EP, EventServices, DeviceEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the user press a device button.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DevicePressEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DevicePressEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
     * @example
     * var objectListener = {};
	 * objectListener.onDevicePressEvent = function (iDevicePressEvent) {
	 *	// a button has been pressed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DevicePressEvent, objectListener, 'onDevicePressEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DevicePressEvent, objectListener, 'onDevicePressEvent');
	 */
	var DevicePressEvent = function (iParameters) {

		DeviceEvent.call(this, iParameters);

		/**
         * Device Button ID.
         *
		 * @private
         * @type {number}
         */
		this.button = undefined;

		/**
         * Device Button name.
         *
		 * @private
         * @type {string}
         */
		this.buttonName = undefined;

	};

	DevicePressEvent.prototype = Object.create(DeviceEvent.prototype);
	DevicePressEvent.prototype.constructor = DevicePressEvent;
	DevicePressEvent.prototype.type = 'DevicePressEvent';

	/**
	 * Return the Device Button ID.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDevicePressEvent = function (iDevicePressEvent) {
	 *	if(iDevicePressEvent.getButton() === 1) {
	 *		// button 1 has been pressed
	 *	}
	 * };
	 */
	DevicePressEvent.prototype.getButton = function () {
		return this.button;
	};

	/**
	 * Return the Device Button name.
	 *
	 * @public
	 * @return {string}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceReleaseEvent = function (iDeviceReleaseEvent) {
	 *	if(iDeviceReleaseEvent.getButtonName() === 'button1') {
	 *		// button 1 has been released
	 *	}
	 * };
	 */
	DevicePressEvent.prototype.getButtonName = function () {
		return this.buttonName;
	};

	EventServices.registerEvent(DevicePressEvent);

	// Expose in EP namespace.
	EP.DevicePressEvent = DevicePressEvent;

	return DevicePressEvent;
});
