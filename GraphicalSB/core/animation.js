/*jslint plusplus:true*/

var swv6 = swv6 || {};
swv6.animation = swv6.animation || {};


swv6.animation.matrix = (function () {
    'use strict';
    var active = {}, // map of active animation timers, keyed by element id.
        getSVG = function () {
            var svg = document.getElementsByTagName('svg')[0];
            getSVG = function () {
                return svg;
            };
            return svg;
        };

    return function (start, end, t, callback, key) {
        
        // TODO: devise an algorithm that calculates animation duration based on magnitude of 
        //       transformation that is being requested.
        
        var fn,
            da = end.a - start.a, //   change from original to final values.
            db = end.b - start.b,
            dc = end.c - start.c,
            dd = end.d - start.d,
            de = end.e - start.e,
            df = end.f - start.f;

        fn = function (pct) {
            var matrix;

            matrix = getSVG().createSVGMatrix();
            matrix.a = start.a + (da * pct);
            matrix.b = start.b + (db * pct);
            matrix.c = start.c + (dc * pct);
            matrix.d = start.d + (dd * pct);
            matrix.e = start.e + (de * pct);
            matrix.f = start.f + (df * pct);
            
            callback(matrix);
        };
        
        swv6.animation.animation(t, fn, key);

    };
}());

swv6.animation.animation = (function () {
    'use strict';
    var active = {}; // map of active animation timers, keyed by element id.


    return function (t, callback, key) {
        var t0, interval, fn;
        
        // kill any existing animations with this key.
        if (key) {
            interval = active[key];
            if (interval) {
                window.cancelAnimationFrame(interval);
                delete active[key];
            }
        }

        fn = function () {
            var now = Date.now(),
                pct,
                matrix;

            if (!t0) {
                // This little nicety ensures we get an event w/ a '0' pct value first,
                //    just because it's sometimes handy.
                t0 = Date.now();
                pct = 0;
            } else {
                pct = (now - t0) / t;
            }
                
            if (pct >= 1) {
                pct = 1;
            } else {
                interval = window.requestAnimationFrame(fn);
            }

            callback(pct);
        };
        fn();

        if (key) {
            active[key] = interval; 
        }
        
    };
}());
