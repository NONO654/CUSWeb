
// if JQuery.ui has already been exported to global scope (preloaded), define it right away.
if (require.toUrl('DS/VENCompareWidgetUtils/Fancytree_table').indexOf('latest') === -1) { //if we don't have latest in the path for the module
    var lFancytreePath = require.toUrl('DS/VENCompareWidgetUtils/plugins/fancytree/v2.9.0/');
    // Remove any query strings
    var lIndexOfQuestionMark = lFancytreePath.indexOf('?');
    if (lIndexOfQuestionMark > -1) { //remove ? and what follows from the url
        lFancytreePath = lFancytreePath.substring(0, lIndexOfQuestionMark);
    }

    require.config({
        paths: {
            'DS/VENCompareWidgetUtils/Fancytree': lFancytreePath + 'jquery.fancytree'
        },
        shim: {
            'DS/VENCompareWidgetUtils/Fancytree': {
                deps: ['DS/ENO6WPlugins/jQueryUI', 'DS/ENO6WPlugins/jQuery'],
                exports: 'jQuery.ui.fancytree'
            }
        }
    });
}
define('DS/CompareWidgetUtils/Fancytree', ['DS/VENCompareWidgetUtils/Fancytree'], function (tbl) {
    'use strict';
    return tbl;
});
