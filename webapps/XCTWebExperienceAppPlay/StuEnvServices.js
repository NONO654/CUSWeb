define('DS/XCTWebExperienceAppPlay/StuEnvServices', ['DS/StuCore/StuEnvServices'], function (StuEnvServices) {
    'use strict';

    StuEnvServices.prototype.CATGetEnv = function (iEnvVariableName) {
        return localStorage.getItem(iEnvVariableName);
    };
});

