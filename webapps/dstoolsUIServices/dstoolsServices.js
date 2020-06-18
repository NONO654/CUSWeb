/* eslint-disable no-empty */
/* eslint-env browser */

'use strict';
define('DS/dstoolsUIServices/dstoolsServices', [
    'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices', 'DS/WAFData/WAFData'
], function(i3DXCompassPlatformServices, WAFData) {
    /**
	 * @summary toolbox for client-side APIs
     * @module DS/dstoolsUIServices/dstoolsServices
     * @private
     */

    var url;
    var order;
    if (typeof window.__karma__ !== 'undefined') {
        url = window.__karma__.config.json.ts.monitoring;
        order = Date.now();
        if (url === null || url === '' || url === 'undefined') {
            url = undefined;
        }
    }
    return {
        /**
         * @private
         *
         * @param {Object}   params             - parameters of getPlatformServices.
         * @param {string}   params.platformId  - An optional platform ID (Empty string, null and undefined are considered no value).
         * @param {string}   params.serviceName - An optional serviceName (Empty string, null and undefined are considered no value).
         * @param {function} params.onComplete  - Callback triggered when data is available.
         *                                        It must have one parameter to receive data. The structure of this argument is detailed in the example section.
         * @param {function} params.onFailure   - Callback triggered when data fetching fails.
         */
        getPlatformServices: function(params) {
            var result;
            try {
                if (typeof window.__karma__ !== 'undefined') {
                    var config = window.__karma__.config;
                    if (config.json !== undefined) {
                        result = config.json[params.serviceName];
                    } else {
                        result = config.config.args[0];
                    }
                }
            } catch (e) {}

            if (result !== undefined) {
                params.onComplete(window.__karma__.config.args[0]);
            } else {
                i3DXCompassPlatformServices.getPlatformServices(params);
            }
        },
        monitor: (url !== undefined) ? function(cmd, step, cb, error) {
            var time = Date.now() * 1000000;
            //var time = perfnow();
            order++;
            var usedM = (window.peformance !== undefined) ? window.peformance.memory : undefined;
            WAFData.request(url + '/monitor', {
                method: 'POST',
                data: JSON.stringify({
                    step: step,
                    event: cmd,
                    time: time,
                    order: order,
                    memory: usedM
                }),
                onComplete: function(data) {
                    if (cb) 
                        cb(data)},
                onFailure: function(data) {
                   if (error) 
                        error(data)}
            });
        } : function() {}
    };
});
