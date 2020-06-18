
define('DS/StuModel/StuActorDeactivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuActorEvent'], function (STU, ActorEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Actor.
	 * It occurs when an actor is deactivated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Actor.
	 * In order to get notified, you need to add a listener as STU.ActorDeactivateEvent type on the corresponding STU.Actor or on the EP.EventServices.
	 *
	 * @exports ActorDeactivateEvent
	 * @class
	 * @constructor
	 * @public
     * @noinstancector 
	 * @extends STU.ActorEvent
	 * @memberof STU
	 * @alias STU.ActorDeactivateEvent
	 */
	var ActorDeactivateEvent = function () {
	
	    ActorEvent.call(this);
	};
	
	ActorDeactivateEvent.prototype = new ActorEvent();
	ActorDeactivateEvent.prototype.constructor = ActorDeactivateEvent;
	ActorDeactivateEvent.prototype.type = 'ActorDeactivateEvent';
	
	// Expose in STU namespace.
	STU.ActorDeactivateEvent = ActorDeactivateEvent;

	EP.EventServices.registerEvent(ActorDeactivateEvent);

	return ActorDeactivateEvent;
});

define('StuModel/StuActorDeactivateEvent', ['DS/StuModel/StuActorDeactivateEvent'], function (ActorDeactivateEvent) {
    'use strict';

    return ActorDeactivateEvent;
});
