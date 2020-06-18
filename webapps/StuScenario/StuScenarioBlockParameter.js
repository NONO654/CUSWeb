
define('DS/StuScenario/StuScenarioBlockParameter', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
     * @exports ScenarioBlockParameter
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Instance
     * @memberof STU
	 * @alias STU.ScenarioBlockParameter
     */
    var ScenarioBlockParameter = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "ScenarioBlockParameter";
    };

    ScenarioBlockParameter.prototype = new Instance();
    ScenarioBlockParameter.prototype.constructor = ScenarioBlockParameter;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} instance object corresponding to the experience
    */
    ScenarioBlockParameter.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    
    
    // Expose in STU namespace.
    STU.ScenarioBlockParameter = ScenarioBlockParameter;

    return ScenarioBlockParameter;
});

define('StuScenario/StuScenarioBlockParameter', ['DS/StuScenario/StuScenarioBlockParameter'], function (ScenarioBlockParameter) {
    'use strict';

    return ScenarioBlockParameter;
});
