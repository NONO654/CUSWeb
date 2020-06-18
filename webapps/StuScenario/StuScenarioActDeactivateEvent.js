
define('DS/StuScenario/StuScenarioActDeactivateEvent', ['DS/StuCore/StuContext', 'DS/StuScenario/StuScenarioActEvent', 'DS/EPEventServices/EPEventServices'], function (STU, ScenarioActEvent, EventServices) {
    'use strict';

    /**
	 * Describe an event generated from a STU.ScenarioAct.
	 * It occurs when an act is deactivated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Actor.
	 * In order to get notified, you need to add a listener as STU.ScenarioActDeactivateEvent type on the corresponding STU.ScenarioAct or on the EP.EventServices.
	 *
	 * @exports ScenarioActDeactivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.ScenarioActEvent
	 * @memberof STU
	 * @alias STU.ScenarioActDeactivateEvent
	 */
    var ScenarioActDeactivateEvent = function () {

        ScenarioActEvent.call(this);
    };

    ScenarioActDeactivateEvent.prototype = new ScenarioActEvent();
    ScenarioActDeactivateEvent.prototype.constructor = ScenarioActDeactivateEvent;
    ScenarioActDeactivateEvent.prototype.type = 'ScenarioActDeactivateEvent';

    // Expose in STU namespace.
    STU.ScenarioActDeactivateEvent = ScenarioActDeactivateEvent;
    EventServices.registerEvent(ScenarioActDeactivateEvent);

    return ScenarioActDeactivateEvent;
});

define('StuScenario/StuScenarioActDeactivateEvent', ['DS/StuScenario/StuScenarioActDeactivateEvent'], function (ScenarioActDeactivateEvent) {
    'use strict';

    return ScenarioActDeactivateEvent;
});
