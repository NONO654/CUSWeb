/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.CameraLayout
     * @extends swv6.ui.Action
     * Helper class to aid in actions where layout and camera changes need to be synchronized. 
     */
//    'use strict';
    var CLASS,
        BASE = swv6.ui.Action;

    CLASS =
        swv6.ui.Action.CameraLayout =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.camera = config.state.camera;

        };

    swv6.util.inherit(CLASS, BASE, {

        redo: function () {
            CLASS.base.redo.apply(this, arguments);
            return this.updateLayoutAndCamera('redo');
        },

        run: function () {
            this.store('camera');
            this.store('tree');

            return CLASS.base.run.apply(this, arguments);
        },

        updateLayoutAndCamera: function (mode) {
            var that = this,
                layout = this.state.visualTree.getLayout(),
                undo = (mode === 'undo'),
                lastPct = undo ? 1 : 0;

            layout.suppressLayout(true);

            this.changeLayout(layout);

            layout.suppressLayout(false);

            promise = layout.layout(500);

            // let the action do tasks to prepare for camera updates, such as retrieve latest
            // reference to any node it needs.
            this.beginUpdateCamera(that.camera);

            promise.then(
                function () {},
                function (err) {},
                function (update) {
                    var pct = undo ? 1 - update.pct : update.pct;

                    that.updateCamera(that.camera, pct, lastPct);

                    lastPct = pct;
                }
            );

            return promise;
        },

        changeLayout: function (layout) {

        },

        beginUpdateCamera: function (camera) {
        },

        updateCamera: function (camera, pct, lastPct) {

        }

    });

}());

