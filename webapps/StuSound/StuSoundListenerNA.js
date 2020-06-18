/*global define*/
define('DS/StuSound/StuSoundListenerNA', ['DS/StuSound/StuSoundListener'], function (StuSoundListenerJS) {
    'use strict';

    StuSoundListenerJS.prototype.buildWrapper = function () {
        return new stu__SoundListenerWrapper();
    }

    return StuSoundListenerJS;
});
