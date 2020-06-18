
define('DS/StuModel/StuBehaviorDeactivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehaviorEvent'], function (STU, BehaviorEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Behavior.
	 * It occurs when an behavior is deactivated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Behavior.
	 * In order to get notified, you need to add a listener as STU.BehaviorDeactivateEvent type on the corresponding STU.Behavior or on the EP.EventServices.
	 *
	 * @exports BehaviorDeactivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.BehaviorEvent
	 * @memberof STU
	 * @alias STU.BehaviorDeactivateEvent
	 */
	var BehaviorDeactivateEvent = function () {
	
	    BehaviorEvent.call(this);
	};
	
	BehaviorDeactivateEvent.prototype = new BehaviorEvent();
	BehaviorDeactivateEvent.prototype.constructor = BehaviorDeactivateEvent;
	BehaviorDeactivateEvent.prototype.type = 'BehaviorDeactivateEvent';
	
	// Expose in STU namespace.
	STU.BehaviorDeactivateEvent = BehaviorDeactivateEvent;

	EP.EventServices.registerEvent(BehaviorDeactivateEvent);

	return BehaviorDeactivateEvent;
});

define('StuModel/StuBehaviorDeactivateEvent', ['DS/StuModel/StuBehaviorDeactivateEvent'], function (BehaviorDeactivateEvent) {
    'use strict';

    return BehaviorDeactivateEvent;
});
