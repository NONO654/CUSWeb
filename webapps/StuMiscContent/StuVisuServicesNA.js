/*global define*/
define('DS/StuMiscContent/StuVisuServicesNA', ['DS/StuMiscContent/StuVisuServices'], function (StuVisuServicesJS) {
    'use strict';

    StuVisuServicesJS.prototype.build = function () {
        return new StuVisuServices();
    }

    return StuVisuServicesJS;
});
