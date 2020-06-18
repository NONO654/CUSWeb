
define('DS/StuModel/StuExperienceActivateEvent', ['DS/StuCore/StuContext', 'DS/StuModel/StuExperienceEvent'], function (STU, ExperienceEvent) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Experience.
	 * It occurs when an experience is activated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Experience.
	 * In order to get notified, you need to add a listener as STU.ExperienceActivateEvent type on the corresponding STU.Experience or on the EP.EventServices.
	 *
	 * @exports ExperienceActivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @private
	 * @extends STU.ExperienceEvent
	 * @memberof STU
	 */
	var ExperienceActivateEvent = function () {
	
	    ExperienceEvent.call(this);
	};
	
	ExperienceActivateEvent.prototype = new ExperienceEvent();
	ExperienceActivateEvent.prototype.constructor = ExperienceActivateEvent;
	ExperienceActivateEvent.prototype.type = 'ExperienceActivateEvent';
	
	// Expose in STU namespace.
	STU.ExperienceActivateEvent = ExperienceActivateEvent;

	EP.EventServices.registerEvent(ExperienceActivateEvent);

	return ExperienceActivateEvent;
});

define('StuModel/StuExperienceActivateEvent', ['DS/StuModel/StuExperienceActivateEvent'], function (ExperienceActivateEvent) {
    'use strict';

    return ExperienceActivateEvent;
});
