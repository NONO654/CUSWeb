/**
 * Require any UWA/* module as soon as it is defined to emulate previous
 * CujoJS curl behavior.
 *
 * This file should be removed as soon as we are able to load UWA without
 * defining all its module as soon as they are loaded as it hide undeclared
 * dependencies
 */

/* global UWA: true */

(function () {

    var require_define = define;

    define = function (module) {
        require_define.apply(this, Array.prototype.slice.call(arguments));
        if (module && module.substr && module.substr(0, 4) === 'UWA/') {
          require([module], function (m) {
              if (module === 'UWA/Controls/Scroller') {
                  m.prototype.defaultOptions.scrollDrag = require('UWA/Utils/Client').Features.touchEvents;
              }
          });
        }
    };
    define.amd = require_define.amd;
}());

// Redefine UWA.paths to match delivered paths
if (typeof UWA !== 'undefined' && !UWA.paths) {
    UWA.paths = {
        css: '/lib/UWA/assets/css/',
        img: '/lib/UWA/assets/img/'
    };
}
