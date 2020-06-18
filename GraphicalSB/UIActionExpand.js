/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.Expand
     * @extends swv6.ui.Action.CameraLayout
     * TODO: description
     */
//    'use strict';

    var CLASS,
        BASE = swv6.ui.Action.CameraLayout;

    CLASS =
        swv6.ui.Action.Expand =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.indexPath = config.node.getIndexPath();

            this.type = config.type;
            this.researchAfter = config.researchAfter;
        };

    swv6.util.inherit(CLASS, BASE, {

        // possible values: 'Expand', 'Collapse', 'Expand All'
        type: undefined,
/*
        updateLayoutAndCamera: function (mode) {
            var promise = CLASS.base.updateLayoutAndCamera.apply(this, arguments);

            if (this.researchAfter) {
                this.research();
            }

            return promise;
        },
*/
        changeLayout: function (layout) {
            var node = this.state.visualTree.nodeFromIndexPath(this.indexPath),
                fixNode = false;

            switch (this.type) {
            case 'Expand':
                node.setExpanded(true);
                break;

            case 'Collapse':
                fixNode = true; // hold node in place
                node.setExpanded(false);
                break;

            case 'Expand All':
                node.setExpanded(true, true);
                break;
            }

            if (fixNode) {
                this.fixNode();
            } else {
                this.expandViewToFit();
            }

        },

        fixNode: function () {
            var that = this,
                node = this.state.visualTree.nodeFromIndexPath(this.indexPath),
                layout = this.state.visualTree.getLayout(),
                location = layout.getLocation(),
                nodeStart = {
                    x: node.getX() + (node.getWidth() / 2),
                    y: node.getY() + (node.getHeight() / 2)
                },
                vpStart = this.camera.getPosition().fromSceneToViewport(nodeStart.x, nodeStart.y),
                track;

            track = this.camera.createPosition({
                type: 'track',
                trackFn: function () {
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
                }
            });

            this.updateCamera = function (camera, pct, lastPct) {
                camera.setPosition(track, true);
            };

        },

        beginUpdateCamera: function () {
            this.node = this.state.visualTree.nodeFromIndexPath(this.indexPath);
        },

        expandViewToFit: function () {
            var vt = this.state.visualTree,
                layout = vt.getLayout(),
                camera = this.camera,
                path = camera.createPath(),
                start = camera.getPosition(),
                finish = 
                    camera.createPosition({
                        type: 'box',
                        padding: camera.padding 
                    }),
                sBoxOrig = { 
                    x: vt.getX(), 
                    y: vt.getY(), 
                    width: vt.getWidth(), 
                    height: vt.getHeight() 
                },
                fovOrig = start.getFOV(camera.padding),
                offsets,
                adjustTBox;

            path.addPosition({
                time: 0,
                position: start
            });

            path.addPosition({
                time: 1,
                position: finish
            });

            sBoxOrig.right = sBoxOrig.x + sBoxOrig.width;
            sBoxOrig.bottom = sBoxOrig.y + sBoxOrig.height;

            fovOrig.right = fovOrig.x + fovOrig.width;
            fovOrig.bottom = fovOrig.y + fovOrig.height;

            offsets = {
                left: fovOrig.x - sBoxOrig.x,
                right: sBoxOrig.right - fovOrig.right,
                top: fovOrig.y - sBoxOrig.y,
                bottom: sBoxOrig.bottom - fovOrig.bottom
            };

            switch (layout.getLocation()) {
            case 'Top':
                adjustTBox = function (tBox, node) {
                    tBox.x = node.getX() + tBox.x;
                    tBox.y = node.getY();
                };
                break;

            case 'Bottom':
                adjustTBox = function (tBox, node) {
                    tBox.x = node.getX() + tBox.x;
                    tBox.y = node.getY() + node.getHeight() - tBox.height;
                };
                break;

            case 'Left':
                adjustTBox = function (tBox, node) {
                    tBox.x = node.getX();
                    tBox.y = node.getY() + tBox.y;
                };
                break;

            case 'Right':
                adjustTBox = function (tBox, node) {
                    tBox.x = node.getX() + node.getWidth() - tBox.width;
                    tBox.y = node.getY() + tBox.y;
                };
                break;
            }

            this.updateCamera = function (camera, pct, lastPct) {
                var node = this.node,
                    sBox = { 
                        x: vt.getX(), 
                        y: vt.getY(), 
                        width: vt.getWidth(), 
                        height: vt.getHeight() 
                    },                    
                    tBox = {
                        x: node.getSubtreeX(), 
                        y: node.getSubtreeY(), 
                        width: node.getSubtreeWidth(), 
                        height: node.getSubtreeHeight() 
                    },
                    left = offsets.left,
                    right = offsets.right,
                    top = offsets.top,
                    bottom = offsets.bottom,
                    diff,
                    absorb,
                    sum;

                // IE won't allow modificaton of BBox data, so we need to create a working copy.
                tBox = {
                    x: tBox.x,
                    y: tBox.y,
                    width: tBox.width,
                    height: tBox.height
                };

                // Need to adjust bounding box, as its position is not in global coordinates.
                adjustTBox(tBox, node);

                if (sBox.width > sBoxOrig.width) {
                    diff = sBox.width - sBoxOrig.width;

                    // Scene is wider.  Need to either zoom out more, or absorb the extra width in the
                    // free view space around the scene (if any exists).

                    // first try to absorb space around the scene
                    if ((right < 0) || (left < 0)) {
                        if (right >= 0) {
                            absorb = Math.min(-left, diff);
                            left += absorb;
                        } else if (left >= 0) {
                            absorb = Math.min(-right, diff);
                            right += absorb;
                        } else {
                            sum = -right + -left;
                            if (sum >= diff) {
                                absorb = diff;
                                // we split the space to be absorbed between both sides, proportional to how much
                                // free space each side has.
                                left += ((-left / sum) * diff);
                                right += ((-right / sum) * diff);
                            } else {
                                absorb = sum;
                                left = 0;
                                right = 0;
                            }
                        }
                        diff -= absorb;
                    }

                }

                if (sBox.height > sBoxOrig.height) {
                    diff = sBox.height - sBoxOrig.height;

                    // Scene is taller.  Need to either zoom out more, or absorb the extra height in the
                    // free view space around the scene (if any exists).

                    // first try to absorb space around the scene
                    if ((top < 0) || (bottom < 0)) {
                        if (top >= 0) {
                            absorb = Math.min(-bottom, diff);
                            bottom += absorb;
                        } else if (bottom >= 0) {
                            absorb = Math.min(-top, diff);
                            top += absorb;
                        } else {
                            sum = -top + -bottom;
                            if (sum >= diff) {
                                absorb = diff;
                                // we split the space to be absorbed between both sides, proportional to how much
                                // free space each side has.
                                bottom += ((-bottom / sum) * diff);
                                top += ((-top / sum) * diff);
                            } else {
                                absorb = sum;
                                bottom = 0;
                                top = 0;
                            }
                        }
                        diff -= absorb;
                    }

                }


                tBox.bottom  = sBox.height - (tBox.y + tBox.height);
                tBox.right = sBox.width - (tBox.x + tBox.width);

                left = ((left > 0) && (left > tBox.x)) ? tBox.x : left;
                right = ((right > 0) && (right > tBox.right)) ? tBox.right : right;
                top = ((top > 0) && (top > tBox.y)) ? tBox.y : top;
                bottom = ((bottom > 0) && (bottom > tBox.bottom)) ? tBox.bottom : bottom;

                finish.x = sBox.x + left;
                finish.y = sBox.y + top;
                finish.width = sBox.width - left - right;
                finish.height = sBox.height - top - bottom;

                camera.setPosition(
                    path.getPosition(pct, lastPct),
                    true
                );

            };

        }

    });

}());
