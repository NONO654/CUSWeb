
define('DS/StuScenario/StuScenarioBlockObjectParameter', ['DS/StuCore/StuContext', 'DS/StuScenario/StuScenarioBlockParameter'], function (STU, BlockParameter) {
    'use strict';


    /**
     * @exports ScenarioBlockObjectParameter
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.ScenarioBlockParameter
     * @memberof STU
	 * @alias STU.ScenarioBlockObjectParameter
     */
    var ScenarioBlockObjectParameter = function () {
        BlockParameter.call(this);

        this.CATI3DExperienceObject;

        this.name = "ScenarioBlockObjectParameter";
    };

    ScenarioBlockObjectParameter.prototype = new BlockParameter();
    ScenarioBlockObjectParameter.prototype.constructor = ScenarioBlockObjectParameter;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} Instance object corresponding to the experience
    */
    ScenarioBlockObjectParameter.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    

    // Expose in STU namespace.
    STU.ScenarioBlockObjectParameter = ScenarioBlockObjectParameter;

    return ScenarioBlockObjectParameter;
});

define('StuScenario/StuScenarioBlockObjectParameter', ['DS/StuScenario/StuScenarioBlockObjectParameter'], function (ScenarioBlockObjectParameter) {
    'use strict';

    return ScenarioBlockObjectParameter;
});
