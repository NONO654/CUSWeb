
define('DS/StuModel/StuExperienceEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent'], function (STU, Event) {
	'use strict';

	/**
	 * Describe an event generated from a STU.Experience.
	 * It occurs when an experience is processing.
	 * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on the corresponding STU.Experience.
	 * In order to get notified, you need to add a listener as STU.ExperienceEvent type on the corresponding STU.Experience or on the EP.EventServices.
	 *
	 * @exports ExperienceEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @private
	 * @extends EP.Event
	 * @memberof STU
	 * @alias STU.ExperienceEvent
	 */
	var ExperienceEvent = function () {
	
	    Event.call(this);

	    /**
         * The experience.
         * 
         * @member
		 * @private
         * @type {STU.Experience}
         */
	    this.experience;
	};
	
	ExperienceEvent.prototype = new Event();
	ExperienceEvent.prototype.constructor = ExperienceEvent;
	ExperienceEvent.prototype.type = 'ExperienceEvent';

	/**
	 * Set the experience.
	 * 
	 * @method
	 * @private
	 * @param {STU.Experience} iExperience
	 */
	ExperienceEvent.prototype.setExperience = function (iExperience) {
		this.experience = iExperience;
	};

	/**
	 * Return the experience.
	 * 
	 * @method
	 * @private
	 * @return {STU.Experience}
	 */
	ExperienceEvent.prototype.getExperience = function () {
		return this.experience;
	};
	
	// Expose in STU namespace.
	STU.ExperienceEvent = ExperienceEvent;

	EP.EventServices.registerEvent(ExperienceEvent);

	return ExperienceEvent;
});

define('StuModel/StuExperienceEvent', ['DS/StuModel/StuExperienceEvent'], function (ExperienceEvent) {
    'use strict';

    return ExperienceEvent;
});
