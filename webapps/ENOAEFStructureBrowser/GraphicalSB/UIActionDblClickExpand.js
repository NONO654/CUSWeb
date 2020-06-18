/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.DblClickExpand
     * @extends swv6.ui.Action.Camera
     * TODO: description
     */
//    'use strict';
    var CLASS,
        BASE = swv6.ui.Action.Camera;

    CLASS =
        swv6.ui.Action.DblClickExpand =
        function (config) {
            
            CLASS.base.ctor.apply(this, arguments);

            this.indexPath = config.node.getIndexPath();

            this.type = config.type;

        };

    swv6.util.inherit(CLASS, BASE, {

        run: function () {
            this.store('tree');

            return CLASS.base.run.apply(this, arguments);
        },

        redo: function () {
            var that = this,
                node = this.state.visualTree.nodeFromIndexPath(this.indexPath),
                layout = this.state.visualTree.getLayout(),
                location = layout.getLocation(),
                camera = this.state.camera,
                nodeStart = {
                    x: node.getX() + (node.getWidth() / 2),
                    y: node.getY() + (node.getHeight() / 2)
                },
                vpStart = camera.getPosition().fromSceneToViewport(nodeStart.x, nodeStart.y),
                track,
                pct = 0,
                trackFn;

            // Initialize camera with dummy values.  We'll overwrite after layout is complete.
            this.setPosition(camera.getPosition());
            this.setDuration(0);

            layout.suppressLayout(true);

            switch (this.type) {
            case 'Expand':
                node.setExpanded(true);
                trackFn = function () {
                    var vpEnd = that.getTarget(location, node, camera);

                    return {
                        screen: {
                            x: node.getX() + node.getWidth() / 2,
                            y: node.getY() + node.getHeight() / 2
                        },
                        viewport: {
                            x: vpStart.x + (vpEnd.x - vpStart.x) * pct,
                            y: vpStart.y + (vpEnd.y - vpStart.y) * pct
                        }
                    };
                };
                break;

            case 'Collapse':
                node.setExpanded(false);
                trackFn = function () {
                    return {
                        screen: {
                            x: node.getX() + node.getWidth() / 2,
                            y: node.getY() + node.getHeight() / 2
                        },
                        viewport: {
                            x: vpStart.x,
                            y: vpStart.y
                        }
                    };
                };
                break;

            }

            track = camera.createPosition({
                type: 'track',
                trackFn: trackFn
            });

            layout.suppressLayout(false);
            layout.layout(500)
                .then(
                    function () {
                        that.setPosition(camera.getPosition());
                        that.setDuration(500);
                    },
                    function (err) {
                    },
                    function (update) {
                        pct = update.pct;

                        camera.setPosition(track, true);
                    }
                );

            return CLASS.base.redo.apply(this, arguments);
        },
        
        getTarget: function (location, node, camera) {
            var target,
                zoom = camera.getCurrentZoom(),
                p = camera.padding,
                vp = camera.viewport,
                vpw = vp.offsetWidth - p.left - p.right,  // width of viewport (after padding removed)
                vph = vp.offsetHeight - p.top - p.bottom, // height of viewport (after padding removed)
                cx = p.left + vpw / 2, // center x in viewport
                cy = p.top + vph / 2; // center y in viewport

            switch(location) {
            case 'Top':
                // top center
                target = {
                    x: cx,
                    y: p.top + (node.getHeight() * zoom / 2)
                };
                break;

            case 'Bottom':
                // bottom center
                target = {
                    x: cx,
                    y: p.top + vph - (node.getHeight() * zoom / 2)
                };
                break;

            case 'Left':
                target = {
                    x: p.left + (node.getWidth() * zoom / 2),
                    y: cy
                };
                break;

            case 'Right':
                target = {
                    x: p.left + vpw - (node.getWidth() * zoom / 2),
                    y: cy
                };
                break;
            }

            return target;
        }
    });

}());
