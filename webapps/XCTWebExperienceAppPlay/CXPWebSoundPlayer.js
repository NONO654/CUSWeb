define('DS/XCTWebExperienceAppPlay/CXPWebSoundPlayer', ['DS/StuSound/StuSoundPlayer', 'DS/XCTWebExperienceAppPlay/CXPWebSoundSourceWrapper'], 
    function (StuSoundPlayer, CXPWebSoundSourceWrapper) {
    'use strict';

    StuSoundPlayer.prototype.buildWrapper = function () {
        return new CXPWebSoundSourceWrapper();
    };

    return StuSoundPlayer;
});

