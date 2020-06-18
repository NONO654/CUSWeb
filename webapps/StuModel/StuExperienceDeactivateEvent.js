
define('DS/StuModel/StuExperienceDeactivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuExperienceEvent'], function (STU, ExperienceEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Experience.
	 * It occurs when an experience is deactivated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Experience.
	 * In order to get notified, you need to add a listener as STU.ExperienceDeactivateEvent type on the corresponding STU.Experience or on the EP.EventServices.
	 *
	 * @exports ExperienceDeactivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @private
	 * @extends STU.ExperienceEvent
	 * @memberof STU
	 */
	var ExperienceDeactivateEvent = function () {
	
	    ExperienceEvent.call(this);
	};
	
	ExperienceDeactivateEvent.prototype = new ExperienceEvent();
	ExperienceDeactivateEvent.prototype.constructor = ExperienceDeactivateEvent;
	ExperienceDeactivateEvent.prototype.type = 'ExperienceDeactivateEvent';
	
	// Expose in STU namespace.
	STU.ExperienceDeactivateEvent = ExperienceDeactivateEvent;

	EP.EventServices.registerEvent(ExperienceDeactivateEvent);

	return ExperienceDeactivateEvent;
});

define('StuModel/StuExperienceDeactivateEvent', ['DS/StuModel/StuExperienceDeactivateEvent'], function (ExperienceDeactivateEvent) {
    'use strict';

    return ExperienceDeactivateEvent;
});
