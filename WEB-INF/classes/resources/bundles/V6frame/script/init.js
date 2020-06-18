/**
 * @overview V6frame init script.
 * @author Abdoulaye DIONG <w38@3ds.com>
 * @author Clement MORON <i52@3ds.com>
 * @author Aurelien Leboulanger <n27@3ds.com>
 */

define('V6frame/init',
    [
        // UWA
        'UWA/Core',
        'UWA/Promise',

        // WP
        'ds/log',
        'ds/bootstrap', 'ds/WidgetFactory',
        'ds/WidgetCatalog', 'TopFrame/TopFrame'
    ],

/**
 * V6frame init script.
 * @module V6frame/init
 *
 * @requires UWA/Core
 * @requires UWA/Promise
 * @requires ds/log
 * @requires ds/bootstrap
 * @requires ds/WidgetFactory
 * @requires ds/WidgetCatalog
 * @requires TopFrame
 */
function (UWA, Promise, Log, Bootstrap, WFactory, WCatalog, TopFrame) {

    'use strict';

    var exports = {},
        initSequence = function () {
            TopFrame.init({});

            WCatalog.init(document.body);
        },

        startPageMode = function () {
            var startPage = Bootstrap.getStartPageMode(),
                panel = {};

            // Should we handle a specific starting widget ?
            switch (startPage[0]) {
            case 'instance':
                panel.id = startPage[1];
                break;
            case 'widget':
                panel.data = startPage[1].data;
                panel.title = startPage[1].name;
                panel.parent = true; // to bypass the check in widget-factory
                panel.widgetId = startPage[1].id;
                break;
            default:
                panel.id = startPage[1];
                break;
            }
            return panel;
        },

        loadWidget = function (panel) {
            panel.el = UWA.createElement('div', {'class': 'module site-module'});

            // Launch the first widget
            WFactory.load(panel);


            var siteContainer = UWA.createElement('div', {'class': 'site-container'});
            siteContainer.grab(panel.el);
            siteContainer.inject(TopFrame.appContainer);
            return panel;
        };

    /**
     * The start function that is required by the bootstrap.
     * @return {Promise}
     */
    exports.start = function () {
        var deferred = Promise.deferred();

        Promise.resolve()
            .then(initSequence, Log.error)
            .then(startPageMode, Log.error)
            .then(loadWidget, Log.error)
            .then(deferred.resolve);

        // Return promise in case the next component needs to extend this start
        return deferred.promise;
    };

    return exports;
});
