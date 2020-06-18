
define('DS/StuModel/StuInstanceDeactivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstanceEvent'], function (STU, InstanceEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Instance.
	 * It occurs when an instance is deactivated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Instance.
	 * In order to get notified, you need to add a listener as STU.InstanceDeactivateEvent type on the corresponding STU.Instance or on the EP.EventServices.
	 *
	 * @exports InstanceDeactivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.InstanceEvent
	 * @memberof STU
	 * @alias STU.InstanceDeactivateEvent
	 */
	var InstanceDeactivateEvent = function () {
	
	    InstanceEvent.call(this);
	};
	
	InstanceDeactivateEvent.prototype = new InstanceEvent();
	InstanceDeactivateEvent.prototype.constructor = InstanceDeactivateEvent;
	InstanceDeactivateEvent.prototype.type = 'InstanceDeactivateEvent';
	
	// Expose in STU namespace.
	STU.InstanceDeactivateEvent = InstanceDeactivateEvent;

	EP.EventServices.registerEvent(InstanceDeactivateEvent);

	return InstanceDeactivateEvent;
});

define('StuModel/StuInstanceDeactivateEvent', ['DS/StuModel/StuInstanceDeactivateEvent'], function (InstanceDeactivateEvent) {
    'use strict';

    return InstanceDeactivateEvent;
});
