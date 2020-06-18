define('DS/ENOAEFStructureBrowser/bpsUWAInterCom',
        [
        'UWA/Core',
        'UWA/Data',
        'UWA/Utils/InterCom'
    ], function (UWACore, UWAData, UWAInterCom) {
        'use strict';
        /** 
         * UWA Intercom Module.
         * @exports bpsUWAInterCom
         * 
         * @version 1.0
         * @author IXK
         * @since R417
         */
        var exports = {
            version            : 1.0,
            /**
             * UWA server name - ifweServer
             * @public
             */
            serverName         : 'ifweServer',
            serverTarget     : top,
            socket             : UWAInterCom.Socket(),
            eventSuffix     : 'Event',
            socketSuffix     : 'Socket',
            action : {
                success     : 'Success',
                refreshCaller : 'RefreshCaller',
                error         : 'Error'
            },
            /**
             * Method to launch the popup inside 3DDashboard
             * 
             * @author IXK 
             */
            openUWAPopup : function (uwaPopupOptions) {
                uwaPopupOptions.url = uwaPopupOptions.url + '&widgetId=' + uwaPopupOptions.widgetId;
                var dispEventOpts = {};
                dispEventOpts.eventName = 'uwaPopupEvent';
                dispEventOpts.socketName = uwaPopupOptions.widgetId;
                this.dispatchUWAEvent(uwaPopupOptions, dispEventOpts);
            },
            /**
             * Method to register any UWA Handler
             * 
             * @author IXK
             */
            registerHandler : function (methodName, defOptions) {
                var socketA = new UWAInterCom.Socket('bps_handle_'+defOptions.socketName);
                socketA.subscribeServer(this.serverName, this.serverTarget, defOptions.targetOrigin);
                console.dir(defOptions);
                socketA.addListener(defOptions.eventName, function (json, info) {
                    methodName(json, info);
                });
            },
            /**
             * Method to register the Apply Handler
             * 
             * @author IXK
             */
            registerApplyHandler : function (methodName, defOptions) {
                if (defOptions === null) {
                    defOptions = {};
                }
                defOptions.socketName = 'uwaApplyHandlerSocket';
                defOptions.eventName = 'uwaApplyHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to register the Done Handler
             * 
             * @author IXK
             */
            registerDoneHandler : function (methodName) {
                var defOptions = {};
                defOptions.socketName = 'uwaDoneHandlerSocket';
                defOptions.eventName = 'uwaDoneHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to register the Cancel Handler
             * 
             * @author IXK
             */
            registerCancelHandler : function (methodName) {
                var defOptions = {};
                defOptions.socketName = 'uwaCancelHandlerSocket';
                defOptions.eventName = 'uwaCancelHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to register the Reset Handler
             * 
             * @author IXK
             */
            registerResetHandler : function (methodName) {
                var defOptions = {};
                defOptions.socketName = 'uwaResetHandlerSocket';
                defOptions.eventName = 'uwaResetHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to register the Previous Handler
             * 
             * @author IXK
             */
            registerPreviousHandler : function (methodName) {
                var defOptions = {};
                defOptions.socketName = 'uwaPreviousHandlerSocket';
                defOptions.eventName = 'uwaPreviousHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to register the Next Handler
             * 
             * @author IXK
             */
            registerNextHandler : function (methodName) {
                var defOptions = {};
                defOptions.socketName = 'uwaNextHandlerSocket';
                defOptions.eventName = 'uwaNextHandlerEvent';
                this.registerHandler(methodName, defOptions);
            },
            /**
             * Method to dispatch a event using Intercom
             * @param {Object} - JSON Data to send.
             * @param {Object} - JSON Data containing event and socket name.
             * 
             * @author IXK
             */
            dispatchUWAEvent : function (jsonData, defOptions) {
                var socketB = new UWAInterCom.Socket();
                var topWin = getTopWindow();
                var targetOrigin = topWin.document.referrer;
                //console.dir(targetOrigin);
                socketB.setDebugMode(true);
                socketB.subscribeServer(this.serverName, this.serverTarget, targetOrigin);
                console.dir(defOptions);
                //console.dir(jsonData);
                socketB.dispatchEvent(defOptions.eventName, jsonData, 'bps_dispatch_'+defOptions.socketName);
            }
        };
        return exports;
    });
