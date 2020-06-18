/**
 * @overview I18n strings for our fw should be put here until !i18n plugin is made better.
 */

define('ds/NLSLegacy',
    [
        // UWA
        'UWA/Core'
    ],

    /**
     * I18n strings for our fw should be put here until !i18n plugin is made better.
     *
     * @module  ds/NLSLegacy
     *
     * @requires module:UWA/Core
     */
    function (UWA) {

        'use strict';

        function init () {
            UWA.i18n({
                // UWPClient\UWPClientCode.mweb\src\WidgetCatalog.js
                'Add': '@@addToMyPage@@',
                'Widget preview:': '@@widgetPreview@@',
                'This widget cannot be loaded, please try again later.': '@@cannotBeLoaded@@',

                // UWPClient\UWPClientCode.mweb\src\WidgetFactory.js
                'Unable to load this widget, please try again. If the problem persists please try another widget.': '@@UnableToLoadWidget@@',
                'userNotAllowed': '@@userNotAllowed@@',

                // UWPClient\UWPClientCode.mweb\src\UWA\Environment.js
                'Delete': '@@deleteItem@@',
                'Fullscreen': '@@fullScreenItem@@',
                'Duplicate': '@@duplicateItem@@',
                'Edit preferences': '@@editPrefTitle@@',
                'Preferences': '@@preferencesItem@@',
                'Refresh': '@@refreshItem@@',
                'Remove widget': '@@removeWidgetTitle@@',
                'Save': '@@savePrefBtn@@',
                'Share': '@@shareItem@@',
                'Unable to load the remote widget. Check the URL preference.': '@@unableLoadRemoteWidget@@',
                'Unable to parse the remote widget': '@@unableParseRemoteWidget@@',
                'Widget "{widgetName}" will be removed. Are you sure?': '@@removeWidget@@',
                'untrusted': '@@untrusted@@',
                'bulky': '@@bulky@@',
                'filtered': '@@filtered@@',

                // UWPClient\UWPClientCode.mweb\src\I18n.js
                'English': '@@English@@',
                'French': '@@French@@',
                'German': '@@German@@',
                'Japanese': '@@Japanese@@',
                'Russian': '@@Russian@@',
                'Chinese': '@@Chinese@@',

                // UWPClient\UWPClientControls.mweb\src\EditableTabview.js
                'Add new tab': '@@addNewTab@@',

                // multiple
                'Cancel': '@@cancel@@',
                'Loading...': '@@loading@@',

                // standalone
                'noAppId': '@@noAppId@@',

                // UWPClient\UWPClientLegacy.m\src\resources\bundles\wp\script\Ajax.js
                'sessionExpirationTitle': '@@sessionExpirationTitle@@',
                'sessionExpirationMessage': '@@sessionExpirationMessage@@',

                // UWPClient\UWPClientCode.mweb\src\WidgetFactory.js
                'The widget "{0}" cannot be loaded': '@@widgetNotLoaded@@'
            });
        }

        init();
    });
// Auto requiring it
require(['ds/NLSLegacy']);
