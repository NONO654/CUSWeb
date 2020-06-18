define('DS/TransientWidget/Controller/Transient', [
    // UWA
    'UWA/Core',
    'UWA/Class',

    // TransientWidget
    'DS/TransientWidget/Tool/Mapping',
    'DS/TransientWidget/Tool/TransientMessaging'
],
function (
    // UWA
    UWA,
    Class,

    // TransientWidget
    Mapping,
    TransientMessaging
) {
    'use strict';

    var Transient = Class.extend({

        // Tell if this Transient instance is visible or not
        isOpen: false,

        init: function () {
            var that = this;

            TransientMessaging.getInstance().on(Mapping.TransientMessaging.ShowWidget, function () {
                that.isOpen = true;
            });

            TransientMessaging.getInstance().on(Mapping.TransientMessaging.CloseWidget, function () {
                that.isOpen = false;
            });
        },

        /**
         * Displays a transient widget.
         *
         * @param {String} widgetUrl        - Url of the transient widget or app id.
         * @param {Object} [widgetTitle=''] - Title of the transient widget.
         *                                    It will be concatenated to the widget "source" title
         *                                    (in the <title> markup).
         * @param {String|Object} [widgetData={}] - Set of preferences of the transient widget
         *                                          or the url to retrieve the preferences.
         */
        showWidget: function (widgetUrl, widgetTitle, widgetData, options) {
            function fireShowWidgetEvent () {
                TransientMessaging.getInstance().fire(
                    Mapping.TransientMessaging.ShowWidget, {
                        appId: widgetUrl,
                        title: widgetTitle,
                        data: widgetData,
                        options: options
                    }
                );
            }

            // Fire the event immediately, in case the loading of TopFrameMananger has already finished
            fireShowWidgetEvent();

            // In case the TopFrameManegr hasn't loaded yet, re-fire the event later
            require([['DS', 'PubSub', 'PubSub'].join('/')], function (PubSub) {
                PubSub.addOnce('loadedTopFrameManager', fireShowWidgetEvent);
            });

        },

        /**
         * Closes any existing transient widget.
         */
        closeWidget: function () {
            TransientMessaging.getInstance().fire(Mapping.TransientMessaging.CloseWidget);
        },

        /**
         * Hides the currently opened Preview without destroying it
         */
        hide: function () {
            TransientMessaging.getInstance().fire(Mapping.TransientMessaging.Hide);
        },

        /**
         * Tells if a transient widget is already open.
         * Can be called from either the top document or from a widget context
         * @return {Boolean} isOpen - true when transient
         */
        isWidgetOpen: function () {
            // When not inside a widget, we can use 'isOpen', since the state is being correctly updated when open & close happens
            if (!window.widget) {
                return this.isOpen;
            } else {
                // Inside an iframed widget, another instance is created. So use the widget id
                return window.widget.id && window.widget.id.contains('preview');
            }
        },

        /**
         * Show the currently opened Preview hidden by hide method
         */
        show: function () {
            TransientMessaging.getInstance().fire(Mapping.TransientMessaging.Show);
        }

    });

    return Transient;
});
