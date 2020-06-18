/*global define*/
define('DS/StuRaytrace/StuRaytraceNA', ['DS/StuRaytrace/StuRaytrace'], function (StuRaytraceJS) {
    'use strict';

    StuRaytraceJS.prototype.buildWrapper = function () {      
        return new stu__StudioRaytraceWrapper();
    }

    return StuRaytraceJS;
});
