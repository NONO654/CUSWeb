define('DS/TransientWidget/Tool/TransientMessaging',
    [
    // UWA
    'UWA/Class',
    'DS/PlatformAPI/PlatformAPI'
    ],

    function (Class, PlatformAPI) {

        'use strict';

        var TransientMessaging = Class.extend({

            on: function (event, fn) {
                PlatformAPI.subscribe(event, fn);
            },

            fire: function (event, data) {
                PlatformAPI.publish(event, data);
            }
        });



        var transientMessagingInstance;

        return {
            getInstance: function () {
                if (!transientMessagingInstance)
                    transientMessagingInstance = new TransientMessaging();
                return transientMessagingInstance;
            }
        };


    });
