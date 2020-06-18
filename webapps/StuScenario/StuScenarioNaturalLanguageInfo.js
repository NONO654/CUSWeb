
define('DS/StuScenario/StuScenarioNaturalLanguageInfo', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';

    /**
     * @exports ScenarioNaturalLanguageInfo
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Instance
     * @memberof STU
	 * @alias STU.ScenarioNaturalLanguageInfo
     */
    var ScenarioNaturalLanguageInfo = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "ScenarioNaturalLanguageInfo";
    };

    ScenarioNaturalLanguageInfo.prototype = new Instance();
    ScenarioNaturalLanguageInfo.prototype.constructor = ScenarioNaturalLanguageInfo;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} Instance object corresponding to the experience
    */
    ScenarioNaturalLanguageInfo.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };
    

    // Expose in STU namespace.
    STU.ScenarioNaturalLanguageInfo = ScenarioNaturalLanguageInfo;

    return ScenarioNaturalLanguageInfo;
});

define('StuScenario/StuScenarioNaturalLanguageInfo', ['DS/StuScenario/StuScenarioNaturalLanguageInfo'], function (ScenarioNaturalLanguageInfo) {
    'use strict';

    return ScenarioNaturalLanguageInfo;
});
