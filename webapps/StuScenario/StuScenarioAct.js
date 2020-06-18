define('DS/StuScenario/StuScenarioAct',
    ['DS/StuCore/StuContext',
        'DS/StuModel/StuActor',
        'DS/EPEventServices/EPEventServices'],
    function (STU, Actor, EventServices) {
    'use strict';

    /*****************************************************************************
    Instance dedicated to act definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe a sub part of the wizarded scenario object.
    *
    * @exports ScenarioAct
    * @class 
    * @constructor
    * @public
    * @extends STU.Actor
    * @memberof STU
    * @alias STU.ScenarioAct
    */
    var ScenarioAct = function () {
        Actor.call(this);
        this.name = "ScenarioAct";

    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    ScenarioAct.prototype = new Actor();
    ScenarioAct.prototype.constructor = ScenarioAct;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////

    /**
    * Get the natural language behavior owned by this STU.ScenarioAct.
    *
    * @method
    * @private
    * @return {STU.NaturalLanguage}
    */
    ScenarioAct.prototype.getNL = function () {
        return this.getBehaviorByType(STU.NaturalLanguage);
    };

    /**
    * Finish this STU.ScenarioAct
    * As soon as an act is considered as finished the next one is started by the wizarded scenario.
    *
    * @method
    * @public
    */
    ScenarioAct.prototype.finishes = function () {
        // delegate scenario
        var parentScenario = this.getParent();
        if (parentScenario.acts !== null) {
            parentScenario.activateNextAct(this);
        }
    };

    /**
    * Start this STU.ScenarioAct
    * It will stop the current act and start this one instead.
    *
    * @method
    * @public
    */
    ScenarioAct.prototype.starts = function () {
        var parentScenario = this.getParent();
        if (parentScenario.acts !== null) {
            var currentAct = parentScenario.GetCurrentAct();
            currentAct.deactivate();
        }
        this.initialize();
        this.activate();

    };


    ScenarioAct.prototype.onActivate = function () {
        Actor.prototype.onActivate.call(this);
        // broadcast EPEvent ScenarioActActivateEvent
        var actActivatedCtor = EventServices.getEventByType('ScenarioActActivateEvent');
        if (actActivatedCtor !== undefined && actActivatedCtor !== null) {
            var actActivatedEvent = new actActivatedCtor();
            actActivatedEvent.setAct(this);
            EventServices.dispatchEvent(actActivatedEvent);
        }
    }

    ScenarioAct.prototype.onDeactivate = function () {
        // broadcast EPEvent ScenarioActDeactivateEvent
        var actDeactivatedCtor = EventServices.getEventByType('ScenarioActDeactivateEvent');
        if (actDeactivatedCtor !== undefined && actDeactivatedCtor !== null) {
            var actDeactivatedEvent = new actDeactivatedCtor();
            actDeactivatedEvent.setAct(this);
            EventServices.dispatchEvent(actDeactivatedEvent);
        }

        Actor.prototype.onDeactivate.call(this);
    }

    // Expose only those entities in STU namespace.
    STU.ScenarioAct = ScenarioAct;

    return ScenarioAct;
    });

define('StuScenario/StuScenarioAct', ['DS/StuScenario/StuScenarioAct'], function (ScenarioAct) {
    'use strict';

    return ScenarioAct;
});
