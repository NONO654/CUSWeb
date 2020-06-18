/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.ExpandGlobal
     * @extends swv6.ui.Action.Camera
     * TODO: description
     */
//    'use strict';

    var CLASS,
        BASE = swv6.ui.Action.Camera;

    CLASS =
        swv6.ui.Action.ExpandGlobal =
        function (config) {
            var vt;
            
            CLASS.base.ctor.apply(this, arguments);

            vt = this.state.visualTree;
            config.node = config.node || 
                   (this.state.isolated 
                       ? vt.nodeFromIndexPath(this.state.isolated)
                       : vt.getRoot());
            this.indexPath = config.node.getIndexPath();

            this.type = config.type;
        };

    swv6.util.inherit(CLASS, BASE, {

        // possible values: 'Expand All', 'Collapse All'
        type: undefined,

        redo: function () {
            var node = this.state.visualTree.nodeFromIndexPath(this.indexPath);

            switch (this.type) {
            case 'Expand All':
                node.setExpanded(true, true);
                break;
            case 'Collapse All':
                node.setExpanded(false, true);
                node.setExpanded(true); // expand first level of children.
                break;
            }

            return CLASS.base.redo.apply(this, arguments);
        },

        run: function () {
            var node = this.state.visualTree.nodeFromIndexPath(this.indexPath);

            // TODO: Tie this animation in with layout function.
            //       May need to wait for layout to complete before doing final fit.
            this.setPosition({ 
                type: 'fit', 
                el: this.state.camera.scene,
                padding: this.state.camera.padding
            });
            this.setDuration(1000);

            this.store('tree');

            return CLASS.base.run.apply(this, arguments);
        }
    });

}());
