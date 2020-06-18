
define('DS/StuModel/StuInstanceActivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstanceEvent'], function (STU, InstanceEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Instance.
	 * It occurs when an instance is activated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Instance.
	 * In order to get notified, you need to add a listener as STU.InstanceActivateEvent type on the corresponding STU.Instance or on the EP.EventServices.
	 *
	 * @exports InstanceActivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.InstanceEvent
	 * @memberof STU
	 * @alias STU.InstanceActivateEvent
	 */
	var InstanceActivateEvent = function () {
	
	    InstanceEvent.call(this);
	};
	
	InstanceActivateEvent.prototype = new InstanceEvent();
	InstanceActivateEvent.prototype.constructor = InstanceActivateEvent;
	InstanceActivateEvent.prototype.type = 'InstanceActivateEvent';
	
	// Expose in STU namespace.
	STU.InstanceActivateEvent = InstanceActivateEvent;

	EP.EventServices.registerEvent(InstanceActivateEvent);

	return InstanceActivateEvent;
});

define('StuModel/StuInstanceActivateEvent', ['DS/StuModel/StuInstanceActivateEvent'], function (InstanceActivateEvent) {
    'use strict';

    return InstanceActivateEvent;
});
