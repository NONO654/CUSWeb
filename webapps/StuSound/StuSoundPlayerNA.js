/*global define*/
define('DS/StuSound/StuSoundPlayerNA', ['DS/StuSound/StuSoundPlayer'], function (StuSoundPlayerJS) {
    'use strict';

    StuSoundPlayerJS.prototype.buildWrapper = function () {
        return new stu__SoundSourceWrapper();
    }

    return StuSoundPlayerJS;
});
