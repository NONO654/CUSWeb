
define('DS/StuModel/StuActorActivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuActorEvent'], function (STU, ActorEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Actor.
	 * It occurs when an actor is activated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Actor.
	 * In order to get notified, you need to add a listener as STU.ActorActivateEvent type on the corresponding STU.Actor or on the EP.EventServices.
	 *
	 * @exports ActorActivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.ActorEvent
	 * @memberof STU
	 * @alias STU.ActorActivateEvent
	 */
	var ActorActivateEvent = function () {
	
	    ActorEvent.call(this);
	};
	
	ActorActivateEvent.prototype = new ActorEvent();
	ActorActivateEvent.prototype.constructor = ActorActivateEvent;
	ActorActivateEvent.prototype.type = 'ActorActivateEvent';
	
	// Expose in STU namespace.
	STU.ActorActivateEvent = ActorActivateEvent;

	EP.EventServices.registerEvent(ActorActivateEvent);

	return ActorActivateEvent;
});

define('StuModel/StuActorActivateEvent', ['DS/StuModel/StuActorActivateEvent'], function (ActorActivateEvent) {
    'use strict';

    return ActorActivateEvent;
});
