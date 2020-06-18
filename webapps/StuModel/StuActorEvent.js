
define('DS/StuModel/StuActorEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent'], function (STU, Event) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Actor.
	 * It occurs when an actor is processing.
	 * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on the corresponding STU.Actor.
	 * In order to get notified, you need to add a listener as STU.ActorEvent type on the corresponding STU.Actor or on the EP.EventServices.
	 *
	 * @exports ActorEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends EP.Event
	 * @memberof STU
	 * @alias STU.ActorEvent
	 */
	var ActorEvent = function () {
	
	    Event.call(this);

	    /**
         * The actor.
         * 
         * @member
		 * @private
         * @type {STU.Actor}
         */
	    this.actor;
	};
	
	ActorEvent.prototype = new Event();
	ActorEvent.prototype.constructor = ActorEvent;
	ActorEvent.prototype.type = 'ActorEvent';

	/**
	 * Set the actor.
	 * 
	 * @method
	 * @private
	 * @param {STU.Actor} iActor
	 */
	ActorEvent.prototype.setActor = function (iActor) {
		this.actor = iActor;
	};

	/**
	 * Return the actor.
	 * 
	 * @method
	 * @public
	 * @return {STU.Actor}
	 */
	ActorEvent.prototype.getActor = function () {
		return this.actor;
	};
	
	// Expose in STU namespace.
	STU.ActorEvent = ActorEvent;

	EP.EventServices.registerEvent(ActorEvent);

	return ActorEvent;
});

define('StuModel/StuActorEvent', ['DS/StuModel/StuActorEvent'], function (ActorEvent) {
    'use strict';

    return ActorEvent;
});

