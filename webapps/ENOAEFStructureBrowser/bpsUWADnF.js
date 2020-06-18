/***********************************/
define('DS/ENOAEFStructureBrowser/bpsUWADnF',
        [
        'UWA/Core',
        'UWA/Event',
        'UWA/Controls/Drag',
        'DS/ENOAEFStructureBrowser/bpsUWAInterCom'
    ], function (Core, Event, Drag, bpsUWAInterCom) {
        'use strict';
        var isDragging = false;
        /** 
         * UWA Drag and Follow Module.
         * @exports bpsUWADnF
         * 
         * @version 1.0
         * @author IXK
         * @since R417
         */
        var exports = {
            /**
             * This method create a Drag object and dispatches it to the widget
             * 
             * @param {Object} - options
             * 
             * @version 1.0
             * @author IXK
             * @since R417
             */
            handleDnF : function (options) {
                var drag = new Drag.Move({
                    snap: 20,
                    centerHandles : true,
                    delegate: '.object',
                    start: function () {
                        isDragging = true;
                    },
                    handles : function (context) {
                        var handle = UWA.createElement('div', {
                            'class': 'handles'
                        }).inject(context.root);
                        console.dir(context.root);
                        return handle;
                    },
                    leave: function (context) {
                        if (isDragging) {
                            drag.stop();
                            console.log('todo-create intercom');
                            var data, opts, widgetId = options.widgetId;
                            data = {};
                            data.objectId =  context.target.getAttribute('data-oid');
                            data.icon =  context.target.getAttribute('data-icon');
                            data.name = emxUICore.getText(context.target);
                            opts = {};
                            opts.eventName = 'uwaSBRowDragLeaveEvent';
                            opts.socketName = widgetId;
                            bpsUWAInterCom.dispatchUWAEvent(data, opts);
                        }
                    },
                    stop: function (context) {
                        isDragging = false;
                    }
                });
            }
        };
        return exports;
    });
