if (typeof jQuery !== 'undefined') {
        define('DS/ENOFrameworkPlugins/jQuery', function () {
            'use strict';
            return jQuery;
        });
    } else {
        // In case the module gets executed multiple times
        //if we don't have latest in the path for the module
            var lJQueryPath = require.toUrl('DS/VENENOFrameworkPlugins/jQuery');
            // Remove any query strings
            var lIndexOfQuestionMark = lJQueryPath.indexOf('?');
            if (lIndexOfQuestionMark > -1) { //remove ? and what follows from the url
                lJQueryPath = lJQueryPath.substring(0, lIndexOfQuestionMark);
            }


            require.config({
                paths: {
                    'DS/VENENOFrameworkPlugins/jQuery': lJQueryPath 
                    //'DS/VENENO6WPlugins/jQuery': lJQueryPath + 'jquery-2.1.1'
                },
                shim: {
                    'DS/VENENOFrameworkPlugins/jQuery': {
                        exports: 'jQuery'
                    }
                }
            });
        
    }
    define('DS/ENOFrameworkPlugins/jQuery', ['DS/VENENOFrameworkPlugins/jQuery'], function (jQuery) {
        'use strict';
        jQuery.noConflict();    // relinquish control of the $ variable 
        return jQuery;
    });

    
