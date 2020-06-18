
define('DS/StuModel/StuBehaviorEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent'], function (STU, Event) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Behavior.
	 * It occurs when an behavior is processing.
	 * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on the corresponding STU.Behavior.
	 * In order to get notified, you need to add a listener as STU.BehaviorEvent type on the corresponding STU.Behavior or on the EP.EventServices.
	 *
	 * @exports BehaviorEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends EP.Event
	 * @memberof STU
	 * @alias STU.BehaviorEvent
	 */
	var BehaviorEvent = function () {
	
	    Event.call(this);

	    /**
         * The behavior.
         * 
         * @member
		 * @private
         * @type {STU.Behavior}
         */
	    this.behavior;
	};
	
	BehaviorEvent.prototype = new Event();
	BehaviorEvent.prototype.constructor = BehaviorEvent;
	BehaviorEvent.prototype.type = 'BehaviorEvent';

	/**
	 * Set the behavior.
	 * 
	 * @method
	 * @private
	 * @param {STU.Behavior} iBehavior
	 */
	BehaviorEvent.prototype.setBehavior = function (iBehavior) {
		this.behavior = iBehavior;
	};

	/**
	 * Return the behavior.
	 * 
	 * @method
	 * @public
	 * @return {STU.Behavior}
	 */
	BehaviorEvent.prototype.getBehavior = function () {
		return this.behavior;
	};
	
	// Expose in STU namespace.
	STU.BehaviorEvent = BehaviorEvent;

	EP.EventServices.registerEvent(BehaviorEvent);

	return BehaviorEvent;
});

define('StuModel/StuBehaviorEvent', ['DS/StuModel/StuBehaviorEvent'], function (BehaviorEvent) {
    'use strict';

    return BehaviorEvent;
});
