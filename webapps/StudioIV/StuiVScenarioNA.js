/*global define*/
define('DS/StudioIV/StuiVScenarioNA', ['DS/StudioIV/StuiVScenario'], function (StuiVScenarioJS) {
    'use strict';

    StuiVScenarioJS.prototype.buildWrapper = function () {
        return new stu__IVWrapper();
    }

    return StuiVScenarioJS;
});
