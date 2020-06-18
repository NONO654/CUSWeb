
define('DS/StuScenario/StuScenarioActEvent', ['DS/StuCore/StuContext', 'DS/EPEventServices/EPEvent', 'DS/EPEventServices/EPEventServices'], function (STU, Event, EventServices) {
	'use strict';

	/**
	 * Describe an event generated from a STU.ScenarioAct.
	 * It occurs when an act is activated.
	 * This event has specific extensions class and there are all dispatched globally on the EP.EventServices and locally on the corresponding STU.ScenarioAct.
	 * In order to get notified, you need to add a listener as STU.StuScenarioActEvent type on the corresponding STU.ScenarioAct or on the EP.EventServices.
	 *
	 * @exports ScenarioActEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends EP.Event
	 * @memberof STU
     * @alias STU.ScenarioActEvent
	 */
	var ScenarioActEvent = function () {
	
	    Event.call(this);

	    /**
         * The act.
         * 
         * @member
		 * @private
         * @type {STU.ScenarioAct}
         */
	    this.scenarioAct;
	};
	
	ScenarioActEvent.prototype = new Event();
	ScenarioActEvent.prototype.constructor = ScenarioActEvent;
	ScenarioActEvent.prototype.type = 'ScenarioActEvent';

	/**
	 * Set the scenarioAct.
	 * 
	 * @method
	 * @private
	 * @param {STU.ScenarioAct} iAct
	 */
	ScenarioActEvent.prototype.setAct = function (iAct) {
	    this.scenarioAct = iAct;
	};

	/**
	 * Return the scenarioAct.
	 * 
	 * @method
	 * @public
	 * @return {STU.ScenarioAct}
	 */
	ScenarioActEvent.prototype.getAct = function () {
		return this.scenarioAct;
	};
	
	// Expose in STU namespace.
	STU.ScenarioActEvent = ScenarioActEvent;
	EventServices.registerEvent(ScenarioActEvent);

	return ScenarioActEvent;
});

define('StuScenario/StuScenarioActEvent', ['DS/StuScenario/StuScenarioActEvent'], function (ScenarioActEvent) {
    'use strict';

    return ScenarioActEvent;
});
