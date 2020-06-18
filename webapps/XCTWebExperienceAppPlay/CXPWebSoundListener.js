define('DS/XCTWebExperienceAppPlay/CXPWebSoundListener', ['DS/StuSound/StuSoundListener', 'DS/XCTWebExperienceAppPlay/CXPWebSoundListenerWrapper'],
    function (StuSoundListener, CXPWebSoundListenerWrapper) {
    'use strict';

    StuSoundListener.prototype.buildWrapper = function () {
        return new CXPWebSoundListenerWrapper();
    };

    return StuSoundListener;
});

