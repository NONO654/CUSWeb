define('DS/XCTWebExperienceAppPlay/CXPWebRaytrace', ['DS/StuRaytrace/StuRaytrace', 'DS/XCTWebExperienceAppPlay/CXPWebRaytraceWrapper'], function (StuRaytrace, CXPWebRaytraceWrapper) {
    'use strict';

    StuRaytrace.prototype.buildWrapper = function () {
        return new CXPWebRaytraceWrapper();
    };
});

