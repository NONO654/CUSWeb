/*global define*/
define('DS/StudioIV/StuViveManagerNA', ['DS/StudioIV/StuViveManager'], function (StuViveManagerJS) {
    'use strict';

    StuViveManagerJS.prototype.buildHMDWrapper = function () {
        return new stu__HMDWrapper();
    }

    return StuViveManagerJS;
});
