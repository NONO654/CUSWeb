define('DS/EPInputs/EPDeviceTrackerEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPDeviceEvent',
	'MathematicsES/TransformationJSImpl'
], function (EP, EventServices, DeviceEvent, Transformation) {
	'use strict';

	/**
	 * <p>Describe an event generated from a device.</br>
	 * It contains information about the device.</br>
	 * It occurs when the user moves a device tracker.</p>
	 *
	 * <p>This event is dispatched globally on the EP.EventServices.</br>
	 * In order to get notified, you need to add a listener as EP.DeviceTrackerEvent type on the EP.EventServices.</p>
	 *
	 * @constructor
	 * @alias EP.DeviceTrackerEvent
	 * @noinstancector
	 * @public
	 * @param {Object} iParameters
	 * @extends EP.DeviceEvent
     * @example
	 * var objectListener = {};
	 * objectListener.onDeviceTrackerEvent = function (iDeviceTrackerEvent) {
	 *	// an axis value has been changed
	 * };
	 * // Add Listener to get notified
	 * EP.EventServices.addObjectListener(EP.DeviceTrackerEvent, objectListener, 'onDeviceTrackerEvent');
	 * // Remove Listener when you don't need it anymore
	 * EP.EventServices.removeObjectListener(EP.DeviceTrackerEvent, objectListener, 'onDeviceTrackerEvent');
	 */
	var DeviceTrackerEvent = function (iParameters) {

		DeviceEvent.call(this, iParameters);

		/**
         * Device tracker value.
         *
		 * @private
         * @type {Array.<number>}
         */
		this.trackerValue = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0];

		/**
         * Device tracker ID.
         *
		 * @private
         * @type {number}
         */
		this.tracker = undefined;

		/**
         * Device tracker name.
         *
		 * @private
         * @type {string}
         */
		this.trackerName = undefined;

	};

	DeviceTrackerEvent.prototype = Object.create(DeviceEvent.prototype);
	DeviceTrackerEvent.prototype.constructor = DeviceTrackerEvent;
	DeviceTrackerEvent.prototype.type = 'DeviceTrackerEvent';

	/**
	 * Return the device tracker value.
	 *
	 * @public
	 * @return {DSMath.Transformation}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceTrackerEvent = function (iDeviceTrackerEvent) {
	 *	var deviceTrackerValue = iDeviceTrackerEvent.getTrackerValue();
	 * };
	 */
	DeviceTrackerEvent.prototype.getTrackerValue = function () {
		var trackerValue = new Transformation();
		trackerValue.setFromArray(this.trackerValue);
		return trackerValue;
	};

	/**
	 * Return the device tracker ID.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceTrackerEvent = function (iDeviceTrackerEvent) {
	 *	if(iDeviceTrackerEvent.getTracker() === 1) {
	 *		// tracker 1 value has been changed
	 *	}
	 * };
	 */
	DeviceTrackerEvent.prototype.getTracker = function () {
		return this.tracker;
	};

	/**
	 * Return the device tracker name.
	 *
	 * @public
	 * @return {string}
	 * @example
	 * var objectListener = {};
	 * objectListener.onDeviceTrackerEvent = function (iDeviceTrackerEvent) {
	 *	if(iDeviceTrackerEvent.getTrackerName() === 'tracker1') {
	 *		// tracker 1 value has been changed
	 *	}
	 * };
	 */
	DeviceTrackerEvent.prototype.getTrackerName = function () {
		return this.trackerName;
	};

	EventServices.registerEvent(DeviceTrackerEvent);

	// Expose in EP namespace.
	EP.DeviceTrackerEvent = DeviceTrackerEvent;

	return DeviceTrackerEvent;
});
