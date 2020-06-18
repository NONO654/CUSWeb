
define('DS/StuModel/StuInstanceEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent'], function (STU, Event) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Instance.
	 * It occurs when an instance is processing.
	 * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on the corresponding STU.Instance.
	 * In order to get notified, you need to add a listener as STU.InstanceEvent type on the corresponding STU.Instance or on the EP.EventServices.
	 *
	 * @exports InstanceEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends EP.Event
	 * @memberof STU
	 * @alias STU.InstanceEvent
	 */
	var InstanceEvent = function () {
	
	    Event.call(this);
		
		/**
         * The instance.
         * 
         * @member
		 * @private
         * @type {STU.Instance}
         */
	    this.instance;
	};
	
	InstanceEvent.prototype = new Event();
	InstanceEvent.prototype.constructor = InstanceEvent;
	InstanceEvent.prototype.type = 'InstanceEvent';

	/**
	 * Set the instance.
	 * 
	 * @method
	 * @private
	 * @param {STU.Instance} iInstance
	 */
	InstanceEvent.prototype.setInstance = function (iInstance) {
		this.instance = iInstance;
	};

	/**
	 * Return the instance.
	 * 
	 * @method
	 * @public
	 * @return {STU.Instance}
	 */
	InstanceEvent.prototype.getInstance = function () {
		return this.instance;
	};
	
	// Expose in STU namespace.
	STU.InstanceEvent = InstanceEvent;

	EP.EventServices.registerEvent(InstanceEvent);

	return InstanceEvent;
});

define('StuModel/StuInstanceEvent', ['DS/StuModel/StuInstanceEvent'], function (InstanceEvent) {
    'use strict';

    return InstanceEvent;
});
