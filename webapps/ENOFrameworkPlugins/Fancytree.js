/*! Copyright 2014 Dassault Systèmes */
/* Configure AMD Loader to load non AMD lib
 * See requirejs shim config for references :
 *   http://requirejs.org/docs/api.html#config-shim
 */
/* global require, define, jQuery */

// if JQuery.ui has already been exported to global scope (preloaded), define it right away.
if (typeof jQuery !== 'undefined' && typeof jQuery.ui !== 'undefined' && typeof jQuery.ui.fancytree !== 'undefined') {
    define('DS/ENOFrameworkPlugins/Fancytree', function () {
        'use strict';
        return jQuery.ui.fancytree;
    });
} else {
    // In case the module gets executed multiple times
    if (require.toUrl('DS/VENENOFrameworkPlugins/Fancytree').indexOf('latest') === -1) { //if we don't have latest in the path for the module
        var lFancytreePath = require.toUrl('DS/VENENOFrameworkPlugins/plugins/fancytree/latest/');
        // Remove any query strings
        var lIndexOfQuestionMark = lFancytreePath.indexOf('?');
        if (lIndexOfQuestionMark > -1) { //remove ? and what follows from the url
            lFancytreePath = lFancytreePath.substring(0, lIndexOfQuestionMark);
        }

        require.config({
            paths: {
                'DS/VENENOFrameworkPlugins/Fancytree': lFancytreePath + 'jquery.fancytree'
            },
            shim: {
                'DS/VENENOFrameworkPlugins/Fancytree': {
                    deps: ['DS/ENO6WPlugins/jQueryUI', 'DS/ENO6WPlugins/jQuery'],
                    exports: 'jQuery.ui.fancytree'
                }
            }
        });
    }
}
define('DS/ENOFrameworkPlugins/Fancytree', ['DS/VENENOFrameworkPlugins/Fancytree'], function (fancytree) {
    'use strict';
    return fancytree;
});
