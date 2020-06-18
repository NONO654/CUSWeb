define('DS/EPInputs/EPDevice', ['DS/EP/EP', 'MathematicsES/TransformationJSImpl'], function (EP, Transformation) {
	'use strict';

	/**
	 * Describe an object representing a device.</br>
	 * It contains the state of the device.
	 *
	 * @constructor
	 * @alias EP.Device
	 * @noinstancector
	 * @public
	 * @param {number} [iIndex]
	 * @param {Array.<string>} [iButtonNames]
	 * @param {Array.<string>} [iAxisNames]
	 * @param {Array.<string>} [iTrackerNames]
     * @example
	 * var device = EP.Devices.getDevice();
	 */
	var Device = function (iIndex, iButtonNames, iAxisNames, iTrackerNames) {

		/**
         * Device index.
         *
		 * @private
         * @type {number}
		 * @see EP.Device#getIndex
         */
		this.index = iIndex || 0;

		/**
         * The list of button names.
         *
		 * @private
         * @type {Array.<string>}
         */
		this.buttonNames = iButtonNames || [];

		/**
         * The list of axis names.
         *
		 * @private
         * @type {Array.<string>}
         */
		this.axisNames = iAxisNames || [];

		/**
         * The list of tracker names.
         *
		 * @private
         * @type {Array.<string>}
         */
		this.trackerNames = iTrackerNames || [];

		/**
         * The number of buttons.
         *
		 * @private
         * @type {number}
		 * @see EP.Device#getButtonCount
         */
		this.buttonCount = this.buttonNames.length || 0;

		/**
         * The number of axes.
         *
		 * @private
         * @type {number}
		 * @see EP.Device#getAxisCount
         */
		this.axisCount = this.axisNames.length || 0;

		/**
         * The number of trackers.
         *
		 * @private
         * @type {number}
		 * @see EP.Device#getTrackerCount
         */
		this.trackerCount = this.trackerNames.length || 0;

		/**
	     * Axis values.
	     *
	     * @private
	     * @type {Array.<number>}
		 * @see EP.Device#getAxisValue
	     */
		this.axisValues = [];
		for (var axis = 0; axis < this.axisCount; axis++) {
			this.axisValues[axis] = 0.0;
		}

		/**
	     * The list of buttons currently pressed.
	     *
	     * @private
	     * @type {Array.<number>}
		 * @see EP.Device#getButtonsPressed
		 * @see EP.Device#isButtonPressed
	     */
	    this.buttonsPressed = [];

		/**
	     * Tracker values.
	     *
	     * @private
	     * @type {Array.<DSMath.Transformation>}
		 * @see EP.Device#getTrackerValue
	     */
	    this.trackerValues = [];
	    for (var tracker = 0; tracker < this.trackerCount; tracker++) {
	    	this.trackerValues[tracker] = new Transformation();
	    }
	};

	Device.prototype.constructor = Device;

	/**
	 * Return the device index.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var index = device.getIndex();
	 */
	Device.prototype.getIndex = function () {
		return this.index;
	};

	/**
	 * Return the number of buttons.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var buttonCount = device.getButtonCount();
	 */
	Device.prototype.getButtonCount = function () {
		return this.buttonCount;
	};

	/**
	 * Return the number of axes.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var axisCount = device.getAxisCount();
	 */
	Device.prototype.getAxisCount = function () {
		return this.axisCount;
	};

	/**
	 * Return the number of trackers.
	 *
	 * @public
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var trackerCount = device.getTrackerCount();
	 */
	Device.prototype.getTrackerCount = function () {
		return this.trackerCount;
	};

	/**
	 * Return the axis id.
	 *
	 * @public
	 * @param {string} iDeviceAxisName
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceAxis = device.getAxis('axis1');
	 */
	Device.prototype.getAxis = function (iDeviceAxisName) {
		var axis = -1;

		if (iDeviceAxisName !== '') {
			axis = this.axisNames.indexOf(iDeviceAxisName);
		}

		return axis;
	};

	/**
	 * Return the axis name.
	 *
	 * @public
	 * @param {number} iDeviceAxis
	 * @return {string}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceAxisName = device.getAxisName(1);
	 */
	Device.prototype.getAxisName = function (iDeviceAxis) {
		return this.axisNames[iDeviceAxis];
	};

	/**
	 * Return the axis value.
	 *
	 * @public
	 * @param {number} iDeviceAxis
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceAxisValue = device.getAxisValue(1);
	 */
	Device.prototype.getAxisValue = function (iDeviceAxis) {
		return this.axisValues[iDeviceAxis];
	};

	/**
	 * Return the axis name value.
	 *
	 * @public
	 * @param {string} iDeviceAxisName
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceAxisNameValue = device.getAxisNameValue(1);
	 */
	Device.prototype.getAxisNameValue = function (iDeviceAxisName) {
		return this.getAxisValue(this.getAxis(iDeviceAxisName));
	};

	/**
	 * Return the button id.
	 *
	 * @public
	 * @param {string} iDeviceButtonName
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceButton = device.getButton('button1');
	 */
	Device.prototype.getButton = function (iDeviceButtonName) {
		var button = -1;

		if (iDeviceButtonName !== '') {
			button = this.buttonNames.indexOf(iDeviceButtonName);
		}

		return button;
	};

	/**
	 * Return the button name.
	 *
	 * @public
	 * @param {number} iDeviceButton
	 * @return {string}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceButtonName = device.getButtonName(1);
	 */
	Device.prototype.getButtonName = function (iDeviceButton) {
		return this.buttonNames[iDeviceButton];
	};

	/**
	 * Return the list of buttons currently pressed from the device.</br>
	 * Each element is a number corresponding to the id.
	 *
	 * @public
	 * @return {Array.<number>}
	 * @see EP.Device#isButtonPressed
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var buttonsPressed = device.getButtonsPressed();
	 * for(var i=0; i&lt;buttonsPressed.length; i++) {
	 *	// buttonsPressed[i] is pressed
	 * }
	 */
	Device.prototype.getButtonsPressed = function () {
		return this.buttonsPressed.slice(0);
	};

	/**
	 * Deprecated ! Please use getButtonsPressed instead !
	 *
	 * @deprecated R2019x
	 * @public
	 * @return {Array.<number>}
	 * @see EP.Device#getButtonsPressed
	 */
	Device.prototype.getButtonPressed = function () {
		return this.getButtonsPressed();
	};

	/**
	 * Return the list of buttons name currently pressed from the device.</br>
	 * Each element is a string corresponding to the name.
	 *
	 * @public
	 * @return {Array.<string>}
	 * @see EP.Device#isButtonNamePressed
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var buttonNamePressed = device.getButtonNamePressed();
	 * for(var i=0; i&lt;buttonNamePressed.length; i++) {
	 *	// buttonNamePressed[i] is pressed
	 * }
	 */
	Device.prototype.getButtonsNamePressed = function () {
		var buttonsNamePressed = [];
		for (var i = 0; i < this.buttonsPressed.length; i++) {
			var buttonName = this.getButtonName(this.buttonsPressed[i]);
			if (buttonName !== '') {
				buttonsNamePressed.push(buttonName);
			}
		}
		return buttonsNamePressed;
	};

	/**
	 * Deprecated ! Please use getButtonsNamePressed instead !
	 *
	 * @deprecated R2019x
	 * @public
	 * @return {Array.<string>}
	 * @see EP.Device#getButtonsNamePressed
	 */
	Device.prototype.getButtonNamePressed = function () {
		return this.getButtonsNamePressed();
	};

	/**
	 * Check if the button specified is pressed.
	 *
	 * @public
	 * @param {number} iDeviceButton
	 * @return {boolean}
	 * @see EP.Device#getButtonsPressed
	 * @example
	 * var device = EP.Devices.getDevice();
	 * if(device.isButtonPressed(1)) {
	 *	// device button 1 is pressed
	 * }
	 */
	Device.prototype.isButtonPressed = function (iDeviceButton) {
		return this.buttonsPressed.indexOf(iDeviceButton) !== -1;
	};

	/**
	 * Check if the button name specified is pressed.
	 *
	 * @public
	 * @param {string} iDeviceButtonName
	 * @return {boolean}
	 * @see EP.Device#getButtonNamePressed
	 * @example
	 * var device = EP.Devices.getDevice();
	 * if(device.isButtonNamePressed('button1')) {
	 *	// device button 1 is pressed
	 * }
	 */
	Device.prototype.isButtonNamePressed = function (iDeviceButtonName) {
		return this.isButtonPressed(this.getButton(iDeviceButtonName));
	};

	/**
	 * Return the tracker id.
	 *
	 * @public
	 * @param {string} iDeviceTrackerName
	 * @return {number}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceTracker = device.getTracker('tracker0');
	 */
	Device.prototype.getTracker = function (iDeviceTrackerName) {
		var tracker = -1;

		if (iDeviceTrackerName !== '') {
			tracker = this.trackerNames.indexOf(iDeviceTrackerName);
		}

		return tracker;
	};

	/**
	 * Return the tracker name.
	 *
	 * @public
	 * @param {number} iDeviceTracker
	 * @return {string}
	 * @example
	 * var device = EP.Devices.getDevice();
	 * var deviceTrackerName = device.getTrackerName(0);
	 */
	Device.prototype.getTrackerName = function (iDeviceTracker) {
		return this.trackerNames[iDeviceTracker];
	};

	/**
	 * Return the tracker value.
	 *
	 * @public
	 * @param {number} iDeviceTracker
	 * @return {DSMath.Transformation}
	 * @example
	 * var device = EP.Devices.getDevice(0);
	 * var deviceTrackerValue = device.getTrackerValue(0);
	 */
	Device.prototype.getTrackerValue = function (iDeviceTracker) {
		return this.trackerValues[iDeviceTracker];
	};

	/**
	 * Return the tracker name value.
	 *
	 * @public
	 * @param {string} iDeviceTrackerName
	 * @return {DSMath.Transformation}
	 * @example
	 * var device = EP.Devices.getDevice(0);
	 * var deviceTrackerNameValue = device.getTrackerNameValue('tracker0');
	 */
	Device.prototype.getTrackerNameValue = function (iDeviceTrackerName) {
		return this.getTrackerValue(this.getTracker(iDeviceTrackerName));
	};

	// Expose in EP namespace.
	EP.Device = Device;

	return Device;
});
