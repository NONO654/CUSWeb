define('DS/TransientWidget/Tool/Mapping',
    [

    ],
    function () {
        'use strict';

        return {
            View: {
                'Transient': 'Transient',
                'TransientFloat': 'TransientFloat',
                'TransientContainer': 'TransientContainer'
            },
            TransientMessaging: {
                'Channel': 'TransientMessaging',
                'ShowWidget': 'ShowWidget',
                'CloseWidget': 'CloseWidget',
                'AddModule': 'AddModule',
                'AddModules': 'AddModules',
                'Hide': 'Hide',
                'Show': 'Show',
                'PreviewPrefUpdate': 'preview:pref.update',
                'T3DNotification': 'common.3DNotification.topic'
            },
            Selector: {
                'TransientContainer': '.preview-wrapper',
                'AppContainer': '.app-content',
                'TransientContent': '.preview-content',
                'TransientApp': 'div.preview-content .r2g-widget'
            },
            Events: {
                PreviewWidgetLoaded: 'preview:widget.loaded',
                PreviewTopBarUpdate: 'preview:topbar.update'
            }
        };
    }

);
