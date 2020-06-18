/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.Isolate
     * @extends swv6.ui.Action.Camera
     * TODO: description
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Action.Camera;

    CLASS =
        swv6.ui.Action.Isolate =
        function (config) {

            CLASS.base.ctor.apply(this, arguments);

            this.setPosition({ 
                type: 'fit', 
                el: this.state.camera.scene,
                padding: this.state.camera.padding
            });
            this.setDuration(600);

            this.indexPath = config.node.getIndexPath();
        };

    swv6.util.inherit(CLASS, BASE, {

        redo: function () {
            var vt = this.state.visualTree,
                node = vt.nodeFromIndexPath(this.indexPath);

            vt.setIsolated(node);
            node.setExpanded(true, false);

            return CLASS.base.redo.apply(this, arguments);
        },

        run: function () {
            this.store('tree');

            return CLASS.base.run.apply(this, arguments);
        }

    });

}());
