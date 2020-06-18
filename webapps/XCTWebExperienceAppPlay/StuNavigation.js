/* global define */
define('DS/XCTWebExperienceAppPlay/StuNavigation', ['DS/StuCameras/StuNavigation', 'DS/XCTWebExperienceAppPlay/StuReticule'], function (Navigation, Reticule) {
    'use strict';

    Navigation.prototype.buildReticule = function () {
        return new Reticule();
    };

    return Navigation;
});
