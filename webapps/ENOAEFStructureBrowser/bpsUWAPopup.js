define('DS/ENOAEFStructureBrowser/bpsUWAPopup',
        [
        'UWA/Core',
        'UWA/Data',
        'UWA/Utils/InterCom',
        'DS/ENOAEFStructureBrowser/bpsUWAInterCom'
    ], function (Core, Data, InterCom, bpsUWAInterCom) {
        'use strict';
        /** 
         * UWA Popup Module.
         * @exports bpsUWAPopup
         * 
         * @version 1.0
         * @author IXK
         * @since R417
         */
        var exports = {
            /**
             * This method is used to create a UWA popup div
             * 
             * @param {URL} - strURL
             * @param {Interger} - intWidth
             * @param {Interger} - intHeight
             * @param {Boolean} - bScrollbars
             * @param {String} - strPopupSize
             * @param {JSON} - uwaPopupOptions
             * 
             * @since R417
             */
            showUWAModalPopup : function (strURL, intWidth, intHeight, bScrollbars, strPopupSize, uwaPopupOptions) {
                //console.log('inside showUWAModalPopup');
                uwaPopupOptions.url = strURL;
                uwaPopupOptions.width = intWidth;
                uwaPopupOptions.height = intHeight;
                uwaPopupOptions.showScrollBars = bScrollbars;
                uwaPopupOptions.popupSize = strPopupSize;
                bpsUWAInterCom.openUWAPopup(uwaPopupOptions);
            }
        };
        return exports;
    });
