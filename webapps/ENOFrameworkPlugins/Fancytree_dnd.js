/*! Copyright 2014 Dassault Systèmes */
/* Configure AMD Loader to load non AMD lib
 * See requirejs shim config for references :
 *   http://requirejs.org/docs/api.html#config-shim
 */
/* global require, define, jQuery */

// if JQuery.ui has already been exported to global scope (preloaded), define it right away.
if (require.toUrl('DS/VENENOFrameworkPlugins/Fancytree_dnd').indexOf('latest') === -1) { //if we don't have latest in the path for the module
    var lFancytreePath = require.toUrl('DS/VENENOFrameworkPlugins/plugins/fancytree/latest/');
    // Remove any query strings
    var lIndexOfQuestionMark = lFancytreePath.indexOf('?');
    if (lIndexOfQuestionMark > -1) { //remove ? and what follows from the url
        lFancytreePath = lFancytreePath.substring(0, lIndexOfQuestionMark);
    }

    require.config({
        paths: {
            'DS/VENENOFrameworkPlugins/Fancytree_dnd': lFancytreePath + 'jquery.fancytree.dnd'
        },
        shim: {
            'DS/VENENOFrameworkPlugins/Fancytree_dnd': {
                deps: ['DS/ENOFrameworkPlugins/Fancytree'],
                exports: 'jQuery.ui.fancytree'
            }
        }
    });
}
define('DS/ENOFrameworkPlugins/Fancytree_dnd', ['DS/VENENOFrameworkPlugins/Fancytree_dnd'], function (dnd) {
    'use strict';
    return dnd;
});
