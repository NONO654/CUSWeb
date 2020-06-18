define('DS/StuScenario/StuScenario', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /*****************************************************************************
    Component dedicated to scenario definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe a scenario object.
    *
    * @exports Scenario
    * @class 
    * @constructor
	* @noinstancector 
    * @public
    * @extends STU.Instance
    * @memberof STU
    * @alias STU.Scenario
    */
    var Scenario = function (iRenderable) {
        Instance.call(this);
        this.name = "Scenario";

    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    Scenario.prototype = new Instance();
    Scenario.prototype.constructor = Scenario;

    // Expose only those entities in STU namespace.
    STU.Scenario = Scenario;

    return Scenario;
});

define('StuScenario/StuScenario', ['DS/StuScenario/StuScenario'], function (Scenario) {
    'use strict';

    return Scenario;
});
