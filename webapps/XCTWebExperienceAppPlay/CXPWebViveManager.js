define('DS/XCTWebExperienceAppPlay/CXPWebViveManager', ['DS/StudioIV/StuViveManager', 'DS/XCTWebExperienceAppPlay/CXPWebHMDWrapper'], function (StuViveManager, CXPWebHMDWrapper) {
    'use strict';

    StuViveManager.prototype.buildHMDWrapper = function () {
        return new CXPWebHMDWrapper();
    };

    return StuViveManager;
});
