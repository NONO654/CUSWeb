define('DS/XCTWebExperienceAppPlay/CXPWebiVScenario', ['DS/StudioIV/StuiVScenario', 'DS/XCTWebExperienceAppPlay/CXPWebiVWrapper'], function (StuiVScenario, CXPWebIVWrapper) {
    'use strict';

    StuiVScenario.prototype.buildWrapper = function () {
        return new CXPWebIVWrapper();
    };

    return StuiVScenario;
});
