
define('DS/StuScenario/StuScenarioActActivateEvent', ['DS/StuCore/StuContext', 'DS/StuScenario/StuScenarioActEvent', 'DS/EPEventServices/EPEventServices'], function (STU, ScenarioActEvent, EventServices) {
    'use strict';

    /**
	 * Describe an event generated from a STU.ScenarioAct.
	 * It occurs when an act is activated.
	 * This event is dispatched globally on the EP.EventServices and locally on the corresponding STU.Actor.
	 * In order to get notified, you need to add a listener as STU.ScenarioActActivateEvent type on the corresponding STU.ScenarioAct or on the EP.EventServices.
	 *
	 * @exports ScenarioActActivateEvent
	 * @class
	 * @constructor
     * @noinstancector 
	 * @public
	 * @extends STU.ScenarioActEvent
	 * @memberof STU
	 * @alias STU.ScenarioActActivateEvent
	 */
    var ScenarioActActivateEvent = function () {

        ScenarioActEvent.call(this);
    };

    ScenarioActActivateEvent.prototype = new ScenarioActEvent();
    ScenarioActActivateEvent.prototype.constructor = ScenarioActActivateEvent;
    ScenarioActActivateEvent.prototype.type = 'ScenarioActActivateEvent';

    // Expose in STU namespace.
    STU.ScenarioActActivateEvent = ScenarioActActivateEvent;
    EventServices.registerEvent(ScenarioActActivateEvent);

    return ScenarioActActivateEvent;
});

define('StuScenario/StuScenarioActActivateEvent', ['DS/StuScenario/StuScenarioActActivateEvent'], function (ScenarioActActivateEvent) {
    'use strict';

    return ScenarioActActivateEvent;
});
