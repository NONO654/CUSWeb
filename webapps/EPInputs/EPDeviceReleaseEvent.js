define('DS/EPInputs/EPDeviceReleaseEvent', ['DS/EP/EP', 'DS/EPEventServices/EPEventServices', 'DS/EPInputs/EPDeviceEvent'], function (EP, EventServices, DeviceEvent) {
	'use strict';

	/**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the user release a device button.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceReleaseEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceReleaseEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
     * @example
	 * var objectListener = {};
	 * objectListener.onDeviceReleaseEvent = function (iDeviceReleaseEvent) {
	 *	// a key has been pressed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceReleaseEvent, objectListener, 'onDeviceReleaseEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceReleaseEvent, objectListener, 'onDeviceReleaseEvent');
	 */
	var DeviceReleaseEvent = function (iParameters) {

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

	DeviceReleaseEvent.prototype = Object.create(DeviceEvent.prototype);
	DeviceReleaseEvent.prototype.constructor = DeviceReleaseEvent;
	DeviceReleaseEvent.prototype.type = 'DeviceReleaseEvent';

	/**
	 * Return the Device Button ID.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceReleaseEvent = function (iDeviceReleaseEvent) {
	 *	if(iDeviceReleaseEvent.getButton() === 1) {
	 *		// button 1 has been released
	 *	}
	 * };
	 */
	DeviceReleaseEvent.prototype.getButton = function () {
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
	DeviceReleaseEvent.prototype.getButtonName = function () {
		return this.buttonName;
	};

	EventServices.registerEvent(DeviceReleaseEvent);

	// Expose in EP namespace.
	EP.DeviceReleaseEvent = DeviceReleaseEvent;

	return DeviceReleaseEvent;
});
