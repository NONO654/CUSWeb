
define('DS/StuModel/StuBehaviorActivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehaviorEvent'], function (STU, BehaviorEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Behavior.
	 * It occurs when an behavior is activated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Behavior.
	 * In order to get notified, you need to add a listener as STU.BehaviorActivateEvent type on the corresponding STU.Behavior or on the EP.EventServices.
	 *
	 * @exports BehaviorActivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.BehaviorEvent
	 * @memberof STU
	 * @alias STU.BehaviorActivateEvent
	 */
	var BehaviorActivateEvent = function () {
	
	    BehaviorEvent.call(this);
	};
	
	BehaviorActivateEvent.prototype = new BehaviorEvent();
	BehaviorActivateEvent.prototype.constructor = BehaviorActivateEvent;
	BehaviorActivateEvent.prototype.type = 'BehaviorActivateEvent';
	
	// Expose in STU namespace.
	STU.BehaviorActivateEvent = BehaviorActivateEvent;

	EP.EventServices.registerEvent(BehaviorActivateEvent);

	return BehaviorActivateEvent;
});

define('StuModel/StuBehaviorActivateEvent', ['DS/StuModel/StuBehaviorActivateEvent'], function (BehaviorActivateEvent) {
    'use strict';

    return BehaviorActivateEvent;
});
