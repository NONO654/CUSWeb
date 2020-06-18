/*global define*/
define('DS/StuCore/StuEnvServicesNA', ['DS/StuCore/StuEnvServices'], function (StuEnvServicesJS) {
    'use strict';

    StuEnvServicesJS.prototype.CATGetEnv = function (iEnvVariableName) {
        var myEnvServices = new StuEnvServices();
        return myEnvServices.CATGetEnv(iEnvVariableName);
    }
});
