/*global define*/
define('DS/StuPhysic/StuCDSDynFactoryNA', ['DS/StuPhysic/StuCDSDynFactory'], function (StuCDSDynFactoryJS) {
    'use strict';

    StuCDSDynFactoryJS.buildCDSDynFactory = function () {
        return CDSDynCreateFactory();
    };

    StuCDSDynFactoryJS.buildCDSDynInertiaComputer = function (shape, volumicMass) {
        return CDSDynCreateInertiaComputer(shape, volumicMass);
    };

    StuCDSDynFactoryJS.removeCDSDynInertiaComputer = function (inertiaComputer) {
        return CDSDynRemoveInertiaComputer(inertiaComputer);
    };
});
