/* global define */
define('DS/StuCameras/StuNavigationNA', ['DS/StuCameras/StuNavigation'], function (Navigation) {
    'use strict';

    Navigation.prototype.buildReticule = function () {
        return new stu__ReticuleWidget();
    };

    return Navigation;
});

define('StuCameras/StuNavigationNA', ['DS/StuCameras/StuNavigationNA'], function (Navigation) {
    'use strict';

    return Navigation;
});
